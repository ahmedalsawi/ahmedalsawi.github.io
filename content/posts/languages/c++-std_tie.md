---
title: "C++ - std::tie and std::ignore"
date: 2020-11-27
toc: false
images:
tags:
  - c++
---

c++11 defines utility `tie` to return tuple that can be used in lvalue. 

[c++ reference][1] has have one line definition

> Creates a tuple of lvalue references to its arguments or instances of std::ignore.


in plain English, this works like unpack tuple in python or destructing in javascript. So, in the following example, `func` return  tuple of two elements and using `tie` and unpacking it in `x` and `y` variables


```c++

#include <iostream>
#include <utility>
#include <string>
#include <tuple> // for tuple
using namespace std;

std::tuple<int, int> func()
{
    return make_tuple(1, 2);
}
int main()
{
    int x, y;
    std::tie(x, y) = func();

    cout << x << endl
         << y << endl;
}

```

so, what does `std::ignore` do here?

`std::ignore` is defined in [cpp reference][2]

> An object of unspecified type such that any value can be assigned to it with no effect. Intended for use with std::tie when unpacking a std::tuple, as a placeholder for the arguments that are not used.

which means that `std::ignore` can be used to ignore the element in the returned tuple. in this example, i care only about the second element in tuple so, i have to use std::ignore in the first element.

```c++
#include <iostream>
#include <utility>
#include <string>
#include <tuple> // for tuple
using namespace std;

std::tuple<int, int> func()
{
    return make_tuple(1, 2);
}
int main()
{
    int x, y;
    std::tie(std::ignore, y) = func();

    cout << x << endl
         << y << endl;

}

```

[1]: https://en.cppreference.com/w/cpp/utility/tuple/tie
[2]: https://en.cppreference.com/w/cpp/utility/tuple/ignore