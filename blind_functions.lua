function Spectrallib.return_to_deck()

end

function Spectrallib.get_bg_colour()
    return G.C.BLIND['Small']
end

function Spectrallib.blind_is(blind)
    if G.GAME.blind and G.GAME.blind.config and G.GAME.blind.config.blind.key == blind then return true end
    if Spectrallib.in_table(Spectrallib.get_copied_blinds(G.GAME.blind), blind) then return true end
end
if Entropy then Entropy.blind_is = Spectrallib.blind_is end --circumventing the redirect system because only this function needs it

function Spectrallib.get_copied_blinds(self, cent)
    local cent = cent or self and self.config and self.config.blind
    if cent and cent.get_copied_blinds then
        local ret = cent:get_copied_blinds(self)
        if type(ret) ~= "table" then ret = {ret} end
        local tret = {}
        for i, v in pairs(ret) do
            if G.P_BLINDS[v] then tret[#tret+1] = v end
        end
        for i, v in pairs(tret) do
            local ret = Spectrallib.get_copied_blinds(self, G.P_BLINDS[v])
            if type(ret) ~= "table" then ret = {ret} end
            for i, v in pairs(ret) do
                if G.P_BLINDS[v] then tret[#tret+1] = v end
            end
        end
        return tret
    end
    return {}
end

function Spectrallib.set_copied_blinds(blinds, self, silent, reset)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.set_blind then
            s:set_blind(reset, silent)
        end
        if s.name == "The Eye" and not reset then
            G.GAME.blind.hands = {
                ["Flush Five"] = false,
                ["Flush House"] = false,
                ["Five of a Kind"] = false,
                ["Straight Flush"] = false,
                ["Four of a Kind"] = false,
                ["Full House"] = false,
                ["Flush"] = false,
                ["Straight"] = false,
                ["Three of a Kind"] = false,
                ["Two Pair"] = false,
                ["Pair"] = false,
                ["High Card"] = false,
            }
        end
        if s.name == "The Mouth" and not reset then
            G.GAME.blind.only_hand = false
        end
        if s.name == "The Fish" and not reset then
            G.GAME.blind.prepped = nil
        end
        if s.name == "The Water" and not reset then
            G.GAME.blind.discards_sub = G.GAME.current_round.discards_left
            ease_discard(-G.GAME.blind.discards_sub)
        end
        if s.name == "The Needle" and not reset then
            G.GAME.blind.hands_sub = G.GAME.round_resets.hands - 1
            ease_hands_played(-G.GAME.blind.hands_sub)
        end
        if s.name == "The Manacle" and not reset then
            G.hand:change_size(-1)
        end
        if s.name == "Amber Acorn" and not reset and #G.jokers.cards > 0 then
            G.jokers:unhighlight_all()
            for k, v in ipairs(G.jokers.cards) do
                v:flip()
            end
            if #G.jokers.cards > 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.2,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.jokers:shuffle("aajk")
                                play_sound("cardSlide1", 0.85)
                                return true
                            end,
                        }))
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.jokers:shuffle("aajk")
                                play_sound("cardSlide1", 1.15)
                                return true
                            end,
                        }))
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.jokers:shuffle("aajk")
                                play_sound("cardSlide1", 1)
                                return true
                            end,
                        }))
                        delay(0.5)
                        return true
                    end,
                }))
            end
        end
    end
end

local set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent, ...)
    local ret = set_blind_ref(self, blind, reset, silent, ...)
    Spectrallib.set_copied_blinds(Spectrallib.get_copied_blinds(self), self, silent, reset)
    return ret
end

function Spectrallib.defeat_copied_blinds(blinds, self, silent)
    for _, k in pairs(blinds) do
        if G.P_BLINDS[k].defeat then
            G.P_BLINDS[k]:defeat(silent)
        end
        if G.P_BLINDS[k].name == "The Manacle" and not self.disabled then
            G.hand:change_size(1)
        end
    end
end

local defeat_blind_ref = Blind.defeat
function Blind:defeat(silent, ...)
    local ret = defeat_blind_ref(self, silent, ...)
    Spectrallib.defeat_copied_blinds(Spectrallib.get_copied_blinds(self), self, silent)
    return ret
end

function Spectrallib.press_play_copied_blinds(blinds, self)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.press_play then
            s:press_play()
        end
        if s.name == "The Hook" then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local any_selected = nil
                    local _cards = {}
                    for k, v in ipairs(G.hand.cards) do
                        _cards[#_cards + 1] = v
                    end
                    for i = 1, 2 do
                        if G.hand.cards[i] then
                            local selected_card, card_key = pseudorandom_element(_cards, pseudoseed("ObsidianOrb"))
                            G.hand:add_to_highlighted(selected_card, true)
                            table.remove(_cards, card_key)
                            any_selected = true
                            play_sound("card1", 1)
                        end
                    end
                    if any_selected then
                        G.FUNCS.discard_cards_from_highlighted(nil, true)
                    end
                    return true
                end,
            }))
            G.GAME.blind.triggered = true
            delay(0.7)
        end
        if s.name == "Crimson Heart" then
            if G.jokers.cards[1] then
                G.GAME.blind.triggered = true
                G.GAME.blind.prepped = true
            end
        end
        if s.name == "The Fish" then
            G.GAME.blind.prepped = true
        end
        if s.name == "The Tooth" then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.2,
                func = function()
                    for i = 1, #G.play.cards do
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.play.cards[i]:juice_up()
                                return true
                            end,
                        }))
                        ease_dollars(-1)
                        delay(0.23)
                    end
                    return true
                end,
            }))
            G.GAME.blind.triggered = true
        end
    end
end

local press_play_ref = Blind.press_play
function Blind:press_play(...)
    local ret = press_play_ref(self, ...)
    Spectrallib.press_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
    return ret
end

function Spectrallib.calculate_copied_blinds(blinds, blind, context)
    if not G.GAME.blind.disabled then
        for _, k in pairs(blinds) do
            s = G.P_BLINDS[k]
            if s.calculate then
                local ret = s:calculate(blind, context)
                if ret then return ret end
            end
        end
    end
end

local calculate_ref = Blind.calculate
function Blind:calculate(context, ...)
    local ret = calculate_ref(self, context, ...)
    local ret2 = Spectrallib.calculate_copied_blinds(Spectrallib.get_copied_blinds(self), self, context)
    return ret or ret2
end

function Spectrallib.modify_hand_copied_blinds(blinds, self, cards, poker_hands, text, mult, hand_chips)
    local new_mult = mult
    local new_chips = hand_chips
    local trigger = false
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.modify_hand then
            local this_trigger = false
            new_mult, new_chips, this_trigger = s:modify_hand(cards, poker_hands, text, new_mult, new_chips)
            trigger = trigger or this_trigger
        end
        if s.name == "The Flint" then
            G.GAME.blind.triggered = true
            new_mult = math.max(math.floor(new_mult * 0.5 + 0.5), 1)
            new_chips = math.max(math.floor(new_chips * 0.5 + 0.5), 0)
            trigger = true
        end
    end
    return new_mult or mult, new_chips or hand_chips, trigger
end

local modify_hand_ref = Blind.modify_hand
function Blind:modify_hand(...)
    local mult, chips, trigger = modify_hand_ref(self, ...)
    mult, chips, trigger = Spectrallib.modify_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, ...)
    return mult, chips, trigger
end

function Spectrallib.get_blind_text(key)
    local self = {
        name = ''
    }
    local loc_vars = nil
    if key == 'bl_ox' then
        loc_vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}
    end
    local target = {type = 'raw_descriptions', key = key, set = 'Blind', vars = loc_vars or G.P_BLINDS[key].vars}
    local obj = G.P_BLINDS[key]
    if obj.loc_vars and type(obj.loc_vars) == 'function' then
        local res = obj:loc_vars() or {}
        target.vars = res.vars or target.vars
        target.key = res.key or target.key
        target.set = res.set or target.set
        target.scale = res.scale
        target.text_colour = res.text_colour
    end
    local loc_target = localize(target)
    if loc_target then 
        self.loc_name = localize{type ='name_text', key = G.P_BLINDS[key].key, set = 'Blind'}
        self.loc_debuff_text = ''
        self.loc_debuff_lines = {}
        if G.localization.descriptions[target.set][target.key] then
            for k, v in ipairs(G.localization.descriptions[target.set][target.key].text_parsed) do
                self.loc_debuff_lines[k] = v
            end
            self.loc_debuff_lines.vars = target.vars
            self.loc_debuff_lines.scale = target.scale
            self.loc_debuff_lines.text_colour = target.text_colour
        else
            for k, v in ipairs(loc_target) do
                self.loc_debuff_lines[k] = v
            end
        end
        for k, v in ipairs(loc_target) do
            self.loc_debuff_text = self.loc_debuff_text..v..(k <= #loc_target and ' ' or '')
        end
    else
        self.loc_name = ''; self.loc_debuff_text = ''
        self.loc_debuff_lines = {}
    end
    return self
end

--SMODS.debuff_text
function Spectrallib.get_debuff_text(key)
    local obj = G.P_BLINDS[key]
    if obj.get_loc_debuff_text and type(obj.get_loc_debuff_text) == 'function' then
        return obj:get_loc_debuff_text()
    end
    local bl = Spectrallib.get_blind_text(key)
    local disp_text = (obj.name == 'The Wheel' and G.GAME.probabilities.normal or '')..bl.loc_debuff_text
    if (obj.name == 'The Mouth') and self.only_hand then disp_text = disp_text..' ['..localize(self.only_hand, 'poker_hands')..']' end
    return disp_text
end

function Spectrallib.debuff_hand_copied_blinds(blinds, self, cards, hand, handname, check)
    G.GAME.blind.debuff_boss = nil
	for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.debuff_hand and s:debuff_hand(cards, hand, handname, check) then
            G.GAME.blind.debuff_boss = s
            return true
        end
        if s.debuff then
            G.GAME.blind.triggered = false
            if s.debuff.hand and next(hand[s.debuff.hand]) then
                G.GAME.blind.triggered = true
                G.GAME.blind.debuff_boss = s
                SMODS.debuff_text = Spectrallib.get_debuff_text(k)
                return true
            end
            if s.debuff.h_size_ge and #cards < s.debuff.h_size_ge then
                G.GAME.blind.triggered = true
                G.GAME.blind.debuff_boss = s
                SMODS.debuff_text = Spectrallib.get_debuff_text(k)
                return true
            end
            if s.debuff.h_size_le and #cards > s.debuff.h_size_le then
                G.GAME.blind.triggered = true
                G.GAME.blind.debuff_boss = s
                SMODS.debuff_text = Spectrallib.get_debuff_text(k)
                return true
            end
            if s.name == "The Eye" then
                G.GAME.blind.hands = G.GAME.blind.hands or {}
                if G.GAME.blind.hands[handname] then
                    G.GAME.blind.triggered = true
                    G.GAME.blind.debuff_boss = s
                    SMODS.debuff_text = Spectrallib.get_debuff_text(k)
                    return true
                end
                if not check then
                    G.GAME.blind.hands[handname] = true
                end
            end
            if s.name == "The Mouth" then
                if s.only_hand and s.only_hand ~= handname then
                    G.GAME.blind.triggered = true
                    G.GAME.blind.debuff_boss = s
                    SMODS.debuff_text = Spectrallib.get_debuff_text(k)
                    return true
                end
                if not check then
                    s.only_hand = handname
                end
            end
        end
        if s.name == "The Arm" then
            G.GAME.blind.triggered = false
            if to_big(G.GAME.hands[handname].level) > to_big(1) then
                G.GAME.blind.triggered = true
                if not check then
                    SMODS.upgrade_poker_hands{hands = handname, from = G.GAME.blind.children.animatedSprite, level_up = -1}
                    G.GAME.blind:wiggle()
                end
            end
        end
        if s.name == "The Ox" then
            G.GAME.blind.triggered = false
            if handname == G.GAME.current_round.most_played_poker_hand then
                G.GAME.blind.triggered = true
                if not check then
                    ease_dollars(-G.GAME.dollars, true)
                    G.GAME.blind:wiggle()
                end
            end
        end
    end
    return false
end

local debuff_hand_ref = Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
    return debuff_hand_ref(self, cards, hand, handname, check) or Spectrallib.debuff_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, cards, hand, handname, check)
end

function Spectrallib.drawn_to_hand_copied_blinds(blinds, self)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.drawn_to_hand then
            s:drawn_to_hand()
        end
        if s.name == "Cerulean Bell" then
            local any_forced = nil
            for k, v in ipairs(G.hand.cards) do
                if v.ability.forced_selection then
                    any_forced = true
                end
            end
            if not any_forced then
                G.hand:unhighlight_all()
                local forced_card = pseudorandom_element(G.hand.cards, pseudoseed("ObsidianOrb"))
                if focred_card then
                    forced_card.ability.forced_selection = true
                    G.hand:add_to_highlighted(forced_card)
                end
            end
        end
        if s.name == "Crimson Heart" and G.GAME.blind.prepped and G.jokers.cards[1] then
            local jokers = {}
            for i = 1, #G.jokers.cards do
                if not G.jokers.cards[i].debuff or #G.jokers.cards < 2 then
                    jokers[#jokers + 1] = G.jokers.cards[i]
                end
                G.jokers.cards[i]:set_debuff(false)
            end
            local _card = pseudorandom_element(jokers, pseudoseed("ObsidianOrb"))
            if _card then
                _card:set_debuff(true)
                _card:juice_up()
                G.GAME.blind:wiggle()
            end
        end
    end
end

local drawn_to_hand_ref = Blind.drawn_to_hand
function Blind:drawn_to_hand(...)
    local ret = drawn_to_hand_ref(self, ...)
    Spectrallib.drawn_to_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, ...)
    return ret
end

function Spectrallib.stay_flipped_copied_blinds(blinds, self, area, card, from_area)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.stay_flipped and s:stay_flipped(area, card, from_area) then
            return true
        end
        if area == G.hand then
            if
                s.name == "The Wheel"
                and SMODS.pseudorandom_probability(blind, 'wheel', 1, 7)
            then
                return true
            end
            if
                s.name == "The House"
                and G.GAME.current_round.hands_played == 0
                and G.GAME.current_round.discards_used == 0
            then
                return true
            end
            if s.name == "The Mark" and card:is_face(true) then
                return true
            end
            if s.name == "The Fish" and G.GAME.blind.prepped then
                return true
            end
        end
    end
end

local stay_flipped_ref = Blind.stay_flipped
function Blind:stay_flipped(area, card, from_area)
    return stay_flipped_ref(self, area, card, from_area) or Spectrallib.stay_flipped_copied_blinds(Spectrallib.get_copied_blinds(self), self, area, card, from_area, from_area)
end

function Spectrallib.recalc_debuff_copied_blinds(blinds, self, card, from_blind)
    if card and type(card) == "table" and card.area then
        for _, k in pairs(blinds) do
            s = G.P_BLINDS[k]
            if s.debuff_card then
                s:debuff_card(card, from_blind)
            end
            if s.recalc_debuff then
                return s:recalc_debuff(card, from_blind)
            end
            if s.debuff and not G.GAME.blind.disabled and card.area ~= G.jokers then
                --this part is buggy for some reason
                if s.debuff.suit and Card.is_suit(card, s.debuff.suit, true) then
                    card:set_debuff(true)
                    return true
                end
                if s.debuff.is_face == "face" and Card.is_face(card, true) then
                    card:set_debuff(true)
                    return true
                end
                if s.name == "The Pillar" and card.ability.played_this_ante then
                    card:set_debuff(true)
                    return true
                end
                if s.debuff.value and s.debuff.value == card.base.value then
                    card:set_debuff(true)
                    return true
                end
                if s.debuff.nominal and s.debuff.nominal == card.base.nominal then
                    card:set_debuff(true)
                    return true
                end
            end
            if s.name == "Crimson Heart" and not G.GAME.blind.disabled and card.area == G.jokers then
                return
            end
            if s.name == "Verdant Leaf" and not G.GAME.blind.disabled and card.area ~= G.jokers then
                card:set_debuff(true)
                return true
            end
        end
    end
end

local recalc_debuff_ref = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
    recalc_debuff_ref(self, card, from_blind)
    if Spectrallib.recalc_debuff_copied_blinds(Spectrallib.get_copied_blinds(self), self, card, from_blind) then
        card:set_debuff(true)
    end
end

function Spectrallib.before_play_copied_blinds(blinds, self)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.before_play then
            s:before_play()
        end
        if s.cry_before_play then --back_compat
            s:cry_before_play()
        end
    end
end

function Spectrallib.after_play_copied_blinds(blinds, self)
    for _, k in pairs(blinds) do
        s = G.P_BLINDS[k]
        if s.after_play then
            s:after_play()
        end
        if s.cry_after_play then --back_compat
            s:cry_after_play()
        end
    end
end

local play_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    G.GAME.blind:before_play()
	play_ref(e)
end

local gfep = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(e)
	gfep(e)
	G.GAME.blind:after_play()
end

function Blind:after_play()
	if not self.disabled then
		local obj = self.config.blind
		if obj.after_play and type(obj.after_play) == "function" then
			obj:after_play()
		end
        Spectrallib.after_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
	end
end

function Blind:before_play()
	if not self.disabled then
		local obj = self.config.blind
		if obj.before_play and type(obj.before_play) == "function" then
			obj:before_play()
		end
        Spectrallib.before_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
	end
end

function Spectrallib.ante_base_mod_copied_blinds(blinds, dt)
    local mods = {}
    for i, k in pairs(blinds) do
        local obj = G.P_BLINDS[k]
        if obj.ante_base_mod and type(obj.ante_base_mod) == "function" then
			mods[#mods+1] = obj:ante_base_mod(dt)
		end
    end
    return mods
end

function Spectrallib.round_base_mod_copied_blinds(blinds, dt)
    local mods = {}
    for i, k in pairs(blinds) do
        local obj = G.P_BLINDS[k]
        if obj.round_base_mod and type(obj.round_base_mod) == "function" then
			mods[#mods+1] = obj:round_base_mod(dt)
		end
    end
    return mods
end

function Blind:ante_base_mod(dt)
    local mod = 0
	if not self.disabled then
		local obj = self.config.blind
		if obj.ante_base_mod and type(obj.ante_base_mod) == "function" then
			mod = obj:ante_base_mod(dt)
		end
        for i, v in pairs(Spectrallib.ante_base_mod_copied_blinds(Spectrallib.get_copied_blinds(self), self, dt)) do
            mod = mod * v
        end
        return mod
	end
	return 0
end

function Blind:round_base_mod(dt)
    local mod = 0
	if not self.disabled then
		local obj = self.config.blind
		if obj.round_base_mod and type(obj.round_base_mod) == "function" then
			mod = obj:round_base_mod(dt)
		end
        for i, v in pairs(Spectrallib.round_base_mod_copied_blinds(Spectrallib.get_copied_blinds(self), self, dt)) do
            mod = mod * v
        end
	end
	return 1
end

function Spectrallib.cap_final_score_copied_blinds(blinds, score)
    for i, k in pairs(blinds) do
        local obj = G.P_BLINDS[k]
        if obj.modify_score and type(obj.modify_score) == "function" then
			score = obj:modify_score(score)
		end
        if obj.cry_cap_score and type(obj.cry_cap_score) == "function" then
			score = obj:cap_score(score)
		end
    end
    return score
end

function Blind:cap_final_score(score)
	if not self.disabled then
		local obj = self.config.blind
		if obj.modify_score and type(obj.modify_score) == "function" then
			score = obj:modify_score(score)
		end
		if obj.cry_cap_score and type(obj.cry_cap_score) == "function" then
			score = obj:cap_score(score)
		end
	end
	return score
end

local upd = Game.update
function Game:update(dt)
	upd(self, dt)
    if G.GAME.blind then
        if
            G.GAME.round_resets.blind_states[c] ~= "Defeated"
            and not G.GAME.blind.disabled
            and G.GAME.chips < G.GAME.blind.chips
        then
            G.GAME.blind.chips = G.GAME.blind.chips
                + G.GAME.blind:ante_base_mod(dt)
                    * get_blind_amount(G.GAME.round_resets.ante)
                    * G.GAME.starting_params.ante_scaling
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        end
        if
            G.GAME.round_resets.blind_states[c] == "Current"
            and G.GAME
            and G.GAME.blind
            and not G.GAME.blind.disabled
            and to_big(G.GAME.chips) < to_big(G.GAME.blind.chips)
        then
            G.GAME.blind.chips = G.GAME.blind.chips
                * (G.GAME.blind.round_base_mod and G.GAME.blind:round_base_mod(dt) or 1)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        end
    end
end

local score_ref = SMODS.calculate_round_score
function SMODS.calculate_round_score(...)
    local score = score_ref(...)
    if G.GAME.blind then 
        score = G.GAME.blind:cap_final_score(score)
    end
    return score
end

function _G.info_queue_copied(key)
    local width = 6
    local desc_nodes = {}
    localize{type = 'descriptions', key = key, set = "Blind", nodes = desc_nodes, vars = {}}
    local desc = {}
    for _, v in ipairs(desc_nodes) do
        desc[#desc+1] = {n=G.UIT.R, config={align = "cm"}, nodes=v}
    end
    return 
    {n=G.UIT.R, config={align = "cm", colour = G.P_BLINDS[key].boss_colour or lighten(G.C.GREY, 0.4), r = 0.1, padding = 0.05}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1}, nodes = localize{type = 'name', key = key, set = "Blind", name_nodes = {}, vars = {}}},
        {n=G.UIT.R, config={align = "cm", maxw = 3.75, minh = 0.4, r = 0.1, padding = 0.05, colour = desc_nodes.background_colour or G.C.WHITE}, nodes={{n=G.UIT.R, config={align = "cm", padding = 0.03}, nodes=desc}}}
    }}
end

Spectrallib.max_blind_infoqueues = 5

function _G.create_UIBox_blind_info_queue(blind)
    local q_lines = {}
    local nodes = {}
    for _, v in ipairs(Spectrallib.get_copied_blinds(blind)) do
        q_lines[#q_lines+1] = info_queue_copied(v)
        if #q_lines >= Spectrallib.max_blind_infoqueues then
            nodes[#nodes+1] = {n=G.UIT.C, config = {align = "lm", padding = 0.1}, nodes = q_lines}
            q_lines = {}
        end
    end
    if  #q_lines >= 0 then
        nodes[#nodes+1] = {n=G.UIT.C, config = {align = "lm", padding = 0.1}, nodes = q_lines}
    end
    return
    {n=G.UIT.ROOT, config = {align = 'cm', colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, emboss = 0.05, padding = 0.05}, nodes={
        {n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, padding = 0.05, colour = G.C.GREY}, nodes=nodes}
    }}
end

local blind_hoverref = Blind.hover
function Blind.hover(self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
        if not self.hovering and self.states.visible and self.children.animatedSprite.states.visible then
            if next(Spectrallib.get_copied_blinds(self)) then
                G.blind_info_queue = UIBox{
                    definition = create_UIBox_blind_info_queue(self),
                    config = {
                        major = self,
                        parent = nil,
                        offset = {
                            x = 0.15,
                            y = 0.2 + 0.38*math.min(#Spectrallib.get_copied_blinds(self),Spectrallib.max_blind_infoqueues),
                        },  
                        type = "cr",
                    }
                }
                G.blind_info_queue.attention_text = true
                G.blind_info_queue.states.collide.can = false
                G.blind_info_queue.states.drag.can = false
                if self.children.alert then
                    self.children.alert:remove()
                    self.children.alert = nil
                end
            end
        end
    end
    blind_hoverref(self)
end

local blind_stop_hoverref = Blind.stop_hover
function Blind.stop_hover(self)
    if G.blind_info_queue then
        G.blind_info_queue:remove()
        G.blind_info_queue = nil
    end
    blind_stop_hoverref(self)
end