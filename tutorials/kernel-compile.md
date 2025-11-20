# kernel 6.x 内核编译编译
 
当内核中提供的功能不够丰富，可能需要重新编译内核。 以给linux-source-6.9内核添加kvm模块为例，步骤如下：

1. 下载内核，解压缩
```bash
tar xvfJ linux-source-6.9.tar.xz
cd linux-source-6.9
```

2. 复制配置文件
```bash
cp /boot/config-6.9.12-loong64 .config
```
这一步也可以改为
```bash
cp arch/loongarch/configs/loongson3_defconfig .config
```
3. 修改Makefile

修改一下版本号，以区别于现有的内核版本。
```makefile
VERSION = 6
PATCHLEVEL = 9
SUBLEVEL = 12
EXTRAVERSION =-kvm-loong64
```
4. 配置内核选项
```bash
make menuconfig ARCH=loongarch
```

6.9内核龙架构下默认不包含kvm模块，需要在配置的时候选中kvm模块。

**注意**：去掉关于内核调试(kernel hacking)相关的内容，否则编译时间会非常长，编译出来的内核也会非常巨大（～300MB）。

具体需要进入:
`Kernel Hacking -> Compile-time checks and compiler options`

开启 `DEBUG_INFO_NONE`

取消 `CONFIG_DEBUG_INFO  DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT DEBUG_INFO_DWARF4  DEBUG_INFO_DWARF5` 

5. 编译内核及模块

```bash
make ARCH=loongarch -j 8
make modules_install INSTALL_MOD_PATH=./
```

生成的vmlinux大小在22MB左右。

**注意**  vmlinuz文件会自动生成为`arch/loongarch/boot/vmlinuz.efi`, 后缀是`.efi`, 文件的类型为：`PE32+ executable for EFI (application), LoongArch 64-bit (stripped to external PDB), 2 sections`。

`arch/loongarch/boot`/内还有一个vmlinuz文件，该文件不是grub需要的文件！

6. 复制必要的文件

```bash
cp arch/loongarch/boot/vmlinuz.efi /boot/vmlinuz-6.9.12-kvm-loong64
cp -r lib/modules/6.9.12-kvm-loong64 /lib/modules/
cp .config /boot/config-6.9.12-kvm-loong64`

```

7. 运行mkinitramfs,生成initrd.img文件
```bash
mkinitramfs -o initrd.img-6.9.12-kvm-loong64 6.9.12-kvm-loong64
```

需要指定我们要用的内核版本是6.9.12-kvm-loong64，这样程序才会去/lib/modules/6.9.12-kvm-loong64中寻找内核模块。

至此，内核编译完成，修改grub.cfg文件，就可以用新的内核启动了。

