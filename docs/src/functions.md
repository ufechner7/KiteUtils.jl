# Exported Functions

```@meta
CurrentModule = KiteUtils
```

# Reading config files
```@docs
set_data_path
load_settings
copy_settings
se
se_dict
```
Also look at the default example: [settings.yaml](https://github.com/ufechner7/KiteUtils.jl/blob/main/data/settings.yaml) .

# Creating test data
```@docs
demo_state(P, height=6.0, time=0.0)
demo_state_4p
demo_syslog(P, name="Test flight"; duration=10)
demo_log(P, name="Test_flight"; duration=10)
get_particles
```

# Loading, saving and converting log files
```@docs
load_log(P, filename::String)
save_log(flight_log)
export_log(flight_log)
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
calc_heading_w
azimuth_east
ground_dist
acos2
initial_kite_ref_frame
```