module ParameterizedQuantumControlOptimizationExt
using Dates: now

using Optimization: Optimization, OptimizationProblem
import ParameterizedQuantumControl: run_optimizer, update_result!

function run_optimizer(
    backend::Val{:Optimization},
    optimizer,
    wrk,
    f,
    info_hook,
    check_convergence!
)
    u0 = copy(wrk.result.guess_parameters)
    #kwargs = ...  # TODO: optimization_kwargs
    function callback(state, loss_val)
        wrk.optimizer_state = state
        iter = wrk.result.iter
        update_result!(wrk, iter)
        #update_hook!(...) # TODO
        info_tuple = info_hook(wrk, iter)
        wrk.fg_count .= 0
        (info_tuple !== nothing) && push!(wrk.result.records, info_tuple)
        check_convergence!(wrk.result)
        wrk.result.iter += 1  # next iteration
        return wrk.result.converged
    end
    prob = OptimizationProblem(
        (u, _) -> f(u),
        u0,
        nothing;
        lb=get(wrk.kwargs, :lb, nothing),
        ub=get(wrk.kwargs, :ub, nothing)
    )
    try
        sol = Optimization.solve(prob, optimizer; callback)
    catch exc
        exc_msg = sprint(showerror, exc)
        if !contains(exc_msg, "Optimization halted by callback")
            rethrow()
        end
    end
    wrk.result.end_local_time = now()
end

end
