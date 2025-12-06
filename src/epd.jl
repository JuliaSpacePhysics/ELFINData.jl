"""ELFIN A *L1* EPD Electron Counts (Version 1)"""
const ELA_L1_EPDEF = ELFINLogicalDataset(_epd_pattern, :ELA_L1_EPDEF, ELA, L1, "epdef", Dict(); version = 1)

"""ELFIN B *L1* EPD Electron Counts (Version 1)"""
const ELB_L1_EPDEF = ELFINLogicalDataset(_epd_pattern, :ELB_L1_EPDEF, ELB, L1, "epdef", Dict(); version = 1)

"""
ELFIN A L2 EPD Electron Counts (Version 1)

Main data variables: [`ELA_PEF_HS_EPAT_NFLUX`](@ref), [`ELA_PEF_FS_EPAT_NFLUX`](@ref), [`ELA_PEF_HS_EPAT_EFLUX`](@ref), [`ELA_PEF_FS_EPAT_EFLUX`](@ref)
"""
const ELA_L2_EPDEF = ELFINLogicalDataset(_epd_pattern, :ELA_L2_EPDEF, ELA, L2, "epdef", Dict(); version = 1)

"""
ELFIN B L2 EPD Electron Counts (Version 1)

Main data variables: [`ELB_PEF_HS_EPAT_NFLUX`](@ref), [`ELB_PEF_FS_EPAT_NFLUX`](@ref), [`ELB_PEF_HS_EPAT_EFLUX`](@ref), [`ELB_PEF_FS_EPAT_EFLUX`](@ref)
"""
const ELB_L2_EPDEF = ELFINLogicalDataset(_epd_pattern, :ELB_L2_EPDEF, ELB, L2, "epdef", Dict(); version = 1)

"""ELFIN A *L1* EPD Ion Counts (Version 1)"""
const ELA_L1_EPDIF = ELFINLogicalDataset(_epd_pattern, :ELA_L1_EPDIF, ELA, L1, "epdif", Dict(:description => "[UNCALIBRATED RAW DATA ONLY] Energetic Partical Detector Energy Particles, Ions>keV"); version = 1)

"""ELFIN B *L1* EPD Ion Counts (Version 1)"""
const ELB_L1_EPDIF = ELFINLogicalDataset(_epd_pattern, :ELB_L1_EPDIF, ELB, L1, "epdif", Dict(:description => "[UNCALIBRATED RAW DATA ONLY] Energetic Partical Detector Energy Particles, Ions>keV"); version = 1)
# EPD variables
const ELA_PEF = ELFINLogicalVariable(ELA_L1_EPDEF, "ela_pef")
const ELB_PEF = ELFINLogicalVariable(ELB_L1_EPDEF, "elb_pef")
const ELA_PIF = ELFINLogicalVariable(ELA_L1_EPDIF, "ela_pif")
const ELB_PIF = ELFINLogicalVariable(ELB_L1_EPDIF, "elb_pif")
"""ELFIN A EnergyPitchAngleTime spectra nflux, half spin resolution"""
const ELA_PEF_HS_EPAT_NFLUX = ELFINLogicalVariable(ELA_L2_EPDEF, "ela_pef_hs_Epat_nflux")
"""ELFIN B EnergyPitchAngleTime spectra nflux, half spin resolution"""
const ELB_PEF_HS_EPAT_NFLUX = ELFINLogicalVariable(ELB_L2_EPDEF, "elb_pef_hs_Epat_nflux")
"""ELFIN A EnergyPitchAngleTime spectra nflux, full spin resolution"""
const ELA_PEF_FS_EPAT_NFLUX = ELFINLogicalVariable(ELA_L2_EPDEF, "ela_pef_fs_Epat_nflux")
"""ELFIN B EnergyPitchAngleTime spectra nflux, full spin resolution"""
const ELB_PEF_FS_EPAT_NFLUX = ELFINLogicalVariable(ELB_L2_EPDEF, "elb_pef_fs_Epat_nflux")
"""ELFIN A EnergyPitchAngleTime spectra eflux, half spin resolution"""
const ELA_PEF_HS_EPAT_EFLUX = ELFINLogicalVariable(ELA_L2_EPDEF, "ela_pef_hs_Epat_eflux")
"""ELFIN B EnergyPitchAngleTime spectra eflux, half spin resolution"""
const ELB_PEF_HS_EPAT_EFLUX = ELFINLogicalVariable(ELB_L2_EPDEF, "elb_pef_hs_Epat_eflux")
"""ELFIN A EnergyPitchAngleTime spectra eflux, full spin resolution"""
const ELA_PEF_FS_EPAT_EFLUX = ELFINLogicalVariable(ELA_L2_EPDEF, "ela_pef_fs_Epat_eflux")
"""ELFIN B EnergyPitchAngleTime spectra eflux, full spin resolution"""
const ELB_PEF_FS_EPAT_EFLUX = ELFINLogicalVariable(ELB_L2_EPDEF, "elb_pef_fs_Epat_eflux")

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

# EPD instrument
"""
Energetic Particle Detector (EPD)

> The EPD consists of two heads: an electron head that measures 50 keV to 5 MeV electrons and an ion head that measures 50 to 5000 keV ions.

Datasets: 
- ELFIN A: [`ELA_L1_EPDEF`](@ref), [`ELA_L1_EPDIF`](@ref), [`ELA_L2_EPDEF`](@ref)
- ELFIN B: [`ELB_L1_EPDEF`](@ref), [`ELB_L1_EPDIF`](@ref), [`ELB_L2_EPDEF`](@ref)
"""
const EPD = ELFINInstrument(
    "epd", Dict(
        ("a", "l1", "epdef") => ELA_L1_EPDEF,
        ("b", "l1", "epdef") => ELB_L1_EPDEF,
        ("a", "l1", "epdif") => ELA_L1_EPDIF,
        ("b", "l1", "epdif") => ELB_L1_EPDIF,
        ("a", "l2", "epdef") => ELA_L2_EPDEF,
        ("b", "l2", "epdef") => ELB_L2_EPDEF,
    ), Dict(
        "energies_mean" => EPD_ENERGY_BINS,
        "energies_min" => EPD_ENERGY_BINS_MIN,
        "energies_max" => EPD_ENERGY_BINS_MAX,
    ), (datasets; probe = "a", level = "l1", datatype = "epdef") -> datasets[(probe, level, datatype)]
)

"""
    epd_spectral(trange; probe = "a", type = "nflux", datatype = "epdef", fullspin = false)

Load ELFIN EPD L2 data and process it to extract directionally resolved flux spectra (omni, para, anti) and/or pitch angle spectra.

Returns a NamedTuple-like container with omni, para, anti, and prec flux spectra.

```julia
epd_spectral("2020-10-01", "2020-10-02")
```
"""
function epd_spectral(args...; probe = "a", type = "nflux", datatype = "epdef", fullspin = false, Espectra = (;), PAspectra = nothing, kw...)
    res = fullspin ? :fs : :hs
    _data_type = datatype == "epdef" ? "pef" : "pif"
    base_var = "el$(probe)_$(_data_type)_$(res)"
    spec_tvar = "$(base_var)_Epat_$(type)"
    datasets = EPD(args...; probe, datatype, level = "l2")
    spec_data = datasets[spec_tvar]

    pitch_angles = CDF.dim(spec_data, 1)
    loss_cone = Array(datasets["$(base_var)_LCdeg"])
    S = Array(spec_data)
    energies = CDF.dim(spec_data, 2)
    times = DateTime.(CDF.dim(spec_data, ndims(spec_data)))
    Espectras = epd_l2_Espectra(S, pitch_angles, loss_cone; fullspin, Espectra...)
    metadata = merge(spec_data.attrib, Dict("SCALETYP" => log10, :yscale => log10, :colorrange => (1.0e1, 1.0e7), :ylabel => "Energy (keV)"))

    return if isnothing(PAspectra)
        tdim = Ti(times)
        edim = Energy(vec(energies))
        prec = abs.(Espectras.para .- Espectras.anti)
        ds = DimStack((; Espectras..., prec), (edim, tdim); metadata)
        return maplayers(ds) do da
            rebuild(da, metadata = merge(metadata, get(EPD_metadata_patch, da.name, Dict())))
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

function epd_l2_Espectra(flux, pitch_angles, loss_cone; fullspin = false, kw...)
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

"""
    epd_l2_PAspectra(S; energybins=nothing, energies=nothing)

Process EPD L2 CDF data to create pitch angle spectra following Python epd_l2_PAspectra logic.

# Arguments
- `S`: 3D spectral data (time × pitch_angle × energy)
- `energybins`: List of tuples specifying energy channel ranges, e.g., [(0,2), (3,5), (6,8), (9,15)]
- `energies`: List of tuples specifying energy ranges in keV, e.g., [(50,160), (160,345), (345,900), (900,7000)]

# Returns
- Named tuple containing pitch angle spectra for each energy channel
"""
function epd_l2_PAspectra(S; energybins = nothing, energies = nothing)
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
