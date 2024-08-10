using KiteUtils, StaticArrays
using Test

cd("..")

@testset "KiteUtils.jl: Settings       " begin
    @test se().sim_settings == "settings.yaml"
    @test se().log_file == joinpath("data", "log_8700W_8ms")
    @test se().time_lapse == 1.0
    @test se().sim_time == 409.0
    @test se().log_level == 2
    @test se().kcu_model == "KCU1"
    @test length(se().alpha_cl) == 12
    set_data_path(tempdir())
    @test KiteUtils.DATA_PATH[1] == tempdir()
    set_data_path("data")
    set2 = load_settings(joinpath("data", "system.yaml"))
    @test set2.sim_settings == "settings.yaml"
    @test se_dict()["environment"]["z0"] == se().z0
    set3 = update_settings()
    @test set3 == se()
end
@testset "KiteUtils.jl: Settings2      " begin
    set = se("system2.yaml")
    @test set.sim_settings == "settings2.yaml"
    @test set.kcu_model == "KCU2"
    @test set.kcu_mass == 15.0
    @test set.kcu_diameter == 0.4
    @test set.depower_zero == 38.0
    @test set.degrees_per_percent_power == 1.0
    @test set.v_depower == 0.053
    @test set.v_steering == 0.212
end

@testset "KiteUtils.jl: Copy           " begin
    datapath = get_data_path()
    tmpdir = joinpath(mktempdir(), "data")
    oldir = pwd()
    cd(dirname(tmpdir))
    set_data_path(tmpdir)
    @test get_data_path() == tmpdir
    copy_settings()
    @test isfile(joinpath(tmpdir, "settings.yaml"))
    @test isfile(joinpath(tmpdir, "system.yaml"))
    cd(oldir)
    set_data_path(datapath)
end

@testset "KiteUtils.jl: system.yaml    " begin
    @test wc_settings() == "wc_settings.yaml"
    @test fpc_settings() == "fpc_settings.yaml"
    @test fpp_settings() == "fpp_settings.yaml"
end

@testset "KiteUtils.jl: Log files      " begin
    state = KiteUtils.demo_state(7)
    @test typeof(state) == SysState{7}
    @test state.X[end] == 10.0
    @test all(state.pos[end] .≈ [10, 0, 6.0])
    @test repr(state) == "time      [s]:       0.0\nt_sim     [s]:       0.012\nsys_state    :       0\ne_mech    [Wh]:      0.0\norient    [w,x,y,z]: Float32[0.5, 0.5, -0.5, -0.5]\nelevation [rad]:     0.5404195\nazimuth   [rad]:     0.0\nl_tether  [m]:       0.0\nv_reelout [m/s]:     0.0\nforce     [N]:       0.0\ndepower   [-]:       0.0\nsteering  [-]:       0.0\nheading   [rad]:     0.0\ncourse    [rad]:     0.0\nv_app     [m/s]:     0.0\nvel_kite  [m/s]:     Float32[0.0, 0.0, 0.0]\nX         [m]:       Float32[0.0, 1.6666666, 3.3333333, 5.0, 6.6666665, 8.333333, 10.0]\nY         [m]:       Float32[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]\nZ         [m]:       Float32[0.0, 0.15380114, 0.6194867, 1.4100224, 2.5474184, 4.063342, 6.0000005]\nvar_01       :       0.0\nvar_02       :       0.0\nvar_03       :       0.0\nvar_04       :       0.0\nvar_05       :       0.0\nvar_06       :       0.0\nvar_07       :       0.0\nvar_08       :       0.0\nvar_09       :       0.0\nvar_10       :       0.0\nvar_11       :       0.0\nvar_12       :       0.0\nvar_13       :       0.0\nvar_14       :       0.0\nvar_15       :       0.0\nvar_16       :       0.0\n"
    state = KiteUtils.demo_state_4p(7)
    @test typeof(state) == SysState{11}
    @test state.X[end] ≈ 12.45
    @test state.Y[end] ≈ -2.885
    @test state.Y[end-1] ≈ 2.885
    @test demo_state_4p(7).t_sim == 0.014
    state=demo_state_4p_3lines(7)
    @test typeof(state) == SysState{24}
    @test state.X[end] ≈ 51.37055f0
    state.Y[end] ≈ 1.110223f-16
    state.t_sim[end] == 0.014
    set_data_path(tempdir())
    log = KiteUtils.test(true)
    @test typeof(log) == SysLog{7}
    @test log.syslog.Z[end][7] ≈ 6 # height of the last particle which represents the kite
    @test log.z[end] ≈ 6.0
    @test log.y[end] ≈ 0.0
    @test log.x[end] ≈ 10.0
    @test export_log(log) == joinpath(tempdir(), "Test_flight.csv")
end
@testset "Logger: " begin
    steps = 20*30
    logger = Logger(7, steps)
    state = demo_state(7)
    for i in 1:steps
        @test (@allocated log!(logger, state)) == 0
    end
    @test logger.time_vec == zeros(steps)
    @test save_log(logger) == joinpath(tempdir(), "sim_log.arrow")
    logger = Logger(7, 2)
    @test length(logger) == 0
    log!(logger, state)
    log!(logger, state)
    log!(logger, state)
    @test length(logger) == 2
    logger = Logger(7, 100)
    log!(logger, state)
    log!(logger, state)
    @test length(logger.time_vec) == 100
    save_log(logger) == joinpath(tempdir(), "sim_log.arrow")
    @test length(logger.time_vec) == 2
end
@testset "KiteUtils.jl: Transformations" begin
    ax, ay, az = [1, 0, 0], [0, 1, 0],  [0, 0, 1]
    bx, by, bz = [0, 1, 0], [-1, 0, 0], [0, 0, 1]
    res = rot3d(ax, ay, az, bx, by, bz)
    vec = [1, 0, 0]
    @test res * vec ≈ [0, 1, 0]
    pos_kite = [1.0, 1, 10]
    pos_before =  [1.0, 1, 9]
    v_app = [10, 0, 0.0]
    m = rot(pos_kite, pos_before, v_app)
    @test m == [0.0 0.0 -1.0; -1 0.0 0.0; 0 1 0]
    @test ground_dist(pos_kite) ≈ 1.4142135623730951
    @test calc_elevation(pos_kite) ≈ 1.4303066250413763
    @test azimuth_east(pos_kite) ≈ -0.7853981633974483
    @test acos2(1.0001) == 0.0
    @test acos2(-1.0001) ≈ π
    @test calc_azimuth(0) ≈ -1.5707963267948966
    @test calc_azimuth(π) ≈ 1.5707963267948966
    vec1 = SVector(1.0, 2.0, 3.0)
    orient = SVector(0, pi/10, pi / 2.0)
    elevation = deg2rad(71.5)
    azimuth   = 0.0
    @test fromENU2EG(vec1) == [2.0, -1.0, 3.0]
    @test fromW2SE(vec1, elevation, azimuth) == [0.0035903140090769448, 2.0, -3.16227562202369]
    azimuth   = deg2rad(45)
    @test fromW2SE(vec1, elevation, azimuth) == [ 1.622480056571193,  2.121320343559643, -2.62060269137249]
    @test all(fromKS2EX(vec1, orient)        .≈ [-1.9999999999999998, 1.878107499419996, 2.544152554510513])
    @test calc_heading_w(orient)             == [ 0.9510565162951535, 0.0,              0.3090169943749474]
    @test calc_heading(orient, elevation, azimuth)  ≈ 5.388664810099589
    calc_course(vec1, elevation, azimuth)
end
include("bench.jl")
nothing