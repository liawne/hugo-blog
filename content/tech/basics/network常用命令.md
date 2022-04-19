+++
title = "Network常用命令"
description = "一些常用的 network 命令"
date = "2017-04-19T22:12:14+08:00"
lastmod = "2022-04-19T22:12:14+08:00"
tags = ["network", "basic", "note"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = true
toc = true
+++

## route

    a、由于路由是依照顺序来排列与传送的，所以无论数据包是由哪个接口所接收，都会按照第一个匹配的行对应的 \
        接口发送出去 --> 在一台主机设置两个相同网络的IP本身没有什么意义
    b、删除路由表内容时，需要将路由表上出现的内容都写入（dev，netmask等参数）
        route del -net 169.254.0.0 netmask 255.255.0.0 dev eth0
    c、增加一条路由时，该路由的设置必须要能够与自己的网络相通
        route add -net 192.168.100.0 netmask 255.255.255.0 dev eth0
    d、增加默认路由的方法，在一台主机中，只要一个默认路由
        route add default gw 192.168.1.250
## ifconfig

    1、临时增加ip地址
        ifconfig ethx 192.168.110.11
        ifconfig ethx 192.168.110.11 netmask 255.255.255.0 
    2、使用ifconfig让配置的临时配置的ip失效
        ifconfig eth0：0 down
## ip

    用法：ip [option] [operation] [command]
    option：设置的参数
    operation：需要执行的动作
        -s：显示设备的统计数据
    command：命令
        link：与设备相关的设置
        addr/address：与ip相关
        route：与路由相关
    a、与接口设备相关的设置：ip link（第二层，数据链路层）
        ip link show
        ip link set [device] [operations and parameters]
            set：开始设置
            device：需要进行操作的设备
            operations and parameters：
                up|down：启停某个接口
                address：如果该设备可更改mac地址，可用该参数修改
                name：修改该设备，给予一个特殊的名字
                mtu：最大传输单元
         eg：
            ip link set eth0 down
            ip link set eth0 name ruiwen
            ip link show eth0
            ip link set eth0 address aa：aa：aa：aa：aa：aa（MAC地址）
    b、额外ip相关的设定：ip address（第三层，网络层）
        ip address show --> 仅显示接口的IP信息
        ip address [add|del] [IP参数] [dev设备名] [相关参数]
            del|add：进行相关参数的增加或删除
                IP参数：网络配置之类
                dev：这个IP参数所要设置的接口，如eth0，eth1等
                    相关参数有如下：
                        broadcast：设置广播地址，‘+’ 表示为让系统自己计算
                        lable：设置设备的别名
                        scope：包含几大类
                            global：允许来自所有来源的连接
                            site：进支持ipv6,进允许本主机的连接
                            link：仅允许本设备自我连接
                            host：仅允许本主机的内部连接
                            默认为global
        eg：
            ip address show
            ip address add 192.168.110.12/24 broadcast + dev eth0 label eth0：ruiwen
            ip address del 192.168.110.12/24 dev eth0
    c、路由的相关设定：ip route（功能几乎与route相同）
        ip route show
        ip route [add|del] [IP或网络号] [via gateway] [dev 设备]
            show：显示路由表
            add|del：添加或者删除路由表
                IP或网络：可使用192.168.110.0/24等网络号或单纯的IP地址
                via：从这一个gateway出去，不一定需要
                dev：从哪个设备出去，这个需要
                mnt：可额外设置mtu值大小
        eg：
            ip route add 192.168.5.0/24 dev eth0
            ip route show
            ip route add 192.168.10.0/24 via 192.168.5.100 dev eth0
            ip route add default via 192.168.1.254 dev eth0
            ip route del 192.168.10.0/24
## traceroute

    traceroute [选项或参数] IP
    选项或参数：
        -n：可以不必进行主机的名称解析，使用IP
        -U：使用UDP的33434端口来进行检测，默认检测协议
        -I：使用ICMP的方式来进行检测
        -T：使用TCP的方式来进行检测，一般使用port 80测试
        -w：若对方主机在几秒内没有回应就声明不通，默认为5秒
        -p 端口号：若不想使用UDP与TCP的默认端口号来进行检测，可在此改变端口号
        -i 设备：指定设备，网络接口比较 复杂时，才会用到这个参数
    出现× × ×的输出时，表示可能有防火墙设备等导致
    traceroute默认使用UDP数据包，可切换为其他，例如使用-T指定为TCP
    eg：
        traceroute -n -w 1 -T www.google.com
## netstat

    netstat -[antulpc]
        -a：列出所有的连接状态，包括tcp/udp/unix socketdeng
        -n：不使用主机名与服务名，使用ip和port number
        -t：列出TCP数据包的连接
        -u：列出UDP数据包的连接
        -l：仅列出已在listen（监听）状态的服务的网络连接
        -p：列出PID和program的文件名
        -c：设置几秒后自动刷新一次
    netstat -an的输出结果中stat状态栏主要的状态包含有：
        ESTABLISHED：已经建立的连接状态
        SYN_SENT:发出主动连接（SYN连接）的连接数据包
        SYN_RECV:接受到一个要求连接的主动连接数据包
        FIN_WAIT1:该套接字服务已中断，该连接正在断线当中
        FIN_WAIT2:该连接已挂断，但正在等待对方主机响应断线确认的数据包
        TIME_WAIT:该连接已挂断，但socket还在网络上等待结束
        LISTEN:通常用在服务的监听port
    查看自己主机开了多少port在等待客户端的连接：
        netstat -tulnp ×××
## host/nslookup

    用来作为IP与主机名对应的检查，使用/etc/resolv.conf文件作为DNs服务器的来源选择
## tcpdump

    tcpdump [-AennqX] [-i 接口] [-w 存储文件名] [-c次数] [-r 文件] [所要摘取的数据包数据格式]
    -A：数据包的内容以ASCII显示，通常用来抓取WWW的网页数据包数据
    -e：使用数据链路层
    -nn：直接以ip和port number显示，而非主机名和服务名称
    -q：仅列出较为简单的数据包信息，每一行的内容比较精简
    -i：后接需要监听的网络端口
    -w：后接文件名，将监听所得的数据保存至文件中
    -r：后接文件名，将文件中的内容数据读取出来
    -c：监听的数据包数，如果没有这个参数，tcpdump会持续不间断的监听
    
    所要摘取的数据包数据格式：可以专门针对某些协议或者是IP来源进行数据包捕获，简化输出结果，获取有效信息
    常用方式：
        ‘host foo’、‘host 127.0.0.1’：针对单台主机来进行数据包捕获
        ‘net 192.168’：针对某个网络来进行数据包的捕获
        ‘src host 127.0.0.1’ ‘dst net 192.168’：同时加上来源（src）或目标（dst）限制
        ‘tcp port 21’：针对通信协议进行检测，如tcp，udp，arp，ether等
        还可以使用and和or来进行数据包数据的显示
    
