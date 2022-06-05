+++
title = "systemd介绍"
description = "systemd是什么，systemd的构成"
date = "2022-06-02T23:05:38+08:00"
lastmod = "2022-06-02T23:05:38+08:00"
tags = ["linux", "systemd", "boot"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## \# 说明
### \# 什么是 systemd
`systemd` 是一个软件套件，它为 `linux` 操作系统提供一系列系统组件。它的主要目标是统一 `linux` 发行版中的服务配置和行为；它的主要组件是 `system and service manager` —— 一个用于启动用户空间和管理用户进程的 `init` 系统。它还提供各种守护程序和实用程序的替代品，包括设备管理（`device management`）、登录管理（`login management`）、网络连接管理（`network connection management`）和事件日志记录（`event logging`）。

自 `2015` 年以来，大多数 `linux` 发行版都采用了 `systemd`，取代了其他 `init` 系统，例如 `SysV init`。

### \# systemd的历史
最初开发 `systemd` 是 `Red Hat` 软件工程师 `Lennart Poettering` 和 `Kay Sievers` 于 `2010` 年启动的一个项目，目的是用来取代 `linux` 的传统 `System V init`。`Poettering` 在 `2010 年 4 月`发表的一篇题 {{< underline color="#ffdd00" content="重新思考 PID 1 " >}}的博客文章，引入了后来成为 systemd 的实验版本; 他们试图以多种方式超越 `init` 守护进程的效率。他们希望改进表达依赖关系的软件框架，来允许在系统启动期间同时或并行完成更多任务。

`2011 年 5 月`，`Fedora` 成为第一个默认启用 `systemd` 的主要 `linux` 发行版，取代了 `SysVinit`。当时的理由是 `systemd` 在启动期间提供了广泛的并行化、更好的流程管理以及总体上更理智、基于依赖关系的系统控制方法。

`2012 年 10 月`，`Arch linux` 将 `systemd` 设为默认值，也完成了从 `SysVinit` 的切换。

`2013 年 10 月`至 `2014 年 2 月` 期间，`Debian` 技术委员会在经过长时间的辩论后，最终做出决定，在 `Debian 8"jessie"`上使用 `systemd`。

`2014 年 2 月`，在 `Debian` 做出决定后，`Mark Shuttleworth` 在他的博客上宣布 `Ubuntu` 将跟随实施 `systemd`，放弃自己的 `Upstart`。

## systemd的实现
### \# 设计
`Poettering` 将 `systemd` 开发描述为 `never finished, never complete, but tracking progress of technology（远未完成、远未完美、只跟随技术进步）`。

`2014 年 5 月`，`Poettering` 通过提供以下三个通用功能进一步将 `systemd` 描述为`pointless differences between distributions（版本之间无大差异）`：
- 系统和服务管理器（通过应用各种配置来管理系统及其服务）
- 软件平台（作为开发其他软件的基础）
- 应用程序和内核之间的粘合剂（提供各种接口来暴露内核提供的功能）

`systemd` 包括诸如按需`启动守护进程`、`快照支持`、`进程跟踪`和`抑制剂锁（Inhibitor Locks）`等功能。它不仅仅是`systemd init daemon`的名字，还指代围绕它的整个软件包，除了`systemd init`守护进程之外，还包括守护进程`journald`、`logind`和`networkd`以及许多其他基础组件。

`2013 年 1 月`，`Poettering` 将 `systemd` 描述为不是一个程序，而是一个包含 `69` 个单独二进制文件的大型软件套件。作为一个集成的软件套件，`systemd` 取代了由传统 `init` 守护进程控制的启动顺序和运行级别，以及在其控制下执行的 `shell` 脚本。`systemd` 还通过处理用户登录、系统控制台、设备热插拔（`device hotplugging`）、计划执行（`替换 cron`）、日志记录、主机名和语言环境来集成 `Linux` 系统上常见的许多其他服务。

与 `init` 守护进程一样，`systemd` 是一个管理其他守护进程的守护进程，这些守护进程包括 `systemd` 本身都是后台进程。 `systemd` 是在引导期间启动的第一个守护进程，也是在关机期间终止的最后一个守护进程。`systemd` 守护进程充当用户空间进程树的根；第一个进程`（PID 1）`在 `Unix` 系统上具有特殊的作用，因为它会在原始父进程终止时替换进程的父进程，因此，第一个进程特别适合用于监控守护进程。

`systemd` 并行执行其启动序列的元素，这在理论上比传统的启动序列方法更快。对于进程间通信 (`IPC`)，`systemd` 使 `Unix` 域套接字（`Unix domain sockets`）和 `D-Bus` 可用于正在运行的守护进程。 `systemd` 本身的状态也可以保存在快照中以备将来调用。

### \# 核心组件和库
**systemd组件和库**  
![systemd组件和库](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220605-1626.png)
遵循 `systemd` 的集成方法，`systemd` 还提供各种守护程序和实用程序的替代品，包括启动 `shell` 脚本、`pm-utils`、`inetd`、`acpid`、`syslog`、`watchdog`、`cron` 和 `atd`。   
systemd 的核心组件包括：
- `systemd` 是 `linux` 操作系统的系统和服务管理器。
- `systemctl` 是一个自省和控制 `systemd` 系统和服务管理器状态的命令(不要与 sysctl 混淆)。
- `systemd-analyze` 可用于确定系统启动性能统计数据，并从系统和服务管理器检索其他状态和跟踪信息。  

`systemd` 使用 `linux` 内核的 `cgroups` 子系统而不是使用`进程标识符 (PID)` 来跟踪进程；因此，守护进程无法逃离 `systemd`，即使是通过 `double-forking` 也不行。  
`systemd` 不仅使用 `cgroup`，还使用 `systemd-nspawn` 和 `machinectl` 来扩充它们，这两个实用程序有助于创建和管理 `linux` 容器。  
从`版本 205` 开始，`systemd` 还提供 `ControlGroupInterface`，它是 `linux` 内核 `cgroups` 的 `API`。`linux` 内核 `linux` 适用于支持 `kernfs`，并且正在被修改以支持统一的层次结构。  

**统一层次的 `cgroup` 将由 `systemd` 通过 `systemd-nspawn` 独占访问**  
![systemd-nspawn](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220605-1627.png)

### \# 辅助组件
除了提供 `linux` 初始化系统的主要目的之外，`systemd` 套件还可以提供其他功能，包括以下组件：  
**journald**  
`systemd-journald` 是一个负责事件记录的守护进程，使用 `append-only` 的二进制文件作为其日志文件。系统管理员可以选择是否使用 `systemd-journald`、`syslog-ng` 或 `rsyslog` 记录系统事件。  
**libudev**  
`libudev` 是使用 `udev` 的标准库，它允许第三方应用程序查询 `udev` 资源。  
**localed**  
负责系统语言环境和键盘布局  
**logind**  
`systemd-logind` 是一个以各种方式管理用户登录和席位的守护进程。它是一个集成的登录管理器，提供`多席位（multiseat）`改进并取代不再维护的 `ConsoleKit`。对于 `X11` 显示管理器，切换到 `logind` 需要很少的移植。 `logind` 集成在 `systemd version 30` 中。  
**networkd**  
`networkd` 是处理网络接口配置的守护进程；在 `verion 209` 中，`networkd` 首次被集成到`systemd`，支持场景较少，仅限于静态分配的地址和对桥接配置的基本支持。`2014 年 7 月`，`systemd 版本 215` 发布，增加了 `IPv4` 主机的 `DHCP` 服务器和 `VXLAN` 支持等新功能。`networkctl` 可用于查看 `systemd-networkd` 所看到的网络链接的状态。 必须在 /lib/systemd/network/ 下添加新接口的配置作为以 .network 扩展名结尾的新文件。要添加新接口的配置，必须在 `/lib/systemd/network/` 新增以 `.network` 扩展名结尾的新文件。  
**resolved**  
**systemd-boot**  
`systemd-boot` 是一个引导管理器，以前称为 `gummiboot`。 `Kay Sievers` 将其合并到 `systemd with rev 220`。  
**timedated**  
`systemd-timedated` 是一个守护进程，可用于控制与时间相关的设置，例如系统时间、系统时区或 `UTC` 和本地时区系统时钟之间的选择。`timedated` 可以通过 `D-Bus` 访问，在`systemd 版本 30` 中被集成。  
**timesyncd**  
**tmpfiles**  
`systemd-tmpfiles` 是一个负责创建和清理临时文件和目录的实用程序。它通常在启动时运行一次，然后以指定的时间间隔运行。  
**udevd**  
`udev` 是 `linux` 内核的设备管理器，它处理 `/dev` 目录和添加/删除设备时的所有用户空间操作，包括固件加载。`2012 年 4 月`，`udev` 的源代码树被合并到 `systemd` 源代码树中。
`2014 年 5 月 29 日`，通过 `udev` 加载固件的支持从 `systemd` 中删除，应该由内核应该负责加载固件。

### \# systemd的配置
`systemd` 仅通过纯文本文件进行配置。  
`systemd` 将每个守护进程的初始化指令记录在使用声明性语言的配置文件（称为"单元文件(unit file)"）中，替换传统上使用的每个守护进程启动 `shell` 脚本。配置文件支持 `crudini` 配置。

`单元文件（unit file）` 类型包括：
- `.service`
- `.socket`
- `.device` (由 `systemd` 自动启动)
- `.mount`
- `.automount`
- `.swap`
- `.target`
- `.path`
- `.timer` (可以用作类似 `cron` 的作业调度程序)
- `.snapshot`
- `.slice` (用于对流程和资源进行分组和管理)
- `.scope` (用于对工作进程进行分组，不打算通过单元文件进行配置)

## \# 其他
### \# 参考内容
**本文内容参考自：**  
- [systemd](https://en.wikipedia.org/wiki/Systemd)
