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

# Examples
```julia
using KiteUtils
set = se()
```
```julia
KiteUtils.Settings
  project: String "settings.yaml"
  log_file: String "data/log_8700W_8ms"
  model: String "data/kite.obj"
  segments: Int64 6
  sample_freq: Int64 20
  time_lapse: Float64 1.0
  zoom: Float64 0.03
  fixed_font: String ""
  v_reel_out: Float64 0.0
  c0: Float64 0.0
  c_s: Float64 2.59
  c2_cor: Float64 0.93
  k_ds: Float64 1.5
  area: Float64 10.18
  mass: Float64 6.2
  height_k: Float64 2.23
  alpha_cl: Array{Float64}((12,)) [-180.0, -160.0, -90.0, -20.0, -10.0, -5.0, 0.0, 20.0, 40.0, 90.0, 160.0, 180.0]
  cl_list: Array{Float64}((12,)) [0.0, 0.5, 0.0, 0.08, 0.125, 0.15, 0.2, 1.0, 1.0, 0.0, -0.5, 0.0]
  alpha_cd: Array{Float64}((11,)) [-180.0, -170.0, -140.0, -90.0, -20.0, 0.0, 20.0, 90.0, 140.0, 170.0, 180.0]
  cd_list: Array{Float64}((11,)) [0.5, 0.5, 0.5, 1.0, 0.2, 0.1, 0.2, 1.0, 0.5, 0.5, 0.5]
  ...
  l_bridle: Float64 33.4
  l_tether: Float64 392.0
  damping: Float64 473.0
  c_spring: Float64 614600.0
  elevation: Float64 70.7
  sim_time: Float64 100.0
```

You can see the available setting parameters by typing
```set.<TAB><TAB>```
at the Julia prompt. Defining ```set``` as constant improves the performance of the access to the 
parameters.
```julia
const set = se()
```