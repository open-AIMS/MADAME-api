module MADAMEAPI

using
    Oxygen,
    HTTP,
    Caching

using ADRIA

using TOML

include("util.jl")

include("results/metadata.jl")
include("results/viz.jl")

include("run/invoke_run.jl")

function start_server()
    @info "Launching Server... please wait"

    # TO DO: check ADRIA output path aligns with local preferences path

    @info "Setting up result metadata routes..."
    setup_result_metadata_routes()

    @info "Setting up result visualisation paths..."
    setup_result_viz_routes()

    @info "Setting up model run invokation paths..."
    setup_model_run_invokation_routes()

    @info "Setup complete, starting server."
    serve()
end

function dev_server()
    ENV["JULIA_DEBUG"] = "MADAMEAPI"
    start_server()
end

export start_server, dev_server

end
