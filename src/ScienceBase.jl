module ScienceBase

using URIs
using HTTP
using JSON3

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
    endpoint, objecttype = string(endpoint), string(objecttype)

    path = joinpath("/", endpoint, objecttype, objectid)

    if !isempty(kwargs)
        query *= "&$(escapeuri(kwargs))"
    end
    URI(;scheme="https", host=domain, path, query)
end

function get_data(uri::URI=make_uri(), outdir::AbstractString="data", cacheintermediates::Bool=true,)
    resp = HTTP.get(uri)
    content_type = get(Dict(resp.headers), "Content-Type", nothing)
    if occursin("application/json", content_type)
        # JSON response
        data = JSON3.read(resp.body)
        return data
    end
    resp.data
end


end # module ScienceBase
