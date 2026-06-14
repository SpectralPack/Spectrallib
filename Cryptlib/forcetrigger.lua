SMODS.Sound({
	key = "forcetrigger",
	path = "forcetrigger.ogg",
})

SMODS.Sound({
	key = "demitrigger",
	path = "demitrigger.ogg",
})

-- Determines whether a card is forcetriggerable.
---@param card Card
---@return [ boolean ]
function Spectrallib.card_is_forcetriggerable(card)
	local is_triggerable = { false } -- Used to have another boolean, hence table - not sure why
	if not card then return is_triggerable end

	if (
		card.config.center.demicoloncompat
		or card.config.center.demicolon_compat
		or card.config.center.forcetrigger_compat
		or (
			card.ability
			and Spectrallib.vanilla_forcetrigger_results[card.ability.name]
		)
		or (
			card.ability.consumeable
			and Spectrallib.forcetriggerConsumableCheck(card)
		)
	) then
		is_triggerable[1] = true
	end

	return is_triggerable
end
Spectrallib.demicolonGetTriggerable = Spectrallib.card_is_forcetriggerable

local calc_ref = Card.calculate_joker
function Card:calculate_joker(...)
	local ret =  calc_ref(self, ...)
	G.slib_copied_stack = nil
	return ret
end

---@param card Card
---@param context table
---@return table
function Spectrallib.get_forcetrigger_results(card, context)
	G.slib_copied_stack = G.slib_copied_stack or {}
	if not card or Spectrallib.in_table(G.slib_copied_stack, card) then
		return {}
	end

	table.insert(G.slib_copied_stack, card)

	local results = {}

	-- Try Jokers
	if card.ability.set == "Joker" then
		local vanilla_forcetrigger_result = Spectrallib.vanilla_forcetrigger_results[card.ability.name]

		-- Vanilla Jokers
		if vanilla_forcetrigger_result then
			results.jokers = vanilla_forcetrigger_result(card, context)
		-- Other Jokers
		else
			local demicontext = SMODS.shallow_copy(context)
			demicontext.forcetrigger = true
			if card.config.center.forcetrigger then
				results.jokers = card.config.center:forcetrigger(card, demicontext) or {}
			elseif card.config.center.calculate then
				results.jokers = card.config.center:calculate(card, demicontext) or {}
			end
			results.jokers.card = card
		end

	-- Try Consumables
	elseif (
		card.ability.consumeable
		and (
			card.config.center.demicoloncompat
			or not card.config.center.original_mod
			or card.config.center.forcetrigger_compat
		)
	) then
		G.cry_force_use = true

		if --Behavior for cards that require cards in hand to be selected
			(card.ability.consumeable.max_highlighted or card.ability.name == "Aura")
			and not card.config.center.force_use
		then
			local selectable_cards = {}
			local target_cards = {}

			--Get all cards that we can target
			for _,held_card in ipairs(G.hand.cards) do
				if not (
					-- Case 1
					card.ability.name == "Aura"
					and (held_card.edition or held_card.will_be_editioned)
					-- Case 2
					or held_card.will_be_destroyed
				) then
					table.insert(selectable_cards, held_card)
				end
			end

			local highlight_count = math.min(#selectable_cards, card.ability.consumeable.max_highlighted or 1)

			if highlight_count > 0 then
				--Choose random target for consumable
				for _=1, highlight_count do
					local random_card, card_key = pseudorandom_element(selectable_cards, pseudoseed("forcehighlight"))
					if card.ability.name == "Aura" then
						random_card.will_be_editioned = true
					end
					if card.ability.name == "The Hanged Man" then
						random_card.will_be_destroyed = true
					end

					table.insert(target_cards, selectable_cards)
					table.remove(selectable_cards, card_key--[[@as integer]])

					--Dodgy way of doing this
					--Basically we need to highlight the cards temporarily to ensure events are created correctly
					G.hand:add_to_highlighted(random_card, true)
				end

				G.E_MANAGER:add_event(Event({
					func = function()
						for _,target in ipairs(target_cards) do
							G.hand:add_to_highlighted(target, true)
							target.will_be_editioned = nil
							target.will_be_destroyed = nil
							play_sound("card1", 1)
						end
						return true
					end,
				}))

				card:use_consumeable()

				G.E_MANAGER:add_event(Event({
					func = function()
						G.hand:unhighlight_all()
						return true
					end,
				}))

				--Unhighlight once events are created
				-- todo: is this needed?
				G.hand:unhighlight_all()
			end
		else
			-- Copy rigged code to guarantee WoF and Planet.lua
			local original_probability = G.GAME.probabilities.normal

			G.GAME.probabilities.normal = 1e9
			if not card.config.center.force_use then
				card:use_consumeable()
			else
				card.config.center:force_use(card, card.area)
			end

			G.GAME.probabilities.normal = original_probability
		end
		G.cry_force_use = nil
	end
	return results
end

---@class Spectrallib.forcetrigger.args
---@field card? Card The card to perform the forcetrigger on.
---@field context? table
---@field message? string Defaults to the localization of "Forcetrigger!"
---@field message_card? Card The card to display the forcetrigger message; may be distinct from `card`.
---@field colour? [number, number, number, number] Message color.
---@field silent? boolean If true, hides message.

---Forcetriggers a given card and calculates returned effects.
---@param args Spectrallib.forcetrigger.args|table
---@return nil
function Spectrallib.forcetrigger(args)
	args.context = args.context or {}
	local card_is_forcetriggerable = Spectrallib.demicolonGetTriggerable(args.card)[1]
	if card_is_forcetriggerable then
		if not Spectrallib.should_skip_animations() and not args.silent then
			G.E_MANAGER:add_event(Event({
				trigger = "before",
				func = function()
					play_sound("slib_forcetrigger", 1, 0.6)
					return true
				end,
			}))
		end

		if not args.silent then
			SMODS.calculate_effect{
				card = args.context.blueprint_card or args.message_card or args.card,
				colour = args.context.blueprint_card and G.C.BLUE or args.colour or G.C.PURPLE,
				message = args.message or localize("slib_forcetrigger_ex")
			}
		end

		local results = Spectrallib.get_forcetrigger_results(args.card, args.context)
		if results and results.jokers then
			results.jokers.card = args.card
			SMODS.calculate_effect(results.jokers)
		end
	end
end