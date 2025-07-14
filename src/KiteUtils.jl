# SPDX-FileCopyrightText: 2022 Uwe Fechner
# SPDX-License-Identifier: MIT

"""
    KiteUtils

Utility functions for the kite simulators.

This module provides data structures for the flight state and the flight log, 
functions for creating a demo flight state, demo flight log, loading and saving flight logs, 
functions for reading the settings, and helper functions for working with rotations.

See https://ufechner7.github.io/KiteUtils.jl/stable/ for more information.
"""
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
using Parameters, StructTypes, CSV, Parsers, Pkg
export Settings, SysState, SysLog, Logger, MyFloat

import Base.length
import ReferenceFrameRotations as RFR
export demo_state, demo_syslog, demo_log, load_log, save_log, export_log, import_log # functions for logging
export log!, syslog, length, euler2rot, menu
export demo_state_4p, initial_kite_ref_frame       # functions for four point kite model
export rot, rot3d, ground_dist, calc_elevation, azimuth_east, azimuth_north, asin2 
export acos2, wrap2pi, quat2euler, quat2viewer                           # geometric functions
export fromEG2W, fromENU2EG,fromW2SE, fromKS2EX, fromEX2EG               # reference frame transformations
export azn2azw, calc_heading_w, calc_heading, calc_course                # geometric functions
export calc_orient_rot, is_right_handed_orthonormal, enu2ned, ned2enu
export set_data_path, get_data_path, load_settings, copy_settings        # functions for reading and copying parameters
export se, se_dict, update_settings, wc_settings, fpc_settings, fpp_settings
export calculate_rotational_inertia
export AbstractKiteModel
export init!, next_step!, update_sys_state!, find_steady_state!

"""
    const MyFloat = Float32

Type used for position components and scalar SysState members.
"""
const MyFloat   = Float32           # type to use for position components and scalar SysState members  
const DATA_PATH = ["data"]          # path for log files and other data
const MVec3     = MVector{3, Float64}

function init! end
function next_step! end
function update_sys_state! end
function find_steady_state! end

"""
    abstract type AbstractKiteModel

All kite models must inherit from this type. All methods that are defined on this type must work
with all kite models, or a specific method has to be defined for the specific kite model. 
"""
abstract type AbstractKiteModel end

include("settings.jl")
include("yaml_utils.jl")
include("transformations.jl")
include("trafo.jl")

include("_sysstate.jl")

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

include("_show.jl")

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

function prepre_last(vec)
    vec[end-2]
end

"""
    Base.getproperty(log::SysLog, sym::Symbol)

Implement the properties x, y and z. They represent the kite position for the 4-point kite model.
In addition, implements the properties x1, y1 and z1. They represent the kite position for the 1-point model.
"""
function Base.getproperty(log::SysLog, sym::Symbol)
    if sym == :x
        prepre_last.(getproperty(log.syslog, :X))
    elseif sym == :x1
        last.(getproperty(log.syslog, :X))
    elseif sym == :y
        prepre_last.(getproperty(log.syslog, :Y))
    elseif sym == :y1
        last.(getproperty(log.syslog, :Y))
    elseif sym == :z
        prepre_last.(getproperty(log.syslog, :Z))
    elseif sym == :z1
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
    demo_state(P, height=6.0, time=0.0; azimuth_north=-pi/2)

Create a demo state with a given height and time. P is the number of tether particles.
Kite is parking and aligned with the tether.

Returns a SysState instance.
"""
function demo_state(P, height=6.0, time=0.0; azimuth_north=-pi/2)
    ss = SysState{P}()
    ss.time = time
    a = 10
    turn_angle = azimuth_north+pi/2
    dist = collect(range(0, stop=10, length=P))
    ss.X .= dist .* cos(turn_angle)
    ss.Y .= dist .* sin(turn_angle)
    ss.Z .= (a .* cosh.(dist./a) .- a) * height/ 5.430806 
    r_xyz = RotXYZ(pi/2, -pi/2, 0)
    q = QuatRotation(r_xyz)
    ss.orient .= MVector{4, Float32}(Rotations.params(q))
    ss.elevation = calc_elevation([ss.X[end], 0.0, ss.Z[end]])
    ss.v_wind_gnd .= [10.4855, 0, -3.08324]
    ss.v_wind_200m .= [10.4855, 0, -3.08324]
    ss.v_wind_kite .= [10.4855, 0, -3.08324]
    ss.t_sim = 0.012
    ss
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
    demo_state_4p(P, height=6.0, time=0.0; azimuth_north=-pi/2)

Create a demo state, using the 4 point kite model with a given height and time. P is the number of tether particles.

Returns a SysState instance.
"""
function demo_state_4p(P, height=6.0, time=0.0; azimuth_north=-pi/2)
    ss = SysState{P+4}()
    a = 10
    turn_angle = azimuth_north+pi/2
    dist = collect(range(0, stop=10, length=P))
    X = dist .* cos(turn_angle)
    Y = dist .* sin(turn_angle)
    v_app = [10*cos(turn_angle), 10*sin(turn_angle), 0]
    Z = (a .* cosh.(dist./a) .- a) * height/ 5.430806 
    # append the kite particles to X, Y and z
    pod_pos = [X[end], Y[end], Z[end]]
    vec_c = [X[end-2] - X[end-1], Y[end-2] - Y[end-1], Z[end-2] - Z[end-1]]  
    particles = get_particles(se().height_k, se().h_bridle, se().width, se().m_k, pod_pos, vec_c, v_app)[3:end]
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
    ss.X .= X
    ss.Y .= Y
    ss.Z .= Z
    pos_centre = 0.5 * (pos_C + pos_D)
    delta = pos_B - pos_centre
    z = -normalize(delta)
    y = normalize(pos_C - pos_D)
    x = y × z
    pos_kite_ = pod_pos
    pos_before = pos_kite_ + z
   
    rotation = rot(pos_kite_, pos_before, -x)
    q = QuatRotation(rotation)
    ss.orient .= MVector{4, Float32}(Rotations.params(q))
    ss.elevation = calc_elevation([X[end], 0.0, Z[end]])
    ss.v_wind_gnd = [10.4855, 0, -3.08324]
    ss.v_wind_200m = [10.4855, 0, -3.08324]
    ss.v_wind_kite = [10.4855, 0, -3.08324]
    ss.t_sim = 0.014
    ss
end

include("_demo_syslog.jl")

"""
    demo_log(P, name="Test_flight"; duration=10)

Create an artificial SysLog struct for demonstration purposes. P is the number of tether
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

include("load_log.jl")


"""
    calculate_rotational_inertia(X::Vector, Y::Vector, Z::Vector, M::Vector,  
          around_center_of_mass::Bool=true, rotation_point::Vector=[0, 0, 0])

Calculate the rotational inertia (Ixx, Ixy, Ixz, Iyy, Iyz, Izz) of a collection of point masses around a point. 
By default this point is the center of mass which will be calculated, but any point can be given to rotation_point.

Parameters:
- X: x-coordinates of the point masses.
- Y: y-coordinates of the point masses.
- Z: z-coordinates of the point masses.
- M: masses of the point masses.
- `around_center_of_mass`: Calculate the rotational inertia around the center of mass?
- `rotation_point`: Rotation point used if not rotating around the center of mass.

Returns:  
The tuple  Ixx, Ixy, Ixz, Iyy, Iyz, Izz where:
- Ixx: rotational inertia around the x-axis.
- Ixy: rotational inertia around the xy-plane.
- Ixz: rotational inertia around the xz-plane.
- Iyy: rotational inertia around the y-axis.
- Iyz: rotational inertia around the yz-plane.
- Izz: rotational inertia around the z-axis. 

"""
function calculate_rotational_inertia(X::Vector, Y::Vector, Z::Vector, M::Vector, around_center_of_mass::Bool=true, 
    rotation_point::Vector=[0, 0, 0])
    @assert size(X) == size(Y) == size(Z) == size(M)
    
    if around_center_of_mass
        # First loop to determine the center of mass
        x_com = y_com = z_com = m_total = 0.0
        for (x, y, z, m) in zip(X, Y, Z, M)
            x_com += x * m
            y_com += y * m
            z_com += z * m
            m_total += m 
        end

        x_com = x_com / m_total
        y_com = y_com / m_total
        z_com = z_com / m_total
    else
        x_com = rotation_point[begin]
        y_com = rotation_point[begin+1]
        z_com = rotation_point[begin+2]
    end

    Ixx = Ixy = Ixz = Iyy = Iyz = Izz = 0

    # Second loop using the distance between the point and the center of mass
    for (x, y, z, m) in zip(X .- x_com, Y .- y_com, Z .- z_com, M)
        Ixx += m * (y^2 + z^2)
        Iyy += m * (x^2 + z^2)
        Izz += m * (x^2 + y^2)

        Ixy += m * x * y
        Ixz += m * x * z
        Iyz += m * y * z
    end
    
    Ixx, Ixy, Ixz, Iyy, Iyz, Izz
end


function test(save=false)
    if save
        log_to_save=demo_log(7)
        save_log(log_to_save)
    end
    return(load_log(7, "Test_flight.arrow"))
end

function menu()
    Main.include("examples/menu.jl")
end

"""
    copy_examples()

Copy all example scripts to the folder "examples"
(it will be created if it doesn't exist).
"""
function copy_examples()
    PATH = "examples"
    if ! isdir(PATH) 
        mkdir(PATH)
    end
    src_path = joinpath(dirname(pathof(@__MODULE__)), "..", PATH)
    copy_files("examples", readdir(src_path))
end

function install_examples(add_packages=true)
    copy_examples()
    copy_settings(["transition.csv"])
    if add_packages
        Pkg.add("ControlPlots")
        Pkg.add("LaTeXStrings")
        Pkg.add("StatsBase")
    end
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
        try
            load_log(7, "Test_flight.arrow")
        catch
            test(true)
            load_log(7, "Test_flight.arrow")
        end
    end
end

end
