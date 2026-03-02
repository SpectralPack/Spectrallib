function Spectrallib.level_suit(suit, card, amt, chips_override, instant)
    amt = amt or 1
    local used_consumable = copier or card
    local vals_after_level
    --for properly resetting to previous hand display when leveling in scoring
    if SMODS.displaying_scoring then
        vals_after_level = copy_table(G.GAME.current_round.current_hand)
        local text,disp_text,_,_,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
        vals_after_level.handname = disp_text or ''
        vals_after_level.level = (G.GAME.hands[text] or {}).level or ''
        for name, p in pairs(SMODS.Scoring_Parameters) do
            vals_after_level[name] = p.current
        end
    end

    if not G.GAME.SuitBuffs then G.GAME.SuitBuffs = {} end
    if not G.GAME.SuitBuffs[suit] then
        G.GAME.SuitBuffs[suit] = {level = 1, chips = 0}
    end
    if not G.GAME.SuitBuffs[suit].chips then G.GAME.SuitBuffs[suit].chips = 0 end
    if not G.GAME.SuitBuffs[suit].level then G.GAME.SuitBuffs[suit].level = 1 end
    if not instant then
        update_hand_text(
        { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
        { handname = localize(suit,'suits_plural'), chips = number_format(G.GAME.SuitBuffs[suit].chips), mult = "...", level = G.GAME.SuitBuffs[suit].level }
        )
    end
    G.GAME.SuitBuffs[suit].chips = G.GAME.SuitBuffs[suit].chips + (chips_override or 10)*amt
    G.GAME.SuitBuffs[suit].level = G.GAME.SuitBuffs[suit].level + amt
    for i, v in ipairs(G.I.CARD) do
        if v.base and v.base.suit == suit then
            v.ability.suit_bonus = (v.ability.suit_bonus or 0) + (chips_override or 10)*amt
        end
    end
    if not instant then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                G.TAROT_INTERRUPT_PULSE = nil
                return true 
            end 
        }))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                G.TAROT_INTERRUPT_PULSE = nil
                return true 
            end 
        }))
        update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { chips="+"..number_format((chips_override or 10)*amt), StatusText = true })
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                G.TAROT_INTERRUPT_PULSE = nil
                return true 
            end 
        }))
        update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = G.GAME.SuitBuffs[suit].level, chips=number_format(G.GAME.SuitBuffs[suit].chips) })
        delay(1.3)
        update_hand_text(
        { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
        vals_after_level or { mult = 0, chips = 0, handname = "", level = "" }
        )
    end
end

local get_chips_ref = Card.get_chip_bonus
function Card:get_chip_bonus(...)
    return get_chips_ref(self, ...) + (self.ability.suit_bonus or 0)
end