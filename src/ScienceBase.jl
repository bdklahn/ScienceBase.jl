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
    overwriteexisting::Bool=false,
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
    data = nothing
    if occursin("application/json", content_type)
        # JSON response
        try
            data = JSON3.read(tmpfilehandle)
        catch e
            @warn e
        end
    elseif occursin("text/csv", content_type)
        try
            data = CSV.File(tmpfilehandle)
        catch e
            @warn e
        end
    elseif occursin("application/pdf", content_type)
        try
            data = pdDocGetInfo(pdDocOpen(tmpfilepath))
        catch e
            @warn e
        end
    end
    if cacheintermediates
        close(tmpfilehandle)
        _, filename = splitdir(uri.path)
        mkpath(outdir)
        outpath = joinpath(outdir, filename)
        if isfile(outpath) @warn "already exists: $outpath" end
        try
            @info "trying (if allowed) to write: $outpath"
            mv(tmpfilepath, outpath; force=overwriteexisting)
        catch e
            @warn e
        end
    end
    data
end


"""
Pull the [Mineral Commodity Summaries](https://www.usgs.gov/centers/national-minerals-information-center/mineral-commodity-summaries)
PDF files, from between the given years.
"""
function pull_MCS_PDFs(;
    fromyear::Int=1996,
    toyear::Int=year(today()),
    outdir::AbstractString="data/USGS/literature/Mineral_Commodity_Summaries",
)
    @assert fromyear <= toyear "toyear must be greater or equal to fromyear"
    firstyear = 1996
    thisyear = year(today())
    fromyear = clamp(fromyear, firstyear, thisyear)
    toyear =   clamp(toyear,   firstyear, thisyear)

    for y in fromyear:toyear
        uri =
            firstyear <= y <= 1999 ? URI("https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/atoms/files/mcs-$(y)ocr.pdf") :
            2000 <= y <= 2012 ?      URI("https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/mineral-pubs/mcs/mcs$y.pdf") :
            2013 <= y <= 2019 ?      URI("https://apps.usgs.gov/minerals-information-archives/mcs/mcs$(y).pdf") :
                                     URI("https://"*joinpath(pubs_domain, "periodicals/mcs$y/mcs$y.pdf"))
        @info "" uri
        try
            get_data(uri, outdir; cacheintermediates=true)
        catch e
            @warn e
        end
    end
end

end # module ScienceBase
