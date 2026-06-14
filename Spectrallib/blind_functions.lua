------------------------------------
--#region SUPPLEMENTARY FUNCTIONS --
------------------------------------

function Spectrallib.return_to_deck()

end

function Spectrallib.get_bg_colour()
    return G.C.BLIND['Small']
end

-- Get text associated with the blind.
---@param blind_key string
---@return { name: string, loc_name: string, loc_debuff_text: string, loc_debuff_lines: string[] }
function Spectrallib.get_blind_text(blind_key)
    local blind_proto = G.P_BLINDS[blind_key]
    local loc_vars = blind_proto.vars
    if blind_key == 'bl_ox' then
        loc_vars = { localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands') }
    end

    local target = {
        type = 'raw_descriptions',
        key = blind_key,
        set = 'Blind',
        vars = loc_vars
    }
    if type(blind_proto.loc_vars) == 'function' then
        local res = blind_proto:loc_vars() or {}
        target.key         = res.key or target.key
        target.set         = res.set or target.set
        target.vars        = res.vars or target.vars
        target.scale       = res.scale
        target.text_colour = res.text_colour
    end

    local ret = {
        name = '',
        loc_name = '',
        loc_debuff_text = '',
        loc_debuff_lines = {}
    }

    local loc_target = localize(target) --[[@as table]] -- due to providing `set`
    if loc_target then
        ret.loc_name = localize{
            type ='name_text',
            key = blind_proto.key,
            set = 'Blind'
        }
        ret.loc_debuff_text = table.concat(loc_target, " ")

        local blind_loc_entry = G.localization.descriptions[target.set][target.key]
        if blind_loc_entry then
            ret.loc_debuff_lines = SMODS.shallow_copy(blind_loc_entry.text_parsed)
            ret.loc_debuff_lines.vars = target.vars
            ret.loc_debuff_lines.scale = target.scale
            ret.loc_debuff_lines.text_colour = target.text_colour
        else
            ret.loc_debuff_lines = SMODS.shallow_copy(loc_target)
        end
    end

    return ret
end

-- Get the debuff text of a given blind.
---@param blind_key string Key of a blind.
---@param active_blind Blind The currently active blind.
---@return string
function Spectrallib.get_debuff_text(blind_key, active_blind)
    local blind_proto = G.P_BLINDS[blind_key]
    if type(blind_proto.get_loc_debuff_text) == 'function' then
        return blind_proto:get_loc_debuff_text()
    end

    local blind_text = Spectrallib.get_blind_text(blind_key)
    local disp_text = blind_text.loc_debuff_text
    if blind_proto.name == 'The Wheel' then
        local opt_probability = blind_proto.name == 'The Wheel' and G.GAME.probabilities.normal or ''
        disp_text = opt_probability .. disp_text
    end
    if blind_proto.name == 'The Mouth' and blind_proto.only_hand then
        local bracket_format = " [%s]"
        local poker_hand_text = localize(blind_proto.only_hand, 'poker_hands')
        disp_text = disp_text .. bracket_format:format(poker_hand_text)
    end

    return disp_text
end

--#endregion
------------------------------------

------------------------------
--#region NEW BLIND METHODS --
------------------------------

-- Evaluate effects that a blind causes before scoring a hand.
---@return nil
function Blind:before_play()
    if self.disabled then return end

    local blind_proto = self.config.blind
    if type(blind_proto.before_play) == "function" then
        blind_proto:before_play()
    end
    Spectrallib.before_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
end

-- Evaluate effects that a blind causes after scoring a hand.
---@return nil
function Blind:after_play()
    if self.disabled then return end

    local blind_proto = self.config.blind
    if type(blind_proto.after_play) == "function" then
        blind_proto:after_play()
    end
    Spectrallib.after_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
end


function Blind:ante_base_mod(dt)
    local mod = 0
    if self.disabled then return mod end

    local blind_proto = self.config.blind
    if blind_proto.ante_base_mod and type(blind_proto.ante_base_mod) == "function" then
        mod = blind_proto:ante_base_mod(dt)
    end
    for _, submod in pairs(Spectrallib.ante_base_mod_copied_blinds(Spectrallib.get_copied_blinds(self), self, dt)) do
        mod = mod * submod
    end
    return mod
end

function Blind:round_base_mod(dt)
    local mod = 1
    if self.disabled then return mod end

    local blind_proto = self.config.blind
    if blind_proto.round_base_mod and type(blind_proto.round_base_mod) == "function" then
        mod = blind_proto:round_base_mod(dt)
    end
    for _, submod in pairs(Spectrallib.round_base_mod_copied_blinds(Spectrallib.get_copied_blinds(self), self, dt)) do
        mod = mod * submod
    end
    return mod
end

function Blind:cap_final_score(score)
    if self.disabled then return score end

    local blind_proto = self.config.blind
    if blind_proto.modify_score and type(blind_proto.modify_score) == "function" then
        score = blind_proto:modify_score(score)
    end
    if blind_proto.cap_score and type(blind_proto.cap_score) == "function" then
        score = blind_proto:cap_score(score)
    end
    -- todo: not sure if this is how to implement this function
    score = Spectrallib.cap_final_score_copied_blinds(Spectrallib.get_copied_blinds(self), self, score)
    return score
end

--#endregion
------------------------------

--------------------------------
--#region BLIND-RELATED HOOKS --
--------------------------------

local upd = Game.update
function Game:update(dt)
	upd(self, dt)
    -- TODO:
    -- Similar code in Cryptid (Game:update hook, lib/overrides.lua) has:
    -- local choices = {"Small", "Big", "Boss"}; for _,c in pairs(choices) do .. end
    -- but idk if that's what we want here??? -Oinite
    if G.GAME.blind then
        if (
            G.GAME.round_resets.blind_states[c] ~= "Defeated"
            and not G.GAME.blind.disabled
            and G.GAME.chips < G.GAME.blind.chips
            and G.GAME.blind:ante_base_mod(dt) > 0
        ) then
            G.GAME.blind.chips = (
                G.GAME.blind.chips
                + G.GAME.blind:ante_base_mod(dt)
                * get_blind_amount(G.GAME.round_resets.ante)
                * G.GAME.starting_params.ante_scaling
            )
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        end

        if (
            G.GAME.round_resets.blind_states[c] == "Current"
            and G.GAME
            and G.GAME.blind
            and not G.GAME.blind.disabled
            and to_big(G.GAME.chips) < to_big(G.GAME.blind.chips)
            and (G.GAME.blind:round_base_mod(dt) or 0) > 0
        ) then
            G.GAME.blind.chips = (
                G.GAME.blind.chips
                * (G.GAME.blind.round_base_mod and G.GAME.blind:round_base_mod(dt) or 1)
            )
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

-- hook to implement Blind:before_play
local play_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e, ...)
    G.GAME.blind:before_play()
	play_ref(e, ...)
end

-- hook to implement Blind:after_play
local gfep = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(e, ...)
	gfep(e, ...)
	G.GAME.blind:after_play()
end

--#endregion
--------------------------------

-----------------------------------
--#region COPIED BLIND FUNCTIONS --
-----------------------------------

local blinditer = Spectrallib.iter.blinds

-- Get a list of keys of the blinds that a certain blind is copying.
---@param blind Blind
---@param proto? SMODS.Blind
---@return string[] # List of keys of copied blinds.
function Spectrallib.get_copied_blinds(blind, proto)
    proto = proto or (blind and blind.config and blind.config.blind)
    if not (proto and proto.get_copied_blinds) then return {} end

    local unchecked_blind_keys = proto:get_copied_blinds(blind)
    if type(unchecked_blind_keys) ~= "table" then
        unchecked_blind_keys = {unchecked_blind_keys}
    end

    local copied_blind_keys = {}
    for _, blind_key in pairs(unchecked_blind_keys) do
        if G.P_BLINDS[blind_key] then
            table.insert(copied_blind_keys, blind_key)
        end
    end

    for _, blind_key in pairs(copied_blind_keys) do
        -- Recursively get copied blinds
        local subcopied_blind_keys = Spectrallib.get_copied_blinds(blind, G.P_BLINDS[blind_key])
        for _, sub_blind_key in pairs(subcopied_blind_keys) do
            if G.P_BLINDS[sub_blind_key] then
                table.insert(copied_blind_keys, sub_blind_key)
            end
        end
    end

    return copied_blind_keys
end

-- Check if a blind (via its key) is in active effect (including as a copy).
---@param blind string The blind's key.
---@return true|nil
function Spectrallib.blind_is(blind)
    if Spectrallib.safe_get(G.GAME.blind, "config", "blind", "key") == blind then return true end
    if Spectrallib.in_table(Spectrallib.get_copied_blinds(G.GAME.blind), blind) then return true end
end

-- Run the `set_blind` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind? Blind The blind that is copying other blinds.
---@param silent? boolean
---@param reset? any
---@return nil
function Spectrallib.set_copied_blinds(blind_keys, copying_blind, silent, reset)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.set_blind then
            blind_proto:set_blind(reset, silent)
        end
        if reset then return end
        if blind_proto.name == "The Eye" then
            G.GAME.blind.hands = {}
            for _, v in ipairs(G.handlist) do
                G.GAME.blind.hands[v] = false
            end
        end
        if blind_proto.name == "The Mouth" then
            G.GAME.blind.only_hand = false
            blind_proto.only_hand = false
        end
        if blind_proto.name == "The Fish" then
            G.GAME.blind.prepped = nil
        end
        if blind_proto.name == "The Water" then
            G.GAME.blind.discards_sub = G.GAME.current_round.discards_left
            ease_discard(-G.GAME.blind.discards_sub)
        end
        if blind_proto.name == "The Needle" then
            G.GAME.blind.hands_sub = G.GAME.round_resets.hands - 1
            ease_hands_played(-G.GAME.blind.hands_sub)
        end
        if blind_proto.name == "The Manacle" then
            G.hand:change_size(-1)
        end
        if blind_proto.name == "Amber Acorn" and #G.jokers.cards > 0 then
            G.jokers:unhighlight_all()
            for _, joker in ipairs(G.jokers.cards) do
                joker:flip()
            end
            if #G.jokers.cards <= 1 then return end
            Spectrallib.event {
                function ()
                    Spectrallib.event(function ()
                        G.jokers:shuffle("aajk")
                        play_sound("cardSlide1", 0.85)
                        return true
                    end)
                    Spectrallib.event(0.15)
                    Spectrallib.event(function ()
                        G.jokers:shuffle("aajk")
                        play_sound("cardSlide1", 1.15)
                        return true
                    end)
                    Spectrallib.event(0.15)
                    Spectrallib.event(function ()
                        G.jokers:shuffle("aajk")
                        play_sound("cardSlide1", 1)
                        return true
                    end)
                    Spectrallib.event(0.5)
                    return true
                end,
                trigger = "after",
                delay = 0.2,
            }
            Spectrallib.event(0.2)
        end
    end
end

-- Run the `defeat` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param silent? boolean
---@return nil
function Spectrallib.defeat_copied_blinds(blind_keys, copying_blind, silent)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.defeat then
            blind_proto:defeat(silent)
        end
        if blind_proto.name == "The Manacle" and not copying_blind.disabled then
            G.hand:change_size(1)
        end
    end
end

-- Run the `press_play` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@return nil
function Spectrallib.press_play_copied_blinds(blind_keys, copying_blind)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.press_play then
            blind_proto:press_play()
        end
        if blind_proto.name == "The Hook" then
            Spectrallib.event(function ()
                local any_selected = nil
                local _cards = {}
                for _, card in ipairs(G.hand.cards) do
                    table.insert(_cards, card)
                end
                for i = 1, 2 do
                    if G.hand.cards[i] then
                        local selected_card, card_key = pseudorandom_element(_cards, pseudoseed("ObsidianOrb"))
                        G.hand:add_to_highlighted(selected_card, true)
                        table.remove(_cards, card_key --[[@as integer]])
                        any_selected = true
                        play_sound("card1", 1)
                    end
                end
                if any_selected then
                    G.FUNCS.discard_cards_from_highlighted(nil, true)
                end
                return true
            end)
            G.GAME.blind.triggered = true
            Spectrallib.event(0.7)
        end
        if blind_proto.name == "Crimson Heart" then
            if G.jokers.cards[1] then
                G.GAME.blind.triggered = true
                G.GAME.blind.prepped = true
            end
        end
        if blind_proto.name == "The Fish" then
            G.GAME.blind.prepped = true
        end
        if blind_proto.name == "The Tooth" then
            Spectrallib.event{
                function()
                    for i = 1, #G.play.cards do
                        Spectrallib.event(function ()
                            G.play.cards[i]:juice_up()
                            return true
                        end)
                        ease_dollars(-1)
                        Spectrallib.event(0.23)
                    end
                    return true
                end,
                trigger = "after",
                delay = 0.2,
            }
            G.GAME.blind.triggered = true
        end
    end
end

-- Run the `calculate` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param context table
---@return table|nil
function Spectrallib.calculate_copied_blinds(blind_keys, copying_blind, context)
    if G.GAME.blind.disabled then return end
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.calculate then
            local ret = blind_proto:calculate(copying_blind, context)
            if ret then return ret end
        end
    end
end

-- Run the `modify_hand` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param cards Card[]
---@param poker_hands table
---@param text PokerHands|string
---@param mult number
---@param hand_chips number
---@param trigger boolean
---@return number?
---@return number?
---@return boolean?
function Spectrallib.modify_hand_copied_blinds(blind_keys, copying_blind, cards, poker_hands, text, mult, hand_chips, trigger)
    local new_mult = mult
    local new_chips = hand_chips
    for _, blind_keys in pairs(blind_keys) do
        local blind_proto = G.P_BLINDS[blind_keys]
        if blind_proto.modify_hand then
            local this_trigger = false
            new_mult, new_chips, this_trigger = blind_proto:modify_hand(cards, poker_hands, text, new_mult, new_chips)
            trigger = trigger or this_trigger
        end
        if blind_proto.name == "The Flint" then
            G.GAME.blind.triggered = true
            new_mult = math.max(math.floor(new_mult * 0.5 + 0.5), 1)
            new_chips = math.max(math.floor(new_chips * 0.5 + 0.5), 0)
            trigger = true
        end
    end
    return new_mult or mult, new_chips or hand_chips, trigger
end

-- Run the `debuff_hand` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param cards Card[]
---@param hand table
---@param handname PokerHands|string
---@param check boolean
---@return boolean
function Spectrallib.debuff_hand_copied_blinds(blind_keys, copying_blind, cards, hand, handname, check)
    G.GAME.blind.debuff_boss = nil
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.debuff_hand and blind_proto:debuff_hand(cards, hand, handname, check) then
            G.GAME.blind.debuff_boss = blind_proto
            return true
        end

        if blind_proto.debuff then
            G.GAME.blind.triggered = false
            local function debuff_occurred()
                G.GAME.blind.triggered = true
                G.GAME.blind.debuff_boss = blind_proto
                SMODS.debuff_text = Spectrallib.get_debuff_text(blind_key, copying_blind)
                return true
            end
            if blind_proto.debuff.hand and next(hand[blind_proto.debuff.hand]) then
                return debuff_occurred()
            end
            if blind_proto.debuff.h_size_ge and #cards < blind_proto.debuff.h_size_ge then
                return debuff_occurred()
            end
            if blind_proto.debuff.h_size_le and #cards > blind_proto.debuff.h_size_le then
                return debuff_occurred()
            end
            if blind_proto.name == "The Eye" then
                G.GAME.blind.hands = G.GAME.blind.hands or {}
                if G.GAME.blind.hands[handname] then
                    return debuff_occurred()
                end
                if not check then
                    G.GAME.blind.hands[handname] = true
                end
            end
            if blind_proto.name == "The Mouth" then
                if blind_proto.only_hand and blind_proto.only_hand ~= handname then
                    return debuff_occurred()
                end
                if not check then
                    blind_proto.only_hand = handname
                end
            end
        end

        if blind_proto.name == "The Arm" then
            G.GAME.blind.triggered = false
            if G.GAME.hands[handname].level > 1 then
                G.GAME.blind.triggered = true
                if not check then
                    SMODS.upgrade_poker_hands{
                        hands = handname,
                        from = G.GAME.blind.children.animatedSprite,
                        level_up = -1
                    }
                    G.GAME.blind:wiggle()
                end
            end
        end
        if blind_proto.name == "The Ox" then
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

-- Run the `drawn_to_hand` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@return nil
function Spectrallib.drawn_to_hand_copied_blinds(blind_keys, copying_blind)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.drawn_to_hand then
            blind_proto:drawn_to_hand()
        end
        if blind_proto.name == "Cerulean Bell" then
            local any_forced = nil
            for _, card in ipairs(G.hand.cards) do
                if card.ability.forced_selection then
                    any_forced = true
                end
            end
            if not any_forced then
                G.hand:unhighlight_all()
                local forced_card = pseudorandom_element(G.hand.cards, pseudoseed("ObsidianOrb")) --[[@as Card]]
                if forced_card then
                    forced_card.ability.forced_selection = true
                    G.hand:add_to_highlighted(forced_card)
                end
            end
        end
        if blind_proto.name == "Crimson Heart" and G.GAME.blind.prepped and G.jokers.cards[1] then
            local jokers = {}
            for i = 1, #G.jokers.cards do
                if not G.jokers.cards[i].debuff or #G.jokers.cards < 2 then
                    table.insert(jokers, G.jokers.cards[i])
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

-- Run the `stay_flipped` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@return true|nil
function Spectrallib.stay_flipped_copied_blinds(blind_keys, copying_blind, area, card, from_area)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.stay_flipped and blind_proto:stay_flipped(area, card, from_area) then
            return true
        end
        if area == G.hand then
            if
                blind_proto.name == "The Wheel"
                -- todo: not sure if first arg should be copying_blind,
                -- previously it was `self` (SMODS.Blind) in Obsidian Orb (Cryptid)'s `stay_flipped`
                and SMODS.pseudorandom_probability(copying_blind, 'wheel', 1, 7)
            then
                return true
            end
            if
                blind_proto.name == "The House"
                and G.GAME.current_round.hands_played == 0
                and G.GAME.current_round.discards_used == 0
            then
                return true
            end
            if blind_proto.name == "The Mark" and card:is_face(true) then
                return true
            end
            if blind_proto.name == "The Fish" and G.GAME.blind.prepped then
                return true
            end
        end
    end
end

-- Run the `recalc_debuff` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param card Card
---@param from_blind boolean
---@return true|nil
function Spectrallib.recalc_debuff_copied_blinds(blind_keys, copying_blind, card, from_blind)
    if not (type(card) == "table" and card.area) then return end

	for blind_proto in blinditer(blind_keys) do
        if blind_proto.debuff_card then
            blind_proto:debuff_card(card, from_blind)
        end
        if blind_proto.recalc_debuff then
            return blind_proto:recalc_debuff(card, from_blind)
        end
        if blind_proto.debuff and not G.GAME.blind.disabled and card.area ~= G.jokers then
            --this part is buggy for some reason
            if blind_proto.debuff.suit and Card.is_suit(card, blind_proto.debuff.suit, true) then
                card:set_debuff(true)
                return true
            end
            if blind_proto.debuff.is_face == "face" and Card.is_face(card, true) then
                card:set_debuff(true)
                return true
            end
            if blind_proto.name == "The Pillar" and card.ability.played_this_ante then
                card:set_debuff(true)
                return true
            end
            if blind_proto.debuff.value and blind_proto.debuff.value == card.base.value then
                card:set_debuff(true)
                return true
            end
            if blind_proto.debuff.nominal and blind_proto.debuff.nominal == card.base.nominal then
                card:set_debuff(true)
                return true
            end
        end
        if blind_proto.name == "Crimson Heart" and not G.GAME.blind.disabled and card.area == G.jokers then
            return
        end
        if blind_proto.name == "Verdant Leaf" and not G.GAME.blind.disabled and card.area ~= G.jokers then
            card:set_debuff(true)
            return true
        end
    end
end

-- Run the `before_play` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@return nil
function Spectrallib.before_play_copied_blinds(blind_keys, copying_blind)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.before_play then
            blind_proto:before_play()
        end
        if blind_proto.cry_before_play then --back_compat
            blind_proto:cry_before_play()
        end
    end
end

-- Run the `after_play` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@return nil
function Spectrallib.after_play_copied_blinds(blind_keys, copying_blind)
	for blind_proto in blinditer(blind_keys) do
        if blind_proto.after_play then
            blind_proto:after_play()
        end
        if blind_proto.cry_after_play then --back_compat
            blind_proto:cry_after_play()
        end
    end
end

-- Run the `ante_base_mod` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param dt number
---@return number[]
function Spectrallib.ante_base_mod_copied_blinds(blind_keys, copying_blind, dt)
    local mods = {}
	for blind_proto in blinditer(blind_keys) do
        if type(blind_proto.ante_base_mod) == "function" then
            table.insert(mods, blind_proto:ante_base_mod(dt))
		end
    end
    return mods
end

-- Run the `round_base_mod` method on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param dt number
---@return number[]
function Spectrallib.round_base_mod_copied_blinds(blind_keys, copying_blind, dt)
    local mods = {}
	for blind_proto in blinditer(blind_keys) do
        if type(blind_proto.round_base_mod) == "function" then
			table.insert(mods, blind_proto:round_base_mod(dt))
		end
    end
    return mods
end

-- Run the `modify_score` and `cap_score` methods on a list of copied blinds.
---@param blind_keys string[] List of blind keys.
---@param copying_blind Blind The blind that is copying other blinds.
---@param score number
function Spectrallib.cap_final_score_copied_blinds(blind_keys, copying_blind, score)
	for blind_proto in blinditer(blind_keys) do
        if type(blind_proto.modify_score) == "function" then
			score = blind_proto:modify_score(score)
		end
        if type(blind_proto.cap_score) == "function" then
			score = blind_proto:cap_score(score)
		end
    end
    return score
end

--#endregion
-----------------------------------

-------------------------------
--#region COPIED BLIND HOOKS --
-------------------------------

local set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent, ...)
    self.only_hand = nil
    local ret = set_blind_ref(self, blind, reset, silent, ...)
    Spectrallib.set_copied_blinds(Spectrallib.get_copied_blinds(self), self, silent, reset)
    return ret
end

local defeat_blind_ref = Blind.defeat
function Blind:defeat(silent, ...)
    local ret = defeat_blind_ref(self, silent, ...)
    Spectrallib.defeat_copied_blinds(Spectrallib.get_copied_blinds(self), self, silent)
    return ret
end

local press_play_ref = Blind.press_play
function Blind:press_play(...)
    local ret = press_play_ref(self, ...)
    Spectrallib.press_play_copied_blinds(Spectrallib.get_copied_blinds(self), self)
    return ret
end

local calculate_ref = Blind.calculate
function Blind:calculate(context, ...)
    local ret = calculate_ref(self, context, ...)
    local ret2 = Spectrallib.calculate_copied_blinds(Spectrallib.get_copied_blinds(self), self, context)
    return ret or ret2
end

local modify_hand_ref = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips, ...)
    local mult, chips, trigger = modify_hand_ref(self, cards, poker_hands, text, mult, hand_chips, ...)
    mult, chips, trigger = Spectrallib.modify_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, cards, poker_hands, text, mult, chips, trigger)
    return mult, chips, trigger
end

local debuff_hand_ref = Blind.debuff_hand
function Blind:debuff_hand(...)
    return debuff_hand_ref(self, ...) or Spectrallib.debuff_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, ...)
end

local drawn_to_hand_ref = Blind.drawn_to_hand
function Blind:drawn_to_hand(...)
    local ret = drawn_to_hand_ref(self, ...)
    Spectrallib.drawn_to_hand_copied_blinds(Spectrallib.get_copied_blinds(self), self, ...)
    return ret
end

local stay_flipped_ref = Blind.stay_flipped
function Blind:stay_flipped(...)
    return stay_flipped_ref(self, ...) or Spectrallib.stay_flipped_copied_blinds(Spectrallib.get_copied_blinds(self), self, ...)
end

local recalc_debuff_ref = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
    recalc_debuff_ref(self, card, from_blind)
    if Spectrallib.recalc_debuff_copied_blinds(Spectrallib.get_copied_blinds(self), self, card, from_blind) then
        card:set_debuff(true)
    end
end

--#endregion
-------------------------------

----------------------------
--#region COPIED BLIND UI --
----------------------------

function _G.info_queue_copied(key)
    local width = 6
    local desc_nodes = {}
    local vars = G.P_BLINDS[key].loc_vars and G.P_BLINDS[key]:loc_vars(G.GAME.blind) or {vars = {}}
    localize{type = 'descriptions', key = key, set = "Blind", nodes = desc_nodes, vars = vars.vars}
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

Spectrallib.max_blind_infoqueues = 5
local blind_hoverref = Blind.hover
function Blind:hover()
    local copied_blinds = Spectrallib.get_copied_blinds(self)
    if (
        (not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch)
        and not self.hovering
        and self.states.visible
        and self.children.animatedSprite.states.visible
        and next(copied_blinds)
    ) then
        G.blind_info_queue = UIBox{
            definition = create_UIBox_blind_info_queue(self),
            config = {
                major = self,
                parent = nil,
                offset = {
                    x = 0.15,
                    y = 0.2 + 0.38*math.min(#copied_blinds, Spectrallib.max_blind_infoqueues),
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

--#endregion
----------------------------