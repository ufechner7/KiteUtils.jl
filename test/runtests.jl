using KiteUtils
using Test

cd("..")

@testset "KiteUtils.jl: Settings       " begin
    @test se().project == "settings.yaml"
    @test se().log_file == joinpath("data", "log_8700W_8ms")
    @test se().time_lapse == 1.0
    @test se().sim_time == 100.0
    @test length(se().alpha_cl) == 12
    set_data_path(tempdir())
    @test KiteUtils.DATA_PATH[1] == tempdir()
    set_data_path("data")
    set2 = load_settings(joinpath("data", "settings.yaml"))
    @test set2.project == "settings.yaml"
end
@testset "KiteUtils.jl: Log files      " begin
    state = KiteUtils.demo_state(7)
    @test typeof(state) == SysState{7}
    @test state.X[end] == 10.0
    @test repr(state) == "time      [s]:       0.0\norient    [w,x,y,z]: Float32[0.5, 0.5, -0.5, -0.5]\nelevation [rad]:     0.5404195\nazimuth   [rad]:     0.0\nl_tether  [m]:       0.0\nv_reelout [m/s]:     0.0\nforce     [N]:       0.0\ndepower   [-]:       0.0\nv_app     [m/s]:     0.0\nX         [m]:       Float32[0.0, 1.6666666, 3.3333333, 5.0, 6.6666665, 8.333333, 10.0]\nY         [m]:       Float32[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]\nZ         [m]:       Float32[0.0, 0.15380114, 0.6194867, 1.4100224, 2.5474184, 4.063342, 6.0000005]\n"
    set_data_path(tempdir())
    log = KiteUtils.test(true)
    @test typeof(log) == SysLog{7}
    @test log.syslog.Z[end][7] ≈ 6 # height of the last particle which represents the kite
    @test log.z[end] ≈ 6.0
    @test log.y[end] ≈ 0.0
    @test log.x[end] ≈ 10.0
    @test export_log(log) == joinpath(tempdir(), "Test_flight.csv")
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
end
nothing