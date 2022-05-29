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
    project::String       = ""
    log_file::String      = ""
    "file name of the 3D model of the kite for the viewer"
    model::String         = ""
    "name of the kite model to use (KPS3 or KPS4)"
    physical_model::String = ""
    version::Int64 = 1
    "number of tether segments"
    segments::Int64       = 0
    sample_freq::Int64    = 0
    time_lapse            = 0
    zoom                  = 0
    kite_scale            = 1.0
    fixed_font::String    = ""
    abs_tol               = 0.0
    rel_tol               = 0.0
    linear_solver::String = "GMRES"
    max_order::Int64      = 4
    max_iter::Int64       = 1
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
    "width of the kite                [m]"
    width                 = 0
    alpha_zero            = 0
    alpha_ztip            = 0
    "relative nose distance; increasing m_k increases C2 of the turn-rate law"
    m_k                   = 0
    rel_nose_mass         = 0
    "mass of the top particle relative to the sum of top and side particles"
    rel_top_mass          = 0
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
    v_wind_ref::Vector{Float64} = [] # wind speed vector at reference height
    h_ref                 = 0
    rho_0                 = 0
    z0                    = 0
    profile_law::Int64    = 0
    alpha                 = 0
    cd_tether             = 0
    d_tether              = 0
    d_line                = 0
    "height of the bridle                    [m]"
    h_bridle              = 0
    l_bridle              = 0
    l_tether              = 0
    damping               = 0
    c_spring              = 0
    "density of Dyneema                   [kg/m³]"
    rho_tether            = 0
    "axial tensile modulus of the tether     [Pa]"
    e_tether              = 0
    "initial elevation angle                [deg]"
    elevation             = 0
    "simulation time                   [sim only]"
    depower               = 0
    sim_time              = 0
    "temperature at reference height         [°C]"
    temp_ref              = 0
    "height of groundstation above see level  [m]"
    height_gnd            = 0
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
const SETTINGS = Settings()

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
    load_settings(project="")

Load the project with the given file name. The default project is determined by the content of the file system.yaml .

The project must include the path and the suffix .yaml .
"""
function load_settings(project="")
    SETTINGS.segments=0
    se(project)
end

"""
    update_settings()

Re-read the settings from a previously loaded project. Returns the new settings.
"""
function update_settings()
    load_settings(SETTINGS.project)
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
    cp(joinpath(src_path, "kite.obj"), joinpath(DATA_PATH[1], "kite.obj"), force=true)
    chmod(joinpath(DATA_PATH[1], "settings.yaml"), 0o664)
    chmod(joinpath(DATA_PATH[1], "system.yaml"), 0o664)
    chmod(joinpath(DATA_PATH[1], "kite.obj"), 0o664)
end

"""
    se()

Getter function for the [`Settings`](@ref) struct.

The default project is determined by the content of the file system.yaml .
"""
function se(project="")
    global SE_DICT
    if SETTINGS.segments == 0
        if project == ""
            # determine which project to load
            dict = YAML.load_file(joinpath(DATA_PATH[1], "system.yaml"))
            SETTINGS.project = dict["system"]["project"]
        end
        # load project from YAML
        dict = YAML.load_file(joinpath(DATA_PATH[1], SETTINGS.project))
        SE_DICT[1] = dict
        tmp = split(dict["system"]["log_file"], "/")
        SETTINGS.log_file    = joinpath(tmp[1], tmp[2])
        SETTINGS.segments    = dict["system"]["segments"]
        SETTINGS.sample_freq = dict["system"]["sample_freq"]
        SETTINGS.time_lapse  = dict["system"]["time_lapse"]
        SETTINGS.sim_time    = dict["system"]["sim_time"]
        SETTINGS.zoom        = dict["system"]["zoom"]
        SETTINGS.kite_scale  = dict["system"]["kite_scale"]
        SETTINGS.fixed_font  = dict["system"]["fixed_font"]

        SETTINGS.l_tether    = dict["initial"]["l_tether"]
        SETTINGS.v_reel_out  = dict["initial"]["v_reel_out"]
        SETTINGS.elevation   = dict["initial"]["elevation"]
        SETTINGS.depower     = dict["initial"]["depower"]

        SETTINGS.abs_tol     = dict["solver"]["abs_tol"]
        SETTINGS.rel_tol     = dict["solver"]["rel_tol"]
        SETTINGS.linear_solver = dict["solver"]["linear_solver"]
        SETTINGS.max_order   = dict["solver"]["max_order"]
        SETTINGS.max_iter    = dict["solver"]["max_iter"]

        SETTINGS.c0          = dict["steering"]["c0"]
        SETTINGS.c_s         = dict["steering"]["c_s"]
        SETTINGS.c2_cor      = dict["steering"]["c2_cor"]
        SETTINGS.k_ds        = dict["steering"]["k_ds"]

        SETTINGS.alpha_d_max    = dict["depower"]["alpha_d_max"]
        SETTINGS.depower_offset = dict["depower"]["depower_offset"]

        SETTINGS.model         = dict["kite"]["model"]
        SETTINGS.physical_model= dict["kite"]["physical_model"]
        SETTINGS.version       = dict["kite"]["version"]
        SETTINGS.area          = dict["kite"]["area"]
        SETTINGS.rel_side_area = dict["kite"]["rel_side_area"]
        SETTINGS.mass          = dict["kite"]["mass"]
        SETTINGS.height_k      = dict["kite"]["height"]
        SETTINGS.alpha_cl      = dict["kite"]["alpha_cl"]
        SETTINGS.cl_list       = dict["kite"]["cl_list"]
        SETTINGS.alpha_cd      = dict["kite"]["alpha_cd"]
        SETTINGS.cd_list       = dict["kite"]["cd_list"]

        SETTINGS.width         = dict["kps4"]["width"]
        SETTINGS.alpha_zero    = dict["kps4"]["alpha_zero"]
        SETTINGS.alpha_ztip    = dict["kps4"]["alpha_ztip"]
        SETTINGS.m_k           = dict["kps4"]["m_k"]
        SETTINGS.rel_nose_mass = dict["kps4"]["rel_nose_mass"]
        SETTINGS.rel_top_mass  = dict["kps4"]["rel_top_mass"]

        SETTINGS.l_bridle      = dict["bridle"]["l_bridle"]
        SETTINGS.h_bridle      = dict["bridle"]["h_bridle"]
        SETTINGS.d_line        = dict["bridle"]["d_line"]

        SETTINGS.kcu_mass         = dict["kcu"]["kcu_mass"]
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
        SETTINGS.rho_tether  = dict["tether"]["rho_tether"]
        SETTINGS.e_tether    = dict["tether"]["e_tether"]

        SETTINGS.v_wind      = dict["environment"]["v_wind"]
        SETTINGS.v_wind_ref  = dict["environment"]["v_wind_ref"]
        SETTINGS.h_ref       = dict["environment"]["h_ref"]
        SETTINGS.rho_0       = dict["environment"]["rho_0"]
        SETTINGS.z0          = dict["environment"]["z0"]
        SETTINGS.alpha       = dict["environment"]["alpha"]
        SETTINGS.profile_law = dict["environment"]["profile_law"]
        SETTINGS.temp_ref    = dict["environment"]["temp_ref"]            # temperature at reference height         [°C]
        SETTINGS.height_gnd  = dict["environment"]["height_gnd"]          # height of groundstation above see level [m]
        SETTINGS.use_turbulence = dict["environment"]["use_turbulence"]   # turbulence intensity relative to Cabau, NL
        SETTINGS.v_wind_gnds = dict["environment"]["v_wind_gnds"]         # wind speeds at ref height for calculating the turbulent wind field [m/s]
        SETTINGS.avg_height  = dict["environment"]["avg_height"]          # average height during reel out          [m]
        SETTINGS.rel_turbs   = dict["environment"]["rel_turbs"]           # relative turbulence at the v_wind_gnds
        SETTINGS.i_ref       = dict["environment"]["i_ref"]               # is the expected value of the turbulence intensity at 15 m/s.
        SETTINGS.v_ref       = dict["environment"]["v_ref"]               # five times the average wind speed in m/s at hub height over the full year    [m/s]
                                                                          # Cabau: 8.5863 m/s * 5.0 = 42.9 m/s
        SETTINGS.height_step = dict["environment"]["height_step"]         # use a grid with 2m resolution in z direction                                 [m]
        SETTINGS.grid_step   = dict["environment"]["grid_step"]           # grid resolution in x and y direction                                         [m]  
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
