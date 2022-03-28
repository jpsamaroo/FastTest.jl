using FastTest
using Test

@testset "Basics" begin
    @test @eval(FastTest.@testset "test" begin end) isa Test.DefaultTestSet

    @test sum(Test.get_test_counts(@eval(FastTest.@testset "test" begin
        @test true
    end))) == 1
    @test_throws Exception @eval(FastTest.@testset "test" begin
        @test false
    end)

    @testset "Nesting" begin
        @test sum(Test.get_test_counts(@eval(FastTest.@testset "test" begin
            FastTest.@testset "test_inner" begin
                @test true
            end
            @test true
        end))) == 2
        @test_throws Exception @eval(FastTest.@testset "test" begin
            FastTest.@testset "test_inner" begin
                @test false
            end
        end)
    end

    @testset "For Loop" begin
        @test sum(Test.get_test_counts(@eval(FastTest.@testset "test" for i in 1:5
            #=
            FastTest.@testset "test_inner" begin
                @test true
            end
            =#
        end))) == 5
    end
end
