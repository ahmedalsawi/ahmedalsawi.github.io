---
title: "Setting up VNC"
date: 2020-08-21T14:24:17+02:00
toc: false
images:
tags:
  
  - IT
---

# Install server

Install tigervnc server

```
apt install tigervnc-standalone-server
```

Install desktop

```
apt install  xfce4 xfce4-goodies
```

Set up xstartup script

```
touch ~/.vnc/xstartup
chmod 700 ~/.vnc/xstartup
```

```
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
xfce4-session &
```

Finally, create the session and set password

```
vncserver
```

# systemd service

create service file

```
sudo touch /etc/systemd/system/vncserver@.service
```

configure the service as following. Change the `user` as needed.

```
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=<user_name>

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver -geometry 1800x1000 -depth 16 -dpi 120 -alwaysshared -localhost yes :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

Enable and start the service `vncserver@1.service`

```
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

# Client connection

## SSH forwarding

This is needed for port forwarding through ssh

```
ssh -L 5901:127.0.0.1:5901 -N  user@<SERVER IP>
```

## vncviewer

Install vncviewer and connect to `localhost:1`

```
apt install tigervnc-viewer
vncviewer :1
```

[1]: https://linuxize.com/post/how-to-install-and-configure-vnc-on-ubuntu-18-04/
