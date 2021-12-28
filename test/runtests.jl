using KiteUtils
using Test

cd("..")

@testset "KiteUtils.jl: Settings       " begin
    @test se().project == "settings.yaml"
    @test se().log_file == "data/log_8700W_8ms"
    @test se().time_lapse == 1.0
    @test se().sim_time == 100.0
    @test length(se().alpha_cl) == 12
    set_data_path("/tmp")
    @test KiteUtils.DATA_PATH[1] == "/tmp"
    set_data_path("./data")
    set2 = load_settings("./data/settings.yaml")
    @test set2.project == "settings.yaml"
end
@testset "KiteUtils.jl: Log files      " begin
    state = KiteUtils.demo_state(7)
    @test typeof(state) == SysState{7}
    @test state.X[end] == 10.0
    log = KiteUtils.test(true)
    @test typeof(log) == SysLog{7}
    @test log.syslog.Z[end][7] ≈ 6 # height of the last particle which represents the kite
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
    println(demo_state(7))
end
