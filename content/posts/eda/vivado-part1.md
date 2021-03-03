---
title: "Xilinx Vivado - Part1 The Flow"
date: 2020-05-28T20:14:08+02:00
toc: false
images:
tags:
  - fpga
  - eda
---

This post explains the simple vivado non-project flow for synthesis and implementation. The advantage of non-project mode is full control over the flow and reports generated. Note that non-project runs in-memory (no file generated).So, It does need some extra work to create checkpoints and reports as needed.

# Invoking Vivado
vivado takes `-mode` as one of `gui, tcl, batch`
- gui: default. start vivado in gui mode
- tcl: starts vivado in tcl (interactive mode)
- batch: starts vivado and exit after executing commands (regression mode)

Also, `-source run.tcl` is used to run `run.tcl` after init. I like to use `-nojournal -nolog` to get rid of annoying log and journal files.

```bash
vivado -mode batch -source run.tcl -nojournal -nolog
```

# Synthesis
##  Setup
```tcl
set_part <FPGA-PART-NUMBER>
set outputDir ./output
file makdir $outputDir
```

## Reading files

- `read_verilog`
from UG835

> You can use this command to read the contents of source files into the in-memory design, when
running the Vivado tool in Non Project mode, in which there is no project file to maintain and
manage the various project source files.

```tcl
read_verilog ./rtl/top.v
```

Important options: 
`-sv`: Treat as Systemverilog

- `read_xdc` 
from UG835

> Imports physical and timing constraints from a Xilinx Design Constraints file (XDC). The XDC is
imported into the current_instance level of the design hierarchy, which defaults to the top-
level of the design, or can be imported into specified cells.


```tcl
read_xdc -unmanaged ./data/top.xdc
```

important options:
`-unmanaged`: Vivado tool will not save constraint changes back into these unmanaged Tcl files.

## Run synthesis

`synth_desgin` from UG835

> Directly launches the Vivado synthesis engine to compile and synthesize a design in either
Project Mode or Non-Project Mode in the Vivado Design Suite.

```tcl
synth_design -top top -include_dirs ./rtl
```

important options
- `include_dirs`: Path of files included in rtl. initially, i though that something `read_verilog` would need.
- `-generic` to override parameters

There are many options to control the synthesis. Check UG901 for more details.


## checkpoint
At this point, it's good idea to create checkpoint in case we exited vivado. this way we can load the checkpoint and move on with implementation later.

```tcl
write_checkpoint $outputDir/post_synth -force
```

## Reports
`report_timing_summary`
> Generate a timing summary to help understand if the design has met timing requirements. The
timing summary can be run on an open Synthesized or Implemented Design.

we are looking at `Design Timing SUmmary` section. if all is good, There should be at the end of section
```
All user specified timing constraints are met
```

`report_utilization`
> Report the utilization of resources on the target part by the current synthesized or implemented
design.


```tcl
report_timing_summary -file $outputDir/post_synth_report_timing_summary.rpt
report_utilization -file $outputDir/post_synth_report_utilization.rpt
```

Notes:
- `report_timing_summary` is the most important report because it reports `WNS` (worst negative slack).
the max freq is defined with `1/(T-WNS)`.
- After synth, reports are still not final. we will need to generate the reports again after implementation.

## Netlist generation
If we need to do GLS, we will need to generate post-synth netlist. Note we will need to generate xiling simulation libraries to actually use generated netlist and SDF
```tcl
write_verilog $outputDir/post_synth_netlist.v
write_sdf     $outputDir/post_synth_netlist.sdf
```

# Implementation
There are several ways to read design for implementation flow

- in-memory design after synth_design
- Read checkpoint
- Load EDIF (from synth or 3rd party synthesis tool)

For checkpoint, `open_checkpoint` can be used to read and link design in-memory

```tcl
open_checkpoint post_synth.dcp
```
in this example, i am assuming single in-memory run.

## Optimization
After synthesis, there are many optimization that vivado can do to improve area and spead.

```tcl
opt_design
```
According to docs, this list of optimization done by default.

- Retarget
- Constant Propagation
- Sweep
- Global Buffer (BUFG) optimizations
- Shift-Register Logic optimizations
- Block RAM Power optimizations

## Place

from UG835

> Automatically place ports and leaf-level instances.

It seems default setting is good enough. but in case we need to change it, there is `-directive` which takes several options to control the priority of placement.

```tcl
place_design
```
## Routing

from UG835

> Route the nets in the current design to complete logic connections on the target part.

```tcl
route_design
```

like `place_design`, i don't think we need to change default setting unless you really know what you are doing.

## Reports

At this point, the reports should have the best estimate after place and route

```tcl
report_timing_summary -file $outputDir/post_route_report_timing_summary.rpt
report_utilization -file $outputDir/post_route_report_utilization.rpt
```

## Bit generation
Finally the bit stream!

```tcl
write_bitsteam -force top.bit
```

## Putting it all together

```tcl
set_part <FPGA-PART-NUMBER>
set outputDir ./output
file makdir $outputDir

read_verilog ./rtl/top.v

read_xdc -unmanaged ./data/top.xdc

synth_design -top top -include_dirs ./rtl

write_checkpoint $outputDir/post_synth -force

report_timing_summary -file $outputDir/post_synth_report_timing_summary.rpt
report_utilization -file $outputDir/post_synth_report_utilization.rpt

write_verilog $outputDir/post_synth_netlist.v
write_sdf     $outputDir/post_synth_netlist.sdf


opt_design

place_design

write_checkpoint $outputDir/post_place -force

route_design

report_timing_summary -file $outputDir/post_route_report_timing_summary.rpt
report_utilization -file $outputDir/post_route_report_utilization.rpt

write_bitsteam -force top.bit
```