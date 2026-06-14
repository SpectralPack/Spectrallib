for _, v in ipairs({'eq_mult', 'Eqmult_mod', 'xlog_mult', 'eq_chips', 'Eqchips_mod', 'xlog_chips',}) do
    table.insert(SMODS.scoring_parameter_keys or SMODS.calculation_keys or {}, v)
end
for _, v in ipairs({'asc', 'asc_mod', 'plus_asc', 'plusasc_mod', 'exp_asc', 'exp_asc_mod', 'x_asc',
    'hyper_asc', 'hyper_asc_mod', 'hyperasc', 'hyperasc_mod'}) do
    table.insert(SMODS.other_calculation_keys or SMODS.calculation_keys or {}, v)
end

function Spectrallib.get_asc_colour(amount, text)
    return G.C.GOLD
end

SMODS.Sound{
    key = "solar",
    path = "solar.ogg"
}

SMODS.Sound{
    key = "xlog_chips",
    path = "rizz.ogg"
}

-- Identical to card_eval_status_text but with additional parameters for sound control
-- (todo: I'll consider this a blackbox until I feel like working with it -Oinite)
function Spectrallib.card_eval_status_text_eq(card, eval_type, amt, percent, dir, extra, pref, col, sound, vol, ta)
    card = card.original_card or card
    percent = percent or (0.9 + 0.2*math.random())
    if dir == 'down' then
        percent = 1-percent
    end

    if extra and extra.focus then card = extra.focus end

    local text = ''
    local volume = vol or 1
    local card_aligned = 'bm'
    local y_off = 0.15*G.CARD_H
    if card.area == G.jokers or card.area == G.consumeables then
        y_off = 0.05*card.T.h
    elseif card.area == G.hand or ta then
        y_off = -0.05*G.CARD_H
        card_aligned = 'tm'
    elseif card.area == G.play then
        y_off = -0.05*G.CARD_H
        card_aligned = 'tm'
    elseif card.jimbo then
        y_off = -0.05*G.CARD_H
        card_aligned = 'tm'
    end
    local config = {}
    local delay = 0.65
    local colour = config.colour or (extra and extra.colour) or ( G.C.FILTER )
    local extrafunc = nil
    sound = sound or 'multhit1'--'other1'
    amt = amt
    text = (pref) or ("Mult = "..amt)
    colour = col or G.C.MULT
    config.type = 'fade'
    config.scale = 0.7
    delay = delay*1.25
    if to_big(amt) > to_big(0) or to_big(amt) < to_big(0) then
        if extra and extra.instant then
            if extrafunc then extrafunc() end
            attention_text({
                text = text,
                scale = config.scale or 1,
                hold = delay - 0.2,
                backdrop_colour = colour,
                align = card_aligned,
                major = card,
                offset = {x = 0, y = y_off}
            })
            play_sound(sound, 0.8+percent*0.2, volume)
            if not extra or not extra.no_juice then
                card:juice_up(0.6, 0.1)
                G.ROOM.jiggle = G.ROOM.jiggle + 0.7
            end
        else
            G.E_MANAGER:add_event(Event({ --Add bonus chips from this card
                    trigger = 'before',
                    delay = delay,
                    func = function()
                    if extrafunc then extrafunc() end
                    attention_text({
                        text = text,
                        scale = config.scale or 1,
                        hold = delay - 0.2,
                        backdrop_colour = colour,
                        align = card_aligned,
                        major = card,
                        offset = {x = 0, y = y_off}
                    })
                    play_sound(sound, 0.8+percent*0.2, volume)
                    if not extra or not extra.no_juice then
                        card:juice_up(0.6, 0.1)
                        G.ROOM.jiggle = G.ROOM.jiggle + 0.7
                    end
                    return true
                    end
            }))
        end
    end
    if extra and extra.playing_cards_created then
        playing_card_joker_effects(extra.playing_cards_created)
    end
end

--------------------------
-- NEW CALCULATION KEYS --
--------------------------

local eq_mult_aliases = Spectrallib.list_to_keys{'eq_mult', 'Eqmult_mod'}
local eq_chips_aliases = Spectrallib.list_to_keys{'eq_chips', 'Eqchips_mod'}

local sp_mult_calc_hook = SMODS.Scoring_Parameters.mult.calc_effect
SMODS.Scoring_Parameter:take_ownership('mult', {
    calc_effect = function(self, effect, scored_card, key, amount, from_edition)
        if eq_mult_aliases[key] then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            self:modify(amount - self.current)
            if not Spectrallib.should_skip_animations() then
                Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent, nil, nil, localize{ type = "variable", key = "a_eq_mult", vars = {amount}}, G.C.RED )
            end
            return true
        end
        if key == "xlog_mult" then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            local log = math.log(self.current < 0 and 1 or self.current, amount)
            self:modify(self.current*log - self.current)
            if not Spectrallib.should_skip_animations() then
                Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'chips', 1, percent, nil, nil, "Mult Xlog(Mult)", G.C.RED, "multhit2", 0.6)
            end
            return true
        end
        return sp_mult_calc_hook(self, effect, scored_card, key, amount, from_edition) --[[@diagnostic disable-line need-check-nil]]
    end
}, true)

local sp_chips_calc_hook = SMODS.Scoring_Parameters.chips.calc_effect
SMODS.Scoring_Parameter:take_ownership('chips', {
    calc_effect = function(self, effect, scored_card, key, amount, from_edition)
        if eq_chips_aliases[key] then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            self:modify(amount - self.current)
            if not Spectrallib.should_skip_animations() then
                Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'chips', amount, percent, nil, nil, localize{ type = "variable", key = "a_eq_chips", vars = {amount}}, G.C.BLUE)
            end
            return true
        end
        if key == "xlog_chips" then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            local log = math.log(self.current < 0 and 1 or self.current, amount)
            self:modify(self.current*log - self.current)
            if not Spectrallib.should_skip_animations() then
                Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'chips', 1, percent, nil, nil, "Chips Xlog(Chips)", G.C.BLUE, "slib_xlog_chips", 0.6) --janky compat hack
            end
            return true
        end
        return sp_chips_calc_hook(self, effect, scored_card, key, amount, from_edition) --[[@diagnostic disable-line need-check-nil]]
    end
}, true)

-- todo: unsure if adding to SMODS.Scoring_Parameter_Calculation is redundant, please check
for _,key in ipairs({'eq_mult', 'Eqmult_mod', 'xlog_mult'}) do
    table.insert(SMODS.Scoring_Parameters.mult.calculation_keys, key)
    SMODS.Scoring_Parameter_Calculation[key] = "mult"
end
for _,key in ipairs({'eq_chips', 'Eqchips_mod', 'xlog_chips'}) do
    table.insert(SMODS.Scoring_Parameters.chips.calculation_keys, key)
    SMODS.Scoring_Parameter_Calculation[key] = "chips"
end

--------------------------------
-- ASCENSION CALCULATION KEYS --
--------------------------------

local plus_asc_aliases  = Spectrallib.list_to_keys{"plus_asc", "plusasc_mod", "asc", "asc_mod"}
local exp_asc_aliases   = Spectrallib.list_to_keys{"exp_asc", "exp_asc_mod"}
local hyper_asc_aliases = Spectrallib.list_to_keys{"hyper_asc", "hyper_asc_mod", "hyperasc", "hyperasc_mod"}

---@class Spectrallib.calculate_ascension_modification.args
---@field calc_args {effect: table, scored_card: Card, amount: number, from_edition: boolean} All values provided to SMODS.calculate_individual_effect (except `key`) when it is called.
---A function describing how to apply a value to the current value.<br>
---You do NOT have to account for nulling the current value.<br>
---For example, use `current^amount`, not `current^amount - current`.
---@field apply_func fun(current: number, apply: number): number
---@field message_func fun(apply: number): (string|any) The text to display for the card's message.

-- Change Ascension Power *during* score calculation.
-- Intended to be hooked for additional functionality.
---@param args Spectrallib.calculate_ascension_modification.args
---@return true
function Spectrallib.calculate_ascension_modification(args)
    local effect       = args.calc_args.effect
    local scored_card  = args.calc_args.scored_card
    local amount       = args.calc_args.amount
    local from_edition = args.calc_args.from_edition
    local apply_func   = args.apply_func
    local message_func = args.message_func

    -- Store current ascension power
    -- and fallback global ascension power
    local hand = G.GAME.current_round.current_hand.cry_asc_num
    if (G.GAME.asc_power_hand or 0) ~= 0 then
        hand = G.GAME.asc_power_hand
    else
        G.GAME.asc_power_hand = G.GAME.current_round.current_hand.cry_asc_num
    end

    -- Modify global ascension power
    G.GAME.asc_power_hand = apply_func(G.GAME.asc_power_hand, amount)

    -- Set the text in the ascension power window
    Spectrallib.event{
        function ()
            local text = number_format(G.GAME.asc_power_hand)
            local text_format = "(%s%s)"
            local optional_plus = G.GAME.asc_power_hand < 0 and "+" or ""
            G.GAME.current_round.current_hand.cry_asc_num_text = text_format:format(optional_plus, text)
            return true
        end,
        instant = Spectrallib.should_skip_animations()
    }

    -- Update chips/mult to reflect new power
    local temp = card_eval_status_text
    card_eval_status_text = function() end -- Temporarily disable the function
        local sp_mult  = SMODS.Scoring_Parameters.mult
        local sp_chips = SMODS.Scoring_Parameters.chips
        local ascend_power_value = G.GAME.asc_power_hand - hand
        sp_mult:modify(Spectrallib.ascend(sp_mult.current, ascend_power_value) - sp_mult.current)
        sp_chips:modify(Spectrallib.ascend(sp_chips.current, ascend_power_value) - sp_chips.current)
    card_eval_status_text = temp -- Re-enable

    -- Message on card
    if not Spectrallib.should_skip_animations() then
        local card_msg = scored_card or effect.card or effect.focus
        Spectrallib.card_eval_status_text_eq(card_msg, 'mult', amount, percent, nil, nil, message_func(amount), Spectrallib.get_asc_colour(amount), "slib_solar", 0.6)
    end

    return true
end

-- todo: a lot of sounds missing here!
local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    local ret = scie(effect, scored_card, key, amount, from_edition)
    if ret then return ret end
    local calc_args = {
        effect = effect,
        scored_card =
        scored_card,
        key = key,
        amount = amount,
        from_edition = from_edition
    }

    if plus_asc_aliases[key] then
        return Spectrallib.calculate_ascension_modification{
            calc_args = calc_args,
            apply_func = function(current, apply)
                return current + apply
            end,
            message_func = function(apply)
                local msg_key = apply < 0 and "a_asc_minus" or "a_asc"
                apply = math.abs(apply)
                return localize{ type = "variable", key = msg_key, vars = {apply} }
            end
        }
    end
    if key == "x_asc" then
        return Spectrallib.calculate_ascension_modification{
            calc_args = calc_args,
            apply_func = function(current, apply)
                return current*apply
            end,
            message_func = function(apply)
                return localize{ type = "variable", key = "a_xasc", vars = {apply} }
            end
        }
    end
    if exp_asc_aliases[key] then
        return Spectrallib.calculate_ascension_modification{
            calc_args = calc_args,
            apply_func = function(current, apply)
                return current^apply
            end,
            message_func = function(apply)
                return localize{ type = "variable", key = "a_exp_asc", vars = {apply} }
            end
        }
    end
    if hyper_asc_aliases[key] then
        return Spectrallib.calculate_ascension_modification{
            calc_args = calc_args,
            apply_func = function(current, apply)
                return current:arrow(apply[1], apply[2])
            end,
            message_func = function(apply)
                return Spectrallib.format_arrow_mult(amount[1], amount[2]) .. " Asc"
            end
        }
    end
end

-- Reset during-calc ascension power changes
local e_round = end_round
function end_round()
    e_round()
    Spectrallib.event(function ()
        G.GAME.asc_power_hand = 0
        G.GAME.current_round.current_hand.cry_asc_num = 0
        G.GAME.current_round.current_hand.cry_asc_num_text = ''
        return true
    end)
end

local play_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    G.GAME.asc_power_hand = 0
    return play_ref(e)
end

-------------------------
-- PERMA BONUS METHODS --
-------------------------

-- xlog_chips
function Card:get_slib_xlog_chips()
return self.ability.slib_perma_xlog_chips
end

function Card:get_slib_h_xlog_chips()
return self.ability.slib_perma_h_xlog_chips
end

-- xlog_mult
function Card:get_slib_xlog_mult()
    return self.ability.slib_perma_xlog_mult
end

function Card:get_slib_h_xlog_mult()
    return self.ability.slib_perma_h_xlog_mult
end

-- plus_asc
--these currently only return a single value, but exist in case other effects get added that would need to be returned here
function Card:get_slib_plus_asc()
    return self.ability.slib_perma_plus_asc
end

function Card:get_slib_h_plus_asc()
    return self.ability.slib_perma_h_plus_asc
end

-- x_asc
function Card:get_slib_x_asc()
    return self.ability.slib_perma_x_asc + 1
end

function Card:get_slib_h_x_asc()
    return self.ability.slib_perma_h_x_asc + 1
end

-- exp_asc
function Card:get_slib_exp_asc()
    return self.ability.slib_perma_exp_asc + 1
end

function Card:get_slib_h_exp_asc()
    return self.ability.slib_perma_h_exp_asc + 1
end

-- e_chips
function Card:get_slib_e_chips()
    return self.ability.slib_perma_e_chips + 1
end

function Card:get_slib_h_e_chips()
    return self.ability.slib_perma_h_e_chips + 1
end

-- e_mult
function Card:get_slib_e_mult()
    return self.ability.slib_perma_e_mult + 1
end

function Card:get_slib_h_e_mult()
    return self.ability.slib_perma_h_e_mult + 1
end