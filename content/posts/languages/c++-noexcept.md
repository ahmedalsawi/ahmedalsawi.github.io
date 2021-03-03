---
title: "C++ - noexpect"
date: 2020-11-20
toc: false
images:
tags:
  - c++
---
`noexept` is c++11 specifier to mark method as exception non-throwing. the best explanation i found is on [MSF][1]. 

> Unary conditional operator noexcept(constant_expression) where constant_expression yields true, and its unconditional synonym noexcept, specify that the set of potential exception types that can exit a function is empty. That is, the function never throws an exception and never allows an exception to be propagated outside its scope.

and after i tried it out, g++ doesn't error out when that happen. It does issue a warning about `throw` calling terminate.

# Example

```c++
#include <iostream>
using namespace std;
class cls
{

public:
    int x;
    void func()
    {
        throw 3;
    }
    void func2() noexcept
    {
        throw 3;
    }
};
int main()
{
    cls c;
    try
    {

        // c.func();  // print 3
        c.func2(); // crashes as function
    }
    catch (int e)
    {
        cout << e << endl;
    }
}
```

for func, the exception catcher worked as expected 

```
$ ./a.out 
3
```

for func2(marked with noexcept), it terminates with stacktrace as if there is no `try-catch`

```
noexcept.cc: In member function ‘void cls::func2()’:
noexcept.cc:14:15: warning: throw will always call terminate() [-Wterminate]
   14 |         throw 3;
      |               ^
```
```
$ ./a.out 
terminate called after throwing an instance of 'int'
Aborted (core dumped)
```


[1]: https://docs.microsoft.com/en-us/cpp/cpp/noexcept-cpp?view=msvc-160