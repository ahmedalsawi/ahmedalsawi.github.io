---
title: UVM deepdive part 2 - Sequence to Sequencer connection
date: 2020-04-24
toc: false
images:
tags:
  - UVM
  
  
---


# The White Rabbit

the sequencer job is to handle communication between driver and sequence. here is the basic steps:

- Create sequencer class handle from vanilla `uvm_sequencer`

```verilog
uvm_sequencer #(foo_req, foo_rsp) sqr;
```

- Connect it to driver port in connect phase

```verilog
drv.seq_item_port.connect(sqr.seq_item_export);
```

- Define uvm_sequence with `body` task

```verilog
class foo_sequence extends uvm_sequence#(foo_seq_item);
  virtual task body();

  start_item(item);
  // Create the seq item
  ...
  finish_item(item);
  endtask
endclass
```

- Call the sequence with sequencer instance.

```verilog
seq.start(sqr, null);
```

- Finally the driver can use `get_next_item` to get the sequence_item

```verilog
 seq_item_port.get_next_item(req);
 // Do something with req
 seq_item_port.item_done();
```

# Following seq.start down the rabbit hole

let's start with `uvm_sequence` and `seq.start`, it turns out it's very lean class as most logic is define in `uvm_sequence_base` in `src/seq/uvm_sequence_base.svh`

`uvm_sequence_base` is sub class of `uvm_sequence_item` with sequence phases to be overridden.

anyway, `start` eventually calls `body` defined by the user.

```verilog
body();

```

and `body` is virtual task that issues a warning if not overridden.

```verilog
  virtual task body();
    uvm_report_warning("uvm_sequence_base", "Body definition undefined");
    return;
  endtask
```

# How the sequencer and sequence are linked? body to get_next_item.

after creating the item, the `body` method calls `finish_item` to pass over control to sequencer. `finish_item` is defined in `src/seq/uvm_sequence_base.svh`, the task finish_item calls `send_request`

```verilog
  virtual task finish_item (uvm_sequence_item item,
                            int set_priority = -1);
    ...
    sequencer.send_request(this, item);
    ...
  endtask

```

`sequencer.send_request` is defined in `src/seq/uvm_sequence.svh`. which uses `m_sequencer` to call `m_sequencer.send_sequest`

```verilog
  function void send_request(uvm_sequence_item request, bit rerandomize = 0);
    REQ m_request;

  ...
    m_sequencer.send_request(this, m_request, rerandomize);
  endfunction
```

`m_sequencer.send_request` is called from sequencer is defined at `src/seq/uvm_sequencer_param_base.svh`.
and it pushes the item into tlm fifo `m_req_fifo`

```verilog
  if (m_req_fifo.try_put(param_t) != 1) begin
    uvm_report_fatal(get_full_name(), "Concurrent calls to get_next_item() not supported. Consider using a semaphore to ensure that concurrent processes take turns in the driver", UVM_NONE);
  end
```

at this point, we need to jump to the other side `seq_item_port.get_next_item(req);`
then returns the req in the `m_req_fifo`.

```verilog
task uvm_sequencer::get_next_item(output REQ t);
  REQ req_item;
  ...
  m_req_fifo.peek(t);
endtask
```
