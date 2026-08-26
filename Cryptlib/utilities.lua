-------------------------
--#region CARD METHODS --
-------------------------

---@return nil
function Card:has_stickers()
	for sticker_key in pairs(SMODS.Sticker.obj_table) do
		if self.ability[sticker_key] then
			return true
		end
	end
end

---@param seed string|any
---@return nil
function Card:remove_random_sticker(seed)
	local selectable_stickers = {}
	for sticker_key, sticker_def in pairs(SMODS.Sticker.obj_table) do
		if (
			not sticker_def.hidden
			and sticker_key ~= "cry_absolute"
			and self.ability[sticker_key]
		) then
			table.insert(selectable_stickers, sticker_key)
		end
	end

	if #selectable_stickers == 0 then return end

	local sticker = pseudorandom_element(selectable_stickers, pseudoseed(seed))
	self.ability[sticker] = nil
	if sticker == "perishable" then
		self.ability.perish_tally = nil
	end
end

---@return boolean
function Card:is_food()
	--you cant really check if vanilla jokers are in a pool because its hardcoded
	--so i have to hardcode it here too for the starfruit unlock
	local food = {
		j_gros_michel = true,
		j_egg = true,
		j_ice_cream = true,
		j_cavendish = true,
		j_turtle_bean = true,
		j_diet_cola = true,
		j_popcorn = true,
		j_ramen = true,
		j_selzer = true,
	}
	if (
		food[self.config.center.key]
		or Spectrallib.safe_get(self.config.center, "pools", "Food")
	) then
		return true
	end
	return false
end

-- Checks if the key `"no_"..m` is defined in a card's center,
-- or if the card's center's key is a key in the table `G.GAME[m]` and assigned to a truthy value.
---@param m string
---@param no_no boolean
---@return boolean|nil
function Card:no(m, no_no)
	if no_no then
		return self.config.center[m] or Spectrallib.safe_get(G.GAME, m, self.config.center_key) or false --[[@as boolean|nil]]
	end
	return Card.no(self, "no_" .. m, true)
end

--#endregion
-------------------------

------------------
--#region HOOKS --
------------------

-- Hook to add redeemable backs object type
local inj = SMODS.injectItems
function SMODS.injectItems(...)
	inj(...)
	local keys = {}
	local a_keys = {}
	for i, v in pairs(SMODS.scoring_parameter_keys) do
		if not keys[v] then
			a_keys[#a_keys+1] = v
		end
		keys[v] = true
	end
	SMODS.scoring_parameter_keys = a_keys
	SMODS.ObjectType({
		key = "RedeemableBacks",
		default = "b_red",
		cards = {},
		inject = function(self)
			SMODS.ObjectType.inject(self)
			for _,key in ipairs({
				"b_red",
				"b_blue",
				"b_yellow",
				"b_green",
				"b_black",
				"b_magic",
				"b_nebula",
				"b_ghost",
				"b_zodiac",
				"b_painted",
				"b_anaglyph",
				"b_plasma",
				"b_erratic",
				"b_abandoned",
				"b_checkered",
			}) do self:inject_card(G.P_CENTERS[key]) end
		end,
	})
	SMODS.ObjectTypes.RedeemableBacks:inject()
end

-- Create third card layer
if not Spectrallib.can_mods_load({"Cryptid", "Cryptlib"}) then
	local set_spritesref = Card.set_sprites
	function Card:set_sprites(_center, _front)
		set_spritesref(self, _center, _front)

		if not Spectrallib.safe_get(_center, "soul_pos", "extra") then return end

		self.children.floating_sprite2 = SMODS.create_sprite(self.T.x, self.T.y, self.T.w, self.T.h,
			_center.soul_extra_atlas or _center.atlas or _center.set,
			_center.soul_pos.extra
		)
		local floating_sprite2 = self.children.floating_sprite2
		floating_sprite2.role.draw_major = self
		floating_sprite2.states.hover.can = false
		floating_sprite2.states.click.can = false
	end

	SMODS.DrawStep({
		key = "floating_sprite2",
		order = 59,
		func = function(self)
			local center = self.config.center
			if not (
				center.soul_pos
				and center.soul_pos.extra
				and (center.discovered or self.bypass_discovery_center)
			) then return end

			if not self.children.floating_sprite2 then return end

			local scale_mod = 0.07
			local rotate_mod = 0
			local floating_sprite2 = self.children.floating_sprite2

			floating_sprite2:draw_shader(
				"dissolve",   0, nil, nil, self.children.center, scale_mod, rotate_mod, nil, 0.1, nil, 0.6
			)
			floating_sprite2:draw_shader(
				"dissolve", nil, nil, nil, self.children.center, scale_mod, rotate_mod
			)
		end,
		conditions = {
			vortex = false,
			facing = "front"
		},
	})

	SMODS.draw_ignore_keys.floating_sprite2 = true
end

--#endregion
------------------

-------------------------------
--#region INTERNAL UTILITIES --
-------------------------------

-- Merge the contents of two lists into a new list; the returned list has the contents of `t1` then `t2`.
---@param t1 any[]
---@param t2 any[]
---@return any[]
function Spectrallib.table_merge(t1, t2)
	local tbl = {}
	for _,v in pairs(t1) do
		table.insert(tbl, v)
	end
	for _, v in pairs(t2) do
		table.insert(tbl, v)
	end
	return tbl
end

-- Descend a deeply nested table by following a list of keys.<br>
-- If at any point a key is assigned `nil`, returns `false`;<br>
-- otherwise returns the value assigned to the last listed key.
---@param t table
---@param ... any
---@return table|any|false
function Spectrallib.safe_get(t, ...)
	local current = t
	for _, k in ipairs({ ... }) do
		if not current or type(current) ~= "table" or current[k] == nil then
			return false
		end
		current = current[k]
	end
	return current
end

-- Fully copies a table and its tables recursively.
---@param obj table
---@param seen? table Used within the function itself.
---@return table
function Spectrallib.deep_copy(obj, seen)
	if type(obj) ~= "table" then return obj end
	if seen and seen[obj] then return seen[obj] end

	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do
		res[Spectrallib.deep_copy(k, s)] = Spectrallib.deep_copy(v, s)
	end
	return res
end

-- Evaluate plural notation, e.g. #<s>1#, #<ies,y>2#.
---@param str string
---@param vars any[]
---@return string|nil
function Spectrallib.pluralize(str, vars)
	if type(str) ~= "string" or type(vars) ~= "table" then return end
	-- Example strings: "<s>1", "<ies,y>2"
	-- In following comments:
		-- "^" are characters part of the pattern match
		-- but "!" are characters part of selection *groups*

	-- Get the inside of the angle brackets
	local bracket_contents = str:match("<(.-)>")
	if not bracket_contents then return end

	-- Split the bracket contents by the delimiter ","
	local inside_split = {}
	for item in bracket_contents:gmatch("[^,]+") do
		table.insert(inside_split, item)
	end

	-- Prepare checks for grammatical numbers
	local plural_affix = inside_split[1] -- default
	local singular_check_modified = false -- tracks if 1 was modified
	local grammatical_number_checks = {
		-- All contents of this table are of this form
		-- Keys are grammatical numbers:
			-- 1 = singular, 2 = dual, 3 = trial, 4 = quadral, etc...
		-- `comparison` is either "=" or "<", compares variable value `V` to grammatical number `G`
			-- `comparison` == "=" -> `V` == `G`
			-- `comparison` == "<" -> `V` <= `G`
			-- If the `comparison` returns true, the `affix` is returned
			-- (evaluated from smallest to greatest grammatical number)
		-- If none of the comparisons return true, the plural `affix` is returned
		[1] = {
			comparison = "=",
			affix = ""
		}
	}
	if #inside_split > 1 then
		for i = 2, #inside_split do
			local item_is_number = tonumber(inside_split[i])
			if item_is_number then
				-- For inputs of the form "#<plural,%d>%d#",
				-- "#<plural,%d,multi>%d#",
				-- "#<plural,%d,multi,%d,multi>%d#", etc.
				local gr_number = item_is_number
				if not singular_check_modified then
					grammatical_number_checks[1] = nil
				end
				if gr_number == 1 then
					singular_check_modified = true
				end

				-- do less than for custom values
				grammatical_number_checks[gr_number] = {
					comparison = "<",
					affix = inside_split[i+1] or ""
				}
				i = i + 1 -- This will skip two steps ahead
			elseif i == 2 then
				-- For inputs of the form "#<plural,singular>%d#",
				-- "#<plural>%d#"
				grammatical_number_checks[1].affix = inside_split[i]
			end
		end
	end
	local grammatical_numbers = {}
	for gr_number in pairs(grammatical_number_checks) do
		table.insert(grammatical_numbers, gr_number)
	end
	table.sort(grammatical_numbers)

	-- Get the number next to the angle brackets
	-- which is the index of `vars`
	local var_index = tonumber(str:match(">(%d+)"))
	local var_value = vars[var_index] or 1
	if type(var_value) == "string" and Big then
		var_value = to_number(to_big(var_value))
	end
	if not (tonumber(var_value) or is_number(var_value)) then
		var_value = 1
	end

	-- Finally determine which affix to return, depending on var_value
	for _,gr_number in ipairs(grammatical_numbers) do
		local current_check = grammatical_number_checks[gr_number]
		if (
			(current_check.comparison == "=" and var_value == gr_number)
			or (current_check.comparison == "<" and var_value <= gr_number)
		) then
			return current_check.affix
		end
	end
	return plural_affix
end

-- Restricts the input within the range `[min,max]`.
---@param x number
---@param min number
---@param max number
---@return number
function Spectrallib.clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

-- Converts a list of items into a table with keys being the items in the given list,<br>
-- effectively converting a list into a set.
---@generic Spectrallib.list_to_keys.list_contents
---@generic Spectrallib.list_to_keys.all_values
---@param list Spectrallib.list_to_keys.list_contents[]
---@param all_values? Spectrallib.list_to_keys.all_values The value that all keys map to. nil defaults to true.
---@return {[Spectrallib.list_to_keys.list_contents]: Spectrallib.list_to_keys.all_values}
function Spectrallib.list_to_keys(list, all_values)
	if type(list) ~= "table" then return {} end
	if all_values == nil then all_values = true end
	local ret_table = {}
	for _,key in ipairs(list) do
		ret_table[key] = all_values
	end
	return ret_table
end

-- todo: figure out what this is for
---@param card Card
---@param func function
---@return any
function Spectrallib.deck_effects(card, func)
	if not card.added_to_deck then
		return func(card)
	else
		card.from_quantum = true
		card:remove_from_deck(true)
		local ret = func(card)
		card:add_to_deck(true)
		card.from_quantum = nil
		return ret
	end
end
-- needed for compat
Spectrallib.with_deck_effects = Spectrallib.deck_effects

--#endregion
-------------------------------

------------------------------
--#region BOOLEAN FUNCTIONS --
------------------------------

-- Determines if a card can contain BigNumber values. (I think)
---@param card Card
---@return boolean
function Spectrallib.is_card_big(card)
	if not Spectrallib.can_mods_load({'Talisman'}) then
		return false
	end

	local center = card.config and card.config.center
	if not center then
		return false
	end

	if center.immutable and center.immutable == true then
		return false
	end

    -- im making bignums not work with Spectrallib. since i dont see the point
    -- could be changed but i dont feel like making 2 blacklists or making this mod use the Spectrallib table either
	if center.mod and not (Spectrallib or {}).mod_whitelist[center.mod.name] then
		return false
	end

	local in_blacklist = ((Spectrallib or {}).big_num_blacklist or {})[center.key or "Nope!"] or false

	return not in_blacklist
end

-- Determines whether a table has a value assigned to the key `"no_"..m`.
---@param center SMODS.Center|table
---@param m string
---@param key string
---@param no_no boolean If true, check m and not `"no_"..m`.
---@return boolean|any
function Spectrallib.no(center, m, key, no_no)
	if no_no then
		return center[m] or (G.GAME and G.GAME[m] and G.GAME[m][key]) or false
	end
	return Spectrallib.no(center, "no_" .. m, key, true)
end

-- Truthy if input is a number/BigNumber.
---@param x any
---@return boolean
function Spectrallib.is_number(x)
	return type(x) == "number" or Spectrallib.is_big(x)
end

-- Truthy if input is strictly a BigNumber.
---@param x any
---@return boolean
function Spectrallib.is_big(x)
	return (type(x) == "cdata" and is_number(x)) or (is_big and is_big(x))
end

--#endregion
------------------------------

--------------------------------------
--#region GAMEPLAY OBJECT RETRIEVAL --
--------------------------------------

-- Get all highlighted cards in the specified list of card areas.
---@param areas CardArea[]
---@param ignore Card|table A card to exclude from the highlighted list.
---@param min number
---@param max number If the count of highlighted cards exceeds this value, returned table will be a max-sized list of randomly selected highlighted cards.
---@param blacklist? string[]|(fun(card: Card): boolean) If function returns true, card is included into the highlighted list. Table entries are keys of centers to exclude.
---@param seed? string|any Can be used alongside the `max` parameter.
---@return Card[]
function Spectrallib.get_highlighted_cards(areas, ignore, min, max, blacklist, seed)
	ignore = ignore or {}
	ignore.checked = true
	min = min or 1
	max = max or 1
	-- Convert blacklist tables to function
	if type(blacklist) == "table" then
		local t = SMODS.shallow_copy(blacklist)
		blacklist = function (card)
			local center_key = card.config.center.key
			return not t[center_key]
		end
	else -- function or nil
		blacklist = blacklist or function()
			return true
		end
	end
	for i, v in pairs(areas) do
		if v.cards then areas[i] = v.cards end
	end
	local highlighted_cards = {}
	for card in Spectrallib.iter.areacards(areas) do
		if (
			card ~= ignore
			and blacklist(card)
			and (card.highlighted or G.cry_force_use)
			and not card.checked
		) then
			table.insert(highlighted_cards, card)
			card.checked = true
		end
	end
	for _, card in ipairs(highlighted_cards) do
		card.checked = nil
	end

	if (min <= #highlighted_cards and #highlighted_cards <= max) or not G.cry_force_use then
		ignore.checked = nil
		return highlighted_cards
	else -- Pick a random set of highlighted cards
		for i, card in pairs(highlighted_cards) do
			card.f_use_order = i
		end

		pseudoshuffle(highlighted_cards, pseudoseed("forcehighlight" or seed))
		local ret_cards = {}
		for i = 1, max do
			if highlighted_cards[i] and not highlighted_cards[i].checked then
				table.insert(ret_cards, highlighted_cards[i])
			end
		end
		table.sort(ret_cards, function(a, b)
			return a.f_use_order < b.f_use_order
		end)

		for _, card in pairs(highlighted_cards) do
			card.f_use_order = nil
		end
		ignore.checked = nil
		return ret_cards
	end
end

-- Get a rank's ID given its name.
---@param rankname string
---@return integer|nil
function Spectrallib.cry_rankname_to_id(rankname)
	for id, name in pairs(SMODS.Rank.obj_buffer --[[@as string[] ]]) do
		if rankname == name then
			return id
		end
	end
	return nil
end

-- Gets a random edition.<br>
-- (Used by Antimatter Deck (Cryptid))
---@return { string: true } # String is the key of the edition.
function Spectrallib.poll_random_edition()
	local random_edition = pseudorandom_element(G.P_CENTER_POOLS.Edition, pseudoseed("cry_ant_edition"))
	while random_edition.key == "e_base" do
		random_edition = pseudorandom_element(G.P_CENTER_POOLS.Edition, pseudoseed("cry_ant_edition"))
	end
	local ed_table = { [random_edition.key:sub(3)] = true }
	return ed_table
end

-- Gets a random obtainable consumable that satisfies a flag blacklist.<br>
-- (Used by Hammerspace, CCD Deck, Blessing, etc. (Cryptid))
---@param seed? string|any
---@param excluded_flags? string[] Defaults to {"hidden", "no_doe", "no_grc"}
---@param banned_card? string
---@param pool? SMODS.Consumable[]
---@param no_undiscovered? boolean
---@return SMODS.Consumable -- Consumable definition.
function Spectrallib.random_consumable(seed, excluded_flags, banned_card, pool, no_undiscovered)
	-- set up excluded flags - these are the kinds of consumables we DON'T want to have generating
	excluded_flags = excluded_flags or { "hidden", "no_doe", "no_grc" }
	pool = pool or G.P_CENTER_POOLS.Consumeables

	local selected_card
	local tries = 500

	for _=1, tries do
		local passed_flag_count = 0

		-- create a random consumable naively
		local consumable_key = pseudorandom_element(pool, pseudoseed(seed or "grc")).key
		selected_card = G.P_CENTERS[consumable_key]

		-- banned_card = nil makes this always false
		local card_equals_banned = consumable_key == banned_card
		-- no_undiscovered = true makes this always true
		local card_is_discovered = selected_card.discovered or not no_undiscovered

		if not card_equals_banned and card_is_discovered then
			for _,flag in ipairs(excluded_flags) do
				if not Spectrallib.no(selected_card, flag, consumable_key, true) then
					passed_flag_count = passed_flag_count + 1
				end
			end
		end

		if passed_flag_count >= #excluded_flags then
			return selected_card
		end
	end

	if tries <= 0 and no_undiscovered then
		return G.P_CENTERS["c_strength"]
	end

	return selected_card
end

-- Finds a Joker or consumable, with additional filters for specificity.
---@param name string
---@param rarity? string|string[]
---@param edition? string
---@param ability? string|string[]
---@param non_debuff? boolean If true, include debuffed Jokers in the search.
---@param area? "j"|"c" If "j", search Jokers. If "c", search consumables. Otherwise, search does not occur.
---@return Card[]
function Spectrallib.advanced_find_joker(name, rarity, edition, ability, non_debuff, area)
	if not G.jokers or not G.jokers.cards then
		return {}
	end

	local filter_count = 0
	if name then filter_count = filter_count + 1 end
	if edition then filter_count = filter_count + 1 end

	if not rarity then
	elseif type(rarity) == "string" then
		rarity = { rarity }
	elseif type(rarity) ~= "table" then
		rarity = nil
	end
	if rarity then filter_count = filter_count + 1 end

	if not ability then
	elseif type(ability) == "string" then
		ability = { ability }
	elseif type(ability) ~= "table" then
		ability = nil
	end
	if ability then filter_count = filter_count + 1 end

	-- Return nothing if function is called with no useful arguments
	if filter_count == 0 then
		return {}
	end

	-- Card check process
	local found_cards = {}
	local function filter_check_card(card)
		if not (non_debuff or not card.debuff) then return end
		local satisfied_filter_count = 0

		if name and card.ability.name == name then
			satisfied_filter_count = satisfied_filter_count + 1
		end
		if edition and Spectrallib.safe_get(card, "edition", "key") == edition then
			satisfied_filter_count = satisfied_filter_count + 1
		end
		if rarity and card.area == G.jokers then
			for _,rarity_key in ipairs(rarity) do
				if card.config.center.rarity == rarity_key then
					satisfied_filter_count = satisfied_filter_count + 1
					break
				end
			end
		end
		if ability then
			-- Assume ahead of time ability filter satisfied
			satisfied_filter_count = satisfied_filter_count + 1
			for _,ability_key in ipairs(ability) do
				if not card.ability[ability_key] then
					-- Retract assumption and scold accordingly
					satisfied_filter_count = satisfied_filter_count - 1
					break
				end
			end
		end

		if satisfied_filter_count == filter_count then
			table.insert(found_cards, card)
		end
	end

	-- Begin checking cards
	local cardlists = {}
	if not area or area == "j" then
		table.insert(cardlists, G.jokers)
	end
	if not area or area == "c" then
		table.insert(cardlists, G.consumeables)
	end
	for card in Spectrallib.iter.areacards(cardlists) do
		filter_check_card(card)
	end

	return found_cards
end

--#endregion
--------------------------------------

-----------------------------
--#region VISUAL FUNCTIONS --
-----------------------------

-- Pulses the flames on chips and mult temporarily.
---@param duration? number duration of the pulse in seconds
---@param intensity? number intensity of the flames in idfk, it increases pretty quickly though
function Spectrallib.pulse_flame(duration, intensity)
	G.cry_flame_override = G.cry_flame_override or {}
	G.cry_flame_override["duration"] = duration or 0.01
	G.cry_flame_override["intensity"] = intensity or 2
end

-- Pulses the colors on chips and mult temporarily.
---@param new_color [number, number, number, number]
---@param fade_in? number
---@param hold? number
---@param fade_out? number
---@return nil
function Spectrallib.pulse_scoring_window_colors(new_color, fade_in, hold, fade_out)
	fade_in = fade_in or 0.1
	fade_out = fade_out or 1
	hold = hold or 0

	for _, v in ipairs(Spectrallib.scoring_window_pulse_targets) do
		ease_colour(v[1], copy_table(new_color), fade_in)
	end
	-- TARGET: add more colors to pulse on

	Spectrallib.event{
		function()
			for _, v in ipairs(Spectrallib.scoring_window_pulse_targets) do
				ease_colour(v[1], v[2], fade_out)
			end
			-- TARGET: add more colors to pulse off

			return true
		end,
		trigger = "after",
		blockable = false,
		blocking = false,
		delay = fade_in + hold,
	}
end
-- format: {UI color, original color}
Spectrallib.scoring_window_pulse_targets = {
	{G.C.UI_MULT, G.C.RED},
	{G.C.UI_CHIPS, G.C.BLUE},
}

-- Resets the Poker Hand information to show nothing (i.e. after using a Planet Card).
---@param sound_config table
---@return nil
function Spectrallib.reset_to_none(sound_config)
	update_hand_text(sound_config or {delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
end

--#endregion
-----------------------------

-----------
-- HOOKS --
-----------

-- remove sell value from cards (used by multiuse)
local cssv = Card.set_sell_value
function Card:set_sell_value()
	cssv(self)
	if self.ability and self.ability.slib_no_sell_value then
		self.sell_cost = 0 + (self.ability.extra_value or 0)
		self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
	end
end
