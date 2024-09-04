using KiteUtils

set_data_path("data")
filename="transition"
P = 11 # number of particles; 

function parse_vector(str)
    m = match(r"\[(.*)\]", str)
    strs = split(m[1], ','; keepempty=false)
    parse.(Float32, strs)
end

function d_state(P, height=6.0, time=0.0)
    a = 10
    X = range(0, stop=10, length=P)
    Y = zeros(length(X))
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

lg = import_log(filename)

for (i,row) in pairs(lg)
    local P
    X = parse_vector(row.X)
    Y = parse_vector(row.Y)
    Z = parse_vector(row.Z)
    P = length(X)
    orient = parse_vector(row.orient)
    vel_kite = parse_vector(row.vel_kite)
    ss = SysState{P}(row.time, row.t_sim, row.sys_state, row.e_mech, orient, row.elevation, row.azimuth, row.l_tether,
                     row.v_reelout, row.force, row.depower, row.steering, row.heading, row.course, row.v_app,
                     vel_kite, X, Y, Z, row.var_01, row.var_02, row.var_03, row.var_04, row.var_05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    if i == 1
        println(ss)
        break
    end
end