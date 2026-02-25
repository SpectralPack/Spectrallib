function Spectrallib.l_chipsmult(hand, card, l_chips, l_mult, instant)
	if not instant then
		update_hand_text({delay = 0}, {handname = localize(hand, "poker_hands"), level = G.GAME.hands[hand].level, mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand), chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)})
		delay(1)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		update_hand_text({delay = 0}, {handname = localize("k_level_chips"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		delay(2)
	end
	G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips + l_chips
	if not instant then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {chips = G.GAME.hands[hand].l_chips, StatusText = true})
		delay(0.7)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		update_hand_text({delay = 0}, {handname = localize("k_level_mult"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		delay(2)
		G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult + l_mult
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {mult = G.GAME.hands[hand].l_mult, StatusText = true})
		delay(0.7)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		delay(1.3)
	end
	Cryptid.reset_to_none()
end

function Spectrallib.xl_chips(hand, card, l_chips, instant)
	if not instant then
		update_hand_text({delay = 0}, {handname = localize(hand, "poker_hands"), level = G.GAME.hands[hand].level, mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand), chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)})
		delay(1)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		update_hand_text({delay = 0}, {handname = localize("k_level_chips"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		delay(2)
	end
	G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * l_chips
	if not instant then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {chips = "X"..number_format(l_chips), StatusText = true})
		delay(0.7)
		update_hand_text({delay = 0}, {handname = localize("k_level_mult"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		delay(1.3)
	end
	Cryptid.reset_to_none()
end

function Spectrallib.xl_mult(hand, card, l_mult, instant)
	if not instant then
		update_hand_text({delay = 0}, {handname = localize(hand, "poker_hands"), level = G.GAME.hands[hand].level, mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand), chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)})
		delay(1)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		update_hand_text({delay = 0}, {handname = localize("k_level_mult"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		delay(2)
	end
	G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * l_mult
	if not intant then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {mult = "X"..number_format(l_mult), StatusText = true})
		delay(0.7)
		update_hand_text({delay = 0}, {handname = localize("k_level_mult"), chips = G.GAME.hands[hand].l_chips, mult = G.GAME.hands[hand].l_mult})
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			if card and card.juice_up then card:juice_up(0.8, 0.5) end
			G.TAROT_INTERRUPT_PULSE = true
			return true end
		}))
		delay(1.3)
	end
	Cryptid.reset_to_none()
end

local upgrade_hands_ref = SMODS.upgrade_poker_hands
function SMODS.upgrade_poker_hands(args)
    if type(args.hands) == "string" then args.hands = {args.hands} end
    if not args.hands then args.hands = {} end
    if next(SMODS.find_card("j_entr_strawberry_pie")) then
        for i, v in pairs(SMODS.find_card("j_entr_strawberry_pie")) do
            for index, hand in pairs(args.hands) do
                if args.hands[index] == "Full House" or args.hands[index] == "Straight" or args.hands[index] == "Flush" then
                    args.hands[index] = "High Card"
                end
            end
        end 
    end
    if args.ascension_power then
        local card = args.from
        for i, v in pairs(args.hands) do
            local amt = args.ascension_power
            local handname = v
            local used_consumable = card
            local c
            local m
            local chips = Spectrallib.ascend_hand(G.GAME.hands[handname].chips, handname)
            local mult = Spectrallib.ascend_hand(G.GAME.hands[handname].mult, handname)
            if not args.instant then
                c = copy_table(G.C.UI_CHIPS)
                m = copy_table(G.C.UI_MULT)
                delay(0.4)
                update_hand_text(
                    { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
                    { handname = localize(handname,'poker_hands'), chips = "...", mult = "...", level = "..." }
                )
            end
            G.GAME.hands[handname].AscensionPower = to_big((G.GAME.hands[handname].AscensionPower or 0)) + to_big(amt) 
            chips = Spectrallib.ascend_hand(G.GAME.hands[handname].chips, handname) - chips
            mult = Spectrallib.ascend_hand(G.GAME.hands[handname].mult, handname) - mult
            if G.entr_add_to_stats then
                SMODS.Scoring_Parameters.chips.current = SMODS.Scoring_Parameters.chips.current + chips
                SMODS.Scoring_Parameters.mult.current = SMODS.Scoring_Parameters.mult.current + mult
            end
            if not args.instant then
                delay(1.0)
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.2,
                    func = function()
                    play_sound("tarot1")
                    ease_colour(G.C.UI_CHIPS, HEX("ffb400"), 0.1)
                    ease_colour(G.C.UI_MULT, HEX("ffb400"), 0.1)
                    Cryptid.pulse_flame(0.01, sunlevel)
                    if used_consumable and used_consumable.juice_up then used_consumable:juice_up(0.8, 0.5) end
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        blockable = false,
                        blocking = false,
                        delay = 1.2,
                        func = function()
                        ease_colour(G.C.UI_CHIPS, c, 1)
                        ease_colour(G.C.UI_MULT, m, 1)
                        return true
                        end,
                    }))
                    return true
                    end,
                }))
            end
            if not args.instant then
                update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = (to_big(amt) > to_big(0) and "+" or "")..number_format(to_big(amt) ) })
                delay(1.6)
            end
            if card and card.edition and to_big(amt or 1) > to_big(0) and not noengulf and Engulf then
                if Engulf.SpecialFuncs[card.config.center.key] then 
                else Engulf.EditionHand(card, handname, card.edition, amt, instant) end 
            end
            if not args.instant then
                delay(1.6)
                update_hand_text(
                    { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
                    { mult = 0, chips = 0, handname = "", level = "" }
                )
                delay(1)
            end
            G.hand:parse_highlighted()
            G.GAME.current_round.current_hand.cry_asc_num = 0
            G.GAME.current_round.current_hand.cry_asc_num_text = ""
        end
        return
    end
    if args.per_level then
        local mult = args.per_level.mult
        local chips = args.per_level.chips
        if mult or chips then
            for i, v in pairs(args.hands) do
                Spectrallib.l_chipsmult(v, args.from, chips, mult, args.instant)
            end
        end
        return
    end
    if args.x_per_level then
        local mult = args.x_per_level.mult
        local chips = args.x_per_level.chips
        if mult then
            for i, v in pairs(args.hands) do
                Spectrallib.xl_mult(v, args.from, mult, args.instant)
            end
        end
        if chips then
            for i, v in pairs(args.hands) do
                Spectrallib.xl_chips(v, args.from, chips, args.instant)
            end
        end
        return
    end
    return upgrade_hands_ref(args)
end

local hand_row_ref = create_UIBox_current_hand_row
function create_UIBox_current_hand_row(handname, simple)
    G.GAME.badarg = G.GAME.badarg or {}
    if G.GAME.hands[handname].operator then
      return (G.GAME.hands[handname].visible) and
      (not simple and
        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05, hover = true, force_focus = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}}, nodes={
          {n=G.UIT.C, config={align = "cl", padding = 0, minw = 5}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[to_number(math.min(7, G.GAME.hands[handname].level))], minw = 1.5, outline = 0.8, outline_colour = G.C.WHITE}, nodes={
              {n=G.UIT.T, config={text = localize('k_level_prefix')..number_format(G.GAME.hands[handname].level), scale = 0.5, colour = G.C.UI.TEXT_DARK}}
            }},
            {n=G.UIT.C, config={align = "cm", minw = 4.5, maxw = 4.5}, nodes={
              {n=G.UIT.T, config={text = ' '..localize(handname,'poker_hands'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }}
          }},
          {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = G.GAME.badarg[handname] and HEX("FF0000") or G.C.CHIPS, minw = 1.1}, nodes={
              {n=G.UIT.T, config={text = G.GAME.badarg[handname] and "BAD" or number_format(G.GAME.hands[handname].chips, 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
              {n=G.UIT.B, config={w = 0.08, h = 0.01}}
            }},
            {n=G.UIT.T, config={text = G.GAME.hands[handname].operator and Spectrallib.format_arrow_mulkt(G.GAME.hands[handname].operator, "") or "X", scale = 0.45, colour = Spectrallib.get_arrow_color(G.GAME.hands[handname].operator or 0)}},
            {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = G.GAME.badarg[handname] and HEX("FF0000") or G.C.MULT, minw = 1.1}, nodes={
              {n=G.UIT.B, config={w = 0.08,h = 0.01}},
              {n=G.UIT.T, config={text = G.GAME.badarg[handname] and "ARG" or number_format(G.GAME.hands[handname].mult, 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
            }}
          }},
          {n=G.UIT.C, config={align = "cm"}, nodes={
              {n=G.UIT.T, config={text = '  #', scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }},
          {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.L_BLACK,r = 0.1, minw = 0.9}, nodes={
            {n=G.UIT.T, config={text = G.GAME.hands[handname].played, scale = 0.45, colour = G.C.FILTER, shadow = true}},
          }}
        }}
      or {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), force_focus = true, emboss = 0.05, hover = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}, focus_args = {snap_to = (simple and handname == 'Straight Flush')}}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0, minw = 5}, nodes={
            {n=G.UIT.T, config={text = localize(handname,'poker_hands'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
        }}
      }})
      or nil
    elseif G.GAME.hands[handname] and not G.GAME.hands[handname].AscensionPower then
        return hand_row_ref(handname, simple)
    else
        if not (G.GAME.hands[handname]) then return {} end
        if not G.GAME.badarg then G.GAME.badarg = {} end
        local color = (G.GAME.badarg and G.GAME.badarg[handname] and HEX("FF0000")) or Spectrallib.get_asc_colour(G.GAME.hands[handname].AscensionPower)
        return (G.GAME.hands[handname].visible) and
        (not simple and
          {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05, hover = true, force_focus = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}}, nodes={
            {n=G.UIT.C, config={align = "cl", padding = 0, minw = 5}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
                    {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = to_big(G.GAME.hands[handname].level) < to_big(2) and G.C.UI.TEXT_LIGHT or G.C.HAND_LEVELS[to_number(math.min(7, G.GAME.hands[handname].level))], minw = 1.1}, nodes={
                      {n=G.UIT.T, config={text = localize('k_level_prefix')..number_format(G.GAME.hands[handname].level, 1000000), scale = 0.45, colour = G.C.UI.TEXT_DARK}},
                    }},
                    {n=G.UIT.T, config={text = to_big(G.GAME.hands[handname].AscensionPower) >= to_big(0) and "+" or "-", scale = 0.45, colour = color}},
                    {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = color, minw = 0.7}, nodes={
                      {n=G.UIT.T, config={text = ""..number_format(math.abs(to_big(G.GAME.hands[handname].AscensionPower) ^ to_big(G.GAME.hands[handname].TranscensionPower or 1)), 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                  }},
              {n=G.UIT.C, config={align = "cm", minw = 3.8, maxw = 3.8}, nodes={
                {n=G.UIT.T, config={text = ' '..localize(handname,'poker_hands'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
              }}
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
              {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = color, minw = 1.1}, nodes={
                {n=G.UIT.T, config={text = G.GAME.badarg[handname] and "BAD" or number_format(Spectrallib.ascend_hand(G.GAME.hands[handname].chips,handname), 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
                {n=G.UIT.B, config={w = 0.08, h = 0.01}}
              }},
              {n=G.UIT.T, config={text = G.GAME.hands[handname].operator and Spectrallib.format_arrow_mulkt(G.GAME.hands[handname].operator, "") or "X", scale = 0.45, colour = color}},
              {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = color, minw = 1.1}, nodes={
                {n=G.UIT.B, config={w = 0.08,h = 0.01}},
                {n=G.UIT.T, config={text = G.GAME.badarg[handname] and "ARG" or number_format(Spectrallib.ascend_hand(G.GAME.hands[handname].mult,handname), 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
              }}
            }},
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.T, config={text = '  #', scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
              }},
            {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.L_BLACK,r = 0.1, minw = 0.9}, nodes={
              {n=G.UIT.T, config={text = G.GAME.hands[handname].played, scale = 0.45, colour = G.C.FILTER, shadow = true}},
            }}
          }}
        or {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), force_focus = true, emboss = 0.05, hover = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}, focus_args = {snap_to = (simple and handname == 'Straight Flush')}}, nodes={
          {n=G.UIT.C, config={align = "cm", padding = 0, minw = 5}, nodes={
              {n=G.UIT.T, config={text = localize(handname,'poker_hands'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
          }}
        }})
        or nil
    end
end


function Spectrallib.ascend_hand(num, hand) -- edit this function at your leisure
    local ret = Cryptid.ascend(num, (G.GAME.hands[hand].AscensionPower or 0))
    return ret
end

--TODO: clean up later to merge with cryptid stuff
local pokerhandinforef = G.FUNCS.get_poker_hand_info
function G.FUNCS.get_poker_hand_info(_cards)
	local text, loc_disp_text, poker_hands, scoring_hand, disp_text = pokerhandinforef(_cards)
	-- Display text if played hand contains a Cluster and a Bulwark
	-- Not Ascended hand related but this hooks in the same spot so i'm lumping it here anyways muahahahahahaha
    local cards = {}
    for _, card in pairs(_cards) do
        cards[#cards+1] = card
    end
    for _, card in pairs(G.I.CARD) do
        if card.ability and card.ability.entr_marked then
            if not card.highlighted and not Spectrallib.in_table(_cards, card) then
                cards[#cards+1] = card
            end
        end
    end
    _cards = cards
    local hidden = false
    for i, v in pairs(scoring_hand) do
        if type(v) == "table" and v.facing == "back" then
            hidden = true
            break
        end
    end
    -- Ascension power
    local a_power = Cryptid.calculate_ascension_power(
        text,
        _cards,
        scoring_hand,
        G.GAME.used_vouchers.v_cry_hyperspacetether,
        G.GAME.bonus_asc_power
    )
    if a_power ~= 0 then
        G.GAME.current_round.current_hand.cry_asc_num = a_power
        -- Change mult and chips colors if hand is ascended
        if not hidden then
            ease_colour(G.C.GOLD, copy_table(HEX("EABA44")), 0.3)
            ease_colour(G.C.UI_CHIPS, copy_table(Spectrallib.get_asc_colour(G.GAME.current_round.current_hand.cry_asc_num, text)), 0.3)
            ease_colour(G.C.UI_MULT, copy_table(Spectrallib.get_asc_colour(G.GAME.current_round.current_hand.cry_asc_num, text)), 0.3)

            G.GAME.current_round.current_hand.cry_asc_num_text = (
                a_power
            )
                    and " (".. (to_big(a_power) >= to_big(0) and "+" or "") .. number_format(a_power) .. ")"
                or ""
        else
            ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
            ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
            G.GAME.current_round.current_hand.cry_asc_num_text = ""
        end
    else
        G.GAME.current_round.current_hand.cry_asc_num = 0
		if G.GAME.badarg and G.GAME.badarg[text] then
            ease_colour(G.C.UI_CHIPS, copy_table(HEX("FF0000")), 0.3)
            ease_colour(G.C.UI_MULT, copy_table(HEX("FF0000")), 0.3)
		else 
			ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
			ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
		end
        G.GAME.current_round.current_hand.cry_asc_num_text = ""
    end
    if to_big(G.GAME.current_round.current_hand.cry_asc_num) == to_big(0) then
        ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
        ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
    end
	return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end
