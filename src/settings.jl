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

"""
    Settings

Flat struct, defining the settings of the Simulator and the Viewer.

$(TYPEDFIELDS)
"""
@with_kw mutable struct Settings @deftype Float64
    "name of the yaml file with the settings"
    sim_settings::String       = ""

    "filename without extension  [replay only]"
    log_file::String      = ""
    "how many messages to print on the console, 0=none"
    log_level             = 2
    "relative replay speed"
    time_lapse            = 0
    "simulation time             [sim only]"
    sim_time              = 0
    "number of tether segments"
    segments::Int64       = 0
    "sample frequency in Hz"
    sample_freq::Int64    = 0
    "zoom factor for the system view"
    zoom                  = 0
    "relative zoom factor for the 4 point kite"
    kite_scale            = 1.0
    "name or filepath+filename of alternative fixed pitch font"
    fixed_font::String    = ""
    
    "initial tether length       [m]"
    l_tether              = 0
    "initial elevation angle                [deg]"
    elevation             = 0
    "initial reel out speed    [m/s]"
    v_reel_out            = 0
    "initial depower settings    [%]"
    depower               = 0

    "absolute tolerance of the DAE solver [m, m/s]"
    abs_tol               = 0.0
    "relative tolerance of the DAE solver [-]"
    rel_tol               = 0.0
    "DAE solver, can be IDA or DFBDF"
    solver::String        = "DFBDF"
    "can be GMRES or Dense"
    linear_solver::String = "GMRES"
    "maximal order, usually between 3 and 5"
    max_order::Int64      = 4
    "max number of iterations of the steady-state-solver"
    max_iter::Int64       = 1

    "steering offset   -0.0032           [-]"
    c0                    = 0
    "steering coefficient one point model"
    c_s                   = 0
    "correction factor one point model"
    c2_cor                = 0
    "influence of the depower angle on the steering sensitivity"
    k_ds                  = 0
    "steering increment (when pressing RIGHT)"
    delta_st              = 0
    "max. steering angle of the side planes for four point model [degrees]"
    max_steering          = 0

    "max depower angle              [deg]"
    alpha_d_max           = 0
    "at rel_depower=0.236 the kite is fully powered [%]"
    depower_offset        = 23.6

    "file name of the 3D model of the kite for the viewer"
    model::String         = "data/kite.obj"
    "name of the kite model to use (KPS3 or KPS4)"
    physical_model::String = ""
    "version of the model to use"
    version::Int64 = 1
    "kite mass incl. sensor unit     [kg]"
    mass                  = 0
    "projected kite area            [m^2]"
    area                  = 0
    "relative side area               [%]"
    rel_side_area         = 0
    "height of the kite               [m]"
    height_k              = 0
    alpha_cl::Vector{Float64} = []
    cl_list::Vector{Float64}  = []
    alpha_cd::Vector{Float64} = []
    cd_list::Vector{Float64}  = []

    "width of the kite                [m]"
    width                 = 0
    "should be 5                      [degrees]"
    alpha_zero            = 0
    alpha_ztip            = 0
    "relative nose distance; increasing m_k increases C2 of the turn-rate law"
    m_k                   = 0
    rel_nose_mass         = 0
    "mass of the top particle relative to the sum of top and side particles"
    rel_top_mass          = 0
    
    # model KPS4_3L
    "the radius of the circle shape on which the kite lines, viewed from the front [m]"
    radius::Float64 = 10.0
    "the distance from point the center bridle connection point of the middle line to the kite [m]"
    bridle_center_distance::Float64 = 2.0
    "the cord length of the kite in the middle [m]"
    middle_length::Float64 = 2.0
    "the cord length of the kite at the tips [m]"
    tip_length::Float64 = 1.0
    "the distance between the left and right steering bridle line connections on the kite that are closest to eachother [m]"
    min_steering_line_distance::Float64 = 4.0 
    "the number of aerodynamic surfaces to use per mass point [-]"
    aero_surfaces::Int64 = 10
    "the width of the 3 line kite laid flat"
    width_3l = 20

    "bridle line diameter                  [mm]"
    d_line                = 0
    "height of the bridle                    [m]"
    h_bridle              = 0
    "sum of the lengths of the bridle lines [m]"
    l_bridle              = 0
    "relative compression stiffness of the kite springs"
    rel_compr_stiffness   = 0 
    "relative damping of the kite spring (relative to main tether)"
    rel_damping           = 0         

    "mass of the kite control unit   [kg]"
    kcu_mass              = 0
    "power to steering line distance  [m]"
    power2steer_dist      = 0
    depower_drum_diameter = 0
    tape_thickness        = 0
    "max velocity of depowering in units per second (full range: 1 unit)"
    v_depower             = 0
    "max velocity of steering in units per second   (full range: 2 units)"
    v_steering            = 0
    "3.0 means: more than 33% error -> full speed"
    depower_gain          = 3.0
    steering_gain         = 3.0

    "tether diameter                 [mm]"
    d_tether              = 0
    "drag coefficient of the tether"
    cd_tether             = 0
    "unit damping coefficient        [Ns]"
    damping               = 0
    "unit spring constant coefficient [N]"
    c_spring              = 0
    "density of Dyneema                   [kg/m³]"
    rho_tether            = 0
    "axial tensile modulus of the tether     [Pa]"
    e_tether              = 0

    "maximal (nominal) tether force; short overload allowed [N]"
    max_force             = 4000
    "maximal reel-out speed                      [m/s]"
    v_ro_max              = 8
    "minimal reel-out speed (=max reel-in speed) [m/s]"
    v_ro_min              = -8

    "wind speed at reference height          [m/s]"
    v_wind                = 0
    "wind speed vector at reference height   [m/s]"
    v_wind_ref::Vector{Float64} = [] # wind speed vector at reference height
    "temperature at reference height         [°C]"
    temp_ref              = 0
    "height of groundstation above see level  [m]"
    height_gnd            = 0
    " reference height for the wind speed     [m]"
    h_ref                 = 0
    "air density at zero height and 15 °C    [kg/m³]"
    rho_0                 = 0
    "exponent of the wind profile law"
    alpha                 = 0
    "surface roughness                       [m]"
    z0                    = 0
    "1=EXP, 2=LOG, 3=EXPLOG, 4=FAST_EXP, 5=FAST_LOG, 6=FAST_EXPLOG"
    profile_law::Int64    = 0
    "turbulence intensity relative to Cabau, NL"
    use_turbulence        = 0
    "wind speeds at ref height for calculating the turbulent wind field [m/s]"
    v_wind_gnds::Vector{Float64} = []
    "average height during reel out           [m]"
    avg_height            = 0
    "relative turbulence at the v_wind_gnds"
    rel_turbs::Vector{Float64} = []
    "the expected value of the turbulence intensity at 15 m/s"
    i_ref                 = 0
    "five times the average wind speed in m/s at hub height over the full year    [m/s]"
    v_ref                 = 0
    "grid resolution in z direction                                                 [m]"
    height_step           = 0 
    "grid resolution in x and y direction                                           [m]"
    grid_step             = 0
end
StructTypes.StructType(::Type{Settings}) = StructTypes.Mutable()
const SETTINGS = Settings()
PROJECT::String = "system.yaml"

"""
    set_data_path(data_path="")

Set the directory for log and config files.

If called without argument, use the data path of the package to obtain the default settings
when calling se(). 
"""
function set_data_path(data_path="")
    if data_path==""
        data_path = joinpath(dirname(dirname(pathof(KiteUtils))), "data")
    end
    if data_path != DATA_PATH[1]
        DATA_PATH[1] = data_path
        SETTINGS.segments == 0 # enforce reloading of settings.yaml
    end
end

function get_data_path()
    return DATA_PATH[1]
end

"""
    load_settings(project=PROJECT)

Load the project with the given file name.

The project must include the path and the suffix .yaml .
"""
function load_settings(project=PROJECT)
    SETTINGS.segments=0
    se(project)
end

"""
    update_settings()

Re-read the settings from a previously loaded project. Returns the new settings.
"""
function update_settings()
    load_settings(PROJECT)
end

"""
    copy_settings()

Copy the default settings.yaml and system.yaml files to the folder DATAPATH
(it will be created if it doesn't exist).
"""
function copy_settings()
    src_path = abspath(joinpath(dirname(pathof(KiteUtils)), "..", "data"))
    if src_path == abspath(DATA_PATH[1])
        DATA_PATH[1] = joinpath(pwd(), "data")
    end
    if ! isdir(DATA_PATH[1]) 
        mkdir(DATA_PATH[1])
    end
    cp(joinpath(src_path, "settings.yaml"), joinpath(DATA_PATH[1], "settings.yaml"), force=true)
    cp(joinpath(src_path, "system.yaml"), joinpath(DATA_PATH[1], "system.yaml"), force=true)
    cp(joinpath(src_path, "kite.obj"), joinpath(DATA_PATH[1], "kite.obj"), force=true)
    chmod(joinpath(DATA_PATH[1], "settings.yaml"), 0o664)
    chmod(joinpath(DATA_PATH[1], "system.yaml"), 0o664)
    chmod(joinpath(DATA_PATH[1], "kite.obj"), 0o664)
    set_data_path(joinpath(pwd(), "data"))
    # set font
    if Sys.islinux()
        settings = joinpath(DATA_PATH[1], "settings.yaml")
        lines = readfile(settings)
        lines = change_value(lines, "fixed_font:", "\"Liberation Mono\"")
        writefile(lines, settings)
    end
    println("Copied 3 files to $(DATA_PATH[1]) !")
end

function update_settings(dict, sections)
    result = Dict{Symbol, Any}()
    for section in sections
        sec_dict = Dict(Symbol(k) => v for (k, v) in dict[section])
        merge!(result, sec_dict)
    end
    StructTypes.constructfrom!(SETTINGS, result)
end

function wc_settings(project=PROJECT)
    # determine which wc_settings to load
    dict = YAML.load_file(joinpath(DATA_PATH[1], project))
    dict["system"]["wc_settings"]
end

function fpc_settings(project=PROJECT)
    # determine which fpc_settings to load
    dict = YAML.load_file(joinpath(DATA_PATH[1], project))
    dict["system"]["fpc_settings"]
end

function fpp_settings(project=PROJECT)
    # determine which fpc_settings to load
    dict = YAML.load_file(joinpath(DATA_PATH[1], project))
    dict["system"]["fpp_settings"]
end

"""
    se(project="system.yaml")

Getter function for the [`Settings`](@ref) struct.

The settings.yaml file to load is determined by the content of the file system.yaml .
"""
function se(project="system.yaml")
    global SE_DICT, PROJECT
    if SETTINGS.segments == 0
        # determine which sim_settings to load
        dict = YAML.load_file(joinpath(DATA_PATH[1], basename(project)))
        PROJECT = basename(project)
        try
            SETTINGS.sim_settings = dict["system"]["sim_settings"]
        catch
            SETTINGS.sim_settings = dict["system"]["project"]
            println("Warning! Key sim_settings not found in $project .")
        end
        # load sim_settings from YAML
        dict = YAML.load_file(joinpath(DATA_PATH[1], SETTINGS.sim_settings))
        SE_DICT[1] = dict
        # update the SETTINGS struct from the dictionary
        update_settings(dict, ["system", "initial", "solver", "steering", "depower", "kite", "kps4", "kps4_3l", "bridle", 
                               "kcu", "tether", "winch", "environment"])
        tmp = split(dict["system"]["log_file"], "/")
        SETTINGS.log_file    = joinpath(tmp[1], tmp[2])
        SETTINGS.height_k      = dict["kite"]["height"] 
    end
    return SETTINGS
end
"""
    se_dict()

Getter function for the dictionary, representing the settings.yaml file.

Access to the dict is much slower than access to the setting struct, but more flexible.

Usage example:
`z0 = se_dict()["environment"]["z0"]`
"""
function se_dict()
    if SETTINGS.segments == 0
        se()
    end
    SE_DICT[1]
end
