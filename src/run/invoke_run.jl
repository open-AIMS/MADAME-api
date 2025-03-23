using MADAMEAPI

"""
    ModelParam

Represents a model parameter and the parametrisation of its sampling distribution. Currently,
parameter are either drawn from some type of uniform or triangular distribution.

# Fields
- `param_name::Stirng`: name of the parameter in the domain model spec.
- `third_param_flag::Bool`: true if sampling distribution uses the third parametera.
- `lower::Float64`: Lower bound parameter of the sampling distribution.
- `upper::Float64`: Upper bound parameter of the sampling distrbition.
- `optional_third::Float64`: Third parameter of the sampling distribution.
"""
struct ModelParam
    param_name::String
    third_param_flag::Bool
    lower::Float64
    upper::Float64
    optional_third::Float64
end

"""
    InvokeRunResponse

Expected response structure of a invoke run post request.

# Fields
- `run_name::String`: Name of model run and directory to store.
- `num_scenarios::Int64`: Number of scenarios to run.
- `model_params::Vector{ModelParam}`: List of model parameters to set the sampling distriburtion for.
"""
struct InvokeRunResponse
    run_name::String
    num_scenarios::Int64
    model_params::Vector{ModelParam}
end

"""
    model_param_to_tuple(model_param::ModelParam)::Tuple

Convert the model parameter struct a tuple the can be pased to the ADRIA set_factor_bounds
function.
"""
function model_param_to_tuple(model_param::ModelParam)::Tuple
    if model_param.third_param_flag
        return (model_param.lower, model_param.upper, model_param.optional_third)
    else
        return (model_param.lower, model_param.upper)
    end
end

function run_coral_blox(
    n_runs::Int64,
    model_params::Vector{ModelParam}
)::ADRIA.ResultSet

    default_domain_dir = Base.get_preferences()["default_domain"]
    dom = ADRIA.load_domain(default_domain_dir, "45")

    # Set the distribution parametrisation defined by the user.
    ADRIA.set_factor_bounds.(
        Ref(dom),
        Symbol.(getfield.(model_params, :param_name)),
        model_param_to_tuple.(model_params)
    )

    scens = ADRIA.sample(dom, n_runs)
    rs = ADRIA.run_scenarios(dom, scens, "45")

    return rs
end

function setup_model_run_invokation_routes()
    @post "/invoke-run/coralblox" function (req)
        @debug req
        response = json(req, InvokeRunResponse)

        if isnothing(response)
            return HTTP.Response(400, "Incorrectly formatted response.")
        end

        # Parse and validate inputs
        scenario_name = response.run_name

        res_dir = Base.get_preferences()["resultsets_dir"]
        new_path = joinpath(res_dir, scenario_name)
        @debug "Attempting to save to $(new_path)"

        if isdir(new_path)
            return HTTP.Response(400, "Model run name already used.")
        end

        # Pre-setup ADRIA and adjust output directory to MADAME-configured location.
        ADRIA.setup()
        ENV["ADRIA_OUTPUT_DIR"] = res_dir

        # TODO: If user provides a list of SSPs/RCPs to run, have to loop and combine results
        #       at the end.
        rs = run_coral_blox(response.num_scenarios, response.model_params)

        # Move results to named location
        mv(ADRIA.result_location(rs), new_path)

        return json(:run_name => scenario_name)
    end

    return nothing
end
