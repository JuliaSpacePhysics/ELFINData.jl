module ELFINData
using DimensionalData
using CDFDatasets
using CDFDatasets: CDFDataset
import CDFDatasets.CommonDataModel as CDM
import CDFDatasets as CDF
using SpaceDataModel: Registry, Dataset, Archive, FilePattern, Product, getdata, localize
using IntervalSets: Interval
using VelocityDistributionFunctions: directional_energy_spectra, PAspectra, sort_flux_by_pitch_angle!
using Dates

export ELA_L1_EPDEF, ELB_L1_EPDEF, ELA_L2_EPDEF, ELB_L2_EPDEF, ELA_L1_EPDIF, ELB_L1_EPDIF,
    ELA_PEF, ELB_PEF, ELA_PIF, ELB_PIF,
    ELA_PEF_HS_EPAT_NFLUX, ELB_PEF_HS_EPAT_NFLUX, ELA_PEF_FS_EPAT_NFLUX, ELB_PEF_FS_EPAT_NFLUX,
    ELA_PEF_HS_EPAT_EFLUX, ELB_PEF_HS_EPAT_EFLUX, ELA_PEF_FS_EPAT_EFLUX, ELB_PEF_FS_EPAT_EFLUX
export ELA_L1_FGS, ELB_L1_FGS, ELA_FGS, ELB_FGS
export ELA_L1_FGF, ELB_L1_FGF
export ELA_L1_STATE, ELB_L1_STATE, ELA_POS_GEI, ELB_POS_GEI
export ELA_L1_MRMA, ELB_L1_MRMA, ELA_L1_MRMI, ELB_L1_MRMI
export ELA_MRMA, ELB_MRMA, ELA_MRMI, ELB_MRMI
export EPD, FGM, STATE
export epd_spectral
export science_zones
export EPD_DATA_NOTES, epd_data_notes
export getdata

const BASE_URL = "https://data.elfin.ucla.edu"
const OVERPLOTS_URL = FilePattern("$BASE_URL/{probe}/overplots/{t:yyyy}/{t:mm}/{t:dd}/{probe}_{level}_overview_{t:yyyymmdd}_{datatype}.gif")

# ELFIN files carry placeholder VALIDMIN/VALIDMAX (e.g. 0..1e6 on EPD fluxes, ±1e6 on L1 FGM, which
# reaches ±5e6), so only FILLVAL marks invalid values.
const _CHECKS = (; validmin = nothing, validmax = nothing)
_open(files, t0, t1) = view(cdfopen(files; checks = _CHECKS), Interval{:closed,:open}(t0, t1))

include("epd.jl")
include("fgm.jl")
include("mrmx.jl")
include("state.jl")
include("science_zone.jl")
include("data_notes.jl")

function flux_ratio(prec, trap)
    f = prec ./ trap
    metadata = copy(prec.metadata)
    metadata[:colorrange] = (1.0e-2, 1)
    metadata["UNITS"] = ""
    return rebuild(f; metadata)
end

flux_ratio(ds::DimStack) = flux_ratio(ds.prec, ds.perp)

end
