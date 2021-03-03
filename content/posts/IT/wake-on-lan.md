---
title: "Wake on LAN"
date: 2020-08-29T15:46:08+02:00
toc: false
images:
tags:
  - IT
---

There is a cool protocol to boot machine remotely called [Wake on LAN][3]. Considering i am using RPI as gateway, This allows me to start my machine remotely and poweroff if not needed.

# Enable WOL in BIOS/UEFI

This has to be supported by hardware and it's usually disabled by default. On my mobo, It's named "Power On by PCIE". So, that has to be enabled first.

# Enable WOL in ethernet driver

following the steps [page][2], we need ethtool to change the ethernet driver from _d_ (default) to _g_(magic).

```bash
ethtool -s <NETWORK INTERFACE> wol g
```

## Make WOL persistent

from [page][4], interfaces resets the WOL flag on boot. so, we need to create a systemd service to set it back to magic after boot.

```bash
vi /etc/systemd/system/wol.service
```

use the following service

```
[Unit]
Description=Configure Wake On LAN

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s INTERFACE wol g

[Install]
WantedBy=basic.target
```

Restart systemd

```bash
sudo systemctl daemon-reload
sudo systemctl enable wol.service
sudo systemctl start wol.service
```

# Booting the machine

To start a machine, we need the MAC of that machine and connection a machine on the same network.

```bash
sudo etherwake <MAC> -i <INTERFACE>
```

[1]: https://wiki.archlinux.org/index.php/Wake-on-LAN
[2]: https://wiki.debian.org/WakeOnLan
[3]: https://en.wikipedia.org/wiki/Wake-on-LAN
[4]: https://www.techrepublic.com/article/how-to-enable-wake-on-lan-in-ubuntu-server-18-04/
[5]: https://www.tp-link.com/eg/support/faq/2156/
