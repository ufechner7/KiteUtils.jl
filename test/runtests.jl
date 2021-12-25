using KiteUtils
using Test

cd("..")

@testset "KiteUtils.jl: Settings       " begin
    # Write your tests here.
    @test se().project == "settings.yaml"
    @test se().log_file == "data/log_8700W_8ms"
    @test se().time_lapse == 1.0
    @test se().sim_time == 100.0
    @test length(se().alpha_cl) == 12
end
@testset "KiteUtils.jl: Log files      " begin
    log = KiteUtils.test()
    @test typeof(log) == SysLog{7}
    @test log.syslog.Z[end][7] ≈ 6 # height of the last particle which represents the kite
end
@testset "KiteUtils.jl: Transformations" begin
    ax, ay, az = [1, 0, 0], [0, 1, 0],  [0, 0, 1]
    bx, by, bz = [0, 1, 0], [-1, 0, 0], [0, 0, 1]
    res = rot3d(ax, ay, az, bx, by, bz)
    vec = [1, 0, 0]
    @test res * vec ≈ [0, 1, 0]
end
nothing
