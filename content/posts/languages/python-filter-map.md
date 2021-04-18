---
title: "Python filter/map"
date: 2021-04-18T12:39:44+01:00
tags:
    - Python
---

# filter()
Define in [docs][1],

> Construct an iterator from those elements of iterable for which function returns true. iterable may be either a sequence, a container which supports iteration, or an iterator. If function is None, the identity function is assumed, that is, all elements of iterable that are false are removed

This is very similar to filter and map from other languages like javascript

```python
l = [1, 2, 3, 4, 5]
def filter_(x):
    if x < 3:
        return True
    else:
        return False
f = filter(filter_, l)
print(list(f))
```

# map()


> Return an iterator that applies function to every item of iterable, yielding the results. If additional iterable arguments are passed, function must take that many arguments and is applied to the items from all iterables in parallel.

```python
l = [1, 2, 3, 4, 5]

def map_(x):
    return x+1

m  = map(map_, l)
print(list(m))
```

# with lambda

lambda functions can be used to write inline functions with filter and map.

```python
fl = filter(lambda x: x < 3, l)
print(list(fl))

```

[1]: https://docs.python.org/3/library/functions.html
