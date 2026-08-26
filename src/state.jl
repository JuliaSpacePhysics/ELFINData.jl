# State datasets
const STATE_URL = FilePattern("$BASE_URL/{probe}/{level}/state/{datatype}/{t:yyyy}/{probe}_{level}_state_{datatype}_{t:yyyymmdd}_v{version}.cdf")

const _STATE_DATASETS = [
    Dataset("{probe|U}_L1_STATE", Archive(STATE_URL, _open);
        selectors = (; probe = ["ela", "elb"], level = "l1", datatype = "defn")),
]

"""
State data (STATE)

Datasets: [`ELA_L1_STATE`](@ref), [`ELB_L1_STATE`](@ref)
"""
const STATE = Registry("state", _STATE_DATASETS; defaults = (probe = "ela",))

"""ELFIN A *L1* State (main data variables: [`ELA_POS_GEI`](@ref))"""
const ELA_L1_STATE = STATE[probe = "ela"]

"""ELFIN B *L1* State (main data variables: [`ELB_POS_GEI`](@ref))"""
const ELB_L1_STATE = STATE[probe = "elb"]

# State variables
"ELFIN A State Position XYZ in GEI coordinates"
const ELA_POS_GEI = ELA_L1_STATE["ela_pos_gei"]
"ELFIN B State Position XYZ in GEI coordinates"
const ELB_POS_GEI = ELB_L1_STATE["elb_pos_gei"]
