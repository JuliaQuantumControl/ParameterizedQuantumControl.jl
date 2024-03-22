using Test
using SafeTestsets
using Plots

unicodeplots()

# Note: comment outer @testset to stop after first @safetestset failure
@time @testset verbose = true "ParameterizedQuantumControl.jl Package" begin

    @test "Hello World" isa String
    #=
    println("\n* TLS Optimization (test_tls_optimization.jl)")
    @time @safetestset "TLS Optimization" begin
        include("test_tls_optimization.jl")
    end
    =#


end
nothing
