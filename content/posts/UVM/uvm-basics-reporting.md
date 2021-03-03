---
title: "UVM Basics - Reporting"
date: 2020-08-16T00:54:35+02:00
toc: false
images:
tags:
  
  - UVM
---

A previous post went into the UVM Reporting implementation, But i thought UVM reporting is important enough topic to have overview.

# UVM Reporting

UVM Reporting Macros provide 4 severity level `Info`, `Warning`, `Error`,`Fatal`

```
`uvm_info
`uvm_warning
`uvm_error
`uvm_fatal
`uvm_info_context
`uvm_warning_context
`uvm_error_context
`uvm_fatal_context
```

starting with `uvm_info`,

```
`uvm_info(ID,MSG,VERBOSITY)
```

ID: Unique string for the message.
MSG: message string
VERBOSITY:

# Hello world

```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;

class test extends uvm_test;
  `uvm_component_utils(test)
  function new(string name="", uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("TEST/RUN", "hello",UVM_LOW)
  endtask
endclass

module top;

  initial
    run_test("test");

endmodule
```

output

```
UVM_INFO /home/runner/testbench.sv(15) @ 0: uvm_test_top [TEST/RUN] hello
```

message summary

```
UVM_INFO :    2
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
```

# Setting Verbosity on command line
verbosity can be controlled by command plus args.

```
+UVM_VERBOSITY=<LEVEL>
```

LEVEL is one of the following: UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH,
UVM_FULL, UVM_DEBUG.


[1]: https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1c/html/files/macros/uvm_message_defines-svh.html
