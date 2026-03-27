# Validation and Benchmark with PySPEDAS

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
