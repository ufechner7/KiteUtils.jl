# Changelog

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

