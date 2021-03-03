---
title: "C++ - Type alias"
date: 2020-03-20
toc: false
images:
tags:
  - c++
---

for template classes, alias can be used to declare specialization of template class. I guess it can used to define default configuration of the template class.

```c++
#include <iostream>

template <unsigned T>
class cls
{
public:
  cls()
  {
    std::cout << T << std::endl;
  }
};

// The alias with T=32
using alias = cls<32>;

int main()
{
  alias c;
}
```
