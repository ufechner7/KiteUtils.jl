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

# Features
This package provides functions to:
- read configuration files, written in .yaml format
- read and write log files, which is memory efficient and fast due to the use of the Apache Arrow format
- present log files in two different formats, one optimized to look at the system state at one point in time, and one that presents per-variable arrays with the time as index
- helper functions for geometric transformations