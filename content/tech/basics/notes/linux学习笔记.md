+++
title = "Linux 学习笔记"
description = ""
date = "2017-11-16T22:56:06+08:00"
lastmod = "2022-04-13T22:56:06+08:00"
tags = ["linux", "basic", "note"]
dropCap = false
displayCopyright = true
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++

## 用户管理   
\#\# 2017-11-12 ##  
- redhat 禁止空密码用户登录  
- `pwck` 检查用户帐号完整性，依据 `/etc/passwd`  
- `useradd/groupadd -r` 添加一个系统帐号/组，`uid/gid` 小于 500/1000，系统用户/组默认不存在家目录  
- newgrp 临时更改用户的初始组(登录到一个新组)，用户属于切换组时不需要密码，需要退出时使用 exit(newgrp 为登录属性)命令即可  
- 用户在/etc/passwd 文件中保存的注释信息顺序-c，name,office,office-phone,home-phone  
- 新增一个用户可完全使用手动添加的方式，涉及 4 个文件，/etc/{passwd,shadow,group,skel/*}，skel 目录下的文件全部复制后需要修改文件权限和属组;  

## 权限管理 
\#\# 2017-11-12 ##  
- 普通权限   
  ```
  r--> 文本文件 cat,more,less; 目录文件 ls,不能使用 cd,ls -l;  
  w--> 文本文件 可写，可编辑，可删除; 目录文件 可在该目录下新建文件;  
  x--> 文本文件 判断运行方式，新启动一个进程; 目录文件，可在该目录下 ls -l,cd 进入，获取目录下文件的详细信息;  
  ```
  {{<notice tip>}}
  目录文件的执行权限不同于普通文件，具备了执行权限之后，才允许用户获取目录下的文件详情  
  The execute bit on a directory allows you to access items that are inside the directory, even if you cannot list the directories contents.
  {{</notice>}}

- 可使用 openssl 生成密码
  ```
  # 生成后的字符串可放入 /etc/shadow 文件中
  $ openssl passwd -1 -salt '123456'  
  ```
- shell 类型
  ```
  登录式 shell: 正常通过某终端登录，su - USERNAME，su -l USERNAME;
  非登录式 shell: su USERNAME，图形终端下打开的命令窗口，自动执行的shell脚本;
  ```
- 环境变量保存文件：
  ```
  profile类文件: 设定环境变量，运行脚本或命令;  
  bashrc类文件: 设定本地变量，定义命令别名;
  ```

## 重定向   
\#\# 2017-11-16 ##
- 系统设定
  ```
  默认输出设备：标准输出，STDOUT 1
  默认输入设备：标准输入，STDIN  0
  标准错误输出：STDERR，2
  ```
- 标准输入：键盘,标准输出：显示器  
- set -C 可以关闭重定向清空非空文件，set +C 关闭该功能；在-C 指定时>|可强制清空  
- 并无 &>> 的追加重定向  
- cat 与重定向结合使用
  ```
  cat << END --> Here Document
  cat << END >>/> 追加/创建文件
  ```
- 管道：把前一个命令的输出当作下一个命令的输入  
- tee ：ls /etc | tee /tmp/tmp.out 

## 正则表达式   
\#\# 2017-11-16 ##
- 元字符
  ```
  .：匹配任意单个字符
  []：匹配指定范围内的任意字符
  [^]：匹配指定范围外的任意字符
  字符集合：[:digit:],[:upper:],[:punct:],[:space:],[:alpha:],[:alnum:]
  ```
- 匹配次数
  ```
  - *:匹配其前面的字符任意次
  ?:匹配其前面的字符0次或1次
  \{m,n\}:匹配其前面的字符至少m次,至多n次
  ```
- 位置锚定
  ```
  ^:锚定行首,此字符后出现的任意字符必须出现在行首
  $:锚定行尾,此字符前出现的任意字符必须出现在行尾
  ^$:空白行
  \<或\b:锚定词首,其后面的任意字符必须作为单词的首部出现
  \>或\b:锚定词尾,其后面的任意字符必须作为单词的尾部出现
  eg:
      egrep "^(root|hadoop)\b" /etc/passwd
  ```
- 分组
  ```
  \(\):括号中的内容作为一个整体,主要是作为后向引用.
    \1:引用第一个左括号以及与之对应的右括号所包括的所有内容
    \2:
    \3:
      eg:
      1-> grep \(ab\)* /tmp/tmpfile
      2-> he love his lover
         grep '\(l..e\).*\1r' /tmp/tmpfile
  ```
- 默认情况下,正则表达式工作在贪婪模式下,尽可能多的匹配  
- grep/egrep -o 的使用（主要是正则表达式的使用）  
  ```
  $ echo aaabbbccabababcaccaccacbabcbabbacbcacabcba | egrep -o '[abc]{1,3}'
   aaa
   bbb
   cca
   bab
   abc
   acc
   acc
   acb
   abc
   bab
   bac
   bca
   cab
   cba
  # 抓取出来的结果是在[]中三个字母的任意组合
  ```

## 扩展正则表达式   
\#\# 2017-11-21 ##
- grep: 使用基本正则表达式定义的模式来过滤文本的命令；
  ```
  -A
  -B
  -C
  ```
- 扩展正则表达式:
```    
字符匹配同基本正则表达式
  次数匹配:
    *:
    ?:
    +:匹配其前面的字符至少一次
    {m,n}
    位置锚定同基本正则表达式
    
  分组:
    ():分组
    \1,\2,\3,.....
    
  或者: |
    分组示例:
      grep -E '(C|c)at' test6.txt
      匹配0-255之间的数字: \<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>
```
- fgrep:不支持正则表达式,可快速搜索   

## bash scripts 1
\#\# 2017-11-21 ##
- shell 编程:  
  ```
  编译器,解释器
  编程语言:
    机器语言,汇编语言,高级语言
  
  静态语言:编译型语言
    强类型(变量)
    实现转换成可执行程序
    C,C++,JAVA,C#
  
  动态语言:解释型语言 on the fly
    弱类型
    边解释边执行
    PHP,SHELL,python,perl
  
  面向对象
  面行过程
  ```
- 变量:内存空间,被命名的内存空间
  ```    
  内存:编址的存储单元
    变量类型:事先确定数据的存储格式和长度
      字符
      数值
        整形
        浮点型
      bull类型:逻辑运算,与,或,非,抑或
        与:只要一个为假,结果一定为假
        或:只要一个为真,结果一定为真
  ```
- shell:弱类型编程语言
  ```
  强类型:变量在使用前,必须事先声明,甚至还需要初始化.  
  弱类型:变量用时声明.甚至不区分类型.  
  变量赋值:VAR_NAME=VALUE 
  ``` 
- bash 变量:
  ```
  环境变量:作用与为当前shell及其子进程,export NAME=xxx
  本地变量:整个bash进程
  局部变量:作用域为当前代码块
  位置变量:
  特殊变量(系统变量):
    $?:上一个命令的执行状态返回值
    程序执行,可能有两类返回值:
      程序执行结果
      程序状态返回代码(0-255)
        0:正确执行
        1-255:错误执行,1,2,127系统预留
  ```
- 脚本在执行时会启动一个子 shell 进程  
    命令行中启动的脚本会继承当前 shell 环境变量;  
    系统自动执行的脚本(非命令行启动)就需要自我定义各种环境变量;  
- /dev/null --> bit bucket 软件设备  
- 撤销变量:用于回收资源,内存空间,unset VAR_NAME  
- 默认情况下,bash 将所有变量均识别为字符串  
- 脚本:命令的堆砌,按照实际需求,结合命令流程控制机制实现的源程序  

## bash scripts 2
\#\# 2017-11-21 ##
- bash 中如何实现条件判断
  ```
  条件测试类型:
      整数测试:
      字符测试:
      文件测试:
  
  条件测试的表达式:
      [ expression ]
      [[ expression ]]
      test expression
  ```
- 整数测试:
  ```
  -eq:测试两个整数是否相等
  -ne:测试两个整数是否不等,不等,为真;相等,为假;
  -le:
  -ge:
  -lt:
  -gt:
  ```
- 命令间的逻辑关系:
  ```
  逻辑与: &&
    第一个条件为假时,第二个条件不用再判断,最终结果已有;
    第一个条件为真时,第二个条件必须得判断;
  逻辑非: ||
  ```

## 软件包管理 rpm 1
\#\# 2017-11-21 ##

1,应用程序

    程序,architecture
    源代码-->编译-->链接-->运行
        程序:
            库
                静态
                动态

                静态链接
                动态链接
                    共享库
2,程序组成部分:

    二进制文件
    库
    配置文件
    帮助文件/usr/share/man
    /etc,/bin /sbin,/lib -->    均不可使用单独分区,必须在根文件系统分区上,系统启动就需要使用的程序
    /usr/                -->    操作系统核心功能,可以单独分区(可以单独格式化根分区,在挂载/usr可使用)
        bin
        sbin
        lib

    /usr/local
        bin
        sbin
        lib
        etc
        man
3,/proc,/sys 不能单独分区,默认为空;

    proc接口,sys硬件接口
4,/dev:设备,不能单独分区

    udev:能够利用内核识别到的硬件信息,动态的创建设备名;内核识别设备是通过驱动程序来实现的;
5,/boot:内核,initrd(initramfs)

    内核:
    POST-->BIOS(HD)-->(MBR)bootloader(文件系统结构,ext2,ext3,xfs)-->内核
    /boot分区其实是先被访问后,启动内核再被挂载起来的
    lvm是属于内核中的功能,所以尽量不要将boot分区与根目录放在一个分区上
5,程序=指令+数据

    指令:芯片
        CPU:普通指令,特权指令
        指令集:
6,软件包管理器:

    a,打包成一文件:二进制文件,库文件,配置文件,帮助文件
    b,生成数据库,追踪所安装的每一个文件
7,软件包管理器的核心功能:

    a,制作软件包
    b,安装,卸载,升级,查询,校验
    c,RedHat,SUSE,Debian
        RedHat SUSE
            RedHat Package Manager
            RPM is Package Manager
        Debian:dpt
8,前端工具:yum(yellowdog update modifier),apt-get 

    后端工具:RPM,dpt

## 软件包管理 rpm 2
\#\# 2017-11-27 ##  
1,rpm 命令:

    rpm:
        数据库/var/lib/rpm
    rpmbuild:
2,安装,卸载,升级,查询,校验,数据库的重建,验证数据包等工作  
3,rpm 命名:

    包:组成部分
       主包:
          bind-9.7.1-1.i586.el5.rpm
       子包:
          bind-libs-9.7.1-1.i586.el5.rpm
    包名格式:
       name-version-release.arch.rpm
       bind-major.minor.release-release.arch.rpm
  
    主版本号:重大改进
    次版本号:某个子功能发生重大变化
    发行版:修正了部分bug,调整了一点功能
    release1:开发者
    release2:制作者
4,rpm 安装

    -h:显示安装进度,以#显示,每个#表示2%的进度
    -v:表示详细过程
    -vv:更详细的过程
    --nodeps:忽略依赖关系
    --replacepkgs:重新安装,替换原有安装
    --oldpackage:使用就的软件包替换新的软件包
    --force:强制安装,可以实现重装或降级
5,rpm 查询--> rpm -q PKGS_NAME

    -qa:查询所有安装的软件包
    -qi:查询指定软件包的说明信息
    -ql:查询指定包安装后生成的文件列表
    -qf:查询指定的文件是由哪个rpm包安装后生成的
    -qc:查询指定的包安装的配置文件
    -qd:查询指定包安装的帮助文件
    -q --scripts:查询指定包中包含的脚本
    -qp*:查询尚未安装的软件包的相关内容,承接已安装的软件包的查询内容
6,rpm 升级

    -Uvh: 如果装有老版本的,则升级;否则,则安装;
    -Fvh: 如果装有老版本的,则升级;否则,则退出;
    --oldpackage:降级
7,rpm 卸载

    -e:若有依赖关系,则不允许卸载
8,rpm 校验

    rpm -V PKG_NAME -->检查文件在安装后是否被改动过
9,重建数据库

    rpm --rebuilddb:重建数据库(不管有没有都重建,一定会重新建立)
    rpm --initdb:初始化数据库(没有才建立,有就不重建)
10,检验来源合法性,及软件完整性

    加密类型:
          对称:加密解密使用同一个密钥
          公钥:一对密钥,公钥,私钥:公钥隐含于私钥中,可以提取出来,并公开出去;
              rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
              rpm -K PKG_NAME
              dsa,gpg:验证来源合法性,也即验证签名;--nosignature略过
              sha1,md5:验证包完整性;使用--nodigist略过
          单向:
11，在 rescue 模式下安装 rpm 软件包

    rpm --ivh --replacepkgs --root /mnt/sysimage bash-××××

## 软件包管理 yum 1
\#\# 2017-11-28 ##  
1,yum

    createrepo --> 创建元数据
    XML:eXtended mark language
    xml,json:半结构化的数据
2,yum 仓库中的元数据文件:

    primary.xml.gz 
        a,包含所有rpm包的列表
        b,依赖关系
        c,每个rpm生成的文件列表
    filelists.xml.gz
        a,当前仓库中所有rpm包的所有文件列表;
    other.xml.gz
        a,额外信息
    repomd.xml
        a,记录的是上面三个文件的时间戳和校验和
    comps*.xml.gz
        a,rpm包分组信息
            更改了镜像中的包后，此文件需要重新生成
3,*.repo 文件

    [Repo_ID]
    name=Description 
    baseurl=
        ftp://
        http://
        file:///
    enabled={1|0}
    gpgcheck={1|0}
    gpgkey=
       ftp://
       http://
       file:/// 
4,yum 命令

    list:列表
        all:所有(默认)
        available:可用的
        installed:已安装的
        updates:可用的升级
    clean:清理缓存
        all:
        packages:
        headers:
        metadata:
        dbcache:
    install:安装
        --nogpgcheck
        -y
    update:升级
    update-to:升级至指定版本
5,createrepo

    -g comps*.xml /path

## 软件包管理 yum 2
\#\# 2017-11-28 ##  
1,rpm 安装:

    二进制格式:
    源程序-->编译-->二进制格式
        有些特性是编译选定的,如果编译未选定此特性,将无法使用
        rpm包的版本会落后于源码包,甚至落后很多
2,rpm 包定制:手动编译安装

    前提:准备需要的环境编译环境,开发环境,开发库,开发工具
    安装:"development tools"和"Development libraries"
        C,C++:静态语言,linux上最流行的开发环境
        gcc:GNU C Complier,C
        g++:

    make:项目管理工具
        makefile:定义了make(gcc,g++)按照何种次序去编译这些源程序文件中的源程序
        automake --> makefile.in(半成品) --> makefile
        autoconf --> configure(100个可选择特性,用户自定义哪些加入)
3,编译安装的三个步骤:

    # tar
    # cd
    # ./configure
        --help
        --prefix=/path/to/somewhere
        --sysconfdir=/path/to/conffile_path
    # make
    # make install
    若指定了安装路径:
        1,修改PATH环境变量,以能够识别此程序的二进制文件路径;
            a,修改/etc/profile文件
            b,在/etc/profile.d/目录下建立一个以.sh为名称后缀的文件
        2,默认情况下,系统搜索库文件的路径/lib,/usr/lib;要增添额外搜寻路径;
            在/etc/ld.so.conf.d/中创建以.conf为后缀名的文件,而后把要增添的路径直接写至此文件中
            a,默认情况下需要重启才能生效
            b,可使用如下方式即时生效,ldconfig 通知系统重新搜寻库文件(-v显示重新搜寻库的过程)
        3,头文件(#include):输出给系统
            a,默认:/usr/include
            b,增添头文件搜寻路径,使用链接进行:
                ln -s /usr/local/tengine/include/* /usr/include/ 或者
                ln -s /usr/local/tengine/include /usr/include/tengine
        4,帮助文档路径:默认安装在--prefix指定的目录下的man目录
            a,man -M /PATH/TO/MAN_DIR COMMAND
            b,在/etc/man.config中添加一条MANPATH
            c,可直接在man后接上准备需要查看相关帮助的文件的绝对路径
                man /etc/passwd
4,netstat 命令

    -r:显示路由表
    -a:监听和不监听的端口都显示出来
    -n:不解析主机名
    -t:显示tcp连接
    -u:显示udp连接
    -l:显示监听状态的连接
    -p:显示监听指定的套接字的进程的进程号和服务名

## 磁盘管理 1   
\#\# 2017-11-30##  
1,机械式硬盘：U 盘，光盘，软盘，硬盘，磁带  
2,文件名字并不保存在该文件的 inode 中，而是保存在文件夹的 block 中  

    a,文件系统是内核中的功能，可以说是一个软件
3,文件的 inode 保存内容有：block 号，属组，属者，权限，大小，时间戳  
4,找文件的步骤：
> 内核找到根目录的保存块（自引用）--> 读取内容（权限） --> 找到根目录中名为var的目录对应的inode号 --> var目录inode号找到var目录保存块 --> 读取内容（权限） --> 找到var目录中名为log的目录对应的inode号 --> log目录中找到名为messages的文件的保存块 --> 读取内容 --> 核对权限 --> 读取文件  

5,目录中存储的内容为：文件名和对应的 inode 号码（dentry 目录项）  
6,块位图（bitmap）：用来标记硬盘中块是否被使用（0 和 1 来表示）  
7,inode 位图（bitmap）：用来标记 inode 是否被使用（0 和 1 来表示，所以 8 个标记才记录为 1 字节）  
8,在系统中创建文件/backup/test.txt（文件大小 10k，文件系统块大小为 2k）：

    a，扫描inode位图，分配一个空闲inode
    b，查看backup目录inode中权限情况，核查是否有权限增加文件
    c，修改backup目录保存块的内容，增加一行 --> test.txt与新分配inode号的条目
    d，扫描块位图，分配8（假设）个块（多余的两个块用于后续的文件增长，防止文件增长后，保存块不连续的情况）
9,在系统中删除文件/backup/test.txt（文件大小 10k，文件系统块大小为 2k）：

    a，找到文件保存目录所在的区块
    b，删除目录区块中test.txt与相应分配inode号的条目
    c，在inode位图中将文件的inode标记为未使用
    d，inode找到文件对应的区块，在块位图中将相应的块标记为未使用
10,复制文件与剪切文件（同一个分区）速度相差比较大，原因为复制文件相当于新建文件;剪切文件仅更改文件名  
11,文件系统情况：

    a，super block保存文件系统所有block group信息
    b，block group保存块位图，inode位图，inode，block信息
12,（特殊文件）指向同一个 inode 的不同路径，称为硬链接，信息保存在目录文件中;ls -l 第二列显示的数字为硬链接的个数  
13,（特殊文件）一个指向另一个的路径（保存的是路径字符串），称为软链接，文件大小由字符个数决定，

    软链接权限为777,完全不影响源文件的权限

## 磁盘管理 2   
\#\# 2017-11-30##
1,设备

    字符设备：按字符为单位，线性设备;
    块设备：按块为单位，随机访问的设备;
2,/dev（特殊文件）

    主设备号（major number）：标识设备类型
    次设备号（minor number）：同一种类型下的不同设备
3,创建设备文件（mknod）：连接入口，访问入口

    mknod OPTION NAME TYPE major minor
    -m：指定
4,格式化：

    a，低级格式化：创建磁道
    b，高级格式化：创建文件系统
5,文件系统：

    a，FAT32在linux下称为vfat
    b，vfs（同文件系统一样，也是内核的功能）：virtual filesystem --> linux下的虚拟文件系统，作用为提供统一的封装，
        使得同样的命令能够在不同的文件系统上使用（例子：mkfs）
        文件系统（软件）自己提供相应的调用（不同的文件系统，不同的调用;例如在ext2上是open1,在ext3可能就是open）
        为了使软件能够专用于核心功能的实现，vfs把一些基础的调用封装起来
    c，/var，/usr等单独分区，目录仍是存在于/目录下的，只是作为了一个入口，指向了第二分区。。。
    d，挂在用目录独立于挂载分区存在，/var目录挂载分区sda2,但/var目录只存在于sda1

## 磁盘管理 3   
\#\# 2017-11-30 ##  
1,用户模式：用户空间  
2,内核模式：内核空间  
3,文件在 linux 上存储，分为元数据和数据，元数据保存文件的属性，目录是完成文件路径的映射的  
4,cpu（intel，amd）分为四个环，内核在 ring0（特权指令）上运行，普通进程运行在 ring3（ring1,ring2 不使用，历史原因）  
5,文件系统上 block size：1024,2048,4096  
6,软链接，设备文件，管道文件，套接字文件其实都没有大小，占据的都是 inode 的空间  
7,超级块：用来存储文件系统中块组的信息，有多少个块组，块大小，已用块多少，可用块多少，空闲 inode，已用 inode  
8,一个块组能够有多少个块，取决于块的大小（块位图占用空间为 1 个块），一般一个块组的数量为一个块存储的位数（1×1024×8）;创建块组的原因为，在一个很大的文件系统上，就算有块位图，去寻找也会很麻烦，所以再切割，减小找寻时间  
9,块组描述符：用于存储 superblock 无法存储下的各块组信息，含有备份  
10,任何一个分区的第一个块不能被使用，名字为 boot block，在多引导的情况下需要被使用到  
11,mbr（master boot recoder 程序）不属于任何分区，是盘的第一个扇区（sector）  
12,分区的构成为：boot block + n 个 block group  
13,每个 block group 组成为 super-block+GDT+block-bitmap+inode-bitmap+inode-table+data-block  
14,每个 block group 均有一个 super block 太浪费空间，后更改为少量的备份，比如 1,5,7,当第一个损坏后，会自动寻找下一个  
15,GDT（group description table）块组描述符表，记录边界信息等  
16,占据块空间的文件主要是目录文件和普通文件  
17,ext3（日志文件系统）：相对于 ext2 文件系统来说，除去元数据和数据区，多出一个日志区（功能为在存储数据时突然断电，开机后能够直接发现文件所在位置，减少文件系统修复的时间），在存储文件时，inode 先放在日志区而不是在元数据区，存储完成后才被移到元数据区去;基于以上的情况，在写操作时 ext2 的速度会快过 ext3（很小）,读操作时无影响。  
18,位图索引，oracle 使用，备注

## 磁盘管理 4   
\#\# 2017-12-05 ##  
_rhel6与rhel5有差异，在执行命令时，先确认命令使用_

1,重新创建文件系统会损坏文件  
2,创建文件系统完成后，使用 cat /proc/partitions 用于查看是否已经被内核识别，若为识别，使用 partprobe 命令  
3,使用 cat /proc/filesystems 查看当前内核支持哪些操作系统  
4,mkfs 完成系统分区后，在输出的提示信息中能看到，系统会预留 5%的空间给超级用户，用于当系统空间使用完后，仍保留部分空间给 root 用户进行修复工作（这个可以调整） 
5,mkfs -t ext2 = mkfs.ext2;mkfs 为一个统一调用格式化命令的接口  
6,专门管理 ext 系列文件系统：mke2fs，直接创建文件系统;

    -j 创建ext3文件系统
    -b 创建指定块大小
    -L 指定分区卷标
    -m 指定预留给超级用户的块百分比
    -i 用于指定为多少字节的空间创建一个inode，默认为8192;给出的数值应为块大小的2××n倍
    -N 指定要创建的inode的个数
7,查询或查看磁盘设备的相关属性：blkid

    UUID
    TYPE
    LABEL
8,用于查看或定义卷标：e2label  
9,调整文件系统的相关属性：tune2fs

    -j 不损坏文件的情况下，将ext2升级为ext3
    -L 用于设定卷标
    -m 调整预留百分比
    -r 指定预留块数
    -o 设定默认挂载选项
    -c 指定挂载次数达到#后进行自检，0或-1表示关闭此功能
    -i 指定挂载多少天后进行自检，0或-1表示关闭此功能
    -l 查看super block中的信息
10,显示文件系统相关信息：dumpe2fs

    -h 仅显示super block中的信息
    dumpe2fs和tune2fs无法对包含在lvm中的设备进行查看，可以查看lv的
    可以显示详细的信息内容
11,检查并修复 linux 文件系统 fsck

    -t # 指定文件系统格式
    -a 自动进行修复，不需要交互的模式下进行
12,专门用于检查修复 ext2/3 文件系统：e2fsck

    -f 强制检查
    -p 自动修复
13,挂载：将新的文件系统关联至当前根文件系统

    卸载：将某文件系统取消与当前根文件系统的关联
    mount：设备 挂载点
         设备文件：
                 /dev/sd×
                 UUID：uuid=“”
                 LABEL：label=“”
         挂载点：
                 1,此目录未被其他进程使用
14,mount 使用

    -a 挂载/etc/fstab文件中定义的所有文件系统
    -n 默认情况下，mount命令每挂载一个设备，都会把挂载的设备信息保存至/etc/mtab文件中;使用-n选项意味着挂载设备时，
        不把信息写入该文件中
        mount -n 的效果类似于cat /proc/mounts
    -t 指定挂载的文件系统格式，省略时，mount会从blkid命令读取
    -o 指定额外的选项
        async 默认选项，异步写入，可提高读写性能
        atime 每访问一次文件，都将访问时间更新一下，繁忙的服务器不建议使用该选项
        _netdev 指若为网络共享设备，当开机时无网络，可跳过
        remount 重新挂载
        loop 挂载本地回环设备，光盘镜像
    --bind
    --move

## 磁盘管理 5   
\#\# 2017-12-05 ##  
_rhel6与rhel5有差异，在执行命令时，先确认命令使用_

1,page out：内存中数据移到 swap 空间中

    page in ：swap空间中的数据移到内存中
    swap out：对应page in
    swap in ：对应page out
2,buffer 与 cache：

    buffer缓冲--> 蓄水池，照顾吞吐量小/慢的设备;保存元数据--> 查找/var/log/messages，查找中用到的数据
    cache：缓存--> 保存数据，用于重复读取，加快读取性能;保存数据--> 块内保存的数据
3,fdisk 分区后，注意必须调整分区类型，不然错乱后，可能会导致后期管理的混乱  
4,swap：交换分区

    mount -t swap /dea/sda8
    swapon /dev/sda8
        -a 启用所有定义在/etc/fstab下的设备文件
    swapoff /dev/sda8
5,回环设备：loop

    使用软件来模拟实现硬件
6,复制和转换文件：dd

    if=数据来源
    of=数据存储文件
        dd if=/etc/inittab of=/root/inittab
    dd复制的为底层的数据流，底层的10...,直接操作的是底层的存储设备
    cp复制为文件复制，是基于操作系统之上才能使用的
    dd if=/dev/zero of=/tmp/swapfile bs=1M count=1024 seek=1023 创建的文件大小问1M，但在系统识别为1G，使用du能看占用的磁盘空间大小
    seek=# 表示创建文件时，跳过多大空间
7,/etc/fstab

    设备 挂载点 文件系统类型 挂载选项（默认为defaults） 转储频率（每多少次做一次完全备份） 文件系统检测顺序（只有根可以为1）
8,设备被占用而无法卸载时，可以使用 fuser -v 来查看被谁占用，命令是什么，进程号是多少  
9,fuser：验证进程正在使用的文件或套接字

    -v：显示占用
    -k：中止占用的进程
    -m：对挂载点和目录使用  fuser -mk /directory

## lvm管理 1   
\#\# 2017-12-05 ## 
_rhel6与rhel5有差异，在执行命令时，先确认命令使用_

1,MD，DM

    DM：device mapper将多个硬件设备映射为逻辑设备
        LVM2
        快照
        多路径
        可实现动态增减
2,LVM2：

    PE：physical extend;物理卷只有加入卷组之后才有PE
    LE：logical extend;
3,fdisk 可支持 15 个分区，不知道在 6 当中有没有提升 2

## lvm管理 2   
\#\# 2017-12-07 ##  
逻辑边界包含在物理边界内  
1,扩展逻辑卷

    lvextend -L [+]# /PATH/TO/LV
    resize2fs -p /PATH/TO/LV --> 能有多大就扩展到多大
2,缩减逻辑卷

    注意：
    a，缩减逻辑卷的风险很大，不要随便进行该操作
    b，不能在线缩减，请先卸载
    c，确保缩减后的空间大小依然能够存储原有的所有数据
    d，在缩减之前应该先强行检查文件系统，以确保文件系统处于一致状态;
    df -lh --> umount --> e2fsck -f --> resize2fs /PATH/TO/LV --> lvreduce -L [-]# /PATH/TO/LV
3,快照卷

    1,生命周期为整个数据时长：在这段时间内，数据的增长量不能超出快照卷大小;
    2,快照卷应该为只读
    3,快照卷必须与备份卷在同一个卷组中
    4，快照卷也是一个lv，注意，它可以被挂载
    5，生命周期结束，lvremove /PATH/TO/LV
    lvcreate -L 50M -n S_NAME -s -p r /PATH/TO/LV
    lvcreate
        -s：创建
        -p：r|w 权限，只读

## mdadm管理 1   
\#\# 2017-12-07 ##   
1,颜色设置：

    echo -e "\033[1;37;41mHello\033[0m world!"
    -e：启用脱意符
    \033：表示ctrl
    \033[31m：red
    \033[32m：绿色
    \033[33m：yellow
    \033[34m：blue
    [x,y,zm：x为1-9,表示为不同的显示方式，粗体、斜体等;yz为不同颜色的代号（y表示前景色,z表示背景色）
    [0m：表示显示结束
    read -p -e "\033[1;37;41mYour choice :\033[0m"
2,计算机的核心主件：

    a，cpu
    b，内存
    c，输入/出设备
3,设备接口转换，光电转换器，网卡等

    a，集成在主板上的叫做controller（控制器）
    b，需要外接进来的叫做adapter（适配器）
4,计算机中发出的 01 信号，指定在各不同位代表的含义，称之为协议

    a，双方都遵循的方式
5,IDE 和 SATA 接口（1MB=8Mb）

    IDE：133Mbps 理论值 并行
        a，一个IDE控制器上能够连接2个IDE盘
    SATA（1-3）：300Mbps，600Mbps，6Gbps 串行
        a，一个SATA控制器只能连一个SATA盘
    USB（1.0，2.0,3.0）：480Mbps（3.0）并行
    SCSI(small computer system filesystem)：ultrascsi 320Mbps 串行 --> 以前工业生产用，速度快，功能强大
        a，scsi基于IDE接口
        b，数据在scsi上传输存储时，也是以包的形式进行传输的
        外接的设备成为target;分为两种：
            窄带--> 8 --> 1 initiator，7 targets
            宽带--> 16 --> 1 initiator，15 targets
    SAS：更小
6,RAID

    a，级别：仅代表磁盘组织方式不同，没有上下之分
    b，raid1+0和raid0+1是不一样的概念，有先后之分;raid10好于raid01
        0：条带
            性能提升，读写性能都有提升;但不提供冗余功能，无法容错，空间利用率100%
        1：镜像mirror
            写性能下降，读性能提升;具有冗余能力，可以容错，空间利用率50%
        2：
        3：
        4：校验码（校验盘容易成为瓶颈）
        5：校验码（轮流做校验盘）
            读写都提升;具备冗余能力，空间利用率（n-1）/n
        10：
        01：
        50：先5后0
            空间利用率（n-2）/n;最少需要6块盘
    c，jbod：简单的将多个盘叠加成一个大的盘（适用于hadoop）
        性能提升无；冗余能力无；空间利用率100%

## mdadm管理 2   
\#\# 2017-12-07 ## 
硬件 RAID 和软件 RAID  
1,MD：multi disks  
2,逻辑 RAID（软件 RAID）

    a，制作了软RAID设备文件后，必须选择类型为fd，因为这个逻辑RAID依赖于系统;当系统损坏后，可能导致之前的数据不可使用; 标识为fd设备后，在保存数据后会写入一些元数据，以便在重装系统后加载模块直接使用
    b，软RAID不建议配置（生产环境），可能导致数据丢失，要考虑是否可以接受这个结果
    c，需要模块md
    d，mdadm：将任何块设备做成RAID
        模式化的命令：
        1,创建模式（-C）
            专用选项：
                -l：级别
                -n：设备个数
                -a：自动为其创建设备文件
                -c：chunk大小，2的n次方，默认为64K
                -x：指定空闲盘
        2,管理模式
            --add
            mdadm --manage /dev/md0 --fail /dev/sdb1
            mdadm --manage /dev/md0 --remove /dev/sdb1
        3,监控模式（-F）， 
        4,增长模式（-G），
        5,装配模式（-A）
        6,查看信息（-D）
3,创建 raid0：

    a，raid0需要使用的两个盘必须大小相同
    b，mdadm -C /dev/md0 -l 0 -n 2 /dev/sda{5,6}
4,创建 raid1：

    a，raid1需要使用两个盘的大小必须相同
5,mdadm --detail（-D） /dev/md1 查看 md1 的详细信息  
6,mdadm --stop（-S）/dev/md1 关闭使用  
7,mdadm -D --scan > /etc/mdadm.conf   

## linux 文件查找
\#\# 2017-12-11 ##  
1，locate

    a、非实时，模糊匹配，查找是根据全系统文件数据库进行的;
    b、手动生成文件数据库，updatedb（可能需要很长时间）;
    c、速度快;
2，find

    a、实时
    b、精确
    c、支持众多查找标准
    d、遍历指定目录中的所有文件完成查找，速度慢
    e、find 查找路径 查找标准 查找到以后的处理动作
        查找路径：默认为当前目录
        查找标准：默认为当前目录下的所有文件
        处理动作：默认为显示
3,find 匹配标准

    -name ‘filename’：对文件名做精确查找
        文件名通配：
            ×：任意长度任意字符
            ？
            []
    -iname ‘filename’：查找文件名不区分大小写
    -regex PATTERN：基于正则表达式进行文件名匹配
    -user USERNAME：根据文件名查找
    -group GROUPNAME：根据组名
    -uid UID：使用uid进行查找
    -nouser：查找没有属主的文件
    -nogroup：没有属组的文件
    -type
        f：普通文件 b，c，s，p
        d：目录文件
    -size
        [+|-]k，M，G：省略+|-为精确查找，+为大于，-为小于
        find -size 10M --> 显示的是9-10M之间的文件，
4,find 组合条件

    -a
        find -type d -a -nogroup
    -o
        find -type d -o -nogroup
    -not
        find -not -type d
        find -not -type d -a -type s
5,find 时间戳查找

    -mtime：修改时间
    -ctime：改变时间
    -atime：访问时间
        [+|-] #单位为天
    -amin：单位为分钟
    -cmin：单位为分钟
    -mmin：单位为分钟
        [+|-] #单位为分钟
6,find 使用权限来查找

    -perm：
        mode：必须精确匹配
        -mode：文件的权限完全包含该mode时才匹配
        /mode：9为权限位中只要一位匹配即可
7,find 动作：

    -print：显示（默认）
    -ls：类似ls -l的形式或显示每一个文件的详细情况
    -ok ls {} \;            --> 每一次操作都需要用户确认
    -exec chmod u-w {} \;   -->不需要用户确认
    eg：
        find ./ -perm -020 -exec mv {} {}.new \;只要引用文件的文件名，都需要使用{}。
        find / \( -nouser -o -nogroup \) -a -atime -1 -exec chown root:root {} \;
        find /etc/ -mtime -7 -a -not -user root
        find /etc/ -size +1M > /tmp/etc.largetfiles
        find /etc/ -size +1M -exec echo {} >> /tmp/etc.largefiles \;
        find /etc/ -size +1M | xargs echo {} >> /tmp/etc.largefiles
        find /etc/ -not \( -perm -002 -o -perm -020 -o -perm -200 \) -ls
        find /etc/ -not -perm -002 -a -not -perm -020 -a -not -perm -200 -ls
        find /etc/ -not -perm /222 -ls

## linux special permission
\#\# 2017-12-11 ##  
SUID：运行某程序时，相应进程的属主是程序文件自身的属主，而不是启动者;  

    chmod u+s FILE
        如果FILE本身原来就有执行权限，则SUID显示为s;否则显示为S
SGID：运行某程序时，相应进程的属组是程序文件自身的属主，而不是启动者;

    chmod g+s DIRECTORY
        在文件夹下面创建文件，文件的属组将继承文件夹的属组
Sticky：在一个公共的目录中，每个都可以创建文件，删除自己的文件，但不能删除别人的文件

    chmod o+t DIR
    chmod o-t DIR
umask 0002：第一位对应的是特殊权限位

## linux facl permission
\#\# 2017-12-12 ##  
1,FACL-->filesystem access control list

    利用文件的扩展保存额外的访问控制权限
2,setfacl：

    -m：设定
       [d]： u：UID：perm [设置默认]
       [d]： g：GID：perm [设置默认]
    -x：取消
        u：UID
        g：GID
    文件权限顺序：
        Owner-->Group-->Other
        Owner-->facl，user-->Group-->facl，group-->Other
3,ls -l 显示文件最后具有+

    归档具有facl属性的文件，很可能文件facl属性被取消，未被归档进去;需要使用特定的命令和选项才行

## linux terminal   
\#\# 2017-12-12 ##  
1,whoami  
2,终端类型：

    console：控制台-->直接连到设备的硬件
    pty：物理终端（VGA显卡）
    tty#：虚拟终端（VGA显卡）
    ttyS#：串行终端
    pts/#:伪终端（伪文件系统）
3,su 过去的用户不是登录用户，虽然有效用户是期望用户（whoami 有效用户/who 登录用户）的差别

    w：显示哪些用户登录并且正在执行的命令是什么
    who：显示哪些用户登录
    whoami：显示当前有效用户是哪个
4,显示过去登录情况信息

    last：显示/var/log/wtmp显示系统的用户登录历史和重启历史
        last -n 显示近期几次的信息
    lastb：显示/var/log/btmp显示系统上错误的登录尝试信息last（b：bad）
        lastb -n 显示近期几次失败登录信息
    lastlog：显示每一个用户的最近一次的登录信息
        lastlog -u username显示特定用户最近的登录信息
    basename：直接获取一个文件或路径的基名
        $0：执行脚本是的脚本路径及名称
    mail：邮件使用
        -s：指定主题
        cat /etc/fstab | mail -s ‘How are you？’ root
    hostname：显示当前主机的主机名
        $HOSTNAME：系统环境下的主机名变量
    $RANDOM：保存0-32768之间的随机数
5,随机数生成器：熵池（要用到的时候就被那走了，不是复制），大量的加密软件需要用到该随机数

    /dev/urandom（软件模拟）:可能被攻破，但数量可大量获取
    /dev/random（cpu中断，敲键盘间隔时间获取）:安全系数高，但量少，可能导致进程堵塞

## linux sed   
\#\# 2017-12-16 ##  
1、linux 下需要掌握的三大文本处理器：grep、sed、awk

    sed：流编辑器
    awk：报告文本生成器
2、sed 的基本用法（string editor）：只用于处理纯 askii 文本

    a、逐行处理（行编辑器）：每次读取一行到内存当中，在内存中处理，而后将模式空间打印至屏幕
    b、在内存中占用的空间称之为模式空间
    c、默认情况下，sed仅处理模式空间中复制的文本，不更改源文件
    d、命令格式：
        sed ‘AddressCommand’ file ... address和command之间不需要空格间隔
            -n：静默模式，不再默认显示模式空间中的内容
            -i：直接修改源文件
            -e SCRIPT -e SCRIPT：可以同时使用多个脚本
            -f /PATH/TO/SCRIPT：读取sed脚本文件
                sed -f /path/to/script file
            -r：表示使用扩展正则表达式（未加该参数，默认使用基本正则表达式）
            Address：
                1、StartLine，Endline --> 1,100
                    $:最后一行
                    $-1：倒数第二行
                2、/RegExp/做模式匹配，内部有特殊字符时，需要转意 --> /^root/
                3、/pattern1/,/pattern2/ --> 第一次被pattern1匹配到的行开始，到第一次被pattern2匹配到的行结束
                    这中间的所有行
                4、LineNumber
                    指定的行
                5、StartLine,+N
                    从StartLine开始，往后的N行
            Command：
                p：打印符合条件的行（默认），使用该命令时，会将匹配的内容打印两次（结合sed默认行为）
                    sed '1,+2p' /etc/fstab
                d：删除符合条件的行
                    sed '1,$d' /etc/fstab
                    sed -i '/pattern to match/d' ./infile
                    sed -i '/^abc/,+4d' ./xxxfile
                    # To directly modify the file (and create a backup):
                    sed -i.bak '/pattern to match/d' ./infile
                a \string：在指定的行后面追加新行，内容为“string”
                    sed '/^\//a \#hello world \n #hello linux' /etc/fstab
                i \string：在指定的行前面追加新行，内容为“string”
                    sed '/^\//i \Hello.....' /etc/fstab
                r FILE：将制定的文件的内容添加至符合条件的行处
                    sed ’$r /etc/issue' /etc/fstab
                    sed ’1,2r /etc/issue' /etc/fstab
                w FILE：将地址指定范围内的内容另存至指定的文件中
                    sed ’/oot/w /tmp/oot.file‘ /etc/fstab
                s/pattern/string/:pattern可以使用正则表达式，string不能(/可以替换成其他的符号）
                    sed ‘s/oot/OOT/’ /etc/fstab
                    sed ‘s/^\//#/' /etc/fstab（默认替换每行中第一次被模式匹配到的字符串）
                    sed ‘s/^\//#/g' /etc/fstab
                        加修饰符：
                            g：全局
                            i：忽略大小写
                后向引用：\(\),\1,\2,..
                    sed ’#\(l..e\)#\1r#g' sed.txt --> like替换成liker
                &：引用模式匹配到的内容
                    sed ‘s#l..e#&r#g' sed.txt --> like替换成liker
                有些时候只能使用后向引用而不能使用&符号，当要替换匹配内容中的内容时
                    sed ‘s#l\(..e\)#L\1#g’ /etc/fstab

## linux 归档   
\#\# 2017-12-16 ##  
1,linux 下常用的压缩格式：gz，bz2,xz，gzip，Z  
2,压缩的方式，使用替换的方式进行，abcd-->将 a 替换成 1,后续全部采用该方式

    算法不同，压缩比也不相同
3,gzip：.gz

    gzip /path/to/somefile：压缩完成后会删除源文件
    gzip -d /path/to/somefile：解压缩
    gzip -#：1-9，指定压缩比，默认为6;
    gunzip：解压缩，解压完成后删除源文件
4,zcat：在不解压的情况下查看文本文件内容，zcat /path/to/somefile  
5,bzip2：.bz2 比 gzip 有着更大的压缩比，使用格式近似

    bzip2 /path/to/somefile
    -k：压缩时保留源文件
    bunzip2 /path/to/somefile
    ...
    ...
    bzcat：不解压的情况下查看文本文件内容
6,xz：.xz 压缩比更大

    xz /path/to/somefile
    -k：压缩时保留源文件
    unxz /path/to/somefile
    xzcat：不解压的情况下查看文本文件内容
    默认这些压缩软件压缩完文件会删除源文件
7,zip：大多数系统默认支持的工具，既归档又压缩的工具

    zip FILENAME.zip FILE1 FILE2 ...
    默认保存源文件
    unzip filename.zip
8,tar：归档工具，只归档不压缩

    -c：常见归档文件
    -f FILENAME.tar：操作的归档文件
    -x：还原归档，归档文件不动
    --xattrs：zai归档时保留文件的扩展文件属性
    -t：不展开归档，直接查看归档了哪些文件
    -zcf：调用gzip归档并压缩
    -zxf：调用gzip解压缩（-z可省略，下同）
    -jcf：调用bzip归档并压缩
    -jxf：调用bzip归解压缩
    -Jcf：调用xz归档并压缩
9,cpio：归档工具（比较特殊，在/boot/×.img 文件需要使用）  
10,脚本编程结构：

    a、顺序
    b、循环
        for
        while
        until
    c、选择
        if
        case

## linux network 1
\#\# 2017-12-21 ##  
1、电磁信号  
2、协议  
3、网卡速度需要转换  
4、计算机通信模型：线路、网卡、数据流大小  
5、常用网络模型：

    a、总线网络：需要用到线路仲裁，防止通信冲突，一根总线，各台机单独连接上这根线
        批注 -- 总线网络基础推出网桥，相当于是网桥上的每两个口互连时只有这两台机占用‘总线’
    b、环状网络：主机以环形的方式连接成网络，令牌在哪台机上主机才能发送信号（IBM专利）
    c、星型网络：需要有集线器（HUB），可以理解为变形的总线，线变成了一个设备
6、MAC：media access control（MAC 地址）  
7、单播与多播：

    多播：一对多的形式
    单播：一对一的形式
8、CSMA/CD：carrier sense multipath access collision detection（载波侦听，多路访问，冲突检测）
    具有该特征的称为以太网，以太网的标志; Ethernet --> 以太网
9、信号的传输受线路的长度影响，若太长，电阻会减弱信号。此时需要中继器来增强信号，将信号放大之后再传输。  
10、当总线网络大到一定程度后，需要拆分为多个小的总线网络。当分属于两个不同总线网络的主机需要通信时，需要借助网桥来进行通信。  
11、网桥内部存有一个网络和主机对应的信息表，因此在数据传输时，能够正常不出错

    a、网桥极端，就是一台主机一个总线网络，两台主机之间发信号，不影响其他主机之间的通信
        1、半双工，A给B发信号的时候，B不能给A发;同轴线 --> 对讲机
        2、全双工，可以同时互相之间发信号;双绞线 --> 电话
    b、变成了交换机，只能的体现在内部的信息表
    c、任何一台主机在实现通信之前，新来的成员，让大家认识，都要喊一嗓子，广播寻人
    d、交换机（网桥）并不能隔离广播，在主机发出广播之后，交换机必须转发广播;隔离的是冲突，冲突域的概念
    e、当一个交换机上连接的主机数很多，因为通信需要广播，会导致很多的问题，所以此时需要再次细分网络
    f、细分网络后，交换机与交换机之间增加一个设备，称之为网关设备，
    g、源ＭＡＣ为自己的ＭＡＣ地址，目标ＭＡＣ则是ｆｆｆｆｆｆｆｆ，交换机（网桥）无条件转发

    总线网络(一条总线接多台设备) --> 多个总线网络(网桥连接多个小的总线网络) --> 多个总线网络(一条总线一台设备,全双工,互传不影响) --> 交换机

12、以上所讲均为平面地址（物理地址，基于 MAC 地址）;交换机之间通信引入另一个地址（逻辑地址，基于 IP 地址）

    a、MAC地址的工作机制就是基于广播的
    b、交换机接收到报文之后不做任何处理，直接转发出去
    c、网管设备在接收到报文之后，需要先处理
    d、网络传输包的形式：
       1.1 | 2.1 -> 1.1 | 2.1 | A | R1 -> 1.1 | 2.1 -> 1.1 | 2.1 | R2 | M
       1.1 | 2.1的作用是在网络之间传输数据包
    ｅ、网关设备连接交换网络
13、网络类型

    a、环型网络中，环状网路中有一个token，在没有传输时，令牌游走在环状网路中，当有机器需要传输时，拿到令牌开始发送
    b、星型网络中，居中的设备是一个HUB，在整体结构上来说，仍属与总线型网络
14、网络的进化

    总线网络 -- 集线器连接网络（星型网络） -- 网桥连接网络 -- 网桥（交换机VLAN）连接网络
    a、总线用于联通，只满足各pc之间可以通信的功能
    b、星型网络，仍只是满足各pc之间通信的功能，只是网线变成了一个设备
    c、为了隔离冲突域，出现了网桥，可以将网络细分，减少每个总线网络中的主机数;当到达极致时，就是一台主机一个总线网络
    d、当网桥上连接的总线网络过多时，因不能隔离广播，会导致各种问题;此时就出现了VLAN的概念（可隔离广播）
15、几种设备的差别

    a、集线器：创建一个冲突域和广播域
    b、网桥：网桥分割冲突域，但只形成一个大型广播域，使用硬件地址来过滤网络
    c、交换机：交换机是一个更智能的多端口网桥，可以分割冲突域，淡漠人创建一个大型广播域，交换机使用硬件地址来过滤网络
    d、路由器：路由器分割冲突域和广播域，并使用逻辑地址过滤网络;路由器执行分组交换、过滤和路径选择，帮助完成互联网通信
        - 冲突域: 是一个以太网术语,指的是这样一种网络情形 -> 某台设备在网络上发送分组时,当前网段中的所有其他设备都必须注意到这一点
        - 广播域: 同一网段中所有设备的集合,这些设备侦听该网段中发送的所还有广播

## linux network 2
\#\# 2017-12-23 ##  
1、当增加了网关设备之后，有了逻辑地址，同一个交换网络之间的通信也通过逻辑地址来进行  
2、最底层的通信仍然是依赖于 MAC 地址通信，此时引入一个概念，ip 地址和 MAC 地址之间的转换，ARP 协议，地址转换协议  
5、路由器隔离广播  
3、总线网络下，最多只能有一路信号发送，不然会发生冲突  
4、网桥可以理解为就是两个口的交换机  
5、路由器隔离广播  
6、IP 和端口绑定起来，称之为 socket（套接字）IP：port  
7、协议分层（OSI 模型）  
8、各种设备的差别：

    总线：一条网线，一次只允许单台机单向通信
    集线器：多个网线接口，可以连接多条网线，每次只能允许两个接口直接的单向通信;可理解为变形的总线，线变成了一个设备
    简单交换机：可理解为复杂化的集线器，多个网线接口，可以连接多条网线，但可允许同时多个接口对（两两之间）互相通信
    网桥：隔离冲突域的作用，主要是用来联通各个网段
    路由器：
9、分辨一台设备工作是在 OSI 模型的第二层还是第三层，最主要的区别的是看是否具有路由选择功能。  
10、网桥工作在 OSI 模型的第二层：数据链路层，因为网桥不具备路由选择功能。  
11、面向连接的网络服务和无连接网络服务

    a、面向连接的网络服务使用确认和流量控制来建立可靠的会话;相较无连接服务而言，开销更高
    b、无连接服务用于发送无需进行确认和流量控制的数据，但不可靠
12、OSI（Open system interconnection 开放系统互联）七层模型

    a、应用层、表示层和会话层属于上层，负责用户界面和应用程序之间的通信
    b、传输层提供分段、排序和虚电路（三次握手建立的东西之类的）
    c、网络层提供逻辑网络编址以及在互联网络中路由的功能
    d、数据链路层提供了将数据封装成帧并将其放到网络介质上的功能
    e、物理层负责将收到的0和1编码成数字信号，以便在网段中传输

## bash scripts 3
\#\# 2018-01-16 ##  
1、执行结果不是执行状态结果，这个要搞清楚  
2、shell 中怎样进行运算

    A=3;B=6
    a、let加上算数表达式
           let C=$A+$B
    b、$[算数表达式]
           $[$A+$B]
    c、$((算数运算表达式))
           $(($A+$B))
    d、expr 算数运算表达式：表达式中各操作数及运算符之间要有空格，而且要使用命令引用
           D=$(expr $A + $B)
    e、圆整，丢弃小数点后数字
3、脚本中分区块判断是否需要执行下去，如果达不到条件，则没有必要继续执行下去，浪费系统资源

    如果系统中没有某个用户，则不需要在后续继续做基于该用户名字的判断和操作

## bash scripts 4
\#\# 2018-01-16 ##  
1、exit

    退出脚本，返回脚本执行结果状态值，可自定义;如果没有明确定义退出状态码，那么最后一条命令的退出码即为脚本的退出码

2、学习完成后，需要单独整理完成，成为一篇单独的博客  
3、bash 中常用的条件判断有三种

    整数测试：这种情况做对比，需要使用中括号
        -gt
        -lt
        -le
        -ge
        -ne
        -eq
    文件测试：
        -e FILE：是否存在，单目操作
        -f FILE：测试文件是否为普通文件
        -d FILE：测试指定路径是否为目录
        -r/w/x FILE：测试当前用户对指定文件是否具有r/w/x权限
4、测试方法：

    [ expression ]      -->命令测试法，[为命令
    [[ expression ]]    -->关键字测试法，[[为关键字
    test expression     -->test命令测试
5、bash 相关参数

    bash -n scripts：不能作为依据，模糊参考作用
    bash -x scripts：单步执行，可用来做测试，检验脚本中的错误
6、bash 变量的类型：

    本地变量（局部变量） a=1这种方式定义
    环境变量（当前shell进程及其子进程） export a=1这种方式定义
    位置变量：
        $1,$2 ...
        shift:位置参数的更改，执行一次shift（不加数字），位置参数向左移一个
    特殊变量：
        $?:
        $#:参数的个数
        $*:参数列表
        $@:参数列表

## bash scripts 5 
\#\# 2018-01-18 ##  
1、字符测试：

    ==：测试是否相等，在[[]],[]中使用时，=两端需要有空格，否则变成了赋值运算
    ！=：测试是否不等，不等为真，相等为假
    >
    <
    -n string：测试指定字符串是否为空，空则真，不空则假
    -s string：测试指定字符串是否为空，空则假，不空则真
2、bc 的使用

    脚本中可以使用两种方式传递参数给bc
        bc <<< ‘xxxxx;xxxx’
        echo “scale=2；222/333” | bc
3、循环：进入条件、退出条件

    for巡检
        seq [start [length]] last
        declare声明：
            -i：声明为整数
            -x：将一个变量声明为环境变量
    while循环
    until循环

## bash 进程管理 1
\#\# 2018-01-22 ##  
1、内存：

    线性内存：
        32bit：
        进程开始即给自己分配4G大小的空间，1G留给内核，剩余均认为属于自己
    物理内存
2、接口

    内核空间：涉及到敏感信息均由内核空间进行
        内核需要记录追踪每一个进程的运行状态信息，明确知道当前系统运行多少个进程
    用户空间
3、内核数据结构（task structure）

    保存在内核当中，用于记录追踪进程状态信息（每一个进程都有）;进程执行到一半（mkdir为例），交接了，执行完交接、
      任务后重新开始、依赖于此（可类比于主持人控制流程，不同人上台表演）
        PPID：
        PID：
        name：
        ...
        哪里停止，哪里重新开始
4、MMU（memory management unit）内存管理单元：

    进程的页面数据对应到物理内存（页框）的位置，每一次转换都是由MMU负责完成
5、进程上下文切换（context switch）

    VSZ（virtual size）虚拟内存集
    RSS（resident size）常驻内存集
6、cpu 多核也不能同时执行指令，而是在每一个 cpu 核心排队的队列减少

    多线程CPU（mysql多个用户同时发出请求为例）
        一个进程下面分为多个线程
7、线程及进程的区别

    线程的优势：还是以mysql为例，三个线程可以共用打开的文件，三个进程则在内存中需要打开文件三次，占用三倍空间
    线程的劣势：多个线程在共用一个文件，一个线程在写文件，该文件则被锁，其余线程需要等待释放，cpu不断检查浪费资源
8、进程状态

    uninterruptable sleep：不可中断睡眠，需要调用的外部资源仍然未得到满足，进程等待内存加载I/O设备中的数据，进入到、
        睡眠状态，防止资源浪费
    interruptable sleep：可中断睡眠，standby状态，当有外部请求进来时进入到活跃状态
        判断差别主要看是否调用外部I/O来进行
    zombie：僵尸进程，进程结束了，但是内存中占用的空间无法释放
        进程包含父子关系，子进程结束由父进程回收资源

## bash 进程管理 2
\#\# 2018-01-23 ##  
1、进程有优先级概念：

    linux中有0-139共140个优先级，数字越小，优先级越高
        100-139用户可控制
        0-99仅由内核进行控制
   进程的分类：

        跟终端相关的进程
        跟终端无关的进程
2、O 标准：队列长度变长，选取优先执行进程的时间（时间，队列长度）

    O（1）：一条平行于Y轴的直线
    O（n）：一条斜线，线性变化
    O（logn）：logn曲线
    O（2^n）：2^n曲线
3、优先级更高：

    a、获得更多的CPU运行时间
    b、更优先获得运行的机会
    nice值（-20——19）--> （100——139）
    普通用户仅能调大自己进程的nice值
4、每一个进程的 pid 号是唯一的，可能已经退出，但不会被其他新建进程占用

    每个进程所有的信息保存在/proc目录下以pid号命名的文件夹中
        目录下的文件为内核信息的映射，proc为伪文件系统，参数被映射成为名字
5、相关命令

    ps（process state）：进程状态
        linux分为两个版本--> system V风格 （命令需要－）&&　ＢＳＤ风格（不能有－）
    ａ：显示所有跟终端有关的进程
    ｕ：显示进程的用户相关信息
    ｘ：显示所有与终端无关的进程
    -e：显示所有进程
    -F：显示更详细的信息
    -l：长格式
    -o：自己组合输出内容
    aux，-elF，-ef，-eF几种组合

     ps aux显示的内容当中
        TIME：显示的是该进程实际占用CPU的时长
        COMMAND：包含有[]表示为内核线程
        进程状态：
            Ｄ：不可中断的睡眠
            Ｒ：运行或停止
            Ｓ：可中断的睡眠
            Ｔ：停止
            Ｚ：僵死态

            ＜：高优先级进程
            Ｎ：低优先级进程
            ＋：前台进程组中的进程
            ｌ：多线程进程
            ｓ：会话进程首进程
     pstree：显示进程树
     pgrep：仅显示特定进程的进程号
        -u（euid）：指定是哪个用户的进程
        -U：指定哪个用户的进程
     pidof：根据程序名查找进程号
     top：实时显示系统上运行的进程状态
        c：显示详细的进程命令
        -b：批处理模式，分屏列出所有进程信息
        -n：在批模式下，指定显示几批
        -d：指定刷新时长
6、进程间通信（IPC：inter process communication）

    共享内存：
    信号（signal）：
        重要的信号：
            1：sighup --> 让一个进程不用重启，就可以重读其配置文件，并让新的配置文件生效
            2：sigint --> ctrl+c 中止
            9：sigkill --> 杀掉一个正在进行的进程（直接杀死，不留时间）
            15：sigterm --> 终止一个正在进行的进程（提前通知，有反应时间）--> 默认信号
        指定一个信号：
            信号号码：kill -1
            信号名称：kill -SIGKILL
            信号名称简写：kill -KILL
    semaphore：旗语
7、终止进程

    kill PID：指定pid号
    killall command：指定command
8、调整 nice 值

    调整已经启动的进程的nice值：renice NI PID
    启动时指定进程的nice值：nice -n NI COMMAND
9、前端后端 bg、fg

    前台：占据了命令提示符
    后台：启动之后，释放了命令提示符，后续的操作在后台完成
    前台--> 后台：
        ctrl+z：把正在前台的作业送往后台运行，默认发送STOP信号
        command &：让命令在后台运行
    bg：让后台停止的作业继续运行
        bg [[%]JOBID]
    jobs：查看后台的所有作业
        作业号，不同于进程号
         +：命令将默认操作的作业
         -：命令将默认操作的第二个作业
    fg：将后台的作业调回前台
        fg [[%]JOBID]
    kill %JOBID：终止某作业
10、vmstat（系统状态查看命令）

    r：运行队列长度
    b：阻塞队列长度
    buff：缓冲
    cache：缓存
    si：换进
    so：换出
    bi：读入
    bo：写出
    in：interrupt
    cs：context switch（上下文切换，进程数据切换次数）
11、/proc/meminfo

    查看memory相关信息
    cat /proc/meminfo
    查看进程相关内存使用
    cat /proc/pid/maps

## bash boot process 1 
\#\# 2018-01-23 ##  
1、启动流程

    POST--> BIOS（boot sequence按照指定的启动顺序执行）--> MBR（bootloader，446字节）（grub stage1）
        --> grub stage2 --> kernel --> initrd --> init
        a、加载mbr的同时加载了kernel和initrd，kernel使用initrd生成ROOTFS
        b、init：
2、root 文件系统 rootfs

    所有的挂载根源为/
3、内核设计风格：

    单内核：linux（LWP：light weight process）
        核心：ko（kernel object）
            RedHat，SUSE，Debian：
                1、动态加载，内核模块
                2、内核：/lib/modules/“内核版本号命名的目录”/
                3、!$/kernel/*
                    arch：平台相关
                    crypto：加密相关
                    drivers：驱动相关
                    fs：文件系统相关
                    kernel：内核其他相关的功能
                    lib：库文件
                    mm：内存管理
                    net：网络相关
                    sound：声卡 
    微内核：windows，solaris（实现真正的多线程）
4、initramfs 用于过渡的虚拟文件系统

    在系统安装程序即将完成系统安装时，自动判断需要加载哪些模块才能让内核识别到文件系统，从而打包生成过渡文件系统\
        加载了initramfs文件，其下包含有/sbin，/bin等目录
5、chroot 命令，用户切换之独立的目录下，并以该目录作为根目录运行系统

    chroot /PATH/TO/TEMPROOT [COMMAND...]
    ldd /PATH/TO/BINARY_FILE 显示二进制文件依赖的共享库文件
    测试：
        a、mkdir /virroot/bin;mkdir /virroot/lib
        b、cp /bin/bash /virroot/bin;
        c、ldd /bin/bash
        d、cp 上一步找出的依赖库文件，复制至相应目录
        e、chroot /virroot可以切换，但仅可使用内置命令
    initramfs切换机制同上，但不是使用chroot命令;完完全全的切换，但会搬移三个文件夹，在initramfs阶段已经映射好，没有
      必要再次映射
        /proc
        /sys
        /dev
6、initramfs 为一个文件，可以将物理内存当中的一部分模拟成硬盘来使用

    rhel5：ramdisk --> initrd
    rhel6：ramfs --> initramfs
    内核访问根一般需要两个模块：
        识别磁盘的模块
        识别根目录文件系统的模块
7、启动过程详解

    bootloader（MBR) --> 硬盘级别的程序
        lilo：linux loader
        grub：grand unified bootloader;
            rhel5和rhel6使用的grub版本不一样
            grub本身是一个程序，需要装在MBR的bootloader（446字节）当中，用来引导操作系统;grub分为两段，是一个两阶段的程序

            stage1：装在MBR当中，主要作用是用来引导第二阶段
                stage1.5：用来帮助识别不同的文件系统的
            stage2：/boot/grub/; 主要作用是用来引导操作系统

    /etc/grub.conf 文件是一个链接，链接到/boot/grub/grub.conf
    grub.conf:
        全局配置：
        default=×：设定默认启动的title编号，从0开始
        timeout=×：等待用户选择的超时世间，单位为秒
        splashimage=（hd0,0）/grub/xxxx：grub的背景图片
        hiddenmenu：隐藏菜单
        password：后接字符串（明文密码），后接--md5 字符串（加密密码）
            使用命令grub-md5-crypt得到密码的加密输出，填入上面的md5后即可

        单独的系统设置：
        title 后版本号 -->内核版本，或操作系统名称，纯字符串，可自由更改
        root（hd0,0）：内核文件所在的设备;对grub而言，所有类型的硬盘一律识别为hd×，最后的0表示对应磁盘的分区，，隔开
        kernel /vmlinux××××××：内核文件路径，及传递给内核的参数
        initrd /initrd-×××：ramdisk文件路径

        所有的内容都可以单独更改，重启后生效;image需要注意的是，格式为xpm，像素为14,需要使用gzip压缩

    boot单独分区和boot不单独分区，在系统引导时访问的路径不一样
        单独分区时，/vmlinuzxxx
        不单独分区时，/boot/vmlinuz
    文件系统的结构数据是放在磁盘上的
    虚拟机重启时（vcenter上），不要按重启按钮直接重启，可能导致文件丢失，要这样做的时候，先执行sync命令
    看一下马哥的博客

## bash boot process 2
\#\# 2018-01-31 ##  
1、grub 界面的使用

    e edit
        进入到内核行，空格后输入1、s、S、single都可进入到单用户模式
        password字段可以放在顶部全局配置，也可以放在某个title下，用作启动内核输入密码（输入密码才能启动系统）
    c command
    b boot
2、查看当前系统运行级别

    runlevel
    who -r
3、安装 grub stage1，要判断是哪块磁盘

    第一种方式：
        a、命令行界面下输入grub，进入grub命令行界面
        b、指定root位置;
            grub> root （hd0,0）无报错内容
        c、直接键入setup （hd0,0），在正确的分区上重新生成grub
            grub> setup （hd0,0）
        d、执行成功
    第二种方式：
        grub-install --root-directory=/path/to/boot‘s parent directory/ /PATH/TO/DEVICE
            确保内核所在分区挂载在root目录下0
4、在删除了 grub.conf 的系统上怎样手动引导进入操作系统

    a、启动操作系统后会进入到grub界面
        grub>
    b、键入各个root组合，判断是否可用
        grub> root （hd0,0）
    c、查找vmlinux和initrd文件的具体路径和名字，可以在grub界面下使用find命令
        grub> find （hd0,0）/
        输出结果中会将该分区下的文件显示出来
    d、输入kernel行内容
        grub> kernel /vmlinuzxxx tab建可以补全
    e、键入initrd行内容
        grub> initrd /initramfsxx tab键可以补全
    f、键入boot进入系统
        grub> boot
5、kernel 初始化的过程

    a、设备探测
    b、驱动初始化（可能会从initrd（initramfs）文件中装载驱动模块）
    c、以只读方式挂载根文件系统 --> 出于安全考虑，防止启动过程bug导致根文件系统崩溃，后续init进程会重新以读写方式挂载
    d、装载第一个进程init（PID：1）
6、/sbin/init：（/etc/inittab）

    过往较早的unix init启动速度很慢
    由ubuntu开发的upstart可以并行启动，速度变快很多，基于D-bus来完成各进程间的通信，event-driven，rhel6中使用
    systemd：完整意义上并行启动多个进程的方式，rhel7中使用
    以下为rhel5中的机制，inittab：
    id：runlevels：action：process
        id：标识符
        runlevels：在哪个运行级别运行此行
        action：在什么情况下执行此行
            initdefault：设定默认运行级别
            sysinit：系统初始化
            wait：等待级别切换至此级别时完成
            respawn：一旦程序终止，进程重新启动，登录错误（用户，密码错误） --> 在登录界面的时候使用，用于控制终端的××××
        process：要运行的程序
7、/etc/rc.d/rc.sysinit 完成的任务有哪些

    a、激活udev和selinux
    b、根据/etc/sysctl.conf来设定内核参数
    c、设定系统时钟
    d、装载键盘映射
    e、启用交换分区
    f、设置主机名
    g、根文件系统检测，并以读写方式重新挂载
    h、激活软raid和LVM设备
    i、启用磁盘配额（quota）
    j、根据/etc/fstab，检查并挂载其他文件系统
    k、清理过期的锁和PID文件
8、rhel5 中/etc/inittab 文件

    l0：0：wait：/etc/rc.d/rc 0
    l1：0：wait：/etc/rc.d/rc 1
    l2：0：wait：/etc/rc.d/rc 2
    ...
    一行的意思为，等待进入系统后，执行/etc/rc×.d/下K×，S×的文件（使用脚本判断出来的）
9、/etc/init.d/ /etc/rc.d/init.d/是同一个位置，前一个是后一个的链接  

## bash boot sysv scripts 
\#\# 2018-02-01 ##  
1、由/etc/rc.d/rc.sysinit 脚本完成系统的初始化  
2、/etc/rc.d/init.d/目录下的脚本称为服务类脚本，符合 sysV 风格

    每个脚本至少要接受四个参数
        主要的：start|stop|restart|status
        选用的：reload|configtest
3、在 init.d 目录下的脚本都必须包含以下的内容：

    # chkconfig：runlevels SS KK
        a、当chkconfig命令来为此脚本在rc×.d目录创建链接时，runlevels表示默认创建为S×开口的链接，除此之外的级别默认创建
            为K*开头的链接;-表示没有级别默认为S*开头的链接。
        b、S后面的启动优先级为SS所表示的数字;
        c、K后面关闭优先次序为KK所表示的数字;
        d、一般而言，先开启的后关闭，后开启的先关闭，考虑的是程序之间的依赖关系
    # description：××××
        a、用于说明次脚本的简单功能;当描述较长时，使用’\‘续行
4、一般情况下，当一个程序运行起来后，会在/var/lock/[subsys/]目录下创建一个.lock 结尾的文件，锁文件  
5、chkconfig 

    --list --> 查看所有独立守护服务的启动设定;独立守护进程;
    --add SERVICE_NAME --> 将某个服务加入到chkconfig管理
    --del SERVICE_NAME --> 删除，服务不由chkconfig管理
    [--level RUNLEVELS] SERVICE_NAME {on|off} --> 特定级别的启动和关闭，如果省略了runlevels，默认指定为2345
    将自定义的服务类脚本加入到chkconfig管理的步骤：
        a、编写好服务启动类脚本（确保包含chkconfig和description这两行内容）
        b、将脚本放到/etc/init.d/目录下
        c、chkconfig --add SERVICE_NAME
        d、chkconfig --list SERVICE_NAME即可发现，在相应的rc×.d目录下已经生成了K*，S*链接了
6、/etc/rc.d/rc.local：系统最后启动的一个服务，准确说，应该执行的一个脚本

    a、默认在rc×.d目录下会有一个S99local（系统服务器最后启动）的链接，指向/etc/rc.local
        /etc/rc.local --> /etc/rc.d/rc.local
7、/etc/inittab 的任务（rhel5）：

    a、设定默认运行级别
    b、运行系统初始化脚本
    c、运行指定运行级别对应目录下的脚本
    d、设定ctrl+alt+del组合键的操作
    e、定义UPS在电源故障/恢复时执行的操作;
    f、启动虚拟终端（2345级别）
    g、启动图形化终端（5级别）
8、守护进程的类型：

    独立守护进程
    xinetd：超级守护进程，代理人（可类比于超级商城内的小店面）
        瞬时守护进程：不需要关联至运行级别

## how to customed system os 1
\#\# 2018-02- ##  
1、系统

    核心：/boot/vmlinuz-version
    内核模块（ko）：/lib/modules/version
2、模块装载

    insmod
    modprobe
3、用户空间访问、监控内核的方式

    通过修改和查看以下两个目录下的文件来实现的
    /proc/
        a、该目录下的文件基本为只读文件
        b、/proc/sys/此目录中的文件很多是可读写的，通过修改该目录下的文件内容来修改内核运行的特性
            eg：
                echo 1 > /proc/sys/vm/drop_cache
    /sys/
        a、该目录下很多文件都可读写，大部分与硬件相关
4、设定内核参数值的方法：

    a、echo VALUE > /proc/sys/TO/SOMEFILE
        echo 1 > /proc/sys/vm/drop_cache
    b、sysctl -w kernel.hostname='mylab.com' --> 省略/proc/sys/路径，后面每多一层目录则使用.连接
        sysctl -w kernel.hostname='liawne'
    以上两种方式更改后能够立即生效，但不能永久有效，重启即失效
    c、永久有效，但不能立即生效：更改/etc/sysctl.conf
        1、修改文件完成后，执行sysctl -p让更改立即生效
        2、sysctl -a 打印所有内核参数
5、内核模块管理

    a、lsmod：显示系统所加载的模块
    b、modprobe --> 探测模块
        modprobe MODNAME：装载某模块 --> 自动到/lib/modules/version/下找到相对应的模块名字
        modprobe -r MODNAME：卸载某模块
    c、modinfo：查看模块的信息
        modinfo MODNAME
    d、insmod：装载模块
        insmod /PATH/TO/MODULE/FILE
    e、rmmod：移除模块
        rmmod MODULE/FILE
    f、depmod /PATH/TO/MODULES_DIR：生成特定目录下各模块之间的依赖关系，并将生成的依赖文件保存在该目录下
6、内核中的功能除了核心功能之外，在编译时，大多数功能都有三种选择

    a、不使用此功能
    b、编译成内核模块
    c、编译进内核
7、如何手动编译内核

    make gconfig：Gnome桌面环境才能使用，需要安装图形开发库GNOME Software Development
    make kconfig：KDE桌面环境使用，需要安装图形开发库
    make menuconfig：在内核目录下使用
        a、tar xf linux-xxxx.tar.xz -C /usr/src
            解压完成后，需要复制一个可参考的config文件去到linux目录下
                cp /boot/config××× /usr/src/.config
        b、ln -sv /usr/src/linux-xxxx /usr/src/linux
        c、cd /usr/src/linux
        d、make menuconfig
            1、*做进内核
            2、M做成模块
            3、什么都不选，就什么都不做
        e、编辑目录下的.config文件，设定自己系统的特性
        f、make开始进行编译，维持时间会比较长，超过半小时
        g、make modules_install 模块编译
        i、make install 开始编译
    不要在远程连接的时候编译内核，中断了之后需要完全从头开始
8、screen 命令

    screen -ls：查看当前已经建立的screen屏幕
    screen：直接打开一个新的屏幕
        ctrl+a，d：拆除屏幕
        在screen界面下直接使用exit会退出当前的screen屏幕
    screen -r ID：通过上一条命令查看到有哪些打开的screen，通过这个进行切换回该screen
    使用场景：
    a,需要共享操作界面，模拟环境之后，让别人协助解决问题：
        1,screen -S help打开一个名为help的screen窗口
        2,另外一个人通过screen -x help连接进入到同一个窗口
        3,一方敲的任何命令在另一方都能正常显示
9、二次编译时清理，如果有需要请备份配置文件.config

    make clean：清理此前编译好的二进制模块
    make mrproper：清理此前编译所残留的编译参数，包括config文件;建议执行该命令前先备份config文件

## how to customed system os 2 
\#\# 2018-02-07 ##  
1、在一个新盘上手动创建一个可以启动的系统：

    a、fdisk -l /dev/sdb
        --> /dev/sdb1
        --> /dev/sdb2
        --> partprobe
    b、mkfs.ext3 /dev/sdb{1,2}
    c、mkdir /mnt/{boot,sysroot}
    d、mount /dev/sdb1 /mnt/boot
       mount /dev/sdb2 /mnt/sysroot
    e、grub-install --root-directory=/mnt /dev/sdb ---> 生成grub
    f、cp /boot/vmlinuz- /mnt/boot/vmlinuz     ---> 生成vmlinuz文件
    g、更改initrd（更改mkrootdev那一行内容，若有swap内容，将swap那一行注释掉，重新压缩成initrd文件）内容后，
            将文件放到/mnt/boot目录下（步骤参照3） ---> 生成initrd文件
       # rhel5: mkinitrd /boot/initrd-$(uname -r).img $(uname -r)
       # rhel6: dracut /boot/initramfs-$(uname -r).img $(uname -r)
    h、vim /mnt/boot/grub/grub.conf                ---> 配置grub.conf文件
       #  default=0
       #  timeout=5
       #  title Test Linux (Liawne Test)
       #      root (hd0,0)
       #      kernel /vmlinuz
       #      initrd /initrd.gz
    i、cd /mnt/sysroot;mkdir proc sys dev etc/rc.d lib bin sbin home boot var/log usr/{bin,sbin} root tmp -pv
    j、cp /sbin/init /mnt/sysroot/sbin/;cp /bin/bash /mnt/sysroot/bin/;
    k、ldd /bin/bash  --> 复制相应的依赖库文件到对应的/mnt/sysroot/lib目录下
       ldd /sbin/init --> 复制相应的依赖库文件到对应的/mnt/sysroot/lib目录下
    l、chroot /mnt/sysroot --> 试验是否可以使用
    m、vim /mnt/sysroot/etc/inittab 编辑该文件，设定启动级别等
       #  id:3:initdefault:
       #  si::sysinit:/etc/rc.d/rc.sysinit
    n、vim /mnt/sysroot/etc/rc.d/rc.sysinit; chmod +x !$
       #  #!/bin/bash
       #  echo "Welcome to test linux !"
       ##  insmod /lib/modules/mii.ko        <--- 后面新加内容
       ##  insmod /lib/modules/pcnet32.ko    <---
       ##  ifconfig 192.168.110.99/24        <---
       ##  ifconfig 127.0.0.1/8              <---
       #  /bin/bash
    o、sync;sync;sync
    p、将盘卸载，在其他机器上挂载，并以该盘启动，系统可以正常运行 ！！
2、grub --> kernel --> initrd --> ROOTFS（/sbin/init，/bin/bash）  
3、/boot/initrd 文件为一个 gzip 压缩文件（file 查看），查看内部包含的内容：

    第一种解压方式：
    a、cp /boot/initrd-×××× /root/
    b、mv /root/initrd-×××× /root/initrd-××××.gz
    c、gunzip /root/initrd-××××.gz
    d、ls /root/initrd-×××× （cpio文件）
    e、mkdir /root/test && cd /root/test
    f、cpio -id < /root/initrd-×××× /root/test 
        -i：读入
        -d：展开到当前目录下
    第二种解压方式：
    a、mkdir /root/iso && cd /root/iso
    b、zcat /boot/initrd-××××.img | cpio -id
    更改initrd文件内容后，重新压缩：
    a、cd /root/iso
    b、find . | cpio -H newc --quiet -o | gzip -9 > /mnt/boot/initrd.gz
4、创建脚本，设定复制命令需要的 lib 库文件在执行脚本后直接可以满足需求

    a、脚本已经创建，名字为bincopy.sh
    b、在启动单独当作一个可以启动的磁盘之前，复制两个文件到/mnt/sysroot/lib/modules/目录下
        mii    --> （被pcnet32依赖）
        pcnet32
        文件作用是在系统开启启动的时候可以赋予ip地址（参照上面编辑rc.sysinit文件内容）
5、exec 命令的使用

    a、exec的作用为使启动的进程直接替换掉父进程来执行，例如在当前shell下执行一个命令，加上exec后，命令所产生的进程起来
        bash进程终止
    b、在rhel中，使用软链接链接到同一个脚本，实现关机/重启的功能
6、mingetty 的作用

    a、mingetty是一个命令，rhel/centos系统使用这个命令来登录系统，执行/sbin/mingetty后打开一个tty，然后在这个tty上
        执行login命令，提示登录
    b、可使用stty设置终端的size和属性
        stty -F /dev/console size|speed --> 查看终端属性，显示横纵字符数|速度
7、修复文件系统的参考方式（文件系统错乱），在修复过程中，会将检查出错的文件直接删除的

    a、在执行fsck修复之前，将文件先打包备份
        find . | cpio -H newc --quiet -o | gzip > /root/sysroot.gz
    b、umount 相应的设备
    c、mkfs重新格式化后挂载
    d、将之前打包的文件解压后放回
        zcat /root/sysroot.gz | cpio -id

## script knowledge   
\#\# 2018-02-27 ##  
1，脚本编程知识点

    变量中的字符长度：${#var}
 
## how to customed system os two (bash script threeteen)   
\#\# 2018-02-28 ##  
1、系统刚开机启动时显示的内容，默认就是/etc/issue 中的内容，可以自己定制内容

    a、agetty，stty，mingetty都可以实现
        1、系统上默认以mingetty为例，cat /etc/issue的内容存在/r及/m的内容，表示uname -r/-m的输出内容
            可以在mingetty的man文档中查看到
        2、stty和agetty同样也有自己相应的用法
2、系统用户设置

    绕过pam进行登录
    a、/bin/login到文件passwd和group存在一个中间层，为nsswitch（network service switch）
    b、在nsswitch中定义一个框架，去哪里找到用户信息
    c、nsswitch有一堆的库文件，还有自己的配置文件（库：libnss_file.so,libnss_nis.so,libnss_ldap.so）
    d、配置文件nsswitch.conf，在这个文件中定义去哪里找认证信息，这就是所谓的框架的意义
    e、/lib目录下以libnss开头的库文件，实现不同的用户名解析的方式
3、复制一个文件，保留链接地址不变

    cp 
        -d --> 复制文件，保留链接
           --> 复制链接，直接就复制了链接对应的文件本身
    vim
        :.,$d --> 当前行到文件末尾全部删除
        :1,.d --> 从第一行到当前行全部删除

## busybox setting 15_03   
\#\# 2018-03-06 ##  
1，busybox：一个二进制文件，模拟实现了许许多多的命令  
2，RHEL5.8+initrd（busybox）+rootfs（busybox）  
3，查看本机硬件信息

    a、查看cpu信息： 
        cat /proc/cpuinfo
    b、查看usb信息：
        lsusb
    c、查看pci信息
        lspci
    d、硬件抽象层
        hal-device（rhel5）
    e、dmidecode（rhel6）
4，实现部分编译

    a、只编译某子目录下的相关代码
        make dir/
        make arch/
        make drivers/net/
    b、只编译部分模块
        make M=drivers/net/
    c、只编译某一个模块
        make drivers/net/pcnet32.so
    d、将编译完成的结果放至其他目录
        make O=/tmp/kernel
5,如何编译 busybox  

## bash signal 16_01 
\#\# 2020-11-25 ##  
1, 交叉编译(用于在一个平台上编译可在多个平台上运行的程序)
    make ARCH=
2, bash 中变量的赋值
    ${param:-word}: 如果 param 为空或者未定义,则展开变量为"word",否则,展开为 param 的值
    ${param:+word}: 如果 param 为空或者未定义,不做任何操作,否则,展开为"word"的值
    ${param:=word}: 弱国 param 为空或者未定义,则变量展开为"word",并将展开之后的值赋值给 param
    ${param:offset}: 偏移多少后,取剩下的 param 变量值
    ${param:offset:length}: 偏移 offset 之后,再取 length 长度的 param
3, 脚本配置文件
    /etc/rc.d/init.d/服务脚本
    服务脚本支持配置文件,/etc/sysconfig/服务脚本同名的配置文件
## system problem solving 17_02   
\#\# 2018-03-06 ##  
1，常见系统故障排除

    a、确定问题的故障特征
    b、重现故障
    c、使用工具收集进一步信息，确定故障的真正原因
    d、排除不可能的原因
    e、定位故障
        1、从最简单的问题入手
        2、一次尝试一种方式
2,故障排除中的一些原则

    a、任何涉及到修改源文件的操作时，都需要备份源文件
    b、尽可能的借助于工具
3，可能出现的故障

    a、管理员密码忘记
    b、系统无法启动
        1、grub损坏（MBR损坏，grub配置文件丢失）
            MBR损坏：
                模拟环境：
                dd if=/dev/sda of=/root/mbr.backup bs=512 count=1 --> 备份操作
                dd if=/dev/zero of=/dev/sda count=1 bs=200        --> bs小于446,否则分区表被损坏，文件系统无法使用
                解决方法：
                a、借助别的主机修复
                b、使用紧急救援模式
                    1、boot.iso
                    2、使用完整的系统安装光盘
                    3、进入到grub交互界面
                    4、填入grub的启动root（hd0,0），find （hd0,0）2×tab，确认后执行setup（hd0,0）
            grub.conf丢失
                模拟环境：
                mv /boot/grub/grub.conf /root
                解决方法：
                a、系统无法启动，进入到grub界面
                b、find （hd0,0）2×tab，填入root×××回车，kernel×××回车，initrd×××回车，boot启动系统
                c、进入系统后，看看能否找回配置文件，找不回则手动建立
                    手动建立-->1222
        2、系统初始化故障（某文件系统无法正常挂载，驱动不兼容）
            grub：编辑模式
            emergency mode：系统启动过程不执行rc.sysinit脚本，在emergency模式下对系统进行修改
        3、服务故障
            某些服务无法启动导致系统卡住也无法启动
            a、单用户模式下设置该服务不启动
            b、单用户模式下更改该服务配置是其能够正常启动
            c、在内核行敲击‘I'来进入交互式模式指定系统服务的启动与否（交互式模式）
        4、图形界面出现故障
        5、用户无法登录系统（帐号密码输入错误，bash程序故障）
            bash文件被删除后，系统连1级别也无法进入
            mingetty文件被删除，可以进入到单用户模式下，修复文件
            PATH环境变量被损坏，可以手动export进行设定
    c、命令无法运行
    d、编译过程无法继续（开发环境缺少基本组件）
    e、kernel panic（内核恐慌）
    f、另外的故障
        把默认启动级别设置为0或者6 --> 进入单用户模式，编辑inittab文件
        /etc/init.d/rc*.d/目录被删除了 --> 进入单用户模式，编辑inittab文件
4,使用 rescue 进入救援模式后，chroot 切换至原有的根文件系统，缺少了脚本 rc.sysinit 脚本的执行，相应的就缺少了部分功能

    a、常见的情况，无法识别挂载的光盘，因为缺少了udev的激活过程（/dev目录下缺少设备文件）
        手动创建设备文件 --> mknod
5,系统启动过程回顾

    POST --> BIOS（启动设备顺序依次找其MBR中的bootloader）--> kernel（加载initrd，挂载根文件系统rootfs，\
        执行/sbin/init脚本）--> /etc/inittab

## sudo settings 17_03   
\#\# 2018-03-06 ##  
1、sudo 的功能是某个用户能够以哪一个用户的身份通过哪些主机执行哪些命令  
2、不要使用 vi/vim /etc/sudoers，保存后无法检查编辑的语法  
3、sudoers 文件中的语法格式  

    一、用户条目   
    who               which_host      =       (runas)             commands     
    which user      哪些主机可以连上来       以谁的身份连上来     允许使用哪些命令

    二、default设定一些默认属性
    别名：类似于组的概念，别名必须全部而且只能使用大写英文字母的组合，必须先定义才能使用，均可使用’！‘取反
    a、user_alias：用户别名，可以将一些用户统一起来，用一个别名统称
        User_Alias USERNAME =
            用户的用户名
            组名，使用%引导
            还可以包含其他已经用户别名
    b、host_alias：主机别名，可以将一些主机统一起来，用一个别名统称
        Host_Alias
            主机名
            IP
            网络地址
            其他主机别名
    c、runas：以哪个用户的身份来执行的
        Runas_Alias
            用户名
            %组名
            #uid
            其他主机别名
    d、cmnd_alias：命令别名，将一些命令统一起来
        Cmnd_Alias
            命令路径
            目录（表示该目录下的所有命令）
            其他事先定义过的命令别名
    三、可在命令前增加标签，定义命令使用的方式
        a、最常用的方式为在命令前增加NOPASSWD： --> 不再需要用户在使用命令前输入密码
        b、对特定命令需要使用密码，某些不要使用，则在各个命令前增加（PASSWD：|NOPASSWD：）做限定
4、示例

    a、为hadoop用户增加useradd，usermod权限
        # visudo
        # hadoop ALL=(root) /usr/sbin/userdel,/usr/sbin/usermod
    b、增加别名，不需要使用密码
        User_Alias USERADMIN = hadoop, %hadoop, %useradmin
        Cmnd_Alias USERNAMECMD = /usr/sbin/usermod,/usr/sbin/userdel,/usr/sbin/useradd,/usr/bin/passwd,! /usr/bin/passwd root 
        USERADMIN ALL=(root) NOPASSWD:USERNAMECMD 
5、sudo 命令的用法

    -k：使认证信息失效
    -l：列出当前用户所有sudo能够使用的命令列表
    -i：切换至root用户
6、sudo 及/etc/sudoers 文件的具体使用方法都可以在 man 文档中找到  
7、sudo 的日志文件保存在/var/log/secure 日志中，权限设置为 600  

## bash array 31-01   
\#\# 2018-03-13 ##  
1、变量：命名的内存空间，bash 中所有的变量均被以字符型的类型存储  
2、数组：内存中存储连续变量  
3、如何声明一个数组：

    declare -a AA -->声明数组AA
        赋值方法一：
            AA[0]=tom
            AA[1]=jerry
            AA[2]=cat
            AA[6]=natasa
        赋值方法二：
            AA=(tom jerry cat)
        赋值方法三：
            AA=([0]=tom [1]=jerry [2]=cat [6]=natasa)
4、一些特殊使用情景

    查看数组中某个元素的长度
    echo ${#AA[0]} --> 显示数组中第一个元素的长度
    echo ${#AA[*]} --> 显示数组中不为空的元素的个数
    echo ${#AA[@]} --> 显示数组中不为空的元素的个数
5、在脚本中捕捉信号，并且可以实现特定处理

    trap --> 捕捉信号，用户替换执行用户发出的指令
        trap ‘’ SIG --> 将捕捉到的SIG替换成‘’中的命令（函数也可）执行
        使用的场景：用户使用ctrl + C终止脚本执行，将之前定义的变量和生成的文件删除
    9/15一般不可被捕捉，

## getopts 31-02   
\#\# 2018-03-23 ##  
1，getopts

    shell的内置命令，使用help getopts查看相应的使用方法
    a、getopts只能获取一个选项
    b、命令格式：getopts optstring name [arg]
                 1,getopts 'bd' OPT && echo $OPT --> 可接受-b，-d选项，接受的内容存在变量OPT中
                 2,getopts 'bd:' OPT && echo $OPT && echo $OPTARG --> d可接受参数（b缺少：，不可以接受参数），
                    使用shell内置变量OPTARG可显示参数的内容（使用选项不同的时候，变量对应的值不同）
                 3,getopts只可接受一个选项，不接受同时接多个选项（-b -d同时用）
    c、可使用循环来让getopts接受多个选项
        while getopts ":d:" OPT; do
            case $OPT in 
                d)
                    echo $OPT
                    echo $OPTARG
                    ;;
                ?)
                    echo "Wrong choice"
                    echo "USAGE : mkscript [-d DESCRIPTIONS] FILENEME"
                    ;;
             esac
        done
    d、接了：之后，后面必须接上参数，不然返回值为错误
    e、getopts还有一个内置的函数OPTIND（选项索引）
        作用:执行了命令./mkscripts -b -d -c /tmp/testfile，$OPTIND取完了-b之后取-d..，一直到将所有的参数取完
        注意点：使用不同参数时，对应的OPTIND对应的值也不同
    f、getopts命令的具体使用方法可参见定制命令vims,attach-scripts/getinterface

## vnc 31-03   
\#\# 2018-03-24 ##  
1，vnc：virtual network computing 虚拟网络计算  
2，vnc 能够实现跨平台共享桌面，桌面的打开可基于客户端实现也可基于浏览器实现  
3, 能够实现本机没有开启任何图形化界面的情况下，远端的 windows 或者 linux 打开本机的图形界面  
4,vnc 的传输是明文的，跨越网络实现 vnc 链接不安全  
5，实现连接：

    a，查看是否安装vnc-server
        rpm -qa |grep vnc
    b，同样的用户登录ｖｎｃ，使用的密码不一定是该用户的系统登录密码，为ｖｎｃ专用密码，保存密码是加密的，但登录认证的
        过程不是加密的
    ｃ，设定当前用户基于ｖｎｃ协议访问当前主机的ｖｎｃ密码
        vncpasswd
    d，启动服务
        第一次启动vnc服务：vncserver &，稍等片刻会出现c6u6test1：1 desktop for root的提示，表示现在是第一
            个桌面（root），类似于使用screen命令，每个用户只能用一个桌面，需要两个用户登录最少要开启两个桌面
            再次执行vncserver &
        以后启动使用：service vncserver start
    e，登录桌面
        打开windows上的vncviewer，在服务器行输入172.16.100.1：1，确认之后再输入密码
    f，默认打开的桌面是xterm，仍类似于文本界面，twm（著名的桌面管理器），若需要打开图形化，则需要进行配置;
        在需要进行vnc链接的用户家目录下会生成一个.vnc的文件夹，该目录下存在文集那xstartup文件，进行编辑，将
        twm & 改为gnome-session，去掉注释unset SESSION_MANAGER和exec /etc/X11/xinit/xinitrc
    g，重启服务，vncserver -kill ：2; vncserver -kill ：1关掉刚才打开的session;重新打开vncserver &

## iptables-1 28-01   
\#\# 2018-03-24 ##  
1,linux 网络防火墙

    netfilter：Frame（网络过滤器）
    iptables：生成防火墙规则，并且能够将其附加在netfilter上，真正实现数据报文过滤，NAT，mangle等规则生成的工具
2,iptables 依赖于网络的相关内容，分别是 IP 报文首部，TCP 报文首部

    a、以http数据包为例：IP报文<TCP首部<http首部
3,iptables 使用规则

    a、iptables [-t TABLE] COMMAND CHAIN [num] 匹配条件 -j 处理办法
    b、匹配条件：
        通用匹配
            -s:源地址
            -d:目标地址
            -p:匹配协议<tcp|udp|icmp>
        扩展匹配
            隐含扩展
                -p tcp当指定了某个协议之后,就可以使用该协议的相应扩展功能
                    --sport PORT[-port]:源端口(port不能使离散的端口,只能是连续的端口)
                    --dport PORT[-port]:目标端口
                    --tcp-flags mask comp:只检查mask指定的标志位,是逗号分割的标志位列表;comp:此列表中出现在mask中,标记为必须为1,而mask中剩下的必须为0
                        --tcp-flags SYN,FIN,ACK,RST SYN,ACK == --syn(匹配tcp三次握手中的第一次)(31:30)
                    命令示例:
                        1,放行来自172.16.0.0/24到达172.16.100.7的ssh连接(注意应该有两条规则 ,一进一出)
                            iptables -t filter -A INPUT -s 172.16.0.0/24 -d 172.16.100.7 -p tcp --dport 22 -j ACCEPT  -->要注意sport和dport的使用
                            iptables -t filter -A OUTPUT -s 172.16.100.7 -d 172.16.0.0/24 -p tcp --sport 22 -j ACCEPT
                -p icmp
                    --icmp-type:icmp是有类型的,ping命令需要用到的是code为0和8两种
                        0:echo reply(响应报文)
                        8:echo request(请求报文)
                        命令示例:
                            1,设置filter所有鏈的默认策略为DROP,放行172.16.100.7 ping其他主机(自己能ping别人,别人ping不了你)
                            iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -i lo -j ACCEPT
                            iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -o lo -j ACCEPT
                            iptables -A OUTPUT -s 172.16.100.7 -p icmp --icmp-type 8 -j ACCEPT
                            iptables -A INPUT -d 172.16.100.7 -p icmp --icmp-type 0 -j ACCEPT
                -p udp
                    --sport
                    --dport
                        命令示例:
                            1,设置filter所有鏈的默认策略为DROP;主机作为一台DNS服务器,相应来自客户端的DNS请求(能联网的主机)
                            总共需要8条规则,tcp和udp各占一半,剩余四条分别是作为DNS服务端,接收并响应客户端请求;以及需要联网查询的时候,作为客户端时,请求并接收外部主机
            显示扩展:使用额外的匹配机制
                -m EXTENSION --spec-opt
                    state:状态扩展,结合ip_conntrack追踪会话的状态(根据IP来追踪状态的,不是根据tcp来追踪)
                        NEW:新连接请求
                        ESTABLISH:已经建立的连接,对新请求的响应
                        INVALID:非法连接请求
                        RELATED:相关联的,由命令连接激活的另一个连接,两个连接之间的关系叫做related
                    -m state --state NEW,ESTABLISHED -j ACCEPT
                        命令示例:
                            1,只允许http的外部连接请求进来,不允许主机发送新连接请求到其他主机(为了防止反弹木马-->主动连接外部主机)
                            iptables -A INPUT -d 172.16.100.7 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
                            iptables -A OUTPUT -s 172.16.100.7 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
                    -m multiport:离散的多端口扩展匹配
                        --source-ports
                        --destination-ports
                        --ports
                        命令示例:
                            1,同时匹配三个规则
                            iptables -I INPUT -d 172.16.100.7 -p tcp -m multiport --destination-ports 21,22,80 -m state --state NEW -j ACCEPT
                    -m iprange:指定ip地址范围
                        --src-range
                        --dst-range
                        命令示例:
                            iptables -A INPUT -p tcp -m iprange --src-range 172.16.100.3-172.16.100.100 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
                    -m connlimit:连接数限制
                        ! --connlimit-above n:指定连接的上限
                        命令示例:
                            1,限定本机连接到172.16.100.7的连接不能超过两个
                            iptables -A INPUT -d 172.16.100.7 -p tcp --dport 80 -m connlimit ! --connlimit-above 2 -j ACCEPT
                            iptables -A INPUT -d 172.16.100.7 -p tcp --dport 80 -m connlimit --connlimit-above 2 -j REJECT
                    -m limite:用于限制连接速率的
                        --limit RATE:限定速率
                        --limit-brust:限定次数
                    -m string:用来屏蔽请求返回内容包含匹配字符的
                        --algo {bm|kmp}
                        --string "string"
                    条件取反:加上!
4,常用命令:

    a, 管理规则
         -A:附加一条规则(鏈的尾部)
         -I CHAIN [num]:插入一条规则(指定添加的位置),省略则为第一条
         -D CHAIN [num]:删除指定鏈中的第num条规则,省略也可匹配
         -R CHAIN [num]:替换指定的规则
    b, 管理鏈
         -F [CHAIN]: flush,清空指定规则鏈,如果省略CHAIN,则可以实现删除对应表中的所有鏈
         -P CHAIN:设定指定鏈的默认策略;
         -N:自定义一条新的空鏈
         -X:删除一个自定义的空鏈(必须是空鏈,非空则需要先使用-F清空)
         -Z:清空指定鏈中所有规则的计数器
         -E:重命名一条自定义鏈
     c,查看
         -L:显示指定表中的规则
             -n:以数字格式显示主机地址和端口
             -v:显示鏈及规则详细信息(可接收-vv),显示的是可读形式
             -x:显示精确值(exact)
             --line-numbers:显示规则号码
     d,可执行的动作(target):
         ACCEPT:放行
         DROP:丢弃
         REJECT:明确告诉拒绝
         DNAT:目标地址转换
         SNAT:源地址转换
         REDIRECT:端口重定向
         MASQUERADE:地址伪装
         LOG:日志
             LOG还可以包含各种不同的参数,例如记录序列号,用户uid等
             LOG与其他的动作结合使用时,需要把相应的规则放在前面,否则匹配了之后到不了LOG处
             使用LOG作为记录使用时,最好结合速率限制一起使用,防止记录过多信息
         MARK:给匹配的包打上标记,不放行也不拒绝
5,iptables 服务:

    a,iptables不是服务,但有服务脚本;服务脚本的作用主要在于管理保存的规则
    b,可以使用lsmod来查看iptables的相应模块是否被加载(ip_tables,ip_nat,ip_contract,iptable_nat等)
    c,停止了iptables服务,其实就是将iptables的相应模块移除了
    d,加载或者移除iptables/netfilter相关的内核模块
6,连接追踪功能 ip_conntrack

    a,功能:客户端,服务端彼此之间建立的连接关系,并且能够追踪到一个连接与另外一个连接彼此之间处于什么样的一个状态,并且拥有什么样的关系
    b,文件/proc/net/ip_conntrack,保存有当前系统上每一个客户端与当前主机建立的连接关系
    c,使用命令iptstate查看当前系统的包追踪状态
        -t:显示个数
    d,内核参数ip_conntrack_max保存有当前系统最多可追踪的连接数,超出这个数字之后,新的连接会因超时而被丢弃
        1,对于web服务器,连接数需要调大,否则可能导致连接错误
        2,对于特别繁忙的服务器,尽量不要开启这个模块
        3,使用iptables命令查看规则的时候(iptables -t nat -nL),会加载该模块,自动开始追踪
    e,iptables的规则保存文件/etc/sysconfig/iptables
7,iptables 规则保存

    a,service iptables save
        默认保存在/etc/sysconfig/iptables
    b,iptables-save > xxx
        使用重定向的方式将规则保存起来
    c,iptables-restore < xxx读取规则文件

## understanding the linux operating system 1 
\#\# 2018-04-09 ##  
1、OS：operating system 本身就是一个虚拟机  
2、计算机构成：五大部分  

    CPU：
         运算器：负责运算，算数运算、逻辑运算
         控制器：控制指令，数据的存取过程
         寄存器：CPU计算数据来源及计算结果暂存位置（register）
3、程序就是指令加数据构成的  
4、CPU 与内存的沟通（CPU、north bridge、RAM）

    a、理解为CPU通过桥（总线）连接到North bridge，North bridge在通过桥（总线）连接到RAM;桥的宽度可以是32bit、64bit
       桥的宽度影响CPU能够寻址的大小，32bit时为2^32=4GB大小;64bit时为4G×4GB大小。
    b、CPU的控制指令、数据存取都是通过这个32bit、64bit，也即是线路复用的情况
5、PAE：物理地址扩展 physical address extension

    作用：为32位的寻址总线加上了4bit;32bit，+4bit;增加了该功能够，使本身只支持4G的系统可以支持4GB×16=64GB
6、缓存的使用

    a、程序：局部性
    b、CPU的缓存：指令缓存，数据缓存;一级缓存、二级缓存各cpu独有，三级缓存一般是共享的;缓存的大小会影响系统性能
    c、对于ram存取数据来说，保存有数据实际上就是ram中带有电荷，读取完成之后，电荷就消失了;ram需要不停的刷新来存取数据
7、缓存的置换策略

    a、空间局部性：一个数据被使用到，则其旁边的数据被用到的概率更大
    b、时间局部性：一个数据如果被用到，那他再次被用到的概率更大
8、若 CPU 有输出，有数据被更改，则可能对一级缓存、二级缓存、三级缓存、主存、硬盘都要进行写操作，这种方式称为通写（write through）;  
9、若 CPU 有输出，有数据被更改，但是没有立即写入到各层级存储中去，只有数据在被丢弃的时候才写入后面的存储，这种方式称为回写（write back）;目前绝大多数情况都是回写的方式，性能相对而言高了很多;  
10、一般情况下，显卡也是直接接到 North bridge 上的，需要使用到 CPU 对图像进行渲染和计算，数据交换量是非常大的;  
11、IO 分为高速 IO 和低速 IO

    a、高速IO一般是指PCI的IO，高速IO总线
    b、南桥一般是把慢速IO汇总起来，一并交给北桥进行处理
    c、PCI是连接到南桥的，速度其实不能算是很快;现有PCI-E口，直接接到北桥上，速度比PCI口快了不止一点点;
    d、使用PCI-E口的USB速度会很快，带宽足够了，瓶颈可能变成了USB的读写能力，这个时候可以将多个USB设备整合成为一个存储
        设备，并行读写，这种方式就是固态硬盘的方式;仍有选择使用PCI（SATA）口的固态硬盘，建议用PCI-E口的固态硬盘;
12、各种设备连接到南桥，南桥在连接到北桥，北桥在连接到 CPU;北桥和内存又相连;北桥给各种不同的设备分配地址（32bit/64bit）用做 CPU 来区分和识别 

    a、任何一个设备，为了能够和主机交互，在加电自检完成之后，每一个硬件都必须向CPU注册申请整个IO端口上一片连续的端口;
        每一次注册的结果可能不一样;在开启后，CPU与这些设备交互都是通过这些端口来进行;
    b、虽然各个设备已经注册了不同的端口与CPU交互，但仍然还是通过同一个总线进行 --> 总线复用
    c、没一个硬件设备的内部线路可能与CPU不一致，但都会有各自的控制器（适配器），作用是将这个设备能够理解的信号转换成
        总线上能够识别的信号，是个翻译官，还可能附带是司令官，控制校验，速率设定等;
13、（可编程）中断控制器（Interrupt Controller）

    a、CPU上自带有一个中断控制器，用于接收处理中断信号的;
    b、当硬件设备上来了信号之后（区别于IO端口），由这个硬件设备负责通知CPU（中断控制器）进行处理;
    c、中断控制器帮助CPU识别是哪个硬件发过来的中断请求;中断控制器上有中断控制线（中断通路）;
    d、硬件发送过来的中断信号，也即是中断向量 
    e、每一个硬件设备在启动的时候，必须要向中断控制器（可编程中断控制器）来申请注册使用一个中断向量 --> 有地址
        的通知机制;当信号发送过来后，能够自动被CPU识别，即认识到是哪个硬件设备发送过来的。
    f、一般将中断处理分为上半部和下半部;上半部，将请求接近来;下半部，处理中断请求。
14、直接内存访问 DMA（direct memory access）

    a、cpu将数据从磁盘中读取写入的操作授权给其他助手使用（总线的使用），可能出现资源争抢的情况，容易出现争抢现象的
        位置称为临界区
    b、CPU告诉DMA有15M可以读取，将线路授权给DMA;DMA没有CPU那么打的总线带宽，一般系统会预留低地址的内存给DMA
        使用（寻址限制）
15、BIOS 自举

    a、系统启动之后，系统会将ROM空间内容映射到内存最开始的部分
    b、CPU加电后，什么事都不干，先执行内存最初始部分的代码，完成自检，加载bootloader
    c、内存的空间分配为ROM：DMA：left
16、系统启动之后，CPU 一直处于运行状态，区别只是有用的转和无用的转，运行称为时钟周期

    a、CPU内部通常有一个称为时钟产生器的东西（晶体震荡器）
    b、内存可能在一个CPU的时钟周期内只走了一点点
    c、CPU以时间片来进行资源的利用和分配，通过时间的流逝来体现计算能力
17、操作系统的演变（所有的程序运行都要向监控程序申请资源）

    a、有一个管理系统（管理程序），负责从磁盘中加载一个程序到内存中，然后加载程序到CPU进行运算，运算结果保存到内存
        中，再把数据写回到硬盘;再加载另一个程序来运行，周而复始;这个程序早期叫做monitor，就是一个监控程序，其他程序的
        监控程序
    b、程序发展得越来越大，变成了OS（operating system）
    c、OS把整个机器抽象出来，变成了一个虚拟机VM（virtual machine）
18、process：进程，一个独立的运行单位

    a、进程无法直接在硬件上运行，由监控程序（OS）来监控运行
    b、系统资源：CPU时间、存储空间
19、OS：VM

        a、CPU：站在CPU的角度，以时间来进行区分
            1、时间：切片来进行;一个10GHz的CPU可以虚拟看成是10个1GHz的虚拟CPU
            2、缓存：缓存当前程序数据，在数据清空前需要进行回写
            3、指令计数器：CPU当中包含的，当前的进程分配的时间用完了，但是进程仍未执行完，下次怎么继续处理呢，依赖于
                            指令计数器来实现
            4、进程切换：进程切换的时候要保留现场，恢复现场;进程切换是有开销的，如缓存在切换的过程中被清掉了，恢复现场
                            的时候则需要重新加载数据，保存现场的数据保存在主存当中
        b、MEM：站在内存的角度，以空间大小来进行区分，同样还是切片
            1、内存的实现方式为：将内存切割，分成4K大小的存储槽，每个存储槽称作一个页框;每个槽能够存储的数据称为一个
                页面（page），每一个页面的存储空间称为一个页框（page frame），在页框上增加一个页框和页的映射关系;
            2、每一个进程都认为自己是有4G空间可用的
                a、内存空间的分配：指令区（代码区），数据区，bss段，heap区 <--> stack区
                                   --------------  | ----- | ---- | ----- |    |------- --> 4G大小
                                   只使用了有限的空间，中间为空
                   以上面的为例解释，假设指令区一个页，数据区一个页，bss一个页，heap一个页，stack一个页;通过映射，指
                   令区映射到一个页框，数据区映射到一个页框，bss映射到一个页框，heap映射到一个页框，stack映射到一个
                   页框（不一定连续）
                b、虚拟出来的空间可以认为是一个进程描述结构
                c、这个是有内核在内存中维护的，当进程需要使用时，内核告诉进程相应的映射关系
                d、页目录，映射关系由一个芯片负责维护，在进程需要使用到自己的数据时，怎么样能够更快的找到虚拟地址（线
                    性地址）实际对应的物理地址呢;通过页目录来实现的，页目录分为一级、二级、三级。。来实现更高效率的
                    查找;用于方便建立线性地址到物理地址的对应关系
                e、通过空间映射来完成
                f、实现映射关系的芯片的引入还同时具有了内存保护的功能
         c、IO设备：在进程层次上，IO设备不需要去做虚拟，IO设备在谁获得了当前的焦点，IO对应的切换就交给哪个进程了
            1、IO只能是内核控制，一旦产生IO中断，一定是和内核交互，再由内核转给进程
            2、内核，N×进程 --> 系统
                a、内核运行时，是内核模式
                b、进程运行时，是用户模式
                c、在内存当中，内核占用空间是内核空间，进程占用空间是用户空间
                d、进程是不能直接控制硬件的
20、早期 x86 架构的系统是不适合用来做虚拟机的，在后来 CPU 支持硬件虚拟化之后才实现了

    a、在进程的层次上，资源已经被虚拟化过一次了
21、CPU 指令分为四个层级，环 0-3,环 0 为内核模式（特权模式），环 3 是用户模式（限制模式）  
22、虚拟机的运行模式有多种，其中一种是仿真（模拟）出来硬件层，在虚拟机系统层面查看不出来是否是在虚拟机上运行

    a、这种模式下，虚拟机上的内核运行特权指令时是通过虚拟机先翻译传给物理机内核，内核处理完再返还
    b、在后来更改了一种机制，物理机上增加环-1（包含最最特权的指令），虚拟机可以运行环0的指令（不包含一些特权指令）
        硬件虚拟化也就是提供了-1环
23、IO 准备的过程

    a、进程空间交接给内核空间
    b、内核开始调用，将辅存当中的数据读取出来，先放到内核空间的缓存中
    c、内核空间缓存转移到用户空间缓存中
    d、地址映射，物理内存映射完成
    e、资源准备完成，内核唤醒进程
24、进程队列

    a、就绪状态，sleeping状态（可中断、不可中断）

## understanding the linux operating system 2   
\#\# 2018-04-16 ##  
1、操作系统、硬件、软件结构图

     ----------------------------------------------------
    |                     Applications                   |
    |---------------------------                         |
    |       Libraries           |                        |
    |----------------------------------------------------|
    |                                                    |
    |         Kernel            -------------------------|
    |                           |            Drivers     |
    |            --------------------------              |  
    |            |       Firmware         |              |
    |----------------------------------------------------|
    |                  Hardware                          |
     ----------------------------------------------------
2、在 linux 中，进程是通过双向链表（list）来进行管理组织的

    a、进程描述符：没一个进程都有其进程描述符 
    b、在创建一个进程的时候，首先一步就是要创建一个进程描述符，并将其添加到双向链表上
    c、杀掉一个进程，就是将这个进程描述符删除，内核不在能够追踪此描述符
    d、创建了一个进程后除了给进程分配CPU、内存等资源外，还需要在内核的内存空间中维护一个进程描述符文件，里面保存有进程
        当前的所有相关信息
3、task_struct（进程描述）

      task_struct
     --------------
    |status
    |--------------
    |thread_info
    |--------------
    |usage
    |flags
    |...
    |--------------
    |run_list
    |
    |tasks
    |--------------
    |...                    mm_struct
    |--------------        --------------------
    |mm            -----> | pointers to memory |
    |--------------       | aera descriptors   |
    |                      --------------------
    |--------------
    |real_parent
    |parent
    |--------------
    |...
    |--------------
    |tty           -----> ...
    |--------------
    |...
    |--------------
    |thread        -----> ...
    |--------------
    |...
    |-------------
    |fs            -----> ...
    |--------------
    |files         -----> ...
    |-------------
    |
    |-------------
    |signals
    |pending
    |-------------
    |
     -------------
4、进程切换

    a、进程切换也称为上下文切换（context switch）
    b、进程A切换至进程B，A挂起，称为保存现场;B恢复，称为恢复现场
    c、进程切换由内核进行管控;每次进程切换都需要经过内核，进程由用户模式切换至内核模式，内核模式在切换回用户模式
    d、进程切换需要时间，分为用户模式需要占用的时间和内核模式需要占用的时间（分别对应top中的sys和usr）
    e、进程切换太多不好（内核模式占用时间多，用于处理事件的用户模式占用时间就少了）;进程切换太少也不好（10个进程，
        每个进程等待时间过长，影响用户体验）
    f、linux支持进程抢占，linux有自己内部的系统时钟：tick（滴答），每一次tick即可产生一次时钟中断
5、linux 中进程分类

    a、交互式进程（IO密集型，等待IO）：桌面型优先级相对高一些
    b、批处理进程（CPU密集型）：服务器型优先级相对高一些
    c、实时进程（real-time）：优先级特别高
    d、分配策略：为CPU密集型进程设定时间片长，优先级低;为IO密集型设定CPU时间片短，优先级高
6、linux 优先级

    a、实时优先级：1-99,数字越小，优先级越低
    b、静态优先级：100-139,数字越小，优先级越高
    c、实时优先级比静态优先级高
    d、在top的输出结果中，表头显示PR（priority）的列中出现RT表示real time;riprio（实时优先级）
    e、在top命令的输出结果中comm列包含[]的命令表示为内核线程
7、linux 调度类别

    a、实时进程：
        1、SCHED_FIFO：First In First Out
        2、SCHED_RR  ：Round Robin
        3、SCHED_OTHER：用来调度100-139的进程
    b、在top命令输出结果中的CLASS列表示的是该进程的调度类别
    c、动态优先级：在内核当中，若某个进程长时间为被运行，内核会临时性的调高其优先级
    d、chrt命令用来调整1-99的进程，nice/renice用于调整100-139的进程
        1、chrt -f -p prio pid ：fifo
        2、chrt -r -p prio pid ：rr
8、优先级算法 O（1）

    2.6的内核使用方式为划分为1-139共140×2=280个队列（每个级别有两个队列，一个是活动队列，一个是过期队列），
    将每个级别的进程分别加入各自对应的队列，每次需要选择进程进行执行，扫描队列的首部即可

## understanding the linux operating system 3  
\#\# 2018-04-16 ##  
1、中断

    a、硬中断：硬件产生的中断
    b、软中断：由用户空间进入到内核空间
2、CPU 缓存

    a、一级缓存有两个，分别是I1（指令缓存），D1（数据缓存）
3、SMP 对称多处理器：在一个主板上有多个 cpu 插槽，每一个插槽称为一个 socket

    a、完成一次正常的内存访问，CPU至少需要三个时钟周期，分别是
        1、向内存控制器传输一个寻址要求
        2、完成地址确定后（内存地址的编址是由内存控制器来完成的），CPU找到内存地址并施加一定的请求机制（对内存施加锁）
        3、完成读或者写的操作
    b、内存节点只有一个，性能的提升是有限的（增加CPU），在于内存的争用

## iptables-4 28-04   
\#\# 2018-09-10 ##  
1,iptables 创建自定义鏈(在包进入到主机前,先让其经过 clean_in 自定义鏈处理)

    命令示例:自定义规则鏈,让其能够备主鏈调用
    # iptables -N clean_in
    # iptables -A clean_in -d 255.255.255.255 -p icmp -j DROP
    # iptables -A clean_in -d 172.16.255.255 -p icmp -j DROP
    # iptables -A clean_in -p tcp ! --syn -m state --state NEW -j DROP
    # iptables -A clean_in -p tcp --tcp-flags ALL ALL -j DROP
    # iptables -A clean_in -p tcp --tcp-flags ALL NONE -j DROP
    # iptables -A clean_in -d 172.16.100.7 -j RETURN
    # iptables -I INPUT -j clean_in
    自定义鏈有一个reference属性,可以看出被其他主鏈引用的次数
2,利用 iptables 的 recent 来抵御 DOS 攻击

    # iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j DROP
    # iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
    # iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j DROP
    a.利用connlimit模块将单IP的并发设置为3；会误杀使用NAT上网的用户，可以根据实际情况增大该值；
    b.利用recent和state模块限制单IP在300s内只能与本机建立3个新连接。被限制五分钟后即可恢复访问。
    下面对最后两句做一个说明：
    1.第二句是记录访问tcp 22端口的新连接，记录名称为SSH
    --set 记录数据包的来源IP，如果IP已经存在将更新已经存在的条目
    2.第三句是指SSH记录中的IP，300s内发起超过3次连接则拒绝此IP的连接
    --update 是指每次建立连接都更新列表；
    --seconds必须与--rcheck或者--update同时使用
    --hitcount必须与--rcheck或者--update同时使用
    3.iptables的记录：/proc/net/ipt_recent/SSH
3,NAT(network address translation)

    a,DNAT(目标地址转换)
    b,SNAT(源地址转换)(30:00)

## 加密类型及其相关算法 18-01   
\#\# 2021-06-08 ##  
- TCP/IP 安全问题: 刚开始设计时,没有考虑安全性要求的深远
  ```
    a,以 A --> B 两台主机建立连接为例说明
        - 机密性: 明文传输(ftp, http, smtp, telnet),所有经手人都能看到内容(明信片和信件的差异)
        - 完整性: 传输时不能随意被篡改掉(交易时订单数目被修改)
        - 身份验证: 保证访问的官网是真的官网
    b,机密性的保证:
        - 传输方: plaintext --> 转换规则 --> ciphertext
        - 接收方: ciphertext --> 转换规则 --> plaintext
        1,在互联网中安全设计体系结构中的基本法则: 保证数据机密性的核心不是算法本身,而是密钥
            - 别人可以知道算法,加密依赖的不是算法,主要是密钥,主要是维护性的考虑(换一个密钥比换一个算法简单的多)
        2,对称加密:提供算法本身,用户提供一个密钥;结合密钥和算法,能够将明文转换为密文;解密也使用的是同一个密钥,有加密算法和解密算法
            - 对称加密的好处是算法计算速度很快,但安全性几乎完全依赖于密钥
            - 对称加密的一个坏处是当通信对象过多时,无法有效的对密钥进行管理
    c,完整性的保证:
        - 单向加密算法: 提取数据特征码,A: plaintext:footprint --> B
            a,输入一样,输出必然相同 
            b,雪崩效应:输入的微笑改变,将会引起结果的巨大改变
            c,定长输出:无论原始数据多巨大,结果大小都是相同的
            d,不可逆的:无法根据特征码还原原来的数据
        - 攻击类型:
            中间人攻击: E 截取了 A 发给 B 的内容,篡改了 plaintext 后,重新生成了 footprint >> A: plaintext:footprint --> E: plaintext2:footprint2 --> B
            修复方式: 将 A 发送给 B 的 footprint 内容也使用密钥加密,B 接受到了之后使用密钥解密
        - 密钥加密算法(协商密钥): 一种情况,A 和 B 从来没有见过面,也没有约定过加密解密密钥
            - 协商生成密码: 密钥交换(Internet key-exchange: IKE),双方协商生成密码,但是不让第三方得到这个密码
            - Diffie-Hellman 协议,按照如下方式协商密钥:
                a,A --> B,A 和 B 准备建立连接
                b,明文确认两个数 p, g(大素数, 生成数)
                c,A 自己取一个随机数 x, B 自己取一个随机数 y
                d,A(g^x%p) --> B; B(g^y%p) --> A(此时互联网上明文传输的有四个数,分别是 p/g/g^x%p/g^y%p),因为离散数学原理,无法获取到 x,y 的具体数值
                e,协商的结果为,密钥是 g^xy%p
            - 由软件自己实现
            - 该方式仍然无法解决身份认证的问题(可能协商密钥已经被截取替换),为了解决这个问题,有了非对称加密,公钥加密算法
        - 公钥加密算法(非对称加密算法):
            - 密钥对(一般都是成对出现的):
                a,公钥 p: 公钥不是独立的,公钥是从私钥中提取出来的
                b,私钥 s: 为了保证安全性,私钥一般都特别长
                c,公钥是所有人都可以知道的,私钥必须只能自己知道
            - 用公钥加密的,只能用私钥解密;反之亦然
                a,A --> B,使用 B 的公钥加密,能够解密的只可能是 B(这样就完成了机密性/身份验证的问题)
                b,发送方用自己的私钥加密,可以实现身份认证; 发送方用对方的公钥加密,可以保证数据机密性
            - 公钥加密算法很少用来加密数据: 主要是速度太慢了,一般来说公钥加密会比对称加密慢上三个数量级
                - 公钥加密算法主要用在身份验证上 
            - 已下列传输方式说明:
                a,A(plaintext/footprint): A 使用自己的私钥加密特征码,发送给 B
                b,B 通过 A 的公钥解密特征码,验证是否正常是 A 的
                c,假设中间有 E 截取了 A 发送给 B 的内容,E 能够获取到 A 的特征码,但是无法修改 plaintext 后再生成 footprint(特征码),因为此时生成特征吗只能使用 E 自己的私钥加密,B 在获取到之后,无法使用 A 的公钥解密 E 发送过来的特征码,这样就可以确保身份验证
                d,主要保证的是身份验证,数据不被篡改(篡改了获取之后能判断出来,直接丢弃了);拿到特征码之后,要确认能够用 A 的公钥解密,不能解密就已经有问题
            - 公钥加密主要用在身份验证上
            - 涉及到另外一个问题,怎么获取到 A 的公钥
    d,公钥签名(签名机构问题)
    e,三重验证怎么完成问题
  ```

## the differences between RHEL6 & RHEL7
\#\# 2018-06-08 ## 
    
    -----------------------------------------------------------------------------------------------------------------
                           -        RHEL6                     -          RHEL7
    ------------------------------------------------------------------------------------------------------------------
    filesystem             -        ext4                      -          xfs        
    -------------------------------------------------------------------------------------------------------------------
    kernel version         -        2.6.x-x                   -          3.10.x-x
    -------------------------------------------------------------------------------------------------------------------
    kernel name            -        Santiago                  -          Maipo
    -------------------------------------------------------------------------------------------------------------------
    release time           -        2010-11-09                -          2014-06-09 
    -------------------------------------------------------------------------------------------------------------------
    progress name          -          init                    -          systemd
    -------------------------------------------------------------------------------------------------------------------
                           -        runlevel0                 -          runlevel0.target-poweroff.target           
                           -        runlevel1                 -          runlevel1.target-rescue.target             
                           -        runlevel2                 -          runlevel2.target-multi-user.target         
    runlevel               -        runlevel3                 -          runlevel3.target-multi-user.target         
                           -        runlevel4                 -          runlevel4.target-multi-user.target         
                           -        runlevel5                 -          runlevel5.target-graphical.target          
                           -        runlevel6                 -          runlevel6.target-reboot.target             
                           -        /etc/inittab              -          /etc/systemd/system/default.target         
    -------------------------------------------------------------------------------------------------------------------
    hostname               -    /etc/sysconfig/network        -          /etc/hostname
    -------------------------------------------------------------------------------------------------------------------
    max file size          -            16TB                  -          500TB
    -------------------------------------------------------------------------------------------------------------------
    filesystem check tool  -            e2fsck                -          xfs.repair
    -------------------------------------------------------------------------------------------------------------------
    boot tool              -            GRUB                  -          GRUB2
    -------------------------------------------------------------------------------------------------------------------
    service start          -            upstart               -          systemd 
    -------------------------------------------------------------------------------------------------------------------
                           -     service xxxx start           -          systemctl enable xxxx.service 
                           -     service xxxx stop            -          systemctl start xxxx.service
    service control        -     service xxxx status          -          systemctl stop xxxx.service
                           -     service xxxx restart         -          systemctl status xxxx.service 
                           -     chkconfig xxxx on|off        -          backwards compativility chkconfig service
    -------------------------------------------------------------------------------------------------------------------
    firewall               -            iptables              -          firewalld,iptables
    -------------------------------------------------------------------------------------------------------------------
    network bond           -            bonding               -          teaming,bonding
    -------------------------------------------------------------------------------------------------------------------
    time set               -            ntp                   -          chrony,ntp
    -------------------------------------------------------------------------------------------------------------------
    nfs version            -            NFS4                  -          NFS4.1，支持NFSv3.0,4.0,4.1客户端
    -------------------------------------------------------------------------------------------------------------------
    cluster management     -            rgmanager             -          pacemaker
    -------------------------------------------------------------------------------------------------------------------
    load-balance tool      -            rgmanager             -          HAProxy，Keepalived
    -------------------------------------------------------------------------------------------------------------------
    desktop environment    -            GNOME2.0              -          GNOME3.0,KDE4.10
    -------------------------------------------------------------------------------------------------------------------
    database               -            mysql                 -          mariadb
    ------------------------------------------------------------------------------------------------------------------
    
    
                                    the commands's differences between RHEL6 & RHEL7
    -----------------------------------------------------------------------------------------------------------------
                           -        RHEL6                                -          RHEL7
    -------------------------------------------------------------------------------------------------------------------
    GUI tool               -       system-config-*                       - gnome-control-center
    -------------------------------------------------------------------------------------------------------------------
    network tool           -  nmcli,nmtui,nm-connection-editor           - system-config-network
    -------------------------------------------------------------------------------------------------------------------
    language tool          -       system-config-language                - localectl
    -------------------------------------------------------------------------------------------------------------------
    time tool              -      system-config-date,date                - timedatactl,date 
    -------------------------------------------------------------------------------------------------------------------
    time synchronise       -      ntpdate,/etc/ntp.conf                  - ntpdate,/etc/chrony.conf
    -------------------------------------------------------------------------------------------------------------------
    keyboard tool          -      system-config-keyboard                 - localectl
    -------------------------------------------------------------------------------------------------------------------
    service list           -       service --status-all                  - systemctl -t status --state=active
    -------------------------------------------------------------------------------------------------------------------
    add service            -         chkconfig --add                     - systemctl daemon-reload
    -------------------------------------------------------------------------------------------------------------------
    get runlevel           -         runlevel                            - systemctl get-default
    -------------------------------------------------------------------------------------------------------------------
    change runlevel        -         init,runlevel                       - systemctl isolate name.target,init,runlevel
    -------------------------------------------------------------------------------------------------------------------
    log file               -         /var/log/                           - /var/log/,journalctl
    -------------------------------------------------------------------------------------------------------------------
    single mode            -         1,s,/bin/bash                       - rd.break,init=/bin/bash
    -------------------------------------------------------------------------------------------------------------------
    shutdown system        -         shutdown                            - systemctl shutdown
    -------------------------------------------------------------------------------------------------------------------
    poweroff host          -         poweroff                            - systemctl poweroff
    -------------------------------------------------------------------------------------------------------------------
    halt the system        -         halt                                - systemctl halt
    -------------------------------------------------------------------------------------------------------------------
    reboot the system      -         reboot                              - systemctl reboot
    -------------------------------------------------------------------------------------------------------------------
    modify runlevel        -         /etc/inittab                        - systemctl set-default
    -------------------------------------------------------------------------------------------------------------------
    configure grub         -         /boot/grub/grub.conf                - /etc/default/grub,grub2-mkconfig,grub-set-default
    -------------------------------------------------------------------------------------------------------------------
    install packages       -   yum install,yum groupinstall              - yum install,yum group install 
    -------------------------------------------------------------------------------------------------------------------
    package information    -   yum info,yum groupinfo                    - yum info,yum group info
    -------------------------------------------------------------------------------------------------------------------
    lvm management         -   vgextend,lvextend,resize2fs               - vgextend,lvextend,xfs_growfs
    -------------------------------------------------------------------------------------------------------------------
                           -     /etc/sysconfig/network                  - /etc/hosts
    network configuration  -     /etc/hosts                              - /etc/resolve.conf
                           -     /etc/resolve.conf                       - /etc/sysconfig/network-scripts/ifcfg*
                           -     /etc/sysconfig/network-scripts/ifcfg*   - 
    -------------------------------------------------------------------------------------------------------------------
    hostname               - hostname,/etc/sysconfig/network             - hostnamectl,/etc/hostname,nmcli
    -------------------------------------------------------------------------------------------------------------------
    ip addr configure      - ip a,ifconfig,brctl                         - ip a,nmcli dev show,teamdctl,brctl bridge
    -------------------------------------------------------------------------------------------------------------------
    port listing           - ss,netstat,lsof                             - ss,lsof
    -------------------------------------------------------------------------------------------------------------------
    
    
