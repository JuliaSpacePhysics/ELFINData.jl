using Chairmarks
@time using ELFINData
@time epd_spectral("2020-10-01", "2020-10-02"; probe = "ela")
@info @b epd_spectral("2020-10-01", "2020-10-02"; probe = "ela")
# 1.219 ms (1828 allocs: 1.904 MiB)
