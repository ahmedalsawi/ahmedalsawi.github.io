---
title: "C++ -is_copy_constructible and is_copy_assignable templates"
date: 2020-11-28
toc: false
images:
tags:
  - c++
---

c++11 defines several templates utilities that can evaluate if class has copy_constructor or assignment operator.

there are several variants but this example uses `std::is_copy_constructible` and `std::is_copy_assignable`.

for more details, see [is_copy_assignable][1] and [is_copy_constructible][2]

```c++
#include <iostream>
#include <type_traits>
using namespace std;

class cls
{
public:
    cls(const cls &) = default;
    cls &operator=(const cls &other) = default;
};

class cls1
{
public:
    cls1(const cls1 &) = delete;
    cls1 &operator=(const cls1 &other) = delete;
};
int main()
{
    cout << std::is_copy_constructible<cls>::value << endl;
    cout << std::is_copy_assignable<cls>::value << endl;
    cout << std::is_copy_constructible<cls1>::value << endl;
    cout << std::is_copy_assignable<cls1>::value << endl;
}
```

[1]: https://en.cppreference.com/w/cpp/types/is_copy_assignable
[2]: https://en.cppreference.com/w/cpp/types/is_copy_constructible