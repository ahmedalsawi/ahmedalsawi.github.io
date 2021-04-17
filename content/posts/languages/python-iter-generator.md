---
title: "Python Generator vs Iterator"
date: 2020-04-17T15:15:17+01:00
draft: true
tags:
- Python
---

This is quick write-up about python iterators and generators.

# Iterator objects
docs defines *iter* functions 

"""
Return an iterator object. The first argument is interpreted very differently depending on the presence of the second argument. Without a second argument, object must be a collection object which supports the iteration protocol (the __iter__() method)
"""

This is an example of built-in iterators where *iter()* and *next()* are called to get iterator object and get next element in the list.

```python
mlist = [100,200,300]

iter_obj = iter(mlist)

print(next(iter_obj))
for i in iter_obj:
    print(i)
```

# user-defined __iter__ 
To define iterator protocol, we need at least *__iter__* and *__next__*
- *__iter__*: initializes the iteration and returns class object
- *__next__*: returns the iter-able elements. at the end of iteration, __next__ returns StopIteration which caller catches and end the iteration.

```python
class custome_itertor:
    def __iter__(self):
        self.o = ["a","b"]
        self.count = 0
        return self
    def __next__(self):
        if  self.count < len(self.o):
            x = self.o[self.count]
            self.count = self.count + 1
            return x
        else:
            raise StopIteration
# Thee object
myclass = custome_itertor()

# Get iterator object
myiter = iter(myclass)

# loop over 
for i in iter(myiter):
    print(i)
```


# Generator function
[pep][1] defines the generator function as functions with *yield*. it also describes gene

"""
When a generator function is called, the actual arguments are bound to function-local formal argument names in the usual way, but no code in the body of the function is executed. Instead a generator-iterator object is returned; this conforms to the iterator protocol [6], so in particular can be used in for-loops in a natural way. Note that when the intent is clear from context, the unqualified name "generator" may be used to refer either to a generator-function or a generator-iterator.
"""

In the example, the call to function returns iterator object which we can call *next* on it. in the first call, function yields to caller and returns 0. and on the second call, the second print is executed.

```python
def gen():
    x = 0
    print("Before first yield")
    yield x

    x = 1
    print("Before sencond yield")
    yield x


itero = gen()

print("calling 1st yield")
print(next(itero))
print("calling 2nd yield")
print(next(itero))

```

# Iteration with Generator function
Now, that *iter* and *generator* are explained. we can combine them  to write simpler iter-able class.
the *__iter__* is a generator function that returns iterator object on the first call and elements from the list on every *next()* call.
 
so, the class object can be used in for or any place iterator object can be used.

```python
class iter_class:
    def __init__(self):
        self.arr= [1,2,3]

    def __iter__(self):
        for x in self.arr:
            yield x


ic = iter_class()
for  i in ic:
    print(i)

```

[1]: https://www.python.org/dev/peps/pep-0255/