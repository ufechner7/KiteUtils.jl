```@meta
CurrentModule = KiteUtils
```

# KiteUtils

Documentation for [KiteUtils](https://github.com/ufechner7/KiteUtils.jl).

## Installation

Download [Julia 1.6](http://www.julialang.org) or later, if you haven't already. You can add KiteUtils from  Julia's package manager, by typing 
```
] add KiteUtils
``` 
at the Julia prompt.

If you are using Windows, it is suggested to install git and bash, too. This is explained for example here: [Julia on Windows](https://github.com/ufechner7/KiteViewer/blob/main/doc/Windows.md) .

## Testing
You can run the unit tests of this package with the command:
```
] test KiteUtils
```

## Features
This package provides functions to:
- read configuration files, written in .yaml format
- read and write log files, which is memory efficient and fast due to the use of the Apache Arrow format
- present log files in two different formats, one optimized to look at the system state at one point in time, and one that presents per-variable arrays with the time as index
- helper functions for geometric transformations

## Related
- The application [KiteViewer](https://github.com/ufechner7/KiteViewer)
- the packages [KiteModels](https://github.com/ufechner7/KiteModels.jl) and [KitePodModels](https://github.com/aenarete/KitePodModels.jl) and [WinchModels](https://github.com/aenarete/WinchModels.jl) and [AtmosphericModels](https://github.com/aenarete/AtmosphericModels.jl)
- the package [KiteControllers](https://github.com/aenarete/KiteControllers.jl) and [KiteViewers](https://github.com/aenarete/KiteViewers.jl)
