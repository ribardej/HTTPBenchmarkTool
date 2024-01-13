using HTTPBenchmarkTool
using Test, DataFrames

@testset "HTTPBenchmarkTool.jl" begin
    # Test case with no noise removal, should not change the DataFrame
    @testset "remove_noise_from_data! - No noise" begin
        data = DataFrame(ElapsedTime = [1.0, 2.0, 3.0, 4.0])
        original_data = copy(data)
        remove_noise_from_data!(data, :ElapsedTime; std_factor=2)
        @test data == original_data
    end

    # Test case with noise removal, should filter out outliers
    @testset "remove_noise_from_data! - With noise" begin
        data = DataFrame(ElapsedTime = [1.0, 2.0, 3.0, 1.3, 1.1, 3.8, 1000.0])
        remove_noise_from_data!(data, :ElapsedTime; std_factor=2)
        @test size(data, 1) == 6
        @test all(x -> 1.0 <= x <= 3.8, data[:, :ElapsedTime])
    end

    # Test case with an empty DataFrame, should remain empty
    @testset "remove_noise_from_data! - Empty DataFrame" begin
        data = DataFrame(ElapsedTime = Float64[])
        remove_noise_from_data!(data, :ElapsedTime; std_factor=2)
        @test isempty(data)
    end

    # Test case with positive mean, should scale the column
    @testset "base! - Positive mean" begin
        data = DataFrame(ElapsedTime = [1.0, 2.0, 3.0, 4.0])
        base!(data, :ElapsedTime)
        @test all(x -> 1.0 <= x <= 10.0, data[:, :ElapsedTime])
    end

    # Test case with 1.0 mean, should not change the column
    @testset "base! - 1.0 mean" begin
        data = DataFrame(ElapsedTime = [1.0, 1.0, 1.0, 1.0])
        original_data = copy(data)
        base!(data, :ElapsedTime)
        @test data == original_data
    end

    # Test case with an empty DataFrame, should remain empty
    @testset "base! - Empty DataFrame" begin
        data = DataFrame(ElapsedTime = Float64[])
        base!(data, :ElapsedTime)
        @test isempty(data)
    end
end
