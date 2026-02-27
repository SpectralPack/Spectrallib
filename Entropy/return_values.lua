for _, v in ipairs({'eq_mult', 'Eqmult_mod', 'eq_chips', 'Eqchips_mod', 'xlog_chips'}) do
    table.insert(SMODS.scoring_parameter_keys or SMODS.calculation_keys or {}, v)
end
for _, v in ipairs({'asc', 'asc_mod', 'plus_asc', 'plusasc_mod', 'exp_asc', 'exp_asc_mod', 'x_asc',
                    'hyper_asc', 'hyper_asc_mod', 'hyperasc', 'hyperasc_mod'}) do
    table.insert(SMODS.other_calculation_keys or SMODS.calculation_keys or {}, v)
end

function Spectrallib.get_asc_colour(amount, text)
    return G.C.GOLD
end


function Spectrallib.card_eval_status_text_eq(card, eval_type, amt, percent, dir, extra, pref, col, sound, vol, ta)
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

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    ret = scie(effect, scored_card, key, amount, from_edition)
    if ret then
        return ret
    end
    if (key == 'eq_mult' or key == 'Eqmult_mod') then 
        mult = mod_mult(amount)
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent)
        end
        return true
    end
    if (key == 'eq_chips' or key == 'Eqchips_mod') then 
        local chips = hand_chips
        hand_chips = mod_chips(amount)
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'chips', amount, percent, nil, nil, "="..amount.. " Chips", G.C.BLUE)
        end
        return true
    end
    if (key == 'asc') or (key == 'asc_mod') or key == "x_asc" then
        local e = card_eval_status_text
        for i, v in pairs(SMODS.find_card("j_entr_axeh")) do
            amount = amount * v.ability.asc_mod
        end
        local hand
        if G.GAME.asc_power_hand and G.GAME.asc_power_hand ~= 0 then hand = G.GAME.asc_power_hand end
        local orig = to_big((hand or G.GAME.current_round.current_hand.cry_asc_num))
        if not G.GAME.asc_power_hand or G.GAME.asc_power_hand == 0 then G.GAME.asc_power_hand = G.GAME.current_round.current_hand.cry_asc_num end
        G.GAME.asc_power_hand = to_big(G.GAME.asc_power_hand) * to_big(amount)        
        local text = number_format(to_big(G.GAME.asc_power_hand))
                if not Spectrallib.should_skip_animations() then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
                    return true
                end
            }))
        else    
            G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
        end
        card_eval_status_text = function() end
        scie(effect, scored_card, "Xmult_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        scie(effect, scored_card, "Xchip_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        card_eval_status_text = e
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent, nil, nil, "X"..amount.." Asc", Spectrallib.get_asc_colour(amount), "entr_e_solar", 0.6)
        end
        return true
    end
    if (key == 'plus_asc') or (key == 'plusasc_mod') then
        local e = card_eval_status_text
        for i, v in pairs(SMODS.find_card("j_entr_axeh")) do
            amount = amount * v.ability.asc_mod
        end
        local hand
        if G.GAME.asc_power_hand and G.GAME.asc_power_hand ~= 0 then hand = G.GAME.asc_power_hand end
        local orig = to_big((hand or G.GAME.current_round.current_hand.cry_asc_num))
        if not G.GAME.asc_power_hand or G.GAME.asc_power_hand == 0 then G.GAME.asc_power_hand = G.GAME.current_round.current_hand.cry_asc_num or 0 end
        G.GAME.asc_power_hand = to_big(G.GAME.asc_power_hand) + to_big(amount)
        local text = number_format(to_big(G.GAME.asc_power_hand))
        if not Spectrallib.should_skip_animations() then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
                    return true
                end
            }))
        else    
            G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
        end
        card_eval_status_text = function() end
        scie(effect, scored_card, "Xmult_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        scie(effect, scored_card, "Xchip_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        card_eval_status_text = e
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent, nil, nil, (to_big(amount) < to_big(0) and "" or "+")..amount.." Asc", Spectrallib.get_asc_colour(amount), "entr_e_solar", 0.6)
        end
        return true
    end
    if (key == 'exp_asc') or (key == 'exp_asc_mod') then
        local e = card_eval_status_text
        for i, v in pairs(SMODS.find_card("j_entr_axeh")) do
            amount = amount * v.ability.asc_mod
        end
        local hand
        if G.GAME.asc_power_hand and G.GAME.asc_power_hand ~= 0 then hand = G.GAME.asc_power_hand end
        local orig = to_big((hand or G.GAME.current_round.current_hand.cry_asc_num))
        if not G.GAME.asc_power_hand or G.GAME.asc_power_hand == 0 then G.GAME.asc_power_hand = G.GAME.current_round.current_hand.cry_asc_num or 0 end
        G.GAME.asc_power_hand = to_big(G.GAME.asc_power_hand) ^ to_big(amount)
        local text = number_format(to_big(G.GAME.asc_power_hand))
        if not Spectrallib.should_skip_animations() then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
                    return true
                end
            }))
        else    
            G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
        end
        card_eval_status_text = function() end
        scie(effect, scored_card, "Xmult_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        scie(effect, scored_card, "Xchip_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        card_eval_status_text = e
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent, nil, nil, "^"..amount.." Asc", Spectrallib.get_asc_colour(amount), "entr_e_solar", 0.6)
        end
        return true
    end
    if (key == 'hyper_asc') or (key == 'hyper_asc_mod') or key == "hyperasc" or key == "hyperasc_mod" then
        for i, v in pairs(SMODS.find_card("j_entr_axeh")) do
            amount = amount * v.ability.asc_mod
        end
        local e = card_eval_status_text
        local hand
        if G.GAME.asc_power_hand and G.GAME.asc_power_hand ~= 0 then hand = G.GAME.asc_power_hand end
        local orig = to_big((hand or G.GAME.current_round.current_hand.cry_asc_num))
        if not G.GAME.asc_power_hand or G.GAME.asc_power_hand == 0 then G.GAME.asc_power_hand = G.GAME.current_round.current_hand.cry_asc_num or 1 end
        G.GAME.asc_power_hand = to_big(G.GAME.asc_power_hand):arrow(amount[1], amount[2])
        local text = number_format(to_big(G.GAME.asc_power_hand))
        if not Spectrallib.should_skip_animations() then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
                    return true
                end
            }))
        else    
            G.GAME.current_round.current_hand.cry_asc_num_text = (to_big(G.GAME.asc_power_hand) < to_big(0) and " (" or " (+") .. (text) .. ")" 
        end
        card_eval_status_text = function() end
        scie(effect, scored_card, "Xmult_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        scie(effect, scored_card, "Xchip_mod", Cryptid.ascend(1, G.GAME.asc_power_hand - orig), false)
        card_eval_status_text = e
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'mult', amount, percent, nil, nil, Spectrallib.format_arrow_mulkt(amount[1], amount[2]).." Asc", Spectrallib.get_asc_colour(amount), "entr_e_solar", 0.6)
        end 
        return true
    end
    if key == 'xlog_chips' then
        local chips = hand_chips
        local gt = to_big(chips) < to_big(0) and 1 or chips
        gt = to_big(gt)
        local log = Talisman and Big and gt.log and gt:log(to_big(amount)) or math.log(gt, amount)
        hand_chips = mod_chips(to_big(chips) * math.max(log, 1))
        if not Spectrallib.should_skip_animations() then
            Spectrallib.card_eval_status_text_eq(scored_card or effect.card or effect.focus, 'chips', 1, percent, nil, nil, "Chips Xlog(Chips)", G.C.BLUE, "entr_e_rizz", 0.6)
        end
        return true
    end
end

local e_round = end_round
function end_round()
    e_round()
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function() G.GAME.asc_power_hand = 0; G.GAME.current_round.current_hand.cry_asc_num = 0;G.GAME.current_round.current_hand.cry_asc_num_text = '';return true end)
    }))
end

local play_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    G.GAME.asc_power_hand = 0
    return play_ref(e)
end
