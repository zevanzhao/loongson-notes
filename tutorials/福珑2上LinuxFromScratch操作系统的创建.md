# 福珑2上创建Linux From Scratch操作实录


# 引言

本文记录了在福珑2上创建Linux From
Scratch（LFS）的全过程，以及在应用过程中遇到的一些问题。不保证对其他用户一定适用，仅供参考。

编译LFS的环境，是航天龙梦孙海勇开发的Fedora 28龙芯版操作系统。

之前我编译过LFS 9.0，这次准备尝试LFS
10.0-systemd。用到的参考资料介绍如下：1）官方的手册：

<http://www.linuxfromscratch.org/lfs/view/stable-systemd/>

2）LFS 10.0-systemd的中文版手册

<https://bf.mengyan1223.wang/lfs/zh_CN/10.0-systemd/index.html>

3）两位前辈的经验

[<u>https://blog.csdn.net/Lina\_ACM/article/details/79736930</u>](https://blog.csdn.net/Lina_ACM/article/details/79736930)

[<u>https://blog.csdn.net/Lina\_ACM/article/details/79670603</u>](https://blog.csdn.net/Lina_ACM/article/details/79670603)

<https://github.com/lina-not-linus/LFS-BOOK-loongson>

[<u>https://www.yhi.moe/cn/2018/12/23/lfs-on-mips64-process.html</u>](https://www.yhi.moe/cn/2018/12/23/lfs-on-mips64-process.html)

4）实体书

《手把手教你构建自己的LINUX系统》，孙海勇著。

# LFS的构建流程

## 准备工作

### 准备宿主系统

宿主系统中，需要安装构建LFS所需的软件包。首先运行version-check.sh脚本。确保所需要的软件都装好了。如果缺少命令，需要自行安装。在Fedora
28下，安装所有需要的软件包：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>yum install bash binutils bison bzip2 coreutils diffutils findutils
gawk gcc gcc-c++ glibc grep gzip m4 make patch perl python3 sed tar
texinfo xz kernel-header kernel-devel</td>
</tr>
</tbody>
</table>

根据手册的说明，对部分程序有强制的特殊要求：

**Bash-3.2 (/bin/sh 必须是到 bash 的符号链接或硬连接)**

**Bison-2.7 (/usr/bin/yacc 必须是到 bison 的链接，或者是一个执行 bison
的小脚本)**

**Gawk-4.0.1 (/usr/bin/awk 必须是到 gawk 的链接)**

如果系统中的情况不是这样的，需要改掉。

注意，部分内容需要用root用户来做，部分需要更换到lfs用户。

Root和lfs都需要设置环境变量。把给LFS准备的分区挂载到/mnt/lfs。设置LFS环境变量为/mnt/lfs。建议将下面的语句放入到/root/.bash\_profile和lfs用户的~/.bashrc中。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>export LFS=/mnt/lfs</td>
</tr>
</tbody>
</table>

修改宿主系统的/etc/fstab，添加自动挂载LFS分区的语句。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>/dev/&lt;xxx&gt; /mnt/lfs ext4 defaults 1 1</td>
</tr>
</tbody>
</table>

创建$LFS/sources文件夹，正确设定文件夹的属性。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>mkdir -v $LFS/sources</p>
<p>chmod -v a+wt $LFS/sources</p></td>
</tr>
</tbody>
</table>

下载所有LFS需要的文件

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>wget --input-file=wget-list --continue
--directory-prefix=$LFS/sources</td>
</tr>
</tbody>
</table>

有一些文件不能正常下载，需要换一个镜像来下载，比如在http://www.linuxfromscratch.org/mirrors.html
中的files mirrors。

建议访问国内镜像，直接下载打包好的文件：

[<u>https://mirrors.ustc.edu.cn/lfs/lfs-packages/10.0/</u>](https://mirrors.ustc.edu.cn/lfs/lfs-packages/9.0/)

[<u>https://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-10.0.tar</u>](https://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-9.0.tar)

将上面的文件包解开，进行必要的md5校验

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>pushd $LFS/sources</p>
<p>md5sum -c md5sums</p>
<p>popd</p></td>
</tr>
</tbody>
</table>

### 构建临时环境

创建必要的目录，包括$LFS/{bin,etc,lib,sbin,usr,var, tools}。

我希望构建的是mips64el版本的LFS。在编译过程中，部分文件会被安装到./lib文件夹中，部分会./lib64文件夹中。在寻找库文件的时候，不同的程序会到不同的文件夹(./lib64或者.lib/)中去搜索库文件，这给LFS的创建带来了很大的困扰。因此，我做了如下的操作：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p><strong>ln -s $LFS/lib $LFS/lib64</strong></p>
<p><strong>mkdir -pv $LFS/usr/lib</strong></p>
<p><strong>ln -s $LFS/usr/lib $LFS/usr/lib64</strong></p>
<p><strong>mkdir -pv $LFS/tools/lib</strong></p>
<p><strong>ln -s $LFS/tools/lib $LFS/tools/lib64</strong></p></td>
</tr>
</tbody>
</table>

编译交叉工具链过程中，程序会被安装在 $LFS/tools 目录中。

新建一个名为lfs的用户，并且修改~/.bashrc文件

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>cat &gt; ~/.bashrc &lt;&lt; "EOF"</p>
<p>set +h</p>
<p>umask 022</p>
<p>LFS=/mnt/lfs</p>
<p>LC_ALL=POSIX</p>
<p><strong>LFS_TGT=mips64el-lfs-linux-gnu</strong></p>
<p>PATH=/usr/bin</p>
<p>if [ ! -L /bin ]; then PATH=/bin:$PATH; fi</p>
<p><strong>PATH=$LFS/tools/bin:$PATH</strong></p>
<p>export LFS LC_ALL LFS_TGT PATH</p>
<p><strong>export MAKEFLAGS='-j4'</strong></p>
<p>EOF</p></td>
</tr>
</tbody>
</table>

注意，这里设置了PATH的目录为$LFS/tools/bin/，以及set +h关闭 bash
的散列功能。在创建LFS系统的工具链的过程中，交叉工具链程序会安装在$LFS/tools/bin/，并在后续的编译中启用。

**特别需要注意的是，LFS\_TGT被手工设置为了mips64el-lfs-linux-gnu。如果按照LFS手册来，这个LFS\_TGT会被设置为mips64-lfs-linux-gnu,导致编译出来的程序是大端序的程序，而非小端序的程序，最终导致LFS构建失败。**

由于龙芯3A4000有4个处理器核，因此在编译的时候可以用4个核并行编译，所以添加了MAKEFLAGS环境变量，能够大幅减少编译时间。

要深入了解LFS构建的原理，请参考：

<https://bf.mengyan1223.wang/lfs/zh_CN/10.0-systemd/partintro/toolchaintechnotes.html>

### 编译binutils pass1

在二代龙芯派下，编译耗时18分钟（只看make的耗时）；在福珑2下，编译耗时2m
6s。所以，3A4000的性能大概是二代派的9倍，单核性能是二代派的4.5倍。

Configure的时候，加上--with-lib-path的选项。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>../configure --prefix=$LFS/tools \</p>
<p>--with-sysroot=$LFS \</p>
<p><strong>--with-lib-path="/lib:/usr/lib/" \</strong></p>
<p>--target=$LFS_TGT \</p>
<p>--disable-nls \</p>
<p>--disable-werror</p></td>
</tr>
</tbody>
</table>

据此估算，如果加上configure的时间，编译binutils的耗时，即一个SBU，大约是2分钟。根据SBU的时间，可以估计其他程序编译的耗时。

各种CPU一个SBU的时间长度。

表1 不同型号的处理器SBU时间

<table>
<colgroup>
<col style="width: 46%" />
<col style="width: 23%" />
<col style="width: 8%" />
<col style="width: 22%" />
</colgroup>
<tbody>
<tr class="odd">
<td>处理器型号</td>
<td>主频（GHz）</td>
<td>核数</td>
<td>SBU</td>
</tr>
<tr class="even">
<td>龙芯2K1000（龙芯派）</td>
<td>1.0</td>
<td>2</td>
<td>19m</td>
</tr>
<tr class="odd">
<td>龙芯3A4000（福珑2）</td>
<td>1.5（睿频1.8G）</td>
<td>4</td>
<td>2m6s</td>
</tr>
<tr class="even">
<td>BCM2711 SoC （树莓派4）</td>
<td>1.5</td>
<td>4</td>
<td>4m</td>
</tr>
<tr class="odd">
<td>AMD Athlon X2</td>
<td>2.5</td>
<td>2</td>
<td>15m</td>
</tr>
<tr class="even">
<td>Intel Celeron N2840</td>
<td>2.16</td>
<td>2</td>
<td>6m17.613s</td>
</tr>
<tr class="odd">
<td>AMD FX-8350 (over clock)</td>
<td>4.4</td>
<td>8</td>
<td>1.23m</td>
</tr>
<tr class="even">
<td>Intel Atom 330</td>
<td>1.6</td>
<td>2</td>
<td>19m</td>
</tr>
<tr class="odd">
<td>BCM2835（Raspberry Pi Zero W）</td>
<td>0.7</td>
<td>1</td>
<td>58m51.823s</td>
</tr>
<tr class="even">
<td>Intel Xeon E5-1650</td>
<td>3.2</td>
<td>6</td>
<td>2m37s(without -j)</td>
</tr>
<tr class="odd">
<td>PowerPC G5</td>
<td>2.0</td>
<td>2</td>
<td>4m17.748s</td>
</tr>
<tr class="even">
<td>Intel Core i5-3470</td>
<td>3.2</td>
<td>4</td>
<td>0m41.302s</td>
</tr>
<tr class="odd">
<td>Intel Core i3-550</td>
<td>3.2</td>
<td>2</td>
<td>1m38.310s</td>
</tr>
<tr class="even">
<td>Qualcomm Snapdragon 410 MSM8916</td>
<td>1.2</td>
<td>4</td>
<td>30m51.855s</td>
</tr>
<tr class="odd">
<td>Intel Core i5-6300HQ</td>
<td>2.3</td>
<td>4</td>
<td>0m42.588s</td>
</tr>
</tbody>
</table>

数据来源：

<https://www.linuxquestions.org/questions/linux-from-scratch-13/what-cpu-are-you-using-and-what-is-your-sbu-4175634812/page2.html>

Binutils 编译出来的程序，比较重要的有汇编器as和链接器ld。

ld --verbose | grep SEARCH
会输出当前的搜索路径及其顺序，确认它会使用正确的路径：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>$LFS_TGT-ld --verbose |grep SEARCH</p>
<p>./mips64el-lfs-linux-gnu-ld --verbose |grep SEARCH</p>
<p>SEARCH_DIR("=/mnt/lfs/tools/mips64el-lfs-linux-gnu/lib32");
SEARCH_DIR("/lib"); SEARCH_DIR("/usr/lib/");
SEARCH_DIR("=/mnt/lfs/tools/mips64el-lfs-linux-gnu/lib");</p></td>
</tr>
</tbody>
</table>

### GCC pass 1

编译的时候，需要根据龙芯的环境作出修改，参考Yhi
Junde的blog、<https://www.yhi.moe/cn/2018/12/23/lfs-on-mips64-process.html>

对于x86\_64位平台,还要设置存放 64 位库的默认目录为
“lib”。之前我已经将建立了指向/lib的符号链接lib64，所以在这里不修改t-linux64文件了。

运行configure的时候，增加一行修改如下：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><strong>--with-abi=64 --with-arch=mips64r5 --with-tune=gs464e
--with-nan=2008</strong></td>
</tr>
</tbody>
</table>

先试试--with-nan=2008是否可以正常编译，如果不行就改掉这个参数。

在执行它的 configure 脚本时，从输出中检查使用的汇编器和链接器的路径：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>checking for as...
/mnt/lfs/tools/mips64el-lfs-linux-gnu/bin/as</p>
<p>...</p>
<p>checking for ld...
/mnt/lfs/tools/mips64el-lfs-linux-gnu/bin/ld</p></td>
</tr>
</tbody>
</table>

根据LFS手册，GCC pass 1构建需要12 SBU。Make实际耗时21m16s。

编译过gcc以后，看看现阶段gcc使用的链接器：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p><strong>$LFS_TGT-gcc -print-prog-name=ld</strong></p>
<p><strong>/mnt/lfs/tools/lib/gcc/mips64-lfs-linux-gnu/10.2.0/../../../../mips64-lfs-linux-gnu/bin/ld</strong></p></td>
</tr>
</tbody>
</table>

### Linux-5.8.3 API headers

### Glibc

Make耗时7m34s

进行测试：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>echo 'int main(){}' &gt; dummy.c</p>
<p>$LFS_TGT-gcc dummy.c</p>
<p>readelf -l a.out | grep '/ld'</p></td>
</tr>
</tbody>
</table>

输出结果为:

\[\[Requesting program interpreter: /lib64/ld-linux-mipsn8.so.1\]

### Libstdc++

## 编译临时工具环境

### m4

### Ncurses

### Bash

### Coreutils

### Diffutils

### File

Make 的报错

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Cannot use the installed version of file (5.33) to</p>
<p>cross-compile file 5.39</p>
<p>Please install file 5.39 locally first</p></td>
</tr>
</tbody>
</table>

为了修正这个报错，编译安装了file 5.39，替换了宿主系统中的file 5.33

解压缩file-5.39

./configure --prefix=/usr/

Make

Make install

这样会把libmagic.so.1.0.0安装到/usr/lib/而不是/lib64/，需要将/lib64中的libmagic.so.1.0.0备份，然后替换掉。

搞完LFS以后，可以用yum reinstall file file-libs 覆盖掉file 5.39的文件。

### Findutils

### Gawk

### Grep

### Gzip

### Make

### Patch

### Sed

### Tar 

### Xz

### Binutil pass 2

与pass1类似，configure的时候设置：

--with-lib-path=”/lib:/usr/lib”

Make 耗时3m5.891s

### Gcc pass 2

编译过程与gcc pass1类似 configure的时候增加一行：

**--with-abi=64 --with-arch=mips64r5 --with-tune=gs464e
--with-nan=2008**

Make 耗时25m57.793s

## 进入 Chroot 并构建其他临时工具

### Stdc++ pass 2

Configure的时候，需要修改其中的--host，还是不能直接用$(uname
-m)-lfs-linux-gnu修改以后的脚本为：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>../libstdc++-v3/configure \</p>
<p>CXXFLAGS="-g -O2 -D_GNU_SOURCE" \</p>
<p>--prefix=/usr \</p>
<p>--disable-multilib \</p>
<p>--disable-nls \</p>
<p><strong>--host=mips64el-lfs-linux-gnu \</strong></p>
<p>--disable-libstdcxx-pch</p></td>
</tr>
</tbody>
</table>

切记，在chroot环境中编译！不要搞错了！否则会死的很惨很惨的！

### Gettext

### Bison

### Perl 5.32

### Python 3.8.5

### Texinfo

### Util-Linux-2.36

清理和备份临时系统。

记得要卸载掉已经挂载到/mnt/lfs中的/dev, /proc等文件系统。

##  **LFS正式系统的编译**

创建必要的文件夹，挂载必要的文件夹。**注意：Debian系统下，/dev/shm
不是/run/shm的符号链接。**

可以将mount和chroot命令写入一个脚本，方便出现中断时能够继续编译。

一旦chroot到临时系统，就无法用文本编辑器了。解决办法有三个：

1.  提前写好一些脚本，方便后续使用。

2.  另外开一个远程登录的终端，在里面写脚本。在chroot的系统内执行，以减少文字的输入。

3.  先手动安装一个编辑器。简单的文本编辑，我选择用nano。根据下面的教程来安装nano

    <http://www.linuxfromscratch.org/blfs/view/10.0/postlfs/nano.html>

    **一定要注意:**

    **编译的时候要在chroot环境中进行!**

    **编译的时候要在chroot环境中进行!**

    **编译的时候要在chroot环境中进行！**

    **重要的事情说三遍，切记切记！不然可能破坏宿主系统，导致出现需要重装的惨烈后果！**

<!-- -->

1.  Man-pages

2.  TCL

    在configure的时候，需要加上--enable-64bit

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>./configure --prefix=/usr \</p>
<p>--mandir=/usr/share/man \</p>
<p><strong>--enable-64bit</strong></p></td>
</tr>
</tbody>
</table>

1.  Expect

2.  DejaGNU

    5\. Iana-Etc

    6\. Glibc

    Make耗时7m46s。Make check非常耗时，大概79分钟。Make
    check，会有一些失败，不过应该是正常的。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Summary of test results:</p>
<p>47 FAIL</p>
<p>4057 PASS</p>
<p>24 UNSUPPORTED</p>
<p>18 XFAIL</p>
<p>2 XPASS</p></td>
</tr>
</tbody>
</table>

调整时区，选择Asia/Shanghai

1.  Zlib

2.  Bzip2

3.  XZ

4.  Zstd

5.  File

6.  Readline

7.  M4

8.  BC

9.  Flex

10. Binutils

    Configure 的时候增加一句：

    **--with-lib-path="/lib:/usr/lib/"**

注意：需要进行简单测试，确认伪终端 (PTY) 在 chroot 环境中能正常工作：

expect -c "spawn ls"

该命令应该输出：

spawn ls

如果输出不是上面这样，而是下面的消息，就说明环境没有为 PTY
的正常工作设置好。**在运行 Binutils 和 GCC
的测试套件前必须解决这个问题。 否则测试的时候会大量的报错！**

Make -k check 的时候有一些报错，不过应该都可以安全的无视。

1.  Gmp

    注意在configure的时候增加ABI=64

2.  MPFR

3.  MPC

4.  Attr

5.  Acl

6.  Libcap

7.  Shadow

8.  GCC 10.2.0

    又到了编译gcc的时候了，需要特别的小心。

    这次编译的是正式的gcc，我需要Fortran的编译器，因此参考

    <http://www.linuxfromscratch.org/blfs/view/10.0/general/gcc.html>

    由于lib和lib64已经做了符号链接，跳过修改t-linux64的步骤。

    Configure的脚本如下：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>../configure \</p>
<p>--prefix=/usr \</p>
<p>LD=ld \</p>
<p><strong>--enable-languages=c,c++,d,fortran,go,objc,obj-c++
\</strong></p>
<p>--disable-multilib \</p>
<p>--disable-bootstrap \</p>
<p>--with-system-zlib \</p>
<p><strong>--with-abi=64 --with-arch=mips64r5 --with-tune=gs464e
--with-nan=2008</strong></p></td>
</tr>
</tbody>
</table>

小心的开始编译

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>time make -j4</td>
</tr>
</tbody>
</table>

耗时29m。下面开始测试

注意：需要进行简单测试，确认伪终端 (PTY) 在 chroot 环境中能正常工作：

expect -c "spawn ls"

该命令应该输出：

spawn ls

如果输出不是上面这样，而是下面的消息，就说明环境没有为 PTY
的正常工作设置好。**在运行 Binutils 和 GCC
的测试套件前必须解决这个问题。 否则测试的时候会大量的报错！**

下面是测试的摘要

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>../contrib/test_summary |grep -A7 Summ</p>
<p>=== g++ Summary ===</p>
<p># of expected passes 181389</p>
<p># of unexpected failures 54</p>
<p># of expected failures 705</p>
<p># of unresolved testcases 3</p>
<p># of unsupported tests 8348</p>
<p>/sources/gcc-10.2.0/build/gcc/xg++ version 10.2.0 (GCC)</p>
<p>--</p>
<p>=== gcc Summary ===</p>
<p># of expected passes 141328</p>
<p># of unexpected failures 86</p>
<p># of unexpected successes 8</p>
<p># of expected failures 745</p>
<p># of unsupported tests 4132</p>
<p>/sources/gcc-10.2.0/build/gcc/xgcc version 10.2.0 (GCC)</p>
<p>--</p>
<p>=== gfortran Summary ===</p>
<p># of expected passes 53983</p>
<p># of unexpected failures 5</p>
<p># of expected failures 183</p>
<p># of unsupported tests 162</p>
<p>/sources/gcc-10.2.0/build/gcc/gfortran version 10.2.0 (GCC)</p>
<p>--</p>
<p>=== libatomic Summary ===</p>
<p># of expected passes 54</p>
<p>=== libgomp tests ===</p>
<p>Running target unix</p>
<p>FAIL: libgomp.c/../libgomp.c-c++-common/for-12.c execution test</p>
<p>--</p>
<p>=== libgomp Summary ===</p>
<p># of expected passes 7592</p>
<p># of unexpected failures 4</p>
<p># of expected failures 2</p>
<p># of unsupported tests 595</p>
<p>=== libstdc++ tests ===</p>
<p>--</p>
<p>=== libstdc++ Summary ===</p>
<p># of expected passes 13884</p>
<p># of unexpected failures 11</p>
<p># of expected failures 93</p>
<p># of unsupported tests 422</p>
<p>Compiler version: 10.2.0 (GCC)</p></td>
</tr>
</tbody>
</table>

1.  Pkg-config

2.  Ncurses

3.  Sed

4.  Psmisc

5.  Gettext

6.  Bison

7.  Grep

8.  Bash

9.  Libtool

    测试的时候有6个已知的fail，可以安全无视。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>ERROR: 152 tests were run,</p>
<p>71 failed (66 expected failures).</p>
<p>18 tests were skipped.</p>
<p>testsuite: 123 124 125 126 130 failed</p></td>
</tr>
</tbody>
</table>

1.  GDBM

2.  Gperf

3.  Expat

4.  Inetutils

5.  Perl

6.  XML::Parser

7.  Intltool

8.  Autoconf

9.  Automake

10. Kmod

11. [Libelf from
    Elfutils-0.180](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/libelf.html)

    Make check的时候有一些错误。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>============================================================================</p>
<p>Testsuite summary for elfutils 0.180</p>
<p>============================================================================</p>
<p># TOTAL: 218</p>
<p># PASS: 202</p>
<p># SKIP: 9</p>
<p># XFAIL: 0</p>
<p># FAIL: 7</p>
<p># XPASS: 0</p>
<p># ERROR: 0</p></td>
</tr>
</tbody>
</table>

1.  [Libffi-3.3](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/libffi.html)

2.  [OpenSSL-1.1.1g](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/openssl.html)

    Configure的时候需要小心

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>./Configure linux64-mips64</p>
<p>--prefix=/usr \</p>
<p>--openssldir=/etc/ssl \</p>
<p>--libdir=lib \</p>
<p>shared \</p>
<p>zlib-dynamic</p></td>
</tr>
</tbody>
</table>

1.  [Python-3.8.5](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/Python.html)

2.  [Ninja-1.10.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/ninja.html)

3.  [Meson-0.55.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/meson.html)

4.  [Coreutils-8.32](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/coreutils.html)

    Make test的时候有一个fail

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p># TOTAL: 625</p>
<p># PASS: 494</p>
<p># SKIP: 130</p>
<p># XFAIL: 0</p>
<p># FAIL: 1</p>
<p># XPASS: 0</p>
<p># ERROR: 0</p></td>
</tr>
</tbody>
</table>

FAIL tests/misc/tty.sh (exit status: 1)

1.  [Check-0.15.2](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/check.html)

2.  [Diffutils-3.7](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/diffutils.html)

3.  [Gawk-5.1.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/gawk.html)

4.  [Findutils-4.7.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/findutils.html)

5.  [Groff-1.22.4](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/groff.html)

6.  [GRUB-2.04](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/grub.html)

    Configure的时候报错

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>hecking for FREETYPE... no</p>
<p>checking whether byte ordering is bigendian... no</p>
<p>checking for BUILD_FREETYPE... no</p>
<p>configure: error: qemu, coreboot and loongson ports need build-time
grub-mkfont (need freetype2 library)</p></td>
</tr>
</tbody>
</table>

Grub完全可以不用安装，用其他系统下的grub管理启动界面。或者等安装freetype2之后再安装。

1.  [Less-551](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/less.html)

2.  [Gzip-1.10](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/gzip.html)

    Make check的时候有fail

    FAIL: timestamp

    不管它，继续。

3.  [IPRoute2-5.8.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/iproute2.html)

4.  [Kbd-2.3.0](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/kbd.html)

5.  [Libpipeline-1.5.3](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/libpipeline.html)

6.  [Make-4.3](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/make.html)

7.  [Patch-2.7.6](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/patch.html)

8.  [Man-DB-2.9.3](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/man-db.html)

9.  [Tar-1.32](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/tar.html)

10. [Texinfo-6.7](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/texinfo.html)

11. [Vim-8.2.1361](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/vim.html)

12. [Systemd-246](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/systemd.html)

13. [D-Bus-1.12.20](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/dbus.html)

14. [Procps-ng-3.3.16](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/procps-ng.html)

15. [Util-linux-2.36](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/util-linux.html)

16. [E2fsprogs-1.45.6](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter08/e2fsprogs.html)

    2.4.17 后续配置

    网络部分

    引导时自动清屏。LFS提供了一个避免自动清屏的办法，不过我还是喜欢让它自动清屏。去掉/etc/systemd/system/getty@tty1.service.d/noclear.conf这个文件，或者改回来：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>cat &gt; /etc/systemd/system/getty@tty1.service.d/noclear.conf
&lt;&lt; EOF[Service]</p>
<p>TTYVTDisallocate=yes</p>
<p>EOF</p></td>
</tr>
</tbody>
</table>

“您总是可以用 root 身份运行 journalctl -b 命令，查阅引导消息。”

静态网络配置：跳过。准备用动态的。

设置主机名为fulong2

系统时钟配置：先跳过。

设置vconsole.conf

Keymp=us

设置locale 为en\_US.utf8

支持串口登录：<https://blog.csdn.net/a617996505/article/details/88423794>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>开机串口控制台自动登录：</p>
<p>1.一般来说，关于系统启动的相关服务会放在/etc/systemd/system/下面，进入其中搜索关于getty自动登录程序</p>
<p>find -iname "*getty*"</p>
<p>./getty.target.wants<br />
./getty.target.wants/serial-getty@ttymxc0.service</p>
<p>2.结果搜索到相关服务目录，进入目录查看： ls -l</p>
<p>总用量 0<br />
lrwxrwxrwx 1 lsy lsy 41  1月 22 10:52 serial-getty@ttymxc0.service -&gt;
/lib/systemd/system/serial-getty@.service</p>
<p>可以看的这个服务链接到/lib/systemd/system/serial-getty@.service，</p>
<p>3.打开/lib/systemd/system/serial-getty@.service，在[Service]项的ExecStart=，添加"-a
root"</p>
<p>[Service]<br />
    Environment="TERM=xterm"</p>
<p>    ExecStart=-/sbin/agetty -a root -8 -L %I 115200 $TERM<br />
    Type=idle<br />
    Restart=always<br />
    RestartSec=0<br />
    UtmpIdentifier=%I<br />
    TTYPath=/dev/%I<br />
    TTYReset=yes<br />
    TTYVHangup=yes<br />
    KillMode=process<br />
    IgnoreSIGPIPE=no<br />
    SendSIGHUP=yes</p></td>
</tr>
</tbody>
</table>

这样开机以后串口也有一个登录的界面。

内核编译部分直接跳过，直接使用Fedora28的内核。想自己编译内核的，也可以等系统引导以后再重新编译，不碍事的。

有必要的话，可以自行编译一个更合适的内核。

1.  下载内核源码

    git clone git://dev.lemote.com/linux-official.git

    下载的内核版本是5.4.83（2021年1月12日）

2.  临时修改内核源码

    目前，福珑2主机没有独立显卡，只有7A1000中内置的集成显卡。在5.4.83内核中，开启了GPU加速功能，但副作用是导致该显卡无法支持60Hz以上的刷新率。如果内核试图去支持60Hz以上的刷新率，会导致屏幕闪烁严重或者黑屏。为了解决这个问题，可以修改内核源码：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>diff --git a/drivers/gpu/drm/loongson/loongson_crtc.c
b/drivers/gpu/drm/loongson/loongson_crtc.c</p>
<p>index 1193f8ac6d88..9ae331a990c2 100644</p>
<p>--- a/drivers/gpu/drm/loongson/loongson_crtc.c</p>
<p>+++ b/drivers/gpu/drm/loongson/loongson_crtc.c</p>
<p>@@ -333,6 +333,10 @@ static enum drm_mode_status
loongson_crtc_mode_valid(struct drm_crtc *crtc,</p>
<p>return MODE_BAD;</p>
<p>}</p>
<p>+ /* HW errata: deny refresh rate larger than 60 Hz. */</p>
<p>+ if (drm_mode_vrefresh(mode) &gt; 60)</p>
<p>+ return MODE_BAD;</p>
<p>+</p>
<p>return MODE_OK;</p>
<p>}</p></td>
</tr>
</tbody>
</table>

此外，编译内核的时候，会报一个关于KVM的错，需要再次修改内核源码。原因大概是内核中大规模使用fallthrough宏来替换原来的fall
through,但注释掉了旧的fall through却忘了增加新的fallthrough.

<https://lkml.org/lkml/2020/8/9/244>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>diff --git a/arch/mips/kvm/emulate.c b/arch/mips/kvm/emulate.c<br />
index 703782355318..d70c4f8e14e2 100644<br />
--- a/arch/mips/kvm/emulate.c<br />
+++ b/arch/mips/kvm/emulate.c<br />
@@ -1935,7 +1935,7 @@ enum emulation_result kvm_mips_emulate_load(union
mips_instruction inst,<br />
<br />
case lwu_op:<br />
vcpu-&gt;mmio_needed = 1; /* unsigned */<br />
- /* fall through */<br />
+ fallthrough;<br />
#endif<br />
case lw_op:<br />
run-&gt;mmio.len = 4;</td>
</tr>
</tbody>
</table>

准备好内核源码以后，就可以开始编译了。在F28下，还需要额外准备一些软件包。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>yum install ncurses-devel xz-compat</td>
</tr>
</tbody>
</table>

1.  复制内核配置文件

    我不想自己调整内核配置文件了，直接复制Fedora28现有内核的配置文件算了。

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td>cp -v /boot/config-5.4.60* .config</td>
</tr>
</tbody>
</table>

虽然源码的版本是5.4.83，内核配置文件是给5.4.60内核用的，不过运气不错，可以直接使用。

1.  配置内核，并编译内核模块

    如果说是本地编译使用命令为：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>make ARCH=mips menuconfig</p>
<p>make -j4 ARCH=mips</p>
<p>make -j4 ARCH=mips INSTALL_MOD_PATH=./tmp modules_install</p></td>
</tr>
</tbody>
</table>

如果使用-j4导致出现死机等情况，请改成-j2。

如果是在X86机器上进行交叉编译，使用的命令为：

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>make ARCH=mips CROSS_COMPILE=mips64el-linux- menuconfig</p>
<p>make -j4 ARCH=mips CROSS_COMPILE=mips64el-linux-</p>
<p>make -j4 ARCH=mips CROSS_COMPILE=mips64el-linux-
INSTALL_MOD_PATH=./tmp modules_install</p></td>
</tr>
</tbody>
</table>

编译结束以后，当前文件夹下会生成vmlinuz文件。如果没有生成vmlinuz文件，那么肯定是缺少lzma的包了，把它装上，再重新make
一下内核。接下来，将内核文件复制到正确的位置。

cp vmlinuz /boot/vmlinuz-5.4.83+

cp -avr ./tmp/modules/5.4.83+ /lib/modules/

最后，根据系统的情况，酌情修改grub.cfg文件，增加LFS的启动项，以顺利启动操作系统。

配置好了，重启，在grub界面选择LFS系统，设置无误的话就可以正常进入系统了！

刚编译完成的LFS只包含最最基本的包，距离生产力还差得很远。想要更顺利的使用，还需要安装更多的软件包。

2.4.18 BLFS包安装

参考BLFS手册，进行设置。

<http://linuxfromscratch.org/blfs/view/stable/>

安装Nano

文档：<http://linuxfromscratch.org/blfs/view/stable/postlfs/nano.html>

Nano依赖ncurses。编译完ncurses，就可以安装nano。

安装openssh

文档：<http://linuxfromscratch.org/blfs/view/stable/postlfs/openssh.html>

Openssh依赖openssl。

注意需要下载BLFS脚本

<http://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20190609.tar.xz>

安装wget

文档：<http://linuxfromscratch.org/blfs/view/stable/basicnet/wget.html>

Dhcp（可选，我还没有安装）

用于自动获取IP。这样就不需要自己手工设置IP了。

<http://linuxfromscratch.org/blfs/view/stable/basicnet/dhcpcd.html>

1.  **LFS编译过程的个人经验和建议**

    3.1 经验

    LFS编译很繁琐，建议做好笔记，做个表格，记录一下自己做到哪一步了。

    3.2 有可能犯的错误

    1.  少敲命令，多敲命令，拼写错误。比如，make check以后忘记make
        install。没有什么好的解决办法，多注意。

    2.  忘记在chroot环境中编译。在chroot环境中，连vim都没有，编辑文件都不方便，所以，我会同时开两个终端，第一个没有chroot的终端下编辑LFS用的脚本，第二个终端在chroot下编译LFS。经常会在第一个终端下编辑完脚本以后顺手就跑了一遍，发现错误以后再重新在chroot终端下跑一遍。为了防止出现这个错误，个人建议是在chroot环境中编译完成ncurses以后就立即编译一个nano或者vim编辑器，然后直接在chroot环境中编辑必要的文件，避免犯错。

        **致谢**

        感谢孙海勇、flygoat、陈华才、以及周琰杰等大佬的在我编译LFS过程中给与的帮助和鼓励。
