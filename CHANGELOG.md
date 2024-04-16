# Changelog

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
