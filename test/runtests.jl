using Test
using Aqua
using ELFINData

@testset "Aqua" begin
    using Aqua
    Aqua.test_all(ELFINData)
end

const trange = ("2020-10-01", "2020-10-02")

@testset "Instruments" begin
    @test STATE[] == ELA_L1_STATE
    @test STATE[probe = "elb"] == ELB_L1_STATE
    @test FGM[] == ELA_L1_FGS
    @test FGM[probe = "elb"] == ELB_L1_FGS
    @test EPD[] == ELA_L1_EPDEF
    @test EPD[probe = "elb", level = "l2"] == ELB_L2_EPDEF
    @test STATE[datatype = "defn"] == ELA_L1_STATE
    @test_throws ArgumentError STATE[datatype = "attitude"]
    @test EPD[probe = :elb, level = "l2", datatype = "epdef"] == ELB_L2_EPDEF
    # A combination the instrument does not publish names the ones it does.
    @test_throws ArgumentError EPD[probe = "ela", level = "l2", datatype = "epdif"]
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
    # L1 FGM values exceed the files' placeholder VALIDMIN/VALIDMAX
    @test !any(isnan, ELA_FGS(trange))
    ELA_PEF(trange)
    ELA_POS_GEI(trange)
    ELA_MRMA(trange)
    ELA_MRMI(trange)
end

@testset "Science zones" begin
    using Dates
    zones = science_zones("elb")
    @test length(zones.tstart) == length(zones.tend)
    @test zones.tstart[1] == DateTime(2019, 9, 1, 3, 25, 7)
end

@testset "Data notes" begin
    using Dates
    @test isempty(epd_data_notes("ela", DateTime(2021, 3, 1), DateTime(2021, 3, 2)))
    # the page fault spans only ELFIN-B; an interval overlapping its end is flagged
    @test length(epd_data_notes("elb", DateTime(2021, 11, 25, 3), DateTime(2021, 11, 25, 5))) == 1
    @test isempty(epd_data_notes("ela", DateTime(2021, 11, 20), DateTime(2021, 11, 21)))
    @test only(epd_data_notes("ela", "2022-06-01", "2022-06-02"; head = "i")).tend == DateTime(2022, 6, 29)
end

@testset "Missing remote files" begin
    @test size(getdata(ELA_FGS, ("2020-10-08", "2020-10-10")), 1) == 3
end

@testset "URL patterns" begin
    using Dates
    overplots = ELFINData.OVERPLOTS_URL(; probe = "ela", level = "l2", datatype = "24hr")
    @test overplots(Date(2022, 9, 10)) == "https://data.elfin.ucla.edu/ela/overplots/2022/09/10/ela_l2_overview_20220910_24hr.gif"
    # fgm splits survey/fast across the directory (survey) and the file name (fgs)
    @test ELA_L1_FGS.source.pattern(Date(2020, 10, 1); version = "01") ==
        "https://data.elfin.ucla.edu/ela/l1/fgm/survey/2020/ela_l1_fgs_20201001_v01.cdf"
end

@test epd_spectral(trange).para[:, 1] ≈ Float32[20541.432, 11046.116, 2887.873, 3359.2217, 434.48523, 173.7941, 0.0, 152.99594, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 85.875145]
