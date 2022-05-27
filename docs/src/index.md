```@meta
CurrentModule = KiteUtils
```

# KiteUtils

Documentation for [KiteUtils](https://github.com/ufechner7/KiteUtils.jl).

This package is the foundation of Julia Kite Power Tools, which consist of the following packages:

![Julia Kite Power Tools](kite_power_tools.png)

## What to install
If you want to run simulations and see the results in 3D, please install the meta package  [KiteSimulators](https://github.com/aenarete/KiteSimulators.jl) . If you have already KiteSimulators installed, use `using KiteSimulators` instead of `using KiteUtils`.
If you just want to learn how this package works quickly just install only this package.

## Installation

Download [Julia 1.6](http://www.julialang.org) or later, if you haven't already. You can add KiteUtils from  Julia's package manager, by typing 
```julia
using Pkg
pkg"add KiteUtils"
``` 
at the Julia prompt.

If you are using Windows, it is suggested to install git and bash, too. This is explained for example here: [Julia on Windows](https://github.com/ufechner7/KiteViewer/blob/main/doc/Windows.md) .

## Testing
You can run the unit tests of this package with the command:
```julia
using Pkg
pkg"test KiteUtils"
```

## Features
- read configuration files, written in .yaml format
- provides the default configuration file [settings.yaml](../../data/settings.yaml)
- read and write log files, which is memory efficient and fast due to the use of the Apache Arrow format
- present log files in two different formats, one optimized to look at the system state at one point in time, and one that presents per-variable arrays with the time as index
- functions for coordinate system transformations
- provides types for the state of a kite power system, for logfiles and for configuration data

## Related
- The meta package [KiteSimulators](https://github.com/aenarete/KiteSimulators.jl) which contains all packages from Julia Kite Power Tools.
- the packages [KiteModels](https://github.com/ufechner7/KiteModels.jl) and [KitePodModels](https://github.com/aenarete/KitePodModels.jl) and [WinchModels](https://github.com/aenarete/WinchModels.jl) and [AtmosphericModels](https://github.com/aenarete/AtmosphericModels.jl)
- the package [KiteControllers](https://github.com/aenarete/KiteControllers.jl) and [KiteViewers](https://github.com/aenarete/KiteViewers.jl)
