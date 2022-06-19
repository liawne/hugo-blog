+++
title = "linux 文件锁"
description = "linux系统中的锁机制，以及flock命令和flock系统调用的说明"
date = "2022-06-15T22:53:59+08:00"
lastmod = "2022-06-15T22:53:59+08:00"
tags = ["linux", "lock", "flock"]
dropCap = false
displayCopyright = false
displayExpiredTip = false
gitinfo = false
draft = false
toc = true
+++
## \# 说明
### \# 背景
在多进程共享的应用程序中，通过`锁`来对同一个计算资源进行协同管理是非常常见的做法，无论在单机或多机的系统、数据库、文件系统中，都需要依赖`锁`机制来避免并发访问导致的不确定结果。  
文件锁是一种互斥机制，可确保多个进程以安全的方式读取/写入同一个文件。之所以要对这些多进程业务进行控制，是因为这些进程的调度是不可预期的，这种时序上的不可预期会对同一个文件资源产生竞争性访问，从而带来预期外的结果。  

### \# 中间更新问题（interceding update）
中间更新是并发系统中典型的竞争条件问题。
举例说明：
```text
假设有一个 account.dat 文件，用于存储帐户余额，其初始值为200。并发系统有两个进程来更新这个文件上的余额值：

进程 A : 读取当前值，减去 20，然后将结果保存回文件中。
进程 B : 读取当前值，加 80，然后将结果写回到文件中。

显然，在顺序执行完这两个进程后，我们期望文件具有以下值：200-20 + 80 = 260。
但是，如果进程的执行不是按预期的顺序执行，在以下这种情况下，可能会出现不一样的结果：

进程 A : 读取文件的当前值 200 ，并准备进行进一步的计算。
进程 B : 读取相同的文件并获得当前余额 200 。
进程 A : 计算 200-20 并将结果 180 保存回文件。
进程 B : 不知道余额已更新。因此，它仍将使用过时的值 200 计算 200 + 80，并将结果 280 写入文件。

结果，account.dat 文件中保存的余额就是 280 而不是预期值 260。
```

## linux 中的文件锁
文件锁定是一种限制在多个进程之间访问文件的机制。它只允许一个进程在特定时间访问文件，从而避免`中间更新（interceding update）`问题。  
`linux` 支持两种文件锁：
- `协同锁（Advisory Locking）`
- `强制锁（mandatory locks）`

### \# 协同锁
协同锁不是强制锁定方案。只有当参与的进程通过显式获取锁进行合作时，它才会起作用;否则，如果进程根本不知道锁，协同锁将被忽略。  

仍以之前的示例说明：
```text
假设文件 account.dat 仍然包含初始值 200。

备注：必须了解的是，协同锁不是由操作系统或文件系统设置的。因此即使进程 A 锁定了文件，进程 B 仍然可以通过系统调用自由地读取、写入甚至删除文件。如果进程 B 执行文件操作而不尝试获取锁，我们说进程 B 不与进程 A 合作。

协同锁是如何为协作进程工作的：
- 进程 A ：获取 account.dat 文件的排他锁，然后打开并读取该文件以获取当前值：200。
- 进程 B ：在读取文件之前尝试获取 account.dat 文件的锁（与进程 A 合作）。由于进程 A 已锁定文件，进程 B 必须等待进程 A 释放锁定。
- 进程 A ：计算 200-20 并将 180 写回文件。
- 进程 A ：释放锁。
- 进程 B ：现在获取锁并读取文件，并获得更新后的值：180。
- 进程 B ：启动其逻辑并将结果 260 (180+80) 写回文件。
- 进程 B ：释放锁，以便其他协作进程可以读取和写入文件。

后面可以看看使用 flock 命令实现。
```

### \# 强制锁
{{<notice warning>}}在了解强制文件锁定之前，需要了解的是：[Linux 的强制锁实现是不可靠的](https://man7.org/linux/man-pages/man2/fcntl.2.html)<br><br>因强制锁存在 BUG,且自 linux 4.5 以来,该功能被认为很少使用，
强制锁已成为可选功能，由配置选项（CONFIG_MANDATORY_FILE_LOCKING）配置; 后续将逐步删除该功能。{{</notice>}}

与协同锁不同，强制锁不需要参与进程之间的任何合作。一旦在文件上激活强制锁定，操作系统就会阻止其他进程读取或写入文件。要在 `linux` 中启用强制文件锁定，必须满足两个要求：
- 必须使用 `mand` 选项挂载文件系统
    ```bash
    $ mount -o mand FILESYSTEM MOUNT_POINT
    ```
- 必须打开 `set-group-ID` 位并关闭我们将要锁定的文件的 `group-execute` 位
    ```bash
    $ chmod g+s,g-x FILE
    ```

### \# 检查系统中的所有锁
检查正在运行的系统中当前获取的锁的两种方法：  
**lslocks**  
`lslocks` 命令是由 `util-linux` 软件包提供的，可用于所有 `Linux` 发行版，它可以列出我们系统中当前持有的所有文件锁。
```bash
[root@c7u3test1 ~]# lslocks 
COMMAND           PID  TYPE SIZE MODE  M START END PATH
lvmetad           463 POSIX   4B WRITE 0     0   0 /run/lvmetad.pid
crond             628 FLOCK   4B WRITE 0     0   0 /run/crond.pid
atd               629 POSIX   4B WRITE 0     0   0 /run/atd.pid
abrtd             606 POSIX   4B WRITE 0     0   0 /run/abrt/abrtd.pid
master           1512 FLOCK  33B WRITE 0     0   0 /var/spool/postfix/pid/master.pid
master           1512 FLOCK  33B WRITE 0     0   0 /var/lib/postfix/master.lock
```
在命令输出中，我们可以看到系统中所有当前被锁定的文件，以及每个锁的详细信息，比如锁的类型，哪个进程持有锁等。

**/proc/locks**  
`/proc/locks` 不是命令，它是 `procfs` 虚拟文件系统中的一个文件;该文件包含所有当前文件锁。`lslocks` 命令也依赖此文件来生成列表。
```bash
[root@c7u3test1 ~]# cat /proc/locks 
1: FLOCK  ADVISORY  WRITE 1512 fd:00:34534423 0 EOF
2: FLOCK  ADVISORY  WRITE 1512 fd:00:1284 0 EOF
3: POSIX  ADVISORY  WRITE 606 00:12:15127 0 EOF
4: POSIX  ADVISORY  WRITE 629 00:12:15111 0 EOF
5: FLOCK  ADVISORY  WRITE 628 00:12:15087 0 EOF
6: POSIX  ADVISORY  WRITE 463 00:12:12033 0 EOF
```
选取第一行来了解锁信息在 `/proc/locks` 文件系统中是如何组织的：
```text
1:  FLOCK  ADVISORY  WRITE 1512 fd:00:34534423  0  EOF
-1- --2--  ---3---   --4-- --5- -------6------ -7- -8-

# 1: 第一个字段是序列号
# 2: 第二个字段表示使用的锁的类，例如 FLOCK（来自flock 系统调用）或POSIX（来自lockf、fcntl 系统调用）
# 3: 第三个字段表示锁定类型，它可以有两个值：ADVISORY 或 MANDATORY
# 4: 第四个字段显示锁是写锁还是读锁
# 5: 第五个字段表示持有锁的进程的ID
# 6: 第六个字段包含一个冒号分隔值字符串，以 major-device:minor-device:inode 的格式显示锁定文件的 id
# 7和8: 第七和第八字段一起显示被锁定文件的锁定区域的开始和结束;在此示例行中，整个文件被锁定
```

## \# 协同锁使用示例
`util-linux` `包也提供了flock` 命令; `flock` 命令允许我们在 `shell` 脚本或命令行中管理协同文件锁，使用方式为：
```bash
$ flock FILE_TO_LOCK COMMAND
```

### \# 获取协同锁
以更新 `balance.dat` 文本文件为例说明，还需要两个进程 A 和 B 来更新文件中的余额。首先创建一个简单的 `shell` 脚本 `update_balance.sh` 来处理两个进程的余额更新逻辑，脚本如下：
```bash
#!/bin/bash
file="balance.dat"
value=$(cat $file)
echo "Read current balance: $value"

# sleep 10 seconds to simulate business calculation
progress=10
while [[ $progress -lt 101 ]]; do
	echo -n -e "\033[77DCalculating new balance.. $progress%"
	sleep 1
	progress=$((10+progress))
done
echo ""

value=$((value+$1))
echo "Write new balance ($value) back to $file." 
echo $value > "$file"
echo "Done."
```
创建一个简单的 `shell` 脚本 `a.sh` 来模拟`进程A`：
```bash
#!/bin/bash
#-----------------------------------------
# process A: lock the file and subtract 20 
# from the current balance
#-----------------------------------------
flock --verbose account.dat ./update_balance.sh '-20'
```
执行后结果：
```bash
$ ./a.sh 
flock: getting lock took 0.000002 seconds
flock: executing ./update_balance.sh
Read current balance:100
Calculating new balance..100%
Write new balance (80) back to balance.dat.
Done.
```
脚本执行过程中，可以通过 `lslocks` 命令查看锁文件：
```bash
$ lslocks | grep 'balance'
flock      825712  FLOCK   4B WRITE 0      0      0 /tmp/test/balance.dat
```
输出显示 `flock` 命令对整个文件 `/tmp/test/balance.dat` 持有一个 `WRITE` 锁。

### \# 非协作进程示例
协作锁只有在参与的进程协作时才起作用。将余额重置为 200，并测试如果进程 A 获取文件的协作锁但以非协作方式启动进程 B 会发生什么。  
创建一个简单的 `shell` 脚本 `b_non-cooperative.sh`：
```bash
#!/bin/bash
#----------------------------------------
# process B: add 80 to the current balance in a
# non-cooperative way
#----------------------------------------
./update_balance.sh '80'
```
进程 B 调用 `update_balance.sh` 没有尝试获取数据文件上的锁。
![test1](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220619-1538.gif)
如果进程 B 启动时没有与进程 A 协作，进程 A 获取的协作锁将被忽略;因此在 `balance.dat` 中数字为 280，而不是 260。

### \# 协作进程示例
创建另一个协作进程 B，`b.sh`，看看协作锁是如何工作的：
```bash
#!/bin/bash
#----------------------------------------
# process B: add 80 to the current balance
# in a cooperative way
#----------------------------------------
flock --verbose balance.dat ./update_balance.sh '80'
````
![test2](https://ruisum.oss-cn-shenzhen.aliyuncs.com/img/2022/06/20220619-1547.gif)
当进程 B 尝试获取 `balance.dat` 文件上的锁时，它等待进程 A 释放锁。因此，协同锁定起作用了，我们在数据文件中得到了预期的结果 260。

## \# flock 命令的使用
### \# flock 的语法
```bash
## 命令格式
flock [options] file|directory command [arguments]
flock [options] file|directory -c command
flock [options] number

## 几个参数的说明
-c，--command command：后接命令
-x，-e,--exclusive number： 获得排他锁，有时称为写锁。默认的锁
-n，--nb,--nonblock： 如果无法立即获得锁，则失败而不是等待。有关使用的退出代码，请参见 -E 选项
-E，--conflict-exit-code： 使用 -n 选项时使用的退出代码。默认值为 1
-o，--close： 在执行命令之前关闭持有锁的文件描述符。如果命令生成不应持有锁的子进程会比较有用
-s，--shared：获得共享锁，有时称为读锁
-u，--unlock： 释放锁。这通常不是必需的，因为当文件关闭时锁会自动删除;但在特殊情况下可能需要，例如如果封闭的命令组可能已经派生了一个不应该的后台进程保留了锁
-w，--wait，--timeout seconds：如果在几秒钟内无法获取锁，则失败
```
上面的第一种和第二种形式类似于 `su` 或 `newgrp` 的命令格式。他们锁定一个指定的文件或目录，如果尚不存在，则会创建（需要有适当的权限）。默认情况下，如果锁不能立即获得，`flock` 会一直等待，直到锁可用为止。  
第三种形式通过文件描述符号使用打开的文件，后面有示例说明。  

### \# 常见使用方式
```bash
## 执行 echo 命令前，获取排他锁
$ flock -x local-lock-file echo 'a b c'

## shell 脚本中使用很方便，当块中的代码执行完成时，文件描述符9和锁会自动释放
## 此处还可以使用 subshell, 但subshell存在一定的性能损耗，以及一些其他类似变量传递等的问题
$ {
 flock -n 9 || exit 1
 # ... commands executed under lock ...
} 9>/var/lock/mylockfile
  
## 这是 shell 脚本的样板代码。将它放在要锁定的 shell 脚本的顶部，它会在第一次运行时自动锁定。
## 如果 env var $FLOCKER 未设置为正在运行的 shell 脚本，则在重新执行自身之前执行 flock 并获取独占非阻塞锁（使用脚本本身作为锁文件）。 
## 它还将 FLOCKER 环境变量设置为正确的值，因此它不会再次运行。
$ [ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :
```

### \# flock 和 fd 的结合使用
- 为什么将 `flock` 与文件描述符结合使用
  > 与更传统的锁定机制相比，使用`flock() `或与之密切相关的`fcntl(LOCK_EX)` 机制的主要优势之一是，无需在重新启动或其他非正常关机情况下执行清理动作。因为锁是通过文件描述符附加的；当该文件描述符关闭时（无论是通过正常关闭、SIGKILL 还是断电），不再持有锁。
- 使用举例1
  ```bash
  ## 特定版本之后的 bash，支持不用手动管理 fd 的分配
  # this requires a very new bash -- 4.2 or so.
  exec {lock_fd}>filename  # open filename, store FD number in lock_fd
  flock -x "$lock_fd"      # pass that FD number to flock
  exec $lock_fd>&-         # later: release the lock
  ```
- 使用举例2
  ```bash
  ## 配置一个函数，用于获取锁
  declare -A lock_fds=()                        # store FDs in an associative array
  getLock() {
    local file=$(readlink -f "$1")              # declare locals; canonicalize name
    local op=$2
    case $op in
      LOCK_UN)
        [[ ${lock_fds[$file]} ]] || return      # if not locked, do nothing
        exec ${lock_fds[$file]}>&-              # close the FD, releasing the lock
        unset lock_fds[$file]                   # ...and clear the map entry.
        ;;
      LOCK_EX)
        [[ ${lock_fds[$file]} ]] && return      # if already locked, do nothing
        local new_lock_fd                       # don't leak this variable
        exec {new_lock_fd}>"$file"              # open the file...
        flock -x "$new_lock_fd"                 # ...lock the fd...
        lock_fds[$file]=$new_lock_fd            # ...and store the locked FD.
        ;;
    esac
  }
  ```

## \# flock() 系统调用
`flock()` - 在打开的文件上应用或删除协同锁

### \# 实现
```C
#include <sys/file.h> 

int flock(int fd, int operation); 
```

### \# 描述
对 `fd` 指定的打开文件应用或删除协同锁，参数 `operation` 是以下之一：
| **Tag** | **Description** |
|:--- | :--- |
|`LOCK_SH` | `Place a shared lock. More than one process may hold a shared lock for a given file at a given time.`|
|`LOCK_EX` | `Place an exclusive lock. Only one process may hold an exclusive lock for a given file at a given time.`|
|`LOCK_UN` | `Remove an existing lock held by this process.`|  

- 如果另一个进程持有不兼容的锁，则调用 `flock()` 可能会阻塞。要发出非阻塞请求，在上述任何操作中包含 `LOCK_NB（通过 ORing）`。  
- 单个文件一般不会同时拥有共享锁和排他锁。  
- 由 `flock()` 创建的锁与`打开的文件表条目相（open file table entry）`关联。这意味着重复的文件描述符（例如，由 `fork(2)` 或 `dup(2)` 创建）引用同一个锁，并且可以使用这些描述符中的任何一个来修改或释放该锁。此外，通过对这些重复描述符中的任何一个执行显式 `LOCK_UN` 操作或在所有此类描述符已关闭时释放锁。  
- 如果一个进程使用 `open(2)` （或类似方法）为同一个文件获取多个描述符，这些描述符将由 `flock()` 独立处理。  
- 一个进程只能在文件上持有一种类型的锁（共享或独占）。对已锁定文件的后续 `flock()` 调用会将现有锁定转换为新锁定模式。  
- 由 `flock()` 创建的锁在 `execve(2)` 中被保留。
- 无论打开文件的模式如何，都可以在文件上放置共享锁或排他锁。  

### \# 返回值和错误
成功时，返回零;出错时，返回 -1，并适当设置 errno。  
错误内容如下：  
| **Error Code** | **Description** |
|:--- | :--- |
|`EBADF` | `d is not a not an open file descriptor.`|
|`EINTR` | `While waiting to acquire a lock, the call was interrupted by delivery of a signal caught by a handler.`|
|`EINVAL` | `operation is invalid.`|  
|`ENOLCK` | `The kernel ran out of memory for allocating lock records.`|  
|`EWOULDBLOCK` | `The file is locked and the LOCK_NB flag was selected.`|  

### \# 其他
- `flock(2)` 不会通过 `NFS` 锁定文件。请改用 `fcntl(2)`：它可以在 `NFS` 上运行。
- 从内核 `2.0` 开始，`flock(2)` 本身作为系统调用实现，而不是在 `GNU C` 库中模拟为对 `fcntl(2)` 的调用。`flock(2)` 和 `fcntl(2)` 放置的锁类型之间没有交互，`flock(2)` 不会检测到死锁。
- `flock(2)` 仅设置协同锁；给文件适当的权限，进程可以忽略 `flock(2)` 的使用并对文件正常执行`I/O`操作。
- 对于 `forked进程` 和 `dup(2)`，`flock(2)` 和 `fcntl(2)` 锁具有不同的语义。在使用 `fcntl()` 实现 `flock()` 的系统上，`flock()` 的语义与本文`描述`部分不同。
- 转换锁（共享到独占，反之亦然）不能保证是原子的：先移除现有锁，然后建立新锁。在这两个步骤之间，可能会授予另一个进程的挂起锁请求，如果指定了 `LOCK_NB`，则转换要么阻塞，要么失败。

## \# 其他
### \# 参考内容
本文内容参考自：
- [Introduction to File Locking in Linux](https://www.baeldung.com/linux/file-locking#:~:text=Introduction%20to%20flock%20Command,or%20on%20the%20command%20line.)  
- [flock常见使用示例](https://manpages.ubuntu.com/manpages/xenial/man1/flock.1.html)  
- [flock和文件描述符结合使用](https://stackoverflow.com/questions/24388009/linux-flock-how-to-just-lock-a-file)  
- [Lock your script (against parallel execution)](https://wiki.bash-hackers.org/howto/mutex)  
- [Everything you never wanted to know about file locking](https://apenwarr.ca/log/20101213)  
- [wikipedia file locking](https://en.wikipedia.org/wiki/File_locking)  
- [flock() - Unix, Linux System Call](http://www.tutorialspoint.com/unix_system_calls/flock.htm)  
