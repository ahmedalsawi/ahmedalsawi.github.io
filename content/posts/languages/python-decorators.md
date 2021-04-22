---
title: "Python Decorators"
date: 2021-04-19T12:08:54+01:00
tags:
- Python
---

[pep][1] describes decorators as better way for method transformation. 

> The current method of applying a transformation to a function or method places the actual transformation after the function body. For large functions this separates a key component of the function's behavior from the definition of the rest of the function's external interface

the pep mentions an example or the function transformation:

```
def foo(self):
    perform method operation
foo = classmethod(foo)
```

# Syntax
syntax

```
@dec2
@dec1
def func(arg1, arg2, ...):
    pass
```

This is equivalent to:
```
def func(arg1, arg2, ...):
    pass
func = dec2(dec1(func))
```

decorator can define arguments arguments

```
@decomaker(argA, argB, ...)
def func(arg1, arg2, ...):
    pass
```

This is equivalent to:

```
func = decomaker(argA, argB, ...)(func)
```

# Simple Example
A popular application is providing pre/post implementation for a method. in this example, the decorator is method that returns a another *wrapper* method. the wrapper method calls the *func*.

```
def dec(func):
    def wrapper():
        print("before")
        func()
        print("after")
    return wrapper


@dec
def say():
    print("something")

say()
```


# real example (flask route)

in flask `app` defines method route that takes url.

```python
@app.route('/')
def index():
    return "Hello, World!"
```

`@app.route` defined in `flask/app.py` returns decorator method. and the decorator method register the route and returns the original method.

```python
 def route(self, rule, **options):
        def decorator(f):
            endpoint = options.pop("endpoint", None)
            self.add_url_rule(rule, endpoint, f, **options)
            return f

        return decorator
```

so `index` becomes the following

```python
index = route('/')(index)
```
which is 

```python
index = decorator(index)
```

which is

```python
index = index
```

and the final LHS index is *decorated*

[1]: https://www.python.org/dev/peps/pep-0318/
