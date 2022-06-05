+++
title = "linux系统启动流程"
description = "linux系统的启动流程和各个阶段"
date = "2022-05-25T22:52:46+08:00"
lastmod = "2022-05-25T22:52:46+08:00"
tags = ["linux", "grub", "boot", "bootloader"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## 说明
启动 `linux` 计算机并使其可用需要分两个步骤：`boot（引导）` 和 `startup（启动）`。
- `boot` 流程在计算机开机时开始，在内核初始化和 `systemd` 启动时完成。
- `startup` 流程在 `boot` 流程完成后开始，`linux` 计算机进入运行状态时结束。

linux 引导和启动过程由以下步骤组成：
- `BIOS/UEFI POST（power-on self-test）`
- `boot loader (GRUB/GRUB2)`
- `kernel initialization`（内核初始化）
- 启动 `systemd/init（所有进程的父进程）`  

详细流程如下图：
![](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220529-2243.png)

基于 `BIOS` 的启动流程：
![bios](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220603-1442.png)

基于 `UEFI` 的启动流程：
![uefi](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220603-1443.png)

## BIOS/UEFI POST 部分
`linux` 启动过程的第一步和 `linux` 系统无关，这是引导过程的硬件部分，对于任何操作系统都是一样的。当计算机首次通电时，它会运行 `POST`（开机自检）。`POST` 是 `BIOS/UEFI` 的一部分，其任务是确保计算机硬件正常运行。如果 `POST` 失败，计算机可能无法使用，因此引导过程不会继续。

**BIOS**  
`BIOS POST` 检查硬件的基本可操作性，然后发出一个 `BIOS` 中断 `INT 13H`，它可以定位任何连接的可引导设备上的引导扇区。它将找到的包含有效引导记录的第一个引导扇区加载到 `RAM` 中，然后将控制权转移到从引导扇区加载的代码。

**UEFI**  
`EFI` 引导过程不引用 `MBR` 中的代码，通常也不使用分区引导扇区中的代码。相反，`EFI` 加载由 `EFI` 的内置引导管理器指定的引导加载程序，此处是 `GRUB`。

## GRUB 部分
MBR 分区表磁盘：
![mbr grub](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220603-1120.png)

GPT 分区表磁盘：  
![gpt grub](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220603-1054.png)

### GRUB2
**什么是 GRUB2**  
`GRUB2` 代表 `GRand Unified Bootloader version 2`，它是当前大多数 `Linux` 发行版的主要引导加载程序

{{<notice info>}}grub2介绍请查看：[grub2介绍](https://www.ruisum.top/tech/basics/grub2%E4%BB%8B%E7%BB%8D/){{</notice>}}

### BIOS 下 GRUB 流程
任一 `GRUB` 的主要功能是将 `linux` 内核加载到内存中并运行。两个 `GRUB（grub 和 grub2）` 版本的工作方式基本相同，并且具有相同的三个阶段。 虽然官方并没有使用三个阶段来说明 `GRUB` 的工作流程，但是这样理解会比较方便。

**Stage 1**  
如 `BIOS/UEFI POST` 部分所述，在 `POST` 结束时，`BIOS` 在连接的磁盘中搜索引导记录。引导记录通常位于`主引导记录 (MBR) `中，它将找到的{{< underline color="#ffdd00" content="第一个" >}}记录加载到内存中，然后开始执行开机。`引导代码（即 GRUB2 stage 1）`非常小，因为它必须与分区表一起放入硬盘驱动器上的第一个 `512` 字节扇区。在经典通用 `MBR` 中为实际引导代码分配的空间总量为 `446` 字节。阶段 1 的 `446` 字节文件名为 `boot.img`，不包含单独添加到引导记录的分区表。

因为引导记录如此之小，写不了多少代码，功能有限。因此 `stage 1` 的唯一目的是定位和加载`stage 1.5`。为了做到这一点，`GRUB` 的 `stage 1.5` 必须位于引导记录本身和驱动器上的第一个分区之间的空间中。将 `GRUB stage 1.5` 加载到 `RAM` 后，`stage 1` 将控制权移交给`stage 1.5`。

**Stage 1.5**  
如上所述，`GRUB` 的 `stage 1.5` 必须位于引导记录本身和磁盘驱动器上的第一个分区之间的空间中。由于技术原因，这个空间在历史上一直未被使用。硬盘驱动器上的第一个分区从扇区 `63` 开始，`MBR` 在`扇区 0`，剩下 `62512` 字节扇区（31,744 字节）用于存储 `GRUB stage 1.5` 的 `core.img` 文件。`core.img` 文件是 `25,389` 字节，因此在 `MBR` 和存储它的第一个磁盘分区之间有足够的空间。

由于 `stage 1.5` 可以容纳更多的代码，它可以有足够的代码来包含一些常见的文件系统驱动程序，例如标准 `EXT` 和其他 `Linux` 文件系统、`FAT` 和 `NTFS`。`GRUB2 core.img` 比旧的 `GRUB1 stage 1.5` 更复杂和更强大。这意味着 `GRUB2 stage 2`可以位于标准 `EXT` 文件系统上（不能位于lvm逻辑卷上）。所以`stage 2`文件的标准位置是在 `/boot` 文件系统中，特别是 `/boot/grub2`。

需要特别注意的是，`/boot` 目录必须位于 `GRUB` 支持的文件系统上，因为并非所有文件系统都是 `GRUB` 支持的。`stage 1.5` 的功能是从加载文件系统驱动程序开始，以在 `/boot` 文件系统中定位 `stage 2` 文件并加载所需的驱动程序。

`GRUB2 stage 1.5` 的功能是定位 `Linux` 内核并加载到 `RAM` 中，并将计算机的控制权交给内核，内核及其相关文件位于 `/boot` 目录中。内核文件是可识别的，因为它们都以 `vmlinuz` 开头。

**Stage 2**  
`GRUB2 stage 2`将选定的内核加载到内存中，并将计算机的控制权交给内核。

### UEFI 下 GRUB 的流程
/efi/<distro>/grubx64.efi（`x86-64 UEFI` 系统）作为文件安装在 `EFI 系统分区(ESP)`中，并由固件直接引导，在 `MBR 扇区 0` 中没有 `boot.img`。此文件类似于 `stage1` 和 `stage 1.5`。

对于 `x86-64 UEFI` 系统，`stage2` 是 `/boot/grub/x86_64-efi/normal.mod` 文件和其他 `/boot/grub/` 文件。

### 加载完 GRUB 后内容
**菜单选择界面**  
`GRUB` 提供一个菜单，用户可以在其中进行选择需要启动的操作系统。 `GRUB` 可以配置超时后自动加载指定的操作系统。

## kernel 部分
所有内核都采用自解压压缩格式以节省空间。内核与初始 `RAM disk image` 和硬盘驱动器的设备映射一起位于 `/boot` 目录中。

在选定的内核加载到内存并开始执行后，内核首先需要从文件的压缩版本中提取自身，然后才能执行其他工作内容。一旦内核解压了自己，它就会加载 `systemd（旧 SysV init 程序的替代品）`，并将控制权交给它。

到此 `boot process`的结束。此时，`linux` 内核和 `systemd` 正在运行，但无法为用户执行任何任务，因为当前没有任何服务在运行。

## startup 部分
`startup process` 随着 `boot process` 结束而开始，其作用是使 `Linux` 计算机进入可用于生产性工作的运行状态。

### systemd
`systemd` 是所有进程之母，它负责将 `Linux` 主机提升到可以完成生产性工作的状态。`systemd` 的功能比旧的 `init` 要广泛得多，可以管理运行中的 `Linux` 主机的方方面面，包括挂载文件系统、启动和管理使 `Linux` 主机高效工作所需的系统服务。

`systemd` 首先挂载 `/etc/fstab` 定义的文件系统，可以包括任何交换文件或分区。此时，`systemd` 可以访问位于 `/etc` 中的配置文件，包括它自己的。  
`systemd` 使用其配置文件 `/etc/systemd/system/default.target` 来确定应将主机引导到哪个状态或目标。`default.target` 文件只是指向真正目标文件的符号链接。
  - 对于桌面环境，通常是 `graphics.target`，相当于旧 `SystemV init` 中的运行`runlevel 5`。
  - 对于服务器，默认值更可能是 `multi-user.target`，类似于 `SystemV` 中的运行`runlevel 3`。 
  - `Emergency.target` 类似于单用户模式。

请注意，`targets `和 `service` 都是 `systemd units`。

下面的表 1 是 `systemd target` 与旧 `SystemV` 启动运行级别的比较。   
`systemd target alias` 由 `systemd` 提供以实现向后兼容性。目标别名允许脚本使用 `SystemV` 命令（如 `init 3`）来更改运行级别，`SystemV` 命令会被转发到 `systemd` 进行解释和执行。
![sysv和systemd对比](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220529-2315.png)

每个 `target` 都有一组在其配置文件中描述的依赖项，`systemd` 会启动所需的依赖项。这些依赖项是在特定功能级别上运行 `Linux` 主机所需的服务。当目标配置文件中列出的所有依赖项都加载并运行时，系统就在该`目标级别（target level）`运行。

`systemd` 还会查看旧的 `SystemV` 初始化目录以查看那里是否存在任何启动文件。如果存在，`systemd` 使用这些作为配置文件来启动文件描述的服务。

下面的图 1 直接从 [bootup man page](http://man7.org/linux/man-pages/man7/bootup.7.html) 复制而来。它显示了 `systemd` 启动期间事件的一般顺序以及确保成功启动的基本排序要求。

{{<notice info>}}systemd 介绍请查看：[systemd介绍](https://www.ruisum.top/tech/basics/systemd%E4%BB%8B%E7%BB%8D){{</notice>}}

`sysinit.target` 和 `basic.target` `target` 可以被视为启动过程中的检查点。尽管 `systemd` 将并行启动系统服务作为其设计目标之一，但在启动其他`services 和 targets`之前，仍然必须启动某些`service`和功能`target`。在满足该检查点所需的所有`services 和 targets`之前，无法通过这些检查点。

因此，当`sysinit.target`所依赖的所有 `units` 都启动完成时，就完成了 `sysinit.target`的启动。所有这些`units`：挂载文件系统、设置`swap`、启动 `udev`，设置`random generator seed`，启动`low-level services`、`cryptographic服务`等必须完成，但在 `sysinit.target` 中，这些任务可以并行执行。

`sysinit.target` 启动所有`low-level services`和`units`，系统需要这些`services and units`才能正常运行，并且需要继续完成 `basic.target`。

```text
   local-fs-pre.target
            |
            v
   (various mounts and   (various swap   (various cryptsetup
    fsck services...)     devices...)        devices...)       (various low-level   (various low-level
            |                  |                  |             services: udevd,     API VFS mounts:
            v                  v                  v             tmpfiles, random     mqueue, configfs,
     local-fs.target      swap.target     cryptsetup.target    seed, sysctl, ...)      debugfs, ...)
            |                  |                  |                    |                    |
            \__________________|_________________ | ___________________|____________________/
                                                 \|/
                                                  v
                                           sysinit.target
                                                  |
             ____________________________________/|\________________________________________
            /                  |                  |                    |                    \
            |                  |                  |                    |                    |
            v                  v                  |                    v                    v
        (various           (various               |                (various          rescue.service
       timers...)          paths...)              |               sockets...)               |
            |                  |                  |                    |                    v
            v                  v                  |                    v              rescue.target
      timers.target      paths.target             |             sockets.target
            |                  |                  |                    |
            v                  \_________________ | ___________________/
                                                 \|/
                                                  v
                                            basic.target
                                                  |
             ____________________________________/|                                 emergency.service
            /                  |                  |                                         |
            |                  |                  |                                         v
            v                  v                  v                                 emergency.target
        display-        (various system    (various system
    manager.service         services           services)
            |             required for            |
            |            graphical UIs)           v
            |                  |           multi-user.target
            |                  |                  |
            \_________________ | _________________/
                              \|/
                               v
                     graphical.target
```

完成 `sysinit.target` 后，`systemd` 接下来启动 `basic.target`，启动完成它所需的所有`units`。`basic.target` 通过启动下一个 `target` 所需的 `units` 来提供一些附加功能。其中包括设置各种可执行目录、通信套接字和计时器的路径。

最后，可以初始化用户级目标 `multi-user.target` 或 `graphics.target`。在满足 `graphics.target` 依赖关系之前，必须达到 `multi-user.target`。

上面的文本图中，带下划线的 `target` 是通常的 `startup targets`。当达到这些 `target` 之一时，`startup 流程`就完成了。如果 `multi-user.target` 是默认值，那应该会在控制台上看到文本登录界面。如果 `graphics.target` 是默认值，那应该会看到图形登录界面。

## 结论
`GRUB2` 和 `systemd init` 系统是大多数现代 `Linux` 发行版的 `boot` 和 `startup` 阶段的关键组件。尽管围绕 `systemd` 一直存在争议，但这两个组件可以顺利地协同工作，首先加载内核，然后启动 `Linux` 系统所需的所有系统服务。

## 其他
### \# UEFI 中的多重引导
每个操作系统或 `OEM` 供应商都可以在 `ESP(EFI system partition)` 内维护自己的文件，而不会影响对方。因此使用 `UEFI` 进行多重引导，只是启动与特定操作系统的引导加载程序相对应的不同 `EFI` 应用程序的问题，不再需要依赖一个引导加载程序的链加载机制来加载另一个操作系统。

### \# 什么是 bootloader
`bootloader（引导加载程序）` 是由固件（`BIOS` 或 `UEFI`）启动的软件。它负责使用所需的内核参数和相应的 `initramfs` 映像来加载内核。 在 `UEFI` 的情况下，内核本身可以由 `UEFI` 使用 `EFI 引导存根（ EFI boot stub）` 直接启动。   
{{<notice warning>}}`bootloader` 必须能够访问内核和 `initramfs` 映像，否则系统将无法引导，因此在设置中，它必须支持访问 `/boot`。这意味着 `bootloader` 必须支持从块设备、堆叠块设备（`LVM、RAID、dm-crypt、LUKS` 等）访问内核和 `initramfs` 映像所在的文件系统的所有内容。{{</notice>}}

### \# boot sector
如下展示了分布在硬盘扇区上的 `GNU GRUB` 的各种组件。当 `GRUB` 安装在硬盘上时，`boot.img` 会被写入该硬盘的引导扇区。 `boot.img` 的大小只有 `446` 字节。
![boot sector构成](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220603-1529.png)

### \# 参考内容
本文参考文章列表如下：
- [Working with GRUB 2](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader)
- [An introduction to the Linux boot and startup processes](https://opensource.com/article/17/2/linux-boot-and-startup)
- [linux system boot](https://www.freedesktop.org/software/systemd/man/bootup.html)
- [Trying to understand the boot loader process / GRUB?](https://askubuntu.com/questions/961086/trying-to-understand-the-boot-loader-process-grub)
- [How grub2 works on a MBR partitioned disk and GPT partitioned disk?](https://superuser.com/questions/1165557/how-grub2-works-on-a-mbr-partitioned-disk-and-gpt-partitioned-disk)
- [启动流程、模块管理、BootLoader(Grub2)](https://www.jianshu.com/p/7276a98e74cf)
- [Arch boot process](https://wiki.archlinux.org/title/Arch_boot_process)
- [Linux系统启动过程](https://www.cnblogs.com/JMLiu/p/10183948.html)
- [efi bootloaders and The EFI Boot Process](http://www.rodsbooks.com/efi-bootloaders/principles.html)