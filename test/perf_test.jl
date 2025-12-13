using Chairmarks
@time using ELFINData
@time epd_spectral("2020-10-01", "2020-10-02"; probe = "a")
@info @b epd_spectral("2020-10-01", "2020-10-02"; probe = "a")
# 1.219 ms (1828 allocs: 1.904 MiB)


# julia> @b FGM("2020-10-01", "2020-10-03"; probe = "a", datatype = "survey")
# 28.000 μs (88 allocs: 4.484 KiB)

# julia> @b Array(FGM("2020-10-01", "2020-10-03"; probe = "a", datatype = "survey")["ela_fgs"])
# 212.667 μs (250 allocs: 651.234 KiB)

# julia> @b Array(FGM("2020-10-01", "2020-10-03"; probe = "a", datatype = "survey")["ela_fgs"])
# 159.583 μs (252 allocs: 1.261 MiB)

# julia> @b reduce(hcat, Array.(FGM("2020-10-01", "2020-10-03"; probe = "a", datatype = "survey")["ela_fgs"]))
# 87.042 μs (132 allocs: 1.257 MiB)
