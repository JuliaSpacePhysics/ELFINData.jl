const EPD_URL = FilePattern("$BASE_URL/{probe}/{level}/epd/fast/{head}/{t:yyyy}/{probe}_{level}_{datatype}_{t:yyyymmdd}_v{version}.cdf")

const _EPD_VARIABLE_SPECS = (
    (level="l1", datatype="epdef", variable="pef"),
    (level="l1", datatype="epdif", variable="pif"),
    (level="l2", datatype="epdef", variable="pef_hs_Epat_nflux"),
    (level="l2", datatype="epdef", variable="pef_fs_Epat_nflux"),
    (level="l2", datatype="epdef", variable="pef_hs_Epat_eflux"),
    (level="l2", datatype="epdef", variable="pef_fs_Epat_eflux"),
)

const _EPD_DATASET_SPECS = (
    (level="l1", datatype="epdef"),
    (level="l2", datatype="epdef"),
    (level="l1", datatype="epdif"),
)

# One Dataset per head: the electron head covers L1+L2 epdef, the ion head covers L1 epdif only.
const _EPD_DATASETS = [
    Dataset("{probe|U}_{level|U}_EPDEF", Archive(EPD_URL(; head="electron"), _open);
        selectors=(; probe=("ela", "elb"), level=("l1", "l2"), datatype="epdef")),
    Dataset("{probe|U}_L1_EPDIF", Archive(EPD_URL(; head="ion"), _open);
        selectors=(; probe=("ela", "elb"), level="l1", datatype="epdif")),
]

const EPD = Registry("epd", _EPD_DATASETS; defaults=(probe="ela", level="l1", datatype="epdef"))

for spec in _EPD_DATASET_SPECS, probe in ("ela", "elb")
    name = Symbol(uppercase(probe), "_", uppercase(spec.level), "_", uppercase(spec.datatype))
    @eval const $name = EPD[probe=$probe, level=$(spec.level), datatype=$(spec.datatype)]
end

for spec in _EPD_VARIABLE_SPECS, probe in ("ela", "elb")
    name = Symbol(uppercase(probe), "_", uppercase(spec.variable))
    dataset = Symbol(uppercase(probe), "_", uppercase(spec.level), "_", uppercase(spec.datatype))
    varname = "el$(probe[end])_$(spec.variable)"
    @eval const $name = $dataset[$varname]
end

# Energy bins for EPD (16 channels, log-spaced from ~50 keV to ~5.8 MeV)
# "ela_pef_energies_mean"
const EPD_ENERGY_BINS = Float32[63.2455, 97.9796, 138.564, 183.303, 238.118, 305.205, 385.162, 520.48, 752.994, 1081.67, 1529.71, 2121.32, 2893.96, 3728.61, 4906.12, 6500.0]
const EPD_ENERGY_BINS_MIN = Float32[50.0, 80.0, 120.0, 160.0, 210.0, 270.0, 345.0, 430.0, 630.0, 900.0, 1300.0, 1800.0, 2500.0, 3350.0, 4150.0, 5800.0]
const EPD_ENERGY_BINS_MAX = Float32[80.0, 120.0, 160.0, 210.0, 270.0, 345.0, 430.0, 630.0, 900.0, 1300.0, 1800.0, 2500.0, 3350.0, 4150.0, 5800.0, 8000.0]

const EPD_metadata_patch = Dict(
    :anti => Dict("LABLAXIS" => "anti nflux"),
    :para => Dict("LABLAXIS" => "para nflux"),
    :omni => Dict("LABLAXIS" => "omni nflux"),
    :perp => Dict("LABLAXIS" => "perp nflux"),
    :prec => Dict("LABLAXIS" => "prec nflux")
)

function epd_spectral(args...; probe="ela", type="nflux", datatype="epdef", fullspin=false, Espectra=(;), PAspectra=nothing, kw...)
    res = fullspin ? :fs : :hs
    _data_type = datatype == "epdef" ? "pef" : "pif"
    base_var = "el$(probe[end])_$(_data_type)_$(res)"
    spec_tvar = "$(base_var)_Epat_$(type)"
    ds = EPD[probe=probe, datatype=datatype, level="l2"]
    cdf = getdata(ds, args...; kw...)
    spec_data = cdf[spec_tvar]

    pitch_angles = convert(Array, CDF.dim(spec_data, 1))
    loss_cone = Array(cdf["$(base_var)_LCdeg"])
    S = Array(spec_data)
    energies = convert(Array, CDF.dim(spec_data, 2))
    times = DateTime.(CDF.dim(spec_data, ndims(spec_data)))
    Espectras = epd_l2_Espectra(S, pitch_angles, loss_cone; fullspin, Espectra...)
    metadata = merge(spec_data.attrib, Dict("SCALETYP" => log10, :yscale => log10, :colorrange => (1.0e1, 1.0e7), :ylabel => "Energy (keV)"))

    return if isnothing(PAspectra)
        tdim = Ti(times)
        edim = Energy(vec(energies))
        prec = abs.(Espectras.para .- Espectras.anti)
        ds = DimStack((; Espectras..., prec), (edim, tdim); metadata)
        return maplayers(ds) do da
            rebuild(da, metadata=merge(metadata, get(EPD_metadata_patch, da.name, Dict())))
        end
    else
        sort_flux_by_pitch_angle!(S, pitch_angles)
        PAspectras = epd_l2_PAspectra(S; PAspectra..., kw...)
        merge(
            Espectras,
            PAspectras,
            (; energies, times, pitch_angles)
        )
    end
end

using DimensionalData: YDim, @dim
@dim Energy YDim "Energy"

function epd_l2_Espectra(flux, pitch_angles, loss_cone; fullspin=false, kw...)
    # Determine nspinsectors based on resolution
    res = fullspin ? :fs : :hs
    n_pa = size(pitch_angles, 1)
    nspinsectors = res == :hs ? (n_pa - 2) * 2 : n_pa - 2

    # Calculate tolerances
    FOVo2 = 11.0  # Field of View divided by 2 (deg)
    half_sector_width = 180 / nspinsectors
    para_tol = FOVo2 + half_sector_width
    perp_tol = -FOVo2
    return directional_energy_spectra(flux, pitch_angles, loss_cone; para_tol, perp_tol, half_sector_width, kw...)
end

# Port of PySPEDAS `epd_l2_PAspectra`
function epd_l2_PAspectra(S; energybins=nothing, energies=nothing)
    # Energy bin boundaries (constant from Python code)
    EMINS = EPD_ENERGY_BINS_MIN
    EMAXS = EPD_ENERGY_BINS_MAX
    dE = EMAXS .- EMINS

    # Determine energy channel ranges
    if !isnothing(energybins)
        min_channels = [eb[1] for eb in energybins]
        max_channels = [eb[2] for eb in energybins]
        !isnothing(energies) && @warn "Both energies and energybins are set, 'energybins' takes precedence!"
    elseif !isnothing(energies)
        min_channels = [findfirst(e -> e >= en[1], EPD_ENERGY_BINS) for en in energies]
        max_channels = [findlast(e -> e <= en[2], EPD_ENERGY_BINS) for en in energies]
    else
        # Default energy channels: [(1,3), (4,6), (7,9), (10,16)]
        min_channels = (1, 4, 7, 10)
        max_channels = (3, 6, 9, 16)
    end
    keys = Tuple(Symbol("ch$(i - 1)") for i in 1:length(min_channels))
    values = PAspectra(S, dE, min_channels, max_channels)
    return NamedTuple{keys}(values)
end
