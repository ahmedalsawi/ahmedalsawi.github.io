---
title: "APB Tutorial"
date: 2020-07-23T14:36:41+02:00
images:
tags:
  - AMBA
  - SOC
---

This is walk through in APB specification `AMBA 3 APB Protocol`. The spec is short but i thought to document my notes anyway.

# Introduction
APB is AMBA low-speed bus that provide basic write/read transfer. no pipelines with minimum access time of 2 cycles.

# Transfers
Chapter 2 explains  write and read transfer with 2 variants
- no wait ( exactly 2 cycles)
- wait (more that 2 cycles)

I will go through the write transfer and how that related to FSM in chapter 2. Read transfer should be the same.

For no-wait write transfer, the spec provide the following timing diagram.

![Example image](/apb-1.png)

The order of event in the diagram:
- at T1, master asserts PSEL, PADDR, PWRITE
- at T2, master asserts PENABLE, slave asserts PREADY
- at T3, date is Latched and transfer is done.

Quick and dirty model of the master would something like

```verilog
    @(posedge PRESETn);
    @(posedge PCLK);
    PSELx = 1;
    PADDR  = 0;
    PWRITE = 1;
    PWDATA = 2;
    @(posedge PCLK);
    PENABLE = 1;
    @(posedge PCLK);
    PSELx = 0;
    PENABLE = 0;
```

In case of wait transfer, slave can introduce wait states with `PREADY`. and the master has to keep the all signals stable until `PREADY` is asserted.

![Example image](/apb-2.png)

# APB master FSM

Chapter 3 shows the following FSM for APB transfer. It shows the 3 transition on master signals during 2 cycles (T1, T2, T3).

![Example image](/apb-3.png)

So, What about the slave FSM? The slave has to be one clock cycle behind the master. So, for no-wait, the `PREADY` is asserted in the setup state or stay de-asserted until slave is ready for transfer.


The slave should be simpler than the master. basically, slave needs to do 2 things
- Wait for PSEL and assert PREADY if ready.
- Do the transfer (read or write) whenever both PENABLE and PREADY.

I wrote small(again quick and dirty) slave model. I assume the slave will have internal flag to inidcate it's ready to do the transfer. in this example `ready`.

If both `ready` and `PSEL` are asserted, `PREADY` will be asserted.

If the master starts new transfer, it will have to go back to setup/idle which means `PENABLE` will de-asserted anyway.  

```verilog
// internal ready flag
logic ready=0;
logic pready;

assign PREADY = pready;

always @(posedge PCLK) begin
    if (PRESETn == 0 ) begin
        pready <= #1 1'b1;
    end
    else begin
        if (PSELx == 1)  begin
            if(ready == 1) begin
                pready <= #1 1;
            end
            else begin
                pready <= #1 0;
            end
        end
    end
end

always @(posedge PCLK) begin
    if (pready && PENABLE) begin
    $display($time,, "DATA ADDR=%x, DATA=%x", PADDR, PWDATA);
    end
end
```

I used iverilog and gtkwave to test the master and slave above which works. kinda! 

![Example image](/apb-4.png)