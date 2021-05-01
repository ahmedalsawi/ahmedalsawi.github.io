---
title: "Python Context Manager"
date: 2021-05-01T08:53:49+01:00
tags:
- Python
---

# Intro
[pep-343][1] describes the context(pun intended) of context managers.

> PEP 340, Anonymous Block Statements, combined many powerful ideas: using generators as block templates, adding exception handling and finalization to generators, and more


Basically [pep 340][2] introduced the concept of anonymous blocks. which means that something

```
block EXPR1 as VAR1:
    BLOCK1
```

is the same as

```
itr = EXPR1  # The iterator
ret = False  # True if a return statement is active
val = None   # Return value, if ret == True
exc = None   # sys.exc_info() tuple if an exception is active
while True:
    try:
        if exc:
            ext = getattr(itr, "__exit__", None)
            if ext is not None:
                VAR1 = ext(*exc)   # May re-raise *exc
            else:
                raise exc[0], exc[1], exc[2]
        else:
            VAR1 = itr.next()  # May raise StopIteration
```


but pep-343 won with statement *with*



# Specification

the following context mangr expression

```
with EXPR as VAR:
    BLOCK
```

Translates to 

```
mgr = (EXPR)
exit = type(mgr).__exit__  # Not calling it yet
value = type(mgr).__enter__(mgr)
exc = True
try:
    try:
        VAR = value  # Only if "as VAR" is present
        BLOCK
    except:
        # The exceptional case is handled here
        exc = False
        if not exit(mgr, *sys.exc_info()):
            raise
        # The exception is swallowed if exit() returns true
finally:
    # The normal and non-local-goto cases are handled here
    if exc:
        exit(mgr, None, None, None)
```

The pepe defines EXPR and VAR as

> Here, 'with' and 'as' are new keywords; EXPR is an arbitrary expression (but not an expression-list) and VAR is a single assignment target. 



# Examples and application

The main application for context manager is resource management like file or lock. And handle exceptions inside BLOCK. So, even exception happens, the cleanup code will be executed.


## context manager for file

```python
with open("t.log") as f:
	lines = f.readlines()
```


## user defined context manager
ie the context manager data model requires two dunder methods
- __enter__
- __exit__


```python
class File():
    def __init__(self):
        print("__init__")
    def __enter__(self):
        print("__enter__")
    def __exit__(self, type_,  value, traceback):
        print("__exit__")
        print("type", type_)
        print("value", value)
        print("traceback", traceback)



with File() as file:
    print("something")
```

generates the following logs

```
__init__
__enter__
something
__exit__
type None
value None
traceback None

```

and when exception is raised the `__exit__` is called with excep information and stacktrace

```python
with File() as file:
    print("something")
    raise ValueError
```

```
__enter__
something
__exit__
type <class 'ValueError'>
value 
traceback <traceback object at 0x7f18a06b0500>
4
Traceback (most recent call last):
  File "cntx-mngr.py", line 23, in <module>
    raise ValueError
ValueError
```

## Generator based context manager
[doc][3] describes it best:


> This function is a decorator that can be used to define a factory function for with statement context managers, without needing to create a class or separate __enter__() and __exit__() methods.

```python
from contextlib import contextmanager

@contextmanager
def managed_resource(*args, **kwds):
    # Code to acquire resource, e.g.:
    resource = acquire_resource(*args, **kwds)
    try:
        yield resource
    finally:
        # Code to release resource, e.g.:
        release_resource(resource)

>>> with managed_resource(timeout=3600) as resource:
...     # Resource is released at the end of this block,
...     # even if code in the block raises an exception
```


[1]: https://www.python.org/dev/peps/pep-0343/
[2]: https://www.python.org/dev/peps/pep-0340/
[3]: https://docs.python.org/3/library/contextlib.html
