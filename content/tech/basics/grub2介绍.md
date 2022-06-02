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
draft = true
toc = false
+++

**GRUB2 配置文件**  
`GRUB2` 的配置文件（该文件包含菜单信息）：
  - 传统的基于 `BIOS` 的机器： `/boot/grub2/grub.cfg` 文件
  - `UEFI` 机器： `/boot/efi/EFI/redhat/grub.cfg` 文件  

`GRUB2` 的配置文件 `grub.cfg` 是在系统安装期间，或通过调用 /usr/sbin/grub2-mkconfig 实用程序生成的，并且在每次安装新内核时由 `grubby` 自动更新。
> grubby命令的使用可查看：[grubby命令的使用](https://www.ruisum.top/tech/basics/grubby%E5%91%BD%E4%BB%A4%E7%9A%84%E4%BD%BF%E7%94%A8/)

当使用 `grub2-mkconfig` 手动重新生成时，该文件是根据位于 `/etc/grub.d/` 中的模板文件和 `/etc/default/grub` 文件中的自定义设置生成的。每次使用 `grub2-mkconfig` 重新生成文件时，对 `grub.cfg` 的编辑都将丢失，因此要特别注意管控对 `/etc/default/grub` 的任何更改。

**GRUB2 配置文件的修改**  
对于 `grub.cfg` 的正常操作，例如删除和添加新内核，应该使用 `grubby` 工具完成，对于脚本，使用 `new-kernel-pkg` 工具。

`/etc/default/grub` 文件是 `grub2-mkconfig` 工具使用的，`anaconda` 在安装过程中创建 `grub.cfg` 时使用，在系统出现故障时可以使用，例如，如果需要重新创建引导加载程序配置