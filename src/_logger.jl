"""
    mutable struct Logger{P, Q}

Struct to store a simulation log. P is number of points of the tether, segments+1 and 
Q is the number of time steps that will be pre-allocated.

Constructor:
- Logger(P, steps)

Fields:

$(TYPEDFIELDS)
"""
@with_kw mutable struct Logger{P, Q}
    points::Int64 = P
    index::Int64 = 1
    time_vec::Vector{Float64} = zeros(Float64, Q)
    t_sim_vec::Vector{Float64} = zeros(Float64, Q)
    sys_state_vec::Vector{Int16} = zeros(Int16, Q)
    e_mech_vec::Vector{Float64} = zeros(Float64, Q)
    orient_vec::Vector{MVector{4, Float32}} = zeros(MVector{4, Float32}, Q)
    elevation_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    azimuth_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    l_tether_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    v_reelout_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    force_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    depower_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    steering_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    heading_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    course_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    v_app_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    v_wind_gnd_vec::Vector{MVector{3, MyFloat}} = zeros(MVector{3, MyFloat}, Q)
    v_wind_200m_vec::Vector{MVector{3, MyFloat}} = zeros(MVector{3, MyFloat}, Q)
    v_wind_kite_vec::Vector{MVector{3, MyFloat}} = zeros(MVector{3, MyFloat}, Q)
    vel_kite_vec::Vector{MVector{3, MyFloat}} = zeros(MVector{3, MyFloat}, Q)
    X_vec::Vector{MVector{P, MyFloat}} = zeros(MVector{P, MyFloat}, Q)
    Y_vec::Vector{MVector{P, MyFloat}} = zeros(MVector{P, MyFloat}, Q)
    Z_vec::Vector{MVector{P, MyFloat}} = zeros(MVector{P, MyFloat}, Q)
    var_01_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_02_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_03_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_04_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_05_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_06_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_07_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_08_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_09_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_10_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_11_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_12_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_13_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_14_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_15_vec::Vector{MyFloat} = zeros(MyFloat, Q)
    var_16_vec::Vector{MyFloat} = zeros(MyFloat, Q)
end