SMODS.Sound {
	key = "emult",
	path = "ExponentialMult.wav",
}
SMODS.Sound {
	key = "echips",
	path = "ExponentialChips.wav",
}

local add_exponentials = not (SMODS.Mods.Talisman or SMODS.Mods.cdataman or {}).can_load

local calc_exponential = function(...) end

if add_exponentials then
	calc_exponential = function(effect, scored_card, key, amount, from_edition)
		if (key == "e_chips" or key == "echips" or key == "Echip_mod") and amount ~= 1 then
			if effect.card then
				juice_card(effect.card)
			end
			local chips = SMODS.Scoring_Parameters["chips"]
			chips:modify((chips.current ^ amount) - chips.current)
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(
						scored_card,
						"jokers",
						nil,
						percent,
						nil,
						{ message = "^" .. amount, colour = G.C.EDITION, edition = true }
					)
				elseif key ~= "Echip_mod" then
					if effect.echip_message then
						card_eval_status_text(
							scored_card or effect.card or effect.focus,
							"extra",
							nil,
							percent,
							nil,
							effect.echip_message
						)
					else
						card_eval_status_text(scored_card or effect.card or effect.focus, "e_chips", amount, percent)
					end
				end
			end
			return true
		end
		if (key == "e_mult" or key == "emult" or key == "Emult_mod") and amount ~= 1 then
			if effect.card then
				juice_card(effect.card)
			end
			local mult = SMODS.Scoring_Parameters["mult"]
			mult:modify((mult.current ^ amount) - mult.current)
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(
						scored_card,
						"jokers",
						nil,
						percent,
						nil,
						{ message = "^" .. amount .. " " .. localize("k_mult"), colour = G.C.EDITION, edition = true }
					)
				elseif key ~= "Emult_mod" then
					if effect.emult_message then
						card_eval_status_text(
							scored_card or effect.card or effect.focus,
							"extra",
							nil,
							percent,
							nil,
							effect.emult_message
						)
					else
						card_eval_status_text(scored_card or effect.card or effect.focus, "e_mult", amount, percent)
					end
				end
			end
			return true
		end
	end
	for _, v in ipairs({
		"e_mult", "emult", "Emult_mod",
		"e_chips", "echips", "Echip_mod",
	}) do
		table.insert(SMODS.scoring_parameter_keys, v)
	end
	to_big = to_big or function(x) return x end
	to_number = to_number or function(x) return x end
	lenient_bignum = lenient_bignum or function(x) return x end
	is_number = is_number or function(x) return type(x) == "number" end
end

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition, ...)
	local ret = scie(effect, scored_card, key, amount, from_edition, ...)
		or calc_exponential(effect, scored_card, key, amount, from_edition)

	if ret then
		return ret
	end

	if key == "cry_broken_swap" or key == "cry_partial_swap" and amount > 0 then
		if effect.card and effect.card ~= scored_card then
			juice_card(effect.card)
		end
		-- only need math.min due to amount being required to be greater than 0
		amount = math.min(amount, 1)

		local chips = SMODS.Scoring_Parameters.chips
		local mult = SMODS.Scoring_Parameters.mult
		local chip_mod = chips.current * amount
		local mult_mod = mult.current * amount

		chips:modify(mult_mod - chip_mod)
		mult:modify(chip_mod - mult_mod)

		if key == "cry_broken_swap" and not Cryptid.safe_get(Talisman, "config_file", "disable_anims") then
			G.E_MANAGER:add_event(Event{
				func = function()
					-- scored_card:juice_up()
					local pitch_mod = pseudorandom("cry_broken_sync") * 0.05 + 0.85
					play_sound("gong", pitch_mod, 0.3)
					play_sound("gong", pitch_mod * 1.4814814, 0.2)
					play_sound("tarot1", 1.5)
					ease_colour(G.C.UI_CHIPS, mix_colours(G.C.BLUE, G.C.RED, amount))
					ease_colour(G.C.UI_MULT, mix_colours(G.C.RED, G.C.BLUE, amount))
					G.E_MANAGER:add_event(Event{
						trigger = "after",
						blockable = false,
						blocking = false,
						delay = 0.8,
						func = function()
							ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.8)
							ease_colour(G.C.UI_MULT, G.C.RED, 0.8)
							return true
						end,
					})
					G.E_MANAGER:add_event(Event{
						trigger = "after",
						blockable = false,
						blocking = false,
						no_delete = true,
						delay = 1.3,
						func = function()
							G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] =
								G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
							G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] =
								G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
							return true
						end,
					})
					return true
				end,
			})
			if not effect.remove_default_message then
				if effect.balance_message then
					card_eval_status_text(
						effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus,
						"extra",
						nil,
						percent,
						nil,
						effect.balance_message
					)
				else
					card_eval_status_text(
						effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus,
						"extra",
						nil,
						percent,
						nil,
						{ message = localize("cry_balanced_q"), colour = { 0.8, 0.45, 0.85, 1 } }
					)
				end
			end
			delay(0.6)
		end

		return true
	end
end

for _, v in ipairs{ "cry_broken_swap", "cry_partial_swap" } do
	table.insert(SMODS.scoring_parameter_keys, v)
end
