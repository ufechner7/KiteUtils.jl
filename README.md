# KiteUtils

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ufechner7.github.io/KiteUtils.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ufechner7.github.io/KiteUtils.jl/dev)
[![Build Status](https://github.com/ufechner7/KiteUtils.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ufechner7/KiteUtils.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ufechner7/KiteUtils.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ufechner7/KiteUtils.jl)

Utilities for simulating kite power systems.

This package is the foundation of Julia Kite Power Tools, which consist of the following packages:
<p align="center"><img src="https://raw.githubusercontent.com/ufechner7/KiteUtils.jl/main/docs/src/kite_power_tools.png" width="500" /></p>

## What to install
If you want to run simulations and see the results in 3D, please install the meta package  [KiteSimulators](https://github.com/aenarete/KiteSimulators.jl) . If you have already KiteSimulators installed, use `using KiteSimulators` instead of `using KiteUtils`.
If you just want to learn how this package works quickly just install only this package.

## Installation
Download [Julia 1.9](http://www.julialang.org) or later, if you haven't already. You can add KiteUtils from  Julia's package manager, by typing 
```julia
using Pkg
pkg"add KiteUtils"
``` 
at the Julia prompt. You can run the unit tests by typing:
```julia
pkg"test KiteUtils"
```

## Provides 
- functions for coordinate system transformations
- functions for reading configuration files
- the default configuration file [settings.yaml](data/settings.yaml)
- functions for logging, reading and writing log files
- types for the state of a kite power, logging and configuration parameters

## Related
- The meta package [KiteSimulators](https://github.com/aenarete/KiteSimulators.jl) which contains all packages from Julia Kite Power Tools.
- the packages [KiteModels](https://github.com/ufechner7/KiteModels.jl) and [KitePodModels](https://github.com/aenarete/KitePodModels.jl) and [WinchModels](https://github.com/aenarete/WinchModels.jl) and [AtmosphericModels](https://github.com/aenarete/AtmosphericModels.jl)
- the packages [KiteControllers](https://github.com/aenarete/KiteControllers.jl) and [KiteViewers](https://github.com/aenarete/KiteViewers.jl)

**Documentation** [Stable Version](https://ufechner7.github.io/KiteUtils.jl/stable) [Development Version](https://ufechner7.github.io/KiteUtils.jl/dev)

Author: Uwe Fechner (uwe.fechner.msc@gmail.com)
