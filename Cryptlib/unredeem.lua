-- Unapply a voucher and play the corresponding animation.
---@return nil
function Card:unredeem()
	if self.ability.set == "Voucher" then
		stop_use()
		if not self.config.center.discovered then
			discover_card(self.config.center)
		end

		Spectrallib.redeem_animation(self, {
			colour = G.C.RED,
			sounds = {'card1', 'timpani'},
			btm_txt = localize("cry_unredeemed"),
			during_func = function()
				if not self.debuff then
					self:unapply_to_run()
				end
			end
		})
	end

	G.E_MANAGER:add_event(Event({
		func = function()
			Spectrallib.update_used_vouchers()
			return true
		end,
	}))
end

-- Remove a voucher and its effects from the run.
---@param center? table
---@return nil
function Card:unapply_to_run(center)
	local center_table = {
		name = center and center.name or self and self.ability.name,
		extra = self and self.ability.extra or center and center.config.extra,
	}
	local obj = center or self.config.center
	if type(obj.unredeem) == "function" then
		obj:unredeem(self)
		return
	end

	local vanilla_unapply_result = Spectrallib.vanilla_unapply_results[center_table.name]
	if vanilla_unapply_result then
		vanilla_unapply_result(self, center_table)
	end
end

---@return nil
function Spectrallib.update_used_vouchers()
	if not (G and G.GAME and G.vouchers) then return end

	G.GAME.used_vouchers = {}
	for _,voucher in ipairs(G.vouchers.cards) do
		G.GAME.used_vouchers[voucher.config.center_key] = true
	end
end
