---
title: "SSH jump server on Raspberry pi"
date: 2020-08-02T18:46:08+02:00
toc: false
images:
tags:
  
  - IT
---

# Introduction

These are the steps to setup Raspberry pi as ssh [jump server][1]. Well, It's not exactly Fort Knox but it's better than exposing my machine directly to internet. This way i can ssh into RPI first then ssh into a machine on local network.

# Get Dynamic DNS

The first step is getting dynamic DNS. The problem is ISP can change my real IP any time(usually when router reboots). So, I need to either pay for fixed IP(obviously i am too cheap to do that) or setup dynamic DNS. So, I quickly researched DDNS services and chose [no-ip][2]. It's free but i need to login every 30 days which is not a deal breaker.

# RPI setup

I had RPI v1 that i never used after the initial testing 7 years ago. So, I thought put it to good use. I downloaded [Raspberry Pi OS Lite][3]. it should be good enough because i am running it headless and i don't need full-blown desktop environment.

Following the steps in [page][4] and `dd` the image on the SD card.

## ssh boot

I did some research to see if 1 need something specific for ssh. and i was right. According to [page][5], SSH need to find file `ssh` in `boot` partition.

So, I mounted the boot partition, created the file, umount the SD card and we are good to go.

## Connecting to RPI

Once I connected te Ethernet and USB power, it saw the leds blinking. Good sign!

I figured outRPI IP by checking the router connected devices. i could have done network scanning but life is too short!.

At this point, I need the user and password initial setup for `Raspberry pi OS`. and viola, it also mentioned in [page][5].

```
username: pi
password: raspberry
```

once I ssh'ed into RPI, I changeed the password for `pi` user. _THIS IS IMPORTANT_

## Setting static IP

To connect to RPI easily, it's good idea to set a static IP. The details are at [page][6]. but basically, It's just telling DHCP to use that static IP.

```bash
sudo vi  /etc/dhcpcd.conf
```

And changed the addr and router to required IP and router gateway.

```
static ip_address=192.168.0.10/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1
```

Finally, reboot or restart DHCP.

## Harden SSH

I can do the same steps i follow while setting up VPS. good resource at [here][7]. usually disabling root login and fail2ban.

# Configure Router

The next steps are router-specific. So, i will keep very high level.

## Dynamic DNS

Setup DDNS to point to `no-ip` hostname configured earlier. In my case, it was under "network" -> Advanced.

It seems like not all routers support that. if it's doesn't, there is usually some software to run on the machine to get IP updates. Anyway, my router supports DDNS. So, I just added `no-ip` username, password and domain.

## Port forwarding

This is the most important step. This is basically telling the router to direct traffic coming on Port X to RPI IP and port.

for my router, it was under "NAT Forwarding", Then "virtual server". For this to work, it's required to have:

- internal IP
- internal Port
- External Port

let's say traffic coming `real_ip:external_port` will forward `internal_ip:internal_port`.

for ssh, default port is 22. so, the internal port is 22 unless it's changed.

## Bonus: IP Address Reservation

beside setting up static IP on the RPI, I also setup added RPI static IP and MAC to DHCP `reservation list`.

I don't really need to do that but it wouldn't hurt to restrict that IP to RPI MAC number.

# Connect to server through

```
ssh -J <user>@<PUBLIC IP>:<PUBLIC PORT> <user>@<server local IP>:<SERVER IP>
```

[1]: https://en.wikipedia.org/wiki/Jump_server
[2]: https://www.noip.com/
[3]: https://www.raspberrypi.org/downloads/raspberry-pi-os/
[4]: https://www.raspberrypi.org/documentation/installation/installing-images/linux.md
[5]: https://hackernoon.com/raspberry-pi-headless-install-462ccabd75d0
[6]: https://thepihut.com/blogs/raspberry-pi-tutorials/how-to-give-your-raspberry-pi-a-static-ip-address-update
[7]: https://dev.to/zduey/how-to-set-up-an-ssh-server-on-a-home-computer
