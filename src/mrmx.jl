version = 1

"""
ELFIN A *L1* MRMA (Version 1)

Main data variables: [`ELA_MRMA`](@ref)
"""
const ELA_L1_MRMA = ELFINLogicalDataset(_mrmx_pattern, :ELA_L1_MRMA, ELA, L1, "mrma", Dict(:description => "Spacecraft ACB mrm data raw sensor data"); version)
"""
ELFIN B *L1* MRMA (Version 1)

Main data variables: [`ELB_MRMA`](@ref)
"""
const ELB_L1_MRMA = ELFINLogicalDataset(_mrmx_pattern, :ELB_L1_MRMA, ELB, L1, "mrma", Dict(:description => "Spacecraft ACB mrm data raw sensor data"); version)

"""ELFIN A *L1* MRMI (Version 1)

Main data variables: [`ELA_MRMI`](@ref)
"""
const ELA_L1_MRMI = ELFINLogicalDataset(_mrmx_pattern, :ELA_L1_MRMI, ELA, L1, "mrmi", Dict(:description => "Spacecraft IDPU mrm data raw sensor data"); version)
"""ELFIN B *L1* MRMI (Version 1)

Main data variables: [`ELB_MRMI`](@ref)
"""
const ELB_L1_MRMI = ELFINLogicalDataset(_mrmx_pattern, :ELB_L1_MRMI, ELB, L1, "mrmi", Dict(:description => "Spacecraft IDPU mrm data raw sensor data"); version)

"Magnetic field XYZ Sensor data collected by ACB, Sensor Coordinates, ADC units"
const ELA_MRMA = ELFINLogicalVariable(ELA_L1_MRMA, "ela_mrma")
"Magnetic field XYZ Sensor data collected by ACB, Sensor Coordinates, ADC units"
const ELB_MRMA = ELFINLogicalVariable(ELB_L1_MRMA, "elb_mrma")

"Magnetic field XYZ Sensor data collected by IDPU, Sensor Coordinates, ADC units"
const ELA_MRMI = ELFINLogicalVariable(ELA_L1_MRMI, "ela_mrmi")
"Magnetic field XYZ Sensor data collected by IDPU, Sensor Coordinates, ADC units"
const ELB_MRMI = ELFINLogicalVariable(ELB_L1_MRMI, "elb_mrmi")
