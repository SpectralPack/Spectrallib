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
            for _, joker_key in ipairs(value) do
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
            return true
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
    reroll_discount = function (deck_center, value)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - value
                G.GAME.current_round.reroll_cost = math.max(0,
                    G.GAME.current_round.reroll_cost - value)
                return true
            end
        }))
    end,
    edition = function (deck_center, value)
        local count = deck_center.config.edition_count
        local editionless_cards = {}
        for _,c in ipairs(G.playing_cards) do
            if not c.edition then
                editionless_cards[#editionless_cards+1] = c
            end
        end
        pseudoshuffle(editionless_cards, "edition_deck_midgame")
        G.E_MANAGER:add_event(Event{
            func = function (n)
                for i = 1, count do
                    if editionless_cards[i] then
                        editionless_cards[i]:set_edition({[value] = true}, nil, true) --this method sucks but vanilla uses it
                    end
                end
                return true
            end
        })
    end
}

---@type {[string]: fun(value: any)}
Spectrallib.deck_config_unapply_effects = {
    hands = function (value)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - value
        ease_hands_played(-value)
    end,
    discards = function (value)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - value
        ease_discard(-value)
    end,
    joker_slot = function (value)
        Spectrallib.handle_card_limit(G.jokers, -value)
    end,
    hand_size = function (value)
        Spectrallib.handle_card_limit(G.hand, -value)
    end,
    dollars = function (value)
        ease_dollars(-value)
    end,

    -- commented out properties are not modified !!
    -- feel free to modify them to uncomment them

    --[[spectral_rate = function (value)
        G.GAME.spectral_rate = value
    end,]]
    --[[jokers = function (value)
        Spectrallib.event(0.4)
        Spectrallib.event(function ()
            for _, joker_key in ipairs(value) do
                SMODS.add_card{
                    set = 'Joker',
                    area = G.jokers,
                    key = joker_key,
                    key_append = 'deck'
                }
            end
            return true
        end)
    end,]]
    voucher = function (value)
        for _,voucher in pairs(G.vouchers.cards) do
            if voucher.config.center.key == value then
                voucher:unapply_to_run(voucher.config.center)
            end
        end
    end,
    --[[consumables = function (value)
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
            return true
        end)
    end,]]
    vouchers = function (value)
        for _,voucher in pairs(G.vouchers.cards) do
            for _,target_voucher_key in pairs(value) do
                if voucher.config.center.key == target_voucher_key then
                    voucher:unapply_to_run(voucher.config.center)
                    break
                end
            end
        end
    end,
    consumable_slot = function (value)
        G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots - value
    end,
    --[[ante_scaling = function (value)
        G.GAME.starting_params.ante_scaling = value
    end,]]
    --[[boosters_in_shop = function (value)
        G.GAME.starting_params.boosters_in_shop = value
    end,]]
    --[[no_interest = function (value)
        G.GAME.modifiers.no_interest = true
    end,]]
    --[[extra_hand_bonus = function (value)
        G.GAME.modifiers.money_per_hand = value
    end,]]
    --[[extra_discard_bonus = function (value)
        G.GAME.modifiers.money_per_discard = value
    end,]]
    --[[no_faces = function (value)
        local nonfaces = {"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
        for _,card in pairs(G.playing_cards) do
            if card:is_face() then
                SMODS.change_base(card, nil, pseudorandom_element(nonfaces, pseudoseed("abandoned_redeem")))
            end
        end
    end,]]
    --[[randomize_rank_suit = function (value)
        for _,card in pairs(G.playing_cards) do
            Spectrallib.randomize_rank_suit(card, true, true, "erratic_midgame")
        end
    end,]]
    --[[reroll_discount = function (value)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - value
                G.GAME.current_round.reroll_cost = math.max(0,
                    G.GAME.current_round.reroll_cost - value)
                return true
            end
        }))
    end,]]
    --[[edition = function (value)
        local count = deck_center.config.edition_count
        local editionless_cards = {}
        for _,c in ipairs(G.playing_cards) do
            if not c.edition then
                editionless_cards[#editionless_cards+1] = c
            end
        end
        pseudoshuffle(editionless_cards, "edition_deck_midgame")
        G.E_MANAGER:add_event(Event{
            func = function (n)
                for i = 1, count do
                    if editionless_cards[i] then
                        editionless_cards[i]:set_edition({[value] = true}, nil, true) --this method sucks but vanilla uses it
                    end
                end
                return true
            end
        })
    end]]
}

---@type {[string]: fun()}
Spectrallib.vanilla_unapply_deck_results = {
    b_red = function()
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        ease_discard(-1)
    end,
    b_blue = function()
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        ease_hands_played(-1)
    end,
    b_yellow = function()
        ease_dollars(-10)
    end,
    b_green = function()
        G.GAME.modifiers.no_interest = nil
        G.GAME.modifiers.money_per_discard = 0
        G.GAME.modifiers.money_per_hand = 1
    end,
    b_black = function()
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
        ease_hands_played(1)
    end,
    b_magic = function()
        for _, v in pairs(G.vouchers.cards) do
            if v.config.center.key == "v_crystal_ball" then v:unapply_to_run(v.config.center) end
        end
    end,
    b_nebula = function()
        for _, v in pairs(G.vouchers.cards) do
            if v.config.center.key == "v_telescope" then v:unapply_to_run(v.config.center) end
        end
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
    end,
    b_ghost = function()
        G.GAME.spectral_rate = 0
    end,
    b_zodiac = function()
        for i, v in pairs(G.vouchers.cards) do
            if v.config.center.key == "v_tarot_merchant" 
            or v.config.center.key == "v_overstock"
            or v.config.center.key == "v_planet_merchant"
            then v:unapply_to_run(v.config.center) end
        end
    end,
    b_painted = function()
        G.hand.config.card_limit = G.hand.config.card_limit - 2
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end
}