import Base: read
using URIs

function format_date(pattern, date)
    return replace(
        pattern,
        "{Y}" => year(date),
        "{M:02d}" => string(month(date); pad = 2),
        "{D:02d}" => string(day(date); pad = 2)
    )
end


# https://github.com/helgee/RemoteFiles.jl/blob/master/src/RemoteFiles.jl
struct RemoteFile
    uri::URI
    path::String
    updates::Symbol
end

function RemoteFile(uri::URI; dir = ".", updates = :never, flatten = false)
    path = local_path(uri, dir; flatten)
    return RemoteFile(uri, path, updates)
end

RemoteFile(uri::String; kwargs...) = RemoteFile(URI(uri); kwargs...)

local_path(f) = f.path

function local_path(uri::URI, dir = "."; flatten::Bool = false)
    fullpath = lstrip(uri.path, '/')
    return if !flatten
        joinpath(dir, fullpath)
    else
        joinpath(dir, basename(fullpath))
    end
end


function _download(url, output)
    mkpath(dirname(output))
    response = request(url; output)
    return if response.status == 200
        output
    else
        rm(output)
        @info "Remote file not available" url = url message = response.message
        nothing
    end
end

_download(file::RemoteFile) = _download(file.uri.uri, file.path)
_tranges(t0, t1; dt = Day(1)) = floor(DateTime(t0), dt):dt:(ceil(DateTime(t1), dt) - Millisecond(1))

"""
Download data for a given time range `[t0, t1)` using the `pattern`.
"""
function download_pattern(pattern, t0, t1; update::Bool = false, dir = "elfin_data", kw...)
    tranges = _tranges(t0, t1; kw...)
    outputs = map(tranges) do ti
        url = format_date(pattern, ti)
        file = RemoteFile(url; dir)
        output = file.path
        (!isfile(output) || update) ? _download(file) : output
    end
    return filter!(!isnothing, outputs)
end
