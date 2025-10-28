```@meta
CurrentModule = ELFINData
```

# ELFINData

`ELFINData.jl` provides a high-level Julia interface to the ELFIN mission's particle and field measurements. The sections below highlight the most common entry points and link to the auto-generated API reference.

```@docs
ELFINData
```

## Quick Start

The examples in this section walk through the typical workflow: discover an instrument's datasets, load data for the specified time range, and request processed data products.

```@example quick_start
using ELFINData

# Inspect the Energetic Particle Detector (EPD) datasets
EPD.datasets
```

From the Julia REPL you can also type `?EPD` to view the [EPD](@ref) documentation.

```@example quick_start
# Load the instrument's datasets (using the logical source name is the most portable approach)
ELA_L1_FGS("2020-10-01", "2020-10-02")
# Alternatively, specify probe and datatype explicitly. This resolves the same logical dataset.
# If no time range is given, the call returns the set of datasets (i.e. `FGM(; probe = "a", datatype = "survey") == ELA_L1_FGS`)
FGM("2020-10-01", "2020-10-02"; probe = "a", datatype = "survey")
```

The following function derives directionally resolved flux spectra (omni, para, anti) and/or pitch-angle spectra from EPD level 2 data with a single call.

```@example quick_start
epd_spectral("2020-10-01", "2020-10-02"; probe = "a")
```

Commonly used variables have concise convenience wrappers. Because these variables are uniquely identified, no additional metadata (such as `probe`, `datatype`, `level`, or `dataset`) is required.

```@example quick_start
ELA_POS_GEI("2020-10-01", "2020-10-02")
ELB_FGS("2020-10-01", "2020-10-02")
ELA_PEF_HS_EPAT_NFLUX("2020-10-01", "2020-10-02")
```

## Instruments

```@docs
EPD
FGM
STATE
```

## Datasets

```@autodocs
Modules = [ELFINData]
Filter = t -> t isa ELFINData.ELFINLogicalDataset
```

## Variables

```@autodocs
Modules = [ELFINData]
Filter = t -> t isa ELFINData.ELFINLogicalVariable
```

## API

```@autodocs
Modules = [ELFINData]
Private = false
Order   = [:function, :type]
```

## Validation and Benchmarking with PySPEDAS

We compare `ELFINData` results against [PySPEDAS](https://pyspedas.readthedocs.io/en/latest/elfin.html) to ensure numerical parity and to track performance. The following benchmarks illustrate the typical workflow.

State variable `ELA_POS_GEI`: Julia is about 200 times faster than Python for this retrieval.

```@example validation
using PySPEDAS
using ELFINData
using Chairmarks

trange = ("2021-08-08", "2021-08-10")
ela_pos_gei = ELA_POS_GEI(trange)
py_ela_pos_gei = Array(PySPEDAS.elfin.state(trange).ela_pos_gei)
@assert ela_pos_gei == py_ela_pos_gei'
@b Array(ELA_POS_GEI(trange)), PySPEDAS.elfin.state(trange), pyspedas.projects.elfin.state(trange)
```

Processing EPD L2 spectra: Julia is about 100 times faster than Python for spectral derivations across the same interval.

```@example validation
trange = ("2020-10-01", "2020-10-02")
nflux_para = epd_spectral(trange).para
py_nflux_para = PySPEDAS.elfin.epd(trange; level = "l2").ela_pef_hs_nflux_para
@assert nflux_para ≈ Array(py_nflux_para)'
b1 = @b epd_spectral($trange)
b2 = @b PySPEDAS.elfin.epd($trange; level = "l2")
@info "Julia" b1
@info "PySPEDAS" b2
```

!!! note "Array layout"

Julia arrays follow the column-major convention used by most CDF files (time is the last dimension), whereas NumPy and PySPEDAS use row-major arrays (time is the first dimension). Transpose the PySPEDAS output before comparing so the dimensions align.
