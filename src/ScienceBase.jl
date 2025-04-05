module ScienceBase

using URIs
using HTTP
using JSON3
using CSV

include("constants.jl")

"""
Constructs a URI for accessing ScienceBase API.
"""
function make_uri(
    domain::AbstractString=domain, endpoint::Endpoint=catalog, objecttype::ObjectType=item;
    objectid::AbstractString=ScienceBase_root_item_ID,
    query::AbstractString="format=json",
    kwargs...,
)
    verb = objecttype==file ? "get" : ""
    endpoint, objecttype = string(endpoint), string(objecttype)

    path = joinpath("/", endpoint, objecttype, verb, objectid)
    if !isempty(kwargs)
        query *= "&$(escapeuri(kwargs))"
    end
    URI(;scheme="https", host=domain, path, query)
end

function get_data(uri::URI=make_uri(), outdir::AbstractString="data", cacheintermediates::Bool=true,)
    tmpfilepath, tmpfilehandle = mktemp()
    @info "tmpfilepath: " tmpfilepath
    resp = HTTP.open("GET", uri) do data_stream
        while !eof(data_stream)
            write(tmpfilehandle, readavailable(data_stream))
        end
    end
    seek(tmpfilehandle, 0)
    content_type = get(Dict(resp.headers), "Content-Type", nothing)
    @info "content_type: " content_type
    if occursin("application/json", content_type)
        # JSON response
        data = JSON3.read(tmpfilehandle)
    elseif occursin("text/csv", content_type)
        data = CSV.File(tmpfilehandle)
    end
    data
end


end # module ScienceBase
