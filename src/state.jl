# State datasets
const STATE_URL = FilePattern("$BASE_URL/{probe}/{level}/state/{datatype}/{t:yyyy}/{probe}_{level}_state_{datatype}_{t:yyyymmdd}_v{version}.cdf")

const _STATE_DATASETS = [
    Dataset("{probe|U}_L1_STATE", Archive(STATE_URL, _open);
        selectors = (; probe = ["ela", "elb"], level = "l1", datatype = "defn")),
]

const STATE = Registry("state", _STATE_DATASETS; defaults = (probe = "ela",))

const ELA_L1_STATE = STATE[probe = "ela"]

const ELB_L1_STATE = STATE[probe = "elb"]

# State variables
const ELA_POS_GEI = ELA_L1_STATE["ela_pos_gei"]
const ELB_POS_GEI = ELB_L1_STATE["elb_pos_gei"]
