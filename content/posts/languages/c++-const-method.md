---
title: "C++ - const method"
date: 2020-11-20
toc: false
images:
tags:
  - c++
---

`const` method specifier stop the method from writing to class members. It throws compile time error for writes.

# Example

```c++
class cls
{

public:
    int x;
    void func() const
    {
        x = 0;
    }
};
int main()
{
}
```

```
const.cc:8:11: error: assignment of member ‘cls::x’ in read-only object
    8 |         x = 0;
      |         ~~^~~
```

Note that `const` methods can only call constant methods.

# Work around const-ness
To force write inside `const` method, `const_cast` can be used to remove const-ness.

```c++
#include <iostream>
using namespace std;
class cls
{

public:
    int x;
    void func() const
    {
        // x = 0;
        const_cast<int &>(x) = 3;
        std::cout << x << endl;
    }
};
int main()
{
    cls c;
    c.func();
}
```