```@meta
CurrentModule = ParameterizedQuantumControl
```

# ParameterizedQuantumControl.jl

```@eval
using Markdown
using Pkg

VERSION = Pkg.dependencies()[Base.UUID("409be4c9-afa4-4246-894e-472b92a1ed06")].version

github_badge = "[![Github](https://img.shields.io/badge/JuliaQuantumControl-ParameterizedQuantumControl.jl-blue.svg?logo=github)](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl)"

version_badge = "![v$VERSION](https://img.shields.io/badge/version-v$(replace(string(VERSION), "-" => "--"))-green.svg)"

Markdown.parse("$github_badge $version_badge")
```

Implementation of control methods for analytical parameterized control fields.

Part of [`QuantumControl.jl`](https://github.com/JuliaQuantumControl/QuantumControl.jl#readme) and the [JuliaQuantumControl](https://github.com/JuliaQuantumControl) organization.


## Installation

As usual, the package can be installed with

~~~
pkg> add ParameterizedQuantumControl
~~~


## Usage

* Define a [`QuantumControl.ControlProblem`](@ref) that contains parameterized generators or control fields: [`get_parameters(problem)`](@ref get_parameters) must return a vector of control parameters.

* Call [`QuantumControl.optimize`](@extref QuantumControl `QuantumControlBase.optimize`) using `method=ParameterizedQuantumControl`, and give an appropriate backend and optimizer, e.g.,

  ```
  optimize(
      problem;
      method=ParameterizedQuantumControl,
      backend=Optimization,
      optimizer=NLopt.LN_NELDERMEAD(),
  )
  ```

See [`ParameterizedQuantumControl.optimize_parameters`](@ref) for details.

Currently, only [`Optimization.jl`](@extref Optimization :doc:`index`) is supported as a backend, and only with gradient-free optimizers. In the future, this will be extended to gradient-based optimizers (i.e., the "GOAT" method [MachnesPRL2018](@cite)), as well as specific pulse parametrizations (e.g., CRAB [CanevaPRA2011](@cite)).


## Contents


```@contents
Depth = 2
Pages = [pair[2] for pair in Main.PAGES[2:end-1]]
```


## History

See the [Releases](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl/releases) on Github.
