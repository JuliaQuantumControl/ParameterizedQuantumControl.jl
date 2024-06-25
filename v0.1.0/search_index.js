var documenterSearchIndex = {"docs":
[{"location":"references/#References","page":"References","title":"References","text":"","category":"section"},{"location":"references/","page":"References","title":"References","text":"S. Machnes, E. Assémat, D. Tannor and F. K. Wilhelm. Tunable, Flexible, and Efficient Optimization of Control Pulses for Practical Qubits. Phys. Rev. Lett. 120, 150401 (2018).\n\n\n\nT. Caneva, T. Calarco and S. Montangero. Chopped random-basis quantum optimization. Phys. Rev. A 84, 022326 (2011).\n\n\n\n","category":"page"},{"location":"api/","page":"API","title":"API","text":"CollapsedDocStrings = true","category":"page"},{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ParameterizedQuantumControl]","category":"page"},{"location":"api/#ParameterizedQuantumControl.ParameterizedOptResult","page":"API","title":"ParameterizedQuantumControl.ParameterizedOptResult","text":"Result object returned by optimize_parameters.\n\n\n\n\n\n","category":"type"},{"location":"api/#ParameterizedQuantumControl.ParameterizedOptWrk","page":"API","title":"ParameterizedQuantumControl.ParameterizedOptWrk","text":"Parameterized Optimization Workspace.\n\n\n\n\n\n","category":"type"},{"location":"api/#ParameterizedQuantumControl.optimize_parameters-Tuple{Any}","page":"API","title":"ParameterizedQuantumControl.optimize_parameters","text":"using ParameterizedQuantumControl\nresult = optimize(problem; method=ParameterizedQuantumControl, kwargs...)\n\noptimizes the given control problem by varying a set of control parameters in order to minimize the functional\n\nJ(u_n) = J_T(ϕ_k(T))\n\nwhere ϕ_k(T) is the result of propagating the initial state of the k'th trajectory under the parameters u_n\n\nReturns a ParameterizedOptResult.\n\nKeyword arguments that control the optimization are taken from the keyword arguments used in the instantiation of problem; any of these can be overridden with explicit keyword arguments to optimize.\n\nRequired problem keyword arguments\n\nbackend: A package to perform the optimization, e.g., Optimization (for Optimization.jl)\noptimizer: A backend-specific object to perform the optimizatino, e.g., NLopt.LN_NELDERMEAD() from NLOpt/OptimizationNLOpt\nJ_T: A function J_T(ϕ, trajectories; τ=τ) that evaluates the final time functional from a vector ϕ of forward-propagated states and problem.trajectories. For all trajectories that define a target_state, the element τₖ of the vector τ will contain the overlap of the state ϕₖ with the target_state of the k'th trajectory, or NaN otherwise.\n\nOptional problem keyword arguments\n\nparameters: An AbstractVector of parameters to tune in the optimization. By default, parameters=get_parameters(problem). If given explicitly, the vector must alias values inside the generators used in problem.trajectories so that mutating the parameters array directly affects any subsequent propagation.\nlb: An AbstractVector of lower bound values for a box constraint. Must be a vector similar to (and of the same size as parameters)\nub: An AbstractVector of upper bound values for a box constraint, cf. lb\nuse_threads: If given a true, propagate trajectories in parallel\n\n\n\n\n\n","category":"method"},{"location":"api/#ParameterizedQuantumControl.print_table-Tuple{Any, Any, Vararg{Any}}","page":"API","title":"ParameterizedQuantumControl.print_table","text":"Print optimization progress as a table.\n\nThis functions serves as the default info_hook for an optimization with ParameterizedQuantumControl.\n\n\n\n\n\n","category":"method"},{"location":"overview/#Overview","page":"Overview","title":"Overview","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ParameterizedQuantumControl","category":"page"},{"location":"#ParameterizedQuantumControl.jl","page":"Home","title":"ParameterizedQuantumControl.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using Markdown\nusing Pkg\n\nVERSION = Pkg.dependencies()[Base.UUID(\"409be4c9-afa4-4246-894e-472b92a1ed06\")].version\n\ngithub_badge = \"[![Github](https://img.shields.io/badge/JuliaQuantumControl-ParameterizedQuantumControl.jl-blue.svg?logo=github)](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl)\"\n\nversion_badge = \"![v$VERSION](https://img.shields.io/badge/version-v$(replace(string(VERSION), \"-\" => \"--\"))-green.svg)\"\n\nMarkdown.parse(\"$github_badge $version_badge\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Implementation of control methods for analytical parameterized control fields.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Part of QuantumControl.jl and the JuliaQuantumControl organization.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"As usual, the package can be installed with","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add ParameterizedQuantumControl","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Define a QuantumControl.ControlProblem that contains parameterized generators or control fields: get_parameters(problem) must return a vector of control parameters.\nCall QuantumControl.optimize using method=ParameterizedQuantumControl, and give an appropriate backend and optimizer, e.g.,\noptimize(\n    problem;\n    method=ParameterizedQuantumControl,\n    backend=Optimization,\n    optimizer=NLopt.LN_NELDERMEAD(),\n)","category":"page"},{"location":"","page":"Home","title":"Home","text":"See ParameterizedQuantumControl.optimize_parameters for details.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Currently, only Optimization.jl is supported as a backend, and only with gradient-free optimizers. In the future, this will be extended to gradient-based optimizers (i.e., the \"GOAT\" method [1]), as well as specific pulse parametrizations (e.g., CRAB [2]).","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Depth = 2\nPages = [pair[2] for pair in Main.PAGES[2:end-1]]","category":"page"},{"location":"#History","page":"Home","title":"History","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"See the Releases on Github.","category":"page"}]
}