using ADRIA

function get_resultsets()
    dir = Base.get_preferences()["resultsets_dir"]
    resultsets = [f for f in readdir(dir)]
    return resultsets
end

function get_modelspec(name::String)
    dir = Base.get_preferences()["resultsets_dir"]
    path = joinpath(dir, name)
    if !isdir(path)
        error("Not a directory: $(path)")
    end

    rs = ADRIA.load_results(path)
    # DataFrames.DataFrame
    return rs.model_spec
end
