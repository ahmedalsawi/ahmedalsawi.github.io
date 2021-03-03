---
title: "UVM Report Catcher"
date: 2020-09-01T03:13:06+02:00
tags:
  - UVM
  
---

How to use UVM report catcher to change message attributes. Report catcher can't change the message format. Report server can be used to change the format.

# Report Catcher

first we need to sub-class `uvm_report_catcher` and override `catch`. in this example,`get_severity` and `get_id` are used to filter messages. Then `THROW` is returned which passes the modified message.

```verilog
class catcher extends uvm_report_catcher;
  function new(string name="catcher");
    super.new(name);
  endfunction
  function action_e catch();
    if(get_severity() == UVM_WARNING&& get_id() == "MYID")
      set_severity(UVM_ERROR);
    return THROW;
  endfunction
endclass
```

All getters and setters can be found at [UVM report cat catcher][1]

# Register report catcher callback

Create catcher callback

```verilog
catcher cb= new("catcher");
```

At some point before run_phase, Register the callback with `uvm_report_cb`. That's it.

```verilog
function void start_of_simulation_phase(uvm_phase phase);
	uvm_report_cb::add(null, cb);
endfunction

```

After promoting warning to Error, the following message will be printed

```
UVM_ERROR testbench.sv(35) @ 0: uvm_test_top [MYID] Hello World report_catcher
```

# Putting all together

```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;


class catcher extends uvm_report_catcher;
  function new(string name="catcher");
    super.new(name);
  endfunction
  function action_e catch();
    if(get_severity() == UVM_WARNING&& get_id() == "MYID")
      set_severity(UVM_ERROR);
    return THROW;
  endfunction
endclass

class test extends uvm_test;
`uvm_component_utils(test)

  catcher cb= new("catcher");
  function  new(string name="", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    uvm_report_cb::add(null, cb);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_warning("MYID","Hello World report_catcher")
    phase.drop_objection(this);
  endtask
endclass

module top;
  initial run_test("test");
endmodule
```

[1]: https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1a/html/files/base/uvm_report_catcher-svh.html
