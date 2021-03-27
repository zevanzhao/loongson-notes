# Introduction
Over clock patch for kernel 4.19.161-3 from Loongson. Developed by flygoat, modified by zevan.
This patch works for A1901 mainboard and Fuloong2.

# How-to:
1. Download the 4.19.161-3 kernel source code from  
http://ftp.loongnix.org/kernel/linux-4.19.161/Linux-4.19.161-3.tar.gz 
2. Decompress the code.
3. Copy config-4.19.161.oc to .config in the source code directory. 
3. For A1901 mainboard, patch the code by: 
 patch -p1 < A1901/kernel-4.19.161-3-Loongson_OverClock_A1901.patch
For Fulong2, patch the code by:
 patch -p1 < Fulong2/kernel-4.19.161-3-Loongson_OverClock_Fulong2.patch
4. make menuconfig if necessary
5. make -j4 ARCH=mips
6. make -j4 ARCH=mips INSTALL_MOD_PATH=./tmp modules_install
7. copy the vmlinuz file and /lib/modules/* file to /boot and /lib/modules/.
8. Edit the grub.cfg file in /boot/efi/EFI/BOOT/grub.cfg.
