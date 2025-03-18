module MADAMEAPI

using ADRIA
using TOML

include("util.jl")

include("results/metadata.jl")
include("results/viz.jl")

include("run/invoke_run.jl")

function start_server()
    @info "Launching Server... please wait"

    ADRIA_config_path::String = joinpath(pwd(), "config.toml")
    if isfile(ADRIA_config_path)
        ADRIA_outdir::String = TOML.parsefile(ADRIA_config_path)["results"]["output_dir"]
        if !samefile(ADRIA_outdir, Base.get_preferences()["resultsets_dir"])
            msg = "ADRIA model run output directory is not the same as the server result "
            msg *= "store directory. New model runs will not appear in the server results."
            @warn msg
        end
    else
        if !samefile(joinpath(pwd(), "Outputs"), Base.get_preferences()["resultsets_dir"])
            msg = "ADRIA model run output directory is not the same as the server result "
            msg *= "store directory. New model runs will not appear in the server results."
            @warn msg
        end
    end

    @info "Setting up result metadata routes..."
    setup_result_metadata_routes()

    @info "Setting up result visualisation paths..."
    setup_result_viz_routes()

    @info "Setting up model run invokation paths..."
    setup_model_run_invokation_routes()

    @info "Setup complete, starting server."
    serve()
end

export start_server

end
