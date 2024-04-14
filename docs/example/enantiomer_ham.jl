module EnantiomerHams

using ComponentArrays: ComponentVector, Axis
using UnPack: @unpack
const 𝕚 = 1im

struct EnantiomerHam
    a::Float64
    sign::Int64
    parameters::ComponentVector{
        Float64,
        Vector{Float64},
        Tuple{Axis{(ΔT₁=1, ΔT₂=2, ΔT₃=3, ϕ₁=4, ϕ₂=5, ϕ₃=6, E₀₁=7, E₀₂=8, E₀₃=9)}}
    }
end

function EnantiomerHam(; a=1000.0, sign=1, kwargs...)
    EnantiomerHam(a, sign, ComponentVector(; kwargs...))
end

function EnantiomerHam(parameters; a=1000.0, sign=1)
    EnantiomerHam(a, sign, parameters)
end

import QuantumControl.Controls:
    get_controls, evaluate, evaluate!, get_parameters, get_control_deriv

get_controls(::EnantiomerHam) = tuple()

function evaluate(G::EnantiomerHam, args...; kwargs...)
    H = zeros(ComplexF64, 3, 3)
    evaluate!(H, G, args...; kwargs...)
end

# Midpoint of n'th interval of tlist, but snap to beginning/end (that's
# because any S(t) is likely exactly zero at the beginning and end, and we
# want to use that value for the first and last time interval)
function _t(tlist, n)
    @assert 1 <= n <= (length(tlist) - 1)  # n is an *interval* of `tlist`
    if n == 1
        t = tlist[begin]
    elseif n == length(tlist) - 1
        t = tlist[end]
    else
        dt = tlist[n+1] - tlist[n]
        t = tlist[n] + dt / 2
    end
    return t
end

E(t; E₀, t₁, t₂, a) = (E₀ / 2) * (tanh(a * (t - t₁)) - tanh(a * (t - t₂)))

function evaluate!(H, G::EnantiomerHam, tlist, n; _...)
    t = _t(tlist, n)
    evaluate!(H, G, t)
end

function evaluate!(H, G::EnantiomerHam, t; _...)
    @unpack a, sign = G
    @unpack ΔT₁, ΔT₂, ΔT₃, ϕ₁, ϕ₂, ϕ₃, E₀₁, E₀₂, E₀₃ = G.parameters
    T₁ = ΔT₁
    T₂ = ΔT₁ + ΔT₂
    T₃ = ΔT₁ + ΔT₂ + ΔT₃
    μ = sign
    E₁ = E(t; E₀=E₀₁, t₁=0.0, t₂=T₁, a)
    E₂ = E(t; E₀=E₀₂, t₁=T₁, t₂=T₂, a)
    E₃ = E(t; E₀=E₀₃, t₁=T₂, t₂=T₃, a)
    copyto!(
        H,
        µ * [
                    0.0           E₁*exp(𝕚 * ϕ₁)     E₃*exp(𝕚 * ϕ₃)
            E₁*exp(-𝕚 * ϕ₁)           0.0          E₂*exp(𝕚 * ϕ₂)
            E₃*exp(-𝕚 * ϕ₃)     E₂*exp(-𝕚 * ϕ₂)           0.0
        ]
    )
    return H
end

get_parameters(G::EnantiomerHam) = G.parameters

get_control_deriv(G::EnantiomerHam, ::Any) = nothing  # does not have controls

end
