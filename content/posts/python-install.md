---
title: "Python Install without root"
date: 2021-05-05T20:13:02+01:00
draft: true
tags:
- Python
---

This post documents the steps to install python without root.

# libffi
libffi is required by ctypes module which is an important module for python/c interface.

```bash
./autogen.sh
./configure --prefix=$LOCAL
make
make install
```

#  sqlite3
sqlite3 required by sqlite3 module. Python can compile without it but it is good module to have. So worth the trouble.

```bash
./configure --prefix=$LOCAL
make
make install
```

# python
## env
Note that LDFLAGS below is need for compiling ctypes with local libffi and be removed after compilation.

```bash
set path=($LOCAL/bin $path)
setenv LD_LIBRARY_PATH "$LOCAL/lib:$LOCAL/lib64:$LOCAL/lib/pkgconfig"
setenv PKG_CONFIG_PATH $LOCAL/lib/pkgconfig
setenv CFLAGS  "-I$LOCAL/include"
setenv LDFLAGS "-L$LOCAL/lib64 -L$LOCAL/lib"
setenv LDFLAGS "${LDFLAGS} -lffi" 
set path=($LOCAL/python/3.9.4/bin $path)
setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:$LOCAL/python/3.9.4/lib"
```
## Fix for sqlite search path

Add sqlite3 to search path if not installed in standard path [1](https://stackoverflow.com/questions/32779768/python-build-from-source-cannot-build-optional-module-sqlite3)

Modify setup.py to add path to sqlite headers in `sqlite_inc_paths`

```python
sqlite_inc_paths = ['/usr/include',
                    '/usr/include/sqlite',
                    '/usr/include/sqlite3',
                    '/usr/local/include',
                    '/usr/local/include/sqlite',
                    '/usr/local/include/sqlite3',
                     ]
```

## Configure the build
```bash
./configure --prefix=$LOCAL/python/3.9.4 with_system_ffi=yes --enable-shared
```
`with_system_ffi=yes` tells autoconf to use system ffi [link](https://bugs.python.org/issue14527)

## build
```bash
make -j8
make install
```
