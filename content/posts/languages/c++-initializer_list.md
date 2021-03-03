---
title: "C++ -initializer_list"
date: 2020-03-20
toc: false
images:
tags:
  - c++
---
`initializer_list` is wrapper (proxy) to allow passing arrays as curly braces. according to [link][1], it can be used for class constructor to initialize class with arrays.

```c++
#include <initializer_list>
#include <iostream>
using namespace std;

class cls
{
public:
    void func(std::initializer_list<int> ins)
    {
        for (auto in : ins)
            cout << in << endl;
    }
};

int main()
{
    cls c;
    c.func({1, 2, 3});
    return 0;
}
```

[1]: https://en.cppreference.com/w/cpp/utility/initializer_list