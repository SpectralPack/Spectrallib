-----------------------------
-- SUPPLEMENTARY FUNCTIONS --
-----------------------------

local function uht_snd(volume, pitch, delay)
    return {
        sound = "button", volume = volume,
        pitch = pitch, delay = delay
    }
end

local function JUICE_CARD_EVENT(card, delay)
    Spectrallib.event{
        function ()
            if card and card.juice_up then
                card:juice_up(0.8, 0.5)
            end
            G.TAROT_INTERRUPT_PULSE = nil
            return true
        end,
        trigger = 'after',
        delay = delay or 0.9
    }
end

---------------
-- FUNCTIONS --
---------------

-- Apply the ascension formula to a given value, with the ascension power being that of a poker hand.
---@param num number
---@param hand string Key of the poker hand.
---@return number
function Spectrallib.ascend_hand(num, hand) -- edit this function at your leisure
    local ret = Spectrallib.ascend(num, (G.GAME.hands[hand].AscensionPower or 0))
    return ret
end

-- Additively increase the chips and mult level-up amounts.
---@param hand string Poker hand key.
---@param card? Card The card responsible for the levelling.
---@param l_chips number
---@param l_mult number
---@param instant? boolean If true, skips animations.
---@return nil
function Spectrallib.l_chipsmult(hand, card, l_chips, l_mult, instant)
    if instant then
        G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips + l_chips
        G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult + l_mult
        return
    end

    update_hand_text({delay = 0}, {
        handname = localize(hand, "poker_hands"),
        level = G.GAME.hands[hand].level,
        mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand),
        chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)
    })
    delay(2)
    Spectrallib.event(function ()
        play_sound('tarot1')
        return true
    end)
    update_hand_text({delay = 0}, {
        handname = localize("k_level_chips"),
        chips = G.GAME.hands[hand].l_chips,
        mult = G.GAME.hands[hand].l_mult
    })
    delay(1)
    JUICE_CARD_EVENT(card, 0.2)
	G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips + l_chips
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        chips = G.GAME.hands[hand].l_chips,
        StatusText = true
    })
    delay(2)
    Spectrallib.event(function ()
        play_sound('tarot1')
        return true
    end)
    update_hand_text({delay = 0}, {
        handname = localize("k_level_mult"),
        chips = G.GAME.hands[hand].l_chips,
        mult = G.GAME.hands[hand].l_mult
    })
    delay(1)
    JUICE_CARD_EVENT(card, 0.2)
    G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult + l_mult
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        mult = G.GAME.hands[hand].l_mult,
        StatusText = true
    })
    delay(2)
	Spectrallib.reset_to_none()
end

-- Multiplicatively increase the chips level-up amount.
---@param hand string Poker hand key.
---@param card? Card The card responsible for the levelling.
---@param l_chips number
---@param instant? boolean If true, skips animations.
---@return nil
function Spectrallib.xl_chips(hand, card, l_chips, instant)
    if instant then
        G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * l_chips
        return
    end

    update_hand_text({delay = 0}, {
        handname = localize(hand, "poker_hands"),
        level = G.GAME.hands[hand].level,
        mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand),
        chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)
    })
    delay(2)
    Spectrallib.event(function ()
        play_sound('tarot1')
        return true
    end)
    update_hand_text({delay = 0}, {
        handname = localize("k_level_chips"),
        chips = G.GAME.hands[hand].l_chips,
        mult = G.GAME.hands[hand].l_mult
    })
    delay(1)
    JUICE_CARD_EVENT(card, 0.2)
	G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * l_chips
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        chips = "X"..number_format(l_chips),
        StatusText = true
    })
    update_hand_text({delay = 0, volume = 0}, {
        chips = G.GAME.hands[hand].l_chips
    })
    delay(2)
	Spectrallib.reset_to_none()
end

-- Multiplicatively increase the mult level-up amount.
---@param hand string Poker hand key.
---@param card? Card The card responsible for the levelling.
---@param l_mult number
---@param instant? boolean If true, skips animations.
---@return nil
function Spectrallib.xl_mult(hand, card, l_mult, instant)
    if instant then
        G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * l_mult
        return
    end

    update_hand_text({delay = 0}, {
        handname = localize(hand, "poker_hands"),
        level = G.GAME.hands[hand].level,
        mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand),
        chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)
    })
    delay(2)
    Spectrallib.event(function ()
        play_sound('tarot1')
        return true
    end)
    update_hand_text({delay = 0}, {
        handname = localize("k_level_mult"),
        chips = G.GAME.hands[hand].l_chips,
        mult = G.GAME.hands[hand].l_mult
    })
    delay(1)
    JUICE_CARD_EVENT(card, 0.2)
	G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * l_mult
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        mult = "X"..number_format(l_mult),
        StatusText = true
    })
    update_hand_text({delay = 0, volume = 0}, {
        mult = G.GAME.hands[hand].l_mult
    })
    delay(2)
	Spectrallib.reset_to_none()
end

-- Increase the hand's ascension power.
---@param hand string Poker hand key.
---@param card? Card The card responsible for the levelling.
---@param asc_power number
---@param instant? boolean If true, skips animations.
---@return nil
function Spectrallib.l_asc(hand, card, asc_power, instant)
    if instant then
        local chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)
        local mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand)
        G.GAME.hands[hand].AscensionPower = to_big((G.GAME.hands[hand].AscensionPower or 0)) + asc_power
        chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand) - chips
        mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand) - mult
        if G.entr_add_to_stats then
            SMODS.Scoring_Parameters.chips.current = SMODS.Scoring_Parameters.chips.current + chips
            SMODS.Scoring_Parameters.mult.current = SMODS.Scoring_Parameters.mult.current + mult
        end

        if (
            card and card.edition
            and ((asc_power or 1) > 0)
            and not noengulf and Engulf
        ) then
            if Engulf.SpecialFuncs[card.config.center.key] then 
            else
                Engulf.EditionHand(card, hand, card.edition, asc_power, instant)
            end
        end

        G.hand:parse_highlighted()
        G.GAME.current_round.current_hand.cry_asc_num = 0
        G.GAME.current_round.current_hand.cry_asc_num_text = ""

        return
    end

    local chips_color = copy_table(G.C.UI_CHIPS)
    local mult_color = copy_table(G.C.UI_MULT)
    delay(0.4)
    update_hand_text(uht_snd(0.7, 0.8, 0.3), {
        handname = localize(hand,'poker_hands'),
        chips = "...", mult = "...", level = "..."
    })

    local chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand)
    local mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand)
    G.GAME.hands[hand].AscensionPower = to_big((G.GAME.hands[hand].AscensionPower or 0)) + asc_power
    chips = Spectrallib.ascend_hand(G.GAME.hands[hand].chips, hand) - chips
    mult = Spectrallib.ascend_hand(G.GAME.hands[hand].mult, hand) - mult
    if G.entr_add_to_stats then
        SMODS.Scoring_Parameters.chips.current = SMODS.Scoring_Parameters.chips.current + chips
        SMODS.Scoring_Parameters.mult.current = SMODS.Scoring_Parameters.mult.current + mult
    end

    Spectrallib.event(1.0)
    Spectrallib.event{
        function ()
            play_sound("tarot1")
            ease_colour(G.C.UI_CHIPS, HEX("ffb400"), 0.1)
            ease_colour(G.C.UI_MULT, HEX("ffb400"), 0.1)
            Spectrallib.pulse_flame(0.01, sunlevel) -- todo: figure where sunlevel is form
            if card and card.juice_up then card:juice_up(0.8, 0.5) end
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                blockable = false,
                blocking = false,
                delay = 1.2,
                func = function()
                ease_colour(G.C.UI_CHIPS, chips_color, 1)
                ease_colour(G.C.UI_MULT, mult_color, 1)
                return true
                end,
            }))
            return true
        end,
        trigger = "after",
        delay = 0.2
    }

    update_hand_text(uht_snd(0.7, 0.9, 0), {
        level = (asc_power > 0 and "+" or "")..number_format(asc_power)
    })
    delay(1.6)

    if (
        card and card.edition
        and ((asc_power or 1) > 0)
        and not noengulf and Engulf
    ) then
        if Engulf.SpecialFuncs[card.config.center.key] then 
        else
            Engulf.EditionHand(card, hand, card.edition, asc_power, instant)
        end
    end

    delay(1.6)
    update_hand_text(uht_snd(0.7, 1.1, 0), {
        mult = 0, chips = 0,
        handname = "", level = ""
    })
    delay(1)

    G.hand:parse_highlighted()
    G.GAME.current_round.current_hand.cry_asc_num = 0
    G.GAME.current_round.current_hand.cry_asc_num_text = ""
end

---@param op string|integer Return value is G.C.RED
---| "exponent" # Return value is G.C.FILTER
---| "add"      # Return value is G.C.GREEN
---@return [number, number, number, number]
function Spectrallib.get_arrow_color(op)
    if op == "exponent" then --idk what the actual colours are meant to be
        op = 1
    elseif op == "add" then
        op = -1
    elseif op == "multiply" then
        op = 0
    end
    if op <= -3 then
        return G.C.WHITE
    elseif op == -2 then
        return G.C.BLUE
    elseif op == -1 then
        return G.C.GREEN
    elseif op == 0 then
        return G.C.RED
    elseif op == 1 then
        return G.C.FILTER
    elseif op >= 7 then --brace switch point
        return G.C.DARK_EDITION
    else
        return G.C.PURPLE
    end
end

-----------
-- HOOKS --
-----------

-- Hook to incorporate previous functions
local upgrade_hands_ref = SMODS.upgrade_poker_hands
function SMODS.upgrade_poker_hands(args)
    args.hands = args.hands or G.handlist
    if type(args.hands) == "string" then args.hands = {args.hands} end

    if args.ascension_power then
        local card = args.from
        for _, hand in pairs(args.hands) do
            Spectrallib.l_asc(hand, args.from, args.ascension_power, args.instant)
        end
        return
    end

    if args.per_level then
        local mult = args.per_level.mult
        local chips = args.per_level.chips
        if mult or chips then
            for _, hand in pairs(args.hands) do
                Spectrallib.l_chipsmult(hand, args.from, chips, mult, args.instant)
            end
        end
        return
    end

    if args.x_per_level then
        local mult = args.x_per_level.mult
        local chips = args.x_per_level.chips
        if mult then
            for _, hand in pairs(args.hands) do
                Spectrallib.xl_mult(hand, args.from, mult, args.instant)
            end
        end
        if chips then
            for _, hand in pairs(args.hands) do
                Spectrallib.xl_chips(hand, args.from, chips, args.instant)
            end
        end
        return
    end

    return upgrade_hands_ref(args)
end

-- Add ascension power info to hands
local hand_row_ref = create_UIBox_current_hand_row
function create_UIBox_current_hand_row(handname, simple, in_collection)
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
            {n=G.UIT.T, config={text = G.GAME.hands[handname].operator and Spectrallib.format_arrow_mult(G.GAME.hands[handname].operator, "") or "X", scale = 0.45, colour = Spectrallib.get_arrow_color(G.GAME.hands[handname].operator or 0)}},
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
        return hand_row_ref(handname, simple, in_collection)
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
                      {n=G.UIT.T, config={text = ""..number_format(math.abs(to_big(G.GAME.hands[handname].AscensionPower)), 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
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
              {n=G.UIT.T, config={text = G.GAME.hands[handname].operator and Spectrallib.format_arrow_mult(G.GAME.hands[handname].operator, "") or "X", scale = 0.45, colour = color}},
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

--TODO: clean up later to merge with cryptid stuff
--todo: figure this out
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
