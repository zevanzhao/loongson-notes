Running SPEC CPU 2006 with Loongson 3A4000 CPU.

# Hardware   
Lemote A1901 mainboard with Loongson 3A4000 CPU, 2400 MHz Unilc memory (8GB*2).
# Software  
Lemote Fedora 28 OS, GCC 8.4
# How-to 
## 1. Install some necessary packages.  

dnf group install "Development Tools"

yum install numactl numastat gcc gcc-gfortran gcc-c++ glibc-static glibc-devel glibc.mipsn32el glibc-static.mipsn32el glibc-devel.mipsn32el  libgfortran-static libstdc++-devel  libstdc++-static

## 2. Install SPEC CPU 2006.  
If you have trouble compiling the tools, please try to use the fix_src.sh script to patch the source code of SPEC CPU 2006.

## 3. Run SPEC CPU 2006 with Runbench script.
