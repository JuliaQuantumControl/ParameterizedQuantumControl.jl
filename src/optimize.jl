import QuantumControlBase: optimize

using LinearAlgebra
using QuantumControlBase: @threadsif
using QuantumControlBase: set_atexit_save_optimization
using QuantumControlBase: propagate_trajectories


@doc raw"""
```julia
using ParameterizedQuantumControl
result = optimize(problem; method=ParameterizedQuantumControl, kwargs...)
```

optimizes the given control [`problem`](@ref QuantumControlBase.ControlProblem)
by varying a set of control parameters in order to minimize the functional

```math
J(\{u_{n}\}) = J_T(\{|ϕ_k(T)⟩\})
```

where ``|ϕ_k(T)⟩`` is the result of propagating the initial state of the
``k``'th trajectory under the parameters ``\{u_n\}``

Returns a [`ParameterizedOptResult`](@ref).

Keyword arguments that control the optimization are taken from the keyword
arguments used in the instantiation of `problem`; any of these can be overridden
with explicit keyword arguments to `optimize`.

# Required problem keyword arguments

* `backend`: A package to perform the optimization, e.g., `Optimization` (for
  [Optimization.jl](https://github.com/SciML/Optimization.jl))
* `optimizer`: A backend-specific object to perform the optimizatino, e.g.,
  `NLopt.LN_NELDERMEAD()` from `NLOpt`/`OptimizationNLOpt`
* `J_T`: A function `J_T(ϕ, trajectories; τ=τ)` that evaluates the final time
  functional from a vector `ϕ` of forward-propagated states and
  `problem.trajectories`. For all `trajectories` that define a `target_state`,
  the element `τₖ` of the vector `τ` will contain the overlap of the state `ϕₖ`
  with the `target_state` of the `k`'th trajectory, or `NaN` otherwise.


# Optional problem keyword arguments

* `parameters`: An `AbstractVector` of parameters to tune in the optimization.
  By default, [`parameters=get_parameters(problem)`](@ref get_parameters). If
  given explicitly, the vector must alias values inside the generators used in
  `problem.trajectories` so that mutating the `parameters` array directly
  affects any subsequent propagation.
* `lb`: An `AbstractVector` of lower bound values for a box constraint. Must be
  a vector similar to (and of the same size as `parameters`)
* `ub`: An `AbstractVector` of upper bound values for a box constraint,
  cf. `lb`
* `use_threads`: If given a `true`, propagate trajectories in parallel
* `iter_stop`: The maximum number of iterations
"""
function optimize_parameters(problem)

    verbose = get(problem.kwargs, :verbose, false)
    wrk = ParameterizedOptWrk(problem; verbose)

    J_T_func = wrk.kwargs[:J_T]

    initial_states = [traj.initial_state for traj ∈ wrk.trajectories]
    Ψtgt = Union{eltype(initial_states),Nothing}[
        (hasproperty(traj, :target_state) ? traj.target_state : nothing) for
        traj ∈ wrk.trajectories
    ]
    τ = wrk.result.tau_vals
    J = wrk.J_parts

    # loss function
    function f(u; count_call=true)
        copyto!(wrk.parameters, u)
        Ψ = propagate_trajectories(
            wrk.trajectories,
            problem.tlist;
            use_threads=wrk.use_threads,
            _prefixes=["prop_"],
            _filter_kwargs=true,
            problem.kwargs...
        )
        for k in eachindex(wrk.trajectories)
            Ψtgt = wrk.trajectories[k].target_state
            τ[k] = isnothing(Ψtgt) ? NaN : (Ψtgt ⋅ Ψ[k])
        end
        wrk.states = Ψ
        J[1] = J_T_func(Ψ, wrk.trajectories; τ=τ)
        if count_call
            wrk.fg_count[2] += 1
        end
        return sum(J)
    end

    backend = wrk.backend
    optimizer = wrk.optimizer
    info_hook = get(problem.kwargs, :info_hook, print_table)
    check_convergence! = get(problem.kwargs, :check_convergence, res -> res)

    atexit_filename = get(problem.kwargs, :atexit_filename, nothing)
    # atexit_filename is undocumented on purpose: this is considered a feature
    # of @optimize_or_load
    if !isnothing(atexit_filename)
        set_atexit_save_optimization(atexit_filename, wrk.result)
        if !isinteractive()
            @info "Set callback to store result in $(relpath(atexit_filename)) on unexpected exit."
            # In interactive mode, `atexit` is very unlikely, and
            # `InterruptException` is handles via try/catch instead.
        end
    end
    try
        run_optimizer(Val(backend), optimizer, wrk, f, info_hook, check_convergence!)
    catch exc
        # Primarily, this is intended to catch Ctrl-C in interactive
        # optimizations (InterruptException)
        exc_msg = sprint(showerror, exc)
        wrk.result.message = "Exception: $exc_msg"
    end
    if !isnothing(atexit_filename)
        popfirst!(Base.atexit_hooks)
    end

    # restore guess parameters - we don't want to mutate the problem;
    # the optimized parameters are in result.optimized_parameters
    copyto!(wrk.parameters, wrk.result.guess_parameters)
    return wrk.result

end


# backend code stub (see extensions)
function run_optimizer end


"""Print optimization progress as a table.

This functions serves as the default `info_hook` for an optimization with
`ParameterizedQuantumControl`.
"""
function print_table(wrk, iteration, args...)
    # TODO: make_print_table that precomputes headers and such, and maybe
    # allows for more options.
    # TODO: should we report ΔJ instead of ΔJ_T?

    J_T = wrk.result.J_T
    ΔJ_T = J_T - wrk.result.J_T_prev
    secs = wrk.result.secs

    headers = ["iter.", "J_T", "ΔJ_T", "FG(F)", "secs"]
    @assert length(wrk.J_parts) == 1

    iter_stop = "$(get(wrk.kwargs, :iter_stop, 5000))"
    width = Dict(
        "iter." => max(length("$iter_stop"), 6),
        "J_T" => 11,
        "|∇J_T|" => 11,
        "|∇J_a|" => 11,
        "|∇J|" => 11,
        "ΔJ" => 11,
        "ΔJ_T" => 11,
        "FG(F)" => 8,
        "secs" => 8,
    )

    if iteration == 0
        for header in headers
            w = width[header]
            print(lpad(header, w))
        end
        print("\n")
    end

    strs = [
        "$iteration",
        @sprintf("%.2e", J_T),
        (iteration > 0) ? @sprintf("%.2e", ΔJ_T) : "n/a",
        @sprintf("%d(%d)", wrk.fg_count[1], wrk.fg_count[2]),
        @sprintf("%.1f", secs),
    ]
    for (str, header) in zip(strs, headers)
        w = width[header]
        print(lpad(str, w))
    end
    print("\n")
    flush(stdout)
end


# Transfer information from `wrk` to `wrk.result` in each iteration (before the
# `info_hook`)
function update_result!(wrk::ParameterizedOptWrk, i::Int64)
    res = wrk.result
    for (k, Ψ) in enumerate(wrk.states)
        copyto!(res.states[k], Ψ)
    end
    copyto!(wrk.result.optimized_parameters, wrk.parameters)
    res.f_calls += wrk.fg_count[2]
    res.fg_calls += wrk.fg_count[1]
    res.J_T_prev = res.J_T
    res.J_T = wrk.J_parts[1]
    (i > 0) && (res.iter = i)
    if i >= res.iter_stop
        res.converged = true
        res.message = "Reached maximum number of iterations"
        # Note: other convergence checks are done in user-supplied
        # check_convergence routine
    end
    prev_time = res.end_local_time
    res.end_local_time = now()
    res.secs = Dates.toms(res.end_local_time - prev_time) / 1000.0
end


optimize(problem, method::Val{:ParameterizedQuantumControl}) = optimize_parameters(problem)
