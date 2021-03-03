---
title: "Systemverilog Assertions(SVA) - part1 - 5-minute tour"
date: 2020-12-05
toc: false
images:
tags:
    - DV
---

# Introduction
There are two types of assertions: immediate and concurrent. I will omit immediate here because they are simple and straightforward for anyone who wrote an assertions in any language.

concurrent assertions provide temporal(over time) semantics to check the deign "intent". Basically, They describe behavior that spans over time. Unlike immediate assertions, the evaluation model is based on a clock so that a concurrent assertion is evaluated only at the occurrence of a clock tick.

# Clocking
assertions need a clocking event to evaluate sequences and properties over time (sampling tick). if there is no clocking for assertion, tool will throw an error.

clocking can  be defined in sequence, property or assertion. 

```verilog
sequence s1;
@(posedge clk) sig0 ##1 sig1
endsequence
```

or

```verilog
property p1;
@(posedge clk) s1 ##1 sig2
endpropert
```

or

```
assert property (@(posedge clk) pr1)
```

It's usually recommended to define in property or assert. and keep sequence clock-free to be reusable.

# Sampling

LRM defines `Sample value` for concurrent assertions as:


> The definition of a sampled value of an expression is based on the definition of a sampled value of a variable. The general rule for variable sampling is as follows:
>
> — The sampled value of a variable in a time slot corresponding to time greater than 0 is the value of this variable in the Preponed region of this time slot.
> 
> — The sampled value of a variable in a time slot corresponding to time 0 is its default sampled value. (see next section)



For example, The value of signal req is low at clock ticks 1 and 2. At clock tick 3, the value is sampled as high and remains high until clock tick 6. The sampled value of variable req at clock tick 6 is low and remains low up to and including clock tick 9. (Note, here the edge of req is at tick 9 exactly, but it samples the value at preponed region so the value is low)

![Image](/sva1-1.png)



Also, The LRM defines several scheduling regions inside the time unit:

- Values are samples in preponed region(from previous time unit)
- expressions are evaluated in observed region
- action block execute in observed



# statements
A concurrent assertion statement may be specified in any of the following:

- always procedure or initial procedure as a statement, wherever these procedures may appear(called procedural concurrent assertion, will ignore for now)
- module
- interface
- program
- generate block
- checker

And there are 4 types of "SVA" defined in LRM for both simulation and formal tools:

- assert: The assert statement is used to enforce a property. When the property for the assert statement is evaluated to be true, the pass statements of the action block are executed. When the property for the assert statement is evaluated to be false, the fail statements of the action_block are executed.
- cover: to make sure property is hit as part of coverage closure
- assume: to constraint the formal engine. In simulation, it's treated same as assert
- restrict: used for formal.


# properties and sequences
To write an "assertion", we can reuse the following building blocks:

- expressions
- sequence
- property

The way i see it, property is super-class of sequence.There are operators that can be written inside property not sequence. And sequence can be used in properties but not the other way around.

```verilog
sequence s1;
sig0 ##1 sig1
endsequence

property p1;
s1 ##1 sig2
endpropert

assert property (@(posedge clk) pr1)
```

# Threading
It's important to understand that assertions are multi-threaded. This means that there is a thread staring at each sampling tick that evaluates the property. and each of the threads can pass, fail or be vacuous depending on operators used in the property. This will be more apparent in properties using repetition and implication.
