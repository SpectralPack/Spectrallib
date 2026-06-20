---@meta
-- DO NOT LOAD! (There's nothing to load, anyways)
---@diagnostic disable: duplicate-doc-alias

-- Comments _above_ class fields are notes for said field.
-- This format is preferred to reduce file horizontal length.

---@class get_suit_bonus_table.item
---@field key string The suit's key.
---@field loc_key string The localization key of the suit's name.
---@field level number The suit's level.
---@field chips number The suit's bonus chips.
---@field mult number The suit's bonus mult.

---@class get_rank_bonus_table.item
---@field key string The rank's key.
---@field loc_key string The localization key of the rank's name.
---@field level number The rank's level.
---@field chips number The rank's bonus chips.
---@field mult number The rank's bonus mult.

---@class Card
-- Redeems a deck and plays the corresponding animation.
---@field redeem_deck? fun(): nil
-- Get the total amount of bonus chips from all of the card's suits.
---@field get_suit_bonus? fun(): number
-- Get the total amount of bonus mult from all of the card's suits.
---@field get_suit_mult? fun(): number
-- Get a list of bonuses applied to each of a card's suits.
---@field get_suit_bonus_table? fun(): get_suit_bonus_table.item[]
-- Calls the `unredeem` method of the card's center (if defined) and plays the corresponding animation.
-- Get the total amount of bonus chips from all of the card's suits.
---@field get_rank_bonus? fun(): number
-- Get the total amount of bonus mult from all of the card's suits.
---@field get_rank_mult? fun(): number
-- Get a list of bonuses applied to each of a card's suits.
---@field get_rank_bonus_table? fun(): get_suit_bonus_table.item[]
-- Calls the `unredeem` method of the card's center (if defined) and plays the corresponding animation.
---@field unredeem? fun(): nil
-- Calls the `unredeem` method of the card's center (if defined).
-- If `center` is defined, *its* `unredeem` method is called instead.
---@field unapply_to_run? fun(center?: SMODS.Center): nil

---@class SMODS.Blind
-- Calculates effects that occur before scoring a hand.
---@field before_play? fun(self: SMODS.Blind|table)
-- Calculates effects that occur after scoring a hand.
---@field after_play? fun(self: SMODS.Blind|table)
---@field ante_base_mod? fun(self: SMODS.Blind|table, dt: number): number TODO document this
---@field round_base_mod? fun(self: SMODS.Blind|table, dt: number): number TODO document this
---@field modify_score? fun(self: SMODS.Blind|table, score: number): number TODO document this
---@field cap_score? fun(self: SMODS.Blind|table, score: number): number TODO document this
-- The returned list of keys are of blinds whose effects are copied by the main blind.
---@field get_copied_blinds? fun(self: SMODS.Blind|table, blind: Blind): string[]

---@class SMODS.Center
-- Calculate the amount of interest the player should earn.
-- The return number is the final interest value assuming no other sources will affect interest.
---@field calculate_interest? fun(self: SMODS.Center|table, card: Card|table, interest: number): number

---@class SMODS.Joker
-- If true, Joker is forcetriggerable.
---@field forcetrigger_compat? boolean

---@class SMODS.Consumable
-- If true, consumable is forcetriggerable.
---@field forcetrigger_compat? boolean
--- Defines behaviour when this consumable is used via a forcetrigger.
---@field force_use? fun(self: SMODS.Consumable|table, card: Card|table, area: CardArea|table)

---@class CalcContext
-- Check if `true` for forcetrigger effects.
---@field forcetrigger? boolean