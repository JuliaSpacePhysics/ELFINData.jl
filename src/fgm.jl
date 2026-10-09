# FGM datasets
const FGM_URL = FilePattern("$BASE_URL/{probe}/{level}/fgm/{datatype}/{t:yyyy}/{probe}_{level}_{tag}_{t:yyyymmdd}_v{version}.cdf")
const _FGM_METADATA = Dict(:description => "Spacecraft fluxgate magnetometer, Survey mode, raw sensor data")
const _FGF_METADATA = Dict(:description => "Spacecraft fluxgate magnetometer, Fast survey mode, raw sensor data")

const _FGM_DATASETS = [
    Dataset("{probe|U}_L1_FGS", Archive(FGM_URL(; level = "l1", tag = "fgs"), _open);
        selectors = (; probe = ["ela", "elb"], datatype = "survey"), metadata = _FGM_METADATA),
    Dataset("{probe|U}_L1_FGF", Archive(FGM_URL(; level = "l1", tag = "fgf"), _open);
        selectors = (; probe = ["ela", "elb"], datatype = "fast"), metadata = _FGF_METADATA),
]

const FGM = Registry("fgm", _FGM_DATASETS; defaults = (probe = "ela", datatype = "survey"))

const ELA_L1_FGS = FGM[probe = "ela"]
const ELB_L1_FGS = FGM[probe = "elb"]
const ELA_L1_FGF = FGM[probe = "ela", datatype = "fast"]
const ELB_L1_FGF = FGM[probe = "elb", datatype = "fast"]

# FGM variables
const ELA_FGS = ELA_L1_FGS["ela_fgs"]
const ELB_FGS = ELB_L1_FGS["elb_fgs"]
