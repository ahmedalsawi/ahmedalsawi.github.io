---
title: "Python Subprocess"
date: 2021-04-18T14:44:43+01:00
tags:
   - Python
---

# subprocess.run
python 3.5 provided new interface to replace older os.system to call programs and shell commands. [doc][1]

run() is wrapper around the lower interface Popen which provides finer and more complicated control. Also, run waits until process is done but popen will continue execution and user needs to check for process termination.

```
subprocess.run(args, *, stdin=None, input=None, stdout=None, stderr=None, capture_output=False, shell=False, cwd=None, timeout=None, check=False, encoding=None, errors=None, text=None, env=None, universal_newlines=None, **other_popen_kwargs)
```

as docs mentions these are the most important options.

# args
This could be list of strings for the program and program arguments. 


```python
subproccess.run(["ls", "-l"])
```

if it's one string, *shell=True* must be used to allow shell to handle the whole command

```python
run ( "ls -l f*",shell=True)
```

# stdin, stdout, stderr
According to doc, 

> stdin, stdout and stderr specify the executed program’s standard input, standard output and standard error file handles, respectively. Valid values are PIPE, DEVNULL, an existing file descriptor (a positive integer), an existing file object, and None

```python
import subprocess

print("########## default")
ls = subprocess.run(["ls"])

print((ls))


print("########## suppress output")
ls = subprocess.run(["ls"], stdout= subprocess.DEVNULL)

print("########## send to file")
fh = open("t","w")
ls = subprocess.run(["ls"], stdout= fh)

print("########## capture in process")
ls = subprocess.run(["ls"], stdout= subprocess.PIPE)
print(ls.stdout)
ls = subprocess.run(["ls"], stdout= subprocess.PIPE, text=True)
```

# text
by default, stdout, stdin, stderr are using byte encoding for output. with *text=True*, the output is string

```python
In [10]: run ( "echo test",shell=True,stdout=subprocess.PIPE).stdout                                                                  
Out[10]: b'test\n'

In [11]: run ( "echo test",shell=True,stdout=subprocess.PIPE, text=True).stdout                                                       
Out[11]: 'test\n'
```

# subprocess.Popen
Popen starts the process and user needs to check when it terminated if needed

```python
proc = subprocess.Popen("sleep 10", shell=True)
try:
        outs, errs = proc.communicate(timeout=3)
except subprocess.TimeoutExpired:
        proc.kill()
        outs, errs = proc.communicate()
        print("timeout")
```

There is also Popen.wait which makes program wait for child process which make Popen() same as run()

also there are several API to control the process, probably the most important would be

- Popen.send_signal(signal)
- Popen.kill()

[1]: https://docs.python.org/3/library/subprocess.html#subprocess.run

