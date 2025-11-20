# 二代龙芯派硬件+内核+系统配置笔记

自从买了二代龙芯派以后，用的一直不够爽快，总是有小毛病。为了能够比较爽快的用龙芯派，我决定好好整理一下龙芯派的各种配置。下面是我的配置笔记。

1.  **硬件调整**

    对于硬件的优化，主要是更换了更大的SSD，并且安装了M2无线网卡。

    二代派自带的固态硬盘只有16GB，实在是太小了，做不了什么事情。所以，我买了一个128GB
    的固态硬盘，空间比较充足。注意，固态硬盘的型号是M2 2242。

    二代派自带两个有线网卡，这很不错，但我更喜欢不需要网线的无线网卡。二代龙芯派自带的USB口只有2个，太少了。如果要占用一个USB口去插USB无线网卡，实在是太浪费了。用M2无线网卡，可以节省一个USB口。

    淘宝搜QCA9377/NFA435的M.2接口无线模块就行，注意：需要加配两根天线。

    如果希望使用USB无线网卡，推荐使用RTL8192CU芯片的无线网卡，驱动比较完善。产品推荐NW362。

    如果要购买摄像头，请购买支持UVC的摄像头。

2.  **pmon固件更新**

小白用户请跳过这一步操作。

**警告：高危操作，有变砖风险！**

这里，使用了flygoat提供的2.3版本的[pmon](https://github.com/FlyGoat/pmon-ls2k-pi2/releases/tag/v2.3)


放在U盘里，确保md5值准确无误，然后用load命令刷。
```
load -r -f 0xbfc00000 (usb0,0)/flash.bin
```
强烈建议对文件进行md5校验，确保pmon固件下载、复制都正确。

建议用最皮实可靠的U盘进行操作，一定不要用不稳定的U盘来操作！

3.  **Loongnix操作系统安装**

    Loongnix的安装并不是必须的，可以直接使用网络安装的方法来安装Debian操作系统。可以参考龙黑一号的文章。

    <https://tieba.baidu.com/p/5299811786>

    过程稍微有些繁琐，个人习惯双系统，所以我还保留了Loongnix系统。

    首先，安装一个Loongnix操作系统。这个操作系统的主要功能是用来安装Debian操作系统，并作为操作系统的一个备份。一旦Debian系统出现了问题，还可以在Loongnix下抢救一下。

首先，下载Loognix 20180930版本的iso文件。

<http://ftp.loongnix.org/os/loongnix/1.0/liveinst/old/loongnix-20180930.iso>

记得对ISO文件进行MD5校验

<http://ftp.loongnix.org/os/loongnix/1.0/liveinst/old/loongnix-20180930.iso.md5>

20190331版本的应该也可以用。我不清楚最新的Loongnix是否支持二代龙芯派，没有进行尝试。

用dd命令制作安装U盘。
```bash
dd if=loongnix-20180930.iso of=/dev/sdb bs=8M
```
注意，*sdb*需要修改为U盘对应的盘符。

安装细节不再赘述，详情可以参考鸽工的视频教程

[龙芯TechLive第一期：安装Loongnix系统](https://www.bilibili.com/video/av57802116)


安装的时候在分区的时候需要小心一点：

/boot分布必须是第一个分区。分区大小500MB左右即可。个人建议用ext3格式。

/ 分区 由于Loongnix不是我的主系统，只给/ 留了10GB的容量。

/DEBIAN分区，分出了30GB的空间用于安装Debian操作系统。

swap分区留了4GB，是内存大小的两倍。实际上，分出2GB的空间做swap也足够了。

/home分区, 可以让多个系统共享一个home。其余的约74GB磁盘空间留给/home。

安装过程中，遇到了两个问题：

第一个问题：龙芯派比较挑HDMI线，使用绿联的HDMI线可以正常显示，使用渣渣显示器自带的线不能显示画面。如果发现龙芯派屏幕不亮，很可能是HDMI线的问题，而不是龙芯派的问题。

第二个问题：两个标准USB口，如果同时插上USB无线鼠标和USB键盘，pmon会报错，无法正常启动。建议在启动的时候只插一个USB键盘，等正常载入系统的时候再插鼠标等外设。

4.  **Debian操作系统的安装**

    在Loongnix操作系统下，用debootsrap脚本安装Debian操作系统。此时，建议先用有线网络。

    首先，安装debootstrap
```bash
yum install debootstrap
```
Loognix里自带的debootstrap比较古老。如果想用比较新的debootstrap，可以参考[这里](https://packages.debian.org/source/buster/debootstrap)

在给debian系统预留的/DEBIAN分区内，用root执行debootstrap
```bash
debootstrap --arch mips64el stable /DEBIAN http://mirrors.huaweicloud.com/debian/
```

我选择了华为的镜像，速度比较快。此外，我选择了安装stable版本的Debian
buster。喜欢testing或者sid的可以自行选择合适的系统。

<https://www.debian.org/mirror/list>

<https://wiki.debian.org/zh_CN/Debootstrap>

很快，一个基本操作系统就完成安装了。

挂载必要的目录

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>mount --bind /dev /DEBIAN/dev</p>
<p>mount --bind /dev/pts /DEBIAN/dev/pts</p>
<p>mount --bind /proc /DEBIAN/proc</p>
<p>mount --bind /srv /DEBIAN/srv</p>
<p>mount --bind /home /DEBIAN/home</p></td>
</tr>
</tbody>
</table>

chroot到Debian环境下，

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>chroot /DEBIAN</td>
</tr>
</tbody>
</table>

设置root用户密码；新建普通用户,并且设置用户密码。

修改/etc/fstab文件，正确挂载各个分区。我的fstab文件如下所示：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>/dev/sda3 / ext4 defaults,errors=remount-ro,sync 1 1</p>
<p>/dev/sda1 /boot ext3 defaults 1 2</p>
<p>/dev/sda2 /home ext4 defaults 1 2</p>
<p>/dev/sda5 /Loongnix ext4 defaults 1 2</p>
<p>/dev/sda6 swap swap defaults 0 0</p></td>
</tr>
</tbody>
</table>

修改/etc/hostname文件，设置一个合适的主机名称。

修改/boot/boot.cfg文件，引导Debian正常启动。

修改以后的boot.cfg文件如下所示

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>timeout 5</p>
<p>default 2</p>
<p>showmenu 1</p>
<p>title 'Loongnix GNU/Linux'</p>
<p>kernel (wd0,0)/vmlinuz-3.10.0-1.fc21.loongson.2k.11.mips64el</p>
<p>initrd
(wd0,0)/initramfs-3.10.0-1.fc21.loongson.2k.11.mips64el.img</p>
<p>args root=/dev/sda5 ro rhgb quiet loglevel=0 LANG=zh_CN.UTF-8</p>
<p>title 'Loongnix GNU/Linux with 3.10-zevan+'</p>
<p>kernel (wd0,0)/vmlinuz-3.10-20200502-2</p>
<p>args root=/dev/sda5 ro rhgb quiet loglevel=0 LANG=zh_CN.UTF-8</p>
<p>title 'Debian buster GNU/Linux with 3.10-zevan+'</p>
<p>kernel (wd0,0)/vmlinuz-3.10-20200502-2</p>
<p>args root=/dev/sda3 ro loglevel=0 LANG=zh_CN.UTF-8</p>
<p>#args root=/dev/sda3 ro rhgb quiet loglevel=0 LANG=zh_CN.UTF-8</p>
<p>title 'Loognix Rescue'</p>
<p>kernel
(wd0,0)/vmlinuz-0-rescue-48630c8a5f954884a1dfce04a4bafdc6.2k</p>
<p>initrd
(wd0,0)/initramfs-0-rescue-48630c8a5f954884a1dfce04a4bafdc6.2k.img</p>
<p>args root=UUID=d2301806-d811-4a91-b0c1-c9e8de930449 ro rhgb quiet
loglevel=0</p></td>
</tr>
</tbody>
</table>

需要用apt安装一系列软件包，方便后续的使用。下面是我所安装的软件包，仅供参考。

<table>
<colgroup>
<col style="width: 27%" />
<col style="width: 72%" />
</colgroup>
<tbody>
<tr class="odd">
<td>名称</td>
<td>用途</td>
</tr>
<tr class="even">
<td>build-essential</td>
<td>C/C++编译器</td>
</tr>
<tr class="odd">
<td>net-tools</td>
<td>ifconfig等网络相关工具</td>
</tr>
<tr class="even">
<td>gnome-core</td>
<td>Gnome桌面环境</td>
</tr>
<tr class="odd">
<td>lightdm</td>
<td>Lightdm 登陆管理器(注意：gdm无法正常使用)</td>
</tr>
<tr class="even">
<td>xinit</td>
<td>startx等命令</td>
</tr>
<tr class="odd">
<td>mc</td>
<td>Midnight-Command</td>
</tr>
<tr class="even">
<td>emacs</td>
<td>Emacs编辑器</td>
</tr>
<tr class="odd">
<td>firmware-atheros</td>
<td>Ath10K无线网卡固件</td>
</tr>
<tr class="even">
<td>firmware-realtek</td>
<td>RealTek 8192等无线网卡固件</td>
</tr>
<tr class="odd">
<td>wpa_supplicant</td>
<td>无线网卡联网工具</td>
</tr>
<tr class="even">
<td>network-manager</td>
<td>网络管理工具</td>
</tr>
<tr class="odd">
<td>firefox-esr</td>
<td>Firefox浏览器</td>
</tr>
<tr class="even">
<td>gparted</td>
<td>Gparted磁盘分区程序</td>
</tr>
<tr class="odd">
<td>wget</td>
<td>Wget程序</td>
</tr>
<tr class="even">
<td>git</td>
<td>Git程序</td>
</tr>
<tr class="odd">
<td>mate</td>
<td>Mate桌面环境</td>
</tr>
<tr class="even">
<td>Xfce4-terminal</td>
<td>Xfce4终端，有透明背景功能</td>
</tr>
<tr class="odd">
<td>okular</td>
<td>Okular PDF阅读程序</td>
</tr>
<tr class="even">
<td>openssh-server</td>
<td>ssh服务器</td>
</tr>
<tr class="odd">
<td>dhcpcd5</td>
<td>DHCP客户端</td>
</tr>
<tr class="even">
<td>locales</td>
<td>多国语言支持</td>
</tr>
<tr class="odd">
<td>locate</td>
<td>文件查找程序</td>
</tr>
<tr class="even">
<td>apt-file</td>
<td>根据文件名，查找deb包的文件</td>
</tr>
<tr class="odd">
<td>fcitx</td>
<td>Fcitx输入法</td>
</tr>
</tbody>
</table>

完成以上的操作后，重新启动龙芯派，即可进入Debian系统。

5.  **内核模块编译**

    Loongnix自带的3.10内核不仅版本非常古老，而且**非！常！难！用！**内核里只有启动二代派所必需的模块，其余的模块基本上都没有：没有M2无线网卡驱动，没有USB无线网卡驱动，没有摄像头驱动。

    要想用的舒服，还得自己编译一个合适的内核，增加必要的内核模块。以下是编译内核的流程。内核的编译在x86
    处理器的Linux操作系统上完成，请注意。如果在龙芯处理器上编译，请酌情修改编译脚本。

    下载内核源码和工具链。在loongnix的ftp服务上，提供了两份二代龙芯派可以使用的内核源码，分别是

    <http://ftp.loongnix.org/embedd/ls2k/linux-3.10.tar.gz>

    和

    <http://ftp.loongnix.org/loongsonpi/pi_2/source/linux-3.10.tar.gz>

    我使用的是第二份源码。第一份源码的配置我没搞定。

    工具链可以使用

    <http://ftp.loongnix.org/loongsonpi/pi_2/toolchain/gcc-4.9.3-64-gnu%20.tar.gz>

    或者

    <http://ftp.loongnix.org/embedd/ls3a/toolchain/gcc-4.9.3-gnu.tar.gz>

    两个工具链没有太大区别，都可以使用。

    将内核源码文件解压缩。

    复制.config文件

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>cp ls2k.config .config</td>
</tr>
</tbody>
</table>

配置内核模块

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>make ARCH=mips CROSS_COMPILE=mips64el-linux- menuconfig</td>
</tr>
</tbody>
</table>

参考了小子 前辈的文档，我在设置内核模块的时候，做了以下的操作。

<table>
<colgroup>
<col style="width: 52%" />
<col style="width: 47%" />
</colgroup>
<tbody>
<tr class="odd">
<td>内核模块位置</td>
<td>操作</td>
</tr>
<tr class="even">
<td>Device Drivers → Sound Card Support→ Advanced Linux Sound
Architecture→HD-Audio,</td>
<td>选中HD Audio PCI, Loongson HD Audio, Build Realtek HD-Audio codec
support</td>
</tr>
<tr class="odd">
<td>Device Drivers → USB Support</td>
<td>去掉 USB Gadget Support</td>
</tr>
<tr class="even">
<td>Networking Support → Networking options</td>
<td>去掉 B.A.T.M.A.N. Advanced Meshing Protocol 支持</td>
</tr>
<tr class="odd">
<td></td>
<td>去掉一些 firmware 的支持，直接修改.config文件</td>
</tr>
<tr class="even">
<td>Networking support → Wireless</td>
<td>增加802.11支持，选中cfg80211 - wireless configuration API ，Generic
IEEE 802.11 Networking Stack (mac80211)</td>
</tr>
<tr class="odd">
<td>Device Drivers → Network device support → Wireless LAN</td>
<td>增加Ath10K
的M2无线网卡模块，Ralink网卡模块，RealTek无线网卡模块</td>
</tr>
<tr class="even">
<td>Device Drivers → Multimedia support → Media USB Adapters</td>
<td>增加UVC摄像头支持， 增加对RTL-SDR设备的支持（Realtek RTL28xxU DVB
USB support）</td>
</tr>
</tbody>
</table>

编译内核使用的脚本如下：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>#!/bin/bash</p>
<p>export
PATH="${HOME}/Loongson/toolchain/opt/gcc-4.9.3-64-gnu/bin":${PATH}</p>
<p>export MAKEFLAGS='CC=mips64el-linux-gcc'</p>
<p>make -j 2 ARCH=mips CROSS_COMPILE=mips64el-linux-</p>
<p>make -j 2 ARCH=mips CROSS_COMPILE=mips64el-linux-
INSTALL_MOD_PATH=./tmp modules_install</p></td>
</tr>
<tr class="even">
<td></td>
</tr>
</tbody>
</table>

编译需要的config文件和编译出来的内核文件在附件中。

6.  **无线网络自动连接**

    我希望龙芯派开机以后可以自动开启SSH服务器，并且自动连接无线网。这样用起来就方便多了。

    开启ssh服务

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>systemctl enable sshd.service</p>
<p>systemctl start sshd.service</p></td>
</tr>
</tbody>
</table>

自动连接无线网的使用方法如下：

<https://wiki.debian.org/WiFi/HowToUse#wpa_supplicant>

<https://unix.stackexchange.com/questions/537235/getting-wpa-supplicant-to-work-on-boot-in-debian-10>

主要的操作如下：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>wpa_passphrase myssid my_very_secret_passphrase &gt;
/etc/wpa_supplicant/wpa_supplicant.conf</td>
</tr>
</tbody>
</table>

注意查看/etc/wpa\_supplicant/wpa\_supplicant.conf文件，其中有加密后的WPA密码。在wpa\_supplicant.conf后加入两行

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>ctrl_interface=/run/wpa_supplicant</p>
<p>update_config=1</p></td>
</tr>
</tbody>
</table>

编辑/etc/network/interfaces

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>auto wlp16s0</p>
<p>iface wlp16s0 inet dhcp</p>
<p>wpa-ssid <em>myssid</em></p>
<p>wpa-psk
<em>ccb290fd4fe6b22935cbae31449e050edd02ad44627b16ce0151668f5f53c01b</em></p></td>
</tr>
</tbody>
</table>

根据实际情况，修改红色部分。

设置完成后，龙芯派重启后会自动连接无线网。
