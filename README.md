# ELFINData

[![DOI](https://zenodo.org/badge/1071121579.svg)](https://doi.org/10.5281/zenodo.17500124)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/ELFINData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/ELFINData.jl)

Load and process data from the Electron Losses and Fields Investigation (ELFIN) mission.

References: [Website](https://elfin.igpp.ucla.edu/), [NASA Science](https://science.nasa.gov/mission/elfin/), [Wikipedia](https://en.wikipedia.org/wiki/ELFIN), [DOI](https://doi.org/10.1007/s11214-020-00721-7)

## Quickstart

```julia
using Pkg; Pkg.add("ELFINData")
using ELFINData

trange = ("2020-10-01", "2020-10-02")

# High-level instrument access
EPD(trange; probe="a")                        # Energetic Particle Detector
FGM(trange; probe="a", datatype="survey")     # Fluxgate Magnetometer
STATE(trange; probe="a")                      # Spacecraft state/position

# Spectral analysis, returns DimStack with omni/para/anti/perp/prec variables
spectra = epd_spectral(trange)
spectra.para          # precipitating spectrum (Energy × Time)
spectra.omni[:, 1]    # all energies at first time step

# Precipitating-to-trapped flux ratio
ratio = flux_ratio(trange; probe="a")

# Raw L1 dataset
ds = ELA_L1_EPDEF(trange)
flux = ds["ela_pef"]  # raw electron flux

# Direct variable access
fgs = ELA_FGS(trange)       # B field DimArray
pos = ELA_POS_GEI(trange)   # GEI position DimArray

# Time filtering (DimensionalData.jl)
using DimensionalData, Dates
spectra[Ti(DateTime("2020-10-01T06:00") .. DateTime("2020-10-01T07:00"))]
```

## Key conventions

- **Time is the last dimension**
- **Probe** is always a string: `"a"` or `"b"`
- EPD has 16 log-spaced energy channels: ~63–6500 keV

### Dataset constants

Call with `trange`; returns a `CDFDataset` (dict-like):

| Constant                        | Contents                                            |
| ------------------------------- | --------------------------------------------------- |
| `ELA_L1_EPDEF` / `ELB_L1_EPDEF` | L1 electron flux (raw)                              |
| `ELA_L1_EPDIF` / `ELB_L1_EPDIF` | L1 ion flux                                         |
| `ELA_L2_EPDEF` / `ELB_L2_EPDEF` | L2 electron flux (calibrated, pitch-angle resolved) |
| `ELA_L1_FGS` / `ELB_L1_FGS`     | L1 magnetometer survey                              |
| `ELA_L1_STATE` / `ELB_L1_STATE` | L1 spacecraft state                                 |

### Variable constants

Call with trange; return a `DimArray` directly:

| Constant                      | Contents                  |
| ----------------------------- | ------------------------- |
| `ELA_PEF` / `ELB_PEF`         | Electron flux (L1)        |
| `ELA_PIF` / `ELB_PIF`         | Ion flux (L1)             |
| `ELA_FGS` / `ELB_FGS`         | 3-component B field (nT)  |
| `ELA_POS_GEI` / `ELB_POS_GEI` | Spacecraft position (GEI) |
| `ELA_MRMA` / `ELB_MRMA`       | MRM-A magnetometer        |
| `ELA_MRMI` / `ELB_MRMI`       | MRM-I magnetometer        |

### L2 spectral variables

| Constant                           | Description                                  |
| ---------------------------------- | -------------------------------------------- |
| `ELA_PEF_HS_EPAT_NFLUX`            | Half-spin, number flux, pitch-angle × energy |
| `ELA_PEF_FS_EPAT_NFLUX`            | Full-spin equivalent                         |
| `ELA_PEF_HS_EPAT_EFLUX`            | Half-spin, energy flux                       |
| (ELB variants follow same pattern) |    

## Elsewhere

- [PySPEDAS](https://pyspedas.readthedocs.io/en/latest/elfin.html) ([GitHub](https://github.com/spedas/pyspedas/tree/master/pyspedas/projects/elfin))