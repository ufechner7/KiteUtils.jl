using KiteUtils, BenchmarkTools, StaticArrays

@benchmark fromKS2EX(vec1, orient) setup=(vec1 = SVector(1.0, 2.0, 3.0); orient = SVector(0, pi/10, pi / 2.0))
# 64 ns; Python: 10 µs