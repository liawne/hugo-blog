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
下面是一个 `udev` 匹配规则（centos7之前版本适用）的示例。  
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
```
{{<notice info>}}udevinfo 命令中路径是相对于 `/sys/` 目录的，而不是传统的根目录，完整的文件名是 `/sys/block/sdb`。{{</notice>}}

选择合适属性集去配置，不要过多或过少，能确定匹配设备即可;我们在这里选择使用供应商名称和型号名称，可以使用任何对象设备的属性集进行设置。   
确定好谓词和操作后，将 `rules` 文件放在 `/etc/udev/rules.d` 目录中。不要修改系统原有的 `rules` 文件，否则更改可能会在包更新时丢失。

## \# udev 相关内容
`rhel7（centos7）` 和之前版本 `rhel（centos)` 上的 `udev` 版本之间的 `udev` 规则语法略有不同。  

{{<notice warning>}}本文只讨论 `rhel7/8和rhel6`，对 `rhel5/9` 的 `udev` 配置不在讨论范围内。{{</notice>}}

### rhel7(centos7) 中的 udev 规则配置
要生成拥有唯一名称的磁盘，需要为目标磁盘配置相应的 `规则（udev）`。每个 `udev` 规则由三部分组成：
>(1)**ACTION**s (2)**FILTER**s (3)**CHANGE**s

**ACTION**s(动作):  或何时应用规则。最常见的触发操作是 `add` 和/或 `change`。
**FILTER**s(过滤器): 或如何识别目标磁盘以应用更改。有几种常用的磁盘过滤方法，包括通过`子系统(subsystem)`和 wwid（或其他唯一标识符）。一些过滤器生效范围很广，因为要应用的更改会跨多个磁盘完成，例如更改磁盘上的所有者或访问权限。然而，更常见的是过滤器针对单个磁盘，为此，通常使用一些唯一的标识符，如序列号或 `wwid`。  
**CHANGE**s(更改): 或者我们想用设备做什么。最常见的更改是创建一个唯一且持久的设备名称，然后应用程序可以使用该名称。  

如下是示例：
```udev
|<--- ACTIONs ---->|  |<-------------------- FILTERs ------------------->|    |<--------- CHANGEs ---------------->|
ACTION=="add|change", KERNEL=="sd*", ENV{ID_SCSI_SERIAL}==<serial-number>",   SYMLINK+="<my-persistent-disk-name>%n"
ACTION=="add|change", KERNEL=="sd*", ENV{ID_SCSI_SERIAL}=="50014380212E90E0", SYMLINK+="data.A%n"
```

{{<notice info>}}1.`%n` 是分区号，所以如果 `sda` 是上面 `FILTER` 识别的磁盘，那么 `sda`、`sda1`、`sda2` 将同时创建 `data.A`、`data.A1`、`data.A2` 等。<br>2. `NAME udev` 不要使用内核已经使用的名称（例如 `sd* dm* st* nt* eth*` 等）。 这种使用不受支持并且可能会导致问题，`SYMLINK` 值 `my-persistent-disk-name` 应该是唯一的，而不是内核已经使用的东西。{{</notice>}}

示例中的规则将识别具有指定序列号的 `sdX` 磁盘，并在 `devfs` 中创建唯一的 `/dev/my-persistent-disk-name` 条目。 然后应用程序使用 `/dev/my-persistent-disk-name` 而不是尝试使用定义为非持久的 `sdX`。

### rhel7(centos7) 中获取设备信息
要查找唯一的自标识符（由磁盘本身提供），请使用 `udevadm info` 命令。 例如：
```bash
[root@host]# udevadm info --query=all /dev/sda | egrep -i "serial|wwn"
S: disk/by-id/wwn-0x600508b1001ca98d5d765bea5a0dd3fa
E: DEVLINKS=/dev/disk/by-path/pci-0000:04:00.0-scsi-0:1:0:0 /dev/disk/by-id/scsi-0HP_LOGICAL_VOLUME_00000000 /dev/disk/by-id/scsi-3600508b1001ca98d5d765bea5a0dd3fa /dev/disk/by-id/scsi-SHP_LOGICAL_VOLUME_50014380212E90E0 /dev/disk/by-id/wwn-0x600508b1001ca98d5d765bea5a0dd3fa
E: ID_SCSI_SERIAL=50014380212E90E0
E: ID_SERIAL=3600508b1001ca98d5d765bea5a0dd3fa
E: ID_SERIAL_SHORT=600508b1001ca98d5d765bea5a0dd3fa
E: ID_WWN=0x600508b1001ca98d
E: ID_WWN_VENDOR_EXTENSION=0x5d765bea5a0dd3fa
E: ID_WWN_WITH_EXTENSION=0x600508b1001ca98d5d765bea5a0dd3fa
E: SCSI_IDENT_SERIAL=50014380212E90E0
```

`E:` 表示这些是 `ENV{name}="value"` 类型，在上面的示例中，使用了 `ENV{ID_SCSI_SERIAL}`，因为这在当前系统上的磁盘配置中是唯一的。 也可以为此磁盘选择`全球名称 (wwid) ENV{ID_WWN} `或任何其他命名标识符。

使用 `ENV{name}` 子句进行过滤的替代方法是使用 `ATTR{name}=="value"` 或 `ATTRS{name}=="value"` 过滤。 再次使用 `udevadm` 命令可以找到这些信息：
```bash
[root@host]# udevadm info --path=/sys/class/block/sda --attribute-walk | grep -i ww
    ATTRS{wwid}=="naa.600508b1001ca98d5d765bea5a0dd3fa"
```

注意，`此 ATTRS{name}` 与 `ENV{ID_WWN_WITH_EXTENSION}` 具有相同的值，`但带有naa`。 

验证写的 `rules` 文件：
```bash
[root@host]# udevadm test /block/<sdX> 2>&1 | grep <my-persistent-disk-name>
```

验证通过后应用 `rules` 内容，重新加载并触发内容生效：
```bash
[root@host]# udevadm control --reload-rules
[root@host]# udevadm trigger --type=devices --action=change

NOTE: To monitor the rules, open a monitor while you do the above. In a separate terminal run the udev monitor, control-C to exit.
[root@host]# udevadm monitor
```

{{<notice warning>}}在 `rhel7(centos7)和rhel8(centos8)`中，`scsi_id` 命令位于 `/usr/lib/udev` 中，扫描的是 `SUBSYSTEM` 而不是 `BUS`。{{</notice>}}

### rhel6(centos6) 中获取设备信息
第一步是获取 `SCSI` 设备的 `SCSI` 标识符，通常是一个 `WWID`。 可以使用如下命令获取，命令必须以 `root` 身份运行，否则不会生成任何输出，因为需要 `root` 权限才能访问原始设备。   
要获取 /dev/sda 的标识符，请运行以下命令：
```bash
[root@host]# scsi_id --whitelisted --replace-whitespace --device=/dev/sda
3500000e012d5ede0
```
`scsi_id` 命令向设备发出 `SCSI INQUIRY` 命令以访问`重要产品数据 (VPD(vital product data))` 页 `0x83` 的数据（如果有的话）。该页面包括设备 `WWID` 以及其他信息。   
如果 WWID 不可用，则输出基于 `VPD` 页 `0x80` 中的序列号 `id`。由于名义上应该有 `WWID（全球标识符）`可用，本文中设备标识符将是 `WWID`。 

以下是基于序列号的 `SCSI` 标识符示例：
```bash
[root@host]# scsi_id --whitelisted --replace-whitespace --device=/dev/sda
1ATA_ST3250310AS_9RY3GS4M
```
`scsi_id` 命令（长字符串）的结果是当前映射到 `/dev/sda` 的设备的 `WWID`。同一设备的每个路径和设备的每个分区，此 `WWID` 都是相同的。`WWID` 是持久的，即使在系统中添加或删除其他设备也不会更改。  
系统重新启动时，`WWID` 保持相同 。但是设备到 `/dev/sda` 的映射可能会改变。这就是为什么需要为软件使用创建的静态设备名称的原因。  

`udevadm` 命令同样可用于查找 `WWID` 信息：
```bash
[root@host]# udevadm info --query all --name=/dev/sdd | grep WWN
E: ID_WWN=0x500000e012d5ede0
E: ID_WWN_WITH_EXTENSION=0x500000e012d5ede0
```
{{<notice info>}}优先使用 `udevadm` 命令获取`WWN（World Wide Name，World Wide IDentifier 的另一个名称）`和其他信息{{</notice>}}

还可以使用下面的命令来获取 `SCSI` 设备的 `SERIAL ID`：
```bash
[root@host]# udevadm info --query all --name=/dev/sda | grep ID_SERIAL
E: ID_SERIAL=ST3250310AS_9RY3GS4M
E: ID_SERIAL_SHORT=9RY3GS4M
```
### rhel6(centos6) 中的 udev 规则配置
为命名设备创建规则，创建 `/etc/udev/rules.d/20-names.rules` 文件。加命名规则，格式如下：
```bash
ACTION=="add|change",   KERNEL=="sd*", BUS=="scsi", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=%N", RESULT=="WWID", SYMLINK+="devicename%n"

or using udev ENV syntax:

ACTION=="add|change", KERNEL=="sd*", ENV{ID_WWN}=="WWID", SYMLINK="devicename%n"   
```
将上述模板中的 `stringsWWID` 和 `devicename` 替换为在检索到的实际 `WWID` 和所需的设备名称。 
{{<notice info>}}不要使用内核已经使用的名称（例如 `sd* dm* st* nt* eth*` 等）。 这种使用不受支持并且可能会导致问题，为 `SYMLINK` 指定的名称值在所有规则中必须是唯一的。{{</notice>}}

具体示例：
```bash
ACTION=="add|change",   KERNEL=="sd*", BUS=="scsi", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=%N", RESULT=="3500000e012d5ede0", SYMLINK+="mydiskname%n"

or using udev ENV syntax:

ACTION=="add|change", KERNEL=="sd*", ENV{ID_WWN}=="500000e012d5ede0", SYMLINK="mydiskname%n"   
```
规则文件生效时将触发系统检查与 `/dev/sd*` 匹配的所有 `SCSI` 设备，并检查给定的 `WWID` `500000e012d5ede0`。当它找到匹配的设备时，它将创建一个名为 `/dev/mydiskname` 的符号链接，该链接指向 `/dev/sda` —— 至少在当前引导周期内。 如果设备上有任何分区，则会创建其他符号链接：`/dev/mydiskname1` 用于第一个分区 `(/dev/sda1)`，`/dev/mydiskname2` 用于第二个分区 `(/dev/sda2)`，依此类推。

测试规则文件是否生效：
```bash
# /dev/sda 上有分区
[root@host]# udevadm test /block/sda 2>&1 | grep mydiskname
udev_rules_apply_to_event: LINK 'mydiskname' /etc/udev/rules.d/20-names.rules:1
link_find_prioritized: found '/sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/host0/port-0:0/end_device-0:0/target0:0:0/0:0:0:0/block/sda' claiming '/dev/.udev/links/mydiskname'
link_update: creating link '/dev/mydiskname' to '/dev/sda'
node_symlink: creating symlink '/dev/mydiskname' to 'sda'
udevadm_test: DEVLINKS=/dev/mydiskname /dev/block/8:0 /dev/disk/by-id/scsi-3500000e012d5ede0 /dev/disk/by-id/wwn-0x500000e012d5ede0
```

触发生效：
```bash
# add
[root@host]# /sbin/udevadm trigger --type=subsystems --action=add
[root@host]# /sbin/udevadm trigger --type=devices --action=add

# change
[root@host]# /sbin/udevadm trigger --type=subsystems --action=change
[root@host]# /sbin/udevadm trigger --type=devices --action=change

# 触发制定设备
[root@host]# echo change > /sys/block/sda/sda1/uevent
```

检查：
```editorconfig
# ls -l /dev/mydiskname*
lrwxrwxrwx. 1 root root 3 Feb 20 21:52 /dev/mydiskname -> sda
lrwxrwxrwx. 1 root root 3 Feb 20 21:52 /dev/mydiskname1 -> sda1
```

## \# 其他
### \# 参考内容
本文内容参考自：
- [解析linux下磁盘乱序的问题](https://blog.51cto.com/gehailong/1546206)
- [What is udev and how do you write custom udev rules in RHEL7 ?](https://access.redhat.com/solutions/1135513)
- [Inconsistent Device Names Across Reboot Cause Mount Failure Or Incorrect Mount in Linux](https://www.thegeekdiary.com/inconsistent-device-names-across-reboot-cause-mount-failure-or-incorrect-mount-in-linux/)
- [How are custom persistent names assigned for SCSI devices using udev in Red Hat Enterprise Linux 7 and 8?](https://access.redhat.com/solutions/2975361)
- [How can static names be assigned for SCSI devices using udev in Red Hat Enterprise Linux 6?](https://access.redhat.com/solutions/45626)