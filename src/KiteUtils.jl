module KiteUtils

#= MIT License

Copyright (c) 2020, 2021 Uwe Fechner

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

using Rotations, StaticArrays, StructArrays, RecursiveArrayTools, Arrow, YAML, LinearAlgebra, DocStringExtensions, Parameters
export Settings, SysState, SysLog, MyFloat

export demo_state, demo_syslog, demo_log, load_log, save_log, export_log # functions for logging
export demo_state_4p, initial_kite_ref_frame                             # functions for four point kite model
export rot, rot3d, ground_dist, calc_elevation, azimuth_east, acos2      # geometric functions
export set_data_path, get_data_path, load_settings, copy_settings, se, se_dict # functions for reading and copying parameters

"""
    const MyFloat = Float32

Type used for position components and scalar SysState members.
"""
const MyFloat = Float32             # type to use for position components and scalar SysState members  
const DATA_PATH = ["data"]          # path for log files and other data
const SE_DICT = [Dict()]

include("settings.jl")
include("transformations.jl")
include("trafo.jl")

"""
    SysState{P}

Basic system state. One of these is saved per time step. P is the number
of tether particles.

$(TYPEDFIELDS)
"""
struct SysState{P}
    "time since start of simulation in seconds"
    time::Float64
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
    "depower settings"
    depower::MyFloat
    "norm of apparent wind speed [m/s]"
    v_app::MyFloat
    "vector of particle positions in x"
    X::MVector{P, MyFloat}
    "vector of particle positions in y"
    Y::MVector{P, MyFloat}
    "vector of particle positions in z"
    Z::MVector{P, MyFloat}
end 

function Base.getproperty(st::SysState, sym::Symbol)
    if sym == :pos
        X = getfield(st, :X)
        Y = getfield(st, :Y)
        Z = getfield(st, :Z)
        pos = zeros(SVector{length(X), MVector{3, MyFloat}})
        for i in 1:length(X)
            pos[i] .= MVector(X[i], Y[i], Z[i])
        end
        pos
    else
        getfield(st, sym)
    end
end

function Base.getproperty(st::StructVector{SysState}, sym::Symbol)
    if sym == :x
        last.getfield(st, :X)
    elseif sym == :y
        last.getfield(st, :Y)
    elseif sym == :z
        last.getfield(st, :Z) # last.(st.Z)
    else
        getfield(st, sym)
    end
end

function Base.show(io::IO, st::SysState) 
    println(io, "time      [s]:       ", st.time)
    println(io, "orient    [w,x,y,z]: ", st.orient)
    println(io, "elevation [rad]:     ", st.elevation)
    println(io, "azimuth   [rad]:     ", st.azimuth)
    println(io, "l_tether  [m]:       ", st.l_tether)
    println(io, "v_reelout [m/s]:     ", st.v_reelout)
    println(io, "force     [N]:       ", st.force)
    println(io, "depower   [-]:       ", st.depower)
    println(io, "v_app     [m/s]:     ", st.v_app)
    println(io, "X         [m]:       ", st.X)
    println(io, "Y         [m]:       ", st.Y)
    println(io, "Z         [m]:       ", st.Z)
end

"""
    SysLog{P}

Flight log, containing the basic data as struct of vectors which can be accessed as if it would
be an array structs. 
In addition an extended view on the data that includes derived/ calculated values for plotting.
Finally it contains meta data like the name of the log file.

$(TYPEDFIELDS)
"""
struct SysLog{P}
    "name of the flight log"
    name::String
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

# functions
function __init__()
    SETTINGS.segments=0 # force loading of settings.yaml
end

"""
    demo_state(P, height=6.0, time=0.0)

Create a demo state with a given height and time. P is the number of tether particles.

Returns a SysState instance.
"""
function demo_state(P, height=6.0, time=0.0)
    a = 10
    X = range(0, stop=10, length=P)
    Y = zeros(length(X))
    Z = (a .* cosh.(X./a) .- a) * height/ 5.430806 
    r_xyz = RotXYZ(pi/2, -pi/2, 0)
    q = QuatRotation(r_xyz)
    orient = MVector{4, Float32}(Rotations.params(q))
    elevation = calc_elevation([X[end], 0.0, Z[end]])
    return SysState{P}(time, orient, elevation,0.,0.,0.,0.,0.,0.,X, Y, Z)
end

"""
    initial_kite_ref_frame(vec_c, v_app)

Calculate the initial orientation of the kite based on the last tether segment and
the apparent wind speed.

Parameters:
- `vec_c`: (pos_n-2) - (pos_n-1) n: number of particles without the three kite particles
                                    that do not belong to the main thether (P1, P2 and P3).
- v_app: vector of the apparent wind speed

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
    get_particles(height_k, height_b, width, m_k, pos_pod= [ 75., 0., 129.90381057], vec_c=[-15., 0., -25.98076211], v_app=[10.4855, 0, -3.08324])

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
function get_particles(height_k, height_b, width, m_k, pos_pod= [ 75., 0., 129.90381057], vec_c=[-15., 0., -25.98076211], v_app=[10.4855, 0, -3.08324])
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
    demo_state_4p(P, height=6.0, time=0.0)

Create a demo state, using the 4 point kite model with a given height and time. P is the number of tether particles.

Returns a SysState instance.
"""
function demo_state_4p(P, height=6.0, time=0.0)
    a = 10
    X = collect(range(0, stop=10, length=P))
    Y = zeros(length(X))
    Z = (a .* cosh.(X./a) .- a) * height/ 5.430806 
    # append the kite particles to X, Y and z
    pod_pos = [X[end], Y[end], Z[end]]
    particles = get_particles(se().height_k, se().h_bridle, se().width, se().m_k, pod_pos)[3:end]
    for i in 1:4
        particle=particles[i]
        x, y, z = particle[1], particle[2], particle[3]
        push!(X, x)
        push!(Y, y)
        push!(Z, z)
    end
    r_xyz = RotXYZ(pi/2, -pi/2, 0)
    q = QuatRotation(r_xyz)
    orient = MVector{4, Float32}(Rotations.params(q))
    elevation = calc_elevation([X[end], 0.0, Z[end]])
    return SysState{P+4}(time, orient, elevation,0.,0.,0.,0.,0.,0.,X, Y, Z)
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
    myzeros = zeros(MyFloat, steps)
    elevation = Vector{Float64}(undef, steps)
    orient_vec = Vector{MVector{4, Float32}}(undef, steps)
    X_vec = Vector{MVector{P, MyFloat}}(undef, steps)
    Y_vec = Vector{MVector{P, MyFloat}}(undef, steps)
    Z_vec = Vector{MVector{P, MyFloat}}(undef, steps)
    for i in range(0, length=steps)
        state = demo_state(P, max_height * i/steps, i/se().sample_freq)
        time_vec[i+1] = state.time
        orient_vec[i+1] = state.orient
        elevation[i+1] = asin(state.Z[end]/state.X[end])
        X_vec[i+1] = state.X
        Y_vec[i+1] = state.Y
        Z_vec[i+1] = state.Z
    end
    return StructArray{SysState{P}}((time_vec, orient_vec, elevation, myzeros,myzeros,myzeros,myzeros,myzeros,myzeros, X_vec, Y_vec, Z_vec))
end

"""
    demo_log(P, name="Test_flight"; duration=10)

Create an artifical SysLog struct for demonstration purposes. P is the number of tether
particles.
"""
function demo_log(P, name="Test_flight"; duration=10)
    syslog = demo_syslog(P, name, duration=duration)
    return SysLog{P}(name, syslog)
end

"""
    save_log(flight_log, compress=true)

Save a fligh log of type SysLog as .arrow file. By default lz4 compression is used, 
if you use **false** as second parameter no compression is used.
"""
function save_log(flight_log, compress=true)
    filename = joinpath(DATA_PATH[1], flight_log.name) * ".arrow"
    if compress
        Arrow.write(filename, flight_log.syslog, compress=:lz4)
    else
        Arrow.write(filename, flight_log.syslog)
    end
end

"""
    export_log(flight_log)

Save a fligh log of type SysLog as .csv file.
"""
function export_log(flight_log)
    @eval using CSV
    filename = joinpath(DATA_PATH[1], flight_log.name) * ".csv"
    Base.invokelatest(CSV.write, filename, flight_log.syslog)
end

"""
    load_log(P, filename::String)

Read a log file that was saved as .arrow file.  P is the number of tether
particles.
"""
function load_log(P, filename::String)
    if isnothing(findlast(isequal('.'), filename))
        fullname = joinpath(DATA_PATH[1], filename) * ".arrow"
    else
        fullname = joinpath(DATA_PATH[1], filename) 
    end
    table = Arrow.Table(fullname)
    syslog = StructArray{SysState{P}}((table.time, table.orient, table.elevation, table.azimuth, table.l_tether, table.v_reelout, table.force, table.depower, table.v_app, table.X, table.Y, table.Z))
    return SysLog{P}(basename(fullname[1:end-6]), syslog)
end

function test(save=false)
    if save
        log_to_save=demo_log(7)
        save_log(log_to_save)
    end
    return(load_log(7, "Test_flight.arrow"))
end

precompile(load_log, (Int64, String,))     

end
