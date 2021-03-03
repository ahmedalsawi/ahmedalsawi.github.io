---
title: "C++ - final keyword"
date: 2020-11-20
toc: false
images:
tags:
  - c++
---

`final`  keyword was added in C++11 to stop virtual functional override or base class inheritance.

> When used in a virtual function declaration or definition, final specifier ensures that the function is virtual > and specifies that it may not be overridden by derived classes. The program is ill-formed (a compile-time error > is generated) otherwise.
> 
> When used in a class definition, final specifies that this class may not appear in the base-specifier-list of > another class definition (in other words, cannot be derived from). The program is ill-formed otherwise (a > compile-time error is generated). final can also be used with a union definition, in which case it has no > effect (other than on the outcome of std::is_final) (since C++14), since unions cannot be derived from.
> 
> final is an identifier with a special meaning when used in a member function declaration or class head. In > other contexts it is not reserved and may be used to name objects and functions.

# Final class

```c++
#include <iostream>

using namespace std;

class parent final
{
public:
    int x;
    virtual void func()
    {
        cout << "parent" << endl;
    }
};

class child : public parent
{
public:
    int x;
    void func()
    {
        cout << "child" << endl;
    }
};

int main()
{
    child c;
    c.func();
    return 0;
}
```

this throws compile error

```
final.cc:15:7: error: cannot derive from ‘final’ base ‘parent’ in derived type ‘child’
   15 | class child : public parent
```

# Final method
```c++
#include <iostream>

using namespace std;

class parent
{
public:
    int x;
    virtual void func() final
    {
        cout << "parent" << endl;
    }
};

class child : public parent
{
public:
    int x;
    void func()
    {
        cout << "child" << endl;
    }
};

int main()
{
    child c;
    c.func();
    return 0;
}
```
and error
```
final.cc:19:10: error: virtual function ‘virtual void child::func()’ overriding final function
   19 |     void func()
      |          ^~~~
```
[1]: https://en.cppreference.com/w/cpp/language/final