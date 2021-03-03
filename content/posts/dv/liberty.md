---
title: "Liberty format"
date: 2020-12-20
toc: false
images:
tags:
    - DV
---

Liberty format defines delays and power of cells. It's important part of ASIC flow for delay calculation and power estimation.

# Syntax
Liberty defines 3 types statements
- group statement
- attribute statement
- define statement


## Group Statements
A group is a named collection of statements that defines a library, a cell, a pin, a timing arc,
and so forth. Braces ({}), which are used in pairs, enclose the contents of the group.

```
group_name (name) {
... statements ...
}
```

## Attribute Statements
An attribute statement defines characteristics of specific objects in the library. Attributes
applying to specific objects are assigned within a group statement defining the object, such
as a cell group or a pin group.

```
attribute_name : attribute_value ;
```
## Define Statements
You can create new simple attributes with the define statement.
```
define (attribute_name, group_name, attribute_type) ;
```

# Writing liberty library

## library Group
The library group statement defines the name of the library you want to describe. This statement must be the first executable line in your library.
```
library (my_library) {
...
}
```

## library attributes
- technology Attribute
- delay_model Attribute
- bus_naming_style Attribute


## Delay and Slew Attributes
The spec defines two concepts:
- Delay
- Slew

The spec describes it very well.  I will just quote it.

### Delay

> Delay is the time it takes for the output signal voltage, which is falling from 1 to 0, to fall to the threshold point set with the output_threshold_pct_fall attribute after the input signal voltage, which is falling from 1 to 0, has fallen to the threshold point set with the input_threshold_pct_fall attribute

The following commands define the threshold 
- input_threshold_pct_fall
- input_threshold_pct_rise
- output_threshold_pct_fall
- output_threshold_pct_rise

### Slew

> Slew is the time it takes for the voltage value to fall or rise between two designated threshold
> points on an input, an output, or a bidirectional port. The designated threshold points must
> fall within a voltage falling from 1 to 0 or rising from 0 to 1.
> 
> Use the following attributes to enter the two designated threshold points to model the time for voltage falling from 1 to 0:
> 
> slew_lower_threshold_pct_fall
> 
> slew_upper_threshold_pct_fall
> 
> Use the following attributes to enter the two designated threshold points to model the time for voltage rising from 0 to 1:
> 
> slew_lower_threshold_pct_rise
> 
> slew_upper_threshold_pct_rise

## Defining Units attributes

Use these library-level attributes to define units:
- time_unit
- voltage_unit
- current_unit
- pulling_resistance_unit
- capacitive_load_unit
- leakage_power_unit
