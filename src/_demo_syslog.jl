"""
    demo_syslog(P, name="Test flight"; duration=10)

Create a demo flight log  with given name [String] and duration [s] as StructArray. P is the number of tether
particles.
"""
function demo_syslog(P, name="Test flight"; duration=10)
    max_height = 6.03
    steps   = Int(duration * se().sample_freq) + 1
    time_vec = Vector{Float64}(undef, steps)
    t_sim_vec = Vector{Float64}(undef, steps)
    sys_state_vec = Vector{Int16}(undef, steps)
    e_mech_vec = Vector{Float64}(undef, steps)
    myzeros = zeros(MyFloat, steps)
    elevation = Vector{Float64}(undef, steps)
    orient_vec = Vector{MVector{4, Float32}}(undef, steps)
    v_wind_gnd_vec = Vector{MVector{3, MyFloat}}(undef, steps)
    v_wind_200m_vec = Vector{MVector{3, MyFloat}}(undef, steps)
    v_wind_kite_vec = Vector{MVector{3, MyFloat}}(undef, steps)
    vel_kite_vec = Vector{MVector{3, MyFloat}}(undef, steps)
    X_vec = Vector{MVector{P, MyFloat}}(undef, steps) 
    Y_vec = Vector{MVector{P, MyFloat}}(undef, steps)
    Z_vec = Vector{MVector{P, MyFloat}}(undef, steps)
    var_01_vec = Vector{Float64}(undef, steps)
    var_02_vec = Vector{Float64}(undef, steps)
    var_03_vec = Vector{Float64}(undef, steps)
    var_04_vec = Vector{Float64}(undef, steps)
    var_05_vec = Vector{Float64}(undef, steps)
    var_06_vec = Vector{Float64}(undef, steps)
    var_07_vec = Vector{Float64}(undef, steps)
    var_08_vec = Vector{Float64}(undef, steps)
    var_09_vec = Vector{Float64}(undef, steps)
    var_10_vec = Vector{Float64}(undef, steps)
    var_11_vec = Vector{Float64}(undef, steps)
    var_12_vec = Vector{Float64}(undef, steps)
    var_13_vec = Vector{Float64}(undef, steps)
    var_14_vec = Vector{Float64}(undef, steps)
    var_15_vec = Vector{Float64}(undef, steps)
    var_16_vec = Vector{Float64}(undef, steps)
    for i in range(0, length=steps)
        state = demo_state(P, max_height * i/steps, i/se().sample_freq)
        time_vec[i+1] = state.time
        t_sim_vec[i+1] = state.t_sim
        sys_state_vec[i+1] = state.sys_state
        e_mech_vec[i+1] = state.e_mech
        orient_vec[i+1] = state.orient
        v_wind_gnd_vec[i+1] = state.v_wind_gnd
        v_wind_200m_vec[i+1] = state.v_wind_200m
        v_wind_kite_vec[i+1] = state.v_wind_kite
        vel_kite_vec[i+1] = state.vel_kite
        elevation[i+1] = asin(state.Z[end]/state.X[end])
        X_vec[i+1] = state.X
        Y_vec[i+1] = state.Y
        Z_vec[i+1] = state.Z
        var_01_vec[i+1] = 0
        var_02_vec[i+1] = 0
        var_03_vec[i+1] = 0
        var_04_vec[i+1] = 0
        var_05_vec[i+1] = 0
        var_06_vec[i+1] = 0
        var_07_vec[i+1] = 0
        var_08_vec[i+1] = 0
        var_09_vec[i+1] = 0
        var_10_vec[i+1] = 0
        var_11_vec[i+1] = 0
        var_12_vec[i+1] = 0
        var_13_vec[i+1] = 0
        var_14_vec[i+1] = 0
        var_15_vec[i+1] = 0
        var_16_vec[i+1] = 0
    end
    return StructArray{SysState{P}}((time_vec, t_sim_vec,sys_state_vec, e_mech_vec, orient_vec, elevation, myzeros,myzeros,myzeros,myzeros,myzeros,myzeros,
                                     myzeros,myzeros,myzeros, v_wind_gnd_vec, v_wind_200m_vec, v_wind_kite_vec, vel_kite_vec, X_vec, Y_vec, Z_vec, var_01_vec, var_02_vec, var_03_vec, 
                                     var_04_vec, var_05_vec, var_06_vec, var_07_vec, var_08_vec, var_09_vec, var_10_vec, var_11_vec, var_12_vec,
                                     var_13_vec, var_14_vec, var_15_vec, var_16_vec))
end
