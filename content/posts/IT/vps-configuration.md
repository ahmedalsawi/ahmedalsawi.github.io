---
title: "VPS Configuration"
date: 2019-09-02
toc: false
images:
tags:
  - IT
---

Steps to setup VPS machine.

# Change default Hostname

```bash
hostnamectl set-hostname VPS
```

# Add sudo user

```
adduser admin
usermod -aG sudo admin
```

# Setup up strict Firewall

```bash
ufw app list
ufw allow OpenSSH
ufw status
ufw enable
ufw status
```

# Harden sshd

```
$ vi /etc/ssh/sshd_config
```

Disable Root ssh access

```
PermitRootLogin no
```

Disable empty passwords

```
PermitEmptyPasswords no
```

Limit Authentication

```
MaxAuthTries 5
```

Set Idle Time

```
ClientAliveInterval 1200
```

Then restart sshd service

```
$ service ssh restart
```

# Install fail2ban

```
apt install fail2ban
```

Configuration files is `/etc/fail2ban/jail.conf` but can be overridden by `/etc/fail2ban/jail.local`

```
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

and configure

```
# Ban hosts for one day
bantime = 86400

# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport
ignoreip = 127.0.0.1/8

[sshd]
enabled = true

```

to check status of fail2ban sshd jail

```
$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/auth.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:
```

# Create .ssh with correct permission

use `admin` user to create `~/.ssh`

```bash
su admin
mkdir .ssh
chmod 700 ~/.ssh
```

# Add ssh keys

Generate public key on other machine if you don't have one

```
ssh-keygen
```

move `id_rsa.pub` to VPS

```
scp ~/.ssh/id_rsa.pub  admin@VPS:~/.ssh/authorized_keys
```
