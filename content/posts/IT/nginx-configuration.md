---
title: "Nginx Configuration"
date: 2020-07-15T20:52:51+02:00
toc: false
images:
tags:
  - IT
---

```bash
apt install nginx
```

# allow HTTP and HTTPS ports

```bash
sudo ufw allow https
sudo ufw allow http
```

# Add nginx configuration

```
touch /etc/nginx/sites-available/foobar.com.conf
ln -s /etc/nginx/sites-available/foobar.com.conf /etc/nginx/sites-enable

```

```
server {
        listen 80;
        listen [::]:80;

        server_name foobar.com www.foobar.com;

        root /var/www/example.com;
        index index.html;

        location / {
                try_files $uri $uri/ =404;
        }
}

```

then reload nginx

```
service nginx reload
```

# Change DNS on domain and DNS provider

Change the domain to point to your VPS provider. In my case, I am using digitalocean.

```
ns1.digitalocean.com
ns2.digitalocean.com
ns3.digitalocean.com

```

Then create Domain Entry with VPS provider with "foobar.com". under the domain, create 2 "A" records to point to the VPS with nginx

- foobar.com
- www.foobar.com

# Let's Encrypt for SSL

```
sudo add-apt-repository ppa:certbot/certbot
sudo apt install python-certbot-nginx
```

run certbot and follow the steps:

```
sudo certbot --nginx -d foobar.com -d www.foobar.com
```
