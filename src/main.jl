using Oxygen
using HTTP

include("adria/resultsets.jl")
include("util.jl")

# TODO breakup into multiple files
# TODO naming? e.g. ResultSet or ModelRun

include("routing/model_run.jl")
include("routing/viz.jl")


# start the web server
serve()
