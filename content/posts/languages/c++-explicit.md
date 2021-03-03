---
title: "C++ - explicit"
date: 2020-11-21
toc: false
images:
tags:
  - c++
---

by default, compiler can do implicit type conversion if there is a constructor that matches the argument. For example, `func` returns int and return type is `cls` which has a constructor with int.

```c++
#include <iostream>

using namespace std;

class cls
{
public:
     cls(int i)
    {
        cout << i << endl;
    }
};

cls func()
{
    return 230;
}
int main()
{
    int i;
    cls c(1);
    c = func();
}

```


[cpreference][1] describes `explicit` as was to disable the implicit conversion and force compile error when that happens.

> Specifies that a constructor or conversion function (since C++11) or deduction guide (since C++17) is explicit, that is, it cannot be used for implicit conversions and copy-initialization.


```c++
#include <iostream>

using namespace std;

class cls
{
public:
    explicit cls(int i)
    {
        cout << i << endl;
    }
};

cls func()
{
    return 230;
}
int main()
{
    int i;
    cls c(1);
    c = func();
}

```

Error with `explicit`, compiler throws an error

```
explicit.cc:16:12: error: could not convert ‘230’ from ‘int’ to ‘cls’
   16 |     return 230;
      |            ^~~
      |            |
      |            int
```

[1]: https://en.cppreference.com/w/cpp/language/explicit
