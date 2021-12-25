# Exported Functions

```@meta
CurrentModule = KiteUtils
```

# Reading config files
```@docs
se()
```
Also look at the default example: [settings.yaml](https://github.com/ufechner7/KiteUtils.jl/blob/main/data/settings.yaml) .

# Creating test data
```@docs
demo_state(P, height=6.0, time=0.0)
demo_syslog(P, name="Test flight"; duration=10)
demo_log(P, name="Test_flight"; duration=10)
```

# Loading, saving and converting log files
```@docs
load_log(P, filename::String)
save_log(P, flight_log)
syslog2extlog(P, syslog)
```

## Rotation matrices
```@docs
rot3d(ax, ay, az, bx, by, bz)
rot(pos_kite, pos_before, v_app)
```

## Geometric calculations
Calculate the elevation angle, the azimuth angle and the ground distance based on the kite position.
```@docs
calc_elevation(vec)
azimuth_east(vec)
ground_dist(vec)
```