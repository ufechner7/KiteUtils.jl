using KiteUtils, BenchmarkTools, StaticArrays, Test

@benchmark fromKS2EX(vec1, orient) setup=(vec1 = SVector(1.0, 2.0, 3.0); orient = SVector(0, pi/10, pi / 2.0))
# 64 ns; Python: 10 µs

res = @benchmark rot(pos_kite, pos_before, v_app) setup=(pos_kite = SVector(1.0, 1, 10); pos_before = SVector(1.0, 1, 9); v_app = SVector(10.0, 0, 0))
@testset "rot" begin
    @test res.allocs == 0
end

nothing
