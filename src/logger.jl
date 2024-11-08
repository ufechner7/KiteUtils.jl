include("_logger.jl")
function Logger(P, steps)
    Logger{P, steps}()
end

include("_log.jl")

function length(logger::Logger)
    logger.index - 1
end

include("_syslog.jl")

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

include("_save_log.jl")

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