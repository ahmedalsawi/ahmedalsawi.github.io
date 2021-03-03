---
title: "UVM Sequencer grab()"
date: 2020-08-31T03:13:06+02:00
tags:
  - UVM
  
---

# Hierarchical sequences
Big part of sequencer functionality( ie. complexity) is sequence arbitration. That's why we have the whole `start_item` and `get_next_item` thing AKA driver-sequence protocol.

In this example, I am using 2 sequences with `p_sequencer`. By default, the priority of all items from sequences are equal and default arbitration algorithm is fifo.

```verilog
class my_sequence extends uvm_sequence#(my_transaction);
  `uvm_object_utils(my_sequence)
  `uvm_declare_p_sequencer(my_sequencer)
  	function  new(string name="");
		super.new(name);
	endfunction

  	m_seq1 s1;
    m_seq2 s2;
    
  	task body();
      
      s1 = m_seq1::type_id::create("s1");
      s2 = m_seq2::type_id::create("s2");
        
      fork
        s1.start(p_sequencer);
        s2.start(p_sequencer);
      join
    endtask: body
endclass
```

Sequencer alternates between sequences. So, we have item from each sequence in order they were called from virtual sequence. 

```
#  0
# 10
#  1
# 11
#  2
# 12
#  3
# 13
#  4
# 14
```

# grab the sequencer
In some scenarios (like in interrupt handling), it's needed to steal the sequencer to send all the items from a given sequence. That's why there is `grab()`.

`grab` allows the sequence to send all transactions until sequence call `ungrab`. After that sequencer will continue getting items from other sequences

```verilog
      grab();
      for(int i = 0; i < 5; i++) begin
        item = new();
        start_item(item);
        item.i = i + 10;
        finish_item(item);
      end
      ungrab();
```

here is the output with `grab`. all the items from my_seq2 is send first then the items from my_seq1.

```verilog
# 10
# 11
# 12
# 13
# 14
#  0
#  1
#  2
#  3
#  4

```
# Putting it all together
```verilog
`include "uvm_macros.svh"

import uvm_pkg::*;


class my_transaction extends uvm_sequence_item;
  rand logic[3:0] i;
endclass

class m_seq1 extends uvm_sequence#(my_transaction);
  `uvm_object_utils(m_seq1)
  	function  new(string name="");
		super.new(name);
	endfunction

    task body();
      my_transaction item;
      for(int i = 0; i < 5; i++) begin
        item = new();
        start_item(item);
        item.i = i ;
        finish_item(item);
      end
    endtask: body
endclass

class m_seq2 extends uvm_sequence#(my_transaction);
  `uvm_object_utils(m_seq2)
  	function  new(string name="");
		super.new(name);
	endfunction

    task body();
      my_transaction item;
      grab();
      for(int i = 0; i < 5; i++) begin
        item = new();
        start_item(item);
        item.i = i + 10;
        finish_item(item);
      end
      ungrab();
    endtask: body
endclass


typedef uvm_sequencer #(my_transaction) my_sequencer;

/*
*/
class my_sequence extends uvm_sequence#(my_transaction);
  `uvm_object_utils(my_sequence)
  `uvm_declare_p_sequencer(my_sequencer)
  	function  new(string name="");
		super.new(name);
	endfunction

  	m_seq1 s1;
    m_seq2 s2;
    
  	task body();
      
      s1 = m_seq1::type_id::create("s1");
      s2 = m_seq2::type_id::create("s2");
        
      fork
        s1.start(p_sequencer);
        s2.start(p_sequencer);
      join
    endtask: body
endclass

/*
*/
class driver extends uvm_driver#(my_transaction);
	`uvm_component_utils(driver)

	function  new(string name="", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	task run_phase(uvm_phase phase);
      my_transaction req;
      
      forever begin
         seq_item_port.get_next_item(req);
         $display(req.i);
         seq_item_port.item_done();
      end
	endtask
endclass

/*
*/
class my_agent extends uvm_agent;
  	`uvm_component_utils(my_agent)
  
  	driver m_drv;
    my_sequencer m_seqr;
  
	function  new(string name="", uvm_component parent=null);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_drv = driver::type_id::create("m_drv", this);
        m_seqr= my_sequencer::type_id::create("m_seqr", this);
	endfunction

	function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
	endfunction
endclass

/*
*/
class my_env extends uvm_env;
	`uvm_component_utils(my_env)

  	my_agent m_agt;
  
	function  new(string name="", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      	m_agt = my_agent::type_id::create("m_agt", this);
	endfunction

	function void connect_phase(uvm_phase phase);
      	super.connect_phase(phase);
	endfunction
endclass


/*
*/
class my_test extends uvm_test;
`uvm_component_utils(my_test)

  my_env m_env;
  my_sequence m_seq;
  
  function  new(string name="", uvm_component parent=null);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_env = my_env::type_id::create("m_env", this);
      m_seq = my_sequence::type_id::create("m_seq");
  endfunction

  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      m_seq.start(m_env.m_agt.m_seqr, null);
      phase.drop_objection(this);
  endtask
endclass

/*
*/
module top;
  initial run_test("my_test");
endmodule
```