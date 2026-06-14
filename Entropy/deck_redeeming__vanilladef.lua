-- How deck config keys should be handled
-- `deck_center` is the prototype of the deck being redeemed, `value` is the value associated with the config key under `deck_center`
---@type {[string]: fun(deck_center: SMODS.Center, value: any)}
Spectrallib.deck_config_apply_effects = {
    hands = function (deck_center, value)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + value
        ease_hands_played(value)
    end,
    discards = function (deck_center, value)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + value
        ease_discard(value)
    end,
    joker_slot = function (deck_center, value)
        Spectrallib.handle_card_limit(G.jokers, value)
    end,
    hand_size = function (deck_center, value)
        Spectrallib.handle_card_limit(G.hand, value)
    end,
    dollars = function (deck_center, value)
        ease_dollars(value)
    end,
    spectral_rate = function (deck_center, value)
        G.GAME.spectral_rate = value
    end,
    jokers = function (deck_center, value)
        Spectrallib.event(0.4)
        Spectrallib.event(function ()
            for _, joker_key in pairs(deck_center.jokers) do
                SMODS.add_card{
                    set = 'Joker',
                    area = G.jokers,
                    key = joker_key,
                    key_append = 'deck'
                }
            end
            return true
        end)
    end,
    voucher = function (deck_center, value)
        G.GAME.used_vouchers[deck_center.config.voucher] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        Spectrallib.event(function ()
            Card.apply_to_run(nil, G.P_CENTERS[deck_center.config.voucher])
            return true
        end)
    end,
    consumables = function (deck_center, value)
        Spectrallib.event(0.4)
        Spectrallib.event(function ()
            for _,consumable_key in pairs(deck_center.config.consumables) do
                SMODS.add_card{
                    set = 'Tarot',
                    area = G.consumeables,
                    key = consumable_key,
                    key_append = 'deck'
                }
            end
        end)
    end,
    vouchers = function (deck_center, value)
        for _,voucher_key in pairs(deck_center.config.vouchers) do
            G.GAME.used_vouchers[voucher_key] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            Spectrallib.event(function ()
                Card.apply_to_run(nil, G.P_CENTERS[voucher_key])
                return true
            end)
        end
    end,
    consumable_slot = function (deck_center, value)
        G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots + value
    end,
    ante_scaling = function (deck_center, value)
        G.GAME.starting_params.ante_scaling = value
    end,
    boosters_in_shop = function (deck_center, value)
        G.GAME.starting_params.boosters_in_shop = value
    end,
    no_interest = function (deck_center, value)
        G.GAME.modifiers.no_interest = true
    end,
    extra_hand_bonus = function (deck_center, value)
        G.GAME.modifiers.money_per_hand = value
    end,
    extra_discard_bonus = function (deck_center, value)
        G.GAME.modifiers.money_per_discard = value
    end,
    no_faces = function (deck_center, value)
        local nonfaces = {"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
        for _,card in pairs(G.playing_cards) do
            if card:is_face() then
                SMODS.change_base(card, nil, pseudorandom_element(nonfaces, pseudoseed("abandoned_redeem")))
            end
        end
    end,
    randomize_rank_suit = function (deck_center, value)
        for _,card in pairs(G.playing_cards) do
            Spectrallib.randomize_rank_suit(card, true, true, "erratic_midgame")
        end
    end,
}