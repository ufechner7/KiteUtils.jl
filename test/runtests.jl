using KiteUtils
using Test

cd("..")

@testset "KiteUtils.jl" begin
    # Write your tests here.
    @test se().project == "settings.yaml"
    @test se().log_file == "data/log_8700W_8ms"
    @test length(se().alpha_cl) == 12
    log = KiteUtils.test()
    @test typeof(log) == SysLog{7}
    @test log.syslog.Z[end][7] ≈ 6 # height of the last particle which represents the kite
end
nothing
