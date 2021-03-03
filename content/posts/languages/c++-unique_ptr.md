---
title: "C++ - smart pointer - unique_ptr"
date: 2020-11-27
toc: false
images:
tags:
  - c++
---

before c++11, smart pointer can be used from `boost` library but now it's part of std. This post documents some small example how to create and use `unique_ptr`.

# Hello world
This is the first example of `unique_ptr`, note how `sp` is used same as `raw pointer`. namely using `->` or `.`. from program output, It's clear how unique_ptr is different.  `~cls()` is called for  unique_ptr object but not for raw pointer.

```c++
#include <iostream>
#include <memory>
#include <string>

using namespace std;

class cls
{
public:
    int x;
    string str;
    cls(std::string str)
    {
        this->str = str;
        cout
            << "cls(): " << str << endl;
    }
    ~cls()
    {
        cout << "~cls():" << this->str << endl;
    }
};

int main()
{
    //  use smart pointer same as raw pointer
    cls *p = new cls("raw ptr");
    p->x = 1;
    std::unique_ptr<cls> sp(new cls("unique_ptr"));
    sp->x = 100;
    cout << "sp->x: " << sp->x << endl;
    cout << "(*sp).x: " << (*sp).x << endl;
}
```

obviously,we can pass the raw pointer directly to unique_ptr contructor.

```c++
    cls *p = new cls("raw ptr");
    std::unique_ptr<cls> sp(p);
```
# using unique_ptr

in the example above, we used `new` to create the object. but using `raw` new is not recommended any more.
starting c++11, `make_unique` (see [link][2]) can be used to create element or array.

```c++
int main()
{
    std::unique_ptr<cls> e = std::make_unique<cls>("ddd");
}
```

# assign to another ptr
As name suggests, underlying object can't be shared between pointers because we wouldn't know which pointer is responsible for destroying the object.

consider the following snippet:

```c++
int main()
{
    unique_ptr<cls> p1(new cls("o1"));

    unique_ptr<cls> p2 = p1;
}
```

g++ will spit off and error which basically means both assignment operator and copy constructor is `delete`ed.

```
unique_ptr3.cc:29:26: error: use of deleted function ‘std::unique_ptr<_Tp, _Dp>::unique_ptr(const std::unique_ptr<_Tp, _Dp>&) [with _Tp = cls; _Dp = std::default_delete<cls>]’
   29 |     unique_ptr<cls> p2 = p1;
      |                          ^~
In file included from /usr/include/c++/9/memory:80,
                 from unique_ptr3.cc:2:
/usr/include/c++/9/bits/unique_ptr.h:414:7: note: declared here
  414 |       unique_ptr(const unique_ptr&) = delete;
      |       ^~~~~~~~~~
unique_ptr3.cc:30:26: error: use of deleted function ‘std::unique_ptr<_Tp, _Dp>::unique_ptr(const std::unique_ptr<_Tp, _Dp>&) [with _Tp = cls; _Dp = std::default_delete<cls>]’
   30 |     unique_ptr<cls> p3(p1);
      |                          ^
In file included from /usr/include/c++/9/memory:80,
                 from unique_ptr3.cc:2:
/usr/include/c++/9/bits/unique_ptr.h:414:7: note: declared here
  414 |       unique_ptr(const unique_ptr&) = delete;
```

# moving unique_ptr
as we saw above, copy constructor and assignment operator are not allowed on unique_ptr. but move semantics is defined on unique_ptr.
so, `std::move` can be used to steal the underlying object and set the ptr to nullptr.

```c++
int main()
{
    unique_ptr<cls> p1(new cls("o1"));

    unique_ptr<cls> p2;

    p2 = std::move(p1);

    // p1 = nullptr;
    cout << "exit\n";
}
```

# assign to nullptr
if nullptr is assigned to unqiue_ptr, the underlying destructor is called.

```c++
int main()
{
    std::unique_ptr<cls> e = std::make_unique<cls>("ddd");
    cout << "begin: nullptr\n";
    e = nullptr; // descrutrtor called on nullptr
    cout << "end: nullptr\n";
    cout << "exit\n";
}
```

# working with STL

unique_ptr works perfectly with STL without semantic changes. for example, we can use vector of pointers:

```c++
int main()
{
    std::vector<unique_ptr<cls>> v;
    vector<cls *> v1;

    v.push_back(make_unique<cls>("o1"));
    v1.push_back(new cls("r1"));
    for (auto &e : v)
    {
        cout << e->str << endl;
    }
}
```

[1]: https://en.cppreference.com/w/cpp/memory/unique_ptr
[2]: https://en.cppreference.com/w/cpp/memory/unique_ptr/make_unique
[3]: https://docs.microsoft.com/en-us/cpp/cpp/how-to-create-and-use-unique-ptr-instances?view=msvc-160