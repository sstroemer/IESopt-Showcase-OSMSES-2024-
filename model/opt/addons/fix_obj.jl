module GlobalAddon_FixObj

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

function construct_constraints!(model::JuMP.Model, settings::_Settings) end

function construct_objective!(model::JuMP.Model, settings::_Settings)
    wind_invest = MarketFlow._iesopt(model).model.objectives["wind_invest"].terms
    push!(wind_invest, component(model, "wind.invest").var.value + 0)

    pv_invest = MarketFlow._iesopt(model).model.objectives["pv_invest"].terms
    push!(pv_invest, component(model, "pv.invest").var.value + 0)

    storage_invest = MarketFlow._iesopt(model).model.objectives["storage_invest"].terms
    push!(storage_invest, component(model, "h2_storage.invest").var.value + 0)
    push!(storage_invest, component(model, "bess.invest").var.value + 0)

    el_invest = MarketFlow._iesopt(model).model.objectives["el_invest"].terms
    if settings.config["el_type"] == "PEMEL"
        push!(el_invest, component(model, "pemel.invest").var.value + 0)
    elseif settings.config["el_type"] == "AEL"
        push!(el_invest, component(model, "ael.invest").var.value + 0)
    end   
end

end