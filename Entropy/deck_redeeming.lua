SMODS.ObjectType { --idk how the inject function works, probably do that later for mod compat
    key = "RedeemableBacks",
    default = "b_red",
    cards = {
        "b_red",
        "b_blue",
        "b_yellow",
        "b_green",
        "b_black",
        "b_magic",
        "b_nebula",
        "b_ghost",
        "b_zodiac",
        "b_painted",
        "b_anaglyph",
        "b_plasma",
        "b_erratic",
        "b_abandoned",
        "b_checkered"
    }
}

G.FUNCS.buy_deckorsleeve = function(e)
    local c1 = e.config.ref_table
    --G.GAME.DefineBoosterState = G.STATE
    --c1:open()
    if not c1.config then
        c1.config = {}
    end
    if not c1.config.center then
        c1.config.center = G.P_CENTERS[c1.center_key]
    end
    if c1.area then c1.area:remove_card(c1) end
    if c1.config and c1.config.center and c1.config.center.apply then
        local orig = G.GAME.starting_params.joker_slots
        if c1.config.center.set == "Sleeve" then
            c1.config.center:apply(c1.config.center)
        else    
            c1.config.center:apply(false)
        end
        local diff = G.GAME.starting_params.joker_slots - orig
        if to_big(diff) > to_big(0) then
            Spectrallib.handle_card_limit(G.jokers, diff)
        end
    end
    for i, v in pairs(c1.config and c1.config.center and c1.config.center.config or {}) do
        if i == "hands" then 
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + v 
            ease_hands_played(v)
        end
        if i == "discards" then 
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + v 
            ease_discard(v)
        end
        if i == "joker_slot" then Spectrallib.handle_card_limit(G.jokers, v) end
        if i == "hand_size" then Spectrallib.handle_card_limit(G.hand, v) end
        if i == "dollars" then ease_dollars(v) end
        if i == "spectral_rate" then G.GAME.spectral_rate = v end
        if i == "plincoins" then ease_plincoins(v) end
        if i == "jokers" then
            delay(0.4)
            G.E_MANAGER:add_event(Event({
                func = function()
                    for k, v in ipairs(c1.config.center.jokers) do
                        local card = create_card('Joker', G.jokers, nil, nil, nil, nil, v, 'deck')
                        card:add_to_deck()
                        G.jokers:emplace(card)
    					card:start_materialize()
                    end
                return true
                end
            }))
        end
        if i == "voucher" then
            G.GAME.used_vouchers[c1.config.center.config.voucher] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    Card.apply_to_run(nil, G.P_CENTERS[c1.config.center.config.voucher])
                    return true
                end
            }))
        end
        if i == "consumables" then
            delay(0.4)
            G.E_MANAGER:add_event(Event({
                func = function()
                    for k, v in ipairs(c1.config.center.config.consumables) do
                        local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, v, 'deck')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                return true
                end
            }))
        end
        if i == "vouchers" then
            for k, v in pairs(c1.config.center.config.vouchers) do
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        Card.apply_to_run(nil, G.P_CENTERS[v])
                        return true
                    end
                }))
            end
        end
        if i == "consumable_slot" then
            G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots + v
        end
        if i == "ante_scaling" then
            G.GAME.starting_params.ante_scaling = v
        end
        if i == "boosters_in_shop" then
            G.GAME.starting_params.boosters_in_shop = v
        end
        if i == "no_interest" then
            G.GAME.modifiers.no_interest = true
        end
        if i == "extra_hand_bonus" then 
            G.GAME.modifiers.money_per_hand = v
        end
        if i == "extra_discard_bonus" then 
            G.GAME.modifiers.money_per_discard = v
        end
        if i == "no_faces" then
            for i, v in pairs(G.playing_cards) do
                if v:is_face() then
                    SMODS.change_base(v, nil, pseudorandom_element({"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, pseudoseed("abandoned_redeem")))
                end
            end
        end
        if i == "randomize_rank_suit" then
            for i, v in pairs(G.playing_cards) do
                Spectrallib.randomize_rank_suit(v, true, true, "erratic_midgame")
            end
        end
    end
    if c1.config and c1.config.center and c1.config.center.config and c1.config.center.config then
        if c1.config.center.key == "b_checkered" or c1.config.center.key == "sleeve_casl_checkered" then
            for i, v in pairs(G.playing_cards) do
                if v:is_suit("Diamonds") then
                    SMODS.change_base(v, "Hearts")
                elseif v:is_suit("Clubs") then
                    SMODS.change_base(v, "Spades")
                elseif not v:is_suit("Hearts") and not  v:is_suit("Spades") then
                    SMODS.change_base(v, pseudorandom_element({"Spades", "Hearts"}, pseudoseed("checkered_redeem")), nil)
                end
            end
        elseif c1.config.center.key == "b_entr_doc" or c1.config.center.key == "sleeve_entr_doc" then
            -- G.E_MANAGER:add_event(Event({
            --     trigger = "after",
            --     delay = 0.1,
            --     func = function()
            --         G.HUD:remove()
            --         G.HUD = nil
            --         G.HUD = UIBox{
            --             definition = create_UIBox_HUD(),
            --             config = {align=('cli'), offset = {x=-1.3,y=0},major = G.ROOM_ATTACH}
            --         }
            --         for i, v in pairs(G.hand_text_area) do
            --             G.hand_text_area[i] = G.HUD:get_UIE_by_ID(v.config.id)
            --         end
            --         G.HUD_blind:remove()
            --         G.HUD_blind = UIBox{
            --              definition = create_UIBox_HUD_blind_doc(),
            --              config = {major = G.HUD:get_UIE_by_ID('row_blind'), align = 'cm', offset = {x=0,y=-10}, bond = 'Weak'}
            --         }
            --         G.HUD:recalculate()
            --         G.HUD_blind:recalculate()
            --         return true
            --     end
            -- }))
        end
    end
    if c1.config and c1.config.center and c1.config.center.config and c1.config.center.config and c1.config.center.config.cry_beta then
        local count = G.consumeables.config.card_limit
        local cards = {}
        for i, v in pairs(G.jokers.cards) do
            cards[#cards+1]=v
        end
        for i, v in pairs(G.consumeables.cards) do
            cards[#cards+1]=v
        end
        for i, v in pairs(cards) do
            v.area:remove_card(v)
            v:remove_from_deck()
        end
        G.consumeables:remove()
        count = count + G.jokers.config.card_limit
        G.jokers:remove()
        G.consumeables = nil
        local CAI = {
            discard_W = G.CARD_W,
            discard_H = G.CARD_H,
            deck_W = G.CARD_W*1.1,
            deck_H = 0.95*G.CARD_H,
            hand_W = 6*G.CARD_W,
            hand_H = 0.95*G.CARD_H,
            play_W = 5.3*G.CARD_W,
            play_H = 0.95*G.CARD_H,
            joker_W = 4.9*G.CARD_W,
            joker_H = 0.95*G.CARD_H,
            consumeable_W = 2.3*G.CARD_W,
            consumeable_H = 0.95*G.CARD_H
        }
        G.jokers = CardArea(
            CAI.consumeable_W, 0,
            CAI.joker_W+CAI.consumeable_W,
            CAI.joker_H,
            {card_limit = count, type = 'joker', highlight_limit = 1e100}
        )
        G.consumeables = G.jokers
        for i, v in pairs(cards) do
            v:add_to_deck()
            G.jokers:emplace(v)
        end
    end
    G.GAME.entr_bought_decks = G.GAME.entr_bought_decks or {}
    G.GAME.entr_bought_decks[#G.GAME.entr_bought_decks+1] = c1.config.center.key
    c1:start_dissolve()
    if c1.children.price then c1.children.price:remove() end
    c1.children.price = nil
    if c1.children.buy_button then c1.children.buy_button:remove() end
    c1.children.buy_button = nil
    remove_nils(c1.children)

    SMODS.calculate_context({ pull_card = true, card = c1 })
    --c1:remove()
end

local ref = SMODS.calculate_context
function SMODS.calculate_context(context, return_table)
    local tbl = ref(context,return_table)
    if G.GAME.entr_bought_decks then
        for i, v in pairs(G.GAME.entr_bought_decks or {}) do
            if G.P_CENTERS[v].calculate then
                local ret = G.P_CENTERS[v].calculate(G.P_CENTERS[v], nil, context or {})
                for k,v in pairs(ret or {}) do 
                    tbl[k] = v 
                end
            end
        end
    end
    if not return_table then
        return tbl
    end
end

local trigger_effectref = Back.trigger_effect
function Back:trigger_effect(args, ...)
    local chips, mult = trigger_effectref(self, args, ...)
    if G.GAME.entr_bought_decks then
        for i, v in pairs(G.GAME.entr_bought_decks or {}) do
            if v == 'b_anaglyph' and args.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        add_tag(Tag('tag_double'))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end)
                }))
            end
            if v == "b_plasma" and args.context == 'final_scoring_step' then
                chips = chips or args.chips
                mult = mult or args.mult
                local tot = chips + mult
                chips = math.floor(tot/2)
                mult = math.floor(tot/2)
                update_hand_text({delay = 0}, {mult = mult, chips = chips})

                G.E_MANAGER:add_event(Event({
                    func = (function()
                        local text = localize('k_balanced')
                        play_sound('gong', 0.94, 0.3)
                        play_sound('gong', 0.94*1.5, 0.2)
                        play_sound('tarot1', 1.5)
                        ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                        ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                        attention_text({
                            scale = 1.4, text = text, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
                        })
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            blockable = false,
                            blocking = false,
                            delay =  4.3,
                            func = (function() 
                                    ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                                    ease_colour(G.C.UI_MULT, G.C.RED, 2)
                                return true
                            end)
                        }))
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            blockable = false,
                            blocking = false,
                            no_delete = true,
                            delay =  6.3,
                            func = (function() 
                                G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                                G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                                return true
                            end)
                        }))
                        return true
                    end)
                }))
            end
        end
    end
    return chips, mult
end

function Card:redeem_deck()
    if self.ability.set == "Back" or self.ability.set == "Sleeve" then
        G.GAME.current_round.voucher.spawn[self.config.center_key] = nil
        local prev_state = G.STATE
        stop_use()
        if not self.config.center.discovered then
            discover_card(self.config.center)
        end
        --G.STATE = G.STATES.SMODS_REDEEM_VOUCHER

        self.states.hover.can = false
        local top_dynatext = nil
        local bot_dynatext = nil
        
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                top_dynatext = DynaText({string = localize{type = 'name_text', set = self.config.center.set, key = self.config.center.key}, colours = {G.C.WHITE}, rotate = 1,shadow = true, bump = true,float=true, scale = 0.9, pop_in = 0.6/G.SPEEDFACTOR, pop_in_rate = 1.5*G.SPEEDFACTOR})
                bot_dynatext = DynaText({string = localize('k_redeemed_ex'), colours = {G.C.WHITE}, rotate = 2,shadow = true, bump = true,float=true, scale = 0.9, pop_in = 1.4/G.SPEEDFACTOR, pop_in_rate = 1.5*G.SPEEDFACTOR, pitch_shift = 0.25})
                self:juice_up(0.3, 0.5)
                play_sound('card1')
                play_sound('coin1')
                self.children.top_disp = UIBox{
                    definition =    {n=G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes={
                                        {n=G.UIT.O, config={object = top_dynatext}}
                                    }},
                    config = {align="tm", offset = {x=0,y=0},parent = self}
                }
                self.children.bot_disp = UIBox{
                        definition =    {n=G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes={
                                            {n=G.UIT.O, config={object = bot_dynatext}}
                                        }},
                        config = {align="bm", offset = {x=0,y=0},parent = self}
                    }
            return true end }))
        if self.cost ~= 0 then
            ease_dollars(-self.cost)
            inc_career_stat('c_shop_dollars_spent', self.cost)
        end
        --G.GAME.current_round.voucher = nil


        delay(0.6)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 2.6, func = function()
            top_dynatext:pop_out(4)
            bot_dynatext:pop_out(4)
            return true end }))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
            self.children.top_disp:remove()
            self.children.top_disp = nil
            self.children.bot_disp:remove()
            self.children.bot_disp = nil
        return true end }))
        if self.children.use_button then self.children.use_button:remove(); self.children.use_button = nil end
        if self.children.sell_button then self.children.sell_button:remove(); self.children.sell_button = nil end
        if self.children.price then self.children.price:remove(); self.children.price = nil end
        local in_pack = ((G.GAME.pack_choices and G.GAME.pack_choices > 0) or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and G.STATE ~= G.STATES.SHOP
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
            G.FUNCS.buy_deckorsleeve{
                config = {
                    ref_table = self
                }
            }
            if G.booster_pack then
                if G.GAME.pack_choices and G.GAME.pack_choices >= 1 then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                        G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                        G.booster_pack.alignment.offset.py = nil
                        return true
                    end}))
                elseif G.shop then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                        G.shop.alignment.offset.y = G.shop.alignment.offset.py
                        G.shop.alignment.offset.py = nil
                        return true
                    end}))
                end
            elseif not in_pack then
                if G.shop then 
                    G.shop.alignment.offset.y = G.shop.alignment.offset.py
                    G.shop.alignment.offset.py = nil
                end
                if G.blind_select then
                    G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                    G.blind_select.alignment.offset.py = nil
                end
                if G.round_eval then
                    G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                    G.round_eval.alignment.offset.py = nil
                end
            end
        return true end }))
        if in_pack then 
            G.GAME.pack_choices = G.GAME.pack_choices - 1 
            if G.GAME.pack_choices <= 0 then
                G.CONTROLLER.interrupt.focus = true
                if prev_state == G.STATES.SMODS_BOOSTER_OPENED and booster_obj.name:find('Arcana') then inc_career_stat('c_tarot_reading_used', 1) end
                if prev_state == G.STATES.SMODS_BOOSTER_OPENED and booster_obj.name:find('Celestial') then inc_career_stat('c_planetarium_used', 1) end
                G.FUNCS.end_consumeable(nil, delay_fac)
            elseif G.booster_pack and not G.booster_pack.alignment.offset.py and (not (G.GAME.pack_choices and G.GAME.pack_choices > 1)) then
                G.booster_pack.alignment.offset.py = G.booster_pack.alignment.offset.y
                G.booster_pack.alignment.offset.y = G.ROOM.T.y + 29
            end
        else
            if G.shop and not G.shop.alignment.offset.py then
                G.shop.alignment.offset.py = G.shop.alignment.offset.y
                G.shop.alignment.offset.y = G.ROOM.T.y + 29
            end
            if G.blind_select and not G.blind_select.alignment.offset.py then
                G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
            end
            if G.round_eval and not G.round_eval.alignment.offset.py then
                G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
                G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
            end
        end
    end
end