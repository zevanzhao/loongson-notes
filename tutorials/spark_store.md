使用新世界操作系统的时候，如果要安装旧世界的各种商业软件，如QQ、微信等，使用星火商店是一个不错的方案。

关于星火商店的介绍，参考这个[地址](https://www.spark-app.store/)

目前，星火商店只支持Deepin和GXDE操作系统，不再支持Debian系统。好消息是，星火商店提供了一个命令行客户端aptss，使用这个包，也可以安装星火商店中的软件。

参考这个[网页](https://gitee.com/spark-store-project/spark-store/releases)

aptss包下载[地址](https://gitee.com/spark-store-project/spark-store/releases/download/4.7.0/aptss_4.7.0-1_all.deb)

下载以后，进入deb文件所在的目录，使用apt,安装这个包即可：
```bash
sudo apt install ./aptss_4.7.0-1_all.deb 
```

注意，aptss最新版本是4.7。spark store 4.8以上的版本与aptss冲突。

由于无法安装星火商店的图形界面，所有操作需要在命令行下进行。

要查看星火商店提供了那些软件包，可以使用如下的命令
```bash
aptss list "?not(?origin(Debian))"
```
现在星火商店已经提供了很多软件，如：
```
box64
browser360-cn-stable
cajviewer
cn.loongnix.lbrowser
com.xunlei.download
code-oss
codium
lat
lat-runtime
liblol
linuxqq
spark-wine9
spark-wine10
wechat
wemeet
wps-office
```

根据软件名称，查看软件的细节,比如查看wechat
```bash
aptss show wechat -a
```
输出如下：
```
Package: wechat
Version: 4.1.0.10-spark1
Priority: optional
Source: wechat-stable
Maintainer: WeChat Team <>
Installed-Size: 773 MB
Provides: wechat
Pre-Depends: dpkg (>= 1.14.0)
Depends: fonts-noto-cjk | google-noto-cjk-fonts, liblol, liblol-dkms, libtiff5
Download-Size: 226 MB
APT-Manual-Installed: yes
APT-Sources: https://d.spark-app.store/loong64-store  Packages
Description: wechat from Tencent
```
安装软件和apt一样
```bash
aptss install wechat
```

