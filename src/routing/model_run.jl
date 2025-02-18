using Bonito
using WGLMakie, GeoMakie, GraphMakie
using Oxygen: html # Bonito also exports html

include("../adria/resultsets.jl")

# Force inlining of all data and JS dependencies
Page(exportable=true, offline=true)
# WGLMakie.activate!()
Makie.inline!(true)
Makie.set_theme!(WGLMakie=(framerate=25, ))

# Form for testing/dev
@get "/deployment-setting" function ()
    # Should extract control/bounds from ADRIA.model_spec()
    # Changing model-choice should auto-refresh/populate with the relevant deployment controls
    return html("""
    <form action="/invoke-run/coralblox" method="post">
        <label for="model-choice">Model/location to run:</label><br>
        <input type="text" id="model-choice" name="model-option" value="This does nothing right now"><br>

        <label for="scenario-name">Scenario name:</label><br>
        <input type="text" id="scenario-name" name="run"><br>

        <label for="ssps">Representative Concentration Pathways:</label><br>
        <input type="text" id="scenario-name" name="RCP" value="This does nothing, but could be one or more SSPs/RCPs"><br>

        <label for="scenario-set-size">Scenario set size:</label><br>
        <input type="text" id="scenario-set-size" name="scenario-runs" value="32"><br><br>

        <label for="seed-TA-lb">Seeding Tabular Acropora Lower Bound:</label><br>
        <input type="text" id="seed-TA-lb" name="seed-TA-lower_bound" value="100000"><br><br>

        <label for="seed-TA-ub">Seeding Tabular Acropora Upper Bound:</label><br>
        <input type="text" id="seed-TA-ub" name="seed-TA-upper_bound" value="1000000"><br><br>

        <input type="submit" value="Submit">
    </form>
    """)
end

function run_coral_blox(
    ta_lower,
    ta_upper,
    step_size,
    n_runs
)::ADRIA.ResultSet

    default_domain_dir = Base.get_preferences()["default_domain"]
    dom = ADRIA.load_domain(default_domain_dir, "45")

    ADRIA.set_factor_bounds(dom, N_seed_TA=(ta_lower, ta_upper, step_size))

    scens = ADRIA.sample(dom, n_runs)
    rs = ADRIA.run_scenarios(dom, scens, "45")

    return rs
end

function default_save_name(rs::ADRIA.ResultSet)::String
    return "$(rs.name)__RCPs_$(rs.RCP)__$(rs.invoke_time)"
end

# Parse the form data and return it
@post "/form" function (req)
    data = formdata(req)
    return data
end

@post "/invoke-run/coralblox" function (req)
    println(req)
    data = json(req)["params"]

    # Parse and validate inputs
    scenario_name = get(data, "runName", nothing)

    res_dir = Base.get_preferences()["resultsets_dir"]
    new_path = joinpath(res_dir, scenario_name)

    if isdir(new_path)
        return HTTP.Response(400, "Model Run name already used.")
    end

    n_runs = parse(Int, get(data, "numScenarios", "64"))
    n_runs <= 0 && error("Scenario set size must be positive and a power of 2")

    ta_lower = parse(Float64, get(data, "ta_lower", "100000"))
    ta_upper = parse(Float64, get(data, "ta_upper", "1000000"))
    step_size = floor(Int64, (ta_upper - ta_lower) / 10)

    # TODO: If user provides a list of SSPs/RCPs to run, have to loop and combine results
    #       at the end.
    rs = run_coral_blox(ta_lower, ta_upper, step_size, n_runs)

    default_path = joinpath(res_dir, default_save_name(rs))
    
    mv(default_path, new_path)
    # return Page(export_fig(f))
    return json(:run_name => scenario_name)
end
