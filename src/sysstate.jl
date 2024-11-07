"""
    SysState{P}

Basic system state. One of these is saved per time step. P is the number
of tether particles.

$(TYPEDFIELDS)
"""
Base.@kwdef mutable struct SysState{P}
    "time since start of simulation in seconds"
    time::Float64
    "time needed for one simulation timestep in seconds"
    t_sim::Float64
    "state of system state control"
    sys_state::Int16
    "mechanical energy [Wh]"
    e_mech::Float64
    "orientation of the kite (quaternion, order w,x,y,z)"
    orient::MVector{4, Float32}
    "elevation angle [rad]"
    elevation::MyFloat
    "azimuth angle in wind reference frame [rad]"
    azimuth::MyFloat
    "tether length [m]"
    l_tether::MyFloat
    "reelout speed [m/s]"
    v_reelout::MyFloat
    "tether force [N]"
    force::MyFloat
    "depower settings [0..1]"
    depower::MyFloat
    "steering settings [-1..1]"
    steering::MyFloat
    "heading angle [rad]"
    heading::MyFloat
    "course angle [rad]"
    course::MyFloat
    "norm of apparent wind speed [m/s]"
    v_app::MyFloat
    "wind vector at reference height [m/s]"
    v_wind_gnd::MVector{3, MyFloat}
    "wind vector at 200m height [m/s]"
    v_wind_200m::MVector{3, MyFloat}
    "wind vector at the height of the kite [m/s]"
    v_wind_kite::MVector{3, MyFloat}
    "velocity vector of the kite [m/s]"
    vel_kite::MVector{3, MyFloat}
    "vector of particle positions in x [m]"
    X::MVector{P, MyFloat}
    "vector of particle positions in y [m]"
    Y::MVector{P, MyFloat}
    "vector of particle positions in z [m]"
    Z::MVector{P, MyFloat}
    "generic variable 01"
    var_01::MyFloat
    "generic variable 02"
    var_02::MyFloat
    "generic variable 03"
    var_03::MyFloat
    "generic variable 04"
    var_04::MyFloat
    "generic variable 05"
    var_05::MyFloat
    "generic variable 06"
    var_06::MyFloat
    "generic variable 07"
    var_07::MyFloat
    "generic variable 08"
    var_08::MyFloat
    "generic variable 09"
    var_09::MyFloat
    "generic variable 10"
    var_10::MyFloat
    "generic variable 11"
    var_11::MyFloat
    "generic variable 12"
    var_12::MyFloat
    "generic variable 13"
    var_13::MyFloat
    "generic variable 14"
    var_14::MyFloat
    "generic variable 15"
    var_15::MyFloat
    "generic variable 16"
    var_16::MyFloat
end
