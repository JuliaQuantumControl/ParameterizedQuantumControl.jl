# Overview

## Control Parameters

The `ParameterizedQuantumControl` package optimizes a set ``\{u_n\}`` of arbitrary [control parameters](@extref QuantumControl Control-Parameters) associated with a given [control problem](@ref ControlProblem).
The dynamic generators ``\Op{H} = \Op{H}(\{u_n\}, t)`` from the different [trajectories](@ref Trajectory) implicitly depend on these parameter values in arbitrary ways.

Contrast this with the form
```math
\Op{H} = \Op{H}_0 + \sum_l \Op{H}_l(\{ϵ_{l′}(t)\}, t)
\quad\text{or}\quad
\Op{H}_0 + \sum_l a_l(\{ϵ_{l′}(t)\}, t) \Op{H}_l
\quad\text{or}\quad
\Op{H}_0 + \sum_l ϵ_l(t) \Op{H}_l
```
of a [Generator](@extref QuantumControl :label:`Generator`), where ``\Op{H}_0`` is the drift term, ``\Op{H}_l`` are the control terms, and ``a_l(t)`` and ``ϵ_l(t)`` are the [control amplitudes](@extref QuantumControl :label:`Control-Amplitude`) and [control functions](@extref QuantumControl :label:`Control-Function`), respectively. Methods such as [GRAPE](@extref GRAPE :doc:`index`) and [Krotov's method](@extref Krotov :doc:`index`) optimize each ``ϵ_l(t)`` as a time-continuous function.

Control amplitudes or control functions still play a conceptual role: Even though in the most general case, the generator ``\Op{H}`` can directly depend on the parameters, the most common case is for that dependency to be inside of the controls, ``ϵ_l(t) → ϵ_l(\{u_n\}, t)``. The crucial difference is that in `ParameterizedQuantumControl`, we solve the optimization problem by tuning the values ``u_n``, not ``ϵ_l(t)`` as arbitrary time-continuous control functions.

The `ParameterizedQuantumControl` package evaluates an arbitrary optimization functional ``J(\{u_n\})`` and optionally the gradient ``\frac{∂J}{∂ u_n}`` and feeds that information to an optimization backend, e.g. [Optimization.jl](@extref Optimization :doc:`index`) with its large collection of solvers. We may again contrast this with [GRAPE](@extref GRAPE :doc:`index`) and [Krotov's method](@extref Krotov :doc:`index`) which conceptually optimize time-continuous control functions ``ϵ_l(t)`` but in practice discretize these functions as piecewise-constant on a time grid. One might be tempted to think if this discretization as the use of control parameters ``ϵ_l(t) = ϵ_l(\{ϵ_{nl}\})`` where each parameter ``ϵ_{nl}`` is the amplitude of ``ϵ_l(t)`` on the ``n``'th interval of the time grid (what we refer to as a ["pulse"](@extref QuantumControl :label:`Pulse`)). However, GRAPE and Krotov have a specific numerical scheme to evaluate the gradients of the optimization functional with respect to the pulse values. That scheme is dramatically more efficient than the [more general scheme to determine gradients](@ref gradients) with respect to *arbitrary* parameters that is used in `ParameterizedQuantumControl`.


## Parameter API

`ParameterizedQuantumControl` manages the evaluation of functionals and gradients, and organizes feeding that information into an optimization backend. However, the structures for working with control parameters are already provided by the [`QuantumPropagators`](@extref QuantumPropagators :doc:`index`) and [`QuantumControl`](@extref QuantumControl :doc:`index`) packages. We summarize them here in the context of optimal control.

Generally, the vector of `parameters` is obtained from `problem` via the [`get_parameters`](@ref) function. This delegates to `get_parameters(traj)` for each [`Trajectory`](@ref) in `problem.trajectories`, which in turn delegates to `get_parameters(traj.generator)`. This makes it possible to define a custom datatype for the dynamic generator for which a `get_parameters` method is defined. It is recommended for `get_parameters` to return a [`ComponentArrays.ComponentVector`](@extref) `parameters`. That makes it easy to keep track of which value is which parameters. However, in general, `get_parameters` can return an arbitrary [`AbstractVector`](@extref Julia `Base.AbstractVector`). What is important is that the returned `parameters` alias into the generator. That is, mutating `parameters` and then calling [`QuantumControl.Controls.evaluate(generator, args...; kwargs...)`](@extref QuantumControl `QuantumPropagators.Controls.evaluate`) must return an operator that takes into account the current values in `parameters`. The easiest way to achieve this is to have `parameters` be a field in the custom `struct` of the generator and have `get_parameters` return a reference to that field. The `QuantumControl.Interfaces.check_parameterized` function of `QuantumControl.Interfaces.check_generator` with `for_parameterization=true` can be used to verify the implementation of a custom generator.

```@raw todo
As soon as we figure out the interface for the gradients, `QuantumControl.Interfaces.check_generator` needs to be implemented separately from the version in `QuantumPropagators`, and then we can properly link the above references
```

When there are multiple trajectories (and thus multiple generators) in the [`ControlProblem`](@ref), these are automatically combined into a [`RecursiveArrayTools.ArrayPartition`](@extref). The parameters from different generators are considered independent unless they are the same object.

When using a built-in [`QuantumControl.Generators.Generator`](@ref) as returned by [`QuantumControl.hamiltonian`](@ref) or [`QuantumControl.liouvillian`](@ref), the [`get_parameters`](@ref) function delegates to the `get_parameters(control)` for any control returned by [`get_controls(generator)`](@extref QuantumControl `QuantumPropagators.Controls.get_controls`). The recommended way to implement a custom parameterized control is to subtype [`QuantumControl.Controls.ParameterizedFunction`](@ref). Just like parameters from different generators in the same control problem are automatically combined, the parameters from different controls are also automatically combined into a [`RecursiveArrayTools.ArrayPartition`](@extref), taking into account if `get_parameters` returns the same object for two different controls. In any case, for any custom implementation of a parameterized system, and especially if control parameters are aliased between different components of the system, it is important to carefully check that the result of `get_parameters` contains all the independent parameters of the problem.

```@raw todo
The is a connection to be made with the `parameters` field of a propagator and the paremters of the dynamic generators for the propagation.
```

```@raw todo
Explain pulse parameterization
```


## Evaluation of the Functional

In order to evaluate an optimization functional ``J(\{u_n\})``, the `ParameterizedQuantumControl` package simply uses [`QuantumControl.propagate_trajectories`](@ref) and passes the resulting states to a `J_T` function.
Running costs are a work in progress.
Again, the dynamic generators are assumed to have been implemented in such a way that mutating the values in the array returned by [`get_parameters`](@ref) are automatically taken into account.

In principle, any [propagation method](@extref QuantumPropagators :doc:`methods`) can be used for the evaluation of the functional. However, parameterized controls are typically time-continuous functions, and using piecewise-constant propagators such as [`ExpProp`](@extref QuantumPropagators :label:`method_expprop`), [`Cheby`](@extref QuantumPropagators :label:`method_cheby`), or [`Newton`](@extref QuantumPropagators :label:`method_newton`) is unnecessary and introduces a discretization error. Usually, using an ODE solver with [`method=OrdinaryDiffEq`](@extref QuantumPropagators :label:`method_ode`) is more appropriate.

It is also worth noting that the time discretization that happens in piecewise-constant propagators severs the connection between the control parameters and the pulse amplitudes at each interval of the time grid. Thus, any changes to the `parameters` after [`QuantumControl.init_prop`](@ref) will not be reflected in subsequent calls to [`QuantumControl.prop_step!`](@ref). This is not an issue inside of `ParameterizedQuantumControl`, as [`QuantumControl.propagate_trajectories`](@ref) initializes a new propagator for every evaluation of the functional.


```@raw todo
* Can we guarantee that the `OrdinaryDiffEq` propagator is reusable?
* Test that reinit_prop! updates the parameters
```


## [Gradient Evaluation](@id gradients)

Optimizers that rely on gradient information will be supported in a future release.


## Running costs

Running costs are planned in a future release.
