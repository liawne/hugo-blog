+++
title = "vim 打开 txt 文件乱码"
description = "vim 打开 windows 上编辑的 txt 文件格式乱码"
date = "2022-03-20T10:18:17+08:00"
lastmod = "2022-03-20T10:18:17+08:00"
tags = ["vim", "解码"]
dropCap = false
displayCopyright = false
gitinfo = false
draft = false
toc = true
+++
## 背景
使用 vim 打开 windows 上编辑的 txt 文件, 出现下面的乱码现象
![vim显示乱码](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/04/20220403-2144.png)
在 manjaro 的 kate 中打开, 可以正常显示
![kate正常显示](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/04/20220403-2145.png)

## 定位
判断出 vim 编辑乱码的原因是因为 vim 的编码方式问题, 需要调整 vim 的相关配置

对于 vim 的配置文件 ~/.vimrc 或者 /etc/vimrc, 若不清楚配置项的具体作用, 最好不要调整. 建议自行测试配置内容的作用, 确定最合适自己的配置.

/etc/vimrc 是全局配置, ~/.vimrc 是用户配置, 我们只需要调整~/.vimrc 即可

先了解一下 vimrc 中涉及到格式编码的几个配置项

进入 vim 命令行界面, `shift + :` 进入到 `COMMAND mode`, 输入 `help encoding` 查找编码相关的帮助内容 :
 ```angular2
$ vim
:help encoding
```
 
## 配置介绍
|配置项|配置说明|
|:---|:---|
|encoding|vim 内部使用的字符编码方式, 主要包括 buffer, 寄存器, 表达式中的字符, 保存在viminfo中的内容等. 对 MS-windows 来说默认是 UTF-8, 对其他的系统则通过`$LANG`读取或者是`latin1`. 默认情况下, encoding 是设置成当前 `locale` 的值, 如果 `encoding` 没有设置成 `locale` 的 `$LANG`, 则 `termencoding` 必须设置成 `locale` 的 `$LANG`用于转换终端显示的文本内容|
|fileencoding| 设置当前打开文件的 `buffer` 文件字符编码方式, 默认为空值；当 `fileencoding` 的设置和 `encoding` 设置值不一样时, vim 编辑后保存文件时会将文件保存为 `fileencoding` 设置的字符编码方式；`fileencoding`为空时, 使用`encoding` 的编码方式保存文件. 当需要以特定编码方式读取一个文件时, 配置`fileencoding`不生效, 需要使用`++enc` 参数来设置, 也有一种特殊情况, 当`fileencodings`的值是空时, `fileencoding`的值才会被使用|
|fileencodings| vim设置fileencoding的顺序列表, 默认值为`ucs-bom(Byte Order Mark)`, vim 打开文件时会按照`fileencodings` 的内容, 依次检测罗列的字符编码方式, 当一项编码解析出现错误时, 会自动使用下一项进行探测. 最终确认一项可用时, 会将`fileecoding` 设置为该值; 若都失败, `fileencoding` 则设置为空, 则当前打开的缓冲文件使用默认的 `encoding` 设置内容进行编码. `fileencodings` 只对已存在文件生效, 新文件使用的是`fileencoding`配置值, 也就是说新文件和空文件使用的编码方式可能是不一样的. |
|termencoding| vim 所在的命令行终端的字符编码方式, 键盘打印输出和显示器显示内容的编码, 对 GUI 环境来说, 则只对 键盘产生的数据生效, GUI 使用`encoding`的配置值; `termencoding`的默认值是空值. |


相关参数罗列完成后, 整理一下 vim 打开文件的过程, 这几项参数在这个过程中的作用
- vim 使用配置文件(/etc/vimrc 或 ~/.vimrc)中 `encoding` 配置的编码方式打开文件, 设置缓冲区文件, viminfo 文件, 寄存器等内容的编码方式
- 因为是已经存在的文件, vim 加载`fileencodings` 内容, 逐项检测配置的编码方式, 若存在无错误的项时, 分配该编码方式的值给`fileencoding`
- 对比`encoding` 和 `fileencoding` 的值, 若不相同, 则使用`fileencoding` 的编码方式重新编码缓冲区文件内容, 最终体现为当前终端打开文件的显示内容. 转换的动作是由`iconv()` 完成的, 或者在`COMMAND mode`指定 `charconvert` 进行转换
- 编辑完文件后保存, 还是对比 `encoding` 和 `fileencoding` 的内容, 不一致就将缓存区文件内容以 `fileencoding` 设置的编码方式更新到文件中
> `encoding` 和 `fileencoding`的转换可能导致文件内容部分丢失, 当 `encoding` 是 `utf-8` 或者其他 `Unicode` 编码, 转换的内容很大概率还是能够被反解析成相同的内容; 但当 `encoding` 不是 `utf-8`时, 一些字符可能在转换的过程丢失

## 修复
先确认当前文件的编码方式:
```bash
$ chardetect make\ iso\ image.txt 
make iso image.txt: GB2312 with confidence 0.99
```

配置文件增加相应的编码方式: 
```bash
## 编辑 ~/.vimrc, 增加相应的配置项
$ vim ~/.vimrc
$ cat ~/.vimrc | egrep 'fileencoding|encoding'
set fileencodings=utf-8,ucs-bom,gb2312,cp936
```

重新打开文件, 显示正常