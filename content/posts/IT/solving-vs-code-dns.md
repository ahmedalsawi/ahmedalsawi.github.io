---
title: "Solve Vscode extension download errors"
date: 2019-10-24
toc: false
images:
tags:
  - vscode
  - IT
---


This is write-up about how i solved a problem with vscode where i couldn't download/update any extensions.

well, if you see an error like this, read on.

```
"Failed to update 'ms-python.python'."
```

After spending hours reading github issues on vscode repo, it turned out to simple (but stupid) problem. So, I am documenting it for future me when i forget how i solved it.

# The problem

The vscode code marketplace (where all extensions live) can't be resolved unless i have cloudflare `1.1.1.1`

Not sure what changed, but i don't have that `resolv.conf`.

# The solution

if you are using systemd, Edit `/etc/systemd/resolved.conf` to add both google and cloudflare DNS

```
[Resolve]
DNS=1.1.1.1 8.8.8.8
```

Then restart systemd-resolved

```bash
sudo service systemd-resolved restart
sudo systemctl restart networking.service
```

`/etc/resolv.conf` should be updated with new DNS

```
nameserver 1.1.1.1

```

# Gotcha

At some point, systemd changed generated `resolv.conf` to `/run/systemd/resolve/resolv.conf`. So, make sure that `/etc/resolv.co` links to correct file.

```
sudo rm -rf /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

[1]: https://askubuntu.com/questions/973017/wrong-nameserver-set-by-resolvconf-and-networkmanager
