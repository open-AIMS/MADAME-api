using Statistics

using
    Caching,
    Oxygen,
    HTTP

using
    DataFrames,
    YAXArrays

using ADRIA



function get_resultsets()
    dir = Base.get_preferences()["resultsets_dir"]
    resultsets = [f for f in readdir(dir)]
    return resultsets
end

# PERF this cache allows simultaneous entry into function
# ideally would block other thread and only calculate once
@cache function get_resultset(name::String)
    @debug "get_resultset $(name)"
    dir = Base.get_preferences()["resultsets_dir"]
    path = joinpath(dir, name)
    if !isdir(path)
        error("Not a directory: $(path)")
    end

    return ADRIA.load_results(path)
end

struct ResultSetInfo
    # Store Name
    id::String
    # user-visible name
    title::String
    # TODO name? aka "Domain"?
    datapkg_name::String
    ## TODO ISO8601
    invoke_time::String
    model_name::String
    model_version::String
    n_scenarios::Int64
    n_locations::Int64
    n_timesteps::Int64
    start_year::Int32
    end_year::Int32
    # TODO RCP, why is it blank?
end

function get_resultset_info(name::String)
    # PERF change to cheap get info impl
    rs = get_resultset(name)

    # similar to ADRIA Base.show for ResultSet
    tf, sites, scens = size(rs.outcomes[:relative_cover])

    return ResultSetInfo(
        name,
        name,
        rs.name,
        rs.invoke_time,
        "CoralBlox",
        rs.ADRIA_VERSION,
        scens,
        sites,
        tf,
        rs.env_layer_md.timeframe[1],
        rs.env_layer_md.timeframe[end]
    )
end

function get_modelspec(name::String)
    rs = get_resultset(name)
    # DataFrames.DataFrame
    return ADRIA.model_spec(rs)
end

function get_scenarios(name::String)
    rs = get_resultset(name)
    return rs.inputs
end

function get_relative_cover(name::String)
    rs = get_resultset(name)
    rc = ADRIA.metrics.relative_cover(rs)

    # mean relative cover across all time and scenarios
    rc_vec = vec(mean(rc, dims=(:scenarios, :timesteps)))

    table = DataFrames.select(rs.loc_data, :UNIQUE_ID)
    @assert length(rc_vec) == size(table, 1)
    # assuming that data is aligned, how do we guarantee this?
    table.relative_cover = rc_vec

    # mean(relative_cover); groupby UNIQUE_ID
    # this syntax prevents auto-rename to relative_cover_mean
    return combine(groupby(table, :UNIQUE_ID), :relative_cover => mean => :relative_cover)
end
function get_relative_cover(name::String, timestep::Union{Int64, UnitRange{Int64}})
    rs = get_resultset(name)
    rc = ADRIA.metrics.relative_cover(rs)

    # mean across timesteps when it's a range.
    dims = timestep isa UnitRange ? (:scenarios, :timesteps) : (:scenarios)
    rc_vec = mean(rc[timesteps=At(timestep)], dims=dims)

    rc_vec = vec(dropdims(rc_vec; dims=(:scenarios, :timesteps)))

    table = select(rs.loc_data, :UNIQUE_ID)
    @assert length(rc_vec) == size(table, 1)
    # assuming that data is aligned, how do we guarantee this?
    table.relative_cover = rc_vec

    # mean(relative_cover); groupby UNIQUE_ID
    # this syntax prevents auto-rename to relative_cover_mean
    return combine(groupby(table, :UNIQUE_ID), :relative_cover => mean => :relative_cover)
end

function setup_result_metadata_routes()
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

    @get "/resultset/{id}/relative_cover" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        if isnothing(timestep)
            return json(get_relative_cover(id))
        elseif timestep isa String
            timerange = parse_intrange(timestep)
            return json(get_relative_cover(id, timerange))
        else
            return json(get_relative_cover(id, timestep))
        end
    end

    return nothing
end
