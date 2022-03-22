+++
title = "认识PEM文件"
description = "PEM 是什么, 我们有哪些日常使用的命令和 PEM 相关"
date = "2022-03-22T22:30:13+08:00"
lastmod = "2022-03-22T22:30:13+08:00"
tags = ["PEM", "证书", "openssl"]
dropCap = false
displayCopyright = false
gitinfo = false
draft = false
toc = true
+++

## 说明
PEM (`Privacy Enhanced Mail`的缩写)文件最初是为了确保电子邮件安全而发明的, 现在它是一个互联网安全标准. PEM 文件是 X.509 证书、CSR(`certificate signing request`) 和加密密钥的最常见格式.

## 什么是 PEM 文件
PEM 文件是一个文本文件, 文件中包含一个或多个采用 Base64 ASCII 编码的条目, 每个条目都有纯文本的页眉和页脚
> 例如: `--BEGIN CERTIFICATE--` 和 `--END CERTIFICATE--`

PEM 是一种容器格式, 可能只包括公共证书, 也可能包括整个证书链, 包括公钥、私钥和根证书.

PEM可以有多种扩展名
> 例如: .pem、.key、.cer、.cert 等

典型的 PEM 文件是： 
- `key.pem`: 包含私有加密密钥 
- `cert.pem`: 包含证书信息

## PEM 文件格式
页眉和页脚用于标识文件的类型, 但并非所有 PEM 文件都需要它们. 如下说明几种不同类型的PEM文件

| **页眉页脚内容** | **文件类型** |
|:--- | :---: |
|`—–BEGIN CERTIFICATE REQUEST—–`<br>....<br>`—–END CERTIFICATE REQUEST—–`|CSR文件|
|`—–BEGIN RSA PRIVATE KEY—–`<br>....<br>`—–END RSA PRIVATE KEY—–`|私钥文件|
|`—–BEGIN CERTIFICATE—–`<br>....<br>`—–END CERTIFICATE—–`|证书文件|

如果 PEM 文件包含 SSL 证书链, 则格式如下所示:
```text
—–BEGIN CERTIFICATE—–
//end-user
—–END CERTIFICATE—–
—–BEGIN CERTIFICATE—–
//intermediate
—–END CERTIFICATE—–
—–BEGIN CERTIFICATE—–
//root
—–END CERTIFICATE—–
```

## 文件示例
如下示例是一个私钥 pem 文件:
```text
—–BEGIN PRIVATE KEY—–
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDBj08sp5++4anG
cmQxJjAkBgNVBAoTHVByb2dyZXNzIFNvZnR3YXJlIENvcnBvcmF0aW9uMSAwHgYD
VQQDDBcqLmF3cy10ZXN0LnByb2dyZXNzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD
…
bml6YXRpb252YWxzaGEyZzIuY3JsMIGgBggrBgEFBQcBAQSBkzCBkDBNBggrBgEF
BQcwAoZBaHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3Nvcmdh
z3P668YfhUbKdRF6S42Cg6zn
—–END PRIVATE KEY—–
```

如下是根证书 pem 文件的示例:
```text
# Trust chain root certificate

—–BEGIN CERTIFICATE—–
MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkG
YWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJHbG9iYWxT
aWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDaDuaZ
…
jc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavp
38NflNUVyRRBnMRddWQVDf9VMOyGj/8N7yy5Y0b2qvzfvGn9LhJIZJrglfCm7ymP
HMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4A==
—–END CERTIFICATE—–
```

## 其他
- 使用 `openssl` 命令检查 PEM 证书文件

    `openssl` 是一个开源命令行工具, 通常用于生成私钥、创建 CSR、安装我们的 SSL/TLS 证书以及识别证书信息.
    ```bash
    ## 命令格式是: openssl x509 -text -in server.pem -noout
    
    # 示例: 
    $ openssl x509 -in /etc/pki/fwupd/LVFS-CA.pem -text -noout                                
    Certificate:                                                                         
        Data:
            Version: 3 (0x2)
            Serial Number: 1 (0x1)
            Signature Algorithm: sha256WithRSAEncryption
            Issuer: CN = LVFS CA, O = Linux Vendor Firmware Project
            Validity
                Not Before: Aug  1 00:00:00 2017 GMT
                Not After : Aug  1 00:00:00 2047 GMT
            Subject: CN = LVFS CA, O = Linux Vendor Firmware Project
            Subject Public Key Info:
                Public Key Algorithm: rsaEncryption
                    RSA Public-Key: (3072 bit) 
                    Modulus:
                        00:b5:f5:17:1f:73:70:0c:9c:d6:ca:19:0f:c8:f7:
                        ......
                  Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Subject Alternative Name: 
                URI:http://www.fwupd.org/, email:sign@fwupd.org
            X509v3 Extended Key Usage: 
                Code Signing
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign 
            X509v3 Subject Key Identifier:  
                B1:8D:EA:E4:23:A7:7E:09:8E:B5:EE:31:E0:6A:DD:9E:34:37:65:AC
            X509v3 CRL Distribution Points: 

                Full Name:
                  URI:http://www.fwupd.org/pki/

    Signature Algorithm: sha256WithRSAEncryption
         ......
    ```
 
- `ssh` 使用的 PEM
    
    PEM 文件也用于 ssh, 如果我们执行过 `ssh-keygen` 用来配置 `ssh` 的免密, 则 `~/.ssh/id_rsa` 就是一个 PEM 文件, 只是没有扩展名.
    
    我们可以在 `ssh` 中使用 `-i` 标志来指定我们要使用新密钥而不是 `id_rsa`：
    ```bash
    # 生成一对新公私钥对
    $ ssh-keygen -f ./test_rsa -t rsa -P ''
    Generating public/private rsa key pair.
    Your identification has been saved in ./test_rsa
    Your public key has been saved in ./test_rsa.pub
    The key fingerprint is:
    SHA256:r+NkIS+z7wZcjYjsQ1q/mWDkBkbSXjE1W7mS74W69AE liawne@ruiwen
    The key's randomart image is:
    +---[RSA 3072]----+
    | .  ooo ..       |
    |. o .. +.        |
    | + o ..o +       |
    |  + * + + .      |
    | . O oE+S.       |
    |  . B ++oo.      |
    |   o o+B=..      |
    |     .=B+o       |
    |      o**.       |
    +----[SHA256]-----+
  
    # 使用新生成的密钥对配置免密
    $ ssh-copy-id -i ./test_rsa.pub pi@192.168.8.106
    /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "./test_rsa.pub"
    /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    ......
  
    # 使用对应的私钥连接服务器
    $ ssh -i ./test_rsa pi@192.168.8.106
    Last login: Tue Mar 22 23:10:35 2022 from 192.168.8.102
    ......
    ```
