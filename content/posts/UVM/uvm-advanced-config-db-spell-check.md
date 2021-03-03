---
title: "uvm_config_db spellchecker"
date: 2020-08-31T03:13:06+02:00
tags:
  - UVM
  
---

Fun trivia i didn't know about UVM config DB. It has build-in spell checker for resource lookup. Who Knew!

The class for spell checker is `uvm_spell_chkr`. grep'ing trough UVM-1.1d, i found it's used once inside `uvm_resource.svh`

```verilog
  function bit spell_check(string s);
    return uvm_spell_chkr#(uvm_resource_types::rsrc_q_t)::check(rtab, s);
  endfunction
```

looking at `check`, It seems like poorman's spell checker for resource names.

```verilog
    [.........]
    $display("%s not located", s);

    // if (min == max) then the string table is empty
    if(min == max) begin
      $display("  no alternatives to suggest");
      return 0;
    end

    // dump all the alternatives with the minimum distance
    foreach(min_key[i]) begin
      $display("  did you mean %s?", min_key[i]);
    end

```

And `spell_check` is called from lookup_name

```verilog
  function uvm_resource_types::rsrc_q_t lookup_name(string scope = "",
                                                    string name,
                                                    uvm_resource_base type_handle = null,
                                                    bit rpterr = 1);
  [...]
    if((rpterr && !spell_check(name)) || (!rpterr && !rtab.exists(name))) begin
      return q;
    end
```

And finally,`lookup_name` is called with hard-codded 0 to `rpterr`. which means it's disable for `config_db::get`

```verilog
  function uvm_resource_types::rsrc_q_t lookup_regex_names(string scope,
                                                           string name,
                                                           uvm_resource_base type_handle = null);
      [.....]
      result_q = lookup_name(scope, name, type_handle, 0);
```

luckily, `exists` provide an argument to enable spell check. for the example below, it will print

```
 nama not located
   did you mean name?
   did you mean namg?
```

# Putting it all together

```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;


class test extends uvm_test;
`uvm_component_utils(test)
int name=5,name1;

function  new(string name="", uvm_component parent=null);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);
	phase.raise_objection(this);
  `uvm_warning("Test","Hello World!")
  uvm_config_db#(int)::set(null,"*", "name",name);
  uvm_config_db#(int)::set(null,"*", "namg",name);
  uvm_config_db#(int)::get(null,"*", "nama",name1);
  uvm_config_db#(int)::exists(null,"*","nama", 1);
	phase.drop_objection(this);
endtask
endclass
module top;
initial run_test("test");
endmodule
```
