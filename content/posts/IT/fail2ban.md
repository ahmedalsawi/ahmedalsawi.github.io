---
title: "sshd with fail2ban"
date: 2021-01-05
toc: false
images:
tags:
  - IT
---

fail2ban is an important to harden any server exposed to the internet. mainly to stop bots from smashing the ssh service.

# Installation
```bash
apt install fail2ban
systemctl enable fail2ban.service
systemctl start fail2ban.service
```
# configuration

there are several default configuration but we can override with with `fail2ban.local`
```bash
cp /etc/fail2ban/jail.conf /etc/fail2ban.local
```

`fail2ban.local` already has section for sshd. we just need to enable it and configure it as needed.

```
maxretry = 3
enabled = true
action = iptables-multiport
bantime = 1h
```

Then restart the service

```bash
sudo systemctl restart fail2ban.service
```

# fail2ban-client
There is utility to check the `jails` created by fail2ban

```bash
sudo fail2ban-client status sshd
```

And we can always check the logs at `/var/log`