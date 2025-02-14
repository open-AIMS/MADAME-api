using Bonito
using WGLMakie, GeoMakie, GraphMakie
using Oxygen: html # Bonito also exports html

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
        <input type="text" id="scenario-name" name="run" value="This does nothing, but could be one or more SSPs/RCPs"><br>

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

# Parse the form data and return it
@post "/form" function (req)
    data = formdata(req)
    return data
end

@post "/invoke-run/coralblox" function (req)
    data = formdata(req)

    # Parse and validate inputs
    scenario_name = get(data, "run", nothing)

    n_runs = parse(Int, get(data, "scenario-runs", "64"))
    n_runs <= 0 && error("Scenario set size must be positive and a power of 2")

    ta_lower = parse(Float64, get(data, "seed-TA-lower_bound", "100000"))
    ta_upper = parse(Float64, get(data, "seed-TA-upper_bound", "1000000"))
    step_size = floor(Int64, (ta_upper - ta_lower) / 10)

    # TODO: If user provides a list of SSPs/RCPs to run, have to loop and combine results
    #       at the end.
    default_domain_dir = Base.get_preferences()["default_domain"]
    dom = ADRIA.load_domain(default_domain_dir, "45")

    ADRIA.set_factor_bounds(dom, N_seed_TA=(ta_lower, ta_upper, step_size))

    scens = ADRIA.sample(dom, n_runs)
    rs = ADRIA.run_scenarios(dom, scens, "45")

    r_tac = ADRIA.metrics.scenario_total_cover(rs)
    # f = ADRIA.viz.scenarios(rs, r_tac)

    # return Page(export_fig(f))
    return html(ADRIA.viz.scenarios(rs, r_tac))
end


@get "/test-viz" function (req)
    fig = Figure()
    ax = Axis(fig[1,1])
    scatter!(ax, rand(100), rand(100))

    # Create and return a Bonito App
    app = App() do session
        return DOM.div(
            fig
        )
    end

    return html(app)
end