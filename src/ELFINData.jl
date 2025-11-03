"""
Load and process data from the Electron Losses and Fields INvestigation (ELFIN) mission.

# Instruments
- [Fluxgate Magnetometer (FGM)](@ref FGM)
- [Energetic Particle Detector (EPD)](@ref EPD)
- Magneto Resistive Magnetometer-a (MRMa)
- Magneto Resistive Magnetometer-i (MRMi)
- [State data (state)](@ref STATE)
- Engineering data (ENG)

# Functions
- [`epd_spectral`](@ref epd_spectral): Load ELFIN EPD L2 data and extract directionally resolved flux spectra (omni, para, anti) and/or pitch angle spectra.

References: [Website](https://elfin.igpp.ucla.edu/), [NASA Science](https://science.nasa.gov/mission/elfin/), [Wikipedia](https://en.wikipedia.org/wiki/ELFIN), [DOI](https://doi.org/10.1007/s11214-020-00721-7)
"""
module ELFINData
using DimensionalData
using CDFDatasets
using CDFDatasets: CDFDataset
import CDFDatasets.CommonDataModel as CDM
import CDFDatasets as CDF
using SpaceDataModel: AbstractInstrument, AbstractDataSet
using Downloads: request
using VelocityDistributionFunctions: directional_energy_spectra, PAspectra, sort_flux_by_pitch_angle!
using Dates
using URIs

export ELA_L1_EPDEF, ELB_L1_EPDEF, ELA_L2_EPDEF, ELB_L2_EPDEF, ELA_L1_EPDIF, ELB_L1_EPDIF,
    ELA_PEF, ELB_PEF, ELA_PIF, ELB_PIF,
    ELA_PEF_HS_EPAT_NFLUX, ELB_PEF_HS_EPAT_NFLUX, ELA_PEF_FS_EPAT_NFLUX, ELB_PEF_FS_EPAT_NFLUX,
    ELA_PEF_HS_EPAT_EFLUX, ELB_PEF_HS_EPAT_EFLUX, ELA_PEF_FS_EPAT_EFLUX, ELB_PEF_FS_EPAT_EFLUX
export ELA_L1_FGS, ELB_L1_FGS, ELA_FGS, ELB_FGS
export ELA_L1_STATE, ELB_L1_STATE, ELA_POS_GEI, ELB_POS_GEI
export ELA_L1_MRMA, ELB_L1_MRMA, ELA_L1_MRMI, ELB_L1_MRMI
export ELA_MRMA, ELB_MRMA, ELA_MRMI, ELB_MRMI
export EPD, FGM, STATE
export epd_spectral

const BASE_URL = "https://data.elfin.ucla.edu"

@enum Probe begin
    ELA
    ELB
end

@enum Level begin
    L1
    L2
end

include("types.jl")
include("url_pattern.jl")
include("epd.jl")
include("fgm.jl")
include("mrmx.jl")
include("state.jl")
include("utils.jl")


"""
Precipitating-to-trapped flux ratio
"""
function flux_ratio(prec, trap)
    f = prec ./ trap
    metadata = copy(prec.metadata)
    metadata[:colorrange] = (1.0e-2, 1)
    metadata["UNITS"] = ""
    return rebuild(f; metadata)
end

flux_ratio(ds::DimStack) = flux_ratio(ds.prec, ds.perp)

end
