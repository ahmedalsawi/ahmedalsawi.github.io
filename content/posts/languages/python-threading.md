---
title: "Python Threading"
date: 2021-04-18T16:01:24+01:00
tags:
- Python
---

python threading module provides a way to start python callable in a thread of execution 

```
class threading.Thread(group=None, target=None, name=None, args=(), kwargs={}, *, daemon=None)
This constructor should always be called with keyword arguments. Arguments are:

group should be None; reserved for future extension when a ThreadGroup class is implemented.

target is the callable object to be invoked by the run() method. Defaults to None, meaning nothing is called.

name is the thread name. By default, a unique name is constructed of the form “Thread-N” where N is a small decimal number.

args is the argument tuple for the target invocation. Defaults to ().

kwargs is a dictionary of keyword arguments for the target invocation. Defaults to {}.

If not None, daemon explicitly sets whether the thread is daemonic. If None (the default), the daemonic property is inherited from the current thread.
```

it seems straightforward. create *Thread* and pass callable. daemon can be set to True if you want thread to run as daemon.

```python
import threading
import subprocess

def thread():
    print("from thread")
    subprocess.run("sleep 3", shell=True)

thread_ = threading.Thread(target=thread, daemon=True)
thread_.start()

print(thread_.name)
print(thread_.ident)

```

the difference between daemon and non-daemon threads is that python will exit program if there no alive non-daemon threads.
ie main program can exit if there is only daemon threads.

# communcation

To communcation with thread, *queue* module can be used. The [doc][2] says

```
The queue module implements multi-producer, multi-consumer queues. It is especially useful in threaded programming when information must be exchanged safely between multiple threads. The Queue class in this module implements all the required locking semantics.
```

and example of queue put and get.

```python
import threading
import subprocess

import queue

def thread(Q):
    print("from thread")
    x= Q.get()
    print(x)
    #subprocess.run("sleep 3", shell=True)

Q = queue.Queue()
thread_ = threading.Thread(target=thread,  args=(Q,))
thread_.start()

print(thread_.name)
print(thread_.ident)

subprocess.run("sleep 3", shell=True)
Q.put(1)
```

[1]: https://docs.python.org/3/library/threading.html
[2]: https://docs.python.org/3/library/queue.html#module-queue
