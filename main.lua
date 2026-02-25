SMODS.Atlas {
    key = "modicon",
    path = "crylib_icon.png",
    px = 34,
    py = 34,
}:register()

Spectrallib = {}

local files = {

    {path = "other_utils"},
    {path = "blind_functions"},
    {path = "modpage_ui"},

    {path = "Cryptlib/main", redirect = "Cryptid"},
    {path = "Cryptlib/talisman", redirect = "Cryptid"}, -- this is probably not needed with amulet existing but back compat so shrug
    {path = "Cryptlib/manipulate", redirect = "Cryptid"},
    {path = "Cryptlib/forcetrigger", redirect = "Cryptid"},
    {path = "Cryptlib/utilities", redirect = "Cryptid"},
    {path = "Cryptlib/content_sets", redirect = "Cryptid"},
    {path = "Cryptlib/ascended", redirect = "Cryptid"},
    {path = "Cryptlib/unredeem", redirect = "Cryptid"},
    {path = "Cryptlib/colours"}, -- this doesn't have an equivalent in cryptid currently

    {path = "Entropy/utils", redirect = "Entropy"},
    {path = "Entropy/hand_stuff", redirect = "Entropy"},
    {path = "Entropy/suit_levels", redirect = "Entropy"},
    {path = "Entropy/return_values", redirect = "Entropy"},
    {path = "Entropy/deck_redeeming", redirect = "Entropy"},
    {path = "Entropy/card_buttons", redirect = "Entropy"},
}
for i, v in pairs(files) do
    if v.redirect then
        _G[v.redirect] = _G[v.redirect] or {}
        setmetatable(Spectrallib, {
            __newindex = function(table, key, value)
            rawset(table, key, value)
            _G[v.redirect][key] = value
            end
        })
    end
    local file, err = SMODS.load_file(v.path..".lua")
    if file then file() 
    else error("Error in file: "..v.path.." "..err) end
end