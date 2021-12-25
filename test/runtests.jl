using KiteUtils
using Test

@testset "KiteUtils.jl" begin
    # Write your tests here.
    @test se().project == "settings.yaml"
    @test se().log_file == "data/log_8700W_8ms"
    @test length(se().alpha_cl) == 12
end
