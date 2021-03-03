---
title: "Mysql cheat sheet"
date: 2020-08-14T10:23:57+02:00
toc: false
images:
tags:
  - sql
---

This is a small sql cheat sheet i keep. It contains super basic operations (create, select, delete).
I am using Mysql for demo here but there would be some difference with sqlite or postgresql.

# Start Mysql

to connect to server for first time, you need to connect as root

```
sudo mysql
```

# Create user and add privileges

```
CREATE USER 'user'@'localhost' IDENTIFIED BY 'password'
```

```
mysql> GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';
Query OK, 0 rows affected (0.02 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

```

# Create, show delete databases

```
mysql> CREATE DATABASE acme;
Query OK, 1 row affected (0.01 sec)

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| acme               |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
7 rows in set (0.01 sec)

mysql> DROP DATABASE acme;


```

# Connect to database

```
mysql> USE acme;
```

# Tables

list tables

```
mysql> SHOW TABLES;

```

Create table

```
mysql> CREATE TABLE users( id INT AUTO_INCREMENT, first_name VARCHAR(100), register_date DATETIME, PRIMARY KEY(id) );
Query OK, 0 rows affected (0.06 sec)

```

Delete table

```
mysql> DROP TABLE users;
Query OK, 0 rows affected (0.04 sec)
```

## INSERT

```
mysql> INSERT INTO users (first_name, register_date)
    -> values('a', now())
    -> ;
Query OK, 1 row affected (0.01 sec)

mysql> SELECT * FROM users;
+----+------------+---------------------+
| id | first_name | register_date       |
+----+------------+---------------------+
|  1 | a          | 2020-08-09 22:43:52 |
+----+------------+---------------------+
1 row in set (0.00 sec)

```

## SELECT

Select all columns

```
mysql> SELECT * FROM users;
+----+------------+---------------------+
| id | first_name | register_date       |
+----+------------+---------------------+
|  1 | a          | 2020-08-09 22:43:52 |
+----+------------+---------------------+
1 row in set (0.00 sec)
```

Select one column

```
mysql> SELECT first_name FROM users;
+------------+
| first_name |
+------------+
| a          |
+------------+
1 rows in set (0.00 sec)
```

const

```
mysql> SELECT first_name FROM users WHERE first_name='a';
+------------+
| first_name |
+------------+
| a          |
+------------+
1 row in set (0.00 sec)
```

## DELETE

```

mysql> DELETE FROM users WHERE id=1;
Query OK, 1 row affected (0.00 sec)

mysql> SELECT first_name FROM users;
+------------+
| first_name |
+------------+
| b          |
+------------+
1 row in set (0.00 sec)


```

## Update

```
mysql> UPDATE users SET first_name='aa' WHERE id=2;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT first_name FROM users;
+------------+
| first_name |
+------------+
| aa         |
+------------+
1 row in set (0.01 sec)

```

## ALTER table

```
mysql> SELECT first_name FROM users;
+------------+
| first_name |
+------------+
| aa         |
+------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM users;
+----+------------+---------------------+------+
| id | first_name | register_date       | age  |
+----+------------+---------------------+------+
|  2 | aa         | 2020-08-09 22:46:42 | NULL |
+----+------------+---------------------+------+
1 row in set (0.00 sec)

mysql> UPDATE users SET age=4 WHERE id=2;
Query OK, 1 row affected (0.02 sec)
Rows matched: 1  Changed: 1  Warnings: 0

```

## Order

```
mysql> SELECT * FROM users ORDER BY age;
+----+------------+---------------------+------+
| id | first_name | register_date       | age  |
+----+------------+---------------------+------+
|  3 | u2         | 2020-08-09 23:00:43 | NULL |
|  2 | aa         | 2020-08-09 22:46:42 |    4 |
+----+------------+---------------------+------+
```

## Conditions - BETWEEN (Filter)

```
mysql> SELECT * FROM users WHERE age BETWEEN 1 AND 3;
+----+------------+---------------------+------+
| id | first_name | register_date       | age  |
+----+------------+---------------------+------+
|  3 | u2         | 2020-08-09 23:00:43 |    2 |
+----+------------+---------------------+------+
1 row in set (0.00 sec)
```

## Conditions - LIKE (Search)

```
mysql> SELECT * FROM users WHERE first_name LIKE 'u%';
+----+------------+---------------------+------+
| id | first_name | register_date       | age  |
+----+------------+---------------------+------+
|  3 | u2         | 2020-08-09 23:00:43 |    2 |
+----+------------+---------------------+------+
```

## Conditions - IN

```
mysql> SELECT * FROM users WHERE first_name IN('u2');
+----+------------+---------------------+------+
| id | first_name | register_date       | age  |
+----+------------+---------------------+------+
|  3 | u2         | 2020-08-09 23:00:43 |    2 |
+----+------------+---------------------+------+
1 row in set (0.00 sec)
```
