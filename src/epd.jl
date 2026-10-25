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
    prefix = "el$(probe[end])_$(_data_type)"
    base_var = "$(prefix)_$(res)"
    spec_tvar = "$(base_var)_Epat_$(type)"
    ds = EPD[probe=probe, datatype=datatype, level="l2"]
    cdf = getdata(ds, args...; kw...)
    spec_data = cdf[spec_tvar]

    pitch_angles = convert(Array, CDF.dim(spec_data, 1))
    loss_cone = Array(cdf["$(base_var)_LCdeg"])
    energies = convert(Array, CDF.dim(spec_data, 2))
    times = DateTime.(CDF.dim(spec_data, ndims(spec_data)))
    c = epd_counts(Array(spec_data), Array(cdf["$(base_var)_Epat_dfovf"]), _nsum(cdf, prefix, times))
    S = c.flux
    Espectras = epd_l2_Espectra(S, pitch_angles, loss_cone; fullspin, Espectra...)
    metadata = merge(spec_data.attrib, Dict("SCALETYP" => log10, :yscale => log10, :colorrange => (1.0e1, 1.0e7), :ylabel => "Energy (keV)"))

    return if isnothing(PAspectra)
        tdim = Ti(times)
        edim = Energy(vec(energies))
        south = permutedims(loss_cone .> 90)
        prec = ifelse.(south, Espectras.anti .- Espectras.para, Espectras.para .- Espectras.anti)
        flux = (; Espectras..., prec)
        flux = NamedTuple{keys(flux)}(map(keys(flux), values(flux)) do k, x
            DimArray(x, (edim, tdim); metadata = merge(metadata, get(EPD_metadata_patch, k, Dict())))
        end)
        cnt = epd_directional_counts(c.counts, pitch_angles, loss_cone; fullspin, Espectra...)
        nbad = epd_directional_counts(c.bad, pitch_angles, loss_cone; fullspin, Espectra...)
        aux = map(x -> DimArray(x, (edim, tdim)), (; para_cnt = cnt.para, anti_cnt = cnt.anti, perp_cnt = cnt.perp,
            para_bad = nbad.para, anti_bad = nbad.anti, perp_bad = nbad.perp))
        DimStack((; flux..., aux..., lc = DimArray(loss_cone, tdim)); metadata)
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

# Dead time [s] of the SPEDAS `elf_cal_epd` correction `1 / (1 − R τ)` on the raw total rate `R`
const EPD_DEAD_TIME = 1 / (1.02 * 1.25e5)

# Counts a sector registers at most in one spin: its accumulation time (1/16 of a ~2.8 s spin) over the dead time
const EPD_SECTOR_MAX = 2.8 / 16 / EPD_DEAD_TIME

# L2 fill counts, listed since in multi-spin sums they stay below the cap
const _DFOVF_FILL_COUNTS = (37789, 30676)

_isfill(c) = any(f -> abs(c - f) < 0.5, _DFOVF_FILL_COUNTS)

# `nsum`: spins summed (`nspinsinsum`) per time (last dimension), or a scalar
function epd_counts(F, D, nsum = 1)
    C, bad, G = similar(F, Float64), similar(F, Bool), copy(F)
    for I in CartesianIndices(F)
        f, d = F[I], D[I]
        c = 1 / Float64(d)^2
        flux = isfinite(f) && f > 0
        C[I] = flux && c <= (nsum isa Number ? nsum : nsum[I[ndims(F)]]) * EPD_SECTOR_MAX && !_isfill(c) ? c : 0.0
        bad[I] = flux && C[I] == 0
        bad[I] && (G[I] = NaN)
    end
    return (; counts = C, flux = G, bad)
end

const _FOVo2 = 11.0  # Field of View divided by 2 (deg)

# PySPEDAS `epd_l2_Espectra` tolerances [deg] for `n_pa` pitch-angle bins
function epd_tolerances(n_pa; fullspin = false)
    half_sector_width = 180 / (fullspin ? n_pa - 2 : (n_pa - 2) * 2)
    return (; half_sector_width, para_tol = _FOVo2 + half_sector_width, perp_tol = -_FOVo2)
end

# Sector sums per direction (SPEDAS `elf_getspec, type = 'raw'`), unlike the solid-angle-weighted mean of the fluxes
function epd_directional_counts(C, pitch_angles, loss_cone; fullspin = false, kw...)
    n_pa, n_E, n_t = size(C)
    (; para_tol, perp_tol) = merge(epd_tolerances(n_pa; fullspin), kw)
    T = float(eltype(C))
    para, anti, perp = zeros(T, n_E, n_t), zeros(T, n_E, n_t), zeros(T, n_E, n_t)
    for t in 1:n_t, p in 1:n_pa
        pa, lc = pitch_angles[p, t], loss_cone[t]
        dst = is_parallel(pa, lc, para_tol) ? para : is_anti_parallel(pa, lc, para_tol) ? anti :
            is_perpendicular(pa, lc, perp_tol) ? perp : continue
        for E in 1:n_E
            dst[E, t] += C[p, E, t]
        end
    end
    return (; para, anti, perp)
end

# `nspinsinsum` of the `Et` sector nearest each time `t`
function _nsum(cdf, prefix, t)
    te = DateTime.(Array(cdf["$(prefix)_et_time"]))
    ns = Array(cdf["$(prefix)_nspinsinsum"])
    return map(t) do x
        j = clamp(searchsortedfirst(te, x), 1, length(te))
        k = j > 1 && x - te[j - 1] < te[j] - x ? j - 1 : j
        ns[k]
    end
end

function epd_l2_Espectra(flux, pitch_angles, loss_cone; fullspin=false, kw...)
    tol = epd_tolerances(size(pitch_angles, 1); fullspin)
    return directional_energy_spectra(flux, pitch_angles, loss_cone; tol..., kw...)
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

function epd_sectors(args...; probe = "ela", type = "eflux", kw...)
    prefix = "el$(probe[end])_pef"
    cdf = getdata(EPD[probe = probe, level = "l2"], args...; kw...)
    v = cdf["$(prefix)_Et_$(type)"]
    t = DateTime.(Array(cdf["$(prefix)_et_time"]))
    nsum = Array(cdf["$(prefix)_nspinsinsum"])
    c = epd_counts(Array(v), Array(cdf["$(prefix)_Et_dfovf"]), nsum)
    dt = nsum .* median(Dates.value.(diff(t)) ./ 1000 ./ nsum[2:end])
    d = (Energy(vec(convert(Array, CDF.dim(v, 1)))), Ti(t))
    return DimStack((; flux = DimArray(c.flux, d), counts = DimArray(c.counts, d),
        pa = DimArray(Array(cdf["$(prefix)_pa"]), d[2]), dt = DimArray(dt, d[2])))
end
