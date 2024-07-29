import ADRIA
using Statistics
using DataFrames

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
    # 1st relative_cover - each functional group
    #ADRIA.metrics.scenario_relative_cover(rs)
    rc = ADRIA.metrics.relative_cover(rs)

    # mean relative cover across all time and scenarios
    all_rc = vec(mean(rc, dims=(:scenarios, :timesteps)))
    table = select(rs.site_data, :UNIQUE_ID)
    @assert length(all_rc) == size(table, 1)
    # assuming that data is aligned, how do we guarantee this?
    table.relative_cover = all_rc
    return table
end
