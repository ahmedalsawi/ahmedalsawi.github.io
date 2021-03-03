---
title: UVM Deepdive - uvm_create and uvm_send
date: 2021-01-03
toc: false
images:
tags:
  - UVM
---

Typical pattern for sequence `body` does 3 things:

- Create object
- Configure and randomize Object
- Send Object

```verilog
    req = req::type_id::create("req");

    start_item(req);

    // Do something here with req
    
    finish_item(req);
```

UVM provide two macros to do less typing... and confuse everyone (always bonus for UVM people). 
these macros are `uvm_create` and `uvm_send`

# uvm_create

Starting with `uvm_create` which calls `uvm_create_on`

```verilog

	`uvm_create()

     // Do something here with req

	`uvm_send(req)
```


```verilog
`define uvm_create(SEQ_OR_ITEM) \
  `uvm_create_on(SEQ_OR_ITEM, m_sequencer)

```

`uvm_create` uses `uvm_create_on` macro

```verilog
`define uvm_create_on(SEQ_OR_ITEM, SEQR) \
  begin \
  uvm_object_wrapper w_; \
  w_ = SEQ_OR_ITEM.get_type(); \
  $cast(SEQ_OR_ITEM , create_item(w_, SEQR, `"SEQ_OR_ITEM`"));\
  end

```

`create_item` just calls the factory to create object of this sequence_item.

```verilog
  protected function uvm_sequence_item create_item(uvm_object_wrapper type_var, 
                                                   uvm_sequencer_base l_sequencer, string name);

    uvm_factory f_ = uvm_factory::get();
    $cast(create_item,  f_.create_object_by_type( type_var, this.get_full_name(), name ));

    create_item.set_item_context(this, l_sequencer);
  endfunction
```

# uvm_send

Next `uvm_send` which uses `uvm_send_pri` macro

```verilog
`define uvm_send(SEQ_OR_ITEM) \
  `uvm_send_pri(SEQ_OR_ITEM, -1)
```

 `uvm_send_pri` expands to `start_item` and `finish_item` which is expected here.\
but added bonus, `uvm_send_pri` detects if this is a sequence_item or sub-sequence. if it's sub-sequence, it calls `start` instead.


```verilog
`define uvm_send_pri(SEQ_OR_ITEM, PRIORITY) \
  begin \
  uvm_sequence_base __seq; \
  if (!$cast(__seq,SEQ_OR_ITEM)) begin \
     start_item(SEQ_OR_ITEM, PRIORITY);\
     finish_item(SEQ_OR_ITEM, PRIORITY);\
  end \
  else __seq.start(__seq.get_sequencer(), this, PRIORITY, 0);\
  end
  
```