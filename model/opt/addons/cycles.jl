
module GlobalAddon_Cycles

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
    bess_charge = component(model, "bess.charge")
    bess_charge_in = MarketFlow._total(bess_charge, :in, "dc")
    bess_invest_cap = component(model, "bess.invest").var.value * 0.5

    N = settings.config["n_cycles_per_year"]
    scale = 8760 / length(MarketFlow._iesopt(model).model.T)
    JuMP.@constraint(model, sum(bess_charge_in) * scale <= bess_invest_cap * N)
end

function construct_objective!(model::JuMP.Model, settings::_Settings) end

end
