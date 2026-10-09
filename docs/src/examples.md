# Examples

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

spectra = epd_spectral(t0, t1; probe = "ela")[Ti(t0 .. t1)]
tplot([spectra.omni, spectra.anti, spectra.perp, spectra.para]; colormap=:turbo)
```
