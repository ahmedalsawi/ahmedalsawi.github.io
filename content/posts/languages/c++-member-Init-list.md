---
title: "C++ - member initializer lists  "
date: 2020-03-20
toc: false
images:
tags:
  - c++
---


c++11 feature to initialize public members without using constructor using `c1{1, 2};`

```c++
#include <iostream>

class cls
{
public:
	int x;
	int y;
};

int main()
{
	cls c1{1, 2};
	std::cout << c1.x << " " << c1.y << std::endl;
}
```

most GNU toolchains support 11 by default. so, it works as expected

```
$ ./a.out
12
```

when compiled with `std=c++98`, it prints

```
member-class-init.cpp:12:8: warning: extended initializer lists only available with -std=c++11 or -std=gnu++11
  cls c1{1, 2};
        ^
```
