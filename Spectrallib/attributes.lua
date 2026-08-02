if not SMODS.Attribute then return end

local attributes = {
    "echips", "emult", "hyperchips", "hypermult",
    "eqchips", "eqmult", "asc", "xasc", "easc", "hyperasc",
    "escore", "eblindsize", "hyperscore", "hyperblindsize",
    "forcetrigger", "value_manip",
    "multiuse", "ccd",
    "escore", "eblindsize", "hyperscore", "hyperblindsize",
    "asc_power", --for general interacting with ascension power, but NOT the scoring effect (e.g. exploit or sol from cryptid)
    "suit_level", "rank_level", --just the hand_level attribute but for ranks/suits
    "backs", "sleeves", --attributes for center types that dont have one in smods (for some reason voucher is also missing in smods)
}

for _, v in ipairs(attributes) do
    SMODS.Attribute { key = v }
end

SMODS.Attribute {
    key = "vouchers",
    keys = {
        "tag_voucher",
    }
}