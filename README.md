# ParameterizedQuantumControl.jl

[![Version](https://juliahub.com/docs/ParameterizedQuantumControl/version.svg)](https://juliahub.com/ui/Packages/ParameterizedQuantumControl/W0mna)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaquantumcontrol.github.io/ParameterizedQuantumControl.jl/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaquantumcontrol.github.io/ParameterizedQuantumControl.jl/dev)
[![Build Status](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl/workflows/CI/badge.svg)](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaQuantumControl/ParameterizedQuantumControl.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaQuantumControl/ParameterizedQuantumControl.jl)


Implementation of control methods for analytical parameterized control fields.

Part of [`QuantumControl.jl`][QuantumControl] and the [JuliaQuantumControl][] organization.


## Installation

As usual, the package can be installed with

~~~
pkg> add ParameterizedQuantumControl
~~~

## Usage

* Define a `QuantumControl.ControlProblem` that contains parameterized generators or control fields: `get_parameters(problem)` must return a vector of control parameters.

* Call `QuantumControl.optimize` using `method=ParameterizedQuantumControl`, and give an appropriate backend and optimizer, e.g.,

  ```
  optimize(
      problem;
      method=ParameterizedQuantumControl,
      backend=Optimization,
      optimizer=NLopt.LN_NELDERMEAD(),
  )
  ```

Currently, only [`Optimization.jl`](https://github.com/SciML/Optimization.jl) is supported as a backend, and only with gradient-free optimizers. In the future, this will be extended to gradient-based optimizers (i.e., the "GOAT" method), as well as specific pulse parametrizations (e.g., CRAB).


## Documentation

A minimal standalone documentation of `ParameterizedQuantumControl.jl` is available at <https://juliaquantumcontrol.github.io/ParameterizedQuantumControl.jl>.

For a broader perspective, see the [documentation of the `QuantumControl.jl` package](https://juliaquantumcontrol.github.io/QuantumControl.jl/).

[QuantumControl]: https://github.com/JuliaQuantumControl/QuantumControl.jl#readme
[JuliaQuantumControl]: https://github.com/JuliaQuantumControl
