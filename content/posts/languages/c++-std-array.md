---
title: "C++ - std::array"
date: 2020-12-11
toc: false
images:
tags:
  - c++
---

Starting [c++11][1], `std::array` can be used for fixed size array. As opposed to `std::vector` with variable length array.
note that length is fixed with `aggregate initialization` and other 

```c++
    std::array<int, 3> a2 = {1, 2, 3};
```

I think the biggest advantage over the vanilla array `[]` is preventing pointer decay. where array pointers can assigned to compatible pointer. For more details why this is bad see [SO][2]

Beside that, there are cool methods like `fill` and `size` and of course operator overload `[]`  same as vanilla array.

Also, it works with containers and algorithm iterators. And of course with type deduction(below example of auto and iterator).

# Example
```c++
#include <iostream>
#include <array>

using namespace std;

int main()
{
    array<int, 3> ar = {1, 2, 4};

    // Doesn't decay into pointer
    int *p;
    int a[3] = {1, 2, 4};

    p = a;
    //p = ar; // Illegal

    // Iteration
    for (auto i : ar)
    {
        cout << i << " ";
        cout << endl;
    }

    // cool methods

    cout << "size: " << ar.size() << endl;
}
```
output 


```
1 
2 
4 
size: 3
```
[1]: https://en.cppreference.com/w/cpp/container/array
[2]: https://stackoverflow.com/questions/1461432/what-is-array-to-pointer-decay