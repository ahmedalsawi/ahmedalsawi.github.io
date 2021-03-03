---
title: "Not the hitchhiker's guide to UPF"
date: 2020-12-16
toc: false
images:
tags:
    - DV
---

There are my notes while reading the UPF standard (IEEE Std 1801). The standard is short and concise document and required several re-reads to understand the UPF semantics (Exactly as painful as reading the 1800 LRM).

# Domains

This is summary of section 4.2(just in points)

- domain is a collection of design elements. Unless otherwise specified, elements of a power domain share a
common primary supply set (see 4.3). 
- primary supply set is implicitly connected to all elements within the domain.
- The design consists of a hierarchical tree of design elements (logic hierarchy). The logic hierarchy level
where a power domain is created is called the scope of the power domain. 
- The set of design elements that belong to a power domain are said to be the extent of that power domain.
- design element can be the scope of multiple power domains, it can be in the extent of one and only one power domain.

So, each Domain has a scope and extent. And `extent` is all elements are under that domain.


Each power domain exists within a scope of the logic hierarchy. A design element is a member of the power
domain that includes the design element’s parent instance, unless the design element has been explicitly
included as an element of another power domain whose scope is the element or an ancestor of the element.

Related UPF commands:
- create_power_domain
- add_power_state

# Power Nets and Ports

This is the gist of LRM 4.2

- Supply nets transport an electrical current
- Supply ports provide the ability to connect a supply net to a design element
- When created in UPF, the supply net is created within the scope of a design element of the logic hierarchy. 
- When created in UPF, a supply port is created on the interface of an element in the logic hierarchy

The port defines `HighConn` and `Loconn`

> Supply ports consist of two halves. The first half is the HighConn side, which is visible to the parent of the design element whose interface contains the port. The second half is the LowConn side, which is visible internal to the design element whose interface contains the port.

and connection to `HighConn` and `LoConn` is defined as following:

- When a supply or logic net in the active scope is connected to a supply or logic port on a child instance, the connection is made to the HighConn side of the port. 
- When a supply or logic net in the active scope is connected to a port defined on the interface of the design element that is the active scope, the connection is made to the LowConn side of the port.

The related UPF commands
- connect_supply_net
- create_supply_net
- create_supply_port
- add_port_state

# Power states
The following objects have power state
- port
- net
- domain
- set

port states has 2 items
- Supply state (can take value from enum below)
- voltage value

Supply state can take on of the 4 Values
- FULL_ON
- OFF
- PARTIAL_ON
- UNDETERMINED

# supply set
[LRM][1] describes `supply set`

> A supply set relates multiple supply nets as a complete power source for one or more design elements.

basically, supply set is group of nets.

By default, UPF predefines the following supply set handles for
a domain: 
- primary
- default_retention
- default_isolation

Each supply net in a supply set provides a function. UPF predefines the following supply net functions:

- power
- ground
- pwell
- nwell
- deeppwell
- deepnwell


## simstate
LRM defines `simstate` as:

> The simulation behavior semantics (simstate) can be specified for a power state.

This means that simstate are linked to power states of supply set. Possible simstates are:

- CORRUPT
- CORRUPT_ON_ACTIVITY
- CORRUPT_STATE_ON_ACTIVITY
- CORRUPT_STATE_ON_CHANGE
- NORMAL

set_simstate_behavior can be used to DISABLE simstates

## predefined power state
Each supply set has 2 predefined power states
- DEFAULT_NORMAL
- DEFAULT_CORRUPT

simstates mapped to each of above power states
- DEFAULT_NORMAL : NORMAL
- DEFAULT_CORRUPT : CORRUPT


Related UPF commands
- add_power_state

[1]: IEEE Std 1801 TM -2009