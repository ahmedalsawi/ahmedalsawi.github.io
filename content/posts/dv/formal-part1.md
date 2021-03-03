---
title: "My assumptions (pun intended) about formal verification or SymbiYosys - part1 "
date: 2020-11-26
toc: false
images:
tags:
    - formal
    - DV
---

I wanted to try formal verification for long time. I played around with SAT solvers before but didn't try full-blown formal proof before. Well,I was too lazy to read the docs because i thought formal is complex/hard to do. finally, I proved myself wrong (again, pun intended).

`SymbiYosys` is open source formal engine based on Yosys. It's easy and most importantly it's free.

# Installation
This is summary for steps in [official doc][1].

One caveat, installation requires root to copy scripts. I don't like running script with sudo on my machine, so i used docker and i am good to go.

```bash
sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev gperf \
                     libboost-program-options-dev autoconf libgmp-dev \
                     cmake

git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install

cd ..

git clone https://github.com/YosysHQ/SymbiYosys.git SymbiYosys
cd SymbiYosys
sudo make install

cd ..


git clone https://github.com/SRI-CSL/yices2.git yices2
cd yices2
autoconf
./configure
make -j$(nproc)
sudo make install
```
# Hello World
This is small example from [docs][2]

demo.sv

```verilog
 module demo (
  input clk,
  output reg [5:0] counter
);
  initial counter = 0;

  always @(posedge clk) begin
    if (counter == 15)
      counter <= 0;
    else
      counter <= counter + 1;
  end

`ifdef FORMAL
  always @(posedge clk) begin
    assert (counter < 32);
  end
`endif
endmodule
```

demo.sby

```
[options]
mode bmc
depth 100

[engines]
smtbmc

[script]
read -formal demo.sv
prep -top demo

[files]
demo.sv
```

Running the engine

```bash
sby demo.sby
```

and the output same as docs. hurrah!

```
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assertions in step 95..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assumptions in step 96..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assertions in step 96..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assumptions in step 97..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assertions in step 97..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assumptions in step 98..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assertions in step 98..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assumptions in step 99..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Checking assertions in step 99..
SBY 22:44:11 [demo] engine_0: ##   0:00:00  Status: passed
SBY 22:44:11 [demo] engine_0: finished (returncode=0)
SBY 22:44:11 [demo] engine_0: Status returned by engine: pass
SBY 22:44:11 [demo] summary: Elapsed clock time [H:MM:SS (secs)]: 0:00:00 (0)
SBY 22:44:11 [demo] summary: Elapsed process time [H:MM:SS (secs)]: 0:00:00 (0)
SBY 22:44:11 [demo] summary: engine_0 (smtbmc) returned pass
SBY 22:44:11 [demo] DONE (PASS, rc=0)
```

Now into the rabbit holes that SMT and BMC are... more in upcoming posts..


[1]: https://symbiyosys.readthedocs.io/en/latest/install.html
[2]: https://symbiyosys.readthedocs.io/en/latest/quickstart.html
[3]: https://en.wikipedia.org/wiki/Satisfiability_modulo_theories
[4]: http://www.cs.cmu.edu/~emc/papers/Books%20and%20Edited%20Volumes/Bounded%20Model%20Checking.pdf