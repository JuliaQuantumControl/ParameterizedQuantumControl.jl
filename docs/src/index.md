```@meta
CurrentModule = ParameterizedQuantumControl
```

# ParameterizedQuantumControl.jl

```@eval
using Markdown
using Pkg

VERSION = Pkg.dependencies()[Base.UUID("409be4c9-afa4-4246-894e-472b92a1ed06")].version

github_badge = "[![Github](https://img.shields.io/badge/JuliaQuantumControl-ParameterizedQuantumControl.jl-blue.svg?logo=github)](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl)"

version_badge = "![v$VERSION](https://img.shields.io/badge/version-v$VERSION-green.svg)"

Markdown.parse("$github_badge $version_badge")
```

Implementation of control methods for analytical parameterized control fields. This includes methods such a CRAB [CanevaPRA2011](@cite) and GOAT [MachnesPRL2018](@cite).

Part of [`QuantumControl.jl`](https://github.com/JuliaQuantumControl/QuantumControl.jl#readme) and the [JuliaQuantumControl](https://github.com/JuliaQuantumControl) organization.

## Contents


```@contents
Depth = 2
Pages = [pair[2] for pair in Main.PAGES[2:end-1]]
```


## History

See the [Releases](https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl/releases) on Github.
