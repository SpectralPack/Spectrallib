--#region Important Functions
Spectrallib.BonusEffects = {}
Spectrallib.BonusEffect = SMODS.GameObject:extend{
    obj_buffer = {},
    obj_table = Spectrallib.BonusEffects,
    set = "BonusEffects",
    class_prefix = "sbe", --spectrallib bonus effect
    required_params = {
        "key",
    },
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        self.name = self.name or self.key
        Spectrallib.BonusEffect.super.register(self)
    end,
    inject = function () end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.Other, self.key, self.loc_txt)
    end,
    apply = function (self, card, config, index)
        local eff_table = { key = self.key, config = config or {}, }
        if index and #card.ability.slib_bonus_effects >= index then
            table.insert(card.ability.slib_bonus_effects, index, eff_table)
        else
            card.ability.slib_bonus_effects[#card.ability.slib_bonus_effects+1] = eff_table
        end
        if type(self.on_apply) == "function" then
            self:on_apply(card, eff_table)
        end
        if card.added_to_deck and type(self.add_to_deck) == "function" then
            self:add_to_deck(card, eff_table)
        end
    end,
    remove = function (self, card, eff_table, index)
        if type(self.on_remove) == "function" then
            self:on_remove(card, eff_table)
        end
        if card.added_to_deck and type(self.remove_from_deck) == "function" then
            self:remove_from_deck(card, eff_table)
        end
        table.remove(card.ability.slib_bonus_effects, index)
    end
}

---Adds a given Spectrallib.BonusEffect to a given card
---@param card Card|balatro.Card the card object to add the effect to
---@param key string the key of the BonusEffect to add to the card. class prefix may be omitted
---@param config table the config table for the BonusEffect to recieve
---@param forced_index integer? index to insert the effect at. ignored if greater than the total number of effects on the card
function Spectrallib.add_bonus_effect(card, key, config, forced_index)
    if key:sub(0, 4) ~= "sbe_" then --allow omitting class prefix
        key = "sbe_"..key
    end
    local obj = Spectrallib.BonusEffects[key]
    assert(obj, "Could not apply bonus effect "..key.."; Does not exist")
    obj:apply(card, config, forced_index)
end

---Removes the Spectrallib.BonusEffect at given index,<br>
---running `table.remove(card.ability.slib_bonus_effects, index)`<br>
---along with the necessary other functions.<br>
---If no effect exists at the given index, does nothing.
---@param card Card|balatro.Card
---@param index integer
function Spectrallib.remove_bonus_effect(card, index)
    local eff_table = card.ability.slib_bonus_effects[index]
    if not eff_table then return end
    local obj = Spectrallib.BonusEffects[eff_table.key]
    obj:remove(card, eff_table, index)
end

-- Run add_to_deck and remove_from_deck effects for BonusEffects. Will likely not work very well for playing cards

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    if not self.added_to_deck then
        for _, v in ipairs(self.ability.slib_bonus_effects) do
            local obj = Spectrallib.BonusEffects[v.key]
            if obj and type(obj.add_to_deck) == "function" then
                obj:add_to_deck(self, v, from_debuff)
            end
        end
    end
    add_to_deck_ref(self, from_debuff)
end

local remove_from_deck_ref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    if self.added_to_deck then
        for _, v in ipairs(self.ability.slib_bonus_effects) do
            local obj = Spectrallib.BonusEffects[v.key]
            if obj and type(obj.remove_from_deck) == "function" then
                obj:remove_from_deck(self, v, from_debuff)
            end
        end
    end
    remove_from_deck_ref(self, from_debuff)
end

local calc_joker_ref = Card.calculate_joker
function Card:calculate_joker(context, ...)
    local ret, triggered = calc_joker_ref(context, ...)
    local bonus = Spectrallib.calculate_bonus_effects(self, context)
    if ret == true then
        ret = { remove = true }
    end
    local final = SMODS.merge_effects(ret or {}, bonus)
    return final, triggered
end

function Spectrallib.calculate_bonus_effects(card, context)
    local bonus_ret = {}
    for _, eff_table in ipairs(card.ability.slib_bonus_effects) do
        local obj = Spectrallib.BonusEffects[eff_table.key]
        if type(obj.calculate) == "function" then
            bonus_ret[#bonus_ret+1] = obj:calculate(card, eff_table, context)
        end
    end
    return SMODS.merge_effects(bonus_ret)
end

function Spectrallib.add_bonus_effect_boxes(_c, info_queue, card, desc_nodes, specific_vars, full_UI_table, ability)
    local bonuses = ability and ability.slib_bonus_effects or {}
    local num = full_UI_table.multi_box and #full_UI_table.multi_box + 1 or 1
    for _, eff_table in ipairs(bonuses) do
        local obj = Spectrallib.BonusEffects[eff_table.key]
        if obj then
            local i = num + 1
            local card_arg = next(card) and card or { ability = ability } --eh
            local loc_args = type(obj.loc_vars) == "function" and obj:loc_vars(info_queue, card_arg, eff_table) or {}
            local set = loc_args.set or "Other"
            local key = loc_args.key or obj.key
            local desc_text = (G.localization.descriptions[set][key] or {}).text
            if desc_text then
                Spectrallib.generate_ui_multiboxes({ {
                    localized_text = desc_text,
                    loc_vars = function()
                        return loc_args
                    end
                }})(_c, info_queue, card, desc_nodes, specific_vars, full_UI_table)
            end
        end
    end
end

-- I have no clue what any of this does

function Spectrallib.create_vtext(vtext, AUT, nodes, vars, lines, num)
    local localize_args = {
        AUT = AUT,
        nodes = nodes,

        vars = vars
    }
    -- taken from localize; adds the multibox
    localize_args.AUT.multi_box = localize_args.AUT.multi_box or {}
    local i = num + 1 -- fucking janky ass method
    G.AUT = AUT
    for j, line in ipairs(lines) do
        local final_line = SMODS.localize_box(line, localize_args)
        if i == 1 or next(AUT.info) then
            nodes[#nodes+1] = final_line -- Sends main box to AUT.main
            if not next(AUT.info) then nodes.main_box_flag = true end
        elseif not next(AUT.info) then 
            nodes.main_box_flag = true
            AUT.multi_box[i-1] = AUT.multi_box[i-1] or {}
            AUT.multi_box[i-1][#AUT.multi_box[i-1]+1] = final_line
        end
        if not next(AUT.info) and vars.box_colours then AUT.box_colours[i] = vars.box_colours and vars.box_colours[i] or G.C.UI.BACKGROUND_WHITE end
    end
end

function Spectrallib.generate_ui_multiboxes(args2)
    return function(center, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        -- if not full_UI_table.box_colours then return end
        local num = full_UI_table.multi_box and #full_UI_table.multi_box + 1 or 1
        for i, args in pairs(args2) do
            if not args.func or args:func(card) then
                local keys = type(args.key) == "table" and args.key or {args.key}
                for _, k in pairs(keys) do
                    local vars = args.loc_vars and (args:loc_vars({}, card) or {}).vars or {}
                    local lines = SMODS.shallow_copy(G.localization.misc.v_dictionary_parsed[k] or {})
                    local vtext = localize{ type = "variable", key = k, vars = vars } -- the var doesn't matter here
                    Spectrallib.create_vtext(vtext, full_UI_table, desc_nodes, vars, lines, num)
                    if args.seperate_boxes then
                        num = num + 1
                    end
                end
                local texts = type(args.localized_text) == "table" and args.localized_text or {args.localized_text}
                for _, k in pairs(texts) do
                    local vars = args.loc_vars and (args:loc_vars({}, card) or {}).vars or {}
                    local vtext = type(k) == "string" and {k} or k or {}
                    Spectrallib.parse_string(vtext)
                    Spectrallib.create_vtext(nil, full_UI_table, desc_nodes, vars, vtext, num)
                    if args.seperate_boxes then
                        num = num + 1
                    end
                end
                if not args.seperate_boxes then
                    num = num + 1
                end
            end
        end
    end
end

function Spectrallib.parse_string(text)
    for i, v in pairs(text) do
        if type(v) == "table" then
            Spectrallib.parse_string(v)
        else
            text[i] = loc_parse_string(v)
        end
    end
end
--#endregion

--#region Object Definitions

local calc_keys = {
    "xchips", "echips", "eq_chips", "xlog_chips", "xmult", "emult", "eq_mult", "xlog_mult",
    "x_asc", "exp_asc", "score", "xscore", "escore", "xblindsize", "eblindsize",
}
local plus_keys = {
    "chips", "mult", "asc", "score", "blindsize"
}
local function generic_loc_vars(_, _, _, eff_table)
    return { vars = { eff_table.config.extra } }
end

for _, v in ipairs(plus_keys) do
    Spectrallib.BonusEffect {
        key = v,
        calculate = function(self, card, eff_table, context)
            if context.joker_main or (context.main_scoring and context.cardarea == G.play) then
                return { [v] = eff_table.config.extra }
            end
        end,
        loc_vars = function(self, info_queue, card, eff_table)
            return { vars = { SMODS.signed(eff_table.config.extra) } }
        end
    }
end

for _, v in ipairs(calc_keys) do
    Spectrallib.BonusEffect {
        key = v,
        calculate = function(self, card, eff_table, context)
            if context.joker_main or (context.main_scoring and context.cardarea == G.play) then
                return { [v] = eff_table.config.extra }
            end
        end,
        loc_vars = generic_loc_vars
    }
end

for _, v in ipairs({"balance", "swap"}) do
    Spectrallib.BonusEffect {
        key = v,
        calculate = function (self, card, eff_table, context)
            if context.joker_main or (context.main_scoring and context.cardarea == G.play) then
                return { [v] = true }
            end
        end
    }
end

Spectrallib.BonusEffect {
    key = "partial_swap",
    loc_vars = function (self, info_queue, card, eff_table)
        return { vars = { Spectrallib.clamp(eff_table.config.extra, 0, 1) * 100 }}
    end,
    calculate = function (self, card, eff_table, context)
        if context.joker_main or (context.main_scoring and context.cardarea == G.play) then
            return { cry_broken_swap = eff_table.config.extra }
        end
    end
}

Spectrallib.BonusEffect {
    key = "hands",
    loc_vars = generic_loc_vars,
    add_to_deck = function (self, card, eff_table)
        ease_hands_played(eff_table.config.extra)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + eff_table.config.extra
    end,
    remove_from_deck = function (self, card, eff_table)
        ease_hands_played(-eff_table.config.extra)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - eff_table.config.extra
    end
}

Spectrallib.BonusEffect {
    key = "discards",
    loc_vars = generic_loc_vars,
    add_to_deck = function (self, card, eff_table)
        ease_discard(eff_table.config.extra)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + eff_table.config.extra
    end,
    remove_from_deck = function (self, card, eff_table)
        ease_discard(-eff_table.config.extra)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - eff_table.config.extra
    end
}

Spectrallib.BonusEffect {
    key = "h_size",
    loc_vars = generic_loc_vars,
    add_to_deck = function (self, card, eff_table)
        G.hand:change_size(eff_table.config.extra)
    end,
    remove_from_deck = function (self, card, eff_table)
        G.hand:change_size(-eff_table.config.extra)
    end,
}

Spectrallib.BonusEffect {
    key = "consumable_slot",
    loc_vars = generic_loc_vars,
    add_to_deck = function (self, card, eff_table)
        G.consumeables:change_size(eff_table.config.extra)
    end,
    remove_from_deck = function (self, card, eff_table)
        G.consumeables:change_size(-eff_table.config.extra)
    end,
}

Spectrallib.BonusEffect {
    key = "joker_slot",
    loc_vars = generic_loc_vars,
    add_to_deck = function (self, card, eff_table)
        G.jokers:change_size(eff_table.config.extra)
    end,
    remove_from_deck = function (self, card, eff_table)
        G.jokers:change_size(-eff_table.config.extra)
    end,
}

Spectrallib.BonusEffect {
    key = "cashout",
    loc_vars = function (self, info_queue, card, eff_table)
        return { vars = { eff_table.config.extra } }
    end,
    calculate = function (self, card, eff_table, context)
        if context.modify_final_cashout and not card.playing_card then
            return {
                modify = eff_table.config.extra
            }
        end
    end
}

--#endregion