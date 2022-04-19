+++
title = "Python 学习笔记"
description = "python 学习笔记内容"
date = "2022-04-19T23:00:28+08:00"
lastmod = "2022-04-19T23:00:28+08:00"
tags = ["python", "note", "basic"]
dropCap = false
displayCopyright = true
displayExpiredTip = false
gitinfo = false
draft = true
toc = true
+++
## 基础数据类型
\#\# 2018-01-09 ##
### \# 列表（list）

    1、列表是有顺序的，可以使用list.append('xxx') 在后面追加，也可以使用list.insert('xxx')在前面插入;
    2、可以使用del list[2]删除列表中的元素
    3、列表是可以被改变的
    4、列表可认为是传引用，相当与C语言中的指针
    5、列表的特点（有序、混合类型、按偏移量进行取值、长度可变、可嵌套、值可变）
    6、列表推导式fruits_3 = [ x.capitalize() for x in fruits ]
    7、原地扩展列表list1.extend（list2）

### \# 元组（tuple）  

    1、元组通过小括号来表示contries = ('China', 'America', 'Canada')
    2、元组只支持两种方法，出现的次数和下标所处的位置
    3、元组相当于不可变的列表
    4、更改列表为元组t1 = tuple（l1）
    5、元组本身不可改变，但内部元素可以被更改，比如元组中包含有列表，列表可被更改
    6、x = （1）--> x = 1;若想要定义单个元素的tuple，为y = （1,）

### \# 集合（set）

    1、集合中的元素是唯一的，可用set（l2）来对列表l2进行去重
    2、%timeit用于计算命令执行时间，相当于linux下的time命令
    3、使用python内置的功能去实现，效率会高很多
    4、异集 set1 ^ set2; 交集 set1 & set2; 并集 set1 | set2; 差集 set1 - set2
    5、集合增加元素的方式为set.add，删除set.remove，随机去除并打印set.pop

### \# 字典（dict）

    1、字典存储数据的特点（键值对、混合类型、长度可变、可嵌套、值可变）
    2、新增字典中的键值对，直接使用dict['key'] = 'value'来进行增加
    3、字典可以单独拿出key、value、items
    4、字典推导式：{key：value for key value in dict1}
    5、字典赋值：d1 = dict（a=1, b=2, c=3）以及d1 = { ‘a’： 1, ‘b’： 2, ‘c’： 3}

{{<notice info>}}
有序的数据类型：str、list、tuple  
无序的数据类型：set、dict
{{</notice>}}

### \# 文件  

    1、input_file = open('/tmp/passwd')写完表示python已经打开该文件
    2、input_file.close()关闭文件
    3、input_file.readline()读取文件第一行并打印，指针指向下一行（文件指针）
    4、input_file.read()可以指定读取多少个字符，括号内若不加参数，则会将整个文件全部读取完，文件指针到达末尾
    5、input_file.seek()将文件指针指向给定的参数位置，参数指定的是字符,seek接受两个参数，可指定参考位置，开始、当前位置，结尾，偏移量可为负数
    6、input_file.readlines()将文件读取，返回一个以单行作为字符串元素的列表
    7、print为一个函数，内部可接end=‘’指定分隔符
    8、使用open打开文件，默认情况下为r，open('/tmp/passwd','w')模式则为写模式打开 
    9、以写的模式打开文件，源文件中的内容被清空，请小心操作;
    10、f.write('xxxxx')完成后，文件中并没有内容，写的数据保留在缓冲区中，需要使用flush刷入数据;f.flush()见数据写入
    11、读模式情况下不能写入，写模式下不能读取;若要可读可写，需要使用读写模式打开文件
    12、以读写的方式打开文件有两种方式，‘r+’，‘w+’;区别为‘w+’打开文件同样会先把文件清空;同样谨慎操作;
    13、以附加的方式打开文件，可以避免’r+‘模式下，指针不在最后的情况下，覆盖写（replace）的情况，而是以追加（append）的方式进行，发生写的动作时，指针会先跳到末尾
    14、f = open('/tmp/info', 'rb');以二进制形式打开文件info，否则python默认会自动做转化，将\r\n(^M)直接换成\n，用作保护
    15、关闭文件的方式，直接使用close明确关闭;删除了指向文件的变量;

## 基础语法
\#\# 2018-01-12 ##

### \# 语法

    1、语法特点
        1、行之末即语句之末，缩进之末即块之末
        2、几乎一切皆对象
        3、动态引用（不需声明即可引用）、强类型、变量没有类型，但背后的对象有类型
    2、常用的赋值方法
        1、简单赋值（=）
        2、自增/减（+=，-=）
        3、元组赋值（a，b = 1, 2）;x， y = 1, 2
        4、for x in collection
    3、if elif else分支语句
    4、python的布尔值原理
        1.False/True
        2.真假值的其他表示方法：number/str/list/tuple/dict/set/None
        3.number值只有为0的时候才为假，其余情况均为真
        4.bool（）函数，用于测试布尔值，为空是假，不为空则为真 data = [[], []]不为空
        5.None 为False
        6.str，容器（list，tuple，dict，set），没有元素为False，否则为True
        7.‘==’用于判断两个对象是否相等，is用于判断两个对象是否相同（id相同）
    5、for循环语句的应用
        1.iterable可迭代的，list、open（‘file’）、tuple按顺序进行读取;dict、set无顺序，随机获取
        2.for x in iterable：
        3.range（）函数，用于生成序列，常与for结构一同使用，制定特定次数的循环
    6、while循环语句的应用，判断while后接语句是否正确，再确定是否继续执行
        1.死循环，某些常驻后台运行的语句需要使用;while True：
        2.循环条件
    7、break和continue的使用
        break表示推出整个循环架构
        continue中止当前循环，进入下一轮循环
        break终止整个循环，continue终止当前循环 
    8、判断
        1、逻辑与 expr1 and expr2
        2、逻辑或 expr1 or expr2
        3、逻辑非 not expr1
    9、迭代器原理(__iter__, __next__, StopIteration, iter, next)
        1、data = ['morning', 'evening', 'monday']; i = iter(data)用于将data转成迭代器，结合next函数使用
        2、手动生成和操作迭代器的方法（iter，next，StopIteration）
    10、推导式和生成器的写法
        列表推导式（list）--> fruit = ['apple', 'orange']; fruit_3 = [x.capitalize() for x in fruit]
        字典推导式（dict）--> fruit = ['apple', 'orange']; fruit_4 = {key: None for key in fruit}
        集合推导式（set） --> fruit = ['apple', 'orange']; fruit_5 = {key for key in fruit}
        生成器（generator）--> fruit = ['apple', 'orange']; (x for x in fruit)并不显示，需要使用list（）转成列表才可打印

## 附加内容
\#\# 2018-01-12 ##

### \# lambda

    1、定义方法，函数定义与相应的对象
    2、匿名函数lambda: add2 = lambda num1, num2: num1 + num2 --> def add1(num1, num2):\ return num1 + num2
    3、函数对象可以作为参数传递给其他函数，这个是python当中很有用的一种方式（pyexe中print_error.py），回调函数
    4、完整的statment不能放到另外一个statment中当作对象使用 
    5、lambda可以把整个语句当成参数传递给其他函数使用 --> work(lambda v: print(v))
    6、lambda是一个表达式，不是一个完整的句子

### \# 参数的定义方法

    1、定义方式：
        关键字的参数传递方式
        def cat(str1,str2): 
            return str1 + ' ' + str2
        cat(str1,str2)              --> 没有顺序的要求，可能不一定符合自己想要的结果;         
        cat(str1=xxx, str2=yyy)     --> 可以指定关键字，但关键字必须是源码中已经确定的名字;
    2、默认值：省略参数时，选择默认值以使用 --> def sum(message='Enter a number : '):，调用函数sum时，若未指定message内容，就用=后的内容
    3、sys.argv()导出一个列表，脚本名字为第一个元素
    4、在脚本中测试是否为None，使用if numbers is None这种形式，不要使用== --> 最佳实践
    5、参数通吃：
        通吃的位置参数 --> def sum(*numbers):，囊括所有的位置参数;保存numbers的数据类型为tuple元组
        通吃的关键字参数 --> def sum(**kargs):，囊括所有的关键字参数;保存kargs的数据类型为dict字典 (pyexe sum3.py)
    7、打散：
        l1 = [1, 2, 3, 4, 5]; sum3.sum(*l1) --> 将列表l1中的元素打散，作为位置参数传递给了sum;
        d1 = dict(a=1, b=2, c=3); sum3.sum(**d1) --> 将字典d1中的元素打散，作为关键字参数传递给了sum
        --> (pyexe, args.py)

## 函数
\#\# 2018-01-13 ##  
    
    1、变量的作用域类型：
        1、函数里面的作用域，local
        2、函数外围的函数的作用域，nonlocal(enclosing)
        3、模块级别的全局作用域，global
        4、python的内置作用域，builtin 
    2、变量的作用域顺序（LEGB）： 
        L --> local 
        E --> enclosing，Python支持嵌套的函数定义方式（函数当中再定义函数） 
        G --> global，模块的顶层变量（模块：.py结尾的文件，或其他结尾的文件）
        B --> builtin，Python内置的一个模块（import builtins）;ipython的整个交互式界面就是一个global 变量
        LEG可变，B不可变
        global,nonlocal,local均可作为变量声明的关键字
    3、嵌套函数
        pyexe --> sotred-str.py（sorted函数的使用为例，sorted_key为回调函数）
    4、函数的隐式返回值
        pyexe --> default_return_value.py（两个print打印各自的返回值）
        python的代码风格是，尽量明确，不要使用隐晦的返回
    5、函数定义时与函数运行时的区别
        函数定义时（define time）
        函数运行时（run time）
        定义时不会运行函数体内的代码
    6、匿名函数的使用
        lambda的使用一般是在作为参数传递的时候使用，其他时候一般使用def来定义函数
    7、函数的使用策略
        模块化、可重用、可传参、可读性好等等

## 模块的使用
\#\# 2018-01-13 ##  
1、模块是什么：就是一个.py 结尾的文件  
2、python 的模块导入有一个所谓的“搜索路径”  

    查看可以导入的路径：
    1、import sys
    2、sys.path显示出一个以路径为元素的列表，可从这个列表中包含的路径导入py结尾的模块，类似于shell中的$PATH
    3、列表的第一个元素显示为‘’，表示的是当前路径
3、模块 f 中包含的函数、变量、值都可以使用 f.来调用，使用其下包含的函数，打印模块下含有的变量值等等！  
4、模块的导入：

    1、默认行为，导入模块对python来说是一个很消耗资源的行为，默认导入一次模块（例f.py）之后，后续再次导入并不会再执\
    行模块中的代码，也即在更改了模块中的内容之后，再次导入，更改的内容并不会被python识别;
    2、利用模块导入的默认行为，可以利用这个特点在模块之间传递配置信息;范例：开发环境下settings.py文件中的配置参数
    3、需要重新加载已经发生过变化的模块，步骤如下，即可重新加载
        import importlib
        importlib.reload(mymod)
    4、不修改sys.path，实现直接导入当前目录下的模块;pyexe --> importsys.py;
        这种方式可以实现将所有库文件放到libs目录，然后将libs路径加入到sys.path中，可以统一的路径导入模块，规范管理
    5、from xx import yy
        xx为模块名字，yy为xx模块中的顶级名字（对象，可以是函数、变量）
    6、import xx as yy
        导入模块的同时，将模块xx改名为yy
    7、$PYTHONPATH变量用于在shell中设置python的模块导入路径，在shell环境下echo $PYTHONPATH，显示内容添加在sys.path中
5、查看当前导入的模块

    1、import sys
    2、sys.modules返回一个包含模块名称和对应路径的字典
6、其他
    
    1,从一般意义上来说,模块往往就是变量名的封装,被认作是命名空间
    2,属性就是绑定在特定对象上的变量名(就像一个模块)
    3,object.attribute语法--> 对象的属性
    4,from和import的差别: from复制了模块的属性,以便属性成为接收者的直接变量;import则不同,import之后,对应的变量是作为模块的属性存在的
    5,一些以双下划线开头和结尾的变量名,这些通常都是由python预定义的内置变量名,对于解释器来说有特殊的含义
    6,模块导入是一种运行代码文件的方法,模块同样是python程序最大的程序结构
    7,模块文件在代码文件中起到了最小化命名冲突的作用
    8,模块是一个不需要重复输入而可以反复运行代码的方法
    9,reload是不可传递的,重载一个模块的话只会重载该模块,而不能够重载该模块所导入的任何模块,因此有时必须reload多个文件
    10,使用exec运行模块文件,每次都是运行最新的代码,而不需要随后的重载操作--> exec(open('scriptx.py).read())
    11,基本的import语句每个进程只运行文件一次,并且它会把文件生成到一个单独的模块名称空间中,以便它的赋值不会改变你的作用域中的变量
    12,命名空间就是变量的封装,在python中以一个带有属性的对象的形式出现

## 廖雪峰python参考
\#\# 2019-02-25 ##

### \# 一些说明
    1、在print函数当中仍然可以使用\进行脱义;print('I\'m OK!')  
    2、python中可以使用三引号表示多行  
    3、python中全部大写的变量名通常表示常量  
    4、’/‘运算符表示除，得到的结果类型为浮点数，即使能够除尽;’//‘表示地板除，得到的结果永远是整数，即使无法除尽  
    5、对变量赋值x = y是把变量x指向真正的对象，该对象是变量y所指向的。随后对变量y的赋值不影响变量x的指向  
    6、可以把任何数据都看成一个“对象”，而变量就是在程序中用来指向这些数据对象的，对变量赋值就是把数据和变量关联起来。  

### \# 列表生成式  
    1,[x * x for x in range(1, 11)]
    [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
    
    2,[x * x for x in range(1, 11) if x % 2 == 0]
    [4, 16, 36, 64, 100]
    
    3,[m + n for m in 'ABC' for n in 'XYZ']
    ['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ']
    
    4,d = {'x': 'A', 'y': 'B', 'z': 'C' }
    for k, v in d.items():
        print(k, '=', v)
    y = B
    x = A
    z = C
    
    5,L1 = ['Hello', 'World', 18, 'Apple', None]
    [ word.lower() for word in L1 if isinstance(word, str) ]

### \# 创建generator  
    在Python中,这种一边循环一边计算的机制,称为生成器:generator,生成器保存的是算法
    1,要创建一个generator,有很多种方法。第一种方法很简单,只要把一个列表生成式的[]改成(),就创建了一个generator
      g = (x * x for x in range(10))
    2,如果要一个一个打印出来,可以通过next()函数获得generator的下一个返回值
      next(g) --> 每次取出一个元素
    3,另一种方式是使用for循环取出内容,generator也是一个可迭代对象
      g = (x * x for x in range(10))
      for n in g:
          print(n)
    4,第二种创建generator的方法,在一个函数中如果包含了yield关键字,则这个函数不是普通函数,而是一个生成器
      def fib(max):
          n, a, b = 0, 0, 1
          while n < max:
              yield b
              a, b = b, a + b
              n = n + 1
          return 'done'

### \# 迭代器
    可以被 next()函数调用并不断返回下一个值的对象称为迭代器: Iterator
    1,可以使用isinstance()判断一个对象是否是Iterator对象:
      from collections import Iterator
      isinstance((x for x in range(10)), Iterator)
      True
    2,生成器都是Iterator对象,但list,dict,str虽然是Iterable,却不是Iterator
    3,高阶函数,python支持函数作为变量传递给另外一个函数
      def add(x, y, f):
          return f(x) + f(y)
      
      add(-5, 6, abs) = 11
    4,map/reduce
    map()函数接收两个参数,一个是函数,一个是Iterable,map将传入的函数依次作用到序列的每个元素,并把结果作为新的Iterator返回。
      >>> list(map(str, [1, 2, 3, 4, 5, 6, 7, 8, 9]))
      >>> ['1', '2', '3', '4', '5', '6', '7', '8', '9']
    
    reduce()把一个函数作用在一个序列[x1, x2, x3, ...]上,这个函数必须接收两个参数, reduce把结果继续和序列的下一个元素做 \
    累积计算,其效果就是:
      reduce(f, [x1, x2, x3, x4]) = f(f(f(x1, x2), x3), x4)
    
      >>> from functools import reduce
      >>> def add(x, y):
              return x + y
      >>> reduce(add, [1, 3, 5, 7, 9])
          25
    5,filter
    和map()类似,filter()也接收一个函数和一个序列,和map()不同的时,filter()把传入的函数依次作用于每个元素,然后根据返回值是
    True还是False决定保留还是丢弃该元素
      >>> def is_odd(n):
              return n % 2 == 1
    
      >>> list(filter(is_odd, [1, 2, 4, 5, 6, 9, 10, 15]))
      >>> [1, 5, 9, 15]

