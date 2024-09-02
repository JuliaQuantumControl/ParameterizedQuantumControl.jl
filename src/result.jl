using QuantumControl.QuantumPropagators.Controls: get_parameters
using Printf
using Dates


"""Result object returned by [`optimize_parameters`](@ref)."""
mutable struct ParameterizedOptResult{STST,PT}
    tlist::Vector{Float64}
    iter_start::Int64  # the starting iteration number
    iter_stop::Int64 # the maximum iteration number
    iter::Int64  # the current iteration number
    secs::Float64  # seconds that the last iteration took
    tau_vals::Vector{ComplexF64}
    J_T::Float64  # the current value of the final-time functional J_T
    J_T_prev::Float64  # previous value of J_T
    guess_parameters::PT
    optimized_parameters::PT
    states::Vector{STST}
    start_local_time::DateTime
    end_local_time::DateTime
    records::Vector{Tuple}  # storage for info_hook to write data into at each iteration
    converged::Bool
    f_calls::Int64
    fg_calls::Int64
    message::String

    function ParameterizedOptResult(problem)
        tlist = problem.tlist
        iter_start = get(problem.kwargs, :iter_start, 0)
        iter_stop = get(problem.kwargs, :iter_stop, 5000)
        iter = iter_start
        secs = 0
        tau_vals = zeros(ComplexF64, length(problem.trajectories))
        J_T = 0.0
        J_T_prev = 0.0
        parameters = get(problem.kwargs, :parameters, get_parameters(problem))
        optimized_parameters = copy(parameters)
        guess_parameters = copy(parameters)
        states = [similar(traj.initial_state) for traj in problem.trajectories]
        start_local_time = now()
        end_local_time = now()
        records = Vector{Tuple}()
        converged = false
        message = "in progress"
        f_calls = 0
        fg_calls = 0
        PT = typeof(optimized_parameters)
        STST = eltype(states)
        new{STST,PT}(
            tlist,
            iter_start,
            iter_stop,
            iter,
            secs,
            tau_vals,
            J_T,
            J_T_prev,
            guess_parameters,
            optimized_parameters,
            states,
            start_local_time,
            end_local_time,
            records,
            converged,
            f_calls,
            fg_calls,
            message
        )
    end
end


Base.show(io::IO, r::ParameterizedOptResult) =
    print(io, "ParameterizedOptResult<$(r.message)>")
Base.show(io::IO, ::MIME"text/plain", r::ParameterizedOptResult) = print(
    io,
    """
Parameterized Optimization Result
---------------------------------
- Started at $(r.start_local_time)
- Number of trajectories: $(length(r.states))
- Number of iterations: $(max(r.iter - r.iter_start, 0))
- Number of pure func evals: $(r.f_calls)
- Number of func/grad evals: $(r.fg_calls)
- Value of functional: $(@sprintf("%.5e", r.J_T))
- Reason for termination: $(r.message)
- Ended at $(r.end_local_time) ($(Dates.canonicalize(Dates.CompoundPeriod(r.end_local_time - r.start_local_time))))
"""
)
