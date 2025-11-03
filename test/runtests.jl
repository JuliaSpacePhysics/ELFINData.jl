using Test
using Aqua
using ELFINData

@testset "Aqua" begin
    using Aqua
    Aqua.test_all(ELFINData)
end

const trange = ("2020-10-01", "2020-10-02")

@testset "Instruments" begin
    STATE(("2021-08-08", "2021-08-09"))
    FGM(("2020-10-01", "2020-10-02"); probe = "a", datatype = "survey")
end

@testset "Datasets" begin
    ELA_L1_EPDEF("2021-08-08", "2021-08-10")
    ELA_L1_EPDIF("2021-08-08", "2021-08-10")
    ELA_L2_EPDEF("2021-08-08", "2021-08-10")
    ELA_L1_FGS("2020-10-01", "2020-10-02")
    ELA_L1_STATE("2021-08-08", "2021-08-10")
    ELA_L2_EPDEF("2021-08-08", "2021-08-10")

    ELA_L1_MRMA("2021-08-08", "2021-08-10")
    ELA_L1_MRMI("2021-08-08", "2021-08-10")
end

@testset "Variables" begin
    ELA_FGS(trange)
    ELA_PEF(trange)
    ELA_POS_GEI(trange)
    ELA_MRMA(trange)
    ELA_MRMI(trange)
end

@test epd_spectral(trange).para[:, 1] == Float32[20541.432, 11046.116, 2887.873, 3359.2217, 434.48523, 173.7941, 0.0, 152.99594, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 85.875145]
