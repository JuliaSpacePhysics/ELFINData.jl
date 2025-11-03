_probe(s) = startswith(s, "el") ? s : "el$(s)"
_probe(probe::Probe) = lowercase(string(probe))
_version(s) = startswith(s, "v") ? s : "v$(s)"
_version(i::Integer) = "v0$(i)"
_level(l::Level) = lowercase(string(l))

function _fgm_pattern(probe, datatype; level = "l1", version)
    probe, version, level = _probe(probe), _version(version), _level(level)
    path1 = datatype == "survey" ? "fgs" : "fgf"
    return "$BASE_URL/$probe/$level/fgm/$datatype/{Y}/$(probe)_$(level)_$(path1)_{Y}{M:02d}{D:02d}_$version.cdf"
end

function _state_pattern(probe, datatype = "defn"; level = "l1", version)
    probe, version, level = _probe(probe), _version(version), _level(level)
    return "$BASE_URL/$probe/$level/state/$datatype/{Y}/$(probe)_$(level)_state_$(datatype)_{Y}{M:02d}{D:02d}_$version.cdf"
end

function _epd_pattern(probe, datatype; level = "l1", version)
    probe, version, level = _probe(probe), _version(version), _level(level)
    path1 = datatype == "epdef" ? "electron" : "ion"
    return "$BASE_URL/$probe/$level/epd/fast/$path1/{Y}/$(probe)_$(level)_$(datatype)_{Y}{M:02d}{D:02d}_$version.cdf"
end

function _mrmx_pattern(probe, datatype; level = "l1", version)
    probe, version, level = _probe(probe), _version(version), _level(level)
    return "$BASE_URL/$probe/$level/$datatype/{Y}/$(probe)_$(level)_$(datatype)_{Y}{M:02d}{D:02d}_$version.cdf"
end

