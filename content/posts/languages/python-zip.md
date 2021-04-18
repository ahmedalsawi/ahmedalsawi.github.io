---
title: "Python zip()"
date: 2021-04-18T12:08:54+01:00
tags:
- Python
---

# zip iterable collections

zip is a  way to iterate several iterable collections in the same loop. from [docs][1] 

> Make an iterator that aggregates elements from each of the iterables.
> Returns an iterator of tuples, where the i-th tuple contains the i-th element from each of the argument sequences or iterables. The iterator stops when the shortest input iterable is exhausted. With a single iterable argument, it returns an iterator of 1-tuples.

```python
l1 = [1,2]
l2 = ["a", "b"]

zip_ = zip(l1,l2)
print(type(zip_))
for t in zip_:
    print(t)
```

prints

```
<class 'zip'>
(1, 'a')
(2, 'b')
```
# unzip tuples

Also, It can be used to unzip list of tuples back to original lists. Here we will need to use * for collection unpack on function call.

```python
l1 = [1,2]
l2 = ["a", "b"]

zip_ = zip(l1,l2)
print(type(zip_))

x, y = zip(*zip_)
print(x,y)
```

prints

```
(1, 2) ('a', 'b')
```

[1]: https://docs.python.org/3/library/functions.html#zip

