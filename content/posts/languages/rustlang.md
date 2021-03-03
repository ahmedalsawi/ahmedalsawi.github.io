---
title: "rustlang - Hello world"
date: 2020-12-27
toc: false
images:
tags:
  - rust
---

# Cargo
`cargo` package manager can be used to create standard structure for rust application.

```
cargo ini
```

To build 

```
cargo build
```

To build opt binary:

```
cargo build --release
```

We can build and run binary with 
```
cargo run
```

# Creating first rust module

To create a module, create file under `src/`. For this example, the module name is `print.rs`

```rust
pub fn run(){
    println!("Hello there")
}
```

and that module can be imported into main using `mod print`

```rust
mod print;


fn main() {
    print::run();
}

```

# println arguments
can take several formatting

```rust
pub fn run(){
    println!("Hello there");

    println!("This is example {} is {}",4, "koko"); //  Arguments
    println!("This is example {0} is {1}",4, "koko"); //  Positional Arguments
    println!("{} {} {name}", 1,2,name=30); // Name Arguments
}
```
