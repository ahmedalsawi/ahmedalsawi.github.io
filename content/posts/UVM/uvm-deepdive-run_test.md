---
title: UVM deepdive part 1 - run_test
date: 2020-04-24
toc: false
images:
tags:
  - UVM
---


# Hello World

The simplest UVM testbench starts with `run_test`.

```
initial begin
  run_test("test01");
end
```

`run_test` is defined on `src/base/uvm_globals.svh` where it constructs `uvm_root` and run run_test from `top.run_test()`

```
task run_test (string test_name="");
  uvm_root top;
  top = uvm_root::get();
  top.run_test(test_name);
endtask
```

# Creating uvm_root

uvm_root is created by calling `uvm_root::get` static method. Beside creating the singelton `uvm_root`, it creates the `uvm_domain` which is also a singelton.

```
// src/base/uvm_root.svh
function uvm_root uvm_root::get();
  if (m_inst == null) begin
    m_inst = new();
    void'(uvm_domain::get_common_domain());
    m_inst.m_domain = uvm_domain::get_uvm_domain();
  end
  return m_inst;
endfunction
```

`get_common_domain` initializes `m_common_domain` and register phases (build, connect, etc.).

```
  static function uvm_domain get_common_domain();

    uvm_domain domain;
    uvm_phase schedule;

    if (m_common_domain != null)
      return m_common_domain;

    domain = new("common");
    domain.add(uvm_build_phase::get());
    domain.add(uvm_connect_phase::get());
    domain.add(uvm_end_of_elaboration_phase::get());
    domain.add(uvm_start_of_simulation_phase::get());
    domain.add(uvm_run_phase::get());
    domain.add(uvm_extract_phase::get());
    domain.add(uvm_check_phase::get());
    domain.add(uvm_report_phase::get());
    domain.add(uvm_final_phase::get());
    m_domains["common"] = domain;

    // for backward compatibility, make common phases visible;
    // same as uvm_<name>_phase::get().
    build_ph               = domain.find(uvm_build_phase::get());
    connect_ph             = domain.find(uvm_connect_phase::get());
    end_of_elaboration_ph  = domain.find(uvm_end_of_elaboration_phase::get());
    start_of_simulation_ph = domain.find(uvm_start_of_simulation_phase::get());
    run_ph                 = domain.find(uvm_run_phase::get());
    extract_ph             = domain.find(uvm_extract_phase::get());
    check_ph               = domain.find(uvm_check_phase::get());
    report_ph              = domain.find(uvm_report_phase::get());
    m_common_domain = domain;

    domain = get_uvm_domain();
    m_common_domain.add(domain,
                     .with_phase(m_common_domain.find(uvm_run_phase::get())));


    return m_common_domain;

  endfunction
```

In this snippet from `get_common_domain`, there is `get_uvm_domain` that fills the run phases (reset, main, etc).

```
 domain = get_uvm_domain();
    m_common_domain.add(domain,
                     .with_phase(m_common_domain.find(uvm_run_phase::get())));
```

I traced `get_uvm_domain`, but i will focus on common uvm phases. The phase are defined in `src/base/uvm_common_phases.svh`.

The key task is `exec_task` which calls `comp.run_phase(phase)`.

```
// src/base/uvm_common_phases.svh
class uvm_run_phase extends uvm_task_phase;
   virtual task exec_task(uvm_component comp, uvm_phase phase);
      comp.run_phase(phase);
   endtask
   ...
endclass
```

# Running the test

`top.run_test` is defined in `src/base/uvm_root.svh`

```
task uvm_root::run_test(string test_name="");
```

`uvm_root:run_test` first parses +UVM_TESTNAME and eventually creates `uvm_test_top` object

```
    $cast(uvm_test_top, factory.create_component_by_name(test_name,
          "", "uvm_test_top", null));
```

and then calls `uvm_phase::m_run_phases`, well to run the phases.

```
  // phase runner, isolated from calling process
  fork begin
    // spawn the phase runner task
    phase_runner_proc = process::self();
    uvm_phase::m_run_phases();
  end
  join_none
  #0; // let the phase runner start

  wait (m_phase_all_done == 1);
```

at this point `uvm_phase::m_run_phases` calls `get_common_domain` to return the `m_common_domain` that was already constructed in the top (`uvm_root`).

```
task uvm_phase::m_run_phases();
  uvm_root top = uvm_root::get();

  // initiate by starting first phase in common domain
  begin
    uvm_phase ph = uvm_domain::get_common_domain();
    void'(m_phase_hopper.try_put(ph));
  end

  forever begin
    uvm_phase phase;
    m_phase_hopper.get(phase);
    fork
      begin
        phase.execute_phase();
      end
    join_none
    #0;  // let the process start running
  end
endtask
```

jumping to `execute_phase` which is a beast and worthy of another post on it own.

but the key point here is calls to `task_phase.traverse`

```
            task_phase.traverse(top,this,UVM_PHASE_EXECUTING);

```

and in `src/base/uvm_task_phase.svh`, traverse is called. `traverse` calls `m_traverse` recursively

```
  virtual function void traverse(uvm_component comp,
                                 uvm_phase phase,
                                 uvm_phase_state state);
    phase.m_num_procs_not_yet_returned = 0;
    m_traverse(comp, phase, state);
  endfunction

  function void m_traverse(uvm_component comp,
                           uvm_phase phase,
                           uvm_phase_state st

 ph.execute(comp, phase);
 ...
 endfunction
```

in `execute`, `exec_task` is called with component and phase. which links us to other side of the thread.

```
  virtual function void execute(uvm_component comp,
                                          uvm_phase phase);

    fork
      begin
        uvm_sequencer_base seqr;
        process proc;

        // reseed this process for random stability
        proc = process::self();
        proc.srandom(uvm_create_random_seed(phase.get_type_name(), comp.get_full_name()));

        phase.m_num_procs_not_yet_returned++;

        if ($cast(seqr,comp))
          seqr.start_phase_sequence(phase);

        exec_task(comp,phase);

        phase.m_num_procs_not_yet_returned--;

      end
    join_none

  endfunction
endclass
```
