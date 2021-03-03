---
title: "UVM Structural Components - Deep Dive"
date: 2020-11-07T00:13:06+02:00
toc: false
images:
tags:
  - UVM
  
---

# Components
UVM defines set  of standard building blocks to build test hierarchy. All components inherit from `uvm_component`. but some components have more bells and whistles than others.

# uvm_comps.svh
starting with `src/comps/uvm_comps.svh` where components live, we can see there are two types
- Utility components
- Structural components

```verilog
 `include "comps/uvm_pair.svh"
 `include "comps/uvm_policies.svh"
 `include "comps/uvm_in_order_comparator.svh"
 `include "comps/uvm_algorithmic_comparator.svh"
 `include "comps/uvm_random_stimulus.svh"
 `include "comps/uvm_subscriber.svh"

 `include "comps/uvm_monitor.svh"
 `include "comps/uvm_driver.svh"
 `include "comps/uvm_push_driver.svh"
 `include "comps/uvm_scoreboard.svh" 
 `include "comps/uvm_agent.svh"
 `include "comps/uvm_env.svh"
 `include "comps/uvm_test.svh"
```

# The vanilla components
There are several components which are just extension of `uvm_component` without adding any further functionality.

for example `uvm_env` 

```verilog
virtual class uvm_env extends uvm_component;

  function new (string name="env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  const static string type_name = "uvm_env";

  virtual function string get_type_name ();
    return type_name;
  endfunction

endclass

```

The list of wrapper components are
- uvm_env
- uvm_monitor
- uvm_scoreboard
- uvm_test

That said, There are two components that add attributes to base `uvm_component`
- uvm_driver
- uvm_agent

# uvm_driver
`uvm_driver` adds `seq_item_port` for sequencer connection.

```verilog
  uvm_seq_item_pull_port #(REQ, RSP) seq_item_port;

  uvm_seq_item_pull_port #(REQ, RSP) seq_item_prod_if; // alias

  uvm_analysis_port #(RSP) rsp_port;
```

and `new`

```verilog
  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item_port    = new("seq_item_port", this);
    rsp_port         = new("rsp_port", this);
    seq_item_prod_if = seq_item_port;
  endfunction // new
```

To go off on a tangent here, I wanted to know what `seq_item_prod_if` is. Grep'ing through 'src', I found it in `ovm2uvm.pl` which indicated it was deprecated ovm artifact. Quick look at OVM specs and i confirmed it.

```perl
    # FIX+MARKER seq_item_prod_if -> seq_item_port
    $t =~ s/seq_item_prod_if.*/$& \/\/ $opt_marker NOTE seq_item_prod_if has been replaced with seq_item_port \n/g;
    $t =~ s/seq_item_prod_if/seq_item_port/g;
    
```

# uvm_agent

`uvn_agent` adds only one attribute `is_active` to mark agent as active or passive.

```verilog
  uvm_active_passive_enum is_active = UVM_ACTIVE;
```

`is_active` is set by setting `is_active` in uvm_config with specific path of that agent.

there is also `get_is_active` which returns the current value.

```verilog
  function void build_phase(uvm_phase phase);
    int active;
    super.build_phase(phase);
    if(get_config_int("is_active", active)) is_active = uvm_active_passive_enum'(active);
  endfunction

  // the active/passive nature of the agent.

  virtual function uvm_active_passive_enum get_is_active();
    return is_active;
  endfunction
```