# ELFINData

[![DOI](https://zenodo.org/badge/1071121579.svg)](https://doi.org/10.5281/zenodo.17500124)

Load and process data from the Electron Losses and Fields Investigation (ELFIN) mission.

References: [Website](https://elfin.igpp.ucla.edu/), [NASA Science](https://science.nasa.gov/mission/elfin/), [Wikipedia](https://en.wikipedia.org/wiki/ELFIN), [DOI](https://doi.org/10.1007/s11214-020-00721-7)

## Quickstart

```julia
using Pkg; Pkg.add("ELFINData")
using ELFINData

# Instruments are registries of datasets, selected by keyword
EPD[probe = "ela", level = "l2"]                      # Energetic Particle Detector
FGM[probe = "ela", datatype = "survey"]               # Fluxgate Magnetometer
STATE[probe = "ela"]                                  # Spacecraft state/position

trange = ("2020-10-01", "2020-10-02")

# EPD L2 spectra: DimStack of omni/para/anti/perp/prec (Energy × Time)
spectra = epd_spectral(trange)
spectra.para
spectra.omni[:, 1]

# Precipitating-to-trapped flux ratio (prec ./ perp)
ratio = ELFINData.flux_ratio(spectra)

# EPD science zone start/end times: (; tstart, tend)
zones = science_zones("ela")

# Documented EPD data-quality issues overlapping an interval (empty when clean)
epd_data_notes("ela", "2022-04-01", "2022-04-02")

# Datasets and variables load with `getdata(x, t0, t1)` or by calling `x(t0, t1)`
ds = ELA_L1_EPDEF(trange)   # CDFDataset
ds["ela_pef"]               # raw counts per sector
fgs = ELA_FGS(trange)       # CDFVariable (lazy, DimArray-like)

# Time filtering (DimensionalData.jl)
using DimensionalData, Dates
spectra[Ti(DateTime("2020-10-01T06:00") .. DateTime("2020-10-01T07:00"))]
```

## Key conventions

- **Time is the last dimension**
- **Probe** is `"ela"` or `"elb"`
- EPD has an electron head (50 keV–5 MeV) and an ion head (50–5000 keV); 16 log-spaced energy channels, mean energies ~63–6500 keV
- Only `FILLVAL` reads as `NaN`: ELFIN files carry placeholder `VALIDMIN`/`VALIDMAX` (e.g. 0..1e6 on EPD fluxes, which exceed it), so those bounds are not applied

## API

### Functions

- `epd_spectral(t0, t1; probe = "ela", type = "nflux", datatype = "epdef", fullspin = false, PAspectra = nothing)`: `type` is `"nflux"` or `"eflux"`; `fullspin` selects full- over half-spin resolution; `Espectra` keywords pass to `VelocityDistributionFunctions.directional_energy_spectra`. With `PAspectra` a NamedTuple, it instead returns a NamedTuple of the energy spectra, pitch-angle spectra `ch0, ch1, …`, `energies`, `times` and `pitch_angles`; each is the energy-width-weighted mean over `energybins = [(1, 3), (4, 6)]` (channel indices) or `energies = [(50, 160), (160, 345)]` (keV), defaulting to channels 1–3, 4–6, 7–9, 10–16.
- `science_zones(probe = "ela")`: EPD science zone times from the probe's `epd_science_zone_times.csv`.
- `epd_data_notes(probe, t0, t1; head = "e")`: entries of `EPD_DATA_NOTES` (from <https://elfin.igpp.ucla.edu/data-notes>) for head `"e"` (electron) or `"i"` (ion) overlapping `[t0, t1)`.

### Instruments

| Registry | Selectors (default first)                                   |
| -------- | ----------------------------------------------------------- |
| `EPD`    | `probe`, `level` (`"l1"`, `"l2"`), `datatype` (`"epdef"`, `"epdif"`; ion is L1 only) |
| `FGM`    | `probe`, `datatype` (`"survey"`, `"fast"`)                  |
| `STATE`  | `probe`                                                     |

### Dataset constants

| Constant                        | Contents                                            |
| ------------------------------- | --------------------------------------------------- |
| `ELA_L1_EPDEF` / `ELB_L1_EPDEF` | L1 electron counts                                  |
| `ELA_L1_EPDIF` / `ELB_L1_EPDIF` | L1 ion counts                                       |
| `ELA_L2_EPDEF` / `ELB_L2_EPDEF` | L2 electron flux (calibrated, pitch-angle resolved) |
| `ELA_L1_FGS` / `ELB_L1_FGS`     | L1 magnetometer, survey mode                        |
| `ELA_L1_FGF` / `ELB_L1_FGF`     | L1 magnetometer, fast survey mode                   |
| `ELA_L1_MRMA` / `ELB_L1_MRMA`   | L1 MRM data collected by the ACB                    |
| `ELA_L1_MRMI` / `ELB_L1_MRMI`   | L1 MRM data collected by the IDPU                   |
| `ELA_L1_STATE` / `ELB_L1_STATE` | L1 spacecraft state                                 |

### Variable constants

| Constant                      | Contents                               |
| ----------------------------- | -------------------------------------- |
| `ELA_PEF` / `ELB_PEF`         | Electron counts per sector (L1, raw)   |
| `ELA_PIF` / `ELB_PIF`         | Ion counts per sector (L1, raw)        |
| `ELA_FGS` / `ELB_FGS`         | B field, sensor XYZ, survey mode;      |
| `ELA_POS_GEI` / `ELB_POS_GEI` | Spacecraft position (km, GEI)          |
| `ELA_MRMA` / `ELB_MRMA`       | MRM B field (ADC units), sensor XYZ    |
| `ELA_MRMI` / `ELB_MRMI`       | MRM B field (ADC units), sensor XYZ    |

L2 energy–pitch-angle–time spectra: `EL{A,B}_PEF_{HS,FS}_EPAT_{NFLUX,EFLUX}` (half/full spin resolution, number/energy flux).

## Elsewhere

- [PySPEDAS](https://pyspedas.readthedocs.io/en/latest/elfin.html) ([GitHub](https://github.com/spedas/pyspedas/tree/master/pyspedas/projects/elfin))
