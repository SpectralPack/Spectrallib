function Spectrallib.can_mods_load(...)
    local mods = {...}
    if type(mods[1]) == "table" then
        mods = mods[1]
    end
    for i, v in pairs(mods) do
        if (SMODS.Mods[v] or {}).can_load then return true end
    end
end

function Spectrallib.optional_feature(key)
    for i, v in pairs(SMODS.Mods) do
        if v.can_load and v.spectrallib_features and Spectrallib.in_table(v.spectrallib_features, key) then return true end
    end
end