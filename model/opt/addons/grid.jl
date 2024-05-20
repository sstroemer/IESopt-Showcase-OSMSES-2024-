module GlobalAddon_Grid

using MarketFlow
const JuMP = MarketFlow.JuMP

struct _Settings
    config::Dict{String, Any}
    model::Dict{String, Any}
end

function initialize!(model::JuMP.Model, config::Dict{String, Any})
    return _Settings(config, Dict())
end

function setup!(model::JuMP.Model, settings::_Settings) end

function construct_expressions!(model::JuMP.Model, settings::_Settings) end

function construct_variables!(model::JuMP.Model, settings::_Settings)
    settings.model["cap"] = JuMP.@variable(model, [i = 1:12])
    settings.model["total_cap"] = JuMP.@variable(model)
end

function construct_constraints!(model::JuMP.Model, settings::_Settings)
    T = length(MarketFlow._iesopt(model).model.T)
    stepT = (T ÷ 12)
    gridconn_buy_flow = component(model, "gridconn_buy").var.flow

    for i in 1:12
        rT = ( (i-1)*stepT + 1 ):( i*stepT )
        JuMP.@constraint(model, [t = rT], settings.model["cap"][i] >= gridconn_buy_flow[t])
        JuMP.@constraint(model, settings.model["total_cap"] >= settings.model["cap"][i])
    end

    if settings.config["fixed_grid_connection_power"] > 0
        JuMP.fix(settings.model["total_cap"], settings.config["fixed_grid_connection_power"]; force=true)
    end
end

function construct_objective!(model::JuMP.Model, settings::_Settings)
    grid_cost = sum(settings.model["cap"]) * settings.config["grid_cost"]
    push!(MarketFlow._iesopt(model).model.objectives["total_cost"].terms, grid_cost)
    push!(MarketFlow._iesopt(model).model.objectives["grid_connection_power_cost"].terms, grid_cost)
    push!(MarketFlow._iesopt(model).model.objectives["grid_connection_power"].terms, settings.model["total_cap"] + 0)
end

end