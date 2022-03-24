+++
title = "Openssl Toolkit使用"
description = "一种openssl 工具集, 满足各种证书生成和转换需求"
date = "2022-03-24T22:37:26+08:00"
lastmod = "2022-03-24T22:37:26+08:00"
tags = ["openssl", "证书", "CA"]
dropCap = false
displayCopyright = false
gitinfo = false
draft = true
toc = true
+++

> 工具下载: [openssl-toolkit](/uploads/openssl-toolkit.sh)

## 说明
`openssl-toolkit` 是一个封装好的 `openssl` 命令行工具(`shell` 脚本), 可以用来执行证书管理等相关任务.

## 工具使用
下载完成后, 上传文件至可执行 `shell` 脚本的环境
```bash 
## 执行脚本, 查看帮助/说明内容
$ bash openssl-toolkit.sh
      ____                __________     ______          ____    _ __
     / __ \___  ___ ___  / __/ __/ / ___/_  __/__  ___  / / /__ (_) /_
    / /_/ / _ \/ -_) _ \_\ \_\ \/ /_/___// / / _ \/ _ \/ /  '_// / __/
    \____/ .__/\__/_//_/___/___/____/   /_/  \___/\___/_/_/\_\/_/\__/
        /_/


        Submenu options:

        1. Create certificates
        2. Convert certificates

        3. Locally verify certificates
        4. Externally verify certificates (s_client)

        5. Output certificate information

        q. Quit

        Selection:
```

**支持的功能如下:**
- `Create certificates`(**创建证书**):
  - Self-Signed SSL Certificate (key, csr, crt)
    
    > 生成自签名 SSL 证书
    ```bash 
    ## 实际使用命令为
    openssl genrsa -passout pass:${pass} -des3 -out server.key 2048;
    openssl req -sha256 -new -key server.key -out server.csr -passin pass:${pass};
    openssl x509 -req -sha256 -days $certDays -in $csr -signkey $key -out $crt -passin pass:${pass}
    openssl rsa -in $key -out nopassword.key -passin pass:${pass}
    ```
  - Private Key & Certificate Signing Request (key, csr)
    
    > 创建私钥和证书签名请求(`CSR`)
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - PEM with key and entire trust chain
    
    > 生成包含整个证书链和 `key` 的 `PEM` 文件
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```

- `Convert certificates`(**格式转换**):
  
  [不同格式证书说明](need.todo2)
  - PEM -> DER
    
    > `PEM` 转换为 `DER`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - PEM -> P7B
    
    > `PEM` 转换为 `P7B`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - PEM -> PFX
    
    > `PEM` 转换为 `PFX`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - DER -> PEM
    
    > `DER` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - P7B -> PEM
    
    > `P7B` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - P7B -> PFX
    
    > `P7B` 转换为 `PFX`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - PFX -> PEM
    
    > `PFX` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```

- `Verify certificates`(**证书校验**):
  - CSR is a public key from the private key
    
    > 校验 `CSR` 是来自私钥的公钥
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - Signed certificate is the public key from the private key
    
    > 校验签名证书是来自私钥的公钥
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - Chain file applies to the signed certificate (complete ssl chain)
    
    > 校验证书链适用于签​​名证书（包含完整的 `ssl` 链）
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - Check date validity of certificates
    
    > 检查证书的日期有效性
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```

- `Test ssl server`(**测试 `ssl` 服务器**):
  - SSL Certificate handshake
    
    > `SSL` 证书能否完成握手连接
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - SSL Server date validity
    
    > 检查 `SSL` 服务器日期有效性
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - Permitted Protocols
    
    > 检查允许的协议
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```

- `Output certificate information`(**输出证书信息**):
  - Output the details from a certifticate sign request
    
    > 从证书签名请求中(`CSR`)输出详细信息
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
  - Output the details from a signed certificate
    
    > 从签名证书中输出详细信息
    ```bash 
    ## 实际使用命令为
    openssl xxxx
    ```
    
本文内容参考自: [OpenSSL Toolkit](https://community.microfocus.com/cyberres/edirectory/w/edirectorytips/25358/openssl-toolkit)