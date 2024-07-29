using Oxygen
using HTTP

include("adria/resultsets.jl")

# TODO breakup into multiple files
# TODO naming? e.g. ResultSet or ModelRun

@get "/resultsets" function(req::HTTP.Request)
    return json(get_resultsets())
end

@get "/resultset/{id}/info" function(req::HTTP.Request, id::String)
    return json(get_resultset_info(id))
end

@get "/resultset/{id}/modelspec" function(req::HTTP.Request, id::String)
    return json(get_modelspec(id))
end

@get "/resultset/{id}/scenarios" function(req::HTTP.Request, id::String)
    return json(get_scenarios(id))
end

@get "/resultset/{id}/relative_cover" function(req::HTTP.Request, id::String, timestep::Union{Int64, Nothing} = nothing)
    return json(get_relative_cover(id; timestep=timestep))
end


# start the web server
serve()
