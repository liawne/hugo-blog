+++
title = "Pacman 常用命令"
description = "pacman的一些常用命令"
date = "2022-08-16T22:45:44+08:00"
lastmod = "2022-08-16T22:45:44+08:00"
tags = ["manjaro", "shell", "linux", "basic"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## \# 软件安装
```bash
## 安装软件，也可以同时安装多个包，只需以空格分隔包名即可
$ pacman -S software_name1 software_name2
## 安装软件，但不重新安装已经是最新的软件
$ pacman -S --needed software_name1 software_name2
## 安装软件前，先从远程仓库同步软件包数据库
$ pacman -Sy software_name
## 安装时显示一些详细信息
$ pacman -Sv software_name
## 只下载软件包，不做安装操作
$ pacman -Sw software_name
## 安装本地软件包
$ pacman -U software_name.pkg.tar.gz
## 安装一个远程包（不在 pacman 配置的源里面）
$ pacman -U http://www.example.com/repo/example.pkg.tar.xz 
```

## \# 软件更新
```bash
## 同步软件包数据库
$ pacman -Sy
## 升级所有已安装的软件包
$ pacman -Su
## 同步最新的软件包数据库后，更新当前环境的包
$ pacman -Syyu
```

## \# 软件卸载
```bash
## 该命令将只删除包，保留其全部已经安装的依赖关系
$ pacman -R software_name
## 删除软件，并显示详细的信息
$ pacman -Rv software_name
# 删除软件，同时删除本机上只有该软件依赖的软件
$ pacman -Rs software_name
# 删除软件，并删除所有依赖这个软件的程序，慎用
$ pacman -Rsc software_name
# 删除软件,同时删除不再被任何软件所需要的依赖
$ pacman -Ru software_name
```

## \# 软件搜索
```bash
## 在仓库中搜索含关键字的软件包（本地已安装的会标记）
$ pacman -Ss 关键字
## 显示软件仓库中所有软件的列表; 可以省略 repo，通常这样用:`$ pacman -Sl | 关键字`
$ pacman -Sl <repo>
## 搜索已安装的软件包
$ pacman -Qs 关键字
## 列出所有可升级的软件包
$ pacman -Qu
## 列出不被任何软件要求的软件包
$ pacman -Qt
## 搜索文件属于哪个软件包（根据当前软件包数据库查找)
$ pacman -Qo filename
## 查看软件包是否已安装，已安装则显示软件包名称和版本
$ pacman -Q software_name
## 查看某个软件包信息，显示较为详细的信息，包括描述、构架、依赖、大小等等
$ pacman -Qi software_name
## 列出软件包内所有文件，包括软件安装的每个文件、文件夹的名称和路径
$ pacman -Ql software_name
```

## \# 软件缓存
```bash
## 清理未安装的包文件，包文件位于 /var/cache/pacman/pkg/ 目录
$ pacman -Sc
## 清理所有的缓存文件
$ pacman -Scc
```
