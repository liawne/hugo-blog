+++
title = "uefi/bios，gpt/mbr的一些概念"
description = "介绍uefi和bios的差别，gpt和mbr的差别，以及他们互相之间的关系"
date = "2022-05-25T23:03:13+08:00"
lastmod = "2022-05-25T23:03:13+08:00"
tags = ["uefi", "bios", "gpt", "mbr"]
dropCap = false
displayCopyright = true
displayExpiredTip = true
gitinfo = false
draft = false
toc = true
+++

## \# 说明
不清楚 `legacy bios` 和 `uefi`，`gpt` 和 `mbr` 的区别，理一下他们的来源和互相之间的关系  

## \# BIOS 和 UEFI
`BIOS` 和 `UEFI` 是计算机的两个固件接口，它们充当操作系统和计算机固件之间的解释器。这两个接口都用于在计算机启动时初始化硬件组件并启动存储在硬盘驱动器上的操作系统。
- `BIOS` 通过读取硬盘驱动器的第一个扇区来工作，该扇区存储了要初始化的下一个设备地址或要执行的代码。BIOS 还会选择启动操作系统时需要初始化的引导设备。
- `UEFI` 执行相同的任务，但实现略有不同。它将有关初始化和启动的所有信息存储在 `.efi` 文件而不是固件中。此文件存储在名为 `ESP` 的特殊分区内。ESP 分区还包含计算机上安装的操作系统的引导加载程序。

### \# BIOS
**什么是 BIOS**  
`BIOS` 是 `Basic Input/Output System` 的简称，也称为`系统 BIOS`、`ROM BIOS` 或 `PC BIOS`。它是嵌入在计算机主板芯片上的固件。  
`BIOS` 固件预装在 `PC` 的主板上; 它是一个非易失性固件，这意味着它的设置即使在断电后也不会消失或改变。

**BIOS 怎么工作**  
当计算机启动时，`BIOS` 会加载并唤醒计算机的硬件组件，确保它们正常工作，然后加载引导加载程序来初始化已安装的操作系统。  
`BIOS` 必须在 `16` 位处理器模式下运行，并且只有 `1 MB` 的空间可以执行。在这种情况下，`BIOS` 无法同时初始化多个硬件设备，从而导致初始化所有硬件接口和设备时时间更长，启动过程变慢。

**选择 BIOS 的场景**  
用户选择 `Legacy BIOS` 而不是 `UEFI` 的一些可能的原因：
- 如果不需要对计算机的运行方式进行精细控制，`BIOS` 是理想的选择。
- 如果只有小型驱动器或分区，`BIOS` 也足够了。尽管许多较新的硬盘驱动器超过了 `BIOS` 的 `2 TB` 限制，但并非每个用户都需要这么大的空间。
- `UEFI` 的`安全启动（secure boot）`功能可能会导致 `OEM` 制造商阻止用户在其硬件上安装其他操作系统。如果使用 `BIOS`，则可以回避这个问题。
- `BIOS` 提供对接口中硬件信息的访问，但并非所有的 `UEFI` 实现都可以这样做。可以在操作系统中访问硬件规格。

{{<notice tip>}}一些计算机用户使用 UEFI 启动，但仍将其称为"BIOS"，这容易让人感到困惑。即使 PC 使用术语 "BIOS"，如今购买的大多数现代 PC 都使用 UEFI 固件而不是 BIOS。为了区分 UEFI 和 BIOS，也有人将 UEFI 固件称为 UEFI BIOS，而 BIOS 则称为 Legacy BIOS 或传统 BIOS。{{</notice>}}

### \# UEFI
**什么是 UEFI**  
`UEFI（Unified Extensible Firmware Interface）`：统一的可扩展固件接口，它是 `EFI（Extensible Firmware Interface）` 的逻辑继承。

**UEFI 发展历史**  
在90年代中期，英特尔意识到 `IBM BIOS（Basic Input/Output System（基本输入/输出系统））` 样式固件接口有其固有的限制。这些限制并不影响普通用户，但它们使生产高性能服务器变得困难。于是，英特尔于1998年开始开发 `EFI` 规范。2005年，英特尔停止了 `EFI` 规范的开发，并在维持所有权的同时将其捐赠给了 `Unified EFI Forum`。英特尔继续向供应商许可 `EFI` 规范，但 `UEFI` 规范归论坛所有。  

**UEFI 的优势**  
`UEFI` 的设计目标是在未来完全替换传统 `BIOS`，其具有许多传统 `BIOS` 无法实现的新特性和优势，部分突出的优势如下：
- 模块化设计
- 同 `CPU` 架构解偶（`Itanium, x86, x86-64, ARM Arch32, Arm Arch64`）
- 兼容 `BIOS` 接口和传统启动方式
- 从大于 `2TiB` 的磁盘引导的能力（注意`2TB`和`2TiB`之间的差异）
- `UEFI` 支持超过 `4` 个具有 `GUID` 分区表的主分区。
- 使用 `UEFI` 固件的计算机的启动过程比 `BIOS` 更快，`UEFI` 中的各种优化和增强功能可以让系统更快地启动。
- `UEFI` 支持安全启动`（secure boot）`，这意味着可以检查操作系统的有效性，以确保没有恶意软件篡改启动过程。
- `UEFI` 支持 `UEFI` 固件本身的联网功能，有助于远程故障排除和 `UEFI` 配置。
- `UEFI` 具有更简单的图形用户界面，并且还具有比传统 `BIOS` 更丰富的设置菜单。

{{<notice warning>}}并非所有计算机或设备都支持 `UEFI`。要使用 `UEFI` 固件，磁盘上的硬件必须支持 `UEFI`。此外，系统盘需要是 `GPT` 盘。{{</notice>}}

**ESP 特殊分区**  
- `UEFI` 将有关初始化和启动的所有信息存储在 `.efi` 文件中，该文件存储在称为 `EFI 系统分区 (ESP(EFI System Partition))` 的特殊分区上。  
- `ESP` 分区包含计算机上安装的操作系统的引导加载程序。
- `ESP` 分区使用 `FAT32` 格式进行格式化，具有特定的分区类型代码 `EF00`，而不是通常用于 `FAT32` 驱动器的 `0x0C`。  
- 许多操作系统会因为它被视为系统卷而将其隐藏。
- 在启动时，主板上的 `UEFI` 兼容固件会扫描所有磁盘以查找 `ESP`，并在其中查找这些可执行文件，在此过程中，`MBR` 的硬编码引导范例不再适用。
- 正是因为有了这个分区，`UEFI` 可以直接启动操作系统，省去 `BIOS` 自检过程，这也是 `UEFI` 启动速度更快的一个重要原因。

## \# MBR 和 GPT
`MBR（主引导记录（Master Boot Record）)` 和 `GPT（GUID 分区表（GUID Partition Table））` 是各种硬盘驱动器的两种分区方案，其中 `GPT` 是较新的标准。对于这两种分区方案，引导结构和数据处理方式都是不同的，速度不同，使用要求也不同。

### \# MBR
**什么是 MBR**  
- `MBR` 代表的是 `Master Boot Record`，主引导分区的意思。  
- `MBR` 只是硬盘的一部分，在它上面可以找到有关磁盘的所有信息;。
- `MBR` 存储在`引导扇区（boot sector）`，它包含了分区类型的详细信息以及引导计算机操作系统时所需的代码。  
- `MBR` 可以有很多不同的形式，但所有这些形式的共同点是它们都具有 `512` 字节的大小，都存储了分区表和引导代码（通常称为引导加载程序）。

**MBR 的特点**  
如下：
- `MBR` 磁盘上可能的最大主分区数为 `4`，其中每个分区需要 `16` 字节空间，这使得所有分区总共需要 `64` 字节空间。
- `MBR` 分区可以分为三种类型——主分区、扩展分区和逻辑分区。如上所述，它只能有 4 个主分区。扩展分区和逻辑分区克服了这一限制。
- `MBR` 中的分区表仅包含有关主分区和扩展分区的详细信息。此外，重要的是要了解数据不能直接保存在扩展分区上，因此需要创建逻辑分区。
- 一些最新类型的 `MBR` 还可能添加了磁盘签名、时间戳和有关磁盘格式化的详细信息。
- 与可以支持四个分区的旧版本的 `MBR` 不同，最新版本能够支持多达 `16` 个分区。由于所有 `MBR` 的大小不超过 `512` 字节，因此使用 `MBR` 格式化的磁盘有 `2TB` 的可用磁盘空间上限（有些硬盘也有 `1024` 字节或 `2048` 字节扇区，但这会导致磁盘速度出现问题，因此不是明智的选择）。
- 它兼容所有版本的 `Windows（32 位和 64 位）`。

**MBR 构成**
- 传统`MBR`构成图
![classic MBR](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220526-2335.png)
- 以`windows`上的`MBR`为例说明扩展分区
![扩展分区](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220528-1203.png)

**MBR 的限制**
如下：
- `MBR` 风格的分区只能使用不超过 `2TB` 的磁盘空间。
- 它最多只能有 `4` 个主分区。如果创建主分区后有未分配的空间，我们可以通过创建扩展分区来使其可用，其中可以创建各种逻辑分区。  

由于 `MBR` 的这些限制，用户通常会选择不同的分区样式。除了 `MBR` 之外，最常见的分区样式之一是 `GPT`。

### \# GPT
**GPT 的来源**  
同样的，英特尔对基于 `BIOS` 和 `MBR` 的引导模式不满意，于是开发了 `GPT` 规范。

**什么是 GPT**
- `GPT` 代表的是 `GUID（全局唯一标识符（globally unique identifier）） Partition Table`，`GUID分区表`的意思。
- `GPT` 是最新的磁盘分区方式，被称为 `MBR` 的继承者。
- `GPT` 在整个驱动器上维护有关分区组织和操作系统启动代码的数据。这样可以确保在任何分区损坏或删除的情况下，仍然可以检索数据，并且引导过程不会出现问题。这也是 GPT 优于 MBR 的原因之一。

**GPT 构成**
- 纵向分布视图
![GPT 构成1](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220526-2341.png)
- 横向视图
![GPT 构成2](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/05/20220528-1212.png)  

通过以上图片，我们可以看到GPT磁盘分为三个部分：
- `主分区表（Primary Partition Table）`：这是保护 MBR、GPT 标头分区和分区表所在的位置。
- `普通数据分区（Normal Data Partition）`：这是用于存储个人数据的位置。
- `备份分区表（Back up Partition Table）`：此位置用于存储 GPT 标头和分区表的备份数据。这在主分区表损坏的情况下很有用。

**GPT 的特点**  
- 与 `MBR` 相比，`GPT` 磁盘提供了更多的存储空间。用户可以创建多个分区。 `GPT` 磁盘系统可以创建多达 `128` 个分区。
- `GPT` 格式的磁盘分区，分区表数据恢复更容易。
- `GPT` 可以运行检查以确保数据安全。它使用 `CRC` 值来检查数据的安全性。如果数据损坏，它可以检测损坏并尝试从磁盘上的其他位置检索损坏的数据。与 `MBR` 相比，这使得 `GPT` 成为更可靠的选择。
- `GPT` 中包含的一项非常有趣的功能称为 `保护性MBR(Protective MBR)`。此 `MBR` 仅考虑整个驱动器上的一个分区。在这种情况下，当用户尝试借助旧工具管理 `GPT` 时，该工具将读取分布在驱动器上的一个分区。这是保护性 MBR 确保旧工具不会认为 `GPT` 驱动器没有分区，并防止旧工具使用新 `MBR` 对 `GPT` 数据造成任何损坏。保护性 `MBR` 保护 `GPT` 数据，使其不会被删除。
- 与将一部分引导代码放入引导扇区的 `MBR` 不同，`GPT` 将引导代码和分区表分离了。

**GPT 的限制**  
如果必须将 `GPT` 用作引导驱动器，则系统需要基于 `UEFI`。在基于 `BIOS` 的系统中，`GPT` 驱动器不能用作主驱动器。

用户选择 `MBR` 而不是 `GPT` 的唯一原因是当操作系统安装在基于 `BIOS` 的系统上并且驱动器将用作引导驱动器时。

### \# GPT vs MBR
下面是 MBR 和 GPT 之间的综合比较表，该表突出显示了 MBR 和 GPT 之间的主要区别。  
| **比较点** | **MBR** | **GPT** |
|:------------:|:--------------:|:---:|
| 主分区数     |     `4`         | `可达到128` |
| 最大分区大小  |     `2 TB`      | `18 EB` |
| 最大硬盘大小  |     `2 TB`      | `18 EB` |
| 安全性       |     `无`        | `CRC 值用于确保数据安全`<br>`备份 GUID 分区表` |
| 适用于       |     `BIOS`      | `UEFI` |
| 分区名称     |     `存储在分区中`      | `具有唯一的 GUID 和 36 个字符的名称` |
| 支持多重启动  |     `支持较差`      | `引导加载程序条目位于不同的分区中` |
| 数据还原     |     `较难`      | `相对简单` |
| 数据损坏     |     `无法检测数据损坏`      | `易于检测` |
| 分区寻址方法  |     `CHS（Cylinder Head Cycle）`或<br>`LBS（逻辑块寻址 Logical Block Addressing）`| `LBA 是寻址分区的唯一方法` |
| 大小        |     `512 字节`      | `每个 LBA 512 字节`<br>`每个分区条目为 128 字节` |
| 分区类型代码  |     `1字节`      | `使用 16 字节 GUID` |
| 稳定性      |     `与 GPT 相比，稳定性较差`      | `提供更多安全性` |
| 可启动版本的操作系统 |     `引导 32 位操作系统`      | `引导 64 位操作系统` |
| 存储      |     `只支持 2TB 的容量`<br>`磁盘大小 >2TB 被标记为未分配且无法使用`      | `可支持容量达944万TB的磁盘` |
| 性能      |     `与 GPT 相比，性能较低`      | `如果支持 UEFI 引导，则提供卓越的性能` |

上表列出了 `MBR` 与 `GPT` 的性能。基于上述几点，如果支持 `UEFI` 引导，`GPT` 在性能方面要优越得多。它还提供了稳定性和速度的优势，并增强了硬件的性能，这主要归功于 `UEFI` 的结构。

### \# 一些疑问
- MBR和GPT可以混用吗？
  > 只有在支持 `GPT` 的系统上才能混用 `MBR` 和 `GPT`。  
  > `GPT` 需要 `UEFI` 接口，当系统支持 `UEFI` 时，引导分区必须位于 `GPT` 磁盘上，这一点很重要;但是，其他硬盘可以是 `MBR` 或 `GPT`。

- UEFI 可以启动 MBR 吗？
  > `UEFI` 可以同时支持 `MBR` 和 `GPT`。  
  > `UEFI` 与 `GPT` 配合使用可以很好地摆脱 `MBR` 的分区大小和数量限制。

- 如果将 GPT 转换为 MBR，是否有可能丢失数据？
  > 如果通过工具将磁盘分区格式从 `GPT` 转换为 `MBR` 或从 `MBR` 转换为 `GPT`，则需要在转换前删除所有分区。

## 其他
### \# 相关名词解释
**Secure Boot**
- 安全启动`（secure boot）`是什么：是可执行文件的签名，如果签名与已在 `UEFI` 固件中注册的签名匹配，则主板将允许它启动; 否则不允许启动。

### \# 参考内容
[https://fossbytes.com/uefi-bios-gpt-mbr-whats-difference/](https://fossbytes.com/uefi-bios-gpt-mbr-whats-difference/)
[https://www.partitionwizard.com/partitionmagic/uefi-vs-bios.html](https://www.partitionwizard.com/partitionmagic/uefi-vs-bios.html)
[https://www.freecodecamp.org/news/mbr-vs-gpt-whats-the-difference-between-an-mbr-partition-and-a-gpt-partition-solved/](https://www.freecodecamp.org/news/mbr-vs-gpt-whats-the-difference-between-an-mbr-partition-and-a-gpt-partition-solved/)
[https://www.maketecheasier.com/differences-between-uefi-and-bios/#:~:text=BIOS%20uses%20the%20Master%20Boot,physical%20partitions%20to%20only%204.](https://www.maketecheasier.com/differences-between-uefi-and-bios/#:~:text=BIOS%20uses%20the%20Master%20Boot,physical%20partitions%20to%20only%204.)
[https://en.wikipedia.org/wiki/Master_boot_record](https://en.wikipedia.org/wiki/Master_boot_record)
[https://www.partitionwizard.com/partitionmagic/uefi-vs-bios.html](https://www.partitionwizard.com/partitionmagic/uefi-vs-bios.html)
[https://www.softwaretestinghelp.com/mbr-vs-gpt/](https://www.softwaretestinghelp.com/mbr-vs-gpt/)
[https://www.alphr.com/mbr-vs-gpt/#:~:text=The%20main%20difference%20between%20MBR,boot%20off%20of%20GPT%20drives.](https://www.alphr.com/mbr-vs-gpt/#:~:text=The%20main%20difference%20between%20MBR,boot%20off%20of%20GPT%20drives.)