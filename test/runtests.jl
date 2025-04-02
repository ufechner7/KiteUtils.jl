using KiteUtils, StaticArrays, LinearAlgebra
using Test

cd("..")
@testset verbose=true "KiteUtils" begin

@testset "KiteUtils.jl: Settings       " begin
    @test se().sim_settings == "settings.yaml"
    @test se().log_file == joinpath("data", "log_8700W_8ms")
    @test se().time_lapse == 1.0
    @test se().sim_time == 409.0
    @test se().log_level == 2
    @test se().kcu_model == "KCU1"
    @test se("system2.yaml").cs_4p == 1.1
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
    copy_settings() # copy settings.yaml and system.yaml and settings_ram.yaml and system_ram.yaml
    @test isfile(joinpath(tmpdir, "settings.yaml"))
    @test isfile(joinpath(tmpdir, "system.yaml"))
    @test isfile(joinpath(tmpdir, "settings_ram.yaml"))
    @test isfile(joinpath(tmpdir, "system_ram.yaml"))
    cd(oldir)
    set_data_path(datapath)
end

@testset "KiteUtils.jl: system.yaml    " begin
    @test wc_settings() == "wc_settings.yaml"
    @test fpc_settings() == "fpc_settings.yaml"
    @test fpp_settings() == "fpp_settings.yaml"
end

include("test_logfiles.jl")
include("test_logger.jl")
include("test_transformations.jl")
include("test_orientation.jl")
include("test_azimuth.jl")
include("test_rotational_inertia.jl")
include("bench.jl")
include("aqua.jl")
end
nothing