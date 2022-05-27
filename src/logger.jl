"""
    mutable struct Logger{P}

Struct to store a simulation log. P is number of points of the tether, segments+1.

$(TYPEDFIELDS)
"""
@with_kw mutable struct Logger{P}
    points::Int64 = P
    time_vec::Vector{Float64} = []
    orient_vec::Vector{MVector{4, Float32}} = []
    elevation_vec::Vector{MyFloat} = []
    azimuth_vec::Vector{MyFloat} = []
    l_tether_vec::Vector{MyFloat} = []
    v_reelout_vec::Vector{MyFloat} = []
    force_vec::Vector{MyFloat} = []
    depower_vec::Vector{MyFloat} = []
    steering_vec::Vector{MyFloat} = []
    heading_vec::Vector{MyFloat} = []
    course_vec::Vector{MyFloat} = []
    v_app_vec::Vector{MyFloat} = []
    vel_kite_vec::Vector{MVector{3, MyFloat}} = []
    x_vec::Vector{MVector{P, MyFloat}} = []
    y_vec::Vector{MVector{P, MyFloat}} = []
    z_vec::Vector{MVector{P, MyFloat}} = []
end

"""
    log!(logger::Logger, state::SysState)

Log a state in a logger object.
"""
function log!(logger::Logger, state::SysState)
    push!(logger.time_vec, state.time)
    push!(logger.orient_vec, state.orient)
    push!(logger.elevation_vec, state.elevation)
    push!(logger.azimuth_vec, state.azimuth)
    push!(logger.l_tether_vec, state.l_tether)
    push!(logger.v_reelout_vec, state.v_reelout)
    push!(logger.force_vec, state.force)
    push!(logger.depower_vec, state.depower)
    push!(logger.steering_vec, state.steering)
    push!(logger.heading_vec, state.heading)
    push!(logger.course_vec, state.course)
    push!(logger.v_app_vec, state.v_app)
    push!(logger.vel_kite_vec, state.vel_kite)
    push!(logger.x_vec, state.X)
    push!(logger.y_vec, state.Y)
    push!(logger.z_vec, state.Z)
    nothing
end

function syslog(logger::Logger)
    l = logger
    StructArray{SysState{l.points}}((l.time_vec, l.orient_vec, l.elevation_vec, l.azimuth_vec, l.l_tether_vec,
                l.v_reelout_vec, l.force_vec, l.depower_vec, l.steering_vec, l.heading_vec, l.course_vec,
                l.v_app_vec, l.vel_kite_vec, l.x_vec, l.y_vec, l.z_vec))
end

function sys_log(logger::Logger, name="sim_log")
    SysLog{logger.points}(name, syslog(logger))
end

function Logger(P)
    Logger{P}()
end

"""
    save_log(logger::Logger, name="sim_log", compress=true)

Save a fligh log from a logger as .arrow file. By default lz4 compression is used, 
if you use **false** as second parameter no compression is used.
"""
function save_log(logger::Logger, name="sim_log", compress=true)
    flight_log = (sys_log(logger, name))
    save_log(flight_log, compress)
end