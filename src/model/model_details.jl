using JSONTables
using DataFrames

using ADRIA
import ADRIA: Model, Intervention, Coral, model_spec


@get "/params/{component}" function (req::HTTP.Request, component::String)
    # TODO: List of available model components from ADRIA
    component = lowercase(component)
    if component == "intervention"
        params = model_spec(Model(Intervention()))
    elseif component == "coral"
        params = model_spec(Model(Coral()))
    end

    # Remove constants and unnecessary metadata/factors
    params = params[
        params.is_constant .== false,
        Not(:dist, :is_constant, :default_dist_params)
    ]
    params = params[params.fieldname .!= :guided, :]

    return params
end
