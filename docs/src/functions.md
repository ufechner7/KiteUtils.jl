# Exported Functions

```@meta
CurrentModule = KiteUtils
```

# Reading config files
```@docs
set_data_path
load_settings
update_settings
copy_settings
se
se_dict
```
Also look at the default example: [settings.yaml](https://github.com/ufechner7/KiteUtils.jl/blob/main/data/settings.yaml) .

# Modify .yaml files
```@docs
readfile
writefile
change_value
```

# Creating test data
```@docs
demo_state
demo_state_4p
demo_state_4p_3lines
demo_syslog
demo_log
get_particles
get_particles_3l
```

# Loading, saving and converting log files
```@docs
log!
load_log
save_log
import_log
export_log
sys_log
```
The function ```set_data_path(data_path)``` can be used to set the directory for the log files. 

## Rotation matrices
```@docs
rot3d(ax, ay, az, bx, by, bz)
rot(pos_kite, pos_before, v_app)
```

## Coordinate system transformations
```@docs
fromENU2EG
fromEG2W
fromW2SE
fromKS2EX
fromEX2EG
```

## Geometric calculations
Calculate the elevation angle, the azimuth angle and the ground distance based on the kite position. In addition,
calculate the heading angle, the heading vector, the arc cos (safe version) and the initial kite reference frame.
```@docs
calc_elevation
calc_azimuth
calc_heading
calc_course
calc_heading_w
azimuth_east
ground_dist
acos2
wrap2pi
initial_kite_ref_frame
```