+++
title = "ipmi的使用"
description = "ipmi的介绍和ipmitool工具的使用"
date = "2022-04-01T22:55:50+08:00"
lastmod = "2022-04-01T22:55:50+08:00"
tags = ["ops", "ipmi", "linux"]
dropCap = false
displayCopyright = true
gitinfo = false
draft = true
toc = true
+++

## 说明
日常工作内容，或多或少会包含部分运维相关内容，像：
- 自测环境使用完成，需要重装
- 服务器故障，宕机后无法进入系统定位故障原因
- 修复操作系统，需要设定硬件服务器下次从光盘启动
- ...

如果不具备一些基本条件，可能就需要蹲机房解决这些问题了。

当硬件服务器的管理口有连接到交换机，并且在办公环境下能正常访问该交换机的话，上述的问题就比较好解决了，可以通过 `ipmi` 来查看/管理服务器

### 什么是IPMI
`IPMI` 的全称是 `Intelligent Platform Management Interface`，智能平台管理接口的意思。

`IPMI` 原本是一种`Intel`架构的企业系统的周边设备所采用的一种工业标准

`IPMI` 是一个开放的免费标准，用户无需支付额外的费用即可使用此标准。

`IPMI` 能够横跨不同的操作系统、固件和硬件平台，可以智能的监控、控制和自动上报大量服务器的运作状况，以降低服务器系统成本。

### 发展历史
- 1998年`Intel、DELL、HP`及`NEC`共同提出`IPMI`规格，可以透过网络远程控制温度、电压。

- 2001年IPMI从1.0版改版至1.5版，新增 PCI Management Bus等功能。

- 2004年Intel发表了IPMI 2.0的规格，能够向下兼容IPMI 1.0及1.5的规格。新增了Console Redirection，并可以通过Port、Modem以及Lan远程管理服务器，并加强了安全、VLAN 和刀片服务器的支持性。

- 2014年2月11日，发表了v2.0 revision 1.1, 增加了IPv6的支持。

### ipmi 的特点
- `IPMI` 独立于操作系统外自行运作，允许管理员在即使缺少操作系统或系统关机但有接电源的情况下，仍能远程管理系统。
- `IPMI` 能在操作系统启动后活动，与系统管理功能一并使用时，还能提供加强功能（`linux` 的 `ipmi` 服务）。

### ipmi 的结构
IPMI包含了一个以 `基板管理控制器(BMC：baseboard management controller)` 为主的控制器和其他分布在不同系统模块（被称为“卫星”控制器）的管理控制器。

同一机箱内的卫星控制器通过称为 `智能平台管理总线（IPMB：Intelligent Platform Management Bus/Bridge）`的系统接口连接到BMC - 增强的`I²C（Inter-Integrated Circuit）`的实现。

BMC通过智能平台管理控制器（IPMC）总线连接到另一个机箱中的卫星控制器或其他BMC。

它可以使用 `远程管理控制协议（RMCP：Remote Management Control Protocol）` 进行管理，RMCP是该规范定义的专门电线协议。

![ipmi结构](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220516-2324.png)

### BMC
`IPMI` 的核心是 `BMC`，`BMC` 是一种专门的微控制器，该微控制器嵌入了计算机（通常是服务器）主板上。在工作时，所有的 `IPMI` 功能都是向 `BMC` 传送命令来完成的，命令使用 `IPMI` 规范中规定的指令，`BMC` 接收并在系統事件日志中记录事件信息。

BMC管理系统管理软件和平台硬件之间的接口。BMC拥有专用的固件和RAM。

计算机系统中内置的不同类型的传感器向BMC报告温度、冷却风扇速度、电源状态、操作系统（OS）状态等参数。BMC监视传感器，并可以通过网络向系统管理员发送警报，如果任何参数不在预设限制范围内，则表明系统的潜在故障。管理员还可以与BMC进行远程通信，来采取一些纠正措施，例如重置系统以使hang死的系统再次运行。这些能力降低了系统维护的成本。

符合IPMI版本2.0的系统也可以通过LAN串行进行通信，从而可以在LAN上远程查看串行控制台输出。支持IPMI 2.0的系统通常还包括基于IP的KVM、远程虚拟媒体、嵌入式网络服务器接口功能，尽管严格地说，这些功能都不在IPMI接口标准范围内。

## ipmitool 的使用
ipmitool 是一种可用在 linux 系统下的命令行方式的 ipmi 平台管理工具，它支持 ipmi 1.5 规范（最新的规范为 ipmi 2.0），通过它可以实现获取感测器的信息、显示系统日志内容、网路远程开关机等功能。

### 本地管理
- ipmitool 的安装
```bash
# 安装相应包
$ yum install OpenIPMI OpenIPMI-tools

# 启动 ipmi 服务，才能在 linux 上使用
$ systemctl enable ipmi.service; systemctl start ipmi.service

# 要能够正常的使用 ipmi 功能，需要加载相应的 ipmi 模块
$ modprobe ipmi_msghandler 
$ modprobe ipmi_devintf 
$ modprobe ipmi_si 
$ modprobe ipmi_poweroff 
$ modprobe ipmi_watchdog

# 获取信道信息（一般是信道1）
$ for i in $(seq 1 14); do ipmitool lan print $i 2>/dev/null | grep -q ^Set && echo Channel $i; done
Channel 1
```

- 查看固件版本
```bash
$ ipmitool mc info
```

- 重置 `MC（management controller）`
```bash
# 两种方式，硬重置/软重置
$ ipmitool mc reset [ warm | cold ]
```

- 输出传感器信息（sensor）
```bash
$ ipmitool sdr list                 # list sensor
$ ipmitool sdr type list 
$ ipmitool sdr type Temperature 
$ ipmitool sdr type Fan 
$ ipmitool sdr type 'Power Supply'
```

- chassis 相关命令
```bash
$ ipmitool chassis status 
$ ipmitool chassis identify []    # turn on front panel identify light (default 15s) 
$ ipmitool [chassis] power soft   # initiate a soft-shutdown via acpi 
$ ipmitool [chassis] power cycle  # issue a hard power off, wait 1s, power on 
$ ipmitool [chassis] power off    # issue a hard power off 
$ ipmitool [chassis] power on     # issue a hard power on 
$ ipmitool [chassis] power reset  # issue a hard reset
```

- 修改下一次系统启动的引导设备
```bash
$ ipmitool chassis bootdev pxe    # via pxe
$ ipmitool chassis bootdev cdrom  # via cdrom
$ ipmitool chassis bootdev bios   # into bios setup
```

- 日志相关
```bash
$ ipmitool sel info 
$ ipmitool sel list     # show system event log
$ ipmitool sel elist    # extended list (see manpage) 
$ ipmitool sel clear
```

- 用户配置
```bash
# 打印本机用户
$ ipmitool user list 1
$ ipmitool channel setaccess 1 2 callin=true ipmi=on link=on privilege=4
$ ipmitool user set name 2 root
$ ipmitool user set password 2 password@123
```

- 网络配置
```bash
# 打印信道1上配置的 IP 信息
$ ipmitool lan print 1
# 配置信道1的 IP 相关内容
$ ipmitool lan set 1 ipsrc [ static | dhcp ] 
$ ipmitool lan set 1 ipaddr {YOUR DESIRED IP}
$ ipmitool lan set 1 netmask {YOUR NETMASK}
$ ipmitool lan set 1 defgw ipaddr 10.0.1.1
$ ipmitool bmc reset cold
```

### 远程管理
若需要使用 `ipmi` 远程管理其他主机，则需要在 `ILO` 或 `DRAC` 卡或 `ipmitool` 在 `OS` 上配置用户和网络。

配置 `LAN` 设置后，就可以使用 `ipmitool` 的 `lan` 接口进行远程连接，管理其他同网段的服务器。

- ipmitool 远端管理
```bash
# 远程管理机器
$ ipmitool -I lanplus -U <username> -P <password> -H <BMC_IP or Hostname> chassis power <status|on|off|cycle|reset>

# 重置 BMC
$ ipmitool bmc reset cold

# 激活 SOL 系统控制台
$ ipmitool -I lanplus -U <username> -P <password> -H <BMC_IP or Hostname> sol activate
# 退出 SOL 系统控制台
$ ipmitool -I lanplus -U <username> -P <password> -H <BMC_IP or Hostname> sol activate
```
## 共享口和独享口
物理服务器会有一个单独的 `BMC` 管理口，一般是千兆网口; 进入 `BIOS` 设置，配置 `BMC IP`，IP 地址生效的网口就是这个管理口。
这个管理口在 `BIOS` 中可以配置两种模式：共享模式、独享模式

### 共享模式
共享模式可以在 `BIOS` 中设置，要清楚共享模式的实现，需要先了解 `网络控制器边带接口：NC-SI（network controller sideband interface）`，这一技术是用来实现 `BMC` 芯片和以太网控制器之间信息传递的，它使得 `BMC` 芯片能够像使用独立管理网口那样使用主板上的网络接口。  
NC-SI 支持将 `BMC(baseboard management controller)` 连接到服务器计算机系统中的一个或多个网络接口控制器 `(NIC：network interface controllers)`，以实现带外系统管理。这使得对应网口除了常规的主机流量外，还可以接受 `BMC` 的管理网流量。  
![NC-SI](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220518-2329.png)

简单理解：`BMC` 其实是一个单片机，它有自己独立的 `IO` 设备，而独立网口就是其中之一。将`BMC`芯片和网络控制器之间互联，并通过 `NC-SI` 技术使得 `BMC` 芯片能够使用网络控制器上的接口。  

#### 共享模式优势
如下几方面：
- 减少物料成本：可以在物理机系统需要配置千兆网时，节省一根网线
- 减少交换机投入：独立网口会多占用一个交换机端口，增加交换机采购数量，使用共享模式减少了这部分的支出和额外的交换机运维成本
- 减少人力成本：如果业务网只需要接一根网线，共享方案可以减少一半的布线人力支出；

#### 共享模式潜在风险
如下：
- 系统千兆网和 `BMC` 管理网使用的是同一个物理网口，网口故障时，`BMC` 和 千兆网将同时不可访问，单点故障

#### 共享模式配置
不同型号硬件服务器界面可能不一样，实际的配置内容相同，都是通过 `BIOS` 或者 `BMC WEB界面` 将 `IPMI` 访问方式修改为 `share（共享模式）`。

### 独享模式
独享模式是默认模式，`BMC` 管理网单独使用一个网口，不和系统共用。

### python接口使用
    
    安装
        rpm包:python-ipmi
        pip包:pyipmi
    接口调用

### 服务器接线
    
    接在管理口,需要连接到千兆交换机
    千兆网同时使用管理口,pxe同时使用这个口
    千兆网只做管理口,万兆网作为PXE口

## 其他
参考内容：  
[https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface)  
[https://www.easyatm.com.tw/wiki/ipmitool](https://www.easyatm.com.tw/wiki/ipmitool)  
[https://www.ibm.com/docs/en/power9/0000-FUL?topic=msbui-common-ipmi-commands-2](https://www.ibm.com/docs/en/power9/0000-FUL?topic=msbui-common-ipmi-commands-2)  
[https://serverfault.com/questions/259792/how-does-ipmi-sideband-share-the-ethernet-port-with-the-host](https://serverfault.com/questions/259792/how-does-ipmi-sideband-share-the-ethernet-port-with-the-host)  
[https://developer.aliyun.com/article/544871](https://developer.aliyun.com/article/544871)  