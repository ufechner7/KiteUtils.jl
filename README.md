# KiteUtils

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ufechner7.github.io/KiteUtils.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ufechner7.github.io/KiteUtils.jl/dev)
[![Build Status](https://github.com/ufechner7/KiteUtils.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ufechner7/KiteUtils.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ufechner7/KiteUtils.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ufechner7/KiteUtils.jl)

Utilities for simulating kite power systems.

## Installation
Download [Julia 1.6](http://www.julialang.org) or later, if you haven't already. You can add KiteUtils from  Julia's package manager, by typing 
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
- functions for reading and writing log files
- types for the state of a kite power system, for logfiles and for configuration data

## Related
- The application [KiteViewer](https://github.com/ufechner7/KiteViewer)
- the packages [KiteModels](https://github.com/ufechner7/KiteModels.jl) and [KitePodModels](https://github.com/aenarete/KitePodModels.jl) and [WinchModels](https://github.com/aenarete/WinchModels.jl) and [AtmosphericModels](https://github.com/aenarete/AtmosphericModels.jl)
- the package [KiteControllers](https://github.com/aenarete/KiteControllers.jl) and [KiteViewers](https://github.com/aenarete/KiteViewers.jl)

**Documentation** [Stable Version](https://ufechner7.github.io/KiteUtils.jl/stable) [Development Version](https://ufechner7.github.io/KiteUtils.jl/dev)

Author: Uwe Fechner (uwe.fechner.msc@gmail.com)
