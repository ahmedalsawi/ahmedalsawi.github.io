---
title: "Python dict.items and enumerate"
date: 2021-04-18T11:49:07+01:00
tags:
- Python
---

Python provides several iteration API over collections(specially dictionary). In python2, there was dict.iteritems() for key/value iteration. Starting from python3, iteritems was replaced by items()i (see [SO][3]). and there is also enumerate which works with all collections not just dict.

# dict.items()
Defined in [pep][1], items() returns key/value iterator over dict. Although, items behaves the same in python2 and 3. but there is a difference in return type. In python2, items() returns list but in python3, it returns an iterator.

```python
d = {"a":1, "b":2}

items_ = d.items()
print((items_))
print(type(items_))

for k, v in  items_:
    print(k,v)

```

prints

```
dict_items([('a', 1), ('b', 2)])
<class 'dict_items'>
a 1
b 2
```

# enumerate
Define in [pep][2], enumerate works with iterable collections to provide iterator over index, value (in case of dict, it would be index, key).

```python
d = {"a":1, "b":2}
enumerate_ = enumerate(d)
print(enumerate_)
print(type(enumerate_))

for (id, v) in enumerate_:
    print(id, v)
```

prints

```
<enumerate object at 0x7f79a5f67b40>
<class 'enumerate'>
0 a
1 b

```

[1]: https://www.python.org/dev/peps/pep-3106/
[2]: https://www.python.org/dev/peps/pep-0279/
[3]: https://stackoverflow.com/questions/10458437/what-is-the-difference-between-dict-items-and-dict-iteritems-in-python2
