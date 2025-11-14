liblol是在Debian等新世界操作系统中运行旧世界应用软件的一个兼容工具。
它的安装教程，可以参考[如下的地址](https://liblol.aosc.io/docs/usage/#debian) 

首先，在此页面下载最新版本的内核模块包 `liblol-dkms_0.1.1_loong64.deb` 并执行如下命令安装：
```bash
sudo apt install ./liblol-dkms_0.1.1_loong64.deb
```
安装完成后，在此页面下载最新版本的 libLoL 运行时包 `liblol_0.1.9-1_loong64.deb`，随后执行如下命令安装：
```bash
sudo apt install ./liblol_0.1.9-1_loong64.deb
```
**注意**
1. 如果使用Loongnix 25操作系统, 要注意该操作系统安装了另外一套新旧世界的兼容方案abi-compat，该方案与liblol存在冲突。如果要使用liblol，需要删除abi-compat。
2. 安装了liblol以后，需要重新启动操作系统。否则可能还是不能使用旧世界程序（如QQ和微信）。