# Changelog
### KiteUtils v0.7.5 - 2024-08-09
#### Added
- the fields kcu_model, kcu_diameter, depower_zero and degrees_per_percent_power
- the files system2.yaml and system2.yaml which use KCU2

#### Fixed
- when calling se(); se("system2.yaml") the new settings where not used

### KiteUtils v0.7.4 - 2024-08-06
#### Changed
- the first parameter of `demo_state_4p_3lines()` is now the number of middle tether particles

### KiteUtils v0.7.3 - 2024-08-05
#### Added
- function `demo_state_4p_3lines()`
- `dependabot.yml` to the GitHub CI scripts, which keeps the GitHub actions up-to-date
#### Changed
- added the `Base.@kwdef` decorator to the type SysState. This allows it to easily create
  a SysState struct from a JSON message

### KiteUtils v0.7.2 - 2024-07-24
#### Changed
- renamed inertia_motor to inertia_total

### KiteUtils v0.7.1 - 2024-07-24
#### Added
- new parameters `f_coulomb` and `c_vf` for the friction of the winch

### KiteUtils v0.7.0 - 2024-07-24
#### Added
- new parameters `winch_model`, `drum_radius`, `gear_ratio`, `inertia_motor`
- print a warning if the section `kps4_3l` is missing

### KiteUtils v0.6.16 - 2024-06-25
#### Changed
- new field `width_3l`
#### Fixed
- read the fields for the KPS4-3L model from yaml file

### KiteUtils v0.6.15 - 2024-06-21
#### Changed
- add fields needed for the new KPS4-3L model

### KiteUtils v0.6.14 - 2024-06-20
#### Fixed
- all methods of the function save_log() accept now the named parameter `path`

### KiteUtils v0.6.13 - 2024-06-19
#### Fixed
- downgraded RecursiveArrayTools because the latest version stopped working any longer

### KiteUtils v0.6.12 - 2024-06-18
#### Changed
- add 6 more free variables, now 16 free variables can be logged per time step
- drop support for Julia 1.9

### KiteUtils v0.6.11 - 2024-04-22
#### Changed
- the functions `export_log()` support now the named parameter `path` to specify the directory
#### Fixed
- the function `load_log()` works now when a fully qualified filename is passed 

### KiteUtils v0.6.10 - 2024-04-20
#### Added
- new parameters `rel_compr_stiffness` and `rel_damping` in settings.yaml 

#### Changed
- the functions `load_log()` and `save_log()` have the new, optional, named parameter `path` to specify the file path;  if not specified, the default data path is used.

### KiteUtils v0.6.9 - 2024-04-16
#### Added
- function fpc_settings()
- function fpp_settings()

### KiteUtils v0.6.8 - 2024-04-16
#### Added
- function wc_settings(), which returns the name of the wc_settings.yaml file of the current project
#### Changed
- the function load_settings(project) now expects the name of the `systems.yaml` file as parameter
- the key `project` in `systems.yaml` was replaced with the key `sim_settings`
- the key `wc_settings` was added to `systems.yaml`

### KiteUtils v0.6.6 - 2024-04-05
#### Added
- add field `log_level` to `settings.yaml`and Settings struct

### KiteUtils v0.6.5 - 2024-04-03
#### Added
- add field `solver` to `settings.yaml`and Settings struct

### KiteUtils v0.6.4 - 2024-03-29
#### Changed
- the function `load_log()` does not require the number of tether segments as parameter any longer. It is derived from the content of the log file.

### KiteUtils v0.6.3 - 2024-03-26
#### Added
- Add free fields var_01 .. var_02 and column meta data ([#41](https://github.com/ufechner7/KiteUtils.jl/pull/41))

