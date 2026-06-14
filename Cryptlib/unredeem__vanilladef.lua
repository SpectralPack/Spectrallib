-- Unapply results for Vanilla vouchers
-- (You should really be using the unapply method in voucher definitions)
---@type { [string]: fun(card: Card, center_table: {name: string, extra: any}): nil }
Spectrallib.vanilla_unapply_results = {}
local unap = Spectrallib.vanilla_unapply_results

unap["Overstock"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            change_shop_size(-center_table.extra)
            return true
        end,
    }))
end
unap["Overstock Plus"] = unap["Overstock"]

unap["Clearance Sale"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.discount_percent = 0
            for k, v in pairs(G.I.CARD) do
                if v.set_cost then
                    v:set_cost()
                end
            end
            return true
        end,
    }))
end
unap["Liquidation"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.discount_percent = 25 -- no idea why the below returns nil, so it's hardcoded now
            -- G.GAME.discount_percent = G.P_CENTERS.v_clearance_sale.extra
            for k, v in pairs(G.I.CARD) do
                if v.set_cost then
                    v:set_cost()
                end
            end
            return true
        end,
    }))
end

unap["Hone"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.edition_rate = G.GAME.edition_rate / center_table.extra
            return true
        end,
    }))
end
unap["Glow Up"] = unap["Hone"]

unap["Reroll Surplus"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost + card.ability.extra
            G.GAME.current_round.reroll_cost = math.max(0, G.GAME.current_round.reroll_cost + card.ability.extra)
            return true
        end,
    }))
end
unap["Reroll Glut"] = unap["Reroll Surplus"]

unap["Crystal Ball"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.consumeables.config.card_limit = G.consumeables.config.card_limit - center_table.extra
            return true
        end,
    }))
end
-- Omen Globe

-- Telescope
-- Observatory

unap["Grabber"] = function(card, center_table)
    G.GAME.round_resets.hands = G.GAME.round_resets.hands - center_table.extra
    ease_hands_played(-center_table.extra)
end
unap["Nacho Tong"] = unap["Grabber"]

unap["Wasteful"] = function(card, center_table)
    G.GAME.round_resets.discards = G.GAME.round_resets.discards - center_table.extra
    ease_discard(-center_table.extra)
end
unap["Recyclomancy"] = unap["Wasteful"]

unap["Tarot Merchant"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.tarot_rate = G.GAME.tarot_rate / center_table.extra
            return true
        end,
    }))
end
unap["Tarot Tycoon"] = unap["Tarot Merchant"]

unap["Planet Merchant"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.planet_rate = G.GAME.planet_rate / center_table.extra
            return true
        end,
    }))
end
unap["Planet Tycoon"] = unap["Planet Merchant"]

unap["Seed Money"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.interest_cap = 25 --note: does not account for potential deck effects
            return true
        end,
    }))
end
unap["Money Tree"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            if G.GAME.used_vouchers.v_seed_money then
                G.GAME.interest_cap = 50
            else
                G.GAME.interest_cap = 25
            end
            return true
        end,
    }))
end

-- Blank
unap["Antimatter"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            if G.jokers then
                G.jokers.config.card_limit = G.jokers.config.card_limit - center_table.extra
            end
            return true
        end,
    }))
end

unap["Magic Trick"] = function(card, center_table)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.playing_card_rate = 0
            return true
        end,
    }))
end
-- Illusion

unap["Hieroglyph"] = function (card, center_table)
    ease_ante(center_table.extra)
    G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
    G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + center_table.extra

    G.GAME.round_resets.hands = G.GAME.round_resets.hands + center_table.extra
    ease_hands_played(center_table.extra)
end
unap["Petroglyph"] = function (card, center_table)
    ease_ante(center_table.extra)
    G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
    G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + center_table.extra

    G.GAME.round_resets.discards = G.GAME.round_resets.discards + center_table.extra
    ease_discard(center_table.extra)
end

-- Director's Cut
-- Retcon

unap["Paint Brush"] = function(card, center_table)
    G.hand:change_size(-center_table.extra)
end
unap["Palette"] = unap["Paint Brush"]