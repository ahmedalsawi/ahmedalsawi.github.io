---
title: UVM deepdive part 3 - Factory
date: 2020-05-01
toc: false
images:
tags:
  - UVM
  
  
---

# The White Rabbit

The factory is a way to dynamically construct objects and easily configurable.
it requires registering the class first then using `create` to get an object

- registration

```
class env extends uvm_env;
 `uvm_component_utils(uvm_env)
```

- Creation

```
env = uvm_env::type_id::create("env",this);
```

## Registration

`uvm_component_utils` is defined in `src/macros/uvm_object_defines.svh`
```
`define uvm_component_utils(T) \
   `m_uvm_component_registry_internal(T,T) \
   `m_uvm_get_type_name_func(T) \
```

let's start with `m_uvm_get_type_name_func` which simply defines the `type_name` by stringify the `T`

```
`define m_uvm_get_type_name_func(T) \
   const static string type_name = `"T`"; \
   virtual function string get_type_name (); \
     return type_name; \
   endfunction
```


Then `m_uvm_component_registry_internal` just adds `type_id`  type which is going to be called to create the object. (the protagonist)
```
`define m_uvm_component_registry_internal(T,S) \
   typedef uvm_component_registry #(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction
```

# Initialization

It's clear that the heavy stuff is done by `uvm_component_registry::create` but first looking at `get`

in `src/base/uvm_registry.svh`, `get` returns `me` if initialized. but `me` is static and already initialized before any create is called.

```

  local static this_type me = get();


  // Function: get
  //
  // Returns the singleton instance of this type. Type-based factory operation
  // depends on there being a single proxy instance for each registered type. 

  static function this_type get();
    if (me == null) begin
      uvm_factory f = uvm_factory::get();
      me = new;
      f.register(me);
    end
    return me;
  endfunction
```

in `get` above, the factory singleton is created as well(if not already). so in `src/base/uvm_factory.svh`, `get` is defined.

```
function uvm_factory uvm_factory::get();
  if (m_inst == null) begin
    m_inst = new();
  end
  return m_inst;
endfunction
```

# Creation

To create the component, in build phase the `type_id::create` is called

```
env = uvm_env::type_id::create("env",this);
```

`create` in `src/base/uvm_registry.svh`, calls `create_component_by_type`

```
  static function T create (string name="", uvm_component parent=null,
                            string contxt="");
    uvm_object obj;
    uvm_factory f = uvm_factory::get();
    ...
    ...
    obj = f.create_object_by_type(get(),contxt,name);
    ...
    ...
  endfunction
```


`create_component_by_type` first calls `find_override_by_type` which checks for override. if there is no override, it returns `requested_type` as is.


```
function uvm_object uvm_factory::create_object_by_type (uvm_object_wrapper requested_type,  
                                                        string parent_inst_path="",  
                                                        string name=""); 

...
...

  requested_type = find_override_by_type(requested_type, full_inst_path);

  return requested_type.create_object(name);

endfunction
```

Finally `create_component_by_type` calls `create_component`

```
  return requested_type.create_component(name, parent);
```

`create_component` is picked up from requested_type which is `uvm_component_registry`
and it calls `new` to create the object

```
virtual function uvm_component create_component (string name,
                                                   uvm_component parent);
    T obj;
    obj = new(name, parent);
    return obj;
  endfunction
```
