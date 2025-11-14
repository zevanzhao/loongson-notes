# Qtcreator的使用
UOS和麒麟系统中的QtCreator,安装以后无法启动。
具体表现是:
```
qtcreator 
mesa: CommandLine Error: Option 'help-list' registered more than once!
LLVM ERROR: inconsistency in registered CommandLine options
```

经过检索，发现是已知问题, 出现问题的插件是`/usr/lib/loongarch64-linux-gnu/qtcreator/plugins/libClangTools.so` 插件。

两种解决方案：
1. [不加载clang插件启动](https://blog.csdn.net/qq_43680827/article/details/143133478) 
2. [直接删掉这个插件，或者改名](https://cloud.tencent.com/developer/article/2491025)
