-- ascended.lua - Used for Ascended Hands\

------------------
--#region HOOKS --
------------------

-- Reset Chips/Mult colors at end of round
	-- Needed because get_poker_hand_info isnt called at the end of the road
local evaluateroundref = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
	evaluateroundref()
	-- This is just the easiest way to check if its gold because lua is annoying
	if G.C.UI_CHIPS[1] == G.C.GOLD[1] then
		ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
		ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
	end
end

-- UI changes to display ascensded hand details
local pokerhandinforef = G.FUNCS.get_poker_hand_info
function G.FUNCS.get_poker_hand_info(_cards)
	local text, loc_disp_text, poker_hands, scoring_hand, disp_text = pokerhandinforef(_cards)

	local hidden = false
	for _, card in pairs(scoring_hand) do
		if card.facing == "back" then
			hidden = true
			break
		end
	end

	-- funy display text (see localization/ascended_hand_text_generators)
	local ascend_hand_text_func = Spectrallib.safe_get(G.localization, "dynamic", "ascend_hand_text")
	if ascend_hand_text_func then
		text = ascend_hand_text_func(text, scoring_hand)
	end

	-- Get ascension power
	local asc_power = Spectrallib.calculate_ascension_power(text, _cards, scoring_hand)

	-- UI displaying ascension power
	G.GAME.current_round.current_hand.cry_asc_num = asc_power
	if asc_power > 0 and not hidden then
		-- Change mult and chips colors if hand is ascended
		ease_colour(G.C.UI_CHIPS, copy_table(G.C.GOLD), 0.3)
		ease_colour(G.C.UI_MULT, copy_table(G.C.GOLD), 0.3)
		G.GAME.current_round.current_hand.cry_asc_num_text =
			("(+%s)"):format(number_format(asc_power))
	else
		ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
		ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
		G.GAME.current_round.current_hand.cry_asc_num_text = ""
	end

	return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end

--#endregion
------------------

----------------------
--#region FUNCTIONS --
----------------------

-- Sets color of Ascension power text
G.FUNCS.cry_asc_UI_set = function(e)
	e.config.object.colours = { G.C.GOLD }
	e.config.object:update_text()
end

-- Determines if Ascended Hands is enabled;
-- intended to be hooked for conditional activation.
---@return boolean|any
function Spectrallib.ascension_power_enabled()
	if Spectrallib.optional_feature("ascension_power") then return true end
end

-- Determines if all selected cards count toward Ascension Power;
-- intended to be hooked for conditional activation.
---@return boolean
function Spectrallib.has_tether()
	return false
end

-- Apply the ascension formula to a given value.
---@param value number
---@param asc_power number
---@return number
function Spectrallib.ascend(value, asc_power) -- edit this function at your leisure
	-- Sun number fallback (thing that Sol (Cryptid) increases)
	G.GAME.sunnumber = G.GAME.sunnumber or {not_modest = 0, modest = 0}
    local sun_number
    if type(G.GAME.sunnumber) == "table" then
		sun_number = G.GAME.sunnumber.not_modest or 0
    else
		sun_number = G.GAME.sunnumber
	end

	-- Ascension power fallback
    asc_power = asc_power or (1 + (G.GAME.nemesisnumber or 0))*(
		(G.GAME.current_round.current_hand.cry_asc_num or 0)
		+ (G.GAME.asc_power_hand or 0)
	)

	-- ???? please explanation
    local num2 = math.min(asc_power or 0, 50)
    local diff = asc_power - num2
    if to_big(asc_power or 0) > to_big(40) then
        num2 = num2 + diff ^ 0.3
    end
    asc_power = num2

	-- The formula
    return value * (to_big((1.25 + sun_number)) ^ to_big(asc_power))
end

-- Get the ascension threshold for a hand.
---@param hand_name string
---@return number|nil
function Spectrallib.hand_ascension_numbers(hand_name)
	local hand_ascension_number = Spectrallib.ascension_numbers[hand_name]
	-- type checks double as nil check
	if type(hand_ascension_number) == "function" then
		return hand_ascension_number()
	end
	return hand_ascension_number -- can be nil
end

-- Get the starting (hand-dependent) ascension power of the current hand;
-- intended to be hooked for additional sources.
---@param hand_name string
---@param hand_cards Card[]
---@param hand_scoring_cards Card[]
---@return number
function Spectrallib.calculate_starting_asc_power(hand_name, hand_cards, hand_scoring_cards)
	local starting_power = 0
	-- Get starting_power Ascension power from Poker Hands
	if hand_cards then
		local asc_threshold = Spectrallib.hand_ascension_numbers(hand_name)
		if asc_threshold then
			local card_count = Spectrallib.has_tether() and #hand_cards or #hand_scoring_cards
			starting_power = card_count - asc_threshold
		end
	end
	return starting_power
end

-- Get the bonus (external) ascension power of the current hand;
-- intended to be hooked for additional sources.
---@param hand_name string
---@param hand_cards Card[]
---@param hand_scoring_cards Card[]
---@return number
function Spectrallib.calculate_bonus_asc_power(hand_name, hand_cards, hand_scoring_cards)
	return 0
end

-- Get the ascension power of the current hand.
---@param hand_name string
---@param hand_cards Card[]
---@param hand_scoring_cards Card[]
---@return number
function Spectrallib.calculate_ascension_power(hand_name, hand_cards, hand_scoring_cards)
	if not Spectrallib.ascension_power_enabled() then return 0 end

	local starting_power = Spectrallib.calculate_starting_asc_power(hand_name, hand_cards, hand_scoring_cards)
	local bonus_power = (G.GAME.bonus_asc_power or 0) + Spectrallib.calculate_bonus_asc_power(hand_name, hand_cards, hand_scoring_cards)

	local final_power = math.max(0, starting_power + bonus_power)
	-- Needed to avoid awkwardness from raising to power of <1
	if 0 < final_power and final_power < 1 then
		final_power = 1
	end
	return final_power
end

--#endregion
----------------------

-----------------------------
--#region HAND DEFINITIONS --
-----------------------------

--Ascension numbers for Vanilla hands
---@param x integer
---@return fun(): integer|nil
local function tether_check(x)
    return function()
        return Spectrallib.has_tether() and x or nil
    end
end
local function straight_flush()
	return (
		next(SMODS.find_card("j_four_fingers"))
		and Spectrallib.gameset() ~= "modest"
		and 4
		or 5
	)
end
---@type { [string]: integer | fun():(integer|nil) }
Spectrallib.ascension_numbers = {
	["High Card"]       = tether_check(1),
	["Pair"]            = tether_check(2),
	["Three of a Kind"] = tether_check(3),
	["Four of a Kind"]  = tether_check(4),
	["Straight"]        = straight_flush,
	["Flush"]           = straight_flush,
	["Two Pair"]        = 4,
	["Full House"]      = 5,
	["Five of a Kind"]  = 5,
	["Flush House"]     = 5,
	["Flush Five"]      = 5,
}

--#endregion
-----------------------------