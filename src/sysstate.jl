Base.@kwdef mutable struct SysState{P}
    "time since start of simulation in seconds"
    time::Float64
    "time needed for one simulation timestep"
    t_sim::Float64
    "state of system state control"
    sys_state::Int16
    "mechanical energy [Wh]"
    e_mech::Float64
    "orientation of the kite (quaternion, order w,x,y,z)"
    orient::MVector{4, Float32}
    "elevation angle in radians"
    elevation::MyFloat
    "azimuth angle in radians"
    azimuth::MyFloat
    "tether length [m]"
    l_tether::MyFloat
    "reel out velocity [m/s]"
    v_reelout::MyFloat
    "tether force [N]"
    force::MyFloat
    "depower settings [0..1]"
    depower::MyFloat
    "steering settings [-1..1]"
    steering::MyFloat
    "heading angle in radian"
    heading::MyFloat
    "course angle in radian"
    course::MyFloat
    "norm of apparent wind speed [m/s]"
    v_app::MyFloat
    "wind velocity at ground level [m/s]"
    v_wind_gnd::MVector{3, MyFloat}
    "wind velocity at 200m height [m/s]"
    v_wind_200m::MVector{3, MyFloat}
    "wind velocity at kite height [m/s]"
    v_wind_kite::MVector{3, MyFloat}
    "velocity vector of the kite"
    vel_kite::MVector{3, MyFloat}
    "vector of particle positions in x"
    X::MVector{P, MyFloat}
    "vector of particle positions in y"
    Y::MVector{P, MyFloat}
    "vector of particle positions in z"
    Z::MVector{P, MyFloat}
    var_01::MyFloat
    var_02::MyFloat
    var_03::MyFloat
    var_04::MyFloat
    var_05::MyFloat
    var_06::MyFloat
    var_07::MyFloat
    var_08::MyFloat
    var_09::MyFloat
    var_10::MyFloat
    var_11::MyFloat
    var_12::MyFloat
    var_13::MyFloat
    var_14::MyFloat
    var_15::MyFloat
    var_16::MyFloat
end