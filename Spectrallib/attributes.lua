local attributes = {
    "echips", "emult", "hyperchips", "hypermult",
    "eqchips", "eqmult", "asc", "xasc", "easc", "hyperasc",
    "forcetrigger", "value_manip",
    "multiuse", "ccd",
    "escore", "eblindsize", "hyperscore", "hyperblindsize",
    "asc_power", --for general interacting with ascension power, but NOT the scoring effect (e.g. exploit or sol from cryptid)
}

for _, v in ipairs(attributes) do
    SMODS.Attribute { key = v }
end