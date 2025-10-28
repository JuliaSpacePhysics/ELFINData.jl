abstract type LogicalVariable end

struct ELFINLogicalDataset{N, MD} <: AbstractDataSet
    name::N
    probe::Probe
    level::Level
    datatype::String
    url_pattern::String
    metadata::MD
end

function ELFINLogicalDataset(f::Function, name, probe::Probe, level::Level, datatype, metadata; kw...)
    url_pattern = f(probe, datatype; level, kw...)
    return ELFINLogicalDataset(name, probe, level, datatype, url_pattern, metadata)
end

struct ELFINLogicalVariable{V} <: LogicalVariable
    dataset::ELFINLogicalDataset
    variable::V
end


@inline function Base.getproperty(ds::ELFINLogicalDataset, name::Symbol)
    if name in fieldnames(ELFINLogicalDataset)
        return getfield(ds, name)
    else
        ELFINLogicalVariable(ds, name)
    end
end

(ds::ELFINLogicalDataset)(t0, t1; kw...) = begin
    files = download_pattern(ds.url_pattern, t0, t1; kw...)
    ConcatCDFDataset(files)
end

(ds::ELFINLogicalDataset)(trange::Union{Tuple, Vector, Pair}; kw...) = ds(trange...; kw...)

function (var::ELFINLogicalVariable)(args...; kw...)
    ds = var.dataset(args...; kw...)
    return ds[var.variable]
end

struct ELFINInstrument{D, MD, F} <: AbstractInstrument
    name::String
    datasets::D
    metadata::MD
    _lookup::F
end


(inst::ELFINInstrument)(; kw...) = inst._lookup(inst.datasets; kw...)
(inst::ELFINInstrument)(args...; update = false, kw...) = inst(; kw...)(args...; update)
