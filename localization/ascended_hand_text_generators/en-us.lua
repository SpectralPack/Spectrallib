local function int_to_word(int)
	if int >= 1000 then return tostring(int)
	-- text gets stupid small at 100+ anyway
	elseif int == 1000 then return "Thousand"
	elseif int == 0 then return "Zero"
	end

	local ones = {
		"One", "Two", "Three", "Four", "Five",
		"Six", "Seven", "Eight", "Nine"
	}

	local tens = {
		"Ten", "Twenty", "Thirty", "Forty", "Fifty",
		"Sixty", "Seventy", "Eighty", "Ninety"
	}

	local irregular_10s = {
		[10] = "Ten", [11] = "Eleven", [12] = "Twelve",
		[13] = "Thirteen", [15] = "Fifteen", [18] = "Eighteen"
	}

	local concat_table = {}
	local tens_ones_place = int % 100
	local hundreds_place  = (int - tens_ones_place) / 100
	local ones_place      = int % 10
	local tens_place      = (tens_ones_place - ones_place) / 10

	if hundreds_place > 0 then
		table.insert(concat_table, ones[hundreds_place])
		table.insert(concat_table, "Hundred")
	end

	if irregular_10s[tens_ones_place] then
		table.insert(concat_table, irregular_10s[tens_ones_place])
	elseif 0 < tens_ones_place and tens_ones_place < 10 then
		table.insert(concat_table, ones[ones_place])
	elseif tens_ones_place < 20 then
		local tens_string = tens[tens_place] .. "teen"
		table.insert(concat_table, tens_string)
	else
		table.insert(concat_table, tens[tens_place])
		if ones_place > 0 then
			table.insert(concat_table, ones[ones_place])
		end
	end

	return table.concat(concat_table, " ")
end

local function ascend_hand_text(hand_text, scoring_hand)
	if #scoring_hand > 5 and ({
		["Flush Five"] = true,
		["Five of a Kind"] = true,
		["bunc_Spectrum Five"] = true
	})[hand_text] then
		local rank_tracker = {}
		local county = 0
		for _,card in ipairs(scoring_hand) do
			local card_rank = card:get_id()
			rank_tracker[card_rank] = (rank_tracker[card_rank] or 0) + 1
			if rank_tracker[card_rank] > county then
				county = rank_tracker[card_rank]
			end
		end

		return hand_text:gsub("Five", int_to_word(county))
	end
	return hand_text
end

return {
	dynamic = {
		ascend_hand_text = ascend_hand_text
	}
}