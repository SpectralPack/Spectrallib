-------------------------------
--#region INTERNAL UTILITIES --
-------------------------------

---- TABLE MANIP ----

-- Generates a table that contains values fulfilling a certain condition.
---@param tbl any[]
---@param condition_func fun(value: any, i: integer): boolean
---@return any[]
function Spectrallib.filter_table(tbl, condition_func)
    local ret = {}
    for i, value in ipairs(tbl) do
        if condition_func(value, i) then
            table.insert(ret, value)
        end
    end
    return ret
end

-- Checks if a value is contained in a table;<br>
-- returns the index of said item if inside table.
---@param tbl any[]
---@param find_val any|(fun(val: any): boolean) If this is a function, the function checks each individual item in the table.
---@return integer|nil
function Spectrallib.in_table(tbl, find_val)
    for i, value in ipairs(tbl) do
        if (
            type(find_val) == "function"
            and find_val(value)
            or value == find_val
        ) then
            return i
        end
    end
end

-- Get a random element from a table, with the option to blacklist certain values.
---@param tbl table
---@param seed string|any
---@param blacklist fun(elem: any): (boolean|any) If truthy, element is excluded.
---@return any
function Spectrallib.pseudorandom_element(tbl, seed, blacklist)
    local elem = pseudorandom_element(tbl, seed)
    local tries = 0
    while blacklist(elem) and tries < 100 do
        elem = pseudorandom_element(tbl, seed)
        tries = tries + 1
    end
    return elem
end

-- Inserts a dollar sign onto the given value;<br>
-- it is placed to the right of the negative sign, if present.
---@param val number
---@return string
function Spectrallib.format_dollar_value(val)
    if val >= 0 then
        return localize("$")..val
    else
        return "-"..localize("$")..(-val)
    end
end

---- STRING/FORMATTING ----

-- Formats hyperoperators.
---@param arrows integer|string
---| -2               # Operator set to =
---| -1               # Operator set to +
---| "addition"       # Operator set to +
---| 0                # Operator set to X
---| "multiplication" # Operator set to X
---| 1                # From 1-6, operator set to ^ (repeats `arrow` times)
---| "exponent"       # Operator set to ^
---| 7                # From 7 and higher or -3 and lower, operator set to {`arrow`}
---@param mult number|string
---@return string
function Spectrallib.format_arrow_mult(arrows, mult)
    if arrows == "addition" then arrows = -1 end
    if arrows == "multiply" then arrows = 0 end
    if arrows == "exponent" then arrows = 1 end
    if type(arrows) == "string" then arrows = 0 end
    mult = type(mult) ~= "string" and number_format(mult) or mult

    local operator = ("{%s}"):format(arrows)
    if arrows == -2 then
        operator = "="
    elseif arrows == -1 then
        operator = "+"
    elseif arrows == 0 then
        operator = "X"
    elseif 1 <= arrows or arrows <= 6 then
        operator = ("^"):rep(arrows)
    end

    return operator .. mult
end
-- alias lemniscate used for this function
Spectrallib.format_arrow_value = Spectrallib.format_arrow_mult

-- Split a string into its characters.
---@param s string
---@return string[]
function Spectrallib.stringsplit(str)
    local tbl = {}
    for i = 1, #str do
        table.insert(tbl, str:sub(i,i))
    end
    return tbl
end

-- Generates a `length`-long string of random characters.
---@param length integer
---@param charset? string
---@return string
function Spectrallib.string_random(length, charset)
    charset = charset or Spectrallib.charset
    local total = ""
    for _ = 0, length do
        local val = math.random(1, #charset)
        total = total .. charset:sub(val, val)
    end
    return total
end

---- MATH ----

-- Calculate the Euclidean distance between two points.
---@param a [number, number]
---@param b [number, number]
---@return number
function Spectrallib.pythag(a, b)
    local a_X, a_Y = a[1], a[2]
    local b_X, b_Y = b[1], b[2]
    local x = a_X - b_X
    local y = a_Y - b_Y
    return math.sqrt((x^2) + (y^2))
end

-- Approximates a repeated application of the log function.
---@param orig number
---@param base number The base of the log function.
---@param iter integer The number of times to apply the log function.
---@return number
function Spectrallib.approximate_log_recursion(orig, base, iter)
    if iter < 1000 then
        if orig < base then return orig end
        local result = orig
        for _ = 1, to_number(iter) do
            result = result * math.log(result, base)
        end
        return result
    else
        local m = iter/math.log(base)
        local l1 = math.log(m)
        local l2 = math.log(l1)
        local E = iter * (l1 + l2 - 1 + ((l2-2)/l1))
        local result = 2.718281846 ^ E
        return result
    end
end

--#endregion
-------------------------------


------------------------------
--#region CARD MODIFICATION --
------------------------------

---- INVOLVES CARDS DIRECTLY ----

---@alias Spectrallib.flip_then.func fun(card: Card, cardlist: Card[], i: integer): any

-- Double-flips cards in the provided list, and also run functions before, during, and after double-flipping.
---@param cardlist IterableCardList[]
---@param func? {func: Spectrallib.flip_then.func, delay: number}[] | Spectrallib.flip_then.func The functions to run on a card between flips.
---@param before? fun(card: Card): any The function to run on a card before flipping once.
---@param after? fun(card: Card): any The function to run on a card after flipping again.
---@return nil
function Spectrallib.flip_then(cardlist, func, before, after)
    local skip_animations = Spectrallib.should_skip_animations()
    if type(func) ~= "table" then
        func = { {func = func, delay = 0.5} }
    end

    for _,card in Spectrallib.iter.areacards(cardlist) do
        Spectrallib.event {
            function ()
                if before then before(card) end
                if not skip_animations then card:flip() end
                return true
            end,
            delay = 0.4,
            instant = skip_animations
        }
    end
    for _,card in Spectrallib.iter.areacards(cardlist) do
        for i, func_def in ipairs(func) do
            Spectrallib.event {
                function ()
                    func_def.func(card, cardlist, i)
                    return true
                end,
                delay = func_def.delay
            }
        end
    end
    for _,card in Spectrallib.iter.areacards(cardlist) do
        Spectrallib.event {
            function ()
                if not skip_animations then card:flip() end
                if after then after(card) end
                return true
            end,
            delay = 0.4,
            instant = skip_animations
        }
    end
end

-- Randomize a card's rank and/or suit.
---@param card Card
---@param randomize_rank? boolean If true, randomize rank.
---@param randomize_suit? boolean If true, randomize suit.
---@param seed string|any
---@return nil
function Spectrallib.randomize_rank_suit(card, randomize_rank, randomize_suit, seed)
    local ranks = {}
    local suits = {}
    if randomize_rank then
        for rank_key, rank in pairs(SMODS.Ranks) do
            if SMODS.add_to_pool(rank, {}) then table.insert(ranks, rank_key) end
        end
    end
    if randomize_suit then
        for suit_key, suit in pairs(SMODS.Suits) do
            if SMODS.add_to_pool(suit, {}) then table.insert(suits, suit_key) end
        end
    end
    local select_rank = pseudorandom_element(ranks, pseudoseed(seed))
    local select_suit = pseudorandom_element(suits, pseudoseed(seed))
    SMODS.change_base(card, select_suit, select_rank, nil)
end

-- Convert a card or set of cards into the card(s) previous to it, with the order being based on the Collection.
---@param cards Card|Card[]
---@param from_card Card The card causing the conversion.
---@return nil
function Spectrallib.reduce_cards(cards, from_card)
    if cards.ability then cards = {cards} end
    Spectrallib.flip_then(cards, function(cardd)
        local ind = Spectrallib.reduction_index(cardd, cardd.config.center.set, true)
        if G.P_CENTER_POOLS.Joker[ind] then
            cardd:set_ability(G.P_CENTER_POOLS.Joker[ind])
        end
        cardd.area:remove_from_highlighted(from_card)
    end)
end

-- Create a dummy card that has the methods of a regular card without its on-field existence.
---@param center SMODS.Center The prototype of the card.
---@param area CardArea
---@param from_card Card The card that creates the dummy card.
---@param silent boolean If true, ??? todo: figure this out
---@return table
function Spectrallib.get_dummy(center, area, from_card, silent)
    local abil = copy_table(center.config) or {}
    abil.consumeable = copy_table(abil)
    abil.name = center.name or center.key
    abil.set = center.set
    abil.t_mult = abil.t_mult or 0
    abil.t_chips = abil.t_chips or 0
    abil.x_mult = abil.x_mult or abil.Xmult or 1
    abil.extra_value = abil.extra_value or 0
    abil.d_size = abil.d_size or 0
    abil.mult = abil.mult or 0
    abil.effect = center.effect
    abil.h_size = abil.h_size or 0
    abil.card_limit = abil.card_limit or 1
    abil.extra_slots_used = abil.extra_slots_used or 0

    local eligible_editionless_jokers = {}
    for _,joker in Spectrallib.iter.areacards(G.jokers) do
        if not joker.edition then
            eligible_editionless_jokers[#eligible_editionless_jokers + 1] = joker
        end
    end

    local tbl = {
        ability = abil,
        config = {
            center = center,
            center_key = center.key
        },
        juice_up = function(_, ...)
            return from_card:juice_up(...)
        end,
        start_dissolve = function(_, ...)
            if not _.silent then
                return from_card:start_dissolve(...)
            end
        end,
        remove = function(_, ...)
            return from_card:remove(...)
        end,
        flip = function(_, ...)
            return from_card:flip(...)
        end,
        can_use_consumeable = function(self, ...)
            return Card.can_use_consumeable(self, ...)
        end,
        calculate_joker = function(self, ...)
            return Card.calculate_joker(self, ...)
        end,
        can_calculate = function(self, ...)
            return Card.can_calculate(self, ...)
        end,
        set_cost = function(self, ...)
            Card.set_cost(self, ...)
        end,
        calculate_sticker = function(self, ...)
            Card.calculate_sticker(self, ...)
        end,
        base_cost = 1,
        extra_cost = 0,
        original_card = from_card,
        area = area,
        added_to_deck = added_to_deck, -- undefined
        cost = from_card.cost,
        sell_cost = from_card.sell_cost,
        eligible_strength_jokers = eligible_editionless_jokers,
        eligible_editionless_jokers = eligible_editionless_jokers,
        T = from_card.T,
        VT = from_card.VT,
        CT = from_card.CT,
        silent = silent
    }

    for key, method in pairs(Card --[[@as table]]) do
        if type(method) == "function" and key ~= "flip_side" then
            tbl[key] = function(_, ...)
                return method(from_card, ...)
            end
        end
    end
    tbl.set_edition = function(s, ed, ...)
        Card.set_edition(s, ed, ...)
    end
    tbl.get_chip_h_x_mult = function(s, ...)
        local ret = SMODS.multiplicative_stacking(s.ability.h_x_mult or 1,
            (not s.ability.extra_enhancement and s.ability.perma_h_x_mult) or 0)
        return ret
    end
    tbl.get_chip_x_mult = function(s, ...)
        local ret = SMODS.multiplicative_stacking(s.ability.x_mult or 1,
            (not s.ability.extra_enhancement and s.ability.perma_x_mult) or 0)
        return ret
    end
    tbl.use_consumeable = function(self, ...)
        self.bypass_echo = true
        local ret = Card.use_consumeable(self, ...)
        self.bypass_echo = nil
    end

    return tbl
end

-- Hook required by dummy cards to direct eval text to card that created them
local card_eval_status_text_ref = card_eval_status_text
function card_eval_status_text(card, ...)
    return card_eval_status_text_ref(card.original_card or card, ...)
end

---- INVOLVES CARD MODIFIERS ----

---@class Spectrallib.modify_hand_card.modifications
---@field suit? Suits|string
---@field rank? Ranks|string
---@field enhancement? string
---@field edition? string|table
---@field seal? string
---@field sticker? string
---@field extra? { [string]: any } Keys are keys in the card's ability table; values are values assigned to said keys.

-- Generates a function that modifies a list of cards according to given specifications.
---@param modifications Spectrallib.modify_hand_card.modifications
---@param cards Card[]
---@param dont_flip? boolean If true, cards will not be flipped on modification.
---@return fun(self: any, card: Card): nil
function Spectrallib.modify_hand_card(modifications, cards, dont_flip)
    local func = function(mcard)
        if modifications.suit or modifications.rank then
            SMODS.change_base(mcard, modifications.suit, modifications.rank)
        end
        if modifications.enhancement then
            mcard:set_ability(G.P_CENTERS[modifications.enhancement])
        end
        if modifications.edition then
            if type(modifications.edition) == "table" then
                mcard:set_edition(modifications.edition)
            else
                mcard:set_edition(G.P_CENTERS[modifications.edition])
            end
        end
        if modifications.seal then
            mcard:set_seal(modifications.seal)
        end
        if modifications.sticker then
            Spectrallib.apply_sticker(mcard, modifications.sticker)
        end
        if modifications.extra then
            for extra_key, value in pairs(modifications.extra) do
                mcard.ability[extra_key] = value
            end
        end
    end

    return function(self, card)
        local cardlist = cards or Spectrallib.get_highlighted_cards({G.hand}, {}, 1, card.ability.highlighted or 1)
        if not dont_flip then
            Spectrallib.flip_then(cardlist, func)
        else
            for _, mcard in pairs(cardlist) do
                G.E_MANAGER:add_event(Event({
                    delay = 0,
                    func = function()
                        func(mcard)
                        return true
                    end
                }))
            end
        end
    end
end

-- Generates a function that modifies a list of cards according to given specifications.<br>
-- Cards will not be flipped on modification.
---@param modifications Spectrallib.modify_hand_card.modifications
---@param cards Card[]
---@return fun(self: any, card: Card): nil
function Spectrallib.modify_hand_card_NF(modifications, cards)
    return Spectrallib.modify_hand_card(modifications, cards, true)
end

-- Change the enhancement of all cards in the provided card areas.
---@param areas CardArea[]|Card[]
---@param enhancement_key string Key of the enhancement to transform into.
---|"null" Destroy all cards that meet requirements.
---|"ccd" Do completely nothing.
---@param required? string Key of the enhancement of cards to transform. If nil, all cards will be transformed.
---@return nil
function Spectrallib.change_enhancements(areas, enhancement_key, required)
    for card in Spectrallib.iter.areacards(areas) do
        if not required or (card.config and card.config.center.key == required) then
            if enhancement_key == "null" then
                card:start_dissolve()
            elseif enhancement_key == "ccd" then
                -- Do nothing
            else
                card:set_ability(G.P_CENTERS[enhancement_key])
                card:juice_up()
            end
        end
    end
end

---@param card Card
---@param sticker_key string
---@return nil
function Spectrallib.apply_sticker(card, sticker_key)
    local sticker = SMODS.Stickers[sticker_key]
    if not sticker then return end
    if not card.ability then card.ability = {} end

    card.ability[sticker_key] = true
    if sticker.apply then
        sticker.apply(sticker, card)
    end
end

-- Randomize a random aspect of a playing card.
---@param card Card
---@param types? ("Enhancement"|"Edition"|"Seal"|"Base")[]
---@param seed? string|any
---@param noflip? boolean
---@return nil
function Spectrallib.randomise_once(card, types, seed, noflip)
    types = types or {"Enhancement", "Edition", "Seal", "Base"}
    seed = seed or "ihwaz"
    local mtype = pseudorandom_element(types, pseudoseed(seed))

    -- Non-flip modifying
    if mtype == "Seal" then
        local seal = SMODS.poll_seal{guaranteed = true, key = seed}
        card:set_seal(seal)
        card:juice_up()
        return
    elseif mtype == "Edition" then
        local edition = SMODS.poll_edition({guaranteed = true, key = seed})
        card:set_edition(edition)
        card:juice_up()
        return
    end

    -- Flipping modifying

    if not noflip then card:flip() end

    if mtype == "Enhancement" then
        local enhancement = SMODS.poll_enhancement({guaranteed = true, key = seed})
        card:set_ability(G.P_CENTERS[enhancement])
    elseif mtype == "Base" then
        Spectrallib.randomize_rank_suit(card, true, true, seed)
    end

    if not noflip then card:flip() end
end

--#endregion

-------------------------------
--#region FIELD MODIFICATION --
-------------------------------

---@param mod number Added to current play limit.
---@param stroverride? string The label to display for the play limit.
---@return nil
function Spectrallib.change_play_limit_no_bs(mod,stroverride)
    if SMODS.hand_limit_strings then
        G.GAME.starting_params.play_limit = (G.GAME.starting_params.play_limit or 5) + mod
        G.hand.config.highlighted_limit = math.max(G.GAME.starting_params.discard_limit or 5, G.GAME.starting_params.play_limit or 5)
        local str = stroverride or G.GAME.starting_params.play_limit or ""
        SMODS.hand_limit_strings.play = G.GAME.starting_params.play_limit ~= 5 and localize('b_limit') .. str  or ''
    else
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + mod
    end
end

---@param mod number Added to current play limit.
---@param stroverride? string The label to display for the discard limit.
---@return nil
function Spectrallib.change_discard_limit_no_bs(mod,stroverride)
    G.GAME.starting_params.discard_limit = (G.GAME.starting_params.discard_limit or 5) + mod
    G.hand.config.highlighted_limit = math.max(G.GAME.starting_params.discard_limit or 5, G.GAME.starting_params.play_limit or 5)
    local str = stroverride or G.GAME.starting_params.discard_limit or ""
    SMODS.hand_limit_strings.discard = G.GAME.starting_params.discard_limit ~= 5 and localize('b_limit') .. str or ''
end

---@param mod number Added to current play limit.
---@param stroverride? string The label to display for the play and discard limit.
---@return nil
function Spectrallib.change_selection_limit(mod,stroverride)
    if not SMODS.hand_limit_strings then SMODS.hand_limit_strings = {} end
    Spectrallib.change_play_limit_no_bs(mod,stroverride)
    if SMODS.hand_limit_strings then
        Spectrallib.change_discard_limit_no_bs( mod,stroverride)
    end
end

-- Unhighlight all cards in the provided card areas.
---@param areas CardArea[]
---@return nil
function Spectrallib.unhighlight(areas) 
    for _, area in pairs(areas) do
        area:unhighlight_all()
    end
end

-- Wrapper for CardArea:handle_card_limit; sets the card limit of an area.
---@param area CardArea
---@param num? number
---@return nil
function Spectrallib.handle_card_limit(area, num)
    area.config.card_limit = area.config.card_limit + (num or 0)
    area:handle_card_limit()
end

--#endregion

------------------------
--#region CALCULATION --
------------------------

-- Forcetrigger a random card.
---@param source_card Card The card causing the forcetriggering.
---@param count integer
---@param context table
---@return nil
function Spectrallib.random_forcetrigger(source_card, count, context)
    local searched_areas = {G.jokers, G.hand, G.consumeables, G.play}
    local random_condition = function(cardd)
        return not cardd.edition or cardd.edition.key ~= "e_entr_fractured"
    end
    local cards = Spectrallib.get_random_cards(searched_areas, count, "fractured", random_condition)

    for _, card in pairs(cards) do
        if card.base.id and (not card.edition or card.edition.key ~= "e_entr_fractured") then
            for _,area in ipairs({G.play, G.hand}) do
                local results = eval_card(card, {cardarea=area, main_scoring=true, forcetrigger=true, individual=true})
                for _, result_group in pairs(results or {}) do
                    if type(result_group) == "table" then
                        for effect_key, result in pairs(result_group) do
                            SMODS.calculate_individual_effect({[effect_key] = result}, source_card, effect_key, result, false)
                        end
                    end
                end
            end
            card_eval_status_text( card,"extra", nil, nil, nil, { message = localize("cry_demicolon"), colour = G.C.GREEN })
        elseif not card.edition or card.edition.key ~= "e_entr_fractured" then
            Spectrallib.forcetrigger({card = card, context = context, mesasge_card = source_card})
        end
    end
end

-- Give a random context key.
---@param seed? string|any
---@return "before"|"pre_joker"|"joker_main"|"individual"|"pre_discard"|"remove_playing_cards"|"setting_blind"|"ending_shop"|"reroll_shop"|"selling_card"|"using_consumeable"|"playing_card_added"
---@return any
function Spectrallib.random_context(seed)
    --Is this useful? idk but its entropy agnostic so :shrug:
    return pseudorandom_element({
        "before",
        "pre_joker",
        "joker_main",
        "individual",
        "pre_discard",
        "remove_playing_cards",
        "setting_blind",
        "ending_shop",
        "reroll_shop",
        "selling_card",
        "using_consumeable",
        "playing_card_added"
    }, pseudoseed(seed or "desync"))
end

-- A shorthand for various context checks.
---@param self any
---@param card Card
---@param context table
---@param currc string
---@param edition boolean|any
---@return boolean|nil
function Spectrallib.context_checks(self, card, context, currc, edition)
    if (
        context.retrigger_joker
        or context.blueprint
        or context.forcetrigger
        or context.post_trigger
    ) then return end

    local context_check = Spectrallib.context_check_def[currc]
    if not context_check then
        return
    elseif type(context_check) == "function" and context_check(card, context, currc, edition) then
        return true
    elseif context_check == true then
        return true
    end
end

-- Get the number of times that the given card will repeat.
---@param card Card
---@return {repetitions: integer}
function Spectrallib.get_repetitions(card)
    local res2 = {}
    for _, joker in ipairs(G.jokers.cards) do
        local res = eval_card(joker, {
            repetition = true,
            other_card = card,
            cardarea = card.area,
            card_effects = {{},{}}
        }) or {}
        if res.jokers and res.jokers.repetitions then
            res2.repetitions = (res2.repetitions or 0) + res.jokers.repetitions
        end
    end
    return res2
end

--#endregion

---------------------------
--#region BOOLEAN/CHECKS --
---------------------------

-- Check if an item can appear in shop.
---@param key string
---@param consumable boolean If true, consumable probabilities will be checked.
---@return true|nil
function Spectrallib.is_in_shop(key, consumable)
	local center = G.P_CENTERS[key]
    if (
        center.hidden
        or center.no_doe
        or center.no_collection
        or G.GAME.banned_keys[key]
        or not center.unlocked
    ) then
		return
	elseif center.set == "Joker" then
		if center.rarity == 1 or center.rarity == 2 or center.rarity == 3 then
			return center.unlocked or nil
		end
        local rarity_proto = SMODS.Rarities[center.rarity]
        if not rarity_proto then return nil end

		if (
            rarity_proto.get_weight
            or (rarity_proto.default_weight or 0) > 0
        )
		then return center.unlocked or nil end

		return nil
	elseif consumable then
        local set_rate_key = center.set:lower()
        local set_rate = G.GAME[set_rate_key .. "_rate"]
        local percrate_rate = G.GAME.cry_percrate and G.GAME.cry_percrate[set_rate_key] or 1
        return set_rate > 0 and percrate_rate > 0 or nil
    end
	return SMODS.add_to_pool(center, {})
end

-- An extension of SMODS.has_no_suit that checks for additional modded properties.
---@param card Card
---@return boolean
function Spectrallib.true_suitless(card)
    return (
        SMODS.has_no_suit(card)
        or card.config.center.key == "m_stone"
        or card.config.center.overrides_base_rank
        or card.base.suit == "entr_nilsuit"
        or card.base.value == "entr_nilrank"
    )
end

-- Check if a center can spawn;<br>
-- it will not, if a card object with it as its center exists in the game space (and Showman is not held).
---@param center SMODS.Center
---@return boolean|nil
function Spectrallib.allow_spawning(center)
    if not center then return end
    for _, card in pairs(G.I.CARD) do
        if (
            card.config
            and card.config.center
            and card.config.center.key == center.key
        ) then return SMODS.showman(center.key) or nil end
    end
    return true
end

-- Determine if animations should be skipped.
---@param strict? boolean If true, Handy animation skip value must be at least 4 ("skip everything") (instead of 3 ("skip animations")).
---@return boolean
function Spectrallib.should_skip_animations(strict)
    local talisman_check = Talisman and Talisman.config_file.disable_anims
    if talisman_check then return true end

    local handy_check = Spectrallib.safe_get(Handy, "animation_skip", "get_value")
    if type(handy_check) == "function" then
        -- 4 = "Skip everything"
        -- 3 = "Skip animations"
        handy_check = handy_check() >= (strict and 4 or 3)
    else
        handy_check = nil
    end
    if handy_check then return true end
    return false
end

-- Returns true if the two input cards share the same rank, center, edition, or seal.
---@param card1 Card
---@param card2 Card
---@return true|nil
function Spectrallib.shares_aspect(card1, card2)
    if card1:get_id() == card2:get_id() then return true end

    if (
        card1.config.center.set ~= "Default"
        and card1.config.center.key == card2.config.center.key
    ) then return true end

    if (
        card1.edition and card2.edition
        and card1.edition.key == card2.edition.key
    ) then return true end

    if (
        card1.seal
        and card1.seal == card2.seal
    ) then return true end
end

--#endregion

---------------------------
--#region DATA REFERENCE --
---------------------------

-- Get the index of the center previous to the input `card`, with the order based on the selected `pool`.
---@param card Card
---@param pool string Index of G.P_CENTER_POOLS
---@param strict? boolean If true, the card considered "previous" must actually be able to appear in gameplay.
---@return integer
function Spectrallib.reduction_index(card, pool, strict)
    local i = 0
    for x, v in pairs(G.P_CENTER_POOLS[pool]) do
        if card.config and v.key == card.config.center_key then
            i = x - 1 -- previous
            break
        end
    end
    if strict then
        while (
            G.P_CENTER_POOLS[pool]
            and G.P_CENTER_POOLS[pool][i]
            and (
                G.P_CENTER_POOLS[pool][i].no_doe
                or G.P_CENTER_POOLS[pool][i].no_collection
            )
        )
        do i = i - 1 end
    end
    if i < 1 then i = 1 end
    return i
end

-- Get the previous item in a pool before a given item.
---@param item_key string Key of the item to check predecessor of.
---@param pool_name string
---@param ignore? integer When iterating through the pool, this value corresponds to the index to ignore.
---@return string|nil
function Spectrallib.find_previous_in_pool(item_key, pool_name, ignore)
    local select_pool = G.P_CENTER_POOLS[pool_name]
    for i in pairs(select_pool) do
        if select_pool[i].key == item_key then
            local ind = i - 1
            while (
                G.GAME.banned_keys[select_pool[ind].key]
                or select_pool[ind].no_doe
                or ind == ignore
            ) do
                ind = ind - 1
            end
            return select_pool[ind].key
        end
    end
    return nil
end

-- Get the key of the higher tier of a voucher, if it has higher tiers.
---@param voucher_key string
---@return string|nil
function Spectrallib.get_higher_voucher_tier(voucher_key)
    for _, voucher in pairs(G.P_CENTER_POOLS.Voucher) do
        if Spectrallib.in_table(voucher.requires or {}, voucher_key) then
            return voucher.key
        end
    end
end

-- Counts how many times a deck's effect is applied to the run.
---@param key string
---@return integer|nil
function Spectrallib.deck_or_sleeve(key)
    local num = 0
    if key == "doc" and G.GAME.modifiers.doc_antimatter then
        num = num + 1
    elseif key == "butterfly" and G.GAME.modifiers.butterfly_antimatter then
        num = num + 1
    end

    if Spectrallib.can_mods_load({"CardSleeves"}) and (
        G.GAME.selected_sleeve == ("sleeve_entr_"..key)
        or G.GAME.selected_sleeve == key
        or G.GAME.selected_sleeve == "sleeve_"..key
    ) then
        num = num + 1
    end

    for _, bought_deck_key in pairs(G.GAME.entr_bought_decks or {}) do
        if (
            bought_deck_key == "b_entr_"..key
            or bought_deck_key == key
            or bought_deck_key == "b_"..key
            or bought_deck_key == "sleeve_"..key)
        then
            num = num + 1
        end
    end

    if G.GAME.selected_back and (
        G.GAME.selected_back.effect.center.original_key == key
        or G.GAME.selected_back.effect.center.key == key
        or G.GAME.selected_back.effect.center.original_key == "b_"..key
        or G.GAME.selected_back.effect.center.key == "b_"..key
    ) then
        num = num + 1
    end

    return num > 0 and num or nil
end

-- Get the key of a card area in `G`.
---@param area CardArea
---@return string|nil
function Spectrallib.get_area_name(area) 
    if not area then return nil end
    for i, v in pairs(G) do
        if v == area then return i end
    end
end

-- Get the index of a card in its area.
---@param card Card
---@return integer|nil
function Spectrallib.get_idx_in_area(card)
    if not card then return end
    if card.rank then return card.rank end
    if card.area then
        for i, v in pairs(card.area.cards) do
            if v == card then return i end
        end
    end
end

---@param suit string
---@return string
function Spectrallib.get_inverse_suit(suit)
    return ({
        Diamonds = "Hearts",
        Hearts = "Diamonds",
        Clubs = "Spades",
        Spades = "Clubs"
    })[suit] or suit
end

---@param rank string
---@return string
function Spectrallib.get_inverse_rank(rank)
    return ({
        ["2"]  = "Ace",
        ["3"]  = "King",
        ["4"]  = "Queen",
        ["5"]  = "Jack",
        ["6"]  = "10",
        ["7"]  = "9",
        ["8"]  = "8",
        ["9"]  = "7",
        ["10"] = "6",
        ["11"] = "5",
        ["12"] = "4",
        ["13"] = "3",
        ["14"] = "2"
    })[tostring(rank)] or rank
end

-- Count how many hands have been played more than a given amount of times.
---@param threshold number Hands are counted if played more times than this value.
---@return integer
function Spectrallib.played_hands(threshold)
    local total = 0
    for _, hand in pairs(G.GAME.hands or {}) do
        if hand.played > threshold then
            total = total + 1
        end
    end
    return total
end

-- Map a booster pack name to its corresponding item set.
---@param kind string|"Arcana"|"Celestial"|"Ethereal"|"Buffoon"|"Inverted"
---@param c? boolean If true, "Inverted" maps to "Twisted", otherwise it maps to nil.
---@return string|nil
function Spectrallib.kind_to_set(kind, c)
    local check = {
        Arcana = "Tarot",
        Celestial = "Planet",
        Ethereal = "Spectral",
        Buffoon = "Joker",
        Inverted = c and "Twisted" or nil
    }

    local kind2 = check[kind] or kind
    check.Inverted = "Twisted"
    local check2 = check[kind] or kind
    if not (
        G.P_CENTER_POOLS[kind2]
        or G.P_CENTER_POOLS[check2]
    ) then return end

    return kind2
end

---- CARD MODIFIERS ----

-- Get the higher enhancement of a card's enhancement<br>
-- (as defined by `card.upgrade_order` in enhancement prototypes).
---@param card Card
---@param bypass boolean Whether to bypass `card.no_doe` or not.
---@param blacklist string[] A list of keys of enhancements to ignore.
---@return string|nil
function Spectrallib.upgrade_enhancement(card, bypass, blacklist)
    local current_enh = card.config.center.key
    if current_enh == "c_base" then return "m_bonus" end

    local enhancements = {}
    for _,enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
        if (not enhancement.no_doe or bypass) and not blacklist[enhancement.key] then
            table.insert(enhancements, enhancement)
        end
    end

    table.sort(enhancements, function(a, b)
        return (a.upgrade_order or a.order) < (b.upgrade_order or b.order)
    end)

    for i, enhancement in pairs(enhancements) do
        if enhancement.key == current_enh then
            return enhancements[i+1] and enhancements[i+1].key
        end
    end
    return nil
end

-- Get the scoring values of a specific enhancement, as defined by this function.<br>
-- Example: Chameleon (Entropy); Intended to be hooked for additional enhancements.
---@param enh string Enhancement key.
---@param card Card
---@return { [string]: number|any }
function Spectrallib.trigger_enhancement(enh, card)
    if G.P_CENTERS[enh].demicoloncompat then
        return G.P_CENTERS[enh]:calculate(card, {forcetrigger = true})
    end
    local lucky = {}
    if SMODS.pseudorandom_probability(card, 'entr_chameleon', 1, 5) then
        lucky.mult = 20
    end
    if SMODS.pseudorandom_probability(card, 'entr_chameleon', 1, 15) then
        lucky.money = 20
    end
    local funcs = {
        m_mult = {mult = 4},
        m_bonus = {chips = 30},
        m_glass = {xmult = 2},
        m_steel = {xmult = 1.5},
        m_stone = {chips = 50},
        m_gold = {money=3},
        m_lucky = lucky
    }
    if funcs[enh] then
        return funcs[enh]
    end
end

---- RARITY ----

-- Given the rarity rank list `Spectrallib.RarityChecks`,<br>
-- get the rarity higher than the given rarity.<br>
-- If such does not exist, return the given rarity.
---@param rarity integer|string
---@return integer|string
function Spectrallib.get_next_rarity(rarity)
    if rarity == "entr_reverse_legendary" then return "cry_exotic" end
    for i, next_rarity in pairs(Spectrallib.RarityChecks) do
        if next_rarity == rarity then
            return Spectrallib.RarityChecks[i+1] or next_rarity
        end
    end
    return rarity
end

-- Given the rarity rank list `Spectrallib.RarityChecks`,<br>
-- check if a rarity is lower than another rarity.
---@param check integer|string
---@param threshold integer|string
---@param check_greater_than boolean If true, the comparison is based on greater-than (<) instead of greater-than/equal (<=).
---@return boolean
function Spectrallib.rarity_above(check, threshold, check_greater_than)
    if not Spectrallib.ReverseRarityChecks[check] then
        Spectrallib.ReverseRarityChecks[check] = 1
    end
    if not Spectrallib.ReverseRarityChecks[threshold] then
        Spectrallib.ReverseRarityChecks[threshold] = 1
    end
    if check_greater_than then
        return Spectrallib.ReverseRarityChecks[check] < Spectrallib.ReverseRarityChecks[threshold]
    else
        return Spectrallib.ReverseRarityChecks[check] <= Spectrallib.ReverseRarityChecks[threshold]
    end
end

---- RANDOM ----

-- Get a random Joker with a given rarity.
---@param rarity string|integer
---@return SMODS.Joker
function Spectrallib.get_random_rarity_card(rarity)
    if rarity == 1 then rarity = "Common" end
    if rarity == 2 then rarity = "Uncommon" end
    if rarity == 3 then rarity = "Rare" end
    local _pool, _pool_key = get_current_pool("Joker", rarity, rarity == 4, "ieros")
    local center = pseudorandom_element(_pool, pseudoseed(_pool_key))
    local it = 1 -- Resample index
    while center == 'UNAVAILABLE' do
        it = it + 1
        center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
    end
    return center
end

-- Get a random set.
---@param has_parakmi boolean If true, ???
---@return table
function Spectrallib.get_random_set(has_parakmi)
    -- todo: decouple from parakmi
    local pool = pseudorandom_element(G.P_CENTER_POOLS, pseudoseed(has_parakmi and "parakmi" or "chaos"))
    local set = pool and pool[1] and G.P_CENTERS[pool[1].key] and pool[1].set

    while (
        not set
        or Spectrallib.ParakmiBlacklist[set]
        or (not has_parakmi and Spectrallib.ChaosBlacklist[set])
    ) do
        pool = pseudorandom_element(G.P_CENTER_POOLS, pseudoseed(has_parakmi and "parakmi" or "chaos"))
        set = pool and pool[1] and G.P_CENTERS[pool[1].key] and pool[1].set
    end

    return set
end

-- Get the prototype of a random ultra-rare Spectral card.
---@param seed? string|any
---@return SMODS.Consumable
function Spectrallib.get_random_rare(seed)
    seed = seed or "entr_rare"
    local cards = {}
    for _,center in pairs(G.P_CENTERS) do
        if SMODS.add_to_pool(center, {}) and center.hidden and not center.no_doe then
            table.insert(cards, center)
        end
    end
    local select_center = pseudorandom_element(cards, pseudoseed(seed))
    return select_center
end

--#endregion

----------------------------
--#region FIELD REFERENCE --
----------------------------

-- Count the number of ranks that are not present in the total deck.
---@return integer
function Spectrallib.missing_ranks()
    local remaining_ranks = {}

    -- Collect ranks
    for _, rank in pairs(SMODS.Ranks) do
        if not (rank.original_mod or rank.mod) then
            remaining_ranks[rank.id] = true
        end
    end

    -- Strike out ranks that are being used
    for card in Spectrallib.iter.areacards(G.playing_cards) do
        remaining_ranks[card.base.id] = nil
    end

    -- `ranks` now only contains whichever ranks have not been nil'd
    local total = 0
    for _ in pairs(remaining_ranks) do
        total = total + 1
    end

    return total
end

-- Get a Joker based on its sort_id.
---@param id integer
---@return Card|nil
function Spectrallib.get_by_sortid(id)
    for _, joker in pairs(G.jokers.cards) do
        if joker.sort_id == id then
            return joker
        end
    end
end

-- Get the sum of all values in a card's ability table.
---@param card Card|{ ability: {[string]: number|table} }|table
---@return number
function Spectrallib.gather_values(card)
    local total = 0
    for ability_key, value in pairs(card.ability) do
        if (
            Spectrallib.is_number(value)
            and value > 1
            and ability_key ~= "order"
        ) then
            total = total + value
        elseif type(value) == "table" then
            total = total + Spectrallib.gather_values({ability = value})
        end
    end
    return total
end

-- Get a random set of cards from the select areas.
---@param areas CardArea[]
---@param count integer
---@param seed? string|any
---@param cond? fun(card: Card): boolean Iterated over each card; if true, the card can have a chance to be randomly selected.
---@return Card[]
function Spectrallib.get_random_cards(areas, count, seed, cond)
    local cards = {}
    for card in Spectrallib.iter.areacards(areas) do
        if not cond or cond(card) then
            table.insert(cards, card)
        end
    end

    pseudoshuffle(cards, pseudoseed(seed or "fractured"))

    local ret = {}
    for i = 1, count do
        table.insert(ret, cards[i])
    end
    return ret
end

-- Count the total number of stickers across all cards.
---@param extra_card Card May be a card that is not in `G.jokers`, `G.consumeables`, `G.hand`, `G.play`, or `G.deck`
---@return integer
function Spectrallib.count_stickers(extra_card)
    local total = 0
    local cards = {}
    local add_self = true

    for card in Spectrallib.iter.areacards({G.jokers, G.consumeables, G.hand, G.play, G.deck}) do
        table.insert(cards, card)
        if card == extra_card then
            add_self = false
        end
    end
    if add_self then
        table.insert(cards, extra_card)
    end

    for sticker_key in pairs(SMODS.Sticker.obj_table) do
        for _, card in pairs(cards) do
            if card.ability and card.ability[sticker_key] then
                total = total + 1
            end
        end
    end
    return total
end

--#endregion

---------------
--#region UI --
---------------

-- Creates a UI node containing a random character.
---@param arr string
---@return {n: G.UIT.O, config: {object: DynaText}}
function Spectrallib.randomchar(arr)
    return {
        n = G.UIT.O,
        config = {
            object = DynaText({
                string = arr,
                colours = { HEX("b1b1b1") },
                pop_in_rate = 9999999,
                silent = true,
                random_element = true,
                pop_delay = 0.1,
                scale = 0.3,
                min_cycle_time = 0,
            }),
        },
    }
end

-- Determines if a card can be pulled.
---@param card Card
---@return boolean
function Spectrallib.can_be_pulled(card)
    local center = card.config.center
    if card.ability.glitched_crown then
        center = G.P_CENTERS[card.ability.glitched_crown[card.glitched_index]]
    end

    if (
        not card:selectable_from_pack(SMODS.OPENED_BOOSTER)
        and next(SMODS.find_card("j_entr_oekrep"))
        and card.ability.consumeable
    ) then
        return not (center.hidden or center.no_select)
    end

    return (
        not (center.hidden or center.no_select)
        and (
            SMODS.ConsumableTypes[center.set]
            and SMODS.ConsumableTypes[center.set].can_be_pulled
            or center.can_be_pulled
        )
    )
end

-- Determines if a card needs a "pull" button.
---@param card Card
---@return string|boolean|any
function Spectrallib.needs_pull_button(card)
    local center = card.config.center

    local can_be_selected = not (center.hidden or center.no_select)
    local can_be_pulled = (
        SMODS.ConsumableTypes[center.set]
        and SMODS.ConsumableTypes[center.set].can_be_pulled
        or center.can_be_pulled
    )
    local pull_label = type(can_be_pulled) == string and can_be_pulled or nil

    if (
        not card:selectable_from_pack(SMODS.OPENED_BOOSTER)
        and next(SMODS.find_card("j_entr_oekrep"))
        and card.ability.consumeable
    ) then
        return can_be_selected and localize("b_select")
    end

    if can_be_selected and can_be_pulled then
        return localize(pull_label or "b_select")
    end

    for _, center_key in pairs(card.ability.glitched_crown or {}) do
        local sub_center = G.P_CENTERS[center_key]
        local sub_can_be_selected = not (sub_center.hidden or sub_center.no_select)
        local sub_can_be_pulled = (
            SMODS.ConsumableTypes[sub_center.set]
            and SMODS.ConsumableTypes[sub_center.set].can_be_pulled
            or sub_center.can_be_pulled
        )
        local sub_pull_label = type(can_be_pulled) == string and can_be_pulled or nil

        if sub_can_be_selected and sub_can_be_pulled then
            return localize(sub_pull_label or "b_select")
        end
    end
end

-- Determines if a card needs a "use" button.
---@param card Card
---@return boolean
function Spectrallib.needs_use_button(card)
    local center = card.config.center
    local center_cant_use = false

    if not (center.no_use_button or (SMODS.ConsumableTypes[center.set] and SMODS.ConsumableTypes[center.set].no_use_button)) then
        center_cant_use = true
    end

    for _,center_key in pairs(card.ability.glitched_crown or {}) do
        local subcenter = G.P_CENTERS[center_key]
        if not (subcenter.no_use_button or (SMODS.ConsumableTypes[subcenter.set] and SMODS.ConsumableTypes[subcenter.set].no_use_button)) then
            center_cant_use = true
            break
        end
    end
    return center_cant_use
end

-- Get the position of a card on the screen, with units being pixels.
---@param card Card
---@return [number, number]
function Spectrallib.get_card_pixel_pos(card)
    return {
        (G.ROOM.T.x + card.T.x + card.T.w * 0.5) * (G.TILESIZE * G.TILESCALE),
        (G.ROOM.T.y + card.T.y + card.T.h * 0.5) * (G.TILESIZE * G.TILESCALE),
    }
end

-- Calculate the length of the screen's diagonal.
---@return number
function Spectrallib.max_diagonal()
    return Spectrallib.pythag({0, 0}, {love.graphics.getWidth(), love.graphics.getHeight()})
end

--#endregion
---------------

------------------
--#region DEBUG --
------------------

-- DEBUG: Calculate the composition of Entropy Jokers grouped by rarities.
---@param incl_vanilla boolean If true, also count Vanilla Jokers.
---@param only_vanilla boolean If true, only count Vanilla Jokers.
---@return nil # Output is printed.
function Spectrallib.calculate_ratios(incl_vanilla, only_vanilla)
    local total = 0
    local rarities = {}
    for _, joker in pairs(G.P_CENTER_POOLS.Joker) do
        if (
            (
                not only_vanilla
                and (joker.original_mod or {}).id == "entr"
            ) or (
                incl_vanilla
                and not joker.original_mod
            )
        ) and not joker.no_collection then
            local rarity = joker.rarity
            total = total + 1
            rarities[rarity] = (rarities[rarity] or 0) + 1
        end
    end
    for rarity_key, rarity_count in pairs(rarities) do
        local format = "%s = %s = %s%%"
        local rarity_ratio = rarity_count/total*100
        print(format:format(rarity_key, rarity_count, rarity_ratio))
    end
    print("total: "..total)
end

--#endregion
------------------

--------------
-- UNSORTED --
--------------

-- todo: what is this for?
---@param orig? number
---@param new number
---@param etype string
---@return number
function Spectrallib.stack_eval_returns(orig, new, etype)
    local valid_keys = Spectrallib.list_to_keys({
        "Xmult", "x_mult", "Xmult_mod",
        "Xchips", "Xchip_mod", "x_asc",
        "Emult_mod", "Echip_mod"
    })

    if valid_keys[etype] then
        return (orig or 1) * new
    else
        return (orig or 0) + new
    end
end

-- todo: figure out what this does
---@param poker_hands table
---@return string|nil
function Spectrallib.no_recurse_scoring(poker_hands)
    local text, scoring_hand
	for _, hand in ipairs(G.handlist) do
		if next(poker_hands[hand]) then
			text = hand
			scoring_hand = poker_hands[hand][1]
			break
		end
	end
    return text
end

---@return boolean|nil
function Card:is_playing_card()
    if not G.deck or not self then return end
    if self.area == G.play and self.ability.consumeable then return end

    local valid_areas = {[G.hand]=true, [G.play]=true, [G.discard]=true}
    local valid_sets  = {["Default"] = true, ["Enhanced"] = true}
    if (
        valid_areas[self.area]
        and valid_sets[self.config.center.set]
    ) then
        return true
    end

    for _, card in pairs(G.playing_cards) do
        if card == self then
            return true
        end
    end

    if self.area and self.area.config.view_deck then
        return true
    end
end

-- Depreciated; please use SMODS.poll_object instead.
---@deprecated
function Spectrallib.get_pooled_center(_type, twisted, _rarity, _noparakmi, soulable, key_append)
    return SMODS.poll_object({
        type = _type,
        rarities = {_rarity},
        append = key_append
        -- "TODO: how do soul objects fit into this system?" from weights.lua
    })
    -- todo: hook SMODS.poll_object to account _noparakmi
end

-- Depreciated: Please use table.concat instead
---@deprecated
function Spectrallib.concat_strings(tbl)
    return table.concat(tbl)
end