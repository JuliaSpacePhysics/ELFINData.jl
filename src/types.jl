"""
    ELFINLogicalDataset

Calling it with a time range downloads the files and opens them; indexing names one of its variables.

```julia
ELA_L1_FGS("2020-10-01", "2020-10-02")   # a CDFDataset
ELA_L1_FGS[:ela_fgs]                     # an ELFINLogicalVariable
```
"""
struct ELFINLogicalDataset{MD,P} <: AbstractDataSet
    name::Symbol
    probe::Probe
    level::Level
    datatype::String
    url_pattern::P
    metadata::MD
end

function ELFINLogicalDataset(pattern, name, probe::Probe, level::Level, datatype, metadata; kw...)
    url_pattern = pattern(;
        probe=lowercase(string(probe)), level=lowercase(string(level)), datatype, kw...
    )
    return ELFINLogicalDataset(name, probe, level, datatype, url_pattern, metadata)
end

struct ELFINLogicalVariable{D<:ELFINLogicalDataset,V}
    dataset::D
    variable::V
end

Base.getindex(ds::ELFINLogicalDataset, variable::Union{Symbol,AbstractString}) =
    ELFINLogicalVariable(ds, variable)

(ds::ELFINLogicalDataset)(t0, t1; version="*", refresh=false, kw...) =
    CDFDataset(localize(remotefiles(ds.url_pattern, t0, t1; version, refresh); kw...))

(ds::ELFINLogicalDataset)(trange::Union{Tuple,Vector,Pair}; kw...) = ds(trange...; kw...)

function (var::ELFINLogicalVariable)(args...; kw...)
    ds = var.dataset(args...; kw...)
    return ds[var.variable]
end

struct ELFINInstrument{D,MD,K} <: AbstractInstrument
    name::String
    datasets::D
    metadata::MD
    defaults::K
end

(inst::ELFINInstrument)(; kw...) = select(inst; kw...)
(inst::ELFINInstrument)(args...; update=false, kw...) = inst(; kw...)(args...; update)

function select(inst::ELFINInstrument; kw...)
    defaults = inst.defaults
    for key in keys(kw)
        key in keys(defaults) || _unknown_dataset_selectors(inst, kw)
    end
    key = merge(defaults, (; kw...))
    haskey(inst.datasets, key) || _no_such_dataset(inst, key)
    return inst.datasets[key]
end

@noinline function _unknown_dataset_selectors(inst, kw)
    unknown = setdiff(keys(kw), keys(inst.defaults))
    label = length(unknown) == 1 ? "selector" : "selectors"
    known = join(keys(inst.defaults), ", ")
    throw(ArgumentError("$(inst.name): unknown dataset $label: $(join(unknown, ", ")). Known: $known"))
end

@noinline function _no_such_dataset(inst, key)
    _selectors(nt) = join(("$k=$(repr(v))" for (k, v) in pairs(nt)), " ")

    opts = join(sort!(["  $(_selectors(k)): $(inst.datasets[k].name)" for k in keys(inst.datasets)]), "\n")
    throw(
        ArgumentError(
            """
            $(inst.name): no dataset for $(_selectors(key)).
            Available:
            $opts"""
        )
    )
end
