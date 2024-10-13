module KiteUtils

#= MIT License

Copyright (c) 2020, 2021, 2024 Uwe Fechner, Bart van de Lint

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. =#

# data structures for the flight state and the flight log
# functions for creating a demo flight state, demo flight log, loading and saving flight logs
# function se() for reading the settings
# the parameter P is the number of points of the tether, equal to segments+1
# in addition helper functions for working with rotations

using PrecompileTools: @setup_workload, @compile_workload 
using Rotations, StaticArrays, StructArrays, RecursiveArrayTools, Arrow, YAML, LinearAlgebra, DocStringExtensions
using Parameters, StructTypes, CSV, Parsers
export Settings, SysState, SysLog, Logger, MyFloat

import Base.length
export demo_state, demo_syslog, demo_log, load_log, save_log, export_log, import_log # functions for logging
export log!, syslog, length
export demo_state_4p, demo_state_4p_3lines, initial_kite_ref_frame       # functions for four point and three line kite
export rot, rot3d, ground_dist, calc_elevation, azimuth_east, asin2 
export acos2, wrap2pi, quat2euler, quat2frame, quat2viewer               # geometric functions
export fromEG2W, fromENU2EG,fromW2SE, fromKS2EX, fromEX2EG               # reference frame transformations
export calc_azimuth, calc_heading_w, calc_heading, calc_course           # geometric functions
export calc_orient_rot
export set_data_path, get_data_path, load_settings, copy_settings        # functions for reading and copying parameters
export se, se_dict, update_settings, wc_settings, fpc_settings, fpp_settings

"""
    const MyFloat = Float32

Type used for position components and scalar SysState members.
"""
const MyFloat = Float32             # type to use for position components and scalar SysState members  
const DATA_PATH = ["data"]          # path for log files and other data
const SE_DICT = [Dict()]

include("settings.jl")
include("yaml_utils.jl")
include("transformations.jl")
include("trafo.jl")

"""
    SysState{P}

Basic system state. One of these is saved per time step. P is the number
of tether particles.

$(TYPEDFIELDS)
"""
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

function Base.getproperty(st::SysState, sym::Symbol)
    if sym == :pos
        X = getfield(st, :X)
        Y = getfield(st, :Y)
        Z = getfield(st, :Z)
        pos = zeros(SVector{length(X), MVector{3, MyFloat}})
        for i in eachindex(X)
            pos[i] .= MVector(X[i], Y[i], Z[i])
        end
        pos
    else
        getfield(st, sym)
    end
end

# function Base.getproperty(st::StructVector{SysState}, sym::Symbol)
#     if sym == :x
#         last.getfield(st, :X)
#     elseif sym == :y
#         last.getfield(st, :Y)
#     elseif sym == :z
#         last.getfield(st, :Z) # last.(st.Z)
#     else
#         getfield(st, sym)
#     end
# end

function Base.show(io::IO, st::SysState) 
    println(io, "time      [s]:       ", st.time)
    println(io, "t_sim     [s]:       ", st.t_sim)
    println(io, "sys_state    :       ", st.sys_state)
    println(io, "e_mech    [Wh]:      ", st.e_mech)
    println(io, "orient    [w,x,y,z]: ", st.orient)
    println(io, "elevation [rad]:     ", st.elevation)
    println(io, "azimuth   [rad]:     ", st.azimuth)
    println(io, "l_tether  [m]:       ", st.l_tether)
    println(io, "v_reelout [m/s]:     ", st.v_reelout)
    println(io, "force     [N]:       ", st.force)
    println(io, "depower   [-]:       ", st.depower)
    println(io, "steering  [-]:       ", st.steering)
    println(io, "heading   [rad]:     ", st.heading)
    println(io, "course    [rad]:     ", st.course)
    println(io, "v_app     [m/s]:     ", st.v_app)
    println(io, "vel_kite  [m/s]:     ", st.vel_kite)
    println(io, "X         [m]:       ", st.X)
    println(io, "Y         [m]:       ", st.Y)
    println(io, "Z         [m]:       ", st.Z)
    println(io, "var_01       :       ", st.var_01)
    println(io, "var_02       :       ", st.var_02)
    println(io, "var_03       :       ", st.var_03)
    println(io, "var_04       :       ", st.var_04)
    println(io, "var_05       :       ", st.var_05)
    println(io, "var_06       :       ", st.var_06)
    println(io, "var_07       :       ", st.var_07)
    println(io, "var_08       :       ", st.var_08)
    println(io, "var_09       :       ", st.var_09)
    println(io, "var_10       :       ", st.var_10)
    println(io, "var_11       :       ", st.var_11)
    println(io, "var_12       :       ", st.var_12)
    println(io, "var_13       :       ", st.var_13)
    println(io, "var_14       :       ", st.var_14)
    println(io, "var_15       :       ", st.var_15)
    println(io, "var_16       :       ", st.var_16)
end

"""
    SysLog{P}

Flight log, containing the basic data as struct of vectors which can be accessed as if it would
be an array structs. 
In addition an extended view on the data that includes derived/ calculated values for plotting.
Finally it contains meta data like the name of the log file.

$(TYPEDFIELDS)
"""
mutable struct SysLog{P}
    "name of the flight log"
    name::String
    colmeta::Dict
    "struct of vectors that can also be accessed like a vector of structs"
    syslog::StructArray{SysState{P}}
end

function Base.getproperty(log::SysLog, sym::Symbol)
    if sym == :x
        last.(getproperty(log.syslog, :X))
    elseif sym == :y
        last.(getproperty(log.syslog, :Y))
    elseif sym == :z
        last.(getproperty(log.syslog, :Z))
    else
        getfield(log, sym)
    end
end

include("logger.jl")

# functions
function __init__()
    SETTINGS.segments=0 # force loading of settings.yaml
    if isdir(joinpath(pwd(), "data")) && isfile(joinpath(pwd(), "data", "system.yaml"))
        set_data_path(joinpath(pwd(), "data"))
    end
end

"""
    demo_state(P, height=6.0, time=0.0; yaw=-pi/2)

Create a demo state with a given height and time. P is the number of tether particles.
Kite is parking and aligned with the tether.

Returns a SysState instance.
"""
function demo_state(P, height=6.0, time=0.0; yaw=-pi/2)
    a = 10
    turn_angle = yaw+pi/2
    dist = collect(range(10, stop=10, length=P))
    X = dist .* cos(turn_angle)
    Y = dist .* sin(turn_angle)
    Z = (a .* cosh.(X./a) .- a) * height/ 5.430806 
    r_xyz = RotXYZ(pi/2, -pi/2, 0)
    q = QuatRotation(r_xyz)
    orient = MVector{4, Float32}(Rotations.params(q))
    elevation = calc_elevation([X[end], 0.0, Z[end]])
    vel_kite = zeros(3)
    t_sim = 0.012
    sys_state = 0
    e_mech = 0
    return SysState{P}(time, t_sim, sys_state, e_mech, orient, elevation,0,0,0,0,0,0,0,0,0,
                       vel_kite, X, Y, Z, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

"""
    initial_kite_ref_frame(vec_c, v_app)

Calculate the initial orientation of the kite based on the last tether segment and
the apparent wind speed.

Parameters:
- `vec_c`: (`pos_n`-2) - (`pos_n`-1) n: number of particles without the three kite particles
                                    that do not belong to the main thether (P1, P2 and P3).
- `v_app`: vector of the apparent wind speed

Returns:
x, y, z:  the unit vectors of the kite reference frame in the ENU reference frame
"""
function initial_kite_ref_frame(vec_c, v_app)
    z = normalize(vec_c)
    y = normalize(cross(v_app, vec_c))
    x = normalize(cross(y, vec_c))
    return (x, y, z)    
end

"""
    get_particles(height_k, height_b, width, m_k, pos_pod= [ 75., 0., 129.90381057], vec_c=[-15., 0., -25.98076211], 
                  v_app=[10.4855, 0, -3.08324])

Calculate the initial positions of the particels representing 
a 4-point kite, connected to a kite control unit (KCU). 

Parameters:
- height_k: height of the kite itself, not above ground [m]
- height_b: height of the bridle [m]
- width: width of the kite [m]
- mk: relative nose distance
- pos_pod: position of the control pod
- vec_c: vector of the last tether segment
"""
function get_particles(height_k, height_b, width, m_k, pos_pod= [ 75., 0., 129.90381057], 
                       vec_c=[-15., 0., -25.98076211], v_app=[10.4855, 0, -3.08324])
    # inclination angle of the kite; beta = atan(-pos_kite[2], pos_kite[1]) ???
    beta = pi/2.0
    x, y, z = initial_kite_ref_frame(vec_c, v_app)

    h_kx = height_k * cos(beta); # print 'h_kx: ', h_kx
    h_kz = height_k * sin(beta); # print 'h_kz: ', h_kz
    h_bx = height_b * cos(beta)
    h_bz = height_b * sin(beta)
    pos_kite = pos_pod - (h_kz + h_bz) * z + (h_kx + h_bx) * x   # top,        poing B in diagram
    pos_C = pos_kite + h_kz * z + 0.5 * width * y + h_kx * x     # side point, point C in diagram
    pos_A = pos_kite + h_kz * z + (h_kx + width * m_k) * x       # nose,       point A in diagram
    pos_D = pos_kite + h_kz * z - 0.5 * width * y + h_kx * x     # side point, point D in diagram
    pos0 = pos_kite + (h_kz + h_bz) * z + (h_kx + h_bx) * x      # equal to pos_pod, P_KCU in diagram
    [zeros(3), pos0, pos_A, pos_kite, pos_C, pos_D] # 0, p7, p8, p9, p10, p11
end


"""
Calculate the initial positions of the particles representing 
a 4-point 3 line kite.
"""
function get_particles_3l(width, radius, middle_length, tip_length, bridle_center_distance, pos_kite = [ 75., 0., 129.90381057], vec_c=[-15., 0., -25.98076211], v_app=[10.4855, 0, -3.08324])
    # inclination angle of the kite; beta = atan(-pos_kite[2], pos_kite[1]) ???
    beta = pi/2.0
    e_z = normalize(vec_c) # vec_c is the direction of the last two particles
    e_y = normalize(cross(v_app, e_z))
    e_x = normalize(cross(e_y, e_z))

    α_0 = pi/2 - width/2/radius
    α_C = α_0 + width*(-2*tip_length + sqrt(2*middle_length^2 + 2*tip_length^2)) /
        (4*(middle_length - tip_length)) / radius
    α_D = π - α_C

    E = pos_kite
    E_c = pos_kite + e_z * (-bridle_center_distance + radius) # E at center of circle on which the kite shape lies
    C = E_c + e_y*cos(α_C)*radius - e_z*sin(α_C)*radius
    D = E_c + e_y*cos(α_D)*radius - e_z*sin(α_D)*radius

    kite_length_C = tip_length + (middle_length-tip_length) * (α_C - α_0) / (π/2 - α_0)
    P_c = (C+D)./2
    A = P_c - e_x*(kite_length_C*(3/4 - 1/4))

    E, C, D, A, α_C, kite_length_C # important to have the order E = 1, C = 2, D = 3, A = 4
end

"""
    demo_state_4p(P, height=6.0, time=0.0; yaw=-pi/2)

Create a demo state, using the 4 point kite model with a given height and time. P is the number of tether particles.

Returns a SysState instance.
"""
function demo_state_4p(P, height=6.0, time=0.0; yaw=-pi/2)
    a = 10
    turn_angle = yaw+pi/2
    dist = collect(range(10, stop=10, length=P))
    X = dist .* cos(turn_angle)
    Y = dist .* sin(turn_angle)
    Z = (a .* cosh.(X./a) .- a) * height/ 5.430806 
    # append the kite particles to X, Y and z
    pod_pos = [X[end], Y[end], Z[end]]
    particles = get_particles(se().height_k, se().h_bridle, se().width, se().m_k, pod_pos)[3:end]
    local pos_B, pos_C, pos_D
    for i in 1:4
        particle=particles[i]
        x, y, z = particle[1], particle[2], particle[3]
    
        if i==2
            pos_B = SVector(x,y,z)
        elseif  i==3
            pos_C = SVector(x,y,z)
        elseif i==4
            pos_D = SVector(x,y,z)
        end
        push!(X, x)
        push!(Y, y)
        push!(Z, z)
    end
    pos_centre = 0.5 * (pos_C + pos_D)
    delta = pos_B - pos_centre
    z = -normalize(delta)
    y = normalize(pos_C - pos_D)
    x = y × z
    pos_kite_ = pod_pos
    pos_before = pos_kite_ + z
   
    rotation = rot(pos_kite_, pos_before, -x)
    q = QuatRotation(rotation)
    orient = MVector{4, Float32}(Rotations.params(q))
    elevation = calc_elevation([X[end], 0.0, Z[end]])
    vel_kite=zeros(3)
    t_sim = 0.014
    sys_state = 0
    e_mech = 0
    return SysState{P+4}(time, t_sim, sys_state, e_mech, orient, elevation,0,0,0,0,0,0,0,0,0,vel_kite, X, Y, Z, 
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

"""
    demo_state_4p_3lines(P, height=6.0, time=0.0)

Create a demo state, using the 4 point kite model with a given height and time. 
P is the number of middle tether particles.

Returns a SysState instance.
"""
function demo_state_4p_3lines(P, height=6.0, time=0.0)
    P_ = P*3+3 # P_ is total number of particles in the system (kite + 3 tethers)
    num_A = P_
    num_D = P_-1
    num_C = P_-2
    num_E = P_-3
    pos = zeros(SVector{P_, MVector{3, Float64}})

    # ground points
    [pos[i] .= [0.0, 0.0, 0.0] for i in 1:3]

    # middle tether
    sin_el, cos_el = sin(deg2rad(se().elevation)), cos(deg2rad(se().elevation))
    for (i, j) in enumerate(range(6, step=3, length=se().segments))
        radius = i * (se().l_tether/se().segments)
        pos[j] .= [cos_el*radius, 0.0, sin_el*radius]
    end

    # kite points
    vec_c = pos[num_E-3] - pos[num_E]
    E, C, D, A, _, _ = get_particles_3l(se().width, se().radius, se().middle_length, se().tip_length, se().bridle_center_distance, pos[num_E], vec_c)
    pos[num_A] .= A
    pos[num_C] .= C
    pos[num_D] .= [pos[num_C][1], -pos[num_C][2], pos[num_C][3]]
    
    # build tether connection points
    e_z = normalize(vec_c)
    distance_c_l = 0.5 # distance between c and left steering line
    pos[num_E-2] .= pos[num_C] + e_z .* (distance_c_l)
    pos[num_E-1] .= pos[num_E-2] .* [1.0, -1.0, 1.0]

    # build left and right tether points
    for (i, j) in enumerate(range(4, step=3, length=se().segments-1))
        pos[j] .= pos[num_E-2] ./ se().segments .* i
        pos[j+1] .= [pos[j][1], -pos[j][2], pos[j][3]]
    end

    X = zeros(P_)
    Y = zeros(P_)
    Z = zeros(P_)
    for (i, p) in enumerate(pos)
        # println("pos ", pos)
        X[i] = p[1]
        Y[i] = p[2]
        Z[i] = p[3]
    end   
    # println("X ", X) 
    pos_centre = 0.5 * (C + D)
    delta = E - pos_centre
    z = normalize(delta)
    y = normalize(C - D)
    x = y × z
    pos_before = pos[num_E] + z
   
    rotation = rot(pos[num_E], pos_before, -x)
    q = QuatRotation(rotation)
    orient = MVector{4, Float32}(Rotations.params(q))
    elevation = calc_elevation([X[end], 0.0, Z[end]])
    vel_kite=zeros(3)
    t_sim = 0.014
    sys_state = 0
    e_mech = 0
    return SysState{P_}(time, t_sim, sys_state, e_mech, orient, elevation,0,0,0,0,0,0,0,0,0,vel_kite, X, Y, Z, 
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

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
                                     myzeros,myzeros,myzeros, vel_kite_vec, X_vec, Y_vec, Z_vec, var_01_vec, var_02_vec, var_03_vec, 
                                     var_04_vec, var_05_vec, var_06_vec, var_07_vec, var_08_vec, var_09_vec, var_10_vec, var_11_vec, var_12_vec,
                                     var_13_vec, var_14_vec, var_15_vec, var_16_vec))
end

"""
    demo_log(P, name="Test_flight"; duration=10)

Create an artifical SysLog struct for demonstration purposes. P is the number of tether
particles.
"""
function demo_log(P, name="Test_flight"; duration=10,     
    colmeta = Dict(:var_01 => ["name" => "var_01"],
                   :var_02 => ["name" => "var_02"],
                   :var_03 => ["name" => "var_03"],
                   :var_04 => ["name" => "var_04"],
                   :var_05 => ["name" => "var_05"],
                   :var_06 => ["name" => "var_06"],
                   :var_07 => ["name" => "var_07"],
                   :var_08 => ["name" => "var_08"],
                   :var_09 => ["name" => "var_09"],
                   :var_10 => ["name" => "var_10"],
                   :var_11 => ["name" => "var_11"],
                   :var_12 => ["name" => "var_12"],
                   :var_13 => ["name" => "var_13"],
                   :var_14 => ["name" => "var_14"],
                   :var_15 => ["name" => "var_15"],
                   :var_16 => ["name" => "var_16"]
                   ))
    syslog = demo_syslog(P, name, duration=duration)
    return SysLog{P}(name, colmeta, syslog)
end

"""
    save_log(flight_log::SysLog, compress=true; path="")

Save a fligh log of type SysLog as .arrow file. By default lz4 compression is used, 
if you use **false** as second parameter no compression is used.
"""
function save_log(flight_log::SysLog, compress=true; path="")
    if path == ""
        path = DATA_PATH[1]
    end
    filename = joinpath(path, flight_log.name) * ".arrow"
    if compress
        Arrow.write(filename, flight_log.syslog, compress=:lz4, colmetadata = flight_log.colmeta)
    else
        Arrow.write(filename, flight_log.syslog, colmetadata = flight_log.colmeta)
    end
end

"""
    export_log(flight_log; path="")

Save a fligh log of type SysLog as .csv file.
"""
function export_log(flight_log; path="")
    if path == ""
        path = DATA_PATH[1]
    end
    filename = joinpath(path, flight_log.name) * ".csv"
    CSV.write(filename, flight_log.syslog)
end

"""
    load_log(filename::String; path="")

Read a log file that was saved as .arrow file.
"""
load_log(P, filename::String) = load_log(filename)
function load_log(filename::String; path="")
    if path == ""
        path = DATA_PATH[1]
    end
    fullname = filename
    if ! isfile(filename)
        if isnothing(findlast(isequal('.'), filename))
            fullname = joinpath(path, basename(filename)) * ".arrow"
        else
            fullname = joinpath(path, basename(filename)) 
        end
    end
    table   = Arrow.Table(fullname)
    P =  length(table.Z[1])
    colmeta = Dict(:var_01=>Arrow.getmetadata(table.var_01)["name"],
                   :var_02=>Arrow.getmetadata(table.var_02)["name"],
                   :var_03=>Arrow.getmetadata(table.var_03)["name"],
                   :var_04=>Arrow.getmetadata(table.var_04)["name"],
                   :var_05=>Arrow.getmetadata(table.var_05)["name"],
                   :var_06=>Arrow.getmetadata(table.var_06)["name"],
                   :var_07=>Arrow.getmetadata(table.var_07)["name"],
                   :var_08=>Arrow.getmetadata(table.var_08)["name"],
                   :var_09=>Arrow.getmetadata(table.var_09)["name"],
                   :var_10=>Arrow.getmetadata(table.var_10)["name"],
                   :var_11=>Arrow.getmetadata(table.var_11)["name"],
                   :var_12=>Arrow.getmetadata(table.var_12)["name"],
                   :var_13=>Arrow.getmetadata(table.var_13)["name"],
                   :var_14=>Arrow.getmetadata(table.var_14)["name"],
                   :var_15=>Arrow.getmetadata(table.var_15)["name"],
                   :var_16=>Arrow.getmetadata(table.var_16)["name"],
    )
    # example_metadata = KiteUtils.Arrow.getmetadata(table.var_01)
    syslog = StructArray{SysState{P}}((table.time, table.t_sim, table.sys_state, table.e_mech, table.orient, table.elevation, table.azimuth, table.l_tether, 
                    table.v_reelout, table.force, table.depower, table.steering, table.heading, table.course, 
                    table.v_app, table.vel_kite, table.X, table.Y, table.Z, table.var_01, table.var_02,table.var_03,
                    table.var_04,table.var_05,table.var_06,table.var_07,table.var_08,table.var_09,table.var_10,table.var_11,table.var_12,table.var_13,
                    table.var_14,table.var_15,table.var_16))
    return SysLog{P}(basename(fullname[1:end-6]), colmeta, syslog)
end

function test(save=false)
    if save
        log_to_save=demo_log(7)
        save_log(log_to_save)
    end
    return(load_log(7, "Test_flight.arrow"))
end

@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    # list = [OtherType("hello"), OtherType("world!")]
    set_data_path()
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        se()
        load_log(7, "Test_flight.arrow")
    end
end

end
