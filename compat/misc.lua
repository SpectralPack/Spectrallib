-- Hot Potato
Spectrallib.deck_config_apply_effects["plincoins"] = function (deck_center, value)
    ease_plincoins(value)
end

-- Infinifusion compat for no-checking
local card_no_ref = Card.no
function Card:no(m, no_no)
    if no_no then
		if self.infinifusion then
            for _,centeridk in ipairs(self.infinifusion) do
                if (
                    G.P_CENTERS[centeridk.key][m]
                    or Spectrallib.safe_get(G.GAME, m, centeridk.key) --[[@as boolean|nil]]
                ) then return true end
            end
            return false
		end
		if not self.config then
			--assume this is from one component of infinifusion
			return G.P_CENTERS[self.key][m] or Spectrallib.safe_get(G.GAME, m, self.key) --[[@as boolean|nil]]
		end
    end
    return card_no_ref(self, m, no_no)
end