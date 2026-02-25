local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	local abc = G_UIDEF_use_and_sell_buttons_ref(card)
	-- Allow code cards to be reserved
    if (card.area == G.consumeables or card.area == G.jokers) and (card.config.center.set == "Voucher" or card.ability.set == "Voucher") then
        sell = {n=G.UIT.C, config={align = "cr"}, nodes={
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
        use = 
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
            sell = {n=G.UIT.C, config={align = "cr"}, nodes={
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
            use = 
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
        sell = {n=G.UIT.C, config={align = "cr"}, nodes={
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
        use = 
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
    if (card.area == G.pack_cards and G.pack_cards) and card.config.center.set == "Booster" and not Entropy.ConsumablePackBlacklist[SMODS.OPENED_BOOSTER.config.center.key] then
        return  {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'reserve_booster', func = 'can_reserve_booster', handy_insta_action = 'buy_or_sell'}, nodes={
                {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
              }},
          }}
    end
    if (card.area == G.jokers and G.jokers and card.config.center.use) and not card.debuff and card.config.center.set == "Joker" then
        sell = {n=G.UIT.C, config={align = "cr"}, nodes={
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
        transition = {n=G.UIT.C, config={align = "cr"}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "cm",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'use_joker', func = 'can_use_joker', handy_insta_action = 'use'}, nodes={
              {n=G.UIT.B, config = {w=0.1,h=0.3}},
              {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                  {n=G.UIT.T, config={text = localize(card.config.center.use_key or "b_use"),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                }},
              }}
            }},
        }}
        return {
            n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
              {n=G.UIT.C, config={padding = 0, align = 'cl'}, nodes={
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  sell
                }},
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                  transition
                }},
            }},
        }}
    end
    if Entropy.needs_use_button(card) and card.area == G.pack_cards and G.pack_cards and (Entropy.needs_pull_button(card) or (not SMODS.OPENED_BOOSTER or not SMODS.OPENED_BOOSTER.draw_hand and card.children.front and (card.ability.consumeable))) then
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
                                text = Entropy.needs_pull_button(card),
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
    elseif card.area == G.pack_cards and G.pack_cards and (Entropy.needs_pull_button(card) or (not SMODS.OPENED_BOOSTER or not SMODS.OPENED_BOOSTER.draw_hand and card.children.front and (card.ability.consumeable))) then
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
                                text = Entropy.needs_pull_button(card),
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