#using QuantumPropagators.Interfaces: check_generator
using QuantumControl.Interfaces: check_generator
using ComponentArrays: ComponentVector, Axis
using QuantumControl.Controls: get_parameters
using QuantumControl.QuantumPropagators: propagate
import OrdinaryDiffEq
using UnPack: @unpack

const 𝕚 = 1im;


# # Definition of the Hamiltonian

include("enantiomer_ham.jl")
using .EnantiomerHams: EnantiomerHam

# # Testing the Hamiltonian

H = EnantiomerHam(;
    sign = +1,
    ΔT₁ = 0.3,
    ΔT₂ = 0.4,
    ΔT₃ = 0.3,
    ϕ₁ = 0.0,
    ϕ₂ = 0.0,
    ϕ₃ = 0.0,
    E₀₁ = 4.5,
    E₀₂ = 4.0,
    E₀₃ = 5.0
)

tlist = collect(range(0, 1; length = 101));
Ψ₀ = ComplexF64[1, 0, 0];

check_generator(
    H;
    tlist,
    state = Ψ₀,
    for_mutable_state = true,
    for_parameterization = true,
    for_gradient_optimization = false,
    for_time_continuous = true
)


# # Defining the control problem

using QuantumControl: ControlProblem, Trajectory

Ψ₊tgt = ComplexF64[1, 0, 0];
Ψ₋tgt = ComplexF64[0, 0, 1];

parameters = ComponentVector(
    ΔT₁ = 0.2,
    ΔT₂ = 0.4,
    ΔT₃ = 0.3,
    ϕ₁ = π,
    ϕ₂ = π,
    ϕ₃ = π,
    E₀₁ = 4.0,
    E₀₂ = 4.0,
    E₀₃ = 4.0
)
H₊ = EnantiomerHam(parameters; sign = +1)
H₋ = EnantiomerHam(parameters; sign = -1)

@assert get_parameters(H₊) === get_parameters(H₋)
@assert get_parameters(H₊) === parameters

using QuantumControl.Functionals: J_T_ss


function J_T(ϕ, trajectories; τ = nothing)
    Ψ₊, Ψ₋ = ϕ[1], ϕ[2]
    return 1 - (abs(Ψ₊[1]) + abs(Ψ₋[3])) / 2
end


problem = ControlProblem(
    [Trajectory(Ψ₀, H₊; target_state = Ψ₊tgt), Trajectory(Ψ₀, H₋; target_state = Ψ₋tgt)],
    tlist;
    parameters = parameters,
    lb = ComponentVector(
        ΔT₁ = 0.1,
        ΔT₂ = 0.1,
        ΔT₃ = 0.1,
        ϕ₁ = 0.0,
        ϕ₂ = 0.0,
        ϕ₃ = 0.0,
        E₀₁ = 1.0,
        E₀₂ = 1.0,
        E₀₃ = 1.0,
    ),
    ub = ComponentVector(
        ΔT₁ = 1.0,
        ΔT₂ = 1.0,
        ΔT₃ = 1.0,
        ϕ₁ = 2π,
        ϕ₂ = 2π,
        ϕ₃ = 2π,
        E₀₁ = 5.0,
        E₀₂ = 5.0,
        E₀₃ = 5.0,
    ),
    J_T = J_T_ss,
    #J_T,
    prop_method = OrdinaryDiffEq,
    prop_reltol = 1e-9,
    prop_abstol = 1e-9,
    iter_stop = 500,
    check_convergence = res -> begin
        ((res.J_T < 1e-5) && (res.converged = true) && (res.message = "J_T < 10⁻⁵"))
    end,
)

@assert get_parameters(problem) === parameters

using QuantumControl: propagate_trajectory

Ψ₊out = propagate_trajectory(
    problem.trajectories[1],
    tlist;
    method = OrdinaryDiffEq,
    reltol = 1e-9,
    abstol = 1e-9
)
Ψ₋out = propagate_trajectory(
    problem.trajectories[2],
    tlist;
    method = OrdinaryDiffEq,
    reltol = 1e-9,
    abstol = 1e-9
)

# # Running the Optimization

using QuantumControl: optimize
using ParameterizedQuantumControl
using Optimization
using OptimizationNLopt
import NLopt

res = optimize(
    problem;
    method = ParameterizedQuantumControl,
    backend = Optimization,
    optimizer = NLopt.LN_NELDERMEAD(),
    info_hook = (
        ((wrk, iter) -> (1.0 - wrk.J_parts[1],)),
        ParameterizedQuantumControl.print_table,
    )
)
