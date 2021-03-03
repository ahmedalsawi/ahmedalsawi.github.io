---
title: "Console boot options in linux"
date: 2019-05-11
toc: false
images:
tags:
  - embedded
---


# Introduction
I was trying to boot linux with qemu and it didn't work until i added `console=ttyS0`.So, I decided to take a deep dive into the kernel boot sequence to understand it.

I looked into kernel docs,and found `console` supports several console types like ttyS, tty, ttyUSB and few others. but i was interested in ttyS0 only for now.

# Boot options registration
Linux has infrastructure to register boot options and parsers will iterate boot options and call the registered functions.

in `init/main.c`, the chain of calls will eventually call `do_early_param` which specifically looks for `"console"` and calls `setup_func()` through `obs_kernel_param` structure.

```c
static int __init do_early_param(char *param, char *val,
				 const char *unused, void *arg)
{
	const struct obs_kernel_param *p;

	for (p = __setup_start; p < __setup_end; p++) {
		if ((p->early && parameq(param, p->str)) ||
		    (strcmp(param, "console") == 0 &&
		     strcmp(p->str, "earlycon") == 0)
		) {
			if (p->setup_func(val) != 0)
				pr_warn("Malformed early option '%s'\n", param);
		}
	}
	/* We accept everything at this stage. */
	return 0;
}
```

So, what are `__setup_start`, `__setup_end` and `setup_func`?

`__setup_start` are `__setup_end` pointers built into the elf at compile time with *super* linker scripts and macros. anyway, that's topic for another post.

In `kernel/printk/printk.c`, there is the registration of the boot option

```
__setup("console=", console_setup);
```

tracing it down the rabbit hole

```
#define __setup_param(str, unique_id, fn, early)			\
	static const char __setup_str_##unique_id[] __initconst		\
		__aligned(1) = str; 					\
	static struct obs_kernel_param __setup_##unique_id		\
		__used __section(.init.setup)				\
		__attribute__((aligned((sizeof(long)))))		\
		= { __setup_str_##unique_id, fn, early }

#define __setup(str, fn)						\
	__setup_param(str, fn, fn, 0)
```

so, in our case, `setup_func` is `console_setup`.

and in `include/asm-generic/vmlinux.lds.h`

```
#define INIT_SETUP(initsetup_align)					\
		. = ALIGN(initsetup_align);				\
		VMLINUX_SYMBOL(__setup_start) = .;			\
		KEEP(*(.init.setup))					\
		VMLINUX_SYMBOL(__setup_end) = .;
```

back to the `console`, `console_setup` does basic parsing of `console=` options

```c
static int __init console_setup(char *str)
{
	if (str[0] >= '0' && str[0] <= '9') {
		strcpy(buf, "ttyS");
		strncpy(buf + 4, str, sizeof(buf) - 5);
	} else {
		strncpy(buf, str, sizeof(buf) - 1);
	}

	for (s = buf; *s; s++)
		if (isdigit(*s) || *s == ',')
			break;
	idx = simple_strtoul(s, NULL, 10);
	*s = 0;

	__add_preferred_console(buf, idx, options, brl_options);
	console_set_on_cmdline = 1;
	return 1;
}
__setup("console=", console_setup);
```

The real work is done by `__add_preferred_console`. it will put the boot option in global array `console_cmdline`. Here is the declaration from `printk.c`

```
#define MAX_CMDLINECONSOLES 8

static struct console_cmdline console_cmdline[MAX_CMDLINECONSOLES];
```

Note that `__add_preferred_console` will use an existing entry if found. And it will be marked as `preferred_console`.

Normally, it wouldn't match anything and `c` pointer will point to the next empty entry in the array. in my case, loop didn't even start because nothing was in `console_cmdline`.

So, using `console=ttyS0` will populate the first entry in the `console_cmdline` only.

```c
static int __add_preferred_console(char *name, int idx, char *options,
				   char *brl_options)
{
	struct console_cmdline *c;
	int i;

	/*
	 *	See if this tty is not yet registered, and
	 *	if we have a slot free.
	 */
	for (i = 0, c = console_cmdline;
	     i < MAX_CMDLINECONSOLES && c->name[0];
	     i++, c++) {
		if (strcmp(c->name, name) == 0 && c->index == idx) {
			if (!brl_options)
				preferred_console = i;
			return 0;
		}
	}

	if (i == MAX_CMDLINECONSOLES)
		return -E2BIG;
	if (!brl_options)
		preferred_console = i;
	strlcpy(c->name, name, sizeof(c->name));
	c->options = options;
	braille_set_options(c, brl_options);
	c->index = idx;
	return 0;
}
```

# Driver Registration
Now we have `console_cmdline` populated with boot options, something needs to handle these consoles. well, here comes the driver :)

in `kernel/printk/printk.c`, the `console_cmdline` array is accessed through `register_console`
which matches the name of console to driver and does some magic to print the messages in printk buffer.

for uart serial console, i have 8259 driver compiled as part of kernel. from `drivers/tty/serial/8250/8250_core.c`
```c
static int __init univ8250_console_init(void)
{
	if (nr_uarts == 0)
		return -ENODEV;

	serial8250_isa_init_ports();
	register_console(&univ8250_console);
	return 0;
}
console_initcall(univ8250_console_init);
```

Note that `console_initcall` has to be called after `__setup`. So, that driver can find the console device.

The driver will define needed function for setup/write

```c
static struct console univ8250_console = {
	.name		= "ttyS",
	.write		= univ8250_console_write,
	.device		= uart_console_device,
	.setup		= univ8250_console_setup,
	.match		= univ8250_console_match,
	.flags		= CON_PRINTBUFFER | CON_ANYTIME,
	.index		= -1,
	.data		= &serial8250_reg,
};
```

The interesting part is in `register_console`, the comments says that `console_unlock` will flush the buffer.

```c
		/*
		 * console_unlock(); will print out the buffered messages
		 * for us.
		 */
		logbuf_lock_irqsave(flags);
		console_seq = syslog_seq;
		console_idx = syslog_idx;
		logbuf_unlock_irqrestore(flags);
		/*
		 * We're about to replay the log buffer.  Only do this to the
		 * just-registered console to avoid excessive message spam to
		 * the already-registered consoles.
		 */
		exclusive_console = newcon;
	}
	console_unlock();
```

So, `console_unlock` will call `call_console_drivers` which will call `write` registered in the driver.

```c
static void call_console_drivers(const char *ext_text, size_t ext_len,
				 const char *text, size_t len)
{
	struct console *con;

	trace_console_rcuidle(text, len);

	if (!console_drivers)
		return;

	for_each_console(con) {
		if (exclusive_console && con != exclusive_console)
			continue;
		if (!(con->flags & CON_ENABLED))
			continue;
		if (!con->write)
			continue;
		if (!cpu_online(smp_processor_id()) &&
		    !(con->flags & CON_ANYTIME))
			continue;
		if (con->flags & CON_EXTENDED)
			con->write(con, ext_text, ext_len);
		else
			con->write(con, text, len);
	}
}
```

# Reference
* https://www.kernel.org/doc/html/latest/admin-guide/serial-console.html
* https://www.tldp.org/HOWTO/Remote-Serial-Console-HOWTO/configure-kernel.html
