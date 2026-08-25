"""
    ELFINLogicalDataset

Calling it with a time range downloads the files and opens them; indexing names one of its variables.

```julia
ELA_L1_FGS("2020-10-01", "2020-10-02")   # a CDFDataset
ELA_L1_FGS[:ela_fgs]                     # an ELFINLogicalVariable
```
"""
struct ELFINLogicalDataset{P,S,MD}
    name::Symbol
    url::P
    selectors::S
    metadata::MD
end

function ELFINLogicalDataset(pattern, name, probe::Probe, level::Level, datatype, metadata; kw...)
    url = pattern(; probe=lowercase(string(probe)), level=lowercase(string(level)), datatype, kw...)
    return ELFINLogicalDataset(name, url, (; probe, level, datatype), metadata)
end

struct ELFINLogicalVariable{D<:ELFINLogicalDataset,V}
    dataset::D
    variable::V
end

Base.getindex(ds::ELFINLogicalDataset, variable::Union{Symbol,AbstractString}) =
    ELFINLogicalVariable(ds, variable)

(ds::ELFINLogicalDataset)(t0, t1; version="*", refresh=false, kw...) =
    CDFDataset(localize(remotefiles(ds.url, t0, t1; version, refresh); kw...))

(ds::ELFINLogicalDataset)(trange::Union{Tuple,Vector,Pair}; kw...) = ds(trange...; kw...)

function (var::ELFINLogicalVariable)(args...; kw...)
    ds = var.dataset(args...; kw...)
    return ds[var.variable]
end
