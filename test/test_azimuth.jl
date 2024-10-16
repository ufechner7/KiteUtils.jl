using KiteUtils, Test

#     azimuth_east(vec)

# Calculate the azimuth angle in radian from the kite position in ENU reference frame.
# Zero east. Positive direction clockwise seen from above.
# Valid range: -π .. π.

# kite position in ENU reference frame
pos_kite_east=[100.0, 0, 100.0]    # east
pos_kite_north=[0, 100.0, 100.0]   # north
post_kite_south=[0, -100.0, 100.0] # south

@testset "azimuth_east" begin
    aze = azimuth_east(pos_kite_east)
    @test rad2deg(aze) ≈ 0.0 atol=1e-10
    aze = azimuth_east(pos_kite_north)
    @test rad2deg(aze) ≈ -90.0 atol=1e-10
    aze = azimuth_east(post_kite_south)
    @test rad2deg(aze) ≈ 90.0 atol=1e-10
end

@testset "azimuth_north" begin
    azn = azimuth_north(pos_kite_east)
    @test rad2deg(azn) ≈ -90.0 atol=1e-10
    azn = azimuth_north(pos_kite_north)
    @test rad2deg(azn) ≈ 0.0 atol=1e-10
    azn = azimuth_north(post_kite_south)
    @test (rad2deg(azn) ≈ -180.0) || (rad2deg(azn) ≈ 180.0)
end
nothing
