+++
title = "grub2介绍"
description = ""
date = "2022-06-02T22:56:20+08:00"
lastmod = "2022-06-02T22:56:20+08:00"
tags = ["grub2", "linux", "grubby"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++
## \# 说明
`bootloader` 是计算机启动时运行的第一个软件程序，它负责加载并将控制权转移到操作系统内核，然后内核初始化操作系统的其余部分。

### \# 什么是 GRUB
`GNU GRUB` 是一个非常强大的 `bootloader（引导加载程序）`，它可以加载各种各样的开源操作系统，以及链式加载专有操作系统（如：`windows`）

`GRUB` 旨在解决引导个人计算机的复杂性。`GRUB` 的重要特性之一是灵活性，`GRUB` 了解文件系统和内核可执行格式，因此可以按照自己喜欢的方式加载任意操作系统，而无需记录内核在磁盘上的物理位置; 只需指定内核的文件名以及内核所在的驱动器和分区即可加载内核。

使用 `GRUB` 引导时，可以使用命令行界面或菜单界面的方式：
- 使用命令行界面，可以手动键入内核的驱动器规格和文件名。
- 选择菜单界面，可以使用箭头键选择一个操作系统。 
  - 该菜单基于预先准备的配置文件。 
  - 在菜单中，可以切换到命令行模式，反之亦然。

### \# GRUB2 和 GRUB 的异同
`GRUB2` 是对 `GRUB` 的重写，它与以前的版本（现在称为 `GRUB Legacy`）的部分不同点如下：
- `GRUB2` 配置文件不同，使用 `grub.cfg` 而不是 `GRUB` 的 `menu.lst (grub.conf的软链接)`或 `grub.conf`
- `GRUB2` 设备名称中的分区号现在从 `1` 开始，而不是 `0`。
- `GRUB2` 增添了许多语法，更接近于脚本语言，支持变量、条件判断、循环等。
- `GRUB2` 使用 `img` 文件，不再使用 `GRUB` 中的 `stage1、stage1.5和stage2`。 

{{<notice info>}}更详细的内容可以查看：[Differences from previous versions](https://www.gnu.org/software/grub/manual/grub/html_node/Changes-from-GRUB-Legacy.html#Changes-from-GRUB-Legacy){{</notice>}}

## \# GRUB2 使用
### \# GRUB2 的命名约定
```bash
(fd0)           ：表示第一块软盘
(hd0,msdos2)    ：表示第一块硬盘的第二个mbr分区。grub2中分区从1开始编号，传统的grub是从0开始编号的
(hd0,msdos5)    ：表示第一块硬盘的第一个逻辑分区
(hd0,gpt1)      ：表示第一块硬盘的第一个gpt分区
/boot/vmlinuz   ：相对路径，基于根目录，表示根目录下的boot目录下的vmlinuz，
                ：如果设置了根目录变量root为(hd0,msdos1)，则表示(hd0,msdos1)/boot/vmlinuz
(hd0,msdos1)/boot/vmlinuz：绝对路径，表示第一硬盘第一分区的boot目录下的vmlinuz文件
```

{{<notice info>}}更详细的内容可以查看：[Naming convention](https://www.gnu.org/software/grub/manual/grub/html_node/Naming-convention.html#Naming-convention){{</notice>}}

### \# 如何引导操作系统
`GRUB` 有两种不同的引导方法。 一个是直接加载操作系统，另一种是链式加载另一个引导加载程序，然后再加载操作系统。   
一般使用第一种方式，因为不需要安装或维护其他引导加载程序，而且 GRUB 足够灵活，可以从任意磁盘/分区加载操作系统，能够满足绝大部分场景。  
有时需要后者，因为 `GRUB` 本身并不支持所有现有的操作系统。
- `直接引导(direct-load)`：直接通过默认的 `grub2 boot loader` 来引导写在默认配置文件中的操作系统。
- `链式引导(chain-load)`：使用默认 `grub2 boot loader` 链式引导另一个`bootloader`，该 `bootloader` 将引导对应的操作系统。

{{<notice info>}}更详细的内容可以查看：[How to boot operating systems](https://www.gnu.org/software/grub/manual/grub/html_node/General-boot-methods.html#General-boot-methods){{</notice>}}

**GRUB2 配置文件**  
`GRUB2` 的配置文件（该文件包含菜单信息）：
  - 传统的基于 `BIOS` 的机器： `/boot/grub2/grub.cfg` 文件
  - `UEFI` 机器： `/boot/efi/EFI/redhat/grub.cfg` 文件  

`GRUB2` 的配置文件 `grub.cfg` 是在系统安装期间，或通过调用 /usr/sbin/grub2-mkconfig 实用程序生成的，并且在每次安装新内核时由 `grubby` 自动更新。
> grubby命令的使用可查看：[grubby命令的使用](https://www.ruisum.top/tech/basics/grubby%E5%91%BD%E4%BB%A4%E7%9A%84%E4%BD%BF%E7%94%A8/)

当使用 `grub2-mkconfig` 手动重新生成时，该文件是根据位于 `/etc/grub.d/` 中的模板文件和 `/etc/default/grub` 文件中的自定义设置生成的。每次使用 `grub2-mkconfig` 重新生成文件时，对 `grub.cfg` 的编辑都将丢失，因此要特别注意管控对 `/etc/default/grub` 的任何更改。

**GRUB2 配置文件的修改**  
对于 `grub.cfg` 的正常操作，例如删除和添加新内核，应该使用 `grubby` 工具完成，对于脚本，使用 `new-kernel-pkg` 工具。

## \# 其他
### \# 参考内容
本文内容参考自：
- [Changes-from-GRUB-Legacy](https://www.gnu.org/software/grub/manual/grub/html_node/Changes-from-GRUB-Legacy.html#Changes-from-GRUB-Legacy)
- [grub images](https://www.gnu.org/software/grub/manual/grub/html_node/Images.html#Images)
- [命名习惯和文件路径表示方式](https://www.cnblogs.com/f-ck-need-u/p/7094693.html)
- [GNU GRUB手册](https://www.gnu.org/software/grub/manual/grub/html_node/index.html#SEC_Contents)
- [GUN 手册](https://www.gnu.org/manual/manual.html)