---
title: "TCL And C interface"
date: 2020-12-14
toc: false
images:
tags:
  - tcl
---


# Calling TCL from C

Starting with working example, we can see that `Tcl_CreateInterp`  and `Tcl_Eval` are the only two Tcl calls.

```c
#include <stdio.h>
#include <tcl.h>

main (int argc, char *argv[]) {

        Tcl_Interp *myinterp;
        char *action = "set a [expr 5 * 8]; puts $a";
        int status;

        printf ("Your Program will run ... \n");

        myinterp = Tcl_CreateInterp();
        status = Tcl_Eval(myinterp,action);

        printf ("Your Program has completed\n");
}
```

And compilation command

```bash
gcc main.c -I /usr/include/tcl8.6 -ltcl
```

Docs says `Tcl_CreateInterp` is

> Tcl_CreateInterp creates a new interpreter structure and returns a token for it. The token is required in calls to most other Tcl procedures, such as Tcl_CreateCommand, Tcl_Eval

And  `Tcl_Eval`

> Tcl_Eval is similar to Tcl_EvalObjEx except that the script to be executed is supplied as a string instead of a value and no compilation occurs.


# Calling C from TCL (TCL extension)

On the other side, TCL provides an interface to call C from TCL same as built-in procs.

For this to work, we need to 2 functions:
- Registration called when shared object is loaded
- proc implementation


Docs describes `Tcl_CreateObjCommand`

> Tcl_CreateObjCommand deletes any existing command name already associated with the interpreter (however see below for an > exception where the existing command is not deleted). It returns a token that may be used to refer to the command in subsequent > calls to Tcl_GetCommandName. If name contains any :: namespace qualifiers, then the command is added to the specified namespace; > otherwise the command is added to the global namespace. If Tcl_CreateObjCommand is called for an interpreter that is in the > process of being deleted, then it does not create a new command and it returns NULL. proc should have arguments and result that > match the type Tcl_ObjCmdProc:
> 
> typedef int Tcl_ObjCmdProc(
> 	ClientData ta,
> 	Tcl_Interp *interp,
> 	int objc,
> 	Tcl_Obj *CONST objv[]);


```c
#include <stdio.h>
#include <tcl.h>

static int hello(ClientData cdata, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
	printf("Hello World\n");
	return TCL_OK;
}

int Hello_Init(Tcl_Interp *interp)
{
	Tcl_CreateObjCommand(interp, "hello", hello, NULL, NULL);
	return TCL_OK;
}
```

gcc commands to compile shared object

```bash
	gcc -c hello.c -I /usr/include/tcl8.6
	gcc -shared -o hello.so hello.o -ltcl
```

Finally, we need to load the shared object with TCL `load`.

```tcl
load ./hello.so
hello

```
Side note, [Docs](https://www.tcl.tk/man/tcl8.6/TclCmd/load.htm) mentions `Hello_Init` has to be called `SOMEHING_Init` for load command to execute it while loading the shared object. According to docs, `SOMETHING` is package name .

# C-TCL-C chaining

for fun, I tried chaining C calling TCL and TCL calling C.

This is main.c (the main driver)
```c
#include <stdio.h>
#include <tcl.h>

void main (int argc, char *argv[]) {

        Tcl_Interp *myinterp;
        char *action = "load ./hello.so;hello";
        int status;

        printf ("Your Program will run ... \n");

        myinterp = Tcl_CreateInterp();
        status = Tcl_Eval(myinterp,action);

        printf ("Your Program has completed\n");
}
```

and hello.c same as before.