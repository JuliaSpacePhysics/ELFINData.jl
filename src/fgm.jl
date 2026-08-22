# FGM datasets
const FGM_URL = FilePattern("$BASE_URL/{probe}/{level}/fgm/{datatype}/{t:yyyy}/{probe}_{level}_{tag}_{t:yyyymmdd}_v{version}.cdf")
const _FGM_METADATA = Dict(:description => "Spacecraft fluxgate magnetometer, Survey mode, raw sensor data")

"""
ELFIN A *L1* FGM Survey

Main data variables: [`ELA_FGS`](@ref)
"""
const ELA_L1_FGS = ELFINLogicalDataset(
    FGM_URL, :ELA_L1_FGS, ELA, L1, "survey", _FGM_METADATA; tag="fgs"
)

"""
ELFIN B *L1* FGM Survey

Main data variables: [`ELB_FGS`](@ref)
"""
const ELB_L1_FGS = ELFINLogicalDataset(
    FGM_URL, :ELB_L1_FGS, ELB, L1, "survey", _FGM_METADATA; tag="fgs"
)

# FGM variables
"ELFIN A FGM Magnetic field B in XYZ Sensor Coordinates, Survey Mode"
const ELA_FGS = ELFINLogicalVariable(ELA_L1_FGS, "ela_fgs")
"ELFIN B FGM Magnetic field B in XYZ Sensor Coordinates, Survey Mode"
const ELB_FGS = ELFINLogicalVariable(ELB_L1_FGS, "elb_fgs")

"""
Fluxgate Magnetometer (FGM)

Datasets: [`ELA_L1_FGS`](@ref), [`ELB_L1_FGS`](@ref)
"""
const FGM = ELFINInstrument(
    "fgm", Dict(
        (probe="a", datatype="survey") => ELA_L1_FGS,
        (probe="b", datatype="survey") => ELB_L1_FGS,
    ), Dict(), (probe="a", datatype="survey")
)
