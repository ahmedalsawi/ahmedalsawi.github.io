---
title: "C++ - override"
date: 2020-11-20
toc: false
images:
tags:
  - c++
---

override keyword to make sure that class method "overrides" base class method. If there is not virtual in a parent class, it will throw compile error.

# Example

```c++
#include <iostream>

using namespace std;

class parent
{
public:
    int x;
    // virtual void func()
    // {
    //     cout << "parent" << endl;
    // }
};

class child : public parent
{
public:
    int x;
    void func() override
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
g++ errors out with 
```
override.cc:19:10: error: ‘void child::func()’ marked ‘override’, but does not override
   19 |     void func() override
      |          ^~~~
```