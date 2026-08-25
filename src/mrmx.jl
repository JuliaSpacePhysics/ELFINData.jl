const MRMX_URL = FilePattern("$BASE_URL/{probe}/{level}/{datatype}/{t:yyyy}/{probe}_{level}_{datatype}_{t:yyyymmdd}_v{version}.cdf")

const _MRMX_SPECS = (
    (datatype = "mrma", source = "ACB"),
    (datatype = "mrmi", source = "IDPU"),
)

for spec in _MRMX_SPECS, probe in (ELA, ELB)
    prefix = string(probe)
    suffix = uppercase(spec.datatype)
    dataset = Symbol(prefix, "_L1_", suffix)
    variable = Symbol(prefix, "_", suffix)
    dataset_metadata = Dict(:description => "Spacecraft $(spec.source) mrm data raw sensor data")
    dataset_doc = "ELFIN $(prefix[end]) *L1* $suffix\n\nMain data variables: [`$variable`](@ref)"
    variable_doc = "Magnetic field XYZ Sensor data collected by $(spec.source), Sensor Coordinates, ADC units"
    variable_name = "el$(lowercase(prefix[end:end]))_$(spec.datatype)"
    @eval begin
        @doc $dataset_doc const $dataset = ELFINLogicalDataset(
            MRMX_URL, $(QuoteNode(dataset)), $probe, L1, $(spec.datatype), $dataset_metadata
        )
        @doc $variable_doc const $variable = ELFINLogicalVariable($dataset, $variable_name)
    end
end
