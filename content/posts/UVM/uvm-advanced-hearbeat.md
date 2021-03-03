---
title: "UVM Hearbeat"
date: 2020-08-28T02:28:49+02:00
tags:
  - UVM
  
---

Example of UVM hearbeat based on [example][1] and [UVM heartbeat docs][2]

# Introduction

UVM reference manual defines `Heart Beat` as

> Heartbeats provide a way for environments to easily ensure that their descendants are
> alive. A uvm_heartbeat is associated with a specific objection object. A component that
> is being tracked by the heartbeat object must raise (or drop) the synchronizing objection
> during the heartbeat window. The synchronizing objection must be a
> uvm_callbacks_objection type.

which means a component can monitor a another component and expect "keep alive" objection in a given window. If we don't receive signal, a fatal will be generated.

It's useful to detect hanging component and make sure that specific tasks complete in a given window.

# Step 1: create uvm_callbacks_object

A objection object is shared by the environment and the component.

```verilog
uvm_callbacks_objection obj = new("obj");
```

`uvm_callbacks_object` is defined as

> The uvm_callbacks_objection is a specialized uvm_objection which contains callbacks for
> the raised and dropped events. Callbacks happend for the three standard callback
> activities, raised, dropped, and all_dropped.

which is not the same as `uvm_objection_callback`. Anyway, We won't use callbacks `raised` and `dropped` and `all_dropped` in this example.

# Step 2: Raise objections

The run_phase(or whatever tasks consuming time) of component needs to periodically raise objection to `obj`.

```verilog
	task run_phase(uvm_phase phase);
	repeat(10) begin
        `uvm_info(get_type_name(),$sformatf("raise objections "),UVM_LOW)
		obj.raise_objection(this);
        // A delay is used to simulate time consuming tasks
        [....]
	end
```

# Step 3: setup the environment

according to UVM reference manual, we need to pass 2 things to `uvm_heartbeat`

- shared objection define above
- `uvm_event` to synchronize the window

we define heartbeat and event in env class

```verilog
	uvm_heartbeat hb = new("hb", this, obj);
	uvm_event hb_event= new("hb_event");
```

Add the component to list monitored components. In this case, `m_drv` is component with heartbeat.

```verilog
		hb.add(m_drv);
```

Finally, `hb` needs to start by calling `.start` and passing the synchronization event `hb_event`.
In this example, i am defining a window of 100 units. If the m_drv doesn't raise object in the window, the heartbeat will throw FATAL.

```verilog
	hb.start(hb_event);
    repeat(10) begin
      `uvm_info(get_type_name(),$sformatf("Triggering hb_event"),UVM_LOW)
      hb_event.trigger();
      #100;
    end
```

## Using #50

Using `#50` means that driver will stop raising objections after `500` units. and the heatbeat will trigger at 500 and 600. And generates the FATAL message.

```
testbench.sv(54) @ 0: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 0: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(17) @ 50: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(54) @ 100: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 100: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(17) @ 150: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(54) @ 200: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 200: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(17) @ 250: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(54) @ 300: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 300: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(17) @ 350: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(54) @ 400: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 400: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(17) @ 450: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(54) @ 500: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(54) @ 600: uvm_test_top.m_env [env] Triggering hb_event
 UVM_FATAL @ 600: uvm_test_top.m_env [HBFAIL] Did not recieve an update of obj for component uvm_test_top.m_env.m_drv since last event trigger at time 500 : last update time was 450
```

## Using #100

Using `#100` means that driver will raise objections in 100-unit window until the end of `run_task` where env stops triggering `uvm_event`. And simulation completes successfully.

```
testbench.sv(51) @ 0: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 0: uvm_test_top.m_env.m_drv [driver] raise objections
testbench.sv(51) @ 100: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 100: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 200: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 200: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 300: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 300: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 400: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 400: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 500: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 500: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 600: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 600: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 700: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 700: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 800: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 800: uvm_test_top.m_env.m_drv [driver] raise
testbench.sv(51) @ 900: uvm_test_top.m_env [env] Triggering hb_event
testbench.sv(17) @ 900: uvm_test_top.m_env.m_drv [driver] raise objections
```

# Putting all together

```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;


uvm_callbacks_objection obj = new("obj");

class driver extends uvm_driver;
	`uvm_component_utils(driver)

	function  new(string name="", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	task run_phase(uvm_phase phase);
      repeat(10) begin
      `uvm_info(get_type_name(),$sformatf("raise objections "),UVM_LOW)
		obj.raise_objection(this);
		#100;

	end
	endtask
endclass

class env extends uvm_env;
	`uvm_component_utils(env)

	driver m_drv;
	uvm_heartbeat hb = new("hb", this, obj);
	uvm_event hb_event= new("hb_event");

	function  new(string name="", uvm_component parent=null);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_drv = driver::type_id::create("m_drv", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		hb.add(m_drv);

	endfunction

	task run_phase(uvm_phase phase);
	phase.raise_objection(this);
		hb.start(hb_event);
    repeat(10) begin
      `uvm_info(get_type_name(),$sformatf("Triggering hb_event"),UVM_LOW)
      hb_event.trigger();
      #100;
    end
      #1000;
	phase.drop_objection(this);
	endtask

endclass

class test extends uvm_test;
`uvm_component_utils(test)

env m_env;
function  new(string name="", uvm_component parent=null);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_env = env::type_id::create("m_env", this);
endfunction

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

[1]: https://verificationguide.com/uvm/uvm-heartbeat-example/
[2]: https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1c/html/files/base/uvm_heartbeat-svh.html#uvm_heartbeat
