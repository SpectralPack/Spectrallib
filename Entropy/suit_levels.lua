-----------------------------
-- SUPPLEMENTARY FUNCTIONS --
-----------------------------

local function uht_snd(volume, pitch, delay)
    return {
        sound = "button", volume = volume,
        pitch = pitch, delay = delay
    }
end

local function JUICE_CARD_EVENT(card, delay)
    Spectrallib.event{
        function ()
            play_sound('tarot1')
            if card and card.juice_up then
                card:juice_up(0.8, 0.5)
            end
            G.TAROT_INTERRUPT_PULSE = nil
            return true
        end,
        trigger = 'after',
        delay = delay or 0.9
    }
end

local function generate_suit_bonus_tbl(card, suit_key)
    local buff = G.GAME.SuitBuffs[suit_key]
    local check_suitless = suit_key == "suitless"

    if (check_suitless and not Spectrallib.true_suitless(card)) or (not check_suitless and not card:is_suit(suit_key)) or (
        buff.level == 1
        and buff.chips == 0
        and buff.mult == 0
    ) then return end

    local loc_key = "entr_card_suit_level"
    if buff.chips == 0 and buff.mult ~= 0 then
        loc_key = "entr_card_suit_level_mult"
    elseif buff.mult == 0 and buff.chips ~= 0 then
        loc_key = "entr_card_suit_level_chips"
    end

    return {
        level = buff.level,
        chips = buff.chips, mult = buff.mult,
        key = suit_key, loc_key = loc_key
    }
end

local function generate_rank_bonus_tbl(card, rank_key)
    local buff = G.GAME.RankBuffs[rank_key]
    local check_rankless = rank_key == "rankless"

    if (check_rankless and not SMODS.has_no_rank(card)) or (not check_rankless and card:get_id() ~= SMODS.Ranks[rank_key].id) or (
        buff.level == 1
        and buff.chips == 0
        and buff.mult == 0
    ) then return end

    local loc_key = "entr_card_suit_level"
    if buff.chips == 0 and buff.mult ~= 0 then
        loc_key = "entr_card_suit_level_mult"
    elseif buff.mult == 0 and buff.chips ~= 0 then
        loc_key = "entr_card_suit_level_chips"
    end

    return {
        level = buff.level,
        chips = buff.chips, mult = buff.mult,
        key = rank_key, loc_key = loc_key
    }
end

-----------------------------
-- THE LEVELLING FUNCTIONS --
-----------------------------

---Levels up a suit.
---@param suit string|Suits|'suitless' The suit key to be leveled up. Can be `suitless` to level up suitless cards.
---@param card table|Card The card to play the animation on.
---@param level_amt? number The amount of levels to upgrade by.
---@param chips_override? number The amount of chips per level. Defaults to `10` if not set.
---@param mult? number The amount of mult per level. Defaults to `0` if not set.
---@param instant? boolean If `true`, skips the animation (similar to `level_up_hand` in vanilla).
---@param display_all? boolean If `true`, parameters with a level up amount of `0` will not be displayed as `...` during the animation.
---@return nil
function Spectrallib.level_suit(suit, card, level_amt, chips_override, mult, instant, display_all)
    level_amt = level_amt or 1

    local hide = {}
    if (
        chips_override == 0
        and not (hide.chips or display_all)
    ) then hide.chips = "..." end
    if (
        (not mult or mult == 0)
        and not (hide.mult or display_all)
    ) then hide.mult = "..." end

    if not G.GAME.SuitBuffs then G.GAME.SuitBuffs = {} end
    if not G.GAME.SuitBuffs[suit] then
        G.GAME.SuitBuffs[suit] = {level = 1, chips = 0, mult = 0}
    end
    local suit_values = G.GAME.SuitBuffs[suit]
    if not suit_values.level then suit_values.level = 1 end
    if not suit_values.chips then suit_values.chips = 0 end
    if not suit_values.mult  then suit_values.mult  = 0 end

    if instant then
        suit_values.level = suit_values.level + level_amt
        suit_values.chips = suit_values.chips + (chips_override or 10)*level_amt
        suit_values.mult  = suit_values.mult  + (mult or 0)*level_amt
        return
    end

    -- Animations for not-instant

    --for properly resetting to previous hand display when leveling in scoring
    local vals_after_level = { -- default
        mult = 0, chips = 0,
        handname = "", level = ""
    }
    if SMODS.displaying_scoring then
        vals_after_level = copy_table(G.GAME.current_round.current_hand)
        local text,disp_text,_,_,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
        vals_after_level.handname = disp_text or ''
        vals_after_level.level = (G.GAME.hands[text] or {}).level or ''
        for name, param in pairs(SMODS.Scoring_Parameters) do
            vals_after_level[name] = param.current
        end
    end

    update_hand_text(uht_snd(0.7, 0.8, 0.3), {
        handname = localize(suit,'suits_plural'),
        chips = hide.chips or number_format(suit_values.chips),
        mult = hide.mult or number_format(suit_values.mult),
        level = suit_values.level
    })

    suit_values.level = suit_values.level + level_amt
    suit_values.chips = suit_values.chips + (chips_override or 10)*level_amt
    suit_values.mult  = suit_values.mult  + (mult or 0)*level_amt

    JUICE_CARD_EVENT(card)
    if chips_override ~= 0 then
        update_hand_text(uht_snd(0.7, 0.9, 0), {
            chips = "+" .. number_format((chips_override or 10)*level_amt),
            StatusText = true
        })
    end
    JUICE_CARD_EVENT(card)
    if mult then
        update_hand_text(uht_snd(0.7, 0.9, 0), {
            mult = "+" .. number_format(mult*level_amt),
            StatusText = true
        })
    end
    JUICE_CARD_EVENT(card)
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        level = suit_values.level,
        chips = not hide.chips and number_format(suit_values.chips) or nil,
        mult  = not hide.mult and number_format(suit_values.mult) or nil
    })
    delay(1.3)
    update_hand_text(uht_snd(0.7, 1.1, 0), vals_after_level)
end

-- Spectrallib.level_rank("King", G.deck, 1, 12, 3)

---Levels up a rank.
---@param rank string|Ranks|'rankless' The rank key to be leveled up. Can be `rankless` to level up rankless cards.
---@param card table|Card The card to play the animation on.
---@param level_amt? number The amount of levels to upgrade by.
---@param chips? number The amount of chips per level. Defaults to `0` if not set.
---@param mult? number The amount of mult per level. Defaults to `2` if not set.
---@param instant? boolean If `true`, skips the animation (similar to `level_up_hand` in vanilla).
---@param display_all? boolean If `true`, parameters with a level up amount of `0` will not be displayed as `...` during the animation.
---@return nil
function Spectrallib.level_rank(rank, card, level_amt, chips, mult, instant, display_all)
    level_amt = level_amt or 1

    local hide = {}
    if (
        chips == 0
        and not (hide.chips or display_all)
    ) then hide.chips = "..." end
    if (
        (not mult or mult == 0)
        and not (hide.mult or display_all)
    ) then hide.mult = "..." end

    if not G.GAME.RankBuffs then G.GAME.RankBuffs = {} end
    if not G.GAME.RankBuffs[rank] then
        G.GAME.RankBuffs[rank] = {level = 1, chips = 0, mult = 0}
    end
    local rank_values = G.GAME.RankBuffs[rank]
    if not rank_values.level then rank_values.level = 1 end
    if not rank_values.chips then rank_values.chips = 0 end
    if not rank_values.mult  then rank_values.mult  = 0 end

    if instant then
        rank_values.level = rank_values.level + level_amt
        rank_values.chips = rank_values.chips + (chips or 10)*level_amt
        rank_values.mult  = rank_values.mult  + (mult or 0)*level_amt
        return
    end

    -- Animations for not-instant

    --for properly resetting to previous hand display when leveling in scoring
    local vals_after_level = { -- default
        mult = 0, chips = 0,
        handname = "", level = ""
    }
    if SMODS.displaying_scoring then
        vals_after_level = copy_table(G.GAME.current_round.current_hand)
        local text,disp_text,_,_,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
        vals_after_level.handname = disp_text or ''
        vals_after_level.level = (G.GAME.hands[text] or {}).level or ''
        for name, param in pairs(SMODS.Scoring_Parameters) do
            vals_after_level[name] = param.current
        end
    end

    update_hand_text(uht_snd(0.7, 0.8, 0.3), {
        handname = localize(rank, 'ranks'),
        chips = hide.chips or number_format(rank_values.chips),
        mult = hide.mult or number_format(rank_values.mult),
        level = rank_values.level
    })

    rank_values.level = rank_values.level + level_amt
    rank_values.chips = rank_values.chips + (chips or 10)*level_amt
    rank_values.mult  = rank_values.mult  + (mult or 0)*level_amt

    JUICE_CARD_EVENT(card)
    if chips ~= 0 then
        update_hand_text(uht_snd(0.7, 0.9, 0), {
            chips = "+" .. number_format((chips or 10)*level_amt),
            StatusText = true
        })
    end
    JUICE_CARD_EVENT(card)
    if mult then
        update_hand_text(uht_snd(0.7, 0.9, 0), {
            mult = "+" .. number_format(mult*level_amt),
            StatusText = true
        })
    end
    JUICE_CARD_EVENT(card)
    update_hand_text(uht_snd(0.7, 0.9, 0), {
        level = rank_values.level,
        chips = not hide.chips and number_format(rank_values.chips) or nil,
        mult  = not hide.mult and number_format(rank_values.mult) or nil
    })
    delay(1.3)
    update_hand_text(uht_snd(0.7, 1.1, 0), vals_after_level)
end

------------------
-- CARD METHODS --
------------------

-- Get bonus chips from the level of the card's suit.
---@return number
function Card:get_suit_bonus()
    local bonus = 0
    for k in pairs(SMODS.Suits) do
        if self:is_suit(k) then
            bonus = bonus + G.GAME.SuitBuffs[k].chips
        end
    end
    if Spectrallib.true_suitless(self) then
        bonus = bonus + G.GAME.SuitBuffs.suitless.chips
    end
    return bonus
end

-- Get bonus mult from the level of the card's suit.
---@return number
function Card:get_suit_mult()
    local bonus = 0
    for k in pairs(SMODS.Suits) do
        if self:is_suit(k) then
            bonus = bonus + G.GAME.SuitBuffs[k].mult
        end
    end
    if Spectrallib.true_suitless(self) then
        bonus = bonus + G.GAME.SuitBuffs.suitless.mult
    end
    return bonus
end

-- Get suit level information of the card's suit.
---@return {level: number, chips: number, mult: number, key: string, loc_key: string}[]
function Card:get_suit_bonus_table()
    if not G.GAME.SuitBuffs then return {} end
    local card_suit_bonuses = {}

    for _, suit_key in ipairs(SMODS.Suit.obj_buffer) do
        local suit_bonus_tbl = generate_suit_bonus_tbl(self, suit_key)
        if suit_bonus_tbl then
            table.insert(card_suit_bonuses, suit_bonus_tbl)
        end
    end

    local suitless_bonus_tbl = generate_suit_bonus_tbl(self, "suitless")
    if suitless_bonus_tbl then
        table.insert(card_suit_bonuses, suitless_bonus_tbl)
    end

    return card_suit_bonuses
end

-- Get bonus chips from the level of the card's rank.
---@return number
function Card:get_rank_bonus()
    local bonus = 0
    if SMODS.has_no_rank(self) then
        bonus = bonus + G.GAME.RankBuffs.rankless.chips
    else
        for k in pairs(SMODS.Ranks) do
            if self:get_id() == SMODS.Ranks[k].id then
                bonus = bonus + G.GAME.RankBuffs[k].chips
            end
        end
    end
    return bonus
end

-- Get bonus mult from the level of the card's rank.
---@return number
function Card:get_rank_mult()
    local bonus = 0
    if SMODS.has_no_rank(self) then
        bonus = bonus + G.GAME.RankBuffs.rankless.mult
    else
        for k in pairs(SMODS.Ranks) do
            if self:get_id() == SMODS.Ranks[k].id then
                bonus = bonus + G.GAME.RankBuffs[k].mult
            end
        end
    end
    return bonus
end

-- Get rank level information of the card's rank.
---@return {level: number, chips: number, mult: number, key: string, loc_key: string}[]
function Card:get_rank_bonus_table()
    if not G.GAME.RankBuffs then return {} end
    local card_rank_bonuses = {}

    for _, rank_key in ipairs(SMODS.Rank.obj_buffer) do
        local rank_bonus_tbl = generate_rank_bonus_tbl(self, rank_key)
        if rank_bonus_tbl then
            table.insert(card_rank_bonuses, rank_bonus_tbl)
        end
    end

    local rankless_bonus_tbl = generate_rank_bonus_tbl(self, "rankless")
    if rankless_bonus_tbl then
        table.insert(card_rank_bonuses, rankless_bonus_tbl)
    end

    return card_rank_bonuses
end

-----------
-- HOOKS --
-----------

-- Hook to add suit bonus chips to card bonus chips
local get_chips_ref = Card.get_chip_bonus
function Card:get_chip_bonus(...)
    if self.ability.extra_enhancement then return self.ability.bonus end
    return get_chips_ref(self, ...) + self:get_suit_bonus() + self:get_rank_bonus()
end

-- Hook to add suit bonus mult to card bonus mult
local get_mult_ref = Card.get_chip_mult
function Card:get_chip_mult()
    return get_mult_ref(self) + self:get_suit_mult() + self:get_rank_mult()
end

-- If consumable defines `level_suit` in its config table, level up suit when used. Same thing for `level_rank`
-- (Akin to `hand_type`)
local use_ref = Card.use_consumeable
function Card:use_consumeable(area, copier)
    use_ref(self, area, copier)
    local obj = self.config.center
    if obj.use then return end
    if self.ability.consumeable.level_suit then
        Spectrallib.level_suit(self.ability.consumeable.level_suit, self, 1, self.ability.consumeable.suit_chips or 0, self.ability.consumeable.suit_mult, nil, true)
    end
    if self.ability.consumeable.level_rank then
        Spectrallib.level_rank(self.ability.consumeable.level_rank, self, 1, self.ability.consumeable.rank_chips or 0, self.ability.consumeable.rank_mult, nil, true)
    end
end
