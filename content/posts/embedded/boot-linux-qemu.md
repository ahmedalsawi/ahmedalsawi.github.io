---
title: "Boot linux in Qemu"
date: 2019-05-11
toc: false
images:
tags:
  
  - qemu
---


This is quick guide to compile linux kernel and minimal boot in Qemu.

# Compiling linux kernel
To compile linux kernel, you will need `.config` to configure the build. To generate default `.config`:

```bash
make defconfig
```

if you are planning to upgrade the kernel version on your machine, you need to use the current config to generate compatible configuration

```bash
cp /boot/config-`kernel version` ./config
make oldconfig
```

# Creating busybox initramfs

`mkinitramfs` creates minimal busybox file system with busybox unix commands.
More importantly, the kernel will try to mount root file system by default.So, you will get kernel panic if kernel didn't find one.


```bash
mkinitramfs -o initrd.img
```

# Booting qemu
Using `qemu-system-x86_64` which is vanilla qemu (No KVM)


```bash
qemu-system-x86_64 -kernel ./arch/x86_64/boot/bzImage -initrd initrd.img -m 2048 -nographic -append "console=ttyS0"
```

After boot messages, you should see something like:

```
[    5.916979] ata_id (1021) used greatest stack depth: 14128 bytes left

...
...


BusyBox v1.27.2 (Ubuntu 1:1.27.2-2ubuntu3.2) built-in shell (ash)
Enter 'help' for a list of built-in commands.

(initramfs) uname -a
Linux (none) 4.15.0-rc6+ #12 SMP Sat May 11 11:09:29 EET 2019 x86_64 GNU/Linux
```

# Moving between console and qemu monitor
To reboot qemu, you can move to qemu monitor by `Ctrl-a` then `c`

# References
* https://nostillsearching.wordpress.com/2012/09/22/compiling-linux-kernel-and-running-it-using-qemu/
* https://www.zachpfeffer.com/single-post/Build-the-Linux-kernel-and-Busybox-and-run-on-QEMU
* http://manpages.ubuntu.com/manpages/bionic/man8/mkinitramfs.8.html
