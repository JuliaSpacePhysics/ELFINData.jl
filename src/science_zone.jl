science_zone_url(probe) = "$BASE_URL/$probe/$(probe)_epd_science_zone_times.csv"
const _SZ_DATEFORMAT = dateformat"yyyy-mm-dd/HH:MM:SS"

function science_zones(probe="ela"; kw...)
    path = localize(science_zone_url(probe); kw...)
    tstart, tend = DateTime[], DateTime[]
    for line in eachline(path)
        a, b = split(line, ',')
        push!(tstart, DateTime(strip(a, '"'), _SZ_DATEFORMAT))
        push!(tend, DateTime(strip(b, '"'), _SZ_DATEFORMAT))
    end
    return (; tstart, tend)
end
