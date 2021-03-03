---
title: "Stm32f4 Discovery - Part1 - ARM Cortex M4 Initialization"
date: 2020-07-11T17:48:31+02:00
toc: false
images:
tags:
  - embedded
---

# Introduction
This post will explain the linker script and assembly initialization before jumping to main using [stm32f4][1] board and Hello world example from [github][2].


# The end
I will describe this the same way i gone through it. *Starting with the linking command*.

```bash
arm-none-eabi-gcc -g -O2 -Wall -Tstm32_flash.ld  -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Iinc -Ilib -Ilib/inc  -Ilib/inc/core -Ilib/inc/peripherals  src/main.c src/stm32f4xx_it.c src/system_stm32f4xx.c lib/startup_stm32f4xx.s -o main.elf -Llib -lstm32f4
```

Starting with `main.c`, well nothing interesting there. just the `main`, obviously.

So,I jumped to `system_stm32f4xx.c`, it has 2 functions but only `SystemInit` called somewhere else. It's called from `startup_stm32f4xx.s` specifically from routine `Reset_Handler`.

From the snippet below, it's clear that `Reset_Handler` is the bootstrap routine because it does two things
- Hardware-specific initialization with `SystemInit`
- Jump to `main`

```
/* Call the clock system intitialization function.*/
  bl  SystemInit   
/* Call static constructors */
    bl __libc_init_array
/* Call the application's entry point.*/
  bl  main
  bx  lr 
```

# Reset_Handler and ARM M4 boot
`Reset_Handler` is 2nd entry in interrupt vector `isr_vector` defined in the same file.

```
   .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors
    
    
g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
```

So, How is `Reset_Handler` is called?

[stm32 RM][3] Describes the boot process from address `0x0000 0000`.

> Due to its fixed memory map, the code area starts from address 0x0000 0000 (accessed
> through the ICode/DCode buses) while the data area (SRAM) starts from address
> 0x2000 0000 (accessed through the system bus). The CortexTM-M4 with FPU CPU always
> fetches the reset vector on the ICode bus, which implies to have the boot space available
> only in the code area (typically, Flash memory). STM32F4xx microcontrollers implement a
> special mechanism to be able to boot from other memories (like the internal SRAM).

And next section describes the memory remap to allow ICode to access the boot memories (Flash, SRAM).

> Physical remap in STM32F405xx/07xx and STM32F415xx/17xx
> Once the boot pins are selected, the application software can modify the memory
> accessible in the code area (in this way the code can be executed through the ICode bus in

The way i understand it, the boot mode is selected based on BOOT1 and BOOT0. and the address range starting 0x00000000 gets remapped to the boot source. Table 3 shows that mapping.

And finally it mentions, the first 2 entries that the core need. So, we know that core will start executing from address at 0x00000004. in our case, 0x080000000 + 0x00000004.

> The BOOT pins are also resampled when the device exits the Standby mode. Consequently,
> they must be kept in the required Boot mode configuration when the device is in the Standby
> mode. After this startup delay is over, the CPU fetches the top-of-stack value from address
> 0x0000 0000, then starts code execution from the boot memory starting from 0x0000 0004.

So, we know what the program will execute somewhere after 0x08000000 and  we need to put the address of  `Reset_Handler` at offset 0x00000004.

how is that done?

# The linker black magic
`stm32_flash.ld` defines the memory regions and how sections will be linked into the final ELF.  

## The memory map
`MEMORY` defines the memory map available on the system bus. Note that FLASH origin at `0x08000000` and RAM origin at `0x20000000` as defined by [RM][3]
```
MEMORY
{
  FLASH (rx)      : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 192K
  MEMORY_B1 (rx)  : ORIGIN = 0x60000000, LENGTH = 0K
}
```
## ist_vector
This section puts `isr_vector` section into the FLASH memory region and being the first one, it will be placed at address `0x080000000`. Remember the memory remap from the last section? this means that `Reset_Handler` will be at the correct address.

```
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

```

Dumping the elf section after linking with `arm-none-eabi-objdump -x main.elf` shows the ist_vector at address `0800000`.

```
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .isr_vector   00000188  08000000  08000000  00008000  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
```

## text
Same as isr_vector, the `.text` section is the executable code will go into the FLASH region.

```
  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */

  } >FLASH

```

with `objdump`, we see that `.text` section starts right after isr_vector at `0x08000188`

```
  1 .text         00000ea8  08000188  08000188  00008188  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE

```
## data and BSS
Data and BSS are used for static variables in each object file. data is used to allocate variables with initial value. BSS used for variables without initial value.

There are 3 important parts here 
- `_sidata` before the `.data` section
- `.data : AT ( _sidata )` while defining the data section
- `_sdata` and `_edata`

```
  /* used by the startup to initialize data */
  _sidata = .;

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : AT ( _sidata )
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM

```

By doing `_sidata =.;`,  we store the current address(that depends on how big sections were) in `_sidata`.

Next, By using `AT` for `.data`, we define the `VMA` and `LMA` to be different. in this case 
- `VMA` will be the address from RAM (from `>RAM`)
- `LMA` will be the address we are at the ELF(or in this case, FLASH).
  
*What are LMA and VMA and why they are important?*

The problem is  data are read/write regions so, it lives in the RAM but we need to allocate initial values in the FLASH . We will see that `Reset_Handler` will need to copy that from the flash to the RAM.
But Linker will use VMA to resolve and relocate the variables. More details at [ld doc][4].

With `odjdump`, We can see the difference between `LMA` and `VMA`.
Note that wasn't the case in `.text` and `.bss`.

```
Idx Name          Size      VMA       LMA       File off  Algn
  5 .data         00000458  20000000  08001040  00010000  2**3
  6 .jcr          00000004  20000458  08001498  00010458  2**2
  7 .bss          00000024  2000045c  0800149c  0001045c  2**2

```
So, at this points we have 3 addresses
- `_sidata` : address of data in elf (AKA flash) relative 08000000
- `_sdata`  : start address for data section the ram relative 20000000
- `_edata`  : end address for data section the ram.
  
for BSS, it's same. There are addresses `_sbss` and `_ebss` like we have `_sdata` and `_edata`.

# What Does Reset_handler do?

At this point, we have done the following:
- Went through ARM M4 boot sequence and saw how it eventually calls `Reset_Handler`.
- Understood how the linker script tells the linker where to loads elf sections in FLASH and RAM regions.

Now that `Reset_Handler` is called. It does 4 things:

- Initialize the data section by copying from the flash to the ram. This is done by `LoopCopyDataInit` and using `_sidata`, `_sdata` and `_edata`.
- Initialize BSS section in ram with zeros. This is done by `LoopFillZerobss` and uses `_sbss` and `_ebss`.
- Calls `SystemInit`
- Calls `main`

Note, `__libc_init_array` seems like call-back from compiler/libc to initialized things before calling the main. Not even trying to go there!

```
Reset_Handler:  

/* Copy the data segment initializers from flash to SRAM */  
  movs  r1, #0
  b  LoopCopyDataInit

CopyDataInit:
  ldr  r3, =_sidata
  ldr  r3, [r3, r1]
  str  r3, [r0, r1]
  adds  r1, r1, #4
    
LoopCopyDataInit:
  ldr  r0, =_sdata
  ldr  r3, =_edata
  adds  r2, r0, r1
  cmp  r2, r3
  bcc  CopyDataInit
  ldr  r2, =_sbss
  b  LoopFillZerobss
/* Zero fill the bss segment. */  
FillZerobss:
  movs  r3, #0
  str  r3, [r2], #4
    
LoopFillZerobss:
  ldr  r3, = _ebss
  cmp  r2, r3
  bcc  FillZerobss

/* Call the clock system intitialization function.*/
  bl  SystemInit   
/* Call static constructors */
    bl __libc_init_array
/* Call the application's entry point.*/
  bl  main
```

[1]: https://www.st.com/en/evaluation-tools/stm32f4discovery.html
[2]: git://github.com/jeremyherbert/stm32-templates.git
[3]: https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
[4]: https://sourceware.org/binutils/docs/ld/Output-Section-LMA.html#Output-Section-LMA