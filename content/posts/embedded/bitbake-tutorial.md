---
title: "Bitbake Tutorial"
date: 2020-07-03T16:47:59+02:00
toc: false
images:
tags:
  - embedded
---

# Introdction
Bitbake is make-like build system. It was a part of openembedded project but split at some point to function as task runner.

This is small working exaple of bitbake layer. I extracted it from [docs][2] and Yocto-poky repo.

# Installation 
Download git repo from [git][1]. and set PATH to `bitbake/bin`. that's it :)

# Basic concepts
Bitbake uses `recipes` to control how to build software packages. Recipes can be grouped in `layer`.It is useful to isolate related recipes into separate layer. And you can add customization or more recipes with additional layers.

This is the structure of bitbake "Hello world"

```
├── conf
│   └── bblayers.conf
└── layer1
    ├── classes
    │   └── base.bbclass
    ├── conf
    │   ├── bitbake.conf
    │   └── layer.conf
    └── recipes
        └── coolpkg
            └── coolpkg.bb
```
## bblayer Configuration
To run bitbake, it needs to parse configuration files from `conf` directory in `$PWD`. It has to include at least  `bblayers.conf`. `bblayers.conf` points bitbake to the layers.

The smallest `bblayers.conf` just sets `BBPATH` and `BBLAYERS`.

```
BBPATH = "${TOPDIR}"

BBLAYERS = " \
    ${TOPDIR}/layer1 \
"
```

Note, `TOPDIR` is an internal variable in Bitbake.


## bitbake configuration

`bitbake.conf` provides configuration meta data for all recipes. `cond/bitbake.conf` is expected to be somewhere under `BBPATH`.

The following `bitbake.conf` adds the minimal configuration for a working bitbake setup.

```
TMPDIR ?= "${TOPDIR}/tmp"
CACHE = "${TMPDIR}/cache"
PERSISTENT_DIR = "${TOPDIR}/cache"
STAMPS_DIR ?= "${TMPDIR}/stamps"
STAMP = "${STAMPS_DIR}/pkg1"
BASE_WORKDIR ?= "${TMPDIR}/work"
WORKDIR = "${BASE_WORKDIR}/pkg1"

T = "${WORKDIR}/temp"
```

The above configuration would normally depend on the layer/recipes running at a given point but for simplicity I used fixed paths.

## layer
layer is a directory that contains related recipes. It has to contain `conf/layer.conf`  

`layer.conf` has to  update `BBPATH` and `BBFILES` with files in that layer. 

```
BBPATH =. "${LAYERDIR}:"
BBFILES = "${LAYERDIR}/recipes/*/*.bb"

```

Note, `${LAYERDIR}` variable can be used to reference current layer.

## classes

layer should contain `classes/base.bbclass`. It defines the tasks for recipes in that layer. Note that default  bitbake task is `build`. So, we have to provide that in base.bbclass. Also, bitbake adds `do_` before each task. So, that function has be called `do_build`.

Minimal `base.bbclass`

```
addtask build
do_build () {
    :
}
```
Note, the build task contains `:` because recipe will provide `do_build`. if recipe doesn't provide build task, do_build from `base.bbclass` will be called.

## recipes
recipe is a file with extension  `.bb`. It implicitly inherit from `base.bbclass`. so, it provides implementation for tasks like `do_build`.

```
SUMMARY = "First Recipe"
python do_build(){
    print("Hello world from coolpkg:do_build")
}
```

# Hello World
we are ready for "Hello World", just do `bitbake world`

```
Loading cache: 100% |                                                             | ETA:  --:--:--
Loaded 0 entries from dependency cache.
Parsing recipes: 100% |############################################################| Time: 0:00:00
Parsing of 1 .bb files complete (0 cached, 1 parsed). 1 targets, 0 skipped, 0 masked, 0 errors.
NOTE: Resolving any missing task queue dependencies
Initialising tasks: 100% |#########################################################| Time: 0:00:00
NOTE: No setscene tasks
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 1 tasks of which 0 didn't need to be rerun and all succeeded.
```

You can see the output in `tmp/work/log.do_build`

```
DEBUG: Executing python function do_build
DEBUG: Python function do_build finished
Hello world from coolpkg:do_build
```

[1]: https://github.com/openembedded/bitbake
[2]: https://www.yoctoproject.org/docs/1.6/bitbake-user-manual/bitbake-user-manual.html