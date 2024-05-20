
module GlobalAddon_UC

using MarketFlow
const JuMP = MarketFlow.JuMP

struct _Settings
    config::Dict{String, Any}
end

function initialize!(model::JuMP.Model, config::Dict{String, Any})
    return _Settings(config)
end

function setup!(model::JuMP.Model, settings::_Settings) end

function construct_expressions!(model::JuMP.Model, settings::_Settings) end

function construct_variables!(model::JuMP.Model, settings::_Settings) end

function construct_constraints!(model::JuMP.Model, settings::_Settings)
    T = MarketFlow._iesopt(model).model.T
    M = 250

    if settings.config["el_type"] == "PEMEL"
        pemel = component(model, "pemel.electrolysis")
        pemel_ml = settings.config["pemel_min_load"]
        pemel_in = MarketFlow._total(pemel, :in, "dc")
        pemel_cap = component(model, "pemel.invest").var.value
        pemel_oh = settings.config["pemel_oh"]

        JuMP.@variable(model, ison_pemel[t=T], binary=true)
        JuMP.@constraint(model, sum(ison_pemel) <= pemel_oh)
        JuMP.@constraint(model, [t=T], pemel_in[t] <= M * ison_pemel[t])
        JuMP.@constraint(model, [t=T], pemel_in[t]/pemel_ml >= pemel_cap - M * (1 - ison_pemel[t]))
    elseif settings.config["el_type"] == "AEL"
        ael = component(model, "ael.electrolysis")
        ael_ml = settings.config["ael_min_load"]
        ael_in = MarketFlow._total(ael, :in, "dc")
        ael_cap = component(model, "ael.invest").var.value
        ael_oh = settings.config["ael_oh"]
    
        JuMP.@variable(model, ison_ael[t=T], binary=true)
        JuMP.@constraint(model, sum(ison_ael) <= ael_oh)
        JuMP.@constraint(model, [t=T], ael_in[t] <= M * ison_ael[t])
        JuMP.@constraint(model, [t=T], ael_in[t]/ael_ml >= ael_cap - M * (1 - ison_ael[t]))
    else
        MarketFlow.@critical "Unknown electrolyzer type" settings.config["el_type"]
    end
end

function construct_objective!(model::JuMP.Model, settings::_Settings) end

end
