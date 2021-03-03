---
title: "Golang Part2"
date: 2020-07-10T01:59:51+02:00
toc: false
images:
tags:
  - go
---

# Maps
map has to initialized with `make`
```go
package main

import "fmt"

func main() {
	var m map[string]string
	m = make(map[string]string)
	m["a"] = "a1"
	fmt.Println(m)
}
```
# Structure
`type struct` to create a container for variables. in this example, `b1` variable of type `Book`. `b2` is the same with initialized.

```go
package main

import "fmt"

type Book struct {
	title string
	pages int
}

func main() {
	var b1 Book

	b1.pages = 100
	b1.title = "koko"
	fmt.Println(b1)

	b2 := Book{title: "b2", pages: 100}
	fmt.Println(b2)
}
```
# OOP-ish
class can be defined with `type <name> struct`. the class methods can be defined with `type <intf> interface`. and finally to define type method.
```go
package main

import "fmt"

type PersonIntf interface {
	GetAge() int
}

type Person struct {
	name string
	age  int
}

func (person Person) GetAge() int {
	return person.age
}

func main() {
	p := Person{name: "ah", age: 100}
	fmt.Println(p)
	fmt.Println(p.GetAge())
}
```

# Error Handling
go handle error with multiple return functions. The second return can be error.
if all is well, you can return `nil`. in case of error, we can return `errors.New`.

```go
package main

import (
	"errors"
	"fmt"
)

func e(i int) (int, error) {
	if i < 0 {
		return 0, errors.New("bad")
	} else {
		return i, nil
	}
}
func ce(i int) {
	fmt.Println("===========")
	i, err := e(i)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(i)
}
func main() {
	ce(2)
	ce(-1)
}
```

[1]: https://golang.org/pkg/
