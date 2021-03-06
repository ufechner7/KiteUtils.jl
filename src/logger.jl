"""
    mutable struct Logger{P}

Struct to store a simulation log. P is number of points of the tether, segments+1.

$(TYPEDFIELDS)
"""
@with_kw mutable struct Logger{P, Q}
    points::Int64 = P
    index::Int64 = 1
    time_vec::Vector{Float64} = zeros(MyFloat, Q)
    orient_vec::Vector{MVector{4, Float32}} = zeros(SVector{4, Float32}, Q)
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
    vel_kite_vec::Vector{MVector{3, MyFloat}} = zeros(SVector{3, MyFloat}, Q)
    x_vec::Vector{MVector{P, MyFloat}} = zeros(SVector{P, MyFloat}, Q)
    y_vec::Vector{MVector{P, MyFloat}} = zeros(SVector{P, MyFloat}, Q)
    z_vec::Vector{MVector{P, MyFloat}} = zeros(SVector{P, MyFloat}, Q)
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
    logger.vel_kite_vec[i] .= state.vel_kite
    logger.x_vec[i] .= state.X
    logger.y_vec[i] .= state.Y
    logger.z_vec[i] .= state.Z
    logger.index+=1
    return i
end

function length(logger::Logger)
    logger.index - 1
end

function syslog(logger::Logger)
    l = logger
    StructArray{SysState{l.points}}((l.time_vec, l.orient_vec, l.elevation_vec, l.azimuth_vec, l.l_tether_vec,
                l.v_reelout_vec, l.force_vec, l.depower_vec, l.steering_vec, l.heading_vec, l.course_vec,
                l.v_app_vec, l.vel_kite_vec, l.x_vec, l.y_vec, l.z_vec))
end

"""
    sys_log(logger::Logger, name="sim_log")

Converts the data of a Logger object into a SysLog object, containing a StructArray and a name.
"""
function sys_log(logger::Logger, name="sim_log")
    SysLog{logger.points}(name, syslog(logger))
end

"""
    Logger(P, steps)

Creates a Logger object for kite power systems with `P point masses which can store up to `steps` number of time steps.
"""
function Logger(P, steps)
    logger = Logger{P, steps}()
    logger
end

"""
    save_log(logger::Logger, name="sim_log", compress=true)

Save a fligh log from a logger as .arrow file. By default lz4 compression is used, 
if you use **false** as second parameter no compression is used.
"""
function save_log(logger::Logger, name="sim_log", compress=true)
    nl = length(logger)
    resize!(logger.time_vec, nl)
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
    resize!(logger.vel_kite_vec, nl)
    resize!(logger.x_vec, nl)
    resize!(logger.y_vec, nl)
    resize!(logger.z_vec, nl)
    flight_log = (sys_log(logger, name))
    save_log(flight_log, compress)
end