---
title: "UVM Deepdive - transaction id"
date: 2021-01-03
toc: false
images:
tags:
  - UVM
---

Have you ever wondered what `set_id_info` does? If you have, read on.

UVM docs describe `set_id_info` as:

> function void set_id_info(	uvm_sequence_item 	item	)
> 
> Copies the sequence_id and transaction_id from the referenced item into the calling item.  This routine should always be used by drivers to initialize responses for future compatibility.


Basically, `set_id_info` is called as a part of `req`/`rsp` protocol. driver can have something like the following

```verilog
				seq_item_port.get(req);
				rsp = new();
				rsp.set_id_info(req);

                ...
				seq_item_port.put(rsp);
```

Jumping right into `src/seq/uvm_sequence_item.svh`, it's obvious that `set_id_info` copies transaction id and sequence id. so, why is this important anyway? 
Let's start by looking at `set_transaction_id` and `get_transaction_id`.

```verilog

  // Function: set_id_info
  //
  // Copies the sequence_id and transaction_id from the referenced item into
  // the calling item.  This routine should always be used by drivers to
  // initialize responses for future compatibility.

  function void set_id_info(uvm_sequence_item item);
    if (item == null) begin
      uvm_report_fatal(get_full_name(), "set_id_info called with null parameter", UVM_NONE);
    end
    this.set_transaction_id(item.get_transaction_id());
    this.set_sequence_id(item.get_sequence_id());
  endfunction
```


In `src/base/uvm_transaction.svh`, `set_transaction_id` and `get_transaction_id` are setter and getter for `m_transaction_id`.


```verilog
// set_transaction_id
function void uvm_transaction::set_transaction_id(integer id);
    m_transaction_id = id;
endfunction
```

Looking for callers of `set_transaction_id`, it's called from `uvm_sequencer_param_base::send_request` 

```verilog
    if (param_t.get_transaction_id() == -1) begin
      param_t.set_transaction_id(sequence_ptr.m_next_transaction_id++);
    end
```

so, `m_next_transaction_id` is moving counter for the transaction items in the sequence.

```verilog
class uvm_sequence_base extends uvm_sequence_item;

  protected uvm_sequence_state m_sequence_state;
            int                m_next_transaction_id = 1;
```

At this point we know what is transaction id and what sets it. 

But who uses it? Let's trace `get_transaction_id` then. I can see two places where transaction id is used.

First place, `get_response` can be called from sequence to get the rsp after sending req

```verilog
				`uvm_create(req)

...
...
...
				`uvm_send(req)
				get_response(rsp);
```

and `get_response` calls `get_base_response`
```verilog
  virtual task get_response(output RSP response, input int transaction_id = -1);
    uvm_sequence_item rsp;
    get_base_response( rsp, transaction_id);
    $cast(response,rsp);
  endtask


```

and `get_base_response`  gets response from the queue if it can match id.

```verilog

  virtual task get_base_response(output uvm_sequence_item response, input int transaction_id = -1);

    int queue_size, i;
....
....

      queue_size = response_queue.size();
      for (i = 0; i < queue_size; i++) begin
        if (response_queue[i].get_transaction_id() == transaction_id) 
          begin
            $cast(response,response_queue[i]);
            response_queue.delete(i);
            return;
          end
      end
```

Second place, for driver/sequence protocol, driver calls `item_done`  to unblock sequence (blocked at finish_item).
 
And `item_done` sets `m_wait_for_item_transaction_id`

```verilog

function void uvm_sequencer::item_done(RSP item = null);
...
...
    m_wait_for_item_transaction_id = t.get_transaction_id();
```

on sequence side, `finish_item` calls  `wait_for_item_done`


```verilog
  virtual task finish_item (uvm_sequence_item item,
                            int set_priority = -1);
...
...
    sequencer.wait_for_item_done(this, -1);
```

and `wait_for_item_done` blocks until the right transaction id comes up.

```verilog
task uvm_sequencer_base::wait_for_item_done(uvm_sequence_base sequence_ptr,
                                            int transaction_id);
...
...
    wait ((m_wait_for_item_sequence_id == sequence_id &&
           m_wait_for_item_transaction_id == transaction_id));
```

