+++
title = "什么是PFX文件"
description = "PFX 是什么, 我们日常有哪些场景会使用到"
date = "2022-03-23T22:30:13+08:00"
lastmod = "2022-03-23T22:30:13+08:00"
tags = ["PFX", "证书", "openssl", "CA"]
dropCap = false
displayCopyright = false
gitinfo = false
draft = true
toc = true
+++

## 说明
`PFX` 文件是 `PKCS#12` 格式的证书, 它包含 `SSL` 证书（公钥）和相应的私钥. 
> `PKCS#12` 是一个容器标准, 它可以保存 `X509` 客户端证书和相应的私钥, 以及（可选）签署 `X509` 客户端证书的 `CA` 的 `X509` 证书

大多数证书颁发机构不会使用私钥颁发证书, 只会以 `.cer、.crt `和` .p7b `格式颁发或共享证书, 在绝大多数情况下, 这些格式的证书是不包含私钥的.

在有些场景下, 包含了私钥的 `.pfx` 格式证书才能满足需求, 比如: [kubernetes 作为 slave 对接 jenkins](https://need.todo1/)

## 证书和 PFX 文件的区别
- 证书名义上是公钥的容器. 证书内容包括公钥,服务器名称,有关服务器的一些额外信息及由证书颁发机构 (CA) 计算的签名. 当服务器将其公钥发送给客户端时, 实际上发送了它的证书和其他一些证书(包含签署其证书的 `CA` 的公钥的证书, 以及签署 `CA` 证书的 `CA` 的证书, 依此类推). 证书本质上是公共对象.
- `.pfx` 文件是一个 `PKCS#12` 存档：一个可以包含许多对象的包, 并且带有可选的密码保护；通常情况下, `PKCS#12` 存档包含证书（可能带有各种 CA 证书）和相应的私钥.

## PFX 的安全性
因为 `PFX` 包含了私钥, 在创建 `PFX` 时, 需要确保`PFX` 文件有设置密码, 避免证书被滥用. 设置的密码应该有一定复杂度, 不然设置了和没设置一样, 很容易被破解.

## PFX 的一些操作
- 使用 `openssl` 创建 `PFX`
  
  todo: 在 `openssl` 中, 必须在单个 `PFX (PKCS#12)` 文件中使用单独存储的密钥, 如下将密钥加入 PFX：
  ```bash
  # 两次输入密码后, 将在当前目录中创建 output.pfx 文件
  $ openssl pkcs12 -export -in linux_cert+ca.pem -inkey privateky.key -out output.pfx
  ```
- 从 `pfx` 文件中提取内容

  可以从 `pfx` 文件中提取出私钥等, 需要知道创建 `pfx` 文件时设置的密码.
  ```bash 
  # 第一步, 提取私钥; 系统会再次提示我们提供新密码来保护正在创建的 .key 文件
  $ openssl pkcs12 -in output.pfx -nocerts -out private.key
  
  # 第二步, 提取证书
  $ openssl pkcs12 -in output.pfx -clcerts -nokeys -out certificate.crt
  
  # 第三步, 解密私钥；输入第一步中创建的用于保护私钥文件的密码
  $ openssl rsa -in private.key -out decrypted.key
  ```
  
