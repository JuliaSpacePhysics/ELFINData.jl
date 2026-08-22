# State datasets
const STATE_URL = FilePattern("$BASE_URL/{probe}/{level}/state/{datatype}/{t:yyyy}/{probe}_{level}_state_{datatype}_{t:yyyymmdd}_v{version}.cdf")

"""
ELFIN A *L1* State

Main data variables: [`ELA_POS_GEI`](@ref)
"""
const ELA_L1_STATE = ELFINLogicalDataset(STATE_URL, :ELA_L1_STATE, ELA, L1, "defn", Dict())
"""
ELFIN B *L1* State

Main data variables: [`ELB_POS_GEI`](@ref)
"""
const ELB_L1_STATE = ELFINLogicalDataset(STATE_URL, :ELB_L1_STATE, ELB, L1, "defn", Dict())


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
        (probe = "a",) => ELA_L1_STATE,
        (probe = "b",) => ELB_L1_STATE,
    ), Dict(), (probe = "a",)
)
