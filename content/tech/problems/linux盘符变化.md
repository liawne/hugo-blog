+++
title = "linux盘符变化"
description = "linux 系统上磁盘盘符发生变化的几种场景，以及如何规避"
date = "2022-06-08T22:41:20+08:00"
lastmod = "2022-06-08T22:41:20+08:00"
tags = ["udev", "linux", "system"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## \# 背景
`linux` 服务器重启后盘符发生变化，导致之前以盘符写入 `/etc/fstab` 中的开机挂载项错乱，开机自启的应用将数据写入错误的磁盘。

查了一下相关信息，`linux` 系统启动，磁盘设备名称都有可能变化，这是因为驱动加载的顺序、磁盘扫描顺序都不是固定的。在系统开机时，不同的控制器并行检测，先被探测到的先分配盘符，所以盘符乱序在一些场景下属于正常现象。

> `/dev/sdx` 的表示形式长期以来一直不是驱动器的稳定标识符（实际上可能从来没有），这些是按照它们被发现的顺序分配的

### \# 盘符怎么分配的
`linux` 上的设备文件名（通常位于 `/dev/` 目录中）在每次系统启动时动态分配。当内核启动时，会检测到每个可用设备，并向 `UDEV（用户空间设备管理）` 子系统发送通知。通过将内核设备标识中的信息与 `/etc/udev/rules.d` 目录中的 `UDEV` 规则集进行比较，`UDEV` 为设备分配一个名称并创建一个设备节点，例如 `/dev/sda` 或 `/dev/mapper/mpath1`，因此应用程序可以访问设备。

### \# 固定盘符的难点
尽管 `linux` 努力在系统重新启动时保持相同的设备名称，但外部环境的变化还是会影响实际的名称显示。  
> 例如：同一 `SAN` 分区在一个客户端上可能是 `/dev/sda`，但在另一个集群节点上可能是 `/dev/sdf`，这取决于每个主机发现设备的顺序，或者哪台机器的`多路径链接（multipath link）`首先联机。  

节点通常在每次启动时以相同的顺序发现其设备，但这种方式不能确保。需要一种方法来保证持久的、可预测的设备标识。

### \# 盘符变化的几种场景

- 系统几次启动时，`raid` 卡状态有差异
- 服务器磁盘较多，`sata/ssd` 混用
- 

## \# 固定盘符的方式
### \# 通过 lable 挂载
许多文件系统类型支持将任意字符串或标签与每个文件系统相关联。以 `ext3` 文件系统举例说明：
```bash 
# 获取 label
$ /sbin/e2label /dev/sda5
/home

# 配置 /etc/fstab 挂载
LABEL=/HOME /home auto defaults 0 0
```

### \# 通过 uuid 挂载
许多文件系统类型为每个格式化的磁盘分区分配一个`通用唯一标识符（Universally Unique Identifier（UUID））`。`UUID` 通常是自动分配的，不建议手动更改该值。还是以 `ext3` 文件系统为例说明：
```bash 
# 获取 uuid
$ /sbin/blkid /dev/sda5
/dev/sda5: LABEL="/home" UUID="0c960108-7649-4d8c-a28c-2f75e2f906d3" SEC_TYPE="ext2" TYPE="ext3"

# 配置 /etc/fstab 挂载
UUID=0c96010876494d8ca28c2f75e2f906d3 /home  ext3  defaults 0 0
```

### \# 使用 udev 规则集
最灵活同时配置难度高一些的方式是使用 `udev`，这种方式可以配置持久的、可预测的设备名称。这涉及创建 `udev` 匹配规则，该规则使用设备属性来识别设备，然后为其创建设备节点。通常情况下，该规则只是为内核分配的实际`低级设备节点（low-level device node）`创建一个符号链接。

**使用 multipath 的场景**  
这是用于实现`设备映射器多路径设备（device mapper multipath devices）`的技术。
内核创建一个 `/dev/dm-x` 设备；然后 `udev` 规则和`多路径守护进程（multipathing daemon）`创建 `/dev/mpath/` 链接回 `/dev/dm-x` 设备；然后创建 `/dev/mapper/mpathN` 或 `/dev/mapper/[uuid]` 链接。

在使用 `multipath` 的场景下，创建哪种类型的 `/dev/mapper/` 文件名由 `/etc/multipath.conf` 文件 `user_friendly_names` 设置控制。 默认设置是：
```editorconfig
default {
    user_friendly_names yes
}
```
使用该配置会创建完全没有意义的 `/dev/mapper/mpathN` 名称。建议注释掉这一项配置，这样可以直接使用 `/dev/mapper/xxxx` 名称，路径可能更难输出，但至少可以在所有集群节点上移植。

**udev rules文件规则**  
下面是一个 `udev` 匹配规则的示例。  
该行以一系列谓词或`匹配表达式（matching expressions）`开始，由 `==` 运算符标记。 如果所有谓词都与已发现设备的谓词匹配，则采取 `=` 子句表示的操作。

```editorconfig
SYSFS{vendor}=="iriver" SYSFS{model}=="T10" OWNER="user" MODE="0600" SYMLINK+="iriver%n"
```
示例内容是将第一个 `IRiver T10` 播放器插入 `USB` 端口时创建符号链接 `/dev/iriver0`。 该设备文件访问权限 `0600` ，用户为 `user`。   
首先，`USB` 子系统发现设备已插入并通知内核，发现的有关设备的属性也会传递给内核; 这些信息最终到达 `UDEV` 子系统，该子系统开始读取 `/etc/udev/rules.d` 中的规则集并将设备属性与每个规则的谓词进行匹配。 如果所有谓词都与规则匹配，则执行该规则指定的任何操作。

编写 `UDEV` 规则的挑战部分是了解哪些属性可用，以便规则可以正确识别设备。`udevinfo （或者 udevadm info）` 可以显示规则可用的设备名称和属性。
```bash 
# 使用 udevinfo 命令
$ /usr/bin/udevinfo -q all -p /block/sdb
P: /block/sdb
N: sdb
S: disk/by-id/usb-iriver_T10
S: disk/by-path/pci-0000:00:07.2-usb-0:1:1.0-scsi-0:0:0:0
E: ID_VENDOR=iriver
E: ID_MODEL=T10
E: ID_REVISION=1.00
E: ID_SERIAL=iriver_T10
E: ID_TYPE=disk
E: ID_BUS=usb
E: ID_PATH=pci-0000:00:07.2-usb-0:1:1.0-scsi-0:0:0:0

# 使用 udevadm info
$ udevadm info /dev/loop0
P: /devices/virtual/block/loop0
N: loop0
L: 0
E: DEVPATH=/devices/virtual/block/loop0
E: DEVNAME=/dev/loop0
E: DEVTYPE=disk
E: DISKSEQ=2
E: MAJOR=7
E: MINOR=0
E: SUBSYSTEM=block
E: USEC_INITIALIZED=1108575
E: ID_FS_VERSION=4.0
E: ID_FS_TYPE=squashfs
E: ID_FS_USAGE=filesystem
E: TAGS=:systemd:
E: CURRENT_TAGS=:systemd:
```
{{<notice info>}}udevinfo 命令中路径是相对于 `/sys/` 目录的，而不是传统的根目录，完整的文件名是 `/sys/block/sdb`。{{</notice>}}

选择合适属性集去配置，不要过多或过少，能确定匹配设备即可;我们在这里的选择是使用供应商名称和型号名称，可以使用任何对象设备的属性集进行设置。   
确定好谓词和操作后，将 `rules` 文件放在 `/etc/udev/rules.d` 目录中。不要修改系统原有的 `rules` 文件，否则更改可能会在包更新时丢失。

## \# 其他
### \# 参考内容
本文内容参考自：
- [解析linux下磁盘乱序的问题](https://blog.51cto.com/gehailong/1546206)
- [What is udev and how do you write custom udev rules in RHEL7 ?](https://access.redhat.com/solutions/1135513)
- [Inconsistent Device Names Across Reboot Cause Mount Failure Or Incorrect Mount in Linux](https://www.thegeekdiary.com/inconsistent-device-names-across-reboot-cause-mount-failure-or-incorrect-mount-in-linux/)