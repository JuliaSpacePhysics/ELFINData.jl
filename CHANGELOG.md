# Changelog

## [0.3.0]

### Breaking

- `epd_spectral`: `prec` is the downgoing minus the upgoing flux with the hemisphere from the loss cone (was `abs(para - anti)`), and impossible L2 cells (fill `dfovf`, flux without counts) are blanked from the fluxes.

### Added

- `epd_spectral` layers: sector-summed counts `para_cnt`, `anti_cnt`, `perp_cnt`; blanked cells `para_bad`, `anti_bad`, `perp_bad`; loss cone `lc`.
- `epd_sectors`: per-sector `Et` spectra and counts.

## [0.2.0]

### Breaking

- Requires SpaceDataModel 0.4 / CDFDatasets 0.3.
- Probes are `"ela"` / `"elb"` (was `"a"` / `"b"`).
- Instruments select datasets instead of loading: `EPD[probe = "ela", level = "l2"]`.

### Added

- `science_zones(probe)`: EPD science-zone start/end times.
- `epd_data_notes(probe, t0, t1)`, `EPD_DATA_NOTES`: documented EPD data-quality intervals.
- FGM fast-survey datasets `ELA_L1_FGF`, `ELB_L1_FGF`.
