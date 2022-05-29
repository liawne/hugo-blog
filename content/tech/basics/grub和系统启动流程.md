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
了解 Linux 引导和启动过程对于能够配置 Linux 和解决启动问题都很重要。本文描述使用 `GRUB2` 引导加载程序的`boot 流程`以及 `systemd` 初始化系统执行的`startup 流程`。

实际上，启动 `Linux` 计算机并使其可用需要分两个步骤：`boot` 和 `startup`。
- `boot` 流程在计算机开机时开始，在内核初始化和 `systemd` 启动时完成。
- `startup` 流程在 `boot` 流程完成后接管并完成使 `Linux` 计算机进入运行状态的任务。

总的来说，Linux 引导和启动过程由以下步骤组成，将在以下各节中更详细地描述。
- `BIOS POST`
- `Boot loader (GRUB2)`
- `Kernel initialization`（内核初始化）
- 启动 `systemd`，所有进程的父进程  

详细流程如下图：
![](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220529-2243.png)

## BIOS POST
Linux 启动过程的第一步实际上与 Linux 无关。这是引导过程的硬件部分，对于任何操作系统都是一样的。当计算机首次通电时，它会运行 POST（开机自检），它是 BIOS（基本 I/O 系统）的一部分。

当 IBM 在 1981 年设计第一台 PC 时，BIOS 旨在初始化硬件组件。POST 是 BIOS 的一部分，其任务是确保计算机硬件正常运行。如果 POST 失败，计算机可能无法使用，因此引导过程不会继续。

BIOS POST 检查硬件的基本可操作性，然后发出一个 BIOS 中断 INT 13H，它可以定位任何连接的可引导设备上的引导扇区。它将找到的包含有效引导记录的第一个引导扇区加载到 RAM 中，然后将控制权转移到从引导扇区加载的代码。

引导扇区实际上是引导加载程序的第一阶段。大多数 Linux 发行版使用三个引导加载程序：GRUB、GRUB2 和 LILO。 GRUB2 是最新的，并且现在比其他较旧的选项更频繁地使用。

## GRUB2
GRUB2 代表“GRand Unified Bootloader，版本 2”，它现在是大多数当前 Linux 发行版的主要引导加载程序。GRUB2 是使计算机足够智能以找到操作系统内核并将其加载到内存中的程序。因为 GRUB 比 GRUB2 更容易写和说，所以我可以在本文档中使用术语 GRUB，但除非另有说明，否则我将指 GRUB2。

GRUB 被设计为与多重引导规范兼容，允许 GRUB 引导许多版本的 Linux 和其他免费操作系统；它还可以链接加载专有操作系统的引导记录。

GRUB 还可以允许用户选择从任何给定 Linux 发行版的多个不同内核中引导。如果更新的内核以某种方式失败或与重要的软件不兼容，这提供了引导到以前的内核版本的能力。可以使用 /boot/grub/grub.conf 文件配置 GRUB。

GRUB1 现在被认为是遗留的，并且在大多数现代发行版中已被 GRUB2 取代，这是对 GRUB1 的重写。基于 Red Hat 的发行版在 Fedora 15 和 CentOS/RHEL 7 前后升级到 GRUB2。GRUB2 提供与 GRUB1 相同的引导功能，但 GRUB2 也是类似大型机的基于命令的预操作系统环境，并在预引导阶段提供更大的灵活性。 GRUB2 使用 /boot/grub2/grub.cfg 进行配置。

任一 GRUB 的主要功能是将 Linux 内核加载到内存中并运行。两个 GRUB 版本的工作方式基本相同，并且具有相同的三个阶段，但我将使用 GRUB2 来讨论 GRUB 如何完成其​​工作。GRUB 或 GRUB2 的配置以及 GRUB2 命令的使用超出了本文的范围。

虽然 GRUB2 并没有官方对 GRUB2 的三个阶段使用阶段表示法，但是这样引用它们很方便，所以我将在本文中。

### Stage 1
如 BIOS POST 部分所述，在 POST 结束时，BIOS 在连接的磁盘中搜索引导记录，通常位于主引导记录 (MBR) 中，它将找到的第一个记录加载到内存中，然后开始执行开机记录。引导代码（即 GRUB2 阶段 1）非常小，因为它必须与分区表一起放入硬盘驱动器上的第一个 512 字节扇区。在经典通用 MBR 中为实际引导代码分配的空间总量为 446 字节。阶段 1 的 446 字节文件名为 boot.img，不包含单独添加到引导记录的分区表。

因为引导记录必须如此之小，它也不是很聪明并且不了解文件系统结构。因此阶段 1 的唯一目的是定位和加载阶段 1.5。为了做到这一点，GRUB 的 1.5 阶段必须位于引导记录本身和驱动器上的第一个分区之间的空间中。将 GRUB 阶段 1.5 加载到 RAM 后，阶段 1 将控制权移交给阶段 1.5。

### Stage 1.5
如上所述，GRUB 的 1.5 阶段必须位于引导记录本身和磁盘驱动器上的第一个分区之间的空间中。由于技术原因，这个空间在历史上一直未被使用。硬盘驱动器上的第一个分区从扇区 63 开始，MBR 在扇区 0，剩下 62 512 字节扇区（31,744 字节）用于存储 GRUB 阶段 1.5 的 core.img 文件。core.img 文件是 25,389 字节，因此在 MBR 和存储它的第一个磁盘分区之间有足够的空间。

由于 1.5 阶段可以容纳更多的代码，它可以有足够的代码来包含一些常见的文件系统驱动程序，例如标准 EXT 和其他 Linux 文件系统、FAT 和 NTFS。GRUB2 core.img 比旧的 GRUB1 阶段 1.5 更复杂和更强大。这意味着 GRUB2 的第 2 阶段可以位于标准 EXT 文件系统上，但不能位于逻辑卷上。所以第 2 阶段文件的标准位置是在 /boot 文件系统中，特别是 /boot/grub2。

请注意，/boot 目录必须位于 GRUB 支持的文件系统上。并非所有文件系统都是。阶段 1.5 的功能是使用文件系统驱动程序开始执行，以在 /boot 文件系统中定位阶段 2 文件并加载所需的驱动程序。

### Stage 2
GRUB 阶段 2 的所有文件都位于 /boot/grub2 目录和几个子目录中。 GRUB2 没有阶段 1 和阶段 2 那样的映像文件。相反，它主要由根据需要从 /boot/grub2/i386-pc 目录加载的运行时内核模块组成。

GRUB2 阶段 2 的功能是将 Linux 内核定位并加载到 RAM 中，并将计算机的控制权交给内核。内核及其相关文件位于 /boot 目录中。内核文件是可识别的，因为它们都以 vmlinuz 开头。您可以列出 /boot 目录的内容以查看系统上当前安装的内核。

GRUB2 与 GRUB1 一样，支持从一系列 Linux 内核之一进行引导。Red Hat 包管理器 DNF 支持保留多个版本的内核，以便在最新版本出现问题时，可以引导旧版本的内核。默认情况下，GRUB 提供已安装内核的预引导菜单，包括救援选项和恢复选项（如果已配置）。

GRUB2 的第 2 阶段将选定的内核加载到内存中，并将计算机的控制权交给内核。

## kernel
所有内核都采用自解压压缩格式以节省空间。内核与初始 RAM 磁盘映像和硬盘驱动器的设备映射一起位于 /boot 目录中。

在选定的内核加载到内存并开始执行后，它必须首先从文件的压缩版本中提取自身，然后才能执行任何有用的工作。一旦内核解压了自己，它就会加载 systemd，它是旧 SysV init 程序的替代品，并将控制权交给它。

这是引导过程的结束。此时，Linux 内核和 systemd 正在运行，但无法为最终用户执行任何生产任务，因为没有其他任何东西在运行。

## startup 流程
启动过程遵循引导过程，并使 Linux 计算机进入可用于生产性工作的运行状态。

### systemd
systemd 是所有进程之母，它负责将 Linux 主机提升到可以完成生产性工作的状态。它的一些功能比旧的 init 程序要广泛得多，用于管理正在运行的 Linux 主机的许多方面，包括挂载文件系统，以及启动和管理拥有高效 Linux 主机所需的系统服务。任何与启动顺序无关的 systemd 任务都超出了本文的范围。

首先，systemd 挂载 /etc/fstab 定义的文件系统，包括任何交换文件或分区。此时，它可以访问位于 /etc 中的配置文件，包括它自己的。它使用其配置文件 /etc/systemd/system/default.target 来确定应将主机引导到哪个状态或目标。default.target 文件只是指向真正目标文件的符号链接。对于桌面工作站，这通常是 graphics.target，相当于旧 SystemV init 中的运行级别 5。对于服务器，默认值更可能是 multi-user.target，类似于 SystemV 中的运行级别 3。 Emergency.target 类似于单用户模式。

请注意，`targets `和 `service` 是 `systemd units`。

下面的表 1 是 systemd 目标与旧 SystemV 启动运行级别的比较。 systemd 目标别名由 systemd 提供以实现向后兼容性。目标别名允许脚本（以及许多像我这样的系统管理员）使用 SystemV 命令（如 init 3）来更改运行级别。当然，SystemV 命令会被转发到 systemd 进行解释和执行。
![sysv和systemd对比](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220529-2315.png)

每个目标都有一组在其配置文件中描述的依赖项。 systemd 启动所需的依赖项。这些依赖项是在特定功能级别上运行 Linux 主机所需的服务。当目标配置文件中列出的所有依赖项都加载并运行时，系统就在该目标级别运行。

不推荐使用的网络服务是 Fedora 中仍在使用 SystemV 启动文件的服务的一个很好的例子。systemd 还会查看旧的 SystemV 初始化目录以查看那里是否存在任何启动文件。如果是这样，systemd 使用这些作为配置文件来启动文件描述的服务。

下面的图 1 直接从启动手册页复制而来。它显示了 systemd 启动期间事件的一般顺序以及确保成功启动的基本排序要求。

sysinit.target 和 basic.target 目标可以被视为启动过程中的检查点。尽管 systemd 将并行启动系统服务作为其设计目标之一，但在启动其他服务和目标之前，仍然必须启动某些服务和功能目标。在满足该检查点所需的所有服务和目标之前，无法通过这些检查点。

因此，当它所依赖的所有单元都完成时，就会达到 sysinit.target。所有这些单元，挂载文件系统，设置交换文件，启动 udev，设置随机生成器种子，启动低级服务，如果一个或多个文件系统被加密，则设置加密服务必须完成，但在 sysinit.target 中，这些任务可以并行执行。

sysinit.target 启动所有低级服务和单元，系统需要这些服务和单元才能正常运行，并且需要启用向 basic.target 移动。

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

完成 sysinit.target 后，systemd 接下来启动 basic.target，启动完成它所需的所有单元。基本目标通过启动下一个目标所需的单元来提供一些附加功能。其中包括设置各种可执行目录、通信套接字和计时器的路径。

最后，可以初始化用户级目标 multi-user.target 或 graphics.target。请注意，在满足图形目标依赖关系之前，必须达到 multi-user.target。

图 1 中带下划线的目标是通常的启动目标。当达到这些目标之一时，启动已完成。如果 multi-user.target 是默认值，那么您应该会在控制台上看到文本模式登录。如果 graphics.target 是默认值，那么您应该会看到图形登录；您看到的特定 GUI 登录屏幕将取决于您使用的默认显示管理器。

## 结论
GRUB2 和 systemd init 系统是大多数现代 Linux 发行版的引导和启动阶段的关键组件。尽管围绕 systemd 一直存在争议，但这两个组件可以顺利地协同工作，首先加载内核，然后启动生成功能性 Linux 系统所需的所有系统服务。

尽管我确实发现 GRUB2 和 systemd 都比它们的前辈复杂，但它们也同样易于学习和管理。手册页包含大量关于 systemd 的信息，freedesktop.org 在线提供了完整的 systemd 手册页集。有关更多链接，请参阅下面的资源。



## 其他
### \# 参考内容
- [Working with GRUB 2](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader)
- [An introduction to the Linux boot and startup processes](https://opensource.com/article/17/2/linux-boot-and-startup)
- [linux system boot](https://www.freedesktop.org/software/systemd/man/bootup.html)
