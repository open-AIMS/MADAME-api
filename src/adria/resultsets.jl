import ADRIA

function get_resultsets()
    dir = Base.get_preferences()["resultsets_dir"]
    resultsets = [f for f in readdir(dir)]
    return resultsets
end

function get_resultset(name::String)
    dir = Base.get_preferences()["resultsets_dir"]
    path = joinpath(dir, name)
    if !isdir(path)
        error("Not a directory: $(path)")
    end

    return ADRIA.load_results(path)
end

struct ResultSetInfo
    store_name::String
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
