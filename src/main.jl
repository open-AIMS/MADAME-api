using Oxygen
using HTTP

include("adria/resultsets.jl")

# TODO breakup into multiple files
# TODO naming? e.g. ResultSet or ModelRun

@get "/resultsets" function(req::HTTP.Request)
    return json(get_resultsets())
end

@get "/resultset/{id}/modelspec" function(req::HTTP.Request, id::String)
    return json(get_modelspec(id))
end

#@get "/resultset/{id}/scenarios"


# start the web server
serve()