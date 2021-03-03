---
title: UVM deepdive part 4 - Configuration database
date: 2020-05-08
toc: false
images:
tags:
  - UVM
  
  
---

# The White Rabbit
Configuration database is used to store  parameters through centralized database. one of the most used pattern is storing the virtual interface.

```
uvm_config_db#(virtual v_if)::set(null,"*","v_if",intf);
```

Then any component get virtual interface to access pin signals

```
uvm_config_db#(virtual v_if)::get(null,"*","v_if",vintf);
```

# ::set
Starting with `::set`, it is defined in `src/base/uvm_config_db.svh` as static method of class `uvm_class_db`

```
class uvm_config_db#(type T=int) extends uvm_resource_db#(T);

...
...
  static function void set(uvm_component cntxt,
                           string inst_name,
                           string field_name,
                           T value);
```

`set` uses `cntxt` to build the   `inst_name` then add resource `m_rsc` if it doesn't exist


```
    uvm_pool#(string,uvm_resource#(T)) pool;


    if(cntxt == null) 
      cntxt = top;
    if(inst_name == "") 
      inst_name = cntxt.get_full_name();
    else if(cntxt.get_full_name() != "") 
      inst_name = {cntxt.get_full_name(), ".", inst_name};

    if(!m_rsc.exists(cntxt)) begin
      m_rsc[cntxt] = new;
    end
    pool = m_rsc[cntxt];
```

`m_rsc` is defined as assoc array of pools

```
  static uvm_pool#(string,uvm_resource#(T)) m_rsc[uvm_component];
```

assuming the field wasn't already in the pool for that context, a new resource is created and added to the pool

```
       r = new(field_name, inst_name);
       pool.add(lookup, r);
```

and in `uvm_pool.svh`, the `add` just adds the item (in this case resource to local protected assoc array)
```
  virtual function void add (KEY key, T item);
    pool[key] = item;
  endfunction
```

at this point, the value and cntxt are passed to resource.

```
  r.write(value, cntxt);
```

and `write`, define in `uvm_resource.svh`, just stores the value in local variable `val`

```
    val = t;
```

at this point, we have the resource `r` ready to be in `uvm_resource_pool`. Note that `uvm_resource_pool` will be used by `::get` in the next section.

```
    if(exists) begin
      uvm_resource_pool rp = uvm_resource_pool::get();
      rp.set_priority_name(r, uvm_resource_types::PRI_HIGH);
    end
    else begin
      //Doesn't exist yet, so put it in resource db at the head.
      r.set_override();
    end
```

`set_override` is defined in `uvm_resource.svh`,

```
  function void set_override(uvm_resource_types::override_t override = 2'b11);
    uvm_resource_pool rp = uvm_resource_pool::get();
    rp.set(this, override);
  endfunction

```

`uvm_resource_pool` has the `set` method called with resource. Note the resource has the value and context at this point.
rq is created for that resource, and added to `rtab` assoc array

```
        rq = new();
        ....
      if(override & uvm_resource_types::NAME_OVERRIDE)
        rq.push_front(rsrc);
      else
        rq.push_back(rsrc);

      rtab[name] = rq;
```

# ::get

it is also defined in `src/base/uvm_config_db.svh` as static method of class `uvm_class_db`. have similar logic to `set`

starting with creating the `inst_name`
```
   if(cntxt == null) 
      cntxt = uvm_root::get();
    if(inst_name == "") 
      inst_name = cntxt.get_full_name();
    else if(cntxt.get_full_name() != "") 
      inst_name = {cntxt.get_full_name(), ".", inst_name};
```

then the instance name is looked up in `uvm_resource_pool`

```
    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_resource_types::rsrc_q_t rq;
    ...
    rq = rp.lookup_regex_names(inst_name, field_name, uvm_resource#(T)::get_type());
    r = uvm_resource#(T)::get_highest_precedence(rq);
    ...
        value = r.read(cntxt);
```

`lookup_regex_names` looks up the name and returns the `uvm_resource_pool`. it iterates over rq in rtab and returns it.

```
  function uvm_resource_types::rsrc_q_t lookup_regex_names(string scope,
                                                           string name,
                                                           uvm_resource_base type_handle = null);

...
...
      foreach (rtab[re]) begin
      rq = rtab[re];
      for(i = 0; i < rq.size(); i++) begin
        r = rq.get(i);
        if(uvm_re_match(uvm_glob_to_re(re),name) == 0)
          // does the type and scope match?
          if(((type_handle == null) || (r.get_type_handle() == type_handle)) &&
             r.match_scope(scope))
            result_q.push_back(r);
      end
    end
    return result_q;
```


`get_highest_precedence` given `uvm_resource_types::rsrc_q_t`, will get the first element in the queue that was `push_front` in last stage in `::set`

```
  function uvm_resource_base get_highest_precedence(ref uvm_resource_types::rsrc_q_t q);
...
...
    // get the first resources in the queue
    rsrc = q.get(0);
```