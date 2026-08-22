# FGM datasets
const _FGM_METADATA = Dict(:description => "Spacecraft fluxgate magnetometer, Survey mode, raw sensor data")

"""
ELFIN A *L1* FGM Survey (Version 1)

Main data variables: [`ELA_FGS`](@ref)
"""
const ELA_L1_FGS = ELFINLogicalDataset(_fgm_pattern, :ELA_L1_FGS, ELA, L1, "survey", _FGM_METADATA; version = 1)

"""
ELFIN B *L1* FGM Survey (Version 1)

Main data variables: [`ELB_FGS`](@ref)
"""
const ELB_L1_FGS = ELFINLogicalDataset(_fgm_pattern, :ELB_L1_FGS, ELB, L1, "survey", _FGM_METADATA; version = 1)

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
        (probe = "a", datatype = "survey") => ELA_L1_FGS,
        (probe = "b", datatype = "survey") => ELB_L1_FGS,
    ), Dict(), (probe = "a", datatype = "survey")
)
