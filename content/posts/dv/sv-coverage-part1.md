---
title: "Abridged guide to Systemverilog Functional coverage - part1"
date: 2020-12-04
toc: false
images:
tags:
    - DV
---

Coverage is big part of "CRV" (constrained random verification). If randomization answers the question "does it work?", Something needs to say when to stop "randomizing" and answer the question "are done?".

SV Standard define combine several Semantics languages (mixed bag) for OOP, SVA, Randomization and most importantly `Functional Coverage`. This is small(or abridged if you like fancy words) intro to Coverage semantics. So, LRM reading is a must to understand all features and details about functional coverage semantics.

# The mandatory LRM tour guide 
There are 4 language features to be know here:

- covergroup
- coverpoint
- bin
- cross bin

## Covergroup
LRM define the `covergroup`

```verilog
logic clk;
logic [3:0] addr;

covergroup cg @(posedge clk);
    cp1: coverpoint addr;
endcover
```

`covergroup` can be defined inside design units (module, interface, bla bla bla). but it shines when combined with randomization inside a `class`.

```verilog
class cls;

covergroup cg @(posedge clk);
endcover

cg cg_u = new;

endclass
```

Also, `covergroup` can be constructed in class constructor.

```verilog
function new();
cg_u = new()
endfunction
```

`covergroup` can take event for triggering or can triggered by calling `.sample()`. Event can be clock or bus enable ro anything that indicate new values to sample. anther use-case, calling `.sample()` from monitor or scoreboard or coverage-driven component.

```verilog
function get_transction();
    cg.sample();
endfunction
```
## Coverpoint

coverpoint is the way define variables we want to sample to make sure all(needed values) are covered. In this example, `add` is is sampled on each clock cycle.

```verilog
logic clk;
logic [3:0] addr;

covergroup cg @(posedge clk);
    cp1: coverpoint addr;
endcover
```

as addr is 4 bits, there are 16 possible values. So, The simulator will auto-create 16 `bins`. and will keep track which values were hit.

## bins
as mentioned, if there are no bins defined, simulator will create auto bins. but we and group values to define that specific condition was hit instead indivisual values.


```verilog
logic clk;
logic [3:0] addr;

covergroup cg @(posedge clk);
    cp1: coverpoint addr{
        bins border = {0,15};
        bins others = {[1:14]};
    }
endcover
```

## cross bins

LRM also defines `cross` which create `M*N` bins where M and N are bins coverpoint defined in cross.

In this example, 2 bins are created to cover all combinations in these two coverpoints 
- <cp1.border,cp2.large>
- <cp1.others,cp2.large>


```verilog
logic clk;
logic [3:0] addr;

covergroup cg @(posedge clk);
    cp1: coverpoint addr{
        bins border = {0,15};
        bins others = {[2:4]};
    }
    cp2: coverpoint addr{
        bins large = {[4:14]};
    }
    cross cps
endcover
```
