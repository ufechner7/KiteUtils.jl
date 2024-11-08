include("_logger.jl")
function Logger(P, steps)
    Logger{P, steps}()
end

"""
    log!(logger::Logger, state::SysState)

Log a state in a logger object. Do nothing if the preallocated size would be exceeded.
Returns the current number of elements of the log.
"""
function log!(logger::Logger, state::SysState)
    i = logger.index
    if i > length(logger.time_vec)
        return length(logger.time_vec)
    end
    logger.time_vec[i] = state.time
    logger.t_sim_vec[i] = state.t_sim
    logger.sys_state_vec[i] = state.sys_state
    logger.e_mech_vec[i] = state.e_mech
    logger.orient_vec[i] .= state.orient
    logger.elevation_vec[i] = state.elevation
    logger.azimuth_vec[i] = state.azimuth
    logger.l_tether_vec[i] = state.l_tether
    logger.v_reelout_vec[i] = state.v_reelout
    logger.force_vec[i] = state.force
    logger.depower_vec[i] = state.depower
    logger.steering_vec[i] = state.steering
    logger.heading_vec[i] = state.heading
    logger.course_vec[i] = state.course
    logger.v_app_vec[i] = state.v_app
    logger.v_wind_gnd_vec[i] .= state.v_wind_gnd
    logger.v_wind_200m_vec[i] .= state.v_wind_200m
    logger.v_wind_kite_vec[i] .= state.v_wind_kite
    logger.vel_kite_vec[i] .= state.vel_kite
    logger.x_vec[i] .= state.X
    logger.y_vec[i] .= state.Y
    logger.z_vec[i] .= state.Z
    logger.var_01_vec[i] = state.var_01
    logger.var_02_vec[i] = state.var_02
    logger.var_03_vec[i] = state.var_03
    logger.var_04_vec[i] = state.var_04
    logger.var_05_vec[i] = state.var_05
    logger.var_06_vec[i] = state.var_06
    logger.var_07_vec[i] = state.var_07
    logger.var_08_vec[i] = state.var_08
    logger.var_09_vec[i] = state.var_09
    logger.var_10_vec[i] = state.var_10
    logger.var_11_vec[i] = state.var_11
    logger.var_12_vec[i] = state.var_12
    logger.var_13_vec[i] = state.var_13
    logger.var_14_vec[i] = state.var_14
    logger.var_15_vec[i] = state.var_15
    logger.var_16_vec[i] = state.var_16
    logger.index+=1
    return i
end

function length(logger::Logger)
    logger.index - 1
end

function syslog(logger::Logger)
    l = logger
    StructArray{SysState{l.points}}((l.time_vec, l.t_sim_vec, l.sys_state_vec, l.e_mech_vec, l.orient_vec, 
                l.elevation_vec, l.azimuth_vec, l.l_tether_vec,
                l.v_reelout_vec, l.force_vec, l.depower_vec, l.steering_vec, l.heading_vec, l.course_vec,
                l.v_app_vec, l.v_wind_gnd_vec, l.v_wind_200m_vec, l.v_wind_kite_vec, 
                l.vel_kite_vec, l.x_vec, l.y_vec, l.z_vec, l.var_01_vec, l.var_02_vec, l.var_03_vec, 
                l.var_04_vec, l.var_05_vec, l.var_06_vec, l.var_07_vec, l.var_08_vec, l.var_09_vec, l.var_10_vec,
                l.var_11_vec, l.var_12_vec, l.var_13_vec, l.var_14_vec, l.var_15_vec, l.var_16_vec))
end

"""
    sys_log(logger::Logger, name="sim_log";
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

Converts the data of a Logger object into a SysLog object, containing a StructArray, a name
and the column meta data.
"""
function sys_log(logger::Logger, name="sim_log"; 
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
    SysLog{logger.points}(name, colmeta, syslog(logger))
end

"""
    save_log(logger::Logger, name="sim_log", compress=true;
                path="",
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

Save a fligh log from a logger as .arrow file. By default lz4 compression is used, 
if you use **false** as second parameter no compression is used.
"""
function save_log(logger::Logger, name="sim_log", compress=true;
    path="",
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
    nl = length(logger)
    resize!(logger.time_vec, nl)
    resize!(logger.t_sim_vec, nl)
    resize!(logger.sys_state_vec, nl)
    resize!(logger.e_mech_vec, nl)
    resize!(logger.orient_vec, nl)
    resize!(logger.elevation_vec, nl)
    resize!(logger.azimuth_vec, nl)
    resize!(logger.l_tether_vec, nl)
    resize!(logger.v_reelout_vec, nl)
    resize!(logger.force_vec, nl)
    resize!(logger.depower_vec, nl)
    resize!(logger.steering_vec, nl)
    resize!(logger.heading_vec, nl)
    resize!(logger.course_vec, nl)
    resize!(logger.v_app_vec, nl)
    resize!(logger.v_wind_gnd_vec, nl)
    resize!(logger.v_wind_200m_vec, nl)
    resize!(logger.v_wind_kite_vec, nl)
    resize!(logger.vel_kite_vec, nl)
    resize!(logger.x_vec, nl)
    resize!(logger.y_vec, nl)
    resize!(logger.z_vec, nl)
    resize!(logger.var_01_vec, nl)
    resize!(logger.var_02_vec, nl)
    resize!(logger.var_03_vec, nl)
    resize!(logger.var_04_vec, nl)
    resize!(logger.var_05_vec, nl)
    resize!(logger.var_06_vec, nl)
    resize!(logger.var_07_vec, nl)
    resize!(logger.var_08_vec, nl)
    resize!(logger.var_09_vec, nl)
    resize!(logger.var_10_vec, nl)
    resize!(logger.var_11_vec, nl)
    resize!(logger.var_12_vec, nl)
    resize!(logger.var_13_vec, nl)
    resize!(logger.var_14_vec, nl)
    resize!(logger.var_15_vec, nl)
    resize!(logger.var_16_vec, nl)
    flight_log = (sys_log(logger, name; colmeta))
    save_log(flight_log, compress; path)
end

function parse_vector(str)
    m = match(r"\[(.*)\]", str)
    strs = split(m[1], ','; keepempty=false)
    Parsers.parse.(Float32, strs)
end

function import_log_(filename::String; path="")
    if path == ""
        path = DATA_PATH[1]
    end
    filename = joinpath(path, filename) * ".csv"
    return (CSV.File(filename))
end

"""
    import_log(filename)

Read a .csv file with a flight log and return a SysLog object.
The columns `var_01` to `var_05` must exists, the rest are optional.

Parameters:
- filename: name of the file without extension.
"""
function import_log(filename)
    lg = import_log_(filename)
    X = parse_vector(lg[1].X)
    P = length(X)
    logger = Logger(P, length(lg))

    for (i,row) in pairs(lg)
        local X
        X = parse_vector(row.X)
        Y = parse_vector(row.Y)
        Z = parse_vector(row.Z)

        orient = parse_vector(row.orient)
        v_wind_gnd = zeros(Float32, 3)
        v_wind_200m = zeros(Float32, 3)
        v_wind_kite = zeros(Float32, 3)
        vel_kite = parse_vector(row.vel_kite)
        ss = SysState{P}(row.time, row.t_sim, row.sys_state, row.e_mech, orient, row.elevation, row.azimuth, row.l_tether,
                        row.v_reelout, row.force, row.depower, row.steering, row.heading, row.course, row.v_app,
                        v_wind_gnd, v_wind_200m, v_wind_kite,
                        vel_kite, X, Y, Z, row.var_01, row.var_02, row.var_03, row.var_04, row.var_05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        log!(logger, ss)
    end
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
    )
    SysLog{P}(filename, colmeta, syslog(logger))
end