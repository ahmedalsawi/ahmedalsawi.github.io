---
title: "C++ - std::pair"
date: 2020-11-27
toc: false
images:
tags:
  - c++
---

`std::pair` is class template to store two elements(special case of std::tuple)

according to [cpp reference][1], the elements are accessible through `first` and `second` member objects.

there are several ways to create pair according to [link][2]. i am listing the 3 obvious ones here:
- default constructor if both types std;:is_default_constuctible_v for both types is true
- constructor (x,y) which initializes first and second to x and y
- copy contructor from another pain.


```c++
#include <iostream>
#include <utility>

using namespace std;

int main()
{
    std::pair<int, int> p;
    cout << p.first << " " << p.second << endl;
    std::pair<int, int> p1(1, 2);
    cout << p1.first << " " << p1.second << endl;

    auto p2 = make_pair(1, 1.1);
    cout << p2.first << " " << p2.second << endl;

}
```

# make_pair

pairs can be constructed using [`make_pair`][3]. which is template function to deduce the first and second types.

`auto` can be used with to make_pair to create pairs and `auto type deduction will figure it out.

[1]: https://en.cppreference.com/w/cpp/utility/pair
[2]: https://en.cppreference.com/w/cpp/utility/pair/pair
[3]: https://en.cppreference.com/w/cpp/utility/pair/make_pair