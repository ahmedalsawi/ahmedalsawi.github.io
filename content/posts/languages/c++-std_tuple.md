---
title: "C++ - std::tuple"
date: 2020-11-27
toc: false
images:
tags:
  - c++
---


`std::tuple` was added in c++11 fixed sized heterogeneous values  It is a generalization of std::pair.
full details at [cpp reference][1]

`get<index>(tuple)` is used to get the values at index.

what is interesting about tuple though is using `make_tuple` and `auto` to create tuples without specifying types. `auto` type deduction will figure it out.


```c++
#include <iostream>
#include <utility>
#include <string>
#include <tuple> // for tuple
using namespace std;

int main()
{
    std::tuple<int, int, string> p;

    p = make_tuple(1, 2, "fff");

    cout << get<0>(p) << endl;

    auto p1 = make_tuple("1dd", 1.1);
    cout << get<0>(p1) << endl;
}

```

[1]: https://en.cppreference.com/w/cpp/utility/tuple