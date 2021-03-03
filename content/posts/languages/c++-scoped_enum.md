---
title: "C++ - Scoped enum"
date: 2020-12-11
toc: false
images:
tags:
  - c++
---

C defined a way to declare enum(or enum type) and enum constants. but the problem here is namespace pollution due to enum constants. I guess that why they came up with scoped enum to make enum behave like class types and enum constants are scoped with `::`

```c++
#include <iostream>
#include <utility>

using namespace std;
enum
{
    ONE,
    TWO
} e1;

enum class senum
{
    ONES,
    TWOS
};
int main()
{
    e1 = ONE;

    senum e2 = senum::ONES;
}

```