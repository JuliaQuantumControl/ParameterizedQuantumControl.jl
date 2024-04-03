using QuantumControlBase: QuantumControlBase, init_prop_trajectory
using QuantumControlBase.QuantumPropagators.Controls: get_parameters


"""Parameterized Optimization Workspace."""
mutable struct ParameterizedOptWrk{O}

    # a copy of the trajectories
    trajectories

    # parameters: AbstractVector of parameters in the problem. This must
    # aliases into the problem, so that mutating the vector directly affects
    # the propgation
    parameters::AbstractVector

    # The kwargs from the control problem
    kwargs

    # vector [J_T, …] (parts other than J_T for future use)
    J_parts::Vector{Float64}

    fg_count::Vector{Int64}

    # The backend (name of package/module)
    backend::Symbol

    # The optimizer
    optimizer::O

    optimizer_state

    result

    # for normal forward propagation
    propagators

    use_threads::Bool

end

function ParameterizedOptWrk(problem::QuantumControlBase.ControlProblem; verbose=false)
    use_threads = get(problem.kwargs, :use_threads, false)
    kwargs = Dict(problem.kwargs)  # creates a shallow copy; ok to modify
    trajectories = [traj for traj in problem.trajectories]
    parameters = get(problem.kwargs, :parameters, get_parameters(problem))
    tlist = problem.tlist
    _prefixes = ["prop_",]
    propagators = [
        init_prop_trajectory(
            traj,
            tlist;
            verbose,
            _msg="Initializing fw-prop of trajectory $k",
            _prefixes,
            _filter_kwargs=true,
            kwargs...
        ) for (k, traj) in enumerate(trajectories)
    ]
    J_parts = zeros(1)
    fg_count = zeros(Int64, 2)
    backend = Symbol(nothing)
    if haskey(kwargs, :backend)
        if !(kwargs[:backend] isa Module)
            throw(ArgumentError("`backend` must be a module"))
        end
        backend = nameof(kwargs[:backend])
    else
        error("no backend: cannot optimize")
    end
    optimizer = nothing
    if haskey(kwargs, :optimizer)
        optimizer = kwargs[:optimizer]
    else
        error("no optimizer: cannot optimize")
    end
    optimizer_state = nothing
    if haskey(kwargs, :continue_from)
        @info "Continuing previous optimization"
        result = kwargs[:continue_from]
        if !(result isa ParameterizedOptResult)
            # account for continuing from a different optimization method
            result = convert(ParameterizedOptResult, result)
        end
        result.iter_stop = get(kwargs, :iter_stop, 5000)
        result.converged = false
        result.start_local_time = now()
        result.message = "in progress"
    else
        result = ParameterizedOptResult(problem)
    end
    O = typeof(optimizer)
    ParameterizedOptWrk{O}(
        trajectories,
        parameters,
        kwargs,
        J_parts,
        fg_count,
        backend,
        optimizer,
        optimizer_state,
        result,
        propagators,
        use_threads
    )
end
