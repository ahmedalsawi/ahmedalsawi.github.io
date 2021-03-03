---
title: "Building OSS FPGA Toolchain"
date: 2020-02-09
toc: false
images:
tags:
  - fpga
  
  - eda
---

# Introduction

I used yosys occasionally but never tried the whole yosys-nexpnr-icestorm toolchain. This post documents the steps to compile the toolchain. Spoiler alert, the order is important.

# Setup

```bash
export BASRPATH=$PWD
export OSSFPGA=$BASRPATH/opt
export MAKEPARALLEL="-j4"
```

```bash
sudo apt-get install build-essential clang bison flex \
                libreadline-dev gawk tcl-dev libffi-dev git \
                graphviz xdot pkg-config python3 libboost-system-dev \
                libboost-python-dev libboost-filesystem-dev zlib1g-dev \
                libboost-program-options-dev libboost-thread-dev libboost-iostreams-dev \
                libftdi-dev libeigen3-dev qtbase5-dev
```

# Building Yosys

```bash

git clone https://github.com/YosysHQ/yosys.git
cd yosys
make config-gcc
make $MAKEPARALLEL
make install PREFIX=$OSSFPGA
cd $BASRPATH
```

# Building trellis

```bash
git clone https://github.com/SymbiFlow/prjtrellis
cd prjtrellis/libtrellis
cmake -DCMAKE_INSTALL_PREFIX=$OSSFPGA .
make $MAKEPARALLEL
make install
cd $BASRPATH
```

# Building icestorm

```bash
git clone https://github.com/cliffordwolf/icestorm.git
cd icestorm
make
make install PREFIX=$OSSFPGA
cd $BASRPATH
```

# Building nextpnr

```bash
git clone https://github.com/YosysHQ/nextpnr.git
cd nextpnr
mkdir build
cd build
cmake .. -DARCH=all -DCMAKE_INSTALL_PREFIX=$OSSFPGA -DTRELLIS_ROOT=$BASRPATH/prjtrellis \
 -DICEBOX_ROOT=$OSSFPGA/share/icebox
make
make install
cd $BASRPATH
```
