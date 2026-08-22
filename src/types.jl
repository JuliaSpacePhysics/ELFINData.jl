abstract type LogicalVariable end

struct ELFINLogicalDataset{N, MD, P} <: AbstractDataSet
    name::N
    probe::Probe
    level::Level
    datatype::String
    url_pattern::P
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
    CDFDataset(files)
end

(ds::ELFINLogicalDataset)(trange::Union{Tuple, Vector, Pair}; kw...) = ds(trange...; kw...)

function (var::ELFINLogicalVariable)(args...; kw...)
    ds = var.dataset(args...; kw...)
    return ds[var.variable]
end

struct ELFINInstrument{D, MD, K} <: AbstractInstrument
    name::String
    datasets::D
    metadata::MD
    defaults::K
end

@noinline function _unknown_dataset_selectors(defaults, kw)
    unknown = setdiff(keys(kw), keys(defaults))
    label = length(unknown) == 1 ? "selector" : "selectors"
    throw(ArgumentError("unknown dataset $label: $(join(unknown, ", "))"))
end

(inst::ELFINInstrument)(; kw...) = select(inst.datasets, inst.defaults; kw...)

function select(datasets::AbstractDict, defaults; kw...)
    for key in keys(kw)
        key in keys(defaults) || _unknown_dataset_selectors(defaults, kw)
    end
    return datasets[merge(defaults, (; kw...))]
end

(inst::ELFINInstrument)(args...; update = false, kw...) = inst(; kw...)(args...; update)
