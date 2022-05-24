+++
title = "grubby命令的使用"
description = "grubby：用于配置 bootloader 菜单条目的命令行工具"
date = "2022-05-23T23:24:04+08:00"
lastmod = "2022-05-23T23:24:04+08:00"
tags = ["grub", "linux", "basic", "system"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## 说明  
### \# grubby 是什么  
`grubby` 是一个可在不同架构下配置 `bootloader` 菜单条目的命令行工具。

### \# 详细内容
`grubby` 用于更新和显示特定于架构下的`引导程序（bootloader）`的配置文件的信息。`grubby` 是被设计给需要查找有关当前引导环境信息来安装新内核的脚本使用。

#### \# 支持的架构  
- `grubby` 已经完全支持在**x86_64**系统上使用`传统（legacy） BIOS`或者现代 `UEFI` 固件的 `GRUB2 引导加载程序（grub2 bootloader）`；同时支持`ppc64` 和 `ppc64le` 硬件使用 `OPAL` 或 `SLOF` 作为固件的 `GRUB2` 引导加载程序。  
- 完全支持传统 `s390` 和当前的 `s390x` 体系结构及其 `zipl引导加载程序（zipl bootloader）` 。  
- 不再支持 `yaboot`，从 `power8` 之后使用 `grub2` 或 `petitboot` 的 `ppc` 体系结构硬件都使用GRUB2配置文件格式。
- 传统引导加载程序 `LILO, SILO和 ELILO` 被弃用

#### \# 默认行为  
默认的引导加载程序目标主要由构建 `grubby` 的系统架构决定。每个系统架构都有一个首选的引导加载程序，每个引导加载程序都有其自己的配置文件; 如果未在命令行上选择 `bootloader`，则 `grubby` 将使用这些默认设置来搜索现有配置; 如果找不到 `bootloader` 配置文件，`grubby` 将使用该系统架构的默认值, 这些默认值在下表中列出:  

| **架构**           | **bootloader** | **配置文件** |
|:-----------------|:--------------:|:--- |
| `x86_64 [BIOS]`  |     `grub2`      | `/boot/grub2/grub.cfg` |
| `x86_64 [UEFI]`  |     `grub2`      | `/boot/efi/EFI/redhat/grub.cfg` |
| `i386`           |     `grub2`      | `/boot/grub2/grub.cfg` |
| `ia64`           |     `elilo`      | `/boot/efi/EFI/redhat/elilo.conf` |
| `ppc [>=Power8]` |     `grub2`      | `/boot/grub2/grub.cfg` |
| `ppc [<=Power7]` |     `yaboot`      | `/etc/yaboot.conf` |
| `s390`           |     `zipl`      | `/etc/zipl.conf` |
| `s390x`          |     `zipl`      | `/etc/zipl.conf` |

### \# 名词解释

**boot entry**  
- 引导条目（`boot entry`）是一个选项的集合，该选项存储在配置文件中，并绑定到特定的内核版本。
- 实际使用中，系统至少拥有与系统已安装内核一样多的引导条目。
- 引导条目展示的文件名由存储在 `/etc/machine-id` 文件中的机器 `ID` 和内核版本组成。
- 引导条目配置文件包含有关内核版本，初始 `ramdisk image` 和 `kernelopts（其中包含内核命令行参数）` 环境变量的信息。
- `kernelopts` 环境变量在 `/boot/grub2/grubenv` 文件中定义。
- 引导条目配置文件位于 `/boot/loader/entries/directory` 中，类似如下内容:
  ```bash
  $ cat /boot/grub/grub.cfg
    ......
    ### BEGIN /etc/grub.d/10_linux ###                              
    menuentry 'Manjaro Linux' --class manjaro --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-7afa0d3
    2-fd8d-44cc-8e4e-784f2493f4ca' {                                
            savedefault                                                                                                             
            load_video                                                                                                              
            set gfxpayload=keep
            insmod gzio                                                                                                             
            insmod part_gpt                                                                                                         
            insmod ext2                                                                                                             
            search --no-floppy --fs-uuid --set=root 7afa0d32-fd8d-44cc-8e4e-784f2493f4ca                                            
            linux   /boot/vmlinuz-5.15-x86_64 root=UUID=7afa0d32-fd8d-44cc-8e4e-784f2493f4ca rw  quiet apparmor=1 security=apparmor 
    udev.log_priority=3                                             
            initrd  /boot/amd-ucode.img /boot/initramfs-5.15-x86_64.img                                                             
    }
  ......
  ```
## 常用的 grubby 命令
### \# 添加新内核条目
```bash
# 假设已经构建了自己的内核，该内核已安装在服务器上，并希望为此新内核添加自定义条目，可以使用如下命令：
$ grubby --add-kernel=new_kernel --title="entry_title" --initrd="new_initrd" --copy-default

# 上一条命令使用了 --copy-default ，该参数会从我们的默认内核复制所有内核参数到此新内核条目，若要添加自己的自定义内核参数，可以使用：
$ grubby --add-kernel=new_kernel --title="entry_title" --initrd="new_initrd" --args=kernel_args

# 示例命令
$ grubby --grub2 --add-kernel=/boot/vmlinuz-4.18.0-193.el8.x86_64 --title="Red Hat Enterprise 8 Test" --initrd=/boot/initramfs-4.18.0-193.el8.x86_64.img --copy-default
```

### \# 删除已有内核条目
**请谨慎使用此命令**，因为该命令会删除当前已有的内核的引导条目。如果删除了不正确内核的内核条目，系统可能无法启动，到时只能进入单用户模式修复损坏的服务器了。

```bash
# 删除内核条目
$ grubby --remove-kernel=old_kernel

# 或者使用索引进行删除
$ grubby --remove-kernel=menu_index
```

### \# 添加新的内核参数
```bash
# 添加新的内核参数
$ grubby --update-kernel=current_kernel --args="kernel_args"

# 具体命令示例
$ grubby --update-kernel=/boot/vmlinuz-$(uname -r) --args="ipv6.disable=1"

# 给当前所有可用内核统一添加内核参数
$ grubby --update-kernel=ALL --args="kernel_args"
```

### \# 删除已有的内核参数
```bash
# 删除已有的内核参数
$ grubby --update-kernel=current_kernel --remove-args="kernel_args"

# 具体命令示例
$ grubby --update-kernel=/boot/vmlinuz-$(uname -r) --remove-args="ipv6.disable=1"

# 给当前所有可用内核统一删除内核参数
$ grubby --update-kernel=ALL --args="kernel_args"
```

### \# 删除并添加内核参数
```bash
# 删除和添加内核参数可以同时使用
$ grubby --remove-args="kernel-args" --args="kernel_args"

# 具体命令示例
$ grubby --update-kernel=/boot/vmlinuz-$(uname -r) --remove-args="quiet" --args="console=ttsy0"
```

### \# 列出所有安装的内核
```bash
# 列出所有已经安装的内核
$ grubby --info=ALL | grep ^kernel
kernel="/boot/vmlinuz-4.18.0-193.14.3.el8_2.x86_64"
kernel="/boot/vmlinuz-4.18.0-193.1.2.el8_2.x86_64"
kernel="/boot/vmlinuz-4.18.0-193.el8.x86_64"
kernel="/boot/vmlinuz-0-rescue-d88fa2c7ff574ae782ec8c4288de4e85"
```

### \# 获取更多有关内核启动条目的信息
获取更多的内核引导条目的信息可以通过命令 `grubby --info`，命令会提供诸如索引号，`boot entry ID`，应用于内核的参数等信息
```bash
$ grubby --info="/boot/vmlinuz-$(uname -r)"
index=1
kernel="/boot/vmlinuz-4.18.0-193.1.2.el8_2.x86_64"
args="ro resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb biosdevname=0 net.ifnames=0 enforcing=0 $tuned_params console=ttsy0"
root="/dev/mapper/rhel-root"
initrd="/boot/initramfs-4.18.0-193.1.2.el8_2.x86_64.img $tuned_initrd"
title="Red Hat Enterprise Linux (4.18.0-193.1.2.el8_2.x86_64) 8.2 (Ootpa)"
id="d88fa2c7ff574ae782ec8c4288de4e85-4.18.0-193.1.2.el8_2.x86_64"
```

### \# 列出默认内核的路径
默认内核是指系统启动时默认使用的内核
```bash
$ grubby --default-kernel
/boot/vmlinuz-4.18.0-193.el8.x86_64
```

### \# 列出默认内核在引导条目中的索引号
```bash
$ grubby --default-index
2
```

### \# 列出默认内核在引导条目中的标题
```bash
$ grubby --default-title
Red Hat Enterprise Linux (4.18.0-193.1.2.el8_2.x86_64) 8.2 (Ootpa)
```

### \# 使用内核路径设置默认内核
```bash
# 更改默认内核（更改系统启动默认使用的内核）
$ grubby --set-default="/boot/vmlinuz-4.18.0-193.1.2.el8_2.x86_64"
```

### \# 使用索引设置默认内核
不使用内核 `vmlinuz` 来设置默认启动内核，我们还可以通过提供索引号来更改默认内核。
```bash
# 获取所有已安装内核的索引号
$ grubby --info=ALL | grep -E "^kernel|^index"
index=0
kernel="/boot/vmlinuz-4.18.0-193.14.3.el8_2.x86_64"
index=1
kernel="/boot/vmlinuz-4.18.0-193.1.2.el8_2.x86_64"
index=2
kernel="/boot/vmlinuz-4.18.0-193.el8.x86_64"
index=3
kernel="/boot/vmlinuz-4.18.0-193.el8.x86_64"
index=4
kernel="/boot/vmlinuz-0-rescue-d88fa2c7ff574ae782ec8c4288de4e85"

# 通过索引号设置默认内核
$ grubby --set-default-index=2
```

## 其他
### \# 参考内容
[https://www.systutorials.com/docs/linux/man/8-grubby/](https://www.systutorials.com/docs/linux/man/8-grubby/)
[https://www.golinuxcloud.com/grubby-command-examples/](https://www.golinuxcloud.com/grubby-command-examples/)

