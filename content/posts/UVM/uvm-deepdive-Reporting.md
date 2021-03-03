---
title: UVM deepdive part 5 - Reporting
date: 2020-05-08
toc: false
images:
tags:
  - UVM
  
  
---

# The White Rabbit

uvm reporting is an important mechanism to control which messages are printed to the logs. In this part, i am going to trace one of the macro to IO system task

```
`uvm_warning("MYWARN1", "This is a warning")
```

# uvm_warning

starting with macro expansion
```
`define uvm_warning(ID,MSG) \
   begin \
     if (uvm_report_enabled(UVM_NONE,UVM_WARNING,ID)) \
       uvm_report_warning (ID, MSG, UVM_NONE, `uvm_file, `uvm_line); \
   end

```

in `uvm_globals.svh`, the function `uvm_report_warning` is defined

```
function void uvm_report_warning(string id,
                                 string message,
                                 int verbosity = UVM_MEDIUM,
				 string filename = "",
				 int line = 0);
  uvm_root top;
  top = uvm_root::get();
  top.uvm_report_warning(id, message, verbosity, filename, line);
endfunction
```

 `top` is uvm_root which extends `uvm_component` which extends `uvm_report_object`

and `uvm_report_warning` is defined in `uvm_report_object`

```
  virtual function void uvm_report_warning( string id,
                                            string message,
                                            int verbosity = UVM_MEDIUM,
                                            string filename = "",
                                            int line = 0);
    m_rh.report(UVM_WARNING, get_full_name(), id, message, verbosity, 
               filename, line, this);
  endfunction
```

and `m_rh` is defined as `uvm_report_handler`

```
  uvm_report_handler m_rh;
```

in `uvm_report_handler.svh`, the `report` function is defined

```
  virtual function void report(
      uvm_severity severity,
      string name,
      string id,
      string message,
      int verbosity_level=UVM_MEDIUM,
      string filename="",
      int line=0,
      uvm_report_object client=null
      );

    uvm_report_server srvr;
    srvr = uvm_report_server::get_server();

    if (client==null)
      client = uvm_root::get();


    srvr.report(severity,name,id,message,verbosity_level,filename,line,client);
    
  endfunction
```

in `uvm_report_server.svh`, `report` is defined

```
    if(report_ok)
      report_ok = uvm_report_catcher::process_all_report_catchers(
                     this, client, severity, name, id, message,
                     verbosity_level, a, filename, line);

    if(report_ok) begin	
      m = compose_message(severity, name, id, message, filename, line); 
      process_report(severity, name, id, message, a, f, filename,
                     line, m, verbosity_level, client);
    end
```

and finally the printing is done in `process_report` with `$display`

```
  virtual function void process_report(
      uvm_severity severity,
      string name,
      string id,
      string message,
      uvm_action action,
      UVM_FILE file,
      string filename,
      int line,
      string composed_message,
      int verbosity_level,
      uvm_report_object client
      );
    // update counts
    incr_severity_count(severity);
    incr_id_count(id);

    if(action & UVM_DISPLAY)
      $display("%s",composed_message);

```