if not Spectrallib.can_mods_load({"entr"}) then return end

Entropy.get_highlighted_cards = Spectrallib.get_highlighted_cards
Entropy.blind_is = Spectrallib.blind_is

-- Hook for Axeh's effect
local splib_calcascmod_ref = Spectrallib.calculate_ascension_modification
function Spectrallib.calculate_ascension_modification(args)
    for _,axeh in ipairs(SMODS.find_card('j_entr_axeh')) do
        args.calc_args.amount = args.calc_args.amount(axeh.ability.asc_mod)
    end
    return splib_calcascmod_ref(args)
end

-- Hook for Strawberry Pie's effect
local smods_upgradehand_ref = SMODS.upgrade_poker_hands
function SMODS.upgrade_poker_hands(args)
    args.hands = args.hands or G.handlist
    if type(args.hands) == "string" then args.hands = {args.hands} end
    if next(SMODS.find_card("j_entr_strawberry_pie")) then
        for index in pairs(args.hands) do
            if args.hands[index] == "Full House" or args.hands[index] == "Straight" or args.hands[index] == "Flush" then
                args.hands[index] = "High Card"
            end
        end
    end
    return smods_upgradehand_ref(args)
end