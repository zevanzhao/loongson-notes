# WPS一级标题出现黑色乱码

这个问题是一个架构无关的问题，[与freetype版本有关](https://blog.csdn.net/qq_43699560/article/details/136702761)

简而言之，freetype更新到2.13.0-1以后的版本，粗体的设置会太粗，导致会出现这样的问题。解决方案是：降级freetype的版本到2.13.0-1。
新世界下，降级freetype版本有些困难。解决的方案是：从UOS或者麒麟系统下，找一个旧世界的文件，替代一下。

## 解决方案：
从旧世界（比如麒麟下），将`/usr/lib/loongarch64-linux-gnu/libfreetype.so*` 复制到`/opt/kingsoft/wps-office/office6/`。

没有麒麟系统或者统信系统的，还可以从loongnix20的源里[下载](https://pkg.loongnix.cn/loongnix/20/pool/main/f/freetype/libfreetype6_2.9.1-3%2Bdeb10u1.lnd.2_loongarch64.deb)
