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
export SysState, ExtSysState, SysLog, MyFloat

export demo_state, demo_syslog, demo_log, load_log, syslog2extlog, save_log, rot, rot3d, ground_dist, calc_elevation, azimuth_east
export set_data_path, load_settings, copy_settings, se

"""
    const MyFloat = Float32

Type used for position components and scalar SysState members.
"""
const MyFloat = Float32               # type to use for position components and scalar SysState members  
const DATA_PATH = ["./data"]        # path for log files and other data

"""
    Settings

Flat struct, defining the settings of the Simulator and the Viewer.

$(TYPEDFIELDS)
"""
@with_kw mutable struct Settings @deftype Float64
    project::String       = ""
    log_file::String      = ""
    model::String         = ""
    "number of tether segments"
    segments::Int64       = 0
    sample_freq::Int64    = 0
    time_lapse            = 0
    zoom                  = 0
    fixed_font::String    = ""
    v_reel_out            = 0
    c0                    = 0
    c_s                   = 0
    c2_cor                = 0
    k_ds                  = 0
    "projected kite area            [m^2]"
    area                  = 0
    "kite mass incl. sensor unit     [kg]"
    mass                  = 0
    "height of the kite               [m]"
    height_k              = 0
    alpha_cl::Vector{Float64} = []
    cl_list::Vector{Float64}  = []
    alpha_cd::Vector{Float64} = []
    cd_list::Vector{Float64}  = []
    "relative side area               [%]"
    rel_side_area         = 0
    "max depower angle              [deg]"
    alpha_d_max           = 0
    "mass of the kite control unit   [kg]"
    kcu_mass              = 0
    "power to steering line distance  [m]"
    power2steer_dist      = 0
    depower_drum_diameter = 0
    depower_offset        = 0
    tape_thickness        = 0
    v_depower             = 0
    v_steering            = 0
    depower_gain          = 0
    steering_gain         = 0
    v_wind                = 0
    h_ref                 = 0
    rho_0                 = 0
    z0                    = 0
    profile_law::Int64    = 0
    alpha                 = 0
    cd_tether             = 0
    d_tether              = 0
    d_line                = 0
    "height of the bridle             [m]"
    height_b              = 0
    l_bridle              = 0
    l_tether              = 0
    damping               = 0
    c_spring              = 0
    elevation             = 0
    sim_time              = 0
end
const SETTINGS = Settings()

"""
    set_data_path(data_path)

Set the directory for log and config files.
"""
function set_data_path(data_path)
    DATA_PATH[1] = data_path
end

"""
    load_settings(project="")

Load the project with the given file name. The default project is determined by the content of the file system.yaml .

The project must include the path and the suffix .yaml .
"""
function load_settings(project="")
    SETTINGS.segments=0
    se(project)
end

"""
    copy_settings()

Copy the default settings.yaml and system.yaml files to the folder DATAPATH
(it will be created if it doesn't exist).
"""
function copy_settings()
    if ! isdir(DATA_PATH[1]) 
        mkdir(DATA_PATH[1])
    end
    src_path = joinpath(dirname(pathof(@__MODULE__)), "..", DATA_PATH[1])
    cp(joinpath(src_path, "settings.yaml"), joinpath(DATA_PATH[1], "settings.yaml"), force=true)
    cp(joinpath(src_path, "system.yaml"), joinpath(DATA_PATH[1], "system.yaml"), force=true)
end

"""
    se()

Getter function for the [`Settings`](@ref) struct.

The default project is determined by the content of the file system.yaml .
"""
function se(project="")
    if SETTINGS.segments == 0
        if project == ""
            # determine which project to load
            dict = YAML.load_file(joinpath(DATA_PATH[1], "system.yaml"))
            SETTINGS.project = dict["system"]["project"]
        end
        # load project from YAML
        dict = YAML.load_file(joinpath(DATA_PATH[1], SETTINGS.project))
        SETTINGS.log_file    = dict["system"]["log_file"]
        SETTINGS.segments    = dict["system"]["segments"]
        SETTINGS.sample_freq = dict["system"]["sample_freq"]
        SETTINGS.time_lapse  = dict["system"]["time_lapse"]
        SETTINGS.sim_time    = dict["system"]["sim_time"]
        SETTINGS.zoom        = dict["system"]["zoom"]
        SETTINGS.fixed_font  = dict["system"]["fixed_font"]

        SETTINGS.l_tether    = dict["initial"]["l_tether"]
        SETTINGS.v_reel_out  = dict["initial"]["v_reel_out"]
        SETTINGS.elevation   = dict["initial"]["elevation"]

        SETTINGS.c0          = dict["steering"]["c0"]
        SETTINGS.c_s         = dict["steering"]["c_s"]
        SETTINGS.c2_cor      = dict["steering"]["c2_cor"]
        SETTINGS.k_ds        = dict["steering"]["k_ds"]

        SETTINGS.alpha_d_max    = dict["depower"]["alpha_d_max"]
        SETTINGS.depower_offset = dict["depower"]["depower_offset"]

        SETTINGS.model         = dict["kite"]["model"]
        SETTINGS.area          = dict["kite"]["area"]
        SETTINGS.rel_side_area = dict["kite"]["rel_side_area"]
        SETTINGS.mass          = dict["kite"]["mass"]
        SETTINGS.height_k      = dict["kite"]["height"]
        SETTINGS.alpha_cl      = dict["kite"]["alpha_cl"]
        SETTINGS.cl_list       = dict["kite"]["cl_list"]
        SETTINGS.alpha_cd      = dict["kite"]["alpha_cd"]
        SETTINGS.cd_list       = dict["kite"]["cd_list"]

        SETTINGS.l_bridle      = dict["bridle"]["l_bridle"]
        SETTINGS.height_b      = dict["bridle"]["height"]
        SETTINGS.d_line        = dict["bridle"]["d_line"]

        SETTINGS.kcu_mass         = dict["kcu"]["mass"]
        SETTINGS.power2steer_dist = dict["kcu"]["power2steer_dist"]
        SETTINGS.depower_drum_diameter = dict["kcu"]["depower_drum_diameter"]

        SETTINGS.tape_thickness   = dict["kcu"]["tape_thickness"]
        SETTINGS.v_depower        = dict["kcu"]["v_depower"]
        SETTINGS.v_steering       = dict["kcu"]["v_steering"]
        SETTINGS.depower_gain     = dict["kcu"]["depower_gain"]
        SETTINGS.steering_gain    = dict["kcu"]["steering_gain"]

        SETTINGS.cd_tether   = dict["tether"]["cd_tether"]
        SETTINGS.d_tether    = dict["tether"]["d_tether"]
        SETTINGS.damping     = dict["tether"]["damping"]
        SETTINGS.c_spring    = dict["tether"]["c_spring"]

        SETTINGS.v_wind      = dict["environment"]["v_wind"]
        SETTINGS.h_ref       = dict["environment"]["h_ref"]
        SETTINGS.rho_0       = dict["environment"]["rho_0"]
        SETTINGS.z0          = dict["environment"]["z0"]
        SETTINGS.alpha       = dict["environment"]["alpha"]
        SETTINGS.profile_law = dict["environment"]["profile_law"]
    end
    return SETTINGS
end

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


"""
    ExtSysState{P}

Extended system state. Derived values for plotting. P is the number
of tether particles.

$(TYPEDFIELDS)
"""
struct ExtSysState{P}
    "time since launch in seconds"
    time::Float64
    "orientation of the kite"
    orient::QuatRotation{Float32}
    "vector of particle positions in x"
    X::MVector{P, MyFloat}
    "vector of particle positions in y"
    Y::MVector{P, MyFloat}
    "vector of particle positions in z"
    Z::MVector{P, MyFloat}
    "kite position in x"
    x::MyFloat
    "kite position in y"
    y::MyFloat
    "kite position in z"
    z::MyFloat
end

"""
    SysLog{P}

Flight log, containing the basic data as struct of arrays 
and in addition an extended view on the data that includes derived/ calculated values for plotting
finally meta data like the file name of the log file is included.

$(TYPEDFIELDS)
"""
struct SysLog{P}
    "name of the flight log"
    name::String
    "struct of vectors"
    syslog::StructArray{SysState{P}}
    "struct of vectors, containing derived values"
    extlog::StructArray{ExtSysState{P}}
end

# functions
function __init__()
    SETTINGS.segments=0 # force loading of settings.yaml
end

"""
    rot3d(ax, ay, az, bx, by, bz)

Calculate the rotation matrix that needs to be applied on the reference frame (ax, ay, az) to match 
the reference frame (bx, by, bz).
All parameters must be 3-element vectors. Both refrence frames must be orthogonal,
all vectors must already be normalized.

Source: [TRIAD_Algorithm](http://en.wikipedia.org/wiki/User:Snietfeld/TRIAD_Algorithm)
"""
function rot3d(ax, ay, az, bx, by, bz)
    R_ai = hcat(ax, az, ay)
    R_bi = hcat(bx, bz, by)
    return R_bi * R_ai'
end

"""
    rot(pos_kite, pos_before, v_app)

Calculate the rotation matrix of the kite based on the position of the
last two tether particles and the apparent wind speed vector.
"""
function rot(pos_kite, pos_before, v_app)
    delta = pos_kite - pos_before
    @assert norm(delta) > 0.0 "Error in function rot() ! pos_kite must be not equal to pos_before. "
    c = -delta
    z = normalize(c)
    y = normalize(cross(-v_app, c))
    x = normalize(cross(y, c))
    rot = rot3d([0,-1.0,0], [1.0,0,0], [0,0,-1.0], z, y, x)
end

"""
    function ground_dist(vec)

Calculate the ground distance of the kite from the groundstation based on the kite position (x,y,z, z up).
"""
function ground_dist(vec)
    sqrt(vec[1]^2 + vec[2]^2)
end 

"""
     function calc_elevation(vec)

Calculate the elevation angle in radian from the kite position. 
"""
function calc_elevation(vec)
    atan(vec[3] / ground_dist(vec))
end

"""
    function azimuth_east(vec)

Calculate the azimuth angle in radian from the kite position in ENU reference frame.
Zero east. Positive direction clockwise seen from above.
Valid range: -π .. π.
"""
function azimuth_east(vec)
    return -atan(vec[2], vec[1])
end

"""
    function demo_state(P, height=6.0, time=0.0)

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
    function demo_syslog(P, name="Test flight"; duration=10)

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
    function syslog2extlog(P, syslog)

Extend a flight systym log with the fields x, y, and z (kite positions) and convert the orientation to the type UnitQuaternion.
"""
function syslog2extlog(P, syslog)
    x_vec = @view VectorOfArray(syslog.X)[end,:]
    y_vec = @view VectorOfArray(syslog.Y)[end,:]
    z_vec = @view VectorOfArray(syslog.Z)[end,:]
    orient_vec = Vector{QuatRotation{Float32}}(undef, length(syslog.time))
    for i in range(1, length=length(syslog.time))
        orient_vec[i] = QuatRotation(syslog.orient[i])
    end
    return StructArray{ExtSysState{P}}((syslog.time, orient_vec, syslog.X, syslog.Y, syslog.Z, x_vec, y_vec, z_vec))    
end

"""
    function demo_log(P, name="Test_flight"; duration=10)

Create an artifical SysLog struct for demonstration purposes. P is the number of tether
particles.
"""
function demo_log(P, name="Test_flight"; duration=10)
    syslog = demo_syslog(P, name, duration=duration)
    return SysLog{P}(name, syslog, syslog2extlog(P, syslog))
end

"""
    function save_log(P, flight_log)

Save a fligh log file as .arrow file. P is the number of tether
particles.
"""
function save_log(P, flight_log)
    filename=joinpath(DATA_PATH[1], flight_log.name) * ".arrow"
    Arrow.write(filename, flight_log.syslog, compress=:lz4)
end

"""
    function load_log(P, filename::String)

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
    myzeros = zeros(MyFloat, length(table.time))
    syslog = StructArray{SysState{P}}((table.time, table.orient, table.elevation, table.azimuth, table.l_tether, table.v_reelout, table.force, table.depower, table.v_app, table.X, table.Y, table.Z))
    return SysLog{P}(basename(fullname[1:end-6]), syslog, syslog2extlog(P, syslog))
end

function test(save=false)
    if save
        log_to_save=demo_log(7)
        save_log(7, log_to_save)
    end
    return(load_log(7, "Test_flight.arrow"))
end

precompile(load_log, (Int64, String,))     

end
