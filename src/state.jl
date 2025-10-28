# State datasets
"""
ELFIN A *L1* State (Version 2)

Main data variables: [`ELA_POS_GEI`](@ref)
"""
const ELA_L1_STATE = ELFINLogicalDataset(_state_pattern, :ELA_L1_STATE, ELA, L1, "defn", Dict(); version = 2)
"""
ELFIN B *L1* State (Version 2)

Main data variables: [`ELB_POS_GEI`](@ref)
"""
const ELB_L1_STATE = ELFINLogicalDataset(_state_pattern, :ELB_L1_STATE, ELB, L1, "defn", Dict(); version = 2)


# State variables
"ELFIN A State Position XYZ in GEI coordinates"
const ELA_POS_GEI = ELFINLogicalVariable(ELA_L1_STATE, "ela_pos_gei")
"ELFIN B State Position XYZ in GEI coordinates"
const ELB_POS_GEI = ELFINLogicalVariable(ELB_L1_STATE, "elb_pos_gei")

"""
State data (STATE)

Datasets: [`ELA_L1_STATE`](@ref), [`ELB_L1_STATE`](@ref)
"""
const STATE = ELFINInstrument(
    "state", Dict(
        "a" => ELA_L1_STATE,
        "b" => ELB_L1_STATE,
    ), Dict(), (datasets; probe = "a") -> datasets[probe]
)
