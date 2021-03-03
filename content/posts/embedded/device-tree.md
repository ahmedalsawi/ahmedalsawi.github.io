---
title: "Device Tree hello world"
date: 2020-09-06T16:05:18+02:00
tags:
- embedded
---
[Device Tree][1] is defined as

> In computing, a device tree (also written devicetree) is a data structure describing the hardware components of a particular computer so that the operating system's kernel can use and manage those components, including the CPU or CPUs, the memory, the buses and the peripherals.

Basically, device tree defines SOC architecture for operating system or boot-loader. This is widely used in embedded systems where the system is not configurable and not going to change.

This is not a problem on PCs because of things like BIOS enumeration through ACPI and you can add whatever behind PCI and it can be probed.

Anyway, i read the first two chapters of [specification][2] and i thought it was enough to play around with `dtc` which part of `device-tree-compiler`.

```bash
apt install device-tree-compiler
```

# Device tree crash course
I am not going to repeat the spec. but to sum up,
- It's a tree of nodes (DAG)
- each node have pairs of property/values.
- The devicetree has a single root node of which all other device nodes are descendants. The full path to the root node is /.
- All devicetrees shall have a root node and the following nodes shall be present at the root of all devicetrees: one `/cpus/` and at least one `/memory`


That's it.

```
/dts-v1/;

/ {
    compatible = "vendor,model";
	cpus {
		cpu1: cpu@1 {
			compatible = "vendor,model";
			clock-frequency = <650000000>;
			device_type = "cpu";
			reg = <1>;
		};
	};

    memory: memory@80000000 {
		device_type = "memory";
		reg = <0x00000000 0x80000000 0x00000000 0x40000000>;
	};

};
```

Properties can take one the following values
- empty
- u32
- u64
- phandle
- string
- prop-encoded-array
- stringlist

more details and examples at sections 2.2 of [specs][2]

# Compile and de-compile device tree
Using `dtc`, we can compile dts into dtb(device tree blob).
```
dtc -I dts  -O dtb -o 1.dtb  1.dts 
```

we can de-compile the blob back to dts.

```
dtc -I dtb  -O dts -o 1.dtsd  1.dtb
```

Note, the specs define the format for the binary blob. with the following, i guess it would be fun to write a parser for it.

```
struct fdt_header {
uint32_t magic;
uint32_t totalsize;
uint32_t off_dt_struct;
uint32_t off_dt_strings;
uint32_t off_mem_rsvmap;
uint32_t version;
uint32_t last_comp_version;
uint32_t boot_cpuid_phys;
uint32_t size_dt_strings;
uint32_t size_dt_struct;
};
```

we can see this realy quick with `hexdump` as specs says the `magic`value is `0xd00dfeed`.
Note, we get `0dd0 edfe` because of endiance. 

```
$ hexdump 1.dtb 
0000000 0dd0 edfe 0000 3f01 0000 3800 0000 1401
```

# Interrupts
I think that interrupts is most complicated part of specs.Here is quick overview

the spec defines `interrupt-generating devices`

> The physical wiring of an interrupt source to an interrupt controller is represented in the devicetree with the interrupt-parent property. Nodes that represent interrupt-generating devices contain an interrupt-parent property which has a phandle value that points to the device to which the device’s interrupts are routed, typically an interrupt controller. If an interrupt-generating device does not have an interrupt-parent property, its interrupt parent is assumed to be its devicetree parent.

and `interrupt domain` is defined as:

> An interrupt domain is the context in which an interrupt specifier is interpreted. The root of the domain is either (1) an interrupt controller or (2) an interrupt nexus.
> - An interrupt controller 
> - An interrupt nexus 

Looking at any dts in linux kernel say [this one][4]. The interrupt controller has the properties
- interrupt-controller
- interrupt-cells which defines the interrupt specifier in the interrupt-generating device

```
			gic: interrupt-controller@d000 {
				compatible = "arm,cortex-a9-gic";
				#interrupt-cells = <3>;
				#size-cells = <0>;
				interrupt-controller;
				reg = <0xd000 0x1000>,
				      <0xc100 0x100>;
			};

```

somewhere in the same dts, there are interrupt devices with `interrupts` property

```
			rtc: rtc@10300 {
				compatible = "marvell,orion-rtc";
				reg = <0x10300 0x20>;
				interrupts = <GIC_SPI 21 IRQ_TYPE_LEVEL_HIGH>;
			};
```

[1]: https://en.wikipedia.org/wiki/Device_tree
[2]: https://github.com/devicetree-org/devicetree-specification/releases/tag/v0.3
[3]: https://elinux.org/images/f/f9/Petazzoni-device-tree-dummies_0.pdf
[4]: https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/armada-375.dtsi