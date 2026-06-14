SMODS.Atlas {
    key = "modicon",
    path = "crylib_icon.png",
    px = 34,
    py = 34,
}:register()

Spectrallib = {}

SMODS.current_mod.reset_game_globals = function (run_start)
    if run_start then
        -- Value Manipulation API
        Spectrallib.base_values = {}
        ---@type string[] List of deck keys. 
        G.GAME.entr_bought_decks = {}
    end
end

local gigo = Game.init_game_object
function Game:init_game_object()
    local ret = gigo(self)
    ret.SuitBuffs = {}
    for k in pairs(SMODS.Suits) do
        ret.SuitBuffs[k] = { level = 1, chips = 0, mult = 0 }
    end
    ret.SuitBuffs.suitless = { level = 1, chips = 0, mult = 0 }
    return ret
end
--[[
SMODS.current_mod.reset_game_globals = function (run_start)
end
]]
local files = {

    {path = "Spectrallib/other_utils"},
    {path = "Spectrallib/blind_functions"},
    {path = "Spectrallib/modpage_ui"},
    {path = "Spectrallib/attributes"},

    {path = "Cryptlib/main", redirect = "Cryptid"},
    {path = "Cryptlib/utilities", redirect = "Cryptid"},
    {path = "Cryptlib/talisman", redirect = "Cryptid"}, -- this is probably not needed with amulet existing but back compat so shrug
    {path = "Cryptlib/manipulate", redirect = "Cryptid"},
    {path = "Cryptlib/forcetrigger", redirect = "Cryptid"},
    {path = "Cryptlib/forcetrigger__vanilladef", redirect = "Cryptid"},
    {path = "Cryptlib/content_sets", redirect = "Cryptid"},
    {path = "Cryptlib/ascended", redirect = "Cryptid"},
    {path = "Cryptlib/unredeem", redirect = "Cryptid"},
    {path = "Cryptlib/unredeem__vanilladef", redirect = "Cryptid"},
    {path = "Cryptlib/colours"}, -- this doesn't have an equivalent in cryptid currently

    {path = "Entropy/main", redirect = "Entropy"},
    {path = "Entropy/utils", redirect = "Entropy"},
    {path = "Entropy/hand_stuff", redirect = "Entropy"},
    {path = "Entropy/suit_levels", redirect = "Entropy"},
    {path = "Entropy/return_values", redirect = "Entropy"},
    {path = "Entropy/deck_redeeming", redirect = "Entropy"},
    {path = "Entropy/deck_redeeming__vanilladef", redirect = "Entropy"},
    {path = "Entropy/card_buttons", redirect = "Entropy"},

    {path = "Lemniscate/utils", redirect = "Lemniscate"},
    {path = "Lemniscate/math", redirect = "Lemniscate"},
    {path = "Lemniscate/stat_mods", redirect = "Lemniscate"},

    {path = "compat/cryptid"},
    {path = "compat/spectrums"},
    {path = "compat/entropy"},
    {path = "compat/misc"},

}
for _, file_def in pairs(files) do
    if file_def.redirect then
        _G[file_def.redirect] = _G[file_def.redirect] or {}
        setmetatable(Spectrallib, {
            __newindex = function(table, key, value)
                rawset(table, key, value)
                if type(value) == "function" then
                    _G[file_def.redirect][key] = function (...)
                        return Spectrallib[key](...)
                    end
                else
                    _G[file_def.redirect][key] = value
                end
            end
        })
    end
    local file, err = SMODS.load_file(file_def.path..".lua")
    if file then file()
    else error(("Error in file: %s %s"):format(file_def.path, err)) end
end