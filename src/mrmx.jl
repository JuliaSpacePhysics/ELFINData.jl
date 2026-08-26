const MRMX_URL = FilePattern("$BASE_URL/{probe}/{level}/{datatype}/{t:yyyy}/{probe}_{level}_{datatype}_{t:yyyymmdd}_v{version}.cdf")

const _MRMX_SPECS = (
    (datatype = "mrma", source = "ACB"),
    (datatype = "mrmi", source = "IDPU"),
)

for spec in _MRMX_SPECS, probe in ("ela", "elb")
    suffix = uppercase(spec.datatype)
    dataset = Symbol(uppercase(probe), "_L1_", suffix)
    variable = Symbol(uppercase(probe), "_", suffix)
    dataset_metadata = Dict(:description => "Spacecraft $(spec.source) mrm data raw sensor data")
    dataset_doc = "ELFIN $(probe[end]) *L1* $suffix\n\nMain data variables: [`$variable`](@ref)"
    variable_doc = "Magnetic field XYZ Sensor data collected by $(spec.source), Sensor Coordinates, ADC units"
    variable_name = "el$(probe[end])_$(spec.datatype)"
    url = MRMX_URL(; probe, level = "l1", datatype = spec.datatype)
    @eval begin
        @doc $dataset_doc const $dataset = Dataset($(String(dataset)), Archive($url, _open);
            selectors = (; probe = $probe, level = "l1", datatype = $(spec.datatype)), metadata = $dataset_metadata)
        @doc $variable_doc const $variable = $dataset[$variable_name]
    end
end
