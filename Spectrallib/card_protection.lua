-- If returns true, trying to discard this card will cause on-discard
-- effects to occur, but will emplace the card to `G.hand` instead of `G.discard`.\
-- Intended to be hooked.
function Card:protected_from_discard()
    return false
end

-- If returns true, trying to destroy this card will cause on-destruction
-- effects to occur, but will not remove the card.\
-- Intended to be hooked.
function Card:protected_from_destruction()
    return false
end

-- If returns true, trying to sell this card will cause on-sell
-- effects to occur, but will not remove the card.\
-- Intended to be hooked.
function Card:protected_from_selling()
    return false
end

local card_dissolve_ref = Card.start_dissolve
function Card:start_dissolve(...)
    if self:protected_from_destruction() then
        if self.added_to_deck then
            local proto = self.config.center
            if proto and type(proto.remove_from_deck) == 'function' then
                proto:remove_from_deck(self)
                proto:add_to_deck(self)
            end
        end
        self.getting_sliced = nil
        self.shattered = nil
        self.destroyed = nil
        eval_card(self, {protected_from_destruction=true})
        SMODS.calculate_context{
            destruction_protection_occurred = true,
            card = self
        }
        self.area:remove_from_highlighted(self)
    else
        card_dissolve_ref(self, ...)
    end
end

local card_shatter_ref = Card.shatter
function Card:shatter(args)
    if self:protected_from_destruction() then
        if self.added_to_deck then
            local proto = self.config.center
            if proto and type(proto.remove_from_deck) == 'function' then
                proto:remove_from_deck(self)
                proto:add_to_deck(self)
            end
        end
        self.getting_sliced = nil
        self.shattered = nil
        self.destroyed = nil
        eval_card(self, {protected_from_destruction=true})
        SMODS.calculate_context{
            destruction_protection_occurred = true,
            card = self
        }
        self.area:remove_from_highlighted(self)
    else
        card_shatter_ref(self, args)
    end
end