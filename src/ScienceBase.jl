module ScienceBase

using URIs
using HTTP
using JSON3
using CSV
using PDFIO
using Dates

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
    if endswith(domain, ".pdf")
        return URI("https://$domain")
    end

    verb = objecttype==file ? "get" : ""
    endpoint, objecttype = string(endpoint), string(objecttype)

    path = joinpath("/", endpoint, objecttype, verb, objectid)
    if !isempty(kwargs)
        query *= "&$(escapeuri(kwargs))"
    end
    URI(;scheme="https", host=domain, path, query)
end

function get_data(uri::URI=make_uri(), outdir::AbstractString="data/USGS";
    cacheintermediates::Bool=true,
    overwriteexisting=false,
)
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
    elseif occursin("application/pdf", content_type)
        # close(tmpfilehandle)
        data = pdDocGetInfo(pdDocOpen(tmpfilepath))
    end
    if cacheintermediates
        close(tmpfilehandle)
        dir, filename = splitdir(uri.path)
        dir = joinpath(outdir, strip(dir, '/'))
        mkpath(dir)
        outpath = joinpath(dir, filename)
        if !isfile(outpath) || overwriteexisting
            mv(tmpfilepath, outpath; force=true)
        else
            @warn "skipping: $outpath"
        end
    end
    data
end

function pull_MCS_PDFs(fromdate::Int=1996, todate::Int=year(today()))
    for y in fromdate:todate
        uri =
            1996 <= y <= 2012 ? URI("https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/atoms/files/mcs-$(y)ocr.pdf") :
            2013 <= y <= 2019 ? URI("https://apps.usgs.gov/minerals-information-archives/mcs/mcs$(y).pdf") :
                                URI("https://"*joinpath(pubs_domain, "periodicals/mcs$y/mcs$y.pdf"))
        @info "" uri
        try
            get_data(uri; cacheintermediates=true)
        catch e
            @warn e
        end
    end
end

end # module ScienceBase
