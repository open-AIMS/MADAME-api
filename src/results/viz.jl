using Bonito
using WGLMakie, GeoMakie, GraphMakie
using Oxygen: html

function setup_result_viz_routes()
    @get "/resultsets/{id}/plot/relative_cover" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        s_rc = ADRIA.metrics.scenario_relative_cover(rs)
        f = ADRIA.viz.scenarios(rs, s_rc)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/total_cover" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        s_tc = ADRIA.metrics.scenario_total_cover(rs)
        f = ADRIA.viz.scenarios(rs, s_tc)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/relative_juveniles" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        s_rj = ADRIA.metrics.scenario_relative_juveniles(rs)
        f = ADRIA.viz.scenarios(rs, s_rj)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/absolute_juveniles" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        s_aj = ADRIA.metrics.scenario_absolute_juveniles(rs)
        f = ADRIA.viz.scenarios(rs, s_aj)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/juvenile_indicator" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        s_ji = ADRIA.metrics.scenario_juvenile_indicator(rs)
        f = ADRIA.viz.scenarios(rs, s_ji)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/asv" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        scenario_metric = ADRIA.metrics.scenario_asv(rs)
        f = ADRIA.viz.scenarios(rs, scenario_metric)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/rsv" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        scenario_metric = ADRIA.metrics.scenario_rsv(rs)
        f = ADRIA.viz.scenarios(rs, scenario_metric)
        app = App() do session
            return f 
        end
        return html(app)
    end
    @get "/resultsets/{id}/plot/coral_evenness" function(req::HTTP.Request, id::String, timestep::Union{Int64, String, Nothing} = nothing)
        rs = get_resultset(id)
        scenario_metric = ADRIA.metrics.scenario_evenness(rs)
        f = ADRIA.viz.scenarios(rs, scenario_metric)
        app = App() do session
            return f 
        end
        return html(app)
    end
    return nothing
end
