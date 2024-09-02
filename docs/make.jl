using Pkg

DOCUMENTER_VERSION =
    [p for (uuid, p) in Pkg.dependencies() if p.name == "Documenter"][1].version
if DOCUMENTER_VERSION <= v"1.3.0"
    Pkg.develop("Documenter")
end

using QuantumControl
using QuantumPropagators
using ParameterizedQuantumControl
using Documenter
using DocumenterCitations
using DocumenterInterLinks
using Plots

gr()
ENV["GKSwstype"] = "100"


PROJECT_TOML = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
VERSION = PROJECT_TOML["version"]
NAME = PROJECT_TOML["name"]
AUTHORS = join(PROJECT_TOML["authors"], ", ") * " and contributors"
GITHUB = "https://github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl"

DEV_OR_STABLE = "stable/"
if endswith(VERSION, "dev")
    DEV_OR_STABLE = "dev/"
end

links = InterLinks(
    "Julia" => "https://docs.julialang.org/en/v1/",
    "QuantumControl" => "https://juliaquantumcontrol.github.io/QuantumControl.jl/$DEV_OR_STABLE",
    "QuantumPropagators" => "https://juliaquantumcontrol.github.io/QuantumPropagators.jl/$DEV_OR_STABLE",
    "QuantumGradientGenerators" => "https://juliaquantumcontrol.github.io/QuantumGradientGenerators.jl/$DEV_OR_STABLE",
    "QuantumControl" => "https://juliaquantumcontrol.github.io/QuantumControl.jl/$DEV_OR_STABLE",
    "GRAPE" => "https://juliaquantumcontrol.github.io/GRAPE.jl/$DEV_OR_STABLE",
    "Krotov" => "https://juliaquantumcontrol.github.io/Krotov.jl/$DEV_OR_STABLE",
    "Examples" => "https://juliaquantumcontrol.github.io/QuantumControlExamples.jl/$DEV_OR_STABLE",
    "Optimization" => "https://docs.sciml.ai/Optimization/stable/",
    "ComponentArrays" => "https://jonniedie.github.io/ComponentArrays.jl/stable/",
    "RecursiveArrayTools" => "https://docs.sciml.ai/RecursiveArrayTools/stable/",
)

fallbacks = ExternalFallbacks(
    "get_parameters" => "@extref QuantumControl :jl:function:`QuantumPropagators.Controls.get_parameters`",
    "QuantumControl.Generators.Generator" => "@extref QuantumControl :jl:type:`QuantumPropagators.Generators.Generator`",
    "QuantumControl.hamiltonian" => "@extref QuantumControl :jl:function:`QuantumPropagators.Generators.hamiltonian`",
    "QuantumControl.liouvillian" => "@extref QuantumControl :jl:function:`QuantumPropagators.Generators.liouvillian`",
    "QuantumControl.Controls.ParameterizedFunction" => "@extref QuantumControl :jl:type:`QuantumPropagators.Controls.ParameterizedFunction`",
    "QuantumControl.init_prop" => "@extref QuantumControl :jl:function:`QuantumPropagators.init_prop`",
    "QuantumControl.prop_step!" => "@extref QuantumControl :jl:function:`QuantumPropagators.prop_step!`",
)


println("Starting makedocs")

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"); style=:numeric)

PAGES = [
    "Home" => "index.md",
    "Overview" => "overview.md",
    "API" => "api.md",
    "References" => "references.md",
]

makedocs(;
    plugins=[bib, links, fallbacks],
    modules=[ParameterizedQuantumControl],
    authors=AUTHORS,
    sitename="ParameterizedQuantumControl.jl",
    doctest=false,  # we have no doctests (but trying to run them is slow)
    format=Documenter.HTML(;
        prettyurls=true,
        canonical="https://juliaquantumcontrol.github.io/ParameterizedQuantumControl.jl",
        assets=[
            "assets/citations.css",
            asset(
                "https://juliaquantumcontrol.github.io/QuantumControl.jl/dev/assets/topbar/topbar.css"
            ),
            asset(
                "https://juliaquantumcontrol.github.io/QuantumControl.jl/dev/assets/topbar/topbar.js"
            ),
        ],
        mathengine=KaTeX(Dict(:macros => Dict("\\Op" => "\\hat{#1}"))),
        footer="[$NAME.jl]($GITHUB) v$VERSION docs powered by [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).",
    ),
    pages=PAGES,
    warnonly=true,
)

println("Finished makedocs")

deploydocs(;
    repo="github.com/JuliaQuantumControl/ParameterizedQuantumControl.jl",
    devbranch="master"
)
