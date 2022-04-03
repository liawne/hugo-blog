+++
title = "Shortcodes示例"
description = ""
date = "2022-04-03T13:48:19+08:00"
lastmod = "2022-04-03T13:48:19+08:00"
tags = [""]
dropCap = false
displayCopyright = false
gitinfo = false
draft = true
toc = true
+++

## quote
**引用**, 代码样式如下: 
```
{{</* quote */>}}
十里青山远，潮平路带沙。数声啼鸟怨年华。又是凄凉时候，在天涯。白露收残月，清风散晓霞。绿杨堤畔问荷花。记得年时沽酒，那人家。
{{</* /quote */>}}
```

{{< quote >}}
十里青山远，潮平路带沙。数声啼鸟怨年华。又是凄凉时候，在天涯。白露收残月，清风散晓霞。绿杨堤畔问荷花。记得年时沽酒，那人家。
{{< /quote >}}

## quote-center
**居中引用**, 代码样式如下: 
```
{{</* quote-center */>}}
黑夜给了我黑色眼睛<br/>我却用他寻找光明
{{</* /quote-center */>}} 
```

{{< quote-center >}}
黑夜给了我黑色眼睛<br/>我却用他寻找光明
{{< /quote-center >}}

## align
**文字位置设定**, 代码样式如下: 
```
{{</* align left "文字居左" */>}}
{{</* align center "文字居中" */>}}
{{</* align right "文字居右" */>}}
```

{{< align left "文字居左" >}}

## 下划线
**下划线使用**, 代码样式如下: 
``` 
{{</* underline color="#ffdd00" content="还记得当天旅馆的门牌" */>}}
```

{{< underline color="#ffdd00" content="还记得当天旅馆的门牌" >}}

## 卡片
**卡片**, 代码样式如下: 
``` 
{{</* card */>}}
黄河之水天上来
<br />
奔流到海不复回
{{</* /card */>}}
```

{{< card >}}
黄河之水天上来
<br />
奔流到海不复回
{{< /card >}}

## notice
**提示**, 代码样式如下: 
> 可用的关键字用 error,warning,info,tip,success
```
 {{</*notice info*/>}}This is info{{</*/notice*/>}}
```

{{<notice info>}}This is info{{</notice>}}

## shortcodes escape
shortcodes 的形式写出来会被 Hugo 直接渲染，可以使用 /* */ 来防止被转义. 

```
{{</*/* yourcodes */*/>}}
```

## 其他
`shortcodes` 的使用参考了如下文章:
- [自定义-hugo-shortcodes-简码](https://ztygcs.github.io/posts/%E5%8D%9A%E5%AE%A2/%E8%87%AA%E5%AE%9A%E4%B9%89-hugo-shortcodes-%E7%AE%80%E7%A0%81/)
- [https://github.com/gohugoio/hugo/tree/master/docs](https://github.com/gohugoio/hugo/tree/master/docs)
- [https://guanqr.com/tech/website/hugo-shortcodes-customization/](https://guanqr.com/tech/website/hugo-shortcodes-customization/)