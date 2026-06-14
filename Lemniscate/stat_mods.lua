--- Multiplies hands by `mod`
--- @param mod number
--- @param instant boolean? If true, triggers immediately instead of as an event.
--- @param silent boolean? If true, does not play a sound effect.
--- @return nil
function Spectrallib.x_hands_played(mod, instant, silent)
    local _mod = function(modd)
        modd = modd or 1
        local hand_UI = G.HUD:get_UIE_by_ID('hand_UI_count')
        local col = modd < 1 and G.C.RED or G.C.GREEN

        G.GAME.current_round.hands_left = G.GAME.current_round.hands_left * modd
        hand_UI.config.object:update()
        G.HUD:recalculate()

        -- text
        attention_text {
            text = "X"..modd,
            scale = 0.8,
            hold = 0.7,
            cover = hand_UI.parent,
            cover_colour = col,
            align = 'cm',
        }

        if not silent then play_sound("xchips") end
    end

    Spectrallib.event{
        function()
            _mod(mod)
            return true
        end,
        instant = instant
    }
end

--- Multiplies hands by `mod`
--- @param mod number
--- @param instant boolean? If true, triggers immediately instead of as an event.
--- @param silent boolean? If true, does not play a sound effect.
--- @return nil
function Spectrallib.x_discards(mod, instant, silent)
    local _mod = function(modd)
        modd = modd or 1
        local discard_UI = G.HUD:get_UIE_by_ID('discard_UI_count')
        local col = modd < 1 and G.C.RED or G.C.GREEN

        G.GAME.current_round.discards_left = G.GAME.current_round.discards_left * modd
        discard_UI.config.object:update()
        G.HUD:recalculate()

        -- text
        attention_text {
            text = "X"..modd,
            scale = 0.8,
            hold = 0.7,
            cover = discard_UI.parent,
            cover_colour = col,
            align = 'cm',
        }

        if not silent then play_sound("xchips") end
    end

    Spectrallib.event{
        function()
            _mod(mod)
            return true
        end,
        instant = instant
    }
end

--- Sets hands equal to `mod`
--- @param mod number
--- @param instant boolean? If true, triggers immediately instead of as an event.
--- @param silent boolean? If true, does not play a sound effect.
--- @return nil
function Spectrallib.eq_hands(mod, instant, silent)
    local _mod = function(modd)
        modd = modd or 0
        local hand_UI = G.HUD:get_UIE_by_ID('hand_UI_count')
        local col = G.C.DARK_EDITION

        G.GAME.current_round.hands_left = modd
        hand_UI.config.object:update()
        G.HUD:recalculate()

        -- text
        attention_text {
            text = "="..modd,
            scale = 0.8,
            hold = 0.7,
            cover = hand_UI.parent,
            cover_colour = col,
            align = 'cm',
        }

        if not silent then play_sound('chips2') end
    end

    Spectrallib.event{
        function()
            _mod(mod)
            return true
        end,
        instant = instant
    }
end

--- Sets discards equal to `mod`
--- @param mod number
--- @param instant boolean? If true, triggers immediately instead of as an event.
--- @param silent boolean? If true, does not play a sound effect.
--- @return nil
function Spectrallib.eq_discards(mod, instant, silent)
    local _mod = function(modd)
        modd = modd or 0
        local discard_UI = G.HUD:get_UIE_by_ID('discard_UI_count')
        local col = G.C.DARK_EDITION

        G.GAME.current_round.discards_left = modd
        discard_UI.config.object:update()
        G.HUD:recalculate()

        -- text
        attention_text {
            text = "="..modd,
            scale = 0.8,
            hold = 0.7,
            cover = discard_UI.parent,
            cover_colour = col,
            align = 'cm',
        }

        if not silent then play_sound('chips2') end
    end

    Spectrallib.event{
        function()
            _mod(mod)
            return true
        end,
        instant = instant
    }
end

--- @class Spectrallib.x_levels.args
--- @field level_up number
--- @field hands? string|string[] Keys of hands to level up.
--- @field instant? boolean If true, no animation plays when this function is called.
--- @field from? Card|Card[] A card or set of cards causing the level-up.
--- @field bypass_calculate? boolean If true, function will not send out calculation contexts.
--- @field colour? [number, number, number, number] Colour of StatusText.

--- Multiplies hand levels by 2.
--- @param args Spectrallib.x_levels.args
--- @return nil
function Spectrallib.x_levels(args)
    assert(args, "No arguments given to Spectrallib.x_levels")
    assert(args.level_up, "Must provide amount to Spectrallib.x_levels")

    args.hands = args.hands or G.handlist
    if type(args.hands) == 'string' then args.hands = {args.hands --[[@as string]]} end
    if args.from and #args.from < 1 then
        args.from = {args.from}
    end
    local instant = args.instant or Spectrallib.should_skip_animations()

    local vals_after_level = {mult = 0, chips = 0, handname = '', level = ''}
    if SMODS.displaying_scoring then
        vals_after_level = copy_table(G.GAME.current_round.current_hand)
        local text,disp_text,_,_,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
        vals_after_level.handname = disp_text or ''
        vals_after_level.level = (G.GAME.hands[text] or {}).level or ''
        for name, p in pairs(SMODS.Scoring_Parameters) do
            vals_after_level[name] = p.current
        end
    end

    local displayed = false
    local context = {poker_hand_changed = true, card = args.from, slib_x_levels = args.level_up}
    for _, hand in ipairs(args.hands --[[@as string[] ]]) do
        displayed = hand == SMODS.displayed_hand
        local level = G.GAME.hands[hand].level

        context.scoring_name = hand
        if not instant then
            update_hand_text({
                sound = 'button', volume = 0.7,
                pitch = 0.8, delay = 0.3
            }, {
                handname = localize(hand, 'poker_hands'),
                level = G.GAME.hands[hand].level
            })
            for name, sc_param in pairs(SMODS.Scoring_Parameters) do
                sc_param.current = G.GAME.hands[hand][name] or sc_param.default_value
                update_hand_text({nopulse = nil, delay = 0}, {[name] = sc_param.current})
            end
        end

        context.old_parameters = {}
        context.new_parameters = {}

        context.old_level = G.GAME.hands[hand].level
        G.GAME.hands[hand].level = math.max(0, G.GAME.hands[hand].level * 2)
        context.new_level = G.GAME.hands[hand].level

        for _, parameter in ipairs(SMODS.Scoring_Parameter.obj_buffer) do
            if G.GAME.hands[hand][parameter] then
                context.old_parameters[parameter] = G.GAME.hands[hand][parameter]
                G.GAME.hands[hand][parameter] = G.GAME.hands[hand][parameter] + G.GAME.hands[hand]['l_' .. parameter] * level
                context.new_parameters[parameter] = G.GAME.hands[hand][parameter]
            end
        end

        if not instant then
            Spectrallib.event{
                function()
                    G.TAROT_INTERRUPT_PULSE = true
                    return true
                end,
                trigger = "after",
                delay = 0,
            }
            Spectrallib.event(1.3)
            Spectrallib.event{
                function()
                    play_sound("slib_eechips")
                    play_sound("slib_eemult")
                    if args.from then
                        for _, card in ipairs(args.from) do
                            if card and card.juice_up then
                                card:juice_up(0.8, 0.5)
                            end
                        end
                    end
                    Spectrallib.pulse_flame(0.5, Spectrallib.clamp(0, to_number(G.GAME.hands[hand].level), 1e200))
                    Spectrallib.pulse_scoring_window_colors(HEX("d74ff2"), 0.1, 0.7, 2.5)
                    G.TAROT_INTERRUPT_PULSE = nil
                    return true
                end,
                trigger = "after",
                delay = 0.4,
            }

            local uht_args = {
                StatusText = {cover_colour = args.colour or HEX("d74ff2")},
                level = G.GAME.hands[hand].level,
            }

            for _, parameter in ipairs(SMODS.Scoring_Parameter.obj_buffer) do
                if G.GAME.hands[hand][parameter] then
                    uht_args[parameter] = "X" .. number_format(args.level_up)
                end
            end

            update_hand_text({sound = 'button', volume = 0.7, delay = 0}, uht_args)
            delay(1.3)
        end
        if not args.bypass_calculate then SMODS.calculate_context(context) end
    end

    if not instant and not displayed then
        update_hand_text({
            sound = 'button', volume = 0.7,
            pitch = 1.1, delay = 0
        }, vals_after_level)
    end
end