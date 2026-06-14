-- ???
Spectrallib.ChaosBlacklist = {}
-- ???
Spectrallib.ParakmiBlacklist = {}
-- unused by Spectrallib
Spectrallib.ChaosConversions = {}
--identical to entropy, for some reason entropy table was still used in use and sell buttons hook
Spectrallib.ConsumablePackBlacklist = {
    p_mupack_multipack1=true,
    p_mupack_multipack2=true,
    p_mupack_multipack3=true,
    p_mupack_multipack4=true,
    p_mupack_multipack5=true,
}

-- Used by string_random
Spectrallib.charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~#$^~#$^~#$^~#$^~#$^"

-- Position -> Rarity key
Spectrallib.RarityChecks = {1, 2, 3, 4}
if Cryptid and Cryptid.memepack then --using legacy stuff to check for cryptid and not cryptlib
    Spectrallib.RarityChecks = {[0] = "cry_candy", 1, 2, 3, "cry_epic", 4, "cry_exotic", "entr_entropic"}
end

-- Rarity key -> Position
Spectrallib.ReverseRarityChecks = {}
for i, v in ipairs(Spectrallib.RarityChecks) do
    Spectrallib.ReverseRarityChecks[v] = i
end

-- Shorthands for context checks, used by `Spectrallib.context_checks()`
---@type {[string]: true | fun(card: Card, context: table, currc: string, edition: boolean|any): (boolean|any) }
Spectrallib.context_check_def = {
    pre_joker = function (card, context, currc, edition)
        return context.pre_joker or (
            edition
            and context.main_scoring
            and context.cardarea == G.play
        )
    end,
    joker_main = function (card, context, currc, edition)
        return context.joker_main or (
            edition
            and context.main_scoring
            and context.cardarea == G.play
        )
    end,
    individual = function (card, context, currc, edition)
        return (
            context.individual
            and context.cardarea == G.play
            and not context.blueprint
        ) or (
            edition
            and context.main_scoring
            and context.cardarea == G.play
        )
    end,
    pre_discard = function (card, context, currc, edition)
        return (
            context.pre_discard
            and context.cardarea == G.hand
            and not context.retrigger_joker
            and not context.blueprint
        )
    end,
    remove_playing_cards = function (card, context, currc, edition)
        return (
            context.remove_playing_cards
            and not context.blueprint
        )
    end,
    -- Equivalent to `function(card, context, currc, edition) return context[key] end`
    before = true,
    setting_blind = true,
    ending_shop = true,
    reroll_shop = true,
    selling_card = true,
    using_consumeable = true,
    playing_card_added = true,
}