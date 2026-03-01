local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	local abc = G_UIDEF_use_and_sell_buttons_ref(card)
	-- Allow code cards to be reserved
    if (card.area == G.consumeables or card.area == G.jokers) and (card.config.center.set == "Voucher" or card.ability.set == "Voucher") then
        local sell = {n=G.UIT.C, config={align = "cr"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = 'sell'}, nodes={
              {n=G.UIT.B, config = {w=0.1,h=0.6}},
              {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                  {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                  {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                }}
              }}
            }},
          }}
        local use = 
        {n=G.UIT.C, config={align = "cr"}, nodes={
          
          {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'open_voucher', func = 'can_open_voucher', handy_insta_action = 'use'}, nodes={
            {n=G.UIT.B, config = {w=0.1,h=0.6}},
            {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
          }}
        }}
        return {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  sell
                }},
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  use
                }},
              }},
          }}
    end
    if (card.ability.set == "Back" or card.ability.set == "Sleeve" or card.config.center.set == "Back" or card.config.center.set == "Sleeve") then
        if card.area == G.hand or card.area == G.pack_cards then
        return  {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'buy_deckorsleeve', func = 'can_buy_deckorsleeve', handy_insta_action = 'buy_or_sell'}, nodes={
                {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
              }},
          }}
        end
        if card.area == G.consumeables or card.area == G.jokers then
            local sell = {n=G.UIT.C, config={align = "cr"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = "sell"}, nodes={
                  {n=G.UIT.B, config = {w=0.1,h=0.6}},
                  {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                      {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                      {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                      {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                    }}
                  }}
                }},
              }}
            local use = 
            {n=G.UIT.C, config={align = "cr"}, nodes={
              
              {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'buy_deckorsleeve', func = 'can_buy_deckorsleeve', handy_insta_action = 'use'}, nodes={
                {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
              }}
            }}
            return {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                  {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                      sell
                    }},
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                      use
                    }},
                  }},
              }}
        end
    end
    if ((card.area == G.consumeables or card.area == G.jokers) and G.consumeables and card.config.center.set == "Booster") then
        local sell = {n=G.UIT.C, config={align = "cr"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = 'sell'}, nodes={
              {n=G.UIT.B, config = {w=0.1,h=0.6}},
              {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                  {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                  {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                }}
              }}
            }},
          }}
        local use = 
        {n=G.UIT.C, config={align = "cr"}, nodes={
          
          {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'open_booster', func = 'can_open_booster', handy_insta_action = 'use'}, nodes={
            {n=G.UIT.B, config = {w=0.1,h=0.6}},
            {n=G.UIT.T, config={text = localize('b_open'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
          }}
        }}
        return {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  sell
                }},
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  use
                }},
              }},
          }}
    end
    if (card.area == G.hand and G.hand) then --Add a use button
		if card.config.center.set == "Joker" then
			return  {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                  {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'reserve_joker', func = 'can_reserve_joker', handy_insta_action = 'buy_or_sell'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
                  }},
              }}
		end
        if card.config.center.set == "Booster" then
			return  {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                  {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'open_booster', func = 'can_open_booster', handy_insta_action = 'buy_or_sell'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_open'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
                  }},
              }}
		end
        if card.config.center.set == "Voucher" then
			return  {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                  {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'open_voucher', func = 'can_open_voucher', handy_insta_action = 'buy_or_sell'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
                  }},
              }}
		end
	end
    --let boosters not be recursive
    if (card.area == G.pack_cards and G.pack_cards) and card.config.center.set == "Booster" and not Spectrallib.ConsumablePackBlacklist[SMODS.OPENED_BOOSTER.config.center.key] then
        return  {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'reserve_booster', func = 'can_reserve_booster', handy_insta_action = 'buy_or_sell'}, nodes={
                {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
              }},
          }}
    end
    if (card.area == G.jokers and G.jokers and card.config.center.use) and not card.debuff and card.config.center.set == "Joker" then
        local sell = {n=G.UIT.C, config={align = "cr"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = 'sell'}, nodes={
              {n=G.UIT.B, config = {w=0.1,h=0.6}},
              {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                  {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                  {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                }}
              }}
            }},
        }}
        local config = Spectrallib.gather_button_config(card.config.center, card)
        card._spectrallib_use_key = localize(config.key)
        local transition = {n=G.UIT.C, config={align = "cr"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "cm",padding = 0.1, r=0.08, minw = 1.25, minh = 0.8, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'use_joker', func = config.func, handy_insta_action = 'use'}, nodes={
              {n=G.UIT.B, config = {w=0.1,h=config.h}},
              {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                  {n=G.UIT.T, config={ref_table = card, ref_value = "_spectrallib_use_key", colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                }},
              }},
            }},
        }}
        return {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  sell
                }},
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  transition
                }},
            }},
        }}
    end
    if Spectrallib.needs_use_button(card) and card.area == G.pack_cards and G.pack_cards and (Spectrallib.needs_pull_button(card) or (not SMODS.OPENED_BOOSTER or not SMODS.OPENED_BOOSTER.draw_hand and card.children.front and (card.ability.consumeable))) then
        return {
            n = G.UIT.ROOT,
            config = { padding = -0.1, colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = {
                        ref_table = card,
                        r = 0.08,
                        padding = 0.1,
                        align = "bm",
                        minw = 0.5 * card.T.w - 0.15,
                        minh = 0.1 * card.T.h or 0.7 * card.T.h,
                        maxw = 0.7 * card.T.w - 0.15,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = true,
                        button = "use_card",
                        func = card:is_playing_card() and "can_reserve_card_to_deck" or "can_reserve_card",
                        handy_insta_action = 'use'
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = Spectrallib.needs_pull_button(card),
                                colour = G.C.UI.TEXT_LIGHT,
                                scale = 0.55,
                                shadow = true,
                            },
                        },
                    },
                },
                {
                    n = G.UIT.R,
                    config = {
                        ref_table = card,
                        r = 0.08,
                        padding = 0.1,
                        align = "bm",
                        minw = 0.5 * card.T.w - 0.15,
                        maxw = 0.9 * card.T.w - 0.15,
                        minh = 0.1 * card.T.h,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = true,
                        button = "Do you know that this parameter does nothing?",
                        func = "can_use_consumeable",
                        handy_insta_action = 'use'
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("b_use"),
                                colour = G.C.UI.TEXT_LIGHT,
                                scale = 0.45,
                                shadow = true,
                            },
                        },
                    },
                },
                { n = G.UIT.R, config = { align = "bm", w = 7.7 * card.T.w } },
                { n = G.UIT.R, config = { align = "bm", w = 7.7 * card.T.w } },
                { n = G.UIT.R, config = { align = "bm", w = 7.7 * card.T.w } },
                { n = G.UIT.R, config = { align = "bm", w = 7.7 * card.T.w } },
                -- Betmma can't explain it, neither can I
            },
        }
    elseif card.area == G.pack_cards and G.pack_cards and (Spectrallib.needs_pull_button(card) or (not SMODS.OPENED_BOOSTER or not SMODS.OPENED_BOOSTER.draw_hand and card.children.front and (card.ability.consumeable))) then
        return {
            n = G.UIT.ROOT,
                config = { padding = -0.1, colour = G.C.CLEAR },
                nodes = {
                    {
                    n = G.UIT.R,
                    config = {
                        ref_table = card,
                        r = 0.08,
                        padding = 0.1,
                        align = "bm",
                        minw = 0.5 * card.T.w - 0.15,
                        minh = 0.7 * card.T.h,
                        maxw = 0.7 * card.T.w - 0.15,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = true,
                        button = "Do you know that this parameter does nothing?",
                        func = card:is_playing_card() and "can_reserve_card_to_deck" or "can_reserve_card",
                        handy_insta_action = 'use'
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = Spectrallib.needs_pull_button(card),
                                colour = G.C.UI.TEXT_LIGHT,
                                scale = 0.55,
                                shadow = true,
                            },
                        },
                    },
                },
                -- Betmma can't explain it, neither can I
            },
        }
    end
    return abc
end

G.FUNCS.can_reserve_joker = function(e)
    local c1 = e.config.ref_table
    if
        #G.jokers.cards
        < G.jokers.config.card_limit + (Spectrallib.safe_get(c1, "edition", "negative") and 1 or 0)
    then
        e.config.colour = G.C.GREEN
        e.config.button = "reserve_joker"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.reserve_joker = function(e)
    local c1 = e.config.ref_table
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()
            local c2 = copy_card(c1, nil, nil, true, false)
            c1:remove()
            c2:add_to_deck()
            G.jokers:emplace(c2)
            SMODS.calculate_context({ pull_card = true, card = c1 })
            return true
        end,
    }))
end

G.FUNCS.can_open_booster = function(e)
    if
        G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.SHOP
    then
        e.config.colour = G.C.GREEN
        e.config.button = "open_booster"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.open_booster = function(e)
    local c1 = e.config.ref_table
    G.GAME.slib_booster_state = G.STATE
    delay(0.1)
    local area = c1.area
    if area == G.shop_vouchers then
        G.GAME.current_round.voucher.spawn[c1.config.center_key] = nil
    end
    if c1.ability.booster_pos then G.GAME.current_round.used_packs[c1.ability.booster_pos] = 'USED' end
    --draw_card(G.hand, G.play, 1, 'up', true, card, nil, true)
    if not c1.from_tag then
      G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
    end
    if c1.RPerkeoPack then
        G.RPerkeoPack = true
    end
    if G.blind_select then
        G.blind_select:remove()
        G.blind_prompt_box:remove()
    end
    e.config.ref_table.cost = 0
    e.config.ref_table:open()
    if c1.ability.cry_multiuse and to_big(c1.ability.cry_multiuse) > to_big(1) then
        local card = c1
        card.ability.cry_multiuse = card.ability.cry_multiuse - 1
        card.ability.extra_value = -1 * math.max(1, math.floor(card.cost/2))
        card:set_cost()
        delay(0.4)

        -- i make my own card eval status text :D

        card:juice_up()
        play_sound('generic1')
        attention_text({
            text = format_ui_value(card.ability.cry_multiuse),
            scale = 1.1,
            hold = 0.6,
            major = card,
            backdrop_colour = G.C.SET[card.config.center.set],
            align = 'bm',
            offset = {x = 0, y = 0.2}
        })
        local c2 = copy_card(c1)
        c2:add_to_deck()
        area:emplace(c2)

    end
    --c1:remove()
end

G.FUNCS.can_open_voucher = function(e)
    local c1 = e.config.ref_table
    e.config.colour = G.C.GREEN
    e.config.button = "open_voucher"
end
G.FUNCS.open_voucher = function(e)
    local state = G.STATE
    local c1 = e.config.ref_table
    c1.cost = 0
    local area = c1.area
    c1:redeem()
    c1:start_dissolve()
    c1:remove()
    if c1.ability.cry_multiuse and to_big(c1.ability.cry_multiuse) > to_big(1) then
        local card = c1
        card.ability.cry_multiuse = card.ability.cry_multiuse - 1
        card.ability.extra_value = -1 * math.max(1, math.floor(card.cost/2))
        card:set_cost()
        delay(0.4)

        -- i make my own card eval status text :D

        card:juice_up()
        play_sound('generic1')
        attention_text({
            text = format_ui_value(card.ability.cry_multiuse),
            scale = 1.1,
            hold = 0.6,
            major = card,
            backdrop_colour = G.C.SET[card.config.center.set],
            align = 'bm',
            offset = {x = 0, y = 0.2}
        })
        local c2 = copy_card(c1)
        c2:add_to_deck()
        area:emplace(c2)

    end
    G.STATE = state
end

G.FUNCS.can_reserve_booster = function(e)
    local c1 = e.config.ref_table
    if
        G.consumeables.config.card_count
        < G.consumeables.config.card_limit + (Cryptid.safe_get(c1, "edition", "negative") and 1 or 0)
    then
        e.config.colour = G.C.GREEN
        e.config.button = "reserve_booster"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.reserve_booster = function(e)
    local c1 = e.config.ref_table
    --G.GAME.slib_booster_state = G.STATE
    --c1:open()
    G.pack_cards:remove_card(c1)
    G.consumeables.cards[#G.consumeables.cards + 1] = c1
    c1.area = G.consumeables
    c1.parent = G.consumeables
    c1.layered_parallax = G.consumeables.layered_parallax
    G.consumeables:set_ranks()
    G.consumeables:align_cards()

    SMODS.calculate_context({ pull_card = true, card = c1 })
    G.GAME.pack_choices = G.GAME.pack_choices - 1
    if G.GAME.pack_choices <= 0 then
        G.FUNCS.end_consumeable(nil, delay_fac)
    end
    if c1.ability.glitched_crown then
        local center = G.P_CENTERS[c1.ability.glitched_crown[c1.glitched_index]]
        c1:set_ability(center)
        c1.ability.glitched_crown = nil
    end
    --c1:remove()
end

G.FUNCS.can_buy_deckorsleeve = function(e)
    local c1 = e.config.ref_table
    e.config.colour = G.C.GREEN
    e.config.button = "buy_deckorsleeve_2"
end
G.FUNCS.can_buy_deckorsleeve_from_shop = function(e)
    local c1 = e.config.ref_table
    if to_big(G.GAME.dollars+G.GAME.bankrupt_at) >= to_big(c1.cost) or Entropy.has_rune and Entropy.has_rune("rune_entr_naudiz") then --should probably have a hookable function similar to SMODS.showman instead of a hardcoded rune check
        e.config.colour = G.C.GREEN
        e.config.button = "buy_deckorsleeve_from_shop"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.buy_deckorsleeve_from_shop = function(e)
    local c1 = e.config.ref_table
    --G.GAME.slib_booster_state = G.STATE
    --c1:open()
    ease_dollars(-c1.cost)
    G.FUNCS.redeem_deckorsleeve(e)
end

G.FUNCS.buy_deckorsleeve_2 = function(e)
    local c1 = e.config.ref_table
    --G.GAME.slib_booster_state = G.STATE
    --c1:open()
    G.FUNCS.redeem_deckorsleeve(e)
end

G.FUNCS.redeem_deckorsleeve = function(e)
    G.E_MANAGER:add_event(Event{
        trigger = "after",
        func = function()

            local area
            if G.STATE == G.STATES.HAND_PLAYED then
                if not G.redeemed_vouchers_during_hand then
                    G.redeemed_vouchers_during_hand =
                        CardArea(G.play.T.x, G.play.T.y, G.play.T.w, G.play.T.h, { type = "play", card_limit = 5 })
                end
                area = G.redeemed_vouchers_during_hand
            else
                area = G.play
            end

            local card = e.config.ref_table
            if card.config.center.key == "j_joker" then
                card:set_ability(G.P_CENTERS.b_red)
            end
            card.area:remove_card(card)
            card:add_to_deck()
            area:emplace(card)
            card.cost = 0
            card:redeem_deck()
            return true
        end
    })
end

G.FUNCS.can_reserve_card_to_deck = function(e)
    local c1 = e.config.ref_table
    e.config.colour = G.C.GREEN
    e.config.button = "reserve_card_to_deck"
end
G.FUNCS.reserve_card_to_deck = function(e)
    local c1 = e.config.ref_table
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()
            local c2 = copy_card(c1, nil, nil, true, false)
            c1:remove()
            c2:add_to_deck()
			table.insert(G.playing_cards, c2)
			G.deck:emplace(c2)
			playing_card_joker_effects({ c2 })
            SMODS.calculate_context({ pull_card = true, card = c1 })
            return true
        end,
    }))
end

G.FUNCS.can_use_joker = function(e)
    local center = e.config.ref_table.config.center
    local card = e.config.ref_table
    local config = Spectrallib.gather_button_config(card.config.center, card)
    card._spectrallib_use_key = localize(config.key)
    if
        center.can_use and center:can_use(e.config.ref_table) and not e.config.ref_table.debuff
        and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT
        and not (((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)))
    then
        e.config.colour = config.colour
        e.config.button = "use_joker"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.use_joker = function(e)
    local int = G.TAROT_INTERRUPT
    G.TAROT_INTERRUPT = true
    local center = e.config.ref_table.config.center
    local card = e.config.ref_table
    local config = Spectrallib.gather_button_config(center, card)
    if center.use then
        center:use(e.config.ref_table)
    end
    e.config.ref_table:juice_up()
    G.TAROT_INTERRUPT = int
    if config.unhighlight then
        card.area:remove_from_highlighted(card)
        card:highlight()
    end
end


function Spectrallib.gather_button_config(center, card)
    local config = center.use_button_config and copy_table(center.use_button_config) or {
        key = center.use_key
    }
    for i, v in pairs(config) do
        if type(v) == "function" then config[i] = v(center, card, config) end
    end
    config.key = config.key or "b_use"
    config.colour = config.colour or G.C.RED
    config.h = config.h or 0.6
    config.func = config.func or "can_use_joker"
    return config
end

local gfcfbs = G.FUNCS.check_for_buy_space
G.FUNCS.check_for_buy_space = function(card)
	if
		not card or card.ability.infinitesimal or card.ability.set == "Back" or card.ability.set == "Sleeve"
	then
		return true
	end
	return gfcfbs(card)
end

local ref = create_shop_card_ui
function create_shop_card_ui(card, type, area)
    if card.config.center.set == "Back" or card.config.center.set == "Sleeve" then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.43,
            blocking = false,
            blockable = false,
            func = (function()
              if card.opening then return true end
              local t1 = {
                  n=G.UIT.ROOT, config = {minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1}, nodes={
                      {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03}, nodes={
                        {n=G.UIT.O, config={object = DynaText({string = {{prefix = localize('$'), ref_table = card, ref_value = 'cost'}}, colours = {G.C.MONEY},shadow = true, silent = true, bump = true, pop_in = 0, scale = 0.5})}},
                      }}
                  }}
              local t2 = {
                n=G.UIT.ROOT, config = {ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GOLD, shadow = true, r = 0.08, minh = 0.94, func = 'can_buy_deckorsleeve_from_shop', one_press = true, button = 'buy_deckorsleeve', hover = true}, nodes={
                    {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.WHITE, scale = 0.5}}
                }}

              card.children.price = UIBox{
                definition = t1,
                config = {
                  align="tm",
                  offset = {x=0,y=1.5},
                  major = card,
                  bond = 'Weak',
                  parent = card
                }
              }

              card.children.buy_button = UIBox{
                definition = t2,
                config = {
                  align="bm",
                  offset = {x=0,y=-0.3},
                  major = card,
                  bond = 'Weak',
                  parent = card
                }
              }
              card.children.price.alignment.offset.y = card.ability.set == 'Booster' and 0.5 or 0.38

                return true
            end)
          }))
    else
        ref(card, type, area)
    end
end

local generate_uiref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if card_type == "Back" then
        if card.config and card.config.center and card.config.center.collection_loc_vars then
            specific_vars = (card.config.center:collection_loc_vars({}, card) or {}).vars
        elseif card.config and card.config.center and card.config.center.loc_vars then
            specific_vars = (card.config.center:loc_vars({}, card) or {}).vars
        elseif card.config and card.config.center then
            local loc_args = {}
            local effect_config = card.config.center.config
            local name_to_check = card.config.center.name
            if name_to_check == 'Blue Deck' then loc_args = {effect_config.hands}
            elseif name_to_check == 'Red Deck' then loc_args = {effect_config.discards}
            elseif name_to_check == 'Yellow Deck' then loc_args = {effect_config.dollars}
            elseif name_to_check == 'Green Deck' then loc_args = {effect_config.extra_hand_bonus, effect_config.extra_discard_bonus}
            elseif name_to_check == 'Black Deck' then loc_args = {effect_config.joker_slot, -effect_config.hands}
            elseif name_to_check == 'Magic Deck' then loc_args = {localize{type = 'name_text', key = 'v_crystal_ball', set = 'Voucher'}, localize{type = 'name_text', key = 'c_fool', set = 'Tarot'}}
            elseif name_to_check == 'Nebula Deck' then loc_args = {localize{type = 'name_text', key = 'v_telescope', set = 'Voucher'}, -1}
            elseif name_to_check == 'Ghost Deck' then
            elseif name_to_check == 'Abandoned Deck' then
            elseif name_to_check == 'Checkered Deck' then
            elseif name_to_check == 'Zodiac Deck' then loc_args = {localize{type = 'name_text', key = 'v_tarot_merchant', set = 'Voucher'},
                                localize{type = 'name_text', key = 'v_planet_merchant', set = 'Voucher'},
                                localize{type = 'name_text', key = 'v_overstock_norm', set = 'Voucher'}}
            elseif name_to_check == 'Painted Deck' then loc_args = {effect_config.hand_size,effect_config.joker_slot}
            elseif name_to_check == 'Anaglyph Deck' then loc_args = {localize{type = 'name_text', key = 'tag_double', set = 'Tag'}}
            elseif name_to_check == 'Plasma Deck' then loc_args = {effect_config.ante_scaling}
            elseif name_to_check == 'Erratic Deck' then
            end
            specific_vars = loc_args
        end
    end
    return generate_uiref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
end
local set_cost_ref = Card.set_cost
function Card:set_cost()
	if self.config.center.set == "Back" or self.config.center.set == "Sleeve" then
		self.config.center.cost = 15
		self.base_cost = 15
	end
	set_cost_ref(self)
end

local update_ref = Game.update
function Game:update(dt)
    update_ref(self, dt)
    if G.STATE == nil and (G.pack_cards == nil or #G.pack_cards == 0) and G.GAME.slib_booster_state then
        G.STATE = G.GAME.slib_booster_state
        G.STATE_COMPLETE = false
        G.GAME.slib_booster_state = nil
    end
    if self.STATE == nil and not G.GAME.slib_booster_state then
        G.STATE = 1
        G.STATE_COMPLETE = false
    end
end

