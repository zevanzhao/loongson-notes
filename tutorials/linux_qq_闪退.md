# Linux QQ  使用问题

## 问题1： 闪退问题
出现问题的QQ版本 linuxqq_3.2.18-37625。问题表现为闪退。

这个问题有三个解决方案

### 方案1: 版本回退
回退版本到3.2.18-36580

### 方案2： 旧版本文件替换
从旧版本的LinuxQQ中，找到文件`libvips-cpp.so.42`
将这个文件，复制到新版本的QQ的安装目录内
```bash 
cp libvips-cpp.so.42 /opt/QQ/resources/app/sharp-lib/
```
### 方案3: 用系统的libvips取代QQ中自带的libvips
重命名QQ中的libvips,并安装新版本的libvips
```
mv -v /opt/QQ/resources/app/sharp-lib/libvips-cpp.so.42 /opt/QQ/resources/app/sharp-lib/libvips-cpp.so.42.bak
apt install libvips-dev
```
QQ启动的时候，会使用系统自带的libvips-dev,而不是自带的libvips-dev
再重新启动QQ,闪退的问题解决。

## 问题2:启动后报错Failed to configure SIGSYS handler

具体的表现是，启动QQ以后，程序报错退出，有这样的报错信息：
```
[16285:0214/113225.931135:FATAL:sandbox/linux/seccomp-bpf/trap.cc:112] Failed to configure SIGSYS handler
```
之所以出现问题，是因为la_ow_syscall模块没有被正确编译和加载。沙箱功能需要内核模块的支持。

解决方案也有两种。

### 方案1： 彻底根治
正确的解决方案是确保la_ow_syscall 模块被正确编译和加载。

具体方案可以参考[liblol的安装](./install_liblol.md)

### 方案2： 治标不治本

当无法使用第一个解决方案的时候，简单的解决方案是`Run the application with the --no-sandbox flag`

启动QQ的时候，添加`--no-sandbox`参数。
修改`/usr/share/applications/qq.desktop`文件，将启动的命令从
```text
Exec=/opt/QQ/qq %U
```
改为:
```text
Exec=/opt/QQ/qq --no-sandbox %U
```