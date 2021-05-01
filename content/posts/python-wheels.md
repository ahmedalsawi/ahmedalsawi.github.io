---
title: "Python Wheels"
date: 2021-05-01T10:00:20+01:00
tags:
- Python
- IT
---

Python wheels is zip file with package content as opposed to source distribution. It's faster to install than the normal tar(or whatever).

The [article][1] has really good description for wheels.


For me, wheels are most helpful for installing packages on air-gapped machines. I can just copy the wheels and install.
These are the steps based on [SO][2].

```
export PD=/var/tmp/python-deps
mkdir $PD
python -m pip download wheel setuptools cocotb  setuptools_scm -d $PD
```

And to install on another machine

```
cd $PD
pip3 install --user --no-index cocotb-1.5.1.tar.gz  --find-links file://$PD
```

From pip help

```
  --no-index                  Ignore package index (only looking at --find-links URLs instead).
  -f, --find-links <url>      If a url or path to an html file, then parse for links to archives. If a local path or file:// url
                              that's a directory, then look for archives in the directory listing.
```

[1]: https://realpython.com/python-wheels/
[2]: https://stackoverflow.com/questions/36725843/installing-python-packages-without-internet-and-using-source-code-as-tar-gz-and
