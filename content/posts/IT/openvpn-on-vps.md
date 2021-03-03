---
title: "Setup openvpn on VPS"
date: 2020-11-08T19:46:08+02:00
toc: false
images:
tags:
  - IT
---

# Creating openvpn server
I used the script from [github][1]. which is very easy to follow to generate the server and config

```bash
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
./openvpn-install.sh
```

and to make sure the port 1194 is open, I used ufw to allow traffic on it
```bash
ufw allow 1194/udp
```
# Fixing the issue with linux openvpn connection
with generated ovpn, we can connect to the openvpn server
```bash
sudo openvpn --config client1.ovpn
```
but that will fail to connect with the message at the end of output
```
VERIFY OK: depth=0, CN=***************
```

I found the fix for this issue on [link][2]
```
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
script-security 2
```


[1]: https://github.com/angristan/openvpn-install
[2]: https://serverfault.com/questions/893534/cannot-connect-to-openvpn-server-under-ubuntu-16-04