---
title: "Yosys Nextpnr Flow"
date: 2020-07-23T18:10:09+02:00
toc: false
images:
tags:
  - fpga
  
  - eda
---

I came across this [riscv core][1]. I was more interested in the setup to run Yosys and nextpnr all the way to bitstream.

The default target is [board][2] with [ICE40][3] FPGA. These are steps the Makefile used to build bitstream.

# Pre-synthesis
starting with `icepll`, it's part of [icestorm][4] project to reverse-engineer the binary format for ICE40 fpga.

```bash
icepll -q -i 12 -o 48 -m -f pll.sv
```

The generated `pll` is wrapper around Lattice's `SB_PLL40_CORE`. I guess pll was needed to generated higher frequency. the on-baoard clock was 12 MHz and generated clock is 48 MHz.

```
module pll(
	input  clock_in,
	output clock_out,
	output locked
	);

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0111111),	// DIVF = 63
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);

endmodule
```

# Synthesis
[Yosys][5] is OSS verilog synthesis tool. It support ICE40 and ECP5 lattice FPGAs.

```bash
yosys -q ice40.ys
```

`ice40.ys` reads `top.sv`, elaborate the the design, then finally synth for ice40 and generate both json and blif.

```
read_verilog -DICE40 -noautowire -sv top.sv
proc
opt -full
alumacc
share -aggressive
opt -full
synth_ice40 -abc2 -top top -blif top.blif -json top.json
```

# Place and route
[Nextpnr][6] is OSS FPGA PNR tool by the same people who did Yosys.

nextpnr takes synthesis json, pcf and configuration.It generate `.asc` file for icepack.

```bash
nextpnr-ice40 -q --hx8k --package ct256 --json top.json --pcf boards/ice40hx8k-b-evn.pcf --freq 48 --asc top_syn.asc
```

`.asc` is ASCII file to represent tile. utilities from icestorm project can pack and unpack asc files into and from bitstream.

# Bitstream generation
icepack is part of of icestorm project which converts `.asc` to bitstream.

```
cp top_syn.asc top.asc
icepack -s top.asc top.bin
```

[1]: https://github.com/grahamedgecombe/icicle.git
[2]: https://www.digikey.com/product-detail/en/lattice-semiconductor-corporation/ICE40HX8K-B-EVN/220-1874-ND/4738851
[3]: http://www.latticesemi.com/iCE40
[4]: https://github.com/cliffordwolf/icestorm.git
[5]: https://github.com/YosysHQ/yosys.git
[6]: https://github.com/YosysHQ/nextpnr.git