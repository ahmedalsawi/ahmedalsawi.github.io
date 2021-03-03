---
title: "Golang Part1"
date: 2020-07-10T01:59:51+02:00
toc: false
images:
tags:
  - go
---

These are notes i document while learning Go.

# Go package

the core of GO is packages. the main package contains one main function which is entry point for the build elf.
The ways i can run this file

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println(os.Args)
}
```

- Passing the file directory

```
go build main.go
```

- Passing the directory. In this case, the files in that directory will be compiled to generate the elf binary.

```
go build ./
```

Note that all names should be unique in the files compiled into the same package.

# User defined package

By default, go searches the the go `worksapaces`. The `workspace` is directory that contains `src` and `pkg` directory.

```
<GOPATH>/src/github.com/<user>/packages/
├── main.go
└── pks
    └── pks.go
```

for that we need to set the GOPATH. In main.go, `pks` needs to be imported relative to GOPATH.

```go
package main

import (
	"fmt"
	"math/rand"
	"github.com/<user>/packages/pks"
)

func main() {
	fmt.Println("My favorite number is", rand.Intn(10))
	pks.F("Test")
	F("test1")
}
```

The trick here is the export symbols(variable or functions) should start with Capital char.

```go
package pks

import "fmt"

func F(i1 string) {
	fmt.Println(i1)
}

```

# Env variables

`os.Getenv` and `os.Setenv` are used for well Getting and Setting variables.

```go
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {

	gopath := os.Getenv("GOPATH")
	fmt.Println(gopath)
	for _, g := range strings.Split(gopath, ":") {
		fmt.Println(g)
	}
	os.Setenv("GOPATH1", gopath)
	for _, e := range os.Environ() {
		fmt.Println(e)
	}
}
```

# Command line arguments

`os.Args` is `[]string`. I can't find `argc` but there is `len(os.Args)`

```go
package main

import (
	"fmt"
	"os"
)

func main() {

	fmt.Println(os.Args)

	for _, a := range os.Args {
		fmt.Println(a)
	}
}
```

# Files and Directory

`ReadDir` takes string and return slice of type `FileInfo`. there are some basic types `File`, `FileInfo` and `FileMode`. Full `os` package docs at [golang doc][1].

```go
package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	fmt.Println("Hello gotree")

	if len(os.Args) < 2 {
		fmt.Println("Missing argument: Path to diretory")
		os.Exit(1)
	}
	dir := os.Args[1]

	files, err := ioutil.ReadDir(dir)
	fmt.Println(err)

	for _, file := range files {

		if file.IsDir() {
			fmt.Println("Directory:" + file.Name())
		} else {
			fmt.Println(file.Name())
		}
	}
}
```

# Writing and Reading Files

`os.OpenFile` takes path, Flags and permissions. Then `File.Write` of `File.WriteString`.
There is also `ioutil.ReadFile` to read the whole in one go.

```go
package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	fmt.Println("Hello")

	// Write
	f, err := os.OpenFile("tmp.txt", os.O_RDWR|os.O_CREATE, 0777)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(f.Name())

	n := []byte{65}
	f.Write(n)

	f.WriteString("This is text")
	f.Close()

	// Reading
	f, err = os.OpenFile("/etc/passwd", os.O_RDONLY, 0777)
	if err != nil {
		fmt.Println(err)
	}

	b1 := make([]byte, 5)
	n1, err := f.Read(b1)
	fmt.Println(string(b1))
	fmt.Println(n1, err)
	f.Close()

	b2, err := ioutil.ReadFile("/etc/passwd")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(string(b2))
}
```

# Slices

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Println("Slices")

	// Slice is refernce to part of Array
	b := [5]string{"A", "b", "c", "D", "E"}
	s := b[1:4]
	fmt.Println(s)
	s[0] = "THE"
	fmt.Println(b)

	// Slice literal
	bl := []bool{true, false}
	fmt.Println(bl)

	// len, cap
	s1 := []int{2, 3, 5, 7, 11, 13}
	fmt.Println(cap(s1), len(s1))
	s2 := s1[2:5]
	fmt.Println(cap(s2), len(s2))

	// make(dynamic slices)
	s3 := make([]int, 5)
	fmt.Println(cap(s3), len(s3))

	// Append
	s3 = append(s3, s1...)
	fmt.Println(s3)
}
```

[1]: https://golang.org/pkg/os/
