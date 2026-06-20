local attributes = {
    "echips", "emult", "hyperchips", "hypermult",
    "eqchips", "eqmult", "asc", "xasc", "easc", "hyperasc",
    "forcetrigger", "value_manip",
    "multiuse", "ccd",
    "escore", "eblindsize", "hyperscore", "hyperblindsize"
}

for _, v in ipairs(attributes) do
    SMODS.Attribute { key = v }
end