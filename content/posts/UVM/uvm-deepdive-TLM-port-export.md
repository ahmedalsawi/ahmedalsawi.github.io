---
title: "UVM Deepdive - TLM port to imp Connection"
date: 2021-01-12
toc: false
images:
tags:
  - UVM
---

This is deepdive into basic TLM connection port-to-imp. I am using `uvm_blocking_put_port` but others shouldn't be different.


# Producer/Consumer example 

The producer creates `port` and calls `put` with the transaction.

```verilog
class producer extesnds uvm_component;
...
...

uvm_blocking_put_port #(transaction) put_port;

function build_phase(...);
put_port = new("foo", this);
endfunction

function run_phase(....);
    ....
    put_port.put(t);

endfunction

endclass
```

The consumer creates `imp` and provide `put` methods that gets called eventually.

```verilog
class consumer extends ...;

uvm_blocking_put_imp #(transction, consumer) imp;

function void build_phase(...);
    imp = new("bar", this);
endfunction

task put(transaction t);
//  do something with transaction here
endclass


endclass
```

and somewhere  `connect_phase` calls `connect` between port to imp.

```verilog
producer_inst.put_port.connect(consumer_inst.imp)
```
# uvm_blocking_put_port


```verilog
class uvm_blocking_put_port #(type T=int)
  extends uvm_port_base` #(uvm_tlm_if_base #(T,T));
  `UVM_PORT_COMMON(`UVM_TLM_BLOCKING_PUT_MASK,"uvm_blocking_put_port")
  `UVM_BLOCKING_PUT_IMP (this.m_if, T, t)
endclass 
```

The two macros used

- `UVM_PORT_COMMON` define constructor and `get_type_name`
- `UVM_BLOCKING_PUT_IMP` calls `put` from `m_if` defined in `uvm_port_base`

```verilog

`define UVM_TLM_GET_TYPE_NAME(NAME) \
  virtual function string get_type_name(); \
    return NAME; \

  endfunction
`define UVM_PORT_COMMON(MASK,TYPE_NAME) \
  function new (string name, uvm_component parent, \
                int min_size=1, int max_size=1); \
    super.new (name, parent, UVM_PORT, min_size, max_size); \
    m_if_mask = MASK; \
  endfunction \
  `UVM_TLM_GET_TYPE_NAME(TYPE_NAME)
```

```verilog
`define UVM_BLOCKING_PUT_IMP(imp, TYPE, arg) \
  task put (TYPE arg); \
    imp.put(arg); \
  endtask
```
To sum up, `put` is defined by the macro `UVM_BLOCKING_PUT_IMP` and calls `put` from `imp.put` which is set to `this.m_if` after macro expansion. So, what is `m_if`?

# uvm_blocking_put_imp

On the consumer side, `uvm_blocking_put_imp` extends `uvm_port_base` as well.

```verilog
class uvm_blocking_put_imp #(type T=int, type IMP=int)
  extends uvm_port_base #(uvm_tlm_if_base #(T,T));
  `UVM_IMP_COMMON(`UVM_TLM_BLOCKING_PUT_MASK,"uvm_blocking_put_imp",IMP)
  `UVM_BLOCKING_PUT_IMP (m_imp, T, t)
endclass

```

and `UVM_IMP_COMMON`, which calls `super.new` with `imp`. Note that `imp` is `this` which point to consumer component.

```verilog
`define UVM_IMP_COMMON(MASK,TYPE_NAME,IMP) \
  local IMP m_imp; \
  function new (string name, IMP imp); \
    super.new (name, imp, UVM_IMPLEMENTATION, 1, 1); \
    m_imp = imp; \
    m_if_mask = MASK; \
  endfunction \
  `UVM_TLM_GET_TYPE_NAME(TYPE_NAME)
```

and `UVM_BLOCKING_PUT_IMP` expands to `put` method with `m_imp` to `m_imp.put`.


The magic is happening in `uvm_port_base` depending on the type passed `UVM_IMPLEMENTATION` or `UVM_PORT`.

# uvm_port_base

## connect
A good place to start is `connect`. the most important part here is the assignment to `m_provided_by`.

```verilog
  virtual function void connect (this_type provider);
    // Some error checking
    ...

    m_provided_by[provider.get_full_name()] = provider;
    provider.m_provided_to[get_full_name()] = this;
  endfunction

``` 
Side note, `uvm_port_base` extends `uvm_tlm_if_base` which provides empty interface for child classes to implement.

```verilog
class uvm_blocking_put_port #(type T=int)
  extends uvm_port_base` #(uvm_tlm_if_base #(T,T));
```
and `uvm_tlm_if_base`

```verilog
virtual class uvm_tlm_if_base #(type T1=int, type T2=int);
  virtual task put( input T1 t );
    uvm_report_error("put", `UVM_TASK_ERROR, UVM_NONE);
  endtask
  ...
  ...
endclass
```

## resolve_bindings
So, what is the link between `connect` and `m_if.put` and `imp.put`? Here where `resolve_bindings` shows up.
The comments in `uvm_port_base.svh` says this called at end_of_elaboration (ie after the build and connect).

```verilog
  // Function: resolve_bindings
  //
  // This callback is called just before entering the end_of_elaboration phase.
  // It recurses through each port's fanout to determine all the imp destina-
  // tions. It then checks against the required min and max connections.
  // After resolution, <size> returns a valid value and <get_if>
  // can be used to access a particular imp.
  //
  // This method is automatically called just before the start of the
  // end_of_elaboration phase. Users should not need to call it directly.

```

The key part in `resolve_bindings` is the following snippet:

```verilog
    if (is_imp()) begin
      m_imp_list[get_full_name()] = this;
    end
    else begin
      foreach (m_provided_by[nm]) begin
        this_type port;
        port = m_provided_by[nm];
        port.resolve_bindings();
        m_add_list(port);
      end
    end

    ...
    ...
    if (size())
      set_if(0);
```

let's start from the bottom, `set_if` is called to set `m_if`

```verilog
  function void set_if (int index=0);
    m_if = get_if(index);
    if (m_if != null)
      m_def_index = index;
  endfunction
```

and `get_if` searches for `index` in `m_imp_list`

```verilog
  function uvm_port_base #(IF) get_if(int index=0);
    string s;
    ...
    ...
    foreach (m_imp_list[nm]) begin
      if (index == 0)
        return m_imp_list[nm];
      index--;
    end
  endfunction
```

So, `m_imp_list` is used to set the `m_if`. This leads to the first part in `resolve_bindings`.

```verilog
    if (is_imp()) begin
      m_imp_list[get_full_name()] = this;
    end
    else begin
      foreach (m_provided_by[nm]) begin
        this_type port;
        port = m_provided_by[nm];
        port.resolve_bindings();
        m_add_list(port);
      end
    end
```

There are two scenarios for uvm_port_base
- imp
- not imp(port, or export)

For `imp`, `this` (which points to imp port) is added to `m_imp_list`.
```verilog
      m_imp_list[get_full_name()] = this;
```

For port, `m_add_list` is called which adds provider (consumer imp) into `m_imp_list`

```verilog
  local function void m_add_list           (this_type provider);
    string sz;
    this_type imp;

    for (int i = 0; i < provider.size(); i++) begin
      imp = provider.get_if(i);
      if (!m_imp_list.exists(imp.get_full_name()))
        m_imp_list[imp.get_full_name()] = imp;
    end

  endfunction
```

# Summary

In elaboration:
- port and imp are created
- `connect` is called to connect port to imp and updates `m_provided_by`.
- `resolve_bindings` is called on both port and imp. It updates `m_imp_list` on both sides. In case of port, it sets `m_if` to consumer interface (which is the consumer imp port)

In run phase:
- producer calls `port.put` which calls
- `m_if.put` from `uvm_port_base` which points to `consumer imp port put`, which calls put from `consumer component put`.