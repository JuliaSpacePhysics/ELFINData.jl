```@meta
CurrentModule = ELFINData
```

# ELFINData

[![DOI](https://zenodo.org/badge/1071121579.svg)](https://doi.org/10.5281/zenodo.17500124)
[![version](https://juliahub.com/docs/General/ELFINData/stable/version.svg)](https://juliahub.com/ui/Packages/General/ELFINData)

`ELFINData.jl` provides a high-level Julia interface to the [ELFIN](https://elfin.igpp.ucla.edu/) mission's particle and field measurements. The sections below highlight the most common entry points and link to the auto-generated API reference.

```@docs
ELFINData
```

## Installation

```julia
using Pkg
Pkg.add("ELFINData")
```

An [agent skill](https://agentskills.io) is included for using ELFINData with natural language. To install it using [`skills`](https://github.com/vercel-labs/skills), run:

```sh
npx skills add JuliaSpacePhysics/ELFINData.jl
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

Commonly used variables have concise convenience wrappers. Because these variables are uniquely named, no additional metadata (such as `probe`, `datatype`, `level`, or `dataset`) is required to access them.

```@example quick_start
ELA_POS_GEI("2020-10-01", "2020-10-02")
# Alternative ways to access the same variable: 
# `STATE("2020-10-01", "2020-10-02"; probe = "a")["ela_pos_gei"]` or
# `ELA_L1_STATE("2020-10-01", "2020-10-02")["ela_pos_gei"]`

ELB_FGS("2020-10-01", "2020-10-02")
# Alternative ways to access the same variable: 
# `ELB_L1_FGS("2020-10-01", "2020-10-02")["elb_fgs"]` or 
# `FGM("2020-10-01", "2020-10-02"; probe = "b", datatype = "survey")["elb_fgs"]`

ELA_PEF_HS_EPAT_NFLUX("2020-10-01", "2020-10-02")
# Alternative ways to access the same variable: 
# `ELA_L2_EPDEF("2020-10-01", "2020-10-02")["ela_pef_hs_Epat_nflux"]` or 
# `EPD("2020-10-01", "2020-10-02"; probe = "a", level = "l2", datatype = "epdef")["ela_pef_hs_Epat_nflux"]`
```

## Quick Plots

```@example quick_plot
using ELFINData
using Dates
using ELFINData.DimensionalData
using SpacePhysicsMakie, WGLMakie
using Bonito # hide
Page() # hide

# https://data.elfin.ucla.edu/ela/overplots/2022/09/05/ela_l2_overview_20220905_10_ndes.gif
t0 = DateTime("2022-09-05T10:00:00")
t1 = DateTime("2022-09-05T10:30:00")

# Example: plot EPD flux spectra
spectra = epd_spectral(t0, t1; probe = "a")[Ti(t0 .. t1)]
tplot(degap.([spectra.omni, spectra.anti, spectra.perp, spectra.para]); colormap=:turbo)
```

## API

### Instruments

```@docs
EPD
FGM
STATE
```

### Datasets

```@autodocs
Modules = [ELFINData]
Filter = t -> t isa ELFINData.ELFINLogicalDataset
```

### Variables

```@autodocs
Modules = [ELFINData]
Filter = t -> t isa ELFINData.ELFINLogicalVariable
```

### Functions and Types

```@autodocs
Modules = [ELFINData]
Private = false
Order   = [:function, :type]
```