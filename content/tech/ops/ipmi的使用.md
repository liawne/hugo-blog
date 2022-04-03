+++
title = "Ipmi的使用"
description = ""
date = "2022-04-01T22:55:50+08:00"
lastmod = "2022-04-01T22:55:50+08:00"
tags = [""]
dropCap = false
displayCopyright = false
gitinfo = false
draft = true
toc = false
+++

## 说明
### 什么是IPMI
###在什么情况下使用

## 怎么使用
###网口的选择
    共享口
    独享口
###相关命令
    信息确认
        用户信息
        信道信息
        地址信息
        状态信息
    配置命令
        配置用户帐号密码
        配置机器地址相关
        配置启动方式
        系统重置
    操作方式
        本机操作
        指定IP操作
###python接口使用
    安装
        rpm包:python-ipmi
        pip包:pyipmi
    接口调用

## 关联内容
###服务器bios配置
    设置管理口是否为共享模式
        优势
            省网口/网线
            系统上配置IP后可以直接连接
        劣势
            容错率低,系统需要使用的千兆网怀了,都不能用了
###服务器接线
    接在管理口,需要连接到千兆交换机
    千兆网同时使用管理口,pxe同时使用这个口
    千兆网只做管理口,万兆网作为PXE口
###名词解释
    BMC
