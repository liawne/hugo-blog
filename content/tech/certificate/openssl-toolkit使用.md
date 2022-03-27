+++
title = "Openssl Toolkit使用"
description = "一种openssl 工具集, 满足各种证书生成和转换需求"
date = "2022-03-24T22:37:26+08:00"
lastmod = "2022-03-24T22:37:26+08:00"
tags = ["openssl", "证书", "CA"]
dropCap = false
displayCopyright = true
gitinfo = false
draft = false
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
    自签名证书的优点:  
    免费(自己生成),随时签发,方便(证书过期处理),对于测试场景
    ```bash 
    ## 实际使用命令为, 以下 ${pass} 为执行过程中需要手动输入的密码

    $ openssl genrsa -passout pass:${pass} -des3 -out server.key 2048
    # 1. 生成密钥文件
    #    genrsa : 生成一个 rsa key 文件, 也即密钥文件, 此处只会生成私钥文件, 不会生成公钥, 因为公钥提取自私钥
    #    -passout: 对生成的 RSA 秘钥文件施加密码保护, 结合 pass 使用
    #    pass:${pass} : ${pass} 为交互输入时给定的密码, 这里作用是设置私钥的密码
    #    -des3: Triple-DES Cipher, 指定加密私钥文件用的算法, 三重数据加密算法的意思, 对私钥加密密码 ${pass} 应用三次DES加密算法
    #    2048: 指生成多少位的私钥, 还可以为512/1024等
    
    $ openssl req -sha256 -new -key server.key -out server.csr -passin pass:${pass}
    # 2. 通过 server.key 私钥, 生成 server.csr 文件
    #    如果要一个 CA(Certificate Authority) 认证机构颁发 CRT 证书的话, 需要先提供一个 CSR(Certificate Signing Request) 请求文件.
    #    这个 CSR 请求文件中, 会包含公钥(Public Key), 以及一些申请者信息 (DN Distingusied Name).
    #    DN 信息中最重要的部分是 Common Name (CN), 需要与后续安放 CRT 证书的服务器 FQDN(Fully Qualified Domain Name) 完全一致才行. 
    #    openssl-toolkit 会在执行过程中要求输入 DN 信息, 请按实际情况填写相应内容.
    #    req: PKCS#10 X.509 CSR 管理相关
    #    -new: 生成一个新的 CSR 请求文件
    #    -key: 指定已有的私钥文件
    #    -passin: 指定私钥文件的加密密码

    $ openssl x509 -req -sha256 -days $certDays -in $csr -signkey $key -out $crt -passin pass:${pass}
    # 3. 根据已有的密钥文件 ${key} 和请求文件 ${csr} 来产生自签名 CRT(certificate) 证书文件
    #    -days: 指定生成的证书有效时间
    #    -in: 指定 CSR 请求文件
    #    -signkey: 指定私钥文件
    #    -out: 指定生生成的 CRT 文件
    
    $ openssl rsa -in $key -out nopassword.key -passin pass:${pass}
    $ cat nopassword.key ${crt} >> server.pem
    $ rm -f nopassword.key
    # 4. 生成 server.pem 文件, 保存不加密的私钥和 CRT 证书内容
    ```
  - Private Key & Certificate Signing Request (key, csr)
    
    > 创建私钥和证书签名请求(`CSR`)
    ```bash 
    ## 实际使用命令为, ${pass} 为执行时手动交互输入
    
    $ openssl genrsa -passout pass:${pass} -des3 -out server.key 2048
    # 1. 生成密钥文件
    
    $ openssl req -sha256 -new -key server.key -out server.csr -passin pass:${pass}
    # 2. 通过 server.key 私钥, 生成 server.csr 文件, 需要交互输入 DN 内容
    
    ```
  - PEM with key and entire trust chain
    
    > 生成包含整个证书链和 `key` 的 `PEM` 文件
    ```bash 
    ## 实际使用命令为
    
    # 生成 server.pem 文件, 保存不加密的私钥和 CRT 证书内容
    # 证书链有多少级, 则执行多少次如下内容, 注意区分每次的 ${key} 和 ${crt}: 
    $ openssl rsa -in $key -out nopassword.key -passin pass:${pass}
    $ cat nopassword.key ${crt} >> server.pem
    $ rm -f nopassword.key
    ```

- `Convert certificates`(**格式转换**):
  
  [不同格式证书说明](need.todo2)
  - PEM -> DER
    
    > `PEM` 转换为 `DER`
    ```bash 
    ## 实际使用命令为
    $ openssl x509 -outform der -in server.pem -out server.der
    # x509: X.509证书数据管理
    ```
  - PEM -> P7B
    
    > `PEM` 转换为 `P7B`
    ```bash 
    ## 实际使用命令为
    $ openssl crl2pkcs7 -nocrl -certfile server.pem -out server.p7b
    # crl2pkcs7: CRL to PKCS#7
    # -nocrl: 通常 CRL 包含在输出文件中. 使用此选项时, 输出文件中不会包含 CRL, 并且不会从输入文件中读取 CRL.
    # crl(Certificate Revocation List): 证书吊销列表, 是 PKI 系统中的一个结构化数据文件, 该文件包含了证书颁发机构 (CA) 已经吊销的证书的序列号及其吊销日期. 
    #                                   CRL 文件中还包含证书颁发机构信息、吊销列表失效时间和下一次更新时间, 以及采用的签名算法等.
    ```
  - PEM -> PFX
    
    > `PEM` 转换为 `PFX`
    ```bash 
    ## 实际使用命令为
    $ openssl pkcs12 -export -out server.pfx -inkey server.pem -in server.pem -certfile server.pem
    # pkcs12: PKCS#12 数据管理
    # 转换为 PFX 格式, 需要交互输入加密密码
    # -inkey: 私钥文件, 此处即 server.pem
    # -in: 指定要解析的 PKCS＃12 文件的文件名, 此处为 server.pem
    # -certfile: 要从中读取其他证书的文件名, 此处仍是 server.pem
    ```
  - DER -> PEM
    
    > `DER` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    $ openssl x509 -inform der -in server.der -out server.pem
    # x509: X.509 证书数据管理
    ```
  - P7B -> PEM
    
    > `P7B` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    $ openssl pkcs7 -print_certs -in server.p7b -out server.pem
    # pkcs12: PKCS#7 数据管理
    # -print_certs: 打印出文件中包含的任何证书或 CRL.
    ```
  - P7B -> PFX
    
    > `P7B` 转换为 `PFX`
    ```bash 
    ## 实际使用命令为
    $ openssl pkcs7 -print_certs -in server.p7b -out server.pfx
    ```
  - PFX -> PEM
    
    > `PFX` 转换为 `PEM`
    ```bash 
    ## 实际使用命令为
    $ openssl pkcs12 -in server.pfx -out server.pem -nodes
    # -nodes: 不加密私钥
    ```

- `Verify certificates`(**证书校验**):
  - CSR is a public key from the private key
    
    > 校验 `CSR` 是来自私钥的公钥
    ```bash 
    ## 实际使用命令为
    # -noout: 防止输出请求的编码版本.
    # -modules: 打印出请求中包含的公钥的模值.
    $ openssl rsa -noout -modulus -in server.key
    $ openssl req -noout -modulus -in server.csr
    ```
  - Signed certificate is the public key from the private key
    
    > 校验签名证书是来自私钥的公钥
    ```bash 
    ## 实际使用命令为
    # -noout: 防止输出请求的编码版本.
    # -modules: 打印出请求中包含的公钥的模值.
    $ openssl x509 -noout -modulus -in server.crt
    $ openssl rsa -noout -modulus -in server.pem
    ```
  - Chain file applies to the signed certificate (complete ssl chain)
    
    > 校验证书链适用于签​​名证书（包含完整的 `ssl` 链）
    ```bash 
    ## 实际使用命令为
    # verify: 证书校验
    # -purpose: 证书的预期用途. 如果未指定此选项, verify 将不会在链验证期间考虑证书用途.
    #           当前接受的用途是 sslclient、sslserver、nssslserver、smimesign、smimeencrypt.
    $ openssl verify -verbose -purpose sslserver -CAfile server.pem server.crt
    ```
  - Check date validity of certificates
    
    > 检查证书的日期有效性
    ```bash 
    ## 实际使用命令为
    # -noout: 防止输出请求的编码版本.
    # -enddate: 打印出证书的到期日期, 即 notAfter 日期.
    $ openssl x509 -checkend 7776000 -in server.crt
    $ openssl x509 -noout -enddate -in server.crt
    ```

- `Test ssl server`(**测试 `ssl` 服务器**):
  - SSL Certificate handshake
    
    > `SSL` 证书能否完成握手连接
    ```bash 
    ## 实际使用命令为
    $ openssl s_client -connect "$server":"$port"
    ```
  - SSL Server date validity
    
    > 检查 `SSL` 服务器日期有效性
    ```bash 
    ## 实际使用命令为
    $ openssl s_client -connect "$server" 2>&1 | openssl x509 -text | grep -i -B1 -A3 validity
    ```
  - Permitted Protocols
    
    > 检查允许的协议
    ```bash 
    ## 实际使用命令为
    $ timeout 3 openssl s_client -connect www.baidu.com:443 -no_ssl3 -no_tls1
    $ timeout 3 openssl s_client -connect www.baidu.com:443 -cipher NULL,LOW
    ```

- `Output certificate information`(**输出证书信息**):
  - Output the details from a certifticate sign request
    
    > 从证书签名请求中(`CSR`)输出详细信息
    ```bash 
    ## 实际使用命令为
    $ openssl req -text -in ${csr}
    ```
  - Output the details from a signed certificate
    
    > 从签名证书中输出详细信息
    ```bash 
    ## 实际使用命令为
    $ openssl x509 -text -in ${crt}
    ```
    
本文内容参考自: [OpenSSL Toolkit](https://community.microfocus.com/cyberres/edirectory/w/edirectorytips/25358/openssl-toolkit)