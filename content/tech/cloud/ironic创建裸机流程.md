+++
title = "Ironic创建裸机流程"
description = "ironic创建一台裸机的流程及实现原理"
date = "2022-03-13T22:58:17+08:00"
lastmod = "2022-03-13T22:58:17+08:00"
tags = ["云计算","pxe"]
dropCap = false
displayCopyright = false
gitinfo = false
draft = true
toc = false
+++
裸机是openstack的一个重要功能分支

裸机的创建流程:
- 物理机的ipmi网络要和控制节点联通,这样在创建物理机时,控制节点才能通过ipmi命令直接下发指令,让物理机重启并通过pxe启动

- 裸机需要最少两个网口
  - 万兆口,业务网流量和pxe配置物理机的口
  - 千兆口,ipmi IP配置的口；可以是共享口也可以是独享口
  
- 在裸机层面,前后共需要用到三个IP,分别是ipmi IP,pxe IP,业务IP
  - ipmi IP只在千兆口上使用,连接的千兆交换机不需要配置vlan,只需要网络能够联通即可
  - pxe IP和业务IP在不同阶段配置在万兆网口上;裸机刚开始部署时,直连交换机的对应口放行的vlan是ironic pxe使用的,比如4000;当api判断已经安装成功后,直连交换机的对应口vlan改变,为业务vlan范围,这些动作都是通过neutron来实现的
  
- ironic怎么实现装机的
  - 裸机镜像制作: 分为三个镜像,分别是kernel,ramdisk,qcow2
    - kernel当前使用的是centos7的内核
    - ramdisk使用的是与kernel配套的内存文件系统镜像
    - qocw2我们需要安装的系统镜像,挂载后直接dd到系统盘
  - ramdisk中包含服务IPC(ironic-python-client),通过这个服务完成整个物理机系统安装的过程
    - 通过与ironic-api的交互,判断是否完成安装