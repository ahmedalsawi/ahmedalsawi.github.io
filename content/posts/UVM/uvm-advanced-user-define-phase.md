---
title: "UVM user defined phase"
date: 2020-08-29T00:13:06+02:00
toc: false
images:
tags:
  - UVM
  
---

UVM provide a weird pattern to define user defined phases. Usually, it's useful for adding phases for VIP's

# User defined phase boiler-plate

According to UVM class reference manual, we need to extends on of the class

```verilog
class my_PHASE_phase extends uvm_task_phase;
class my_PHASE_phase extends uvm_topdown_phase;
class my_PHASE_phase extends uvm_bottomup_phase;
```

then override exec_task or exec_func

```verilog
task exec_task(uvm_component comp, uvm_phase schedule);
function void exec_func(uvm_component comp, uvm_phase schedule);
```

the important part about exec method that it calls the phase from the component

```verilog
comp.PHASE_phase(uvm_phase phase);
```

Here is example of `foobar` phase boiter-plate

```verilog
class my_foobar_phase extends uvm_task_phase;

  static local my_foobar_phase m_inst;

  protected function new(string name="foobar");
	super.new(name);
  endfunction : new

  static function my_foobar_phase get();
    if (m_inst == null)
    m_inst = new();
    return m_inst;
  endfunction : get

  task exec_task(uvm_component comp, uvm_phase phase);
    dummy_comp dcomp;
    if($cast(dcomp, comp))
    	dcomp.foobar_phase(phase);
  endtask

endclass
```

it's important to notice that exec_task casts the `comp` handle to `dummy_comp`? so what `dummy_comp`?

```verilog
class dummy_comp extends uvm_component;
      function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  virtual task foobar_phase(uvm_phase phase);
  endtask
endclass

```

`dummy_comp` is an abstract class the defines virtual task `foobar_phase`. component that defines the `foobar_phase` need to inherits from `dummy_comp`. This way we can use `$csat` to check if we need to call `foobar_phase`.

If we don't have `$case`, the call will happen on all component even ones that don't have foobar_phase which results in an error.

Here is exec_task

```verilog
  task exec_task(uvm_component comp, uvm_phase phase);
    dummy_comp dcomp;
    // Will only work if component inherits from dummy_comp and we are sure it has foobar_phase
    if($cast(dcomp, comp))
    	dcomp.foobar_phase(phase);
  endtask
```

# Register the phase with domain schedule

finally, we need to insert the new phase somewhere in domain schedule. For this example, i chose between build and run phases.

```verilog
    function void build_phase(uvm_phase phase);
        uvm_phase shed;
        shed = uvm_domain::get_common_domain();
        shed.add(my_foobar_phase::get(),null,uvm_build_phase::get(),uvm_run_phase::get());
    endfunction
```

# Putting it all together

```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;

/*
*
*/
class dummy_comp extends uvm_component;
      function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  virtual task foobar_phase(uvm_phase phase);
  endtask
endclass

/*
*
*/
class my_foobar_phase extends uvm_task_phase;

  static local my_foobar_phase m_inst;

  protected function new(string name="foobar");
	super.new(name);
  endfunction : new

  static function my_foobar_phase get();
  if (m_inst == null)
  m_inst = new();
  return m_inst;
  endfunction : get

  task exec_task(uvm_component comp, uvm_phase phase);
    dummy_comp dcomp;
    if($cast(dcomp, comp))
    	dcomp.foobar_phase(phase);
  endtask

endclass

/*
*
*/
class test extends dummy_comp;
`uvm_component_utils(test)

function  new(string name="", uvm_component parent=null);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);

  uvm_phase shed;
  shed = uvm_domain::get_common_domain();
  shed.add(my_foobar_phase::get(),null,uvm_build_phase::get(),uvm_run_phase::get());
endfunction

    task foobar_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("FOOBAR", "foorbar_phase called", UVM_MEDIUM)
      phase.drop_objection(this);
    endtask

  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_warning("Test","Hello World!")
      phase.drop_objection(this);
  endtask
endclass

module top;
initial run_test("test");
endmodule
```
