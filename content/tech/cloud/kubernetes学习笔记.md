+++
title = "Kubernetes学习笔记"
description = "k8s学习笔记记录"
draft = true
date = "2022-03-13T22:04:30+08:00"
lastmod = "2022-03-13T22:04:30+08:00"
tags = ["cloud", "docker", "云原生", "kubernetes"]
dropCap = false
displayCopyright = false
gitinfo = false
toc = true
+++

## Devops核心要点及kubernetes架构概述 ##
1, ansible:应用编排工具
- 可以安装,配置应用
- 可以依照playbook来配置有依赖关系的应用程序

2, docker的编排工具,docker的编排不能再采用传统意义应用的方式来编排,因为接口已经发生了变化
- docker呼唤面向容器的新式编排工具的实现
  - docker编排三剑客
    1,docker compose(主要功能是编排,可以单机,可以资源池 )
    2,docker swarm(跨机执行,能够将多个主机集成为一个资源池,可以算作一个集群管理工具 )
    3,docker machine(新扩入集群的主机,能够将一个主机迅速初始化加入到一个docker swarm集群中) 
- mesos: IDC的OS,能够将一个IDC所提供的所有硬件资源提供的计算资源统一分配,是一个资源分配工具
    1,marathon: 提供面向容器编排的框架
- kubernetes,现有占据80%以上的份额

3, 新概念
- MicroServices: 微服务, 应用不再分层,将应用拆解成一个个的微服务,很可能当前使用的一个应用以- 微服务体现的话,需要拆解成上百个的微服务,彼此之间互相写作
- CI: continious intergration持续集成
- CD: continious delivery持续交付
- CD: continious deployment持续部署

4, 容器技术的出现,使得DevOps的落地实现成为了可能
```bash
trigger(commit, push and so on) --> CI --> CD(交付) --> CD(部署)

                    DevOps progress
-------------------------------------------------------------->
# DevOps中异构环境的问题,因为容器的出现而可以解决
```

5, 容器编排的必要性
- 通过微服务的方式来发布应用,一个应用几百个微服务构成,出故障是必然的,每天出现多少次,人为修复是不可能的,所以需要容器编排工具来完成这个工作
- 因为容器技术的出现,使得DevOps得以落地; 因为DevOps的落地,使得容器编排技术成为一个底层技术
- devops是一种文化, 打破dev和ops的隔阂, 使传统手工方式自动化完成

6, openshift
- redhat使用的paas工具是openshift, 
- openshift的核心是kubernetes, kubernetes还没达到paas这个层面;
- openshift可以理解为kubernetes的发行版(linux的发行版有ubuntu,redhat,debian等) 
- kubernetes实现的东西很底层,如果要具有paas的功能,还需要自行安装很多工具;openshift则提供了一个完整的工具链供客户使用

7,kubernetes是站在borg肩膀上的开源软件
- kubernetes相关功能
    - 自动装箱: 基于资源依赖及其他约束能够自动完成容器的部署而且不影响其可用性
    - 自动修复: 自我修复,自愈能力,容器的轻量,能够在挂掉之后很短的时间内拉起;
      - 容器方式拉起的应用处理逻辑也发生了变化, 一个应用崩掉了, 可以直接kill掉容器进程, 然后重新拉起来
      - 有了k8s这种编排工具之后, 我们关注的更多的是群体, 而不再是个体了
    - 自动实现水平扩展: 在资源足够的情况下,可以自动扩展节点
    - 服务发现和负载均衡: 
      - 当在k8s上运行了很多应用程序(微服务)后, 服务可以通过服务发现自动找到依赖到的服务
      - 每一种服务拉起来之后,自动做负载均衡
    - 自动发布和回滚
    - 密钥和配置管理
    - 存储编排: 使存储卷实现动态供给(某一个容器需要用到存储卷时,根据容器自身的需求创建能够满足其需要的存储卷)
    - 批处理执行
- kubernetes就是一个集群, 组合多台主机的资源,组合成一个大的资源池,并统一对外提供存储,计算的集群
- kubernetes是一个有中心节点架构的集群系统, master-nodes模型

8, kubernetes编排的应用
  - 非云原生应用的启动方式: entrypoint中定义一个脚本,脚本能够接受用户传递给容器的参数,脚本将其转化为应用可读取的配置信息;应用再通过配置文件来读取配置
  - 云原声的启动方式: 基于环境变量的方式传递参数, 修改环境变量, 容器应用自动通过读取环境变量实现不同动作
    - 通过kubernetes来编排的应用需要是云原声应用, 非云原声的应用可能会碰到各种各样的问题(比如配置文件保存在哪里等等) 

9, kubernetes工作
- 用户在kubernetes上运行一个应用
  - 客户的请求先发给master(启动容器的请求)
  - master当中存在一个调度器,分析各个node现有的可用资源状态
  - 找出一个最佳适配运行客户容器的节点
  - 节点上的容器引擎来运行这个容器(先检查本地是否有镜像,没有镜像则从harbor上拉取镜像)
- 怎样保证kubernetes实现自愈能力的
  - kubelet监控节点上应用容器的状态,确保容器应用的状态正常(节点正常的情况下)
  - 控制器确保容器是否正常,如果不正常,控制器上报给master,由master重新调度新的(节点宕机的场景);
    - kubernetes有一大堆的控制器来监控容器是否正常;
    - 控制器在本地不断的loop,来监控各个容器的状态; 确保处于用户期望的状态,或者说是移向用户期望的状态
  - 控制器有问题了, 在master上有controller-manager,用来监控控制器的状态；控制器有冗余(3个master, 做了高可用, 三个节点中只有一个可用)
  - master是整个集群的大脑, 有三个核心组件: 
    - apiserver: 负责接受并处理请求的
    - scheduler: 调度容器创建的请求
    - controller-manager: 确保控制器状态正常(确保容器状态正常的控制器只是众多控制器中的一种)
- kubernetes并不直接调度容器,调度的最小对象是pod(可以理解为容器的外壳,给容器做了一层抽象的封装)
  - kubernetes做了一个逻辑组件叫pod,在pod内用来运行容器
    - 一个pod内可以包含多个容器,共享的namespace有NET,IPC,UTS,另外三个互相隔离(USER,MNT,PID)
    - pod对外像一个虚拟机
    - 同一个pod中的容器共享存储卷; 存储卷可以理解为不属于容器, 而是属于pod
- kubernetes上运行的node, 负责运行由master指派的各种任务,最核心的就是一pod形式去运行容器的

10, kubernetes区分
- master:
  - apiserver
  - scheduler
  - controller manager
- node:
  - kubelet: node的核心组件, 用来同集群交互, 尝试拉起容器等
  - docker: 容器引擎,不一定是docker,只是docker最流畅
  - kube-proxy: 随时与apiserver通信, 监控本地相关资源的情况,当发生变化通知到apiserver后,apiserver生成一个通知事件,可以被所有关联的组件接收到
    - service的创建需要kube-proxy生成相应规则
    - service的更新,也需要kube-proxy更新相应的规则

## kubernetes基础概念 ##
1, pod说明
- pod:
  - kubernetes的最小调度单元
  - pod很重要的一个属性: label,众多元数据中的一个,用于区分筛选pod,负责筛选的是label selector
- 人为分类(官方未做分类):
  - 自主式pod: 由kubelet监控管理,在节点故障时,pod消失,无法再自动创建
  - 控制器管理的pod: 控制器存在多种

2, 控制器
- ReplicationController: 副本控制器
- ReplicaSet: 
- Deployment:
  - HPA: 自动水平扩展功能(horizontal Pod Autoscaler), 通过监控当前CPU或者内存等资源的消耗情况(比如定义不能超过60%), 来自动添加pod, 当负载下降后还可以自动减少,但有一个最少值
- StatefulSet:
- DaemonSet:
- Job, cronjob

3, Service
- pod时时在变化,在容器时代,不能再按照以前通过写配置文件,固定IP地址或者主机名的方式来访问固定的Pod了; 客户端发送一个请求过来,路由到相应的pod是怎么实现的
  - 在client和目标Pod之间,存在一个中间层,这个中间层就是service
  - service固定IP地址或者端口, 在没有手动删除的情况下, service不会消失
  - 客户端访问service, service将相应的请求路由到后端对应的pod
  - service通过label去匹配pod的
  - service不是什么应用程序,也不是实体组件,是iptables的DNAT规则(现已修改为ipvs规则)
  - 客户端访问service名称,然后被kubernetes中的dns服务解析,得到service的地址,再由service的DNAT转发到相应的pod(现已修改为ipvs规则);
  - service只是用来调度分配到各个pod上的流量的
  - 创建了service之后,其相应的iptables/ipvs规则会反映在所有的node主机上

4, 云计算平台和kubernetes天生具有良好的兼容性
- 物理机在kubernetes创建服务时,若需要对外提供服务,需要有loadbalance,但已经不属于kubernetes的管理范围
- 云平台则不一样,aws,阿里云等可以提供lbaas的接口,在kubernetes需要创建对外提供服务的service时,可以通过调用云平台的lbaas接口来创建loadbalance

5, kubernetes涉及的网络
- 三类网络
  - pod使用的网络(pod网络): 供pod通信使用,各个pod共享同一个network namespace,网络可以互相ping通,类似于一个正常的IP地址
  - Service使用的网络(集群网络): 和pod的地址是不同网段的,虚拟的网络,只存在于iptables或者ipvs中
  - 各个node的网段(节点网络): 各个节点各自的IP地址
- 三类通信
  - 同一个pod内的多个容器间通信: 直接是哟你lo就可以
  - 各个pod之间的通信: 与docker之间的网络通信实现方式不同(两层NAT转发实现跨主机的容器网络通信), kubernetes是直接通过pod地址来通信的(各个pod的地址唯一)
    - 使用物理机桥接网络, 但当集群中pod数多起来之后,广播量太大,无法承受
    - 使用overlay network(叠加网络),使得虽然跨主机,但仍像工作在同一个二层网络中;叠加网络可以实现二层广播,也可以实现三层广播(隧道)
  - pod与service的通信:
    - service的iptables/ipvs规则是反映在所有的节点上的,当一个容器需要去访问一个service时,容器的请求转发给docker0网桥就可以了
- 网络功能kubernetes不提供,需要依赖插件来完成
    - 网络插件提供商最少要提供两个功能:节点网络, 集群网络
    - kubernetes通过CNI插件体系来接入外部的网络服务解决方案
      - flannel: 支持网络配置,叠加网络实现,相对简单
      - calico: 既支持网络配置,也支持网络策略,三层网络隧道实现,相对复杂
      - canel: 这种方式是上面两种方式的折中
      - 各个CNI插件可以作为容器托管在集群上,也可以作为守护进程在各个节点上运行

6, kubernetes使用到的证书
- etcd是整个集群的核心,整个集群的状态信息都在etcd当中存储,故etcd需要做高可用
  - etcd是restful风格的集群:通过http/https通信,kubernetes使用的是https方式
  - etcd是一个端口用于集群内部通信,一个端口用于对客户端提供服务
- 证书使用
  - etcd集群内部通信,点对点通信https,需要使用一个证书
  - etcd对客户端(集群中的apiserver)提供服务,使用另外一套证书(一套ca)
  - kubernetes的apiserver需要使用https对外提供服务,一套证书(不要与etcd使用同一套ca来签署)
  - apiserver与kubelet,kube-proxy等通信,每个组件需要单独的证书
  - 手动部署k8s集群,大概需要手动部署5套ca左右(etcd之间,apiserver访问etcd,client访问apiserver,apiserver与内部集群间的通信,还剩一个需要确认)

## 使用kubeadm安装kubernetes ##
- 常用kubernetes安装方式
  - 使用rpm包的方式安装或者源码编译的方式安装: 这种方式很麻烦,为了提高安全性,需要手动提供很多套的ca和证书
  - 使用kubeadm部署
    - 每个节点都需要安装docker和kubelet,并确保两个服务都已经运行起来
    - 选择一个节点初始化为master后, 将controller-manager,api-server,etcd,kube-schedule以pod的方式运行在master节点上
    - 其他node上以pod的方式运行kube-proxy服务
    - 所有的组件pod都是static pod(静态pod)
- 使用kubeadm安装kubernetes的步骤
  - master, nodes:安装kubelet, kubeadm, docker
  - 在master节点上执行kubeadm init来完成集群初始化
    - 先决条件预捡
    - 生成证书,私钥,配置文件
    - 生成每一个静态pod的清单文件
    - 完成部署addon
  - 在各个node节点上执行kubeadm join
    - 检查先决条件,看能否满足需求
  - 查看github上kubeadm的designvx_xx.md文档说明即可
  - 解决docker下载kubernetes镜像需要翻墙的问题
    - 在安装完docker之后,修改/usr/lib/systemd/system/docker.service文件, 增加一个Environment="HTTPS_PROXY=http://www.ik8s.io:10080"
    - 在下载完kubernetes相关镜像之后,将上面的内容注释掉,正常使用国内源即可

## kubernetes应用快速入门 ##
- kubectl就是apiserver的客户端程序
  - 通过连接master节点上的apiserver
  - apiserver也是整个kubernetes集群的唯一管理入口,kubectl就是这个管理入口的客户端工具,完成kubernetes上各种对象的增删改查等基本操作

- kubectl命令
  - run子命令
    - 通过run命令生成一个deployment或者job来管理相应容器
        ```bash
        kubectl run nginx --image=nginx
        kubectl run nginx-deploy --image=nginx:1.14-alpine --port=80 --replicas=3 --dry-run=true
        ```
    - 传递给pod的命令默认方式是后接--
    - run命令是通过生成deployment或者job,再拉起pod,不是直接直接创建的pod

- kubernetes网络分配
  - pod可分配网段是10.244.0.0/16,各个节点分配一个24位掩码的子网,比如node2分配到的是10.244.2.0/24
  - pod的客户端主要有两类: 其他pod,外部访问
  - 使用kubectl expose来创建service(视频是1.11版本的), 指定端口用于转发
    ```
    - 参考示例: kubectl expose deployment nginx-deploy --name=xxx --port=xxx --target-port=xxx --protocol=xxx
    - 外部访问转发: --> service_ip:service_port --> pod_ip:pod_port
    - 参数type:
        ClusterIP:仅供集群内部使用,是默认的类型
        NodePort:可用于将svc暴露给外部使用,默认会自动生成一个随机端口映射至内部各个节点,网关地址,外部访问时,可以随机使用任意一个node的该端口
    ```
  - service给有生命周期的pod提供了一个固定的访问入口
    - service是iptables或者ipvs规则
    - 访问svc的端口,都会被调度至该svc用Label Selector关联到的各个pod后端

- 命令使用
  - 使用watch方式监控资源变化
    - kubectl get pods -w
  - 动态扩展pod数(也可以缩减)
    - kubectl scale --replicas=x TYPE NAME
  - 动态更新容器镜像
    - kubectl set image TYPE NAME CONTAINER_NAME_1=CONTAINER_IMAGE_1 ...
    - 使用kubectl rollout status TYPE NAME 来查看滚动更新的状态
    - 使用kubectl rollout undo TYPE NAME来回滚更新
    - kubectl rollout --help可以查看支持的各个命令
  - k8s支持自动扩缩容,但是需要有监控系统,这个需要单独部署
  - kubectl run/expose只是一个简单的命令,用于测试学习等场景;因为这些单独的命令无法实现全部功能,无法实现全部定制,实际使用应该基于yaml的配置文件来实现

## 05-kubernetes资源清单定义入门 ##
- kubernetes有一个RESTful风格的API,把各种操作对象都一律当作资源来管理,通过标准的http请求方法(GET,PUT,POST,DELETE)_来完成操作
  - 但是通过相应的命令(kubectl run/expose/edit/get),反馈到命令行上

- 资源实例化之后变成对象
  - 工作资源负载型对象(workload): Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronjobSet, Deployment, StatefulSet, DaemonSet, Job, Cronjob
  - 服务发现及服务均衡: Service, Ingress
  - 配置与存储: Volume(有状态的持久存储需求的应用必须要用到的),CSI(存储卷),
    - configmap:为了配置容器化应用必然会用到的
    - secret:保存敏感数据
  - 集群级资源:
    - namespace
    - node
    - role
    - clusterrole
    - rolebinding
    - clusterrolebinding
  - 元数据型资源
    - HPA
    - Podtemplate
    - LimitRange

- 资源清单定义
  - 运行中的pod为例,说明各个字段的作用
    - apiVersion定义,有两个部分组成,分别是group名+version(组名+版本号),如果group省略,则表示属于core(核心组)
      - apiVersion: v1 --> apiVersion: core/v1
      - 组管理的好处:某一组的改动,只改一组就行,不影响其他组的使用; 一个组的多个版本号还可以并存
      - version一般有3个:alpha(内测版本), beta(公测版本), stable(稳定版本)
        > 不同版本支持的可嵌套字段可能是不一样的
    - kind定义,确定资源类别,用来指明实例化成一个资源对象时使用
    - metadata,元数据,
    - spec(specification):用来定义接下来需要创建的资源应该具有什么样的特性,或者应该满足什么样的规范;基本是一个资源对象中最重要的字段
    - status,与spec对应,显示当前的状态,spec是预期值,status是实际值,当实际值与预期值不符时,会向预期值靠拢

- apiversion仅接收json格式的资源定义,yaml格式提供配置清单,apiserver可自动将其转为json格式,而后再提交

- 大部分资源的配置清单组成有5部分(一级字段):
    - apiversion
        - pod是最核心的资源,所以属于核心群组vxxxx;deployment,replicaset属于应用程序管理的核心资源,他们属于app/vxxxxx
        - kubectl api-versions即可获取
    - kind:资源类别
    - metadata:元数据
        - name: 在同一类别中,那么必须是唯一的,同一命名空间中
        - namespace: name需要受限于namespace,是kubernetes的概念,和操作系统的namespace要区分好
        - labels: 标签
        - annotations: 资源注解
    - spec:最重要的一个字段,定义期望状态(desired state)
        - 不同资源类型,spec部分需要嵌套的内容不同
    - status:当前状态(current state),本字段由kubernetes集群维护,不能人为定义
    - 各个字段的man文档可以使用如下命令查看:
        ```
        kubectl explain KIND.OBJECT.xxx.xxx --> kubectl explain pod.metadata/pod.spec.containers.livenessprobe
        # explain输出的内容中,设定格式有
        #   <string>: 字串
        #   <[]string>: 字串列表,字串类型的数组
        #   <Object>: 嵌套类型的三级字段
        #   <map[string]string>: 键值组成的映射
        #   <[]Object>: 对象列表
        #   -required-: 表示该字段必须存在
        ```

- 每个资源的引用PATH:
  - /api/GROUP/VERSION/namespaces/NAMESPACE/TYPE/NAME

- 一个pod定义的yaml文件示例
    ```
    pod-demo.yaml:
    --------------------------------------------------------------
    apiVersion: v1
    kind: Pod
    metadata:
      name: pod-demo
      namespace: default
      labels:                           ---> labels字段是属于map(kv字典), 这里也可以写成labels: {"app:myapp", "tire:frontend"}
        app: myapp
        tire: frontend                  ---> labels字段可以有多个label map
    spec:
      containers:                       ---> containers是对象列表格式
      - name: myapp
        image: ikubernetes/myapp:v1
      - name: busybox                   ---> 多个容器存在于一个pod中, 用于辅助主容器工作, 这种方式称为边车模型
        image: busybox:latest
        command:                        ---> command字段属于列表, 这里也可以写成command: ["/bin/sh", "-c", "sleep 3600"]; command用于覆盖容器的默认命令
        - "/bin/sh"
        - "-c"
        - "sleep 3600"
    --------------------------------------------------------------
    ```
    - 基于这个yaml文件可对资源进行管理
      - kubectl create -f pod-demo.yaml: 根据这个文件内容,创建相应的资源
      - kubectl delete -f pod-demo.yaml: 根据yaml文件内容,删除相应的资源
      - kubectl apply -f pod-demo.yaml: 根据yaml修改内容,滚动更新相应的资源
    - 问题:
      - 使用pod-demo.yaml文件定义的pod,没有控制器被创建,都是我们自己去控制了,这种形式的pod称之为<自主式Pod资源>
        - 有控制器的pod,一删除会被自动创建
        - 我们这里创建的这个pod,一删除就被删除了

- 在定义pod资源时, spec字段常用的字段有哪些
  - spec.containers: <[]object>
    - name: <string>
    - image: <string>
    - imagePullPolicy: <string>,有Always,Never,IfNotPresent这几个值可选择;
      - 如果镜像标签选择了latest,则使用的是Always
      - 其他策略时默认为IfNotPresent;
      - 该字段不能更改
      - 各个策略的优缺点:
        - always(好处是可以一直拿到最新的镜像,确保拿到最新的发布镜像;缺点是会占用带宽,而且拉起时间长);
        - never: 可以节省带宽和时间,但可能本地就有的基础镜像是被修改过的,有问题的,也无法被更新
        - ifnotpresent: 折中的一种方式,当不可用的时候才去拿镜像
    - ports: <[]object>,informational功能,只是提供信息而已,和docker中的暴露端口不一样
      - containerPort可以有多个
      - containerPort以列表的方式展示
    - command/args: <[]string> 
      - args:entrypoint arguments;
        - 当这个参数没有提供时,容器镜像的默认ENTRYPOINT会被使用
        - 变量引用的格式是\$(variable_name),需要特别注意;若自己需要使用命令替换方式,则格式为\$\$(variable_name),作为逃逸
      - command:entrypoint array;
        - 当这儿参数没有被使用时,容器镜像的默认CMD会被使用
        - 给定的内容不会在shell中执行,所以若需要在shell中执行内容,需要自己在内容中增加'/bin/sh', '-c', 'contents'
        - 变量引用的格式是$(variable_name),需要特别注意;若自己需要使用命令替换方式,则格式为$$(variable_name),作为逃逸
      - docker中entrypoint/cmd和k8s中command/args的结合使用
        ```
        ------------------------------------------------------------------------------------------------------------------------
        | 描述                                 |    Docker filed name               |   Kubernetes field name                  |
        ------------------------------------------------------------------------------------------------------------------------
        | The command run by the container     |    Entrypoint                      |   command                                |
        ------------------------------------------------------------------------------------------------------------------------
        | The arguements passwd to the command |    Cmd                             |   args                                   |
        ------------------------------------------------------------------------------------------------------------------------
        # 资源清单中没有给容器提供command和args,则容器镜像的默认entrypoint和cmd生效
        # 资源清单中给容器提供了command但没有args时,则仅仅command生效,容器镜像默认的entrypoint和cmd被忽略
        # 资源清单中给容器提供了args但没有command时,则容器镜像的Entrypoint使用给定的args
        # 资源清单中给容器提供了command和args,则command使用给定的args生效
        ```
  - 有些字段是可以被修改,而且改完之后能即时生效的;有些字段不能修改
  - docker中如果同时存在entrypoint和cmd时,cmd将作为参数被传递给entrypoint

- 使用kubectl管理资源有三种用法
  - 命令式用法: kubectl run/expose/edit xxxx
  - 配置清单式用法: 本章讲解的内容(命令式资源清单)
  - 也是使用命令清单,但用法不同(声明式资源清单)

## kubernetes Pod控制器应用进(一) ##
- label是kubernetes上很有特色的一个功能
  - 提升资源管理效率,在同一套集群中,k8s的资源量上去后,需要被管理的资源通过label可以被快速识别
  - 当给资源配置了label之后,还可以通过label来查看,删除等管理操作
  - 所谓的label就是附加在对象上的一个键值对
  - 一个资源上可以存在多个label,每个label都可以被标签选择器进行匹配度检查,从而完成资源挑选
  - 标签可以在资源创建时配置,也可以在资源创建之后配置
  - key=value,键值对的长度都不能超过63个字符
    ```
    # key:字母,数字,_,-,.
    # value:可以为空,只能字母或数字开头及结尾
    ```
  - 直接给资源打标签
    ```
    # kubectl label pods pod-demo release=canary
    # kubectl label pods pod-demo release=stable --overwrite
    ```

- 标签选择器的类型
  - 等值关系的标签选择器,可以使用'=','==','!='
    ```
    kubectl get pods -l release=canary
    kubectl get pods -l release=stable
    kubectl get pods -l release!=stable(没有相应的键同样包含在条件内)
    kubectl get pods -l release=stable,app=myapp
    ```
  - 集合关系的标签选择器
    ```
    # KEY in (VALUE1,VALUE2,...)
    kubectl get pods -l "release in (canary,alpha,beta)"
    # KEY notin (VALUE1,VALUE2,...)
    kubectl get pods -l "release notin (canary,alpha,beta)"
    # KEY(存在某个键)
    # !KEY(不存在某个键)
    ```

- deployment,service等资源通常支持通过以下字段来匹配相应的标签
    ```
    # matchLabels: 直接给定键值
    # matchExpression: 基于给定的表达式来定义使用标签选择器
    # 
    # 方式为:{key: "KEY", operator:"OPERATOR", values:[VAL1,VAL2,...]}
    #   操作符常用的有:
    #   In, Notin: values字段的值必须为非空列表
    #   Exists, NotExists: value字段的值必须为空列表
    ```

- node也可以打标签
  - 创建pod时,有一个字段叫做nodeSelector<map[string]string>(节点标签选择器),可以用来选择在哪些标签节点上运行
    ```
      - spec:
          containers:
          - xxx
          - xxx
          选择节点可以有以下方式:
          ----------------
          nodeSelector:
            disktype: ssd
          ----------------
          nodeName:
            node02
    ```

- annotation:
  - 与labels的区别在于,他不能用于挑选资源对象,仅用于为对象提供"元数据";
    - 这些"元数据"在某些时候可能被某些程序用到,并且很重要
    - annotation中键值的大小可大可小,不再受字符的限制
    - 查看annotations可以通过describe来查看

- pod的生命周期:
    - 如下图:
    ```
      --------------------------------------------------------------------
      |                           Pod                                    |
      --------------------------------------------------------------------
     a-->| --------                   |
         | |init c|                   |
         | --------                   |
         |         --------           |
         |         |init c|           |
         |         --------           |
         |                 --------   |
         |                 |init c|   |
         |                 --------   |
         |                            |         -----------------   
         |                            |         |liveness probe |   
         |                            |         -----------------   
         |                            |         -----------------   
         |                            |         |readiness probe|   
         |                            |         -----------------   
         |                            |  ------------          ----------   
         |                            |  |post start|          |pre stop|
         |                            |  ------------          ----------   
         |             b              |  
         |<-------------------------->|  --------------------------------   
         |                            |  |        main container        |   
         |                            |  --------------------------------   
         |                            |<---------------------------------
         |                            |               c
         |                            |
    ```
    - 各个阶段说明
    ```
        1,a是pod中创建容器前的初始化动作(entrypoint中定义的初始化动作内容),这里需要一点时间,时间可能比较短,可以忽略
        2,在主容器启动前,可能需要做一些环境设定和配置,此处有一系列的init container,专门用于给主容器做环境初始化动作(初始化容器是需要串行执行的)
        3,等所有的初始化容器完成之后,拉起主容器
        4,主容器退出,pod的生命周期结束
        5,在主容器的启停前后,可以存在两个分别称为post start和pre stop的
            - post start:在启动完执行一次后自动退出
            - pre stop: 在结束前执行一次的动作
            - 钩子触发,用于开始前的预设,结束前的清理
        6,还可以做health check,一般来说,在post start执行完成之后,可以做两类检测(k8s支持两类)
            - liveness probe : 存活状态检测,检测主进程是否还在运行(避免已经进入死循环还不退出的情况),主容器是否处于运行状态
            - readiness probe: 就绪状态检测,容器中的主进程是否已经准备就绪并可以对外提供服务
            - 两种probe都支持三种探测行为:
                a,执行自定义命令
                b,向指定的套接字发请求(向指定端口发请求)
                c,向指定的http发请求(向指定url发送GET请求)
            - kubernetes和docker的探测差别:docker不需要探测liveness,因为只有一个容器,kubernetes需要,因为一个pod中可能有多个容器存在
    ```
    - pod的各种状态:
      - pending:挂起,启动条件没满足,调度未完成(比如已经创建,但没有适合运行的节点,即没有符合nodeselector或者nodename的节点)
      - running:运行中
      - failed:失败
      - succeed:成功,存在时间很短
      - unknown:所有信息的获取都是apiserver和各个节点上的kubelet交互获取的,如果kubelet出故障了,就有可能出现unknown的状态
    - 用户创建pod时会经历哪些阶段:
      - 用户创建pod时,发送请求给到apiserver
      - apiserveri将创建请求的目标状态保存到etcd中
      - apiserver请求schedule,进行调度,并将调度的结果保存到etcd中(运行在哪个节点上)
      - etcd状态信息更新后,调度节点上的kubelet通过与apiserver通信,获取到有一些任务给到自己了
      - 此时此kubelet通过apiserver拿到此前用户提交的创建清单,根据清单在当前节点上运行这个pod
      - 启动后,pod有一个当前状态,再将当前pod状态发回给apiserver
      - apiserver再次将该信息存入etcd中
    - pod生命周期中的重要行为:
      - 初始化容器
      - 容器探测
        - liveness probe
        - readiness probe
      - pod在kubernetes上代表的是运行的程序或者进程,给用户提供服务的主要单位,当pod发生故障时,需要让其平滑终止,才能确保数据不会丢失
        - 在给pod发送delete请求时,pod给各个容器发送TERM信号,容器自己停止(给予一个宽限期)
        - 超过宽限期后,发送kill信号,杀掉进程
    - restartPolicy:
      - Always: 总是重启
      - OnFailure: 只有状态为错误时才重启 
      - Never: 从不重启
      - 一旦一个pod被调度到某个节点以后,只要这个节点在,这个pod就不会被重新调度了;pod里面的容器只会被重启,如果容器不满足启动条件,则容器会一直在那不断重启(取决于策略定义)

## kubernetes Pod控制器应用进阶(二) ##
- 探针(kubectl explain pods.spec.containers.livenessProbe)
    ```
    # a, ExecAction
    # b, TCPSocketAction
    # c, HTTPGetAction
    ------------------------------------------------------------------------
    Exec:
    ------------------------------------------------------------------------
    apiVersion: v1
    kind: Pod
    metadata:
      name: liveness-probe-pod
      namespace: default
    spec:
      containers:
      - name: liveness-probe-container
        image: busybox:latest
        imagePullPolicy: IfNotPresent
        command: ["/bin/sh", "-c", "touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 3600"]
        livenessProbe:
          exec:
            command: ["test", "-e", "/tmp/healthy"]
          initialDelaySeconds: 1
          periodSeconds: 3
    ------------------------------------------------------------------------
    TCPSocket:
    ------------------------------------------------------------------------
    apiVersion: v1
    kind: Pod
    metadata:
      name: liveness-httpget-pod
      namespace: default
    spec:
      containers:
      - name: liveness-httpget-container
        image: ikubernetes/myapp:v1
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1
          periodSeconds: 3
    ```

- 就绪性探测使用的场景
  - pod提供的服务是通过war来展开的
    - war包很大,容器运行之后,war包展开还需要10s钟时间
    - 容器运行之后,service作为服务入口,通过标签选择器已经关联到该pod了(请求可以调度到该pod了)
    - 新分配到这个pod的请求因还未准备好,所以会出现请求失败的情况

- 使用pod提供服务,必须要用到liveness probe和readiness probe
    ```
    # readiness probe
    ------------------------------------------------------------------------
    TCPSocket:
    ------------------------------------------------------------------------
    apiVersion: v1
    kind: Pod
    metadata:
      name: readiness-probe-pod
      namespace: default
    containers:
    - name: readiness-probe-container
      image: ikubernetes/myapp:v1
      imagePullPolicy: IfNotPresent
      ports:
      - name: http
        containerPort: 80
      readinessProbe:
        httpGet:
          port: http
          path: /index.html
        indexDelaySeconds: 1
        periodSeconds: 3
    ```

- lifecycle(postStart,preStop)字段,启动停止钩子函数
    ```
    # a, ExecAction
    # b, TCPSocketAction
    # c, HTTPGetAction
    ------------------------------------------------------------------------
    postStart:
    ------------------------------------------------------------------------
    apiVersion: v1
    kind: Pod
    metadata:
      name: poststart-pod
      namespace: default
    spec:
      containers:
      - name: poststart-container
        image: ikubernetes/myapp:v1
        imagePullPolicy: IfNotPresent
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "sed -i 's/MyApp/Home_Page/' /usr/share/nginx/html/index.html"]
        command: ["nginx"]
        args: ["-g", "daemon off", "-c", "/etc/nginx/nginx.conf"]                                         ----------->注意不要和lifecycle的command有强依赖
    ```
