---
title: "Starting With Wordpress"
date: 2020-06-25T19:14:05+02:00
toc: false
images:
tags:
  - web
---

# Dependencies

```bash
sudo apt install wordpress php libapache2-mod-php mysql-server php-mysql
```
This will install some important files at `/usr/share/wordpress`. If this is the first time to install mysql you may be asked to set root user password.

# Apache setup
First we need to setup Apache to serve php files from `/usr/share/wordpress`. Edit `/etc/apache2/sites-available/wordpress.conf` with the following content

```
Alias /blog /usr/share/wordpress
<Directory /usr/share/wordpress>
    Options FollowSymLinks
    AllowOverride Limit Options FileInfo
    DirectoryIndex index.php
    Order allow,deny
    Allow from all
</Directory>
<Directory /usr/share/wordpress/wp-content>
    Options FollowSymLinks
    Order allow,deny
    Allow from all
</Directory>
```
Then update Apache and restart

```bash
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo service apache2 reload
```
# MYSQL setup

We need to create database called `wordpress` and give access to `wordpress`
```
sudo mysql -u root
```

Then in mysql REPL

```
mysql> CREATE DATABASE wordpress;
Query OK, 1 row affected (0.01 sec)

mysql> CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';
Query OK, 0 rows affected (0.02 sec)

mysql> GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER
    -> ON wordpress.*
    -> TO 'wordpress'@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql> quit
Bye
```
The restart mysql service

```
sudo service mysql start
```

Then create the following `.php` so that wordpress can access the database server. use the same password used to create database. It should be at `/etc/wordpress/config-localhost.php`

```
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'password');
define('DB_HOST', 'localhost');
define('DB_COLLATE', 'utf8_general_ci');
define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
?>
        
```

# Create Admin User

when you navigate to `localhost/blog`, it will ask to create a user and same for the site.
Note that password here is user admin password and should be kept to log in.