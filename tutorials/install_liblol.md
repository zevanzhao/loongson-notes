liblol是在Debian等新世界操作系统中运行旧世界应用软件的一个兼容工具。
它的安装教程，可以参考[如下的地址](https://liblol.aosc.io/docs/usage/#debian) 

1. 首先，确保已经安装了当前内核的头文件包：
```
sudo apt install linux-header-loong64
```
如果没有安装头文件，liblol的dkms模块将无法正常编译。

2. 随后，在此页面下载最新版本的内核模块包 `liblol-dkms_0.1.1_loong64.deb` 并执行如下命令安装：
```bash
sudo apt install ./liblol-dkms_0.1.1_loong64.deb
```

安装过程会触发dkms模块的编译，生成`/lib/modules/$(uname -r)/updates/dkms/la_ow_syscall.ko.xz`文件。

初次编译以后，内核模块不会被自动加载。你可以重新启动计算机，也可以选择手动加载内核模块
```bash
modprobe la_ow_syscall
```

3. 随后，运行lsmod命令，查看内核模块加载是否正常
```bash
lsmod |grep la_ow
```
如果上述命令输出为空，则表明模块加载不正常。

4. 安装完成后，在此页面下载最新版本的 libLoL 运行时包 `lliblol_0.1.11-1_loong64.deb`，随后执行如下命令安装：
```bash
sudo apt install ./liblol_0.1.11-1_loong64.deb
```
**注意**
1. 如果使用Loongnix 25操作系统, 要注意该操作系统安装了另外一套新旧世界的兼容方案abi-compat，该方案与liblol存在冲突。如果要使用liblol，需要删除abi-compat。
2. 安装了liblol以后，需要重新启动操作系统。否则可能还是不能使用旧世界程序（如QQ和微信）。
3. 在2026年8月份，Debian Testing 操作系统中的glibc版本已经升级到2.43。旧版本的`liblol 0.1.10-1` 中支持的glibc 最高版本为2.42, 新版本的`liblol 0.1.11-1`中支持的glibc最高版本为2.44。所以，在Debian Testing中记得安装新版的liblol。
