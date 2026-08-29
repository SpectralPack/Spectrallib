-- Check if a mod or list of mods (via their keys) can load.
---@param ... string|string[] Mod key or mod keys.
---@return true|nil
function Spectrallib.can_mods_load(...)
    local mods = {...}
    if type(mods[1]) == "table" then
        mods = mods[1] --[[@as string[] ]]
    end
    for _,mod_key in pairs(mods) do
        if (SMODS.Mods[mod_key] or {}).can_load then return true end
    end
end

-- Check if an optional feature is enabled by *any* enabled mod.
---@param key string
---@return true|nil
function Spectrallib.optional_feature(key)
    for _,mod in pairs(SMODS.Mods) do
        if (
            mod.can_load
            and mod.spectrallib_features
            and Spectrallib.in_table(mod.spectrallib_features, key)
        ) then return true end
    end
end

---@param amt number
---@return nil
function Spectrallib.mod_score(amt) --good version
    G.SCORE_DISPLAY_QUEUE = G.SCORE_DISPLAY_QUEUE or {}
    table.insert(G.SCORE_DISPLAY_QUEUE,G.GAME.chips)
    G.GAME.chips = amt
end

---@param amt number
---@return nil
function Spectrallib.mod_blindsize(amt) --good version
    G.BLIND_SIZE_DISPLAY_QUEUE = G.BLIND_SIZE_DISPLAY_QUEUE or {}
    table.insert(G.BLIND_SIZE_DISPLAY_QUEUE,G.GAME.blind.chips)
    G.GAME.blind.chips = amt
end

---@class Spectrallib.redeem_animation.cfg
---@field colour? [number, number, number, number] Text colour. Defaults to white.
---@field scale? number Text scale. Defaults to 0.9.
---@field sounds? string[] The keys of sounds to play during the animation. Defaults to `{'card1', 'coin1'}`.
---@field top_txt? string|any Text to display at the top. Defaults to `card`'s name.
---@field btm_txt? string|any Text to display at the bottom. Defaults to the localization of "Redemed!"
---@field during_func? function A function to run after displaying text, but before removing it.

-- Play the voucher redeem animation, with customization options.
---@param card Card
---@param cfg Spectrallib.redeem_animation.cfg
---@return nil
function Spectrallib.redeem_animation(card, cfg)
    cfg.colour = cfg.colour or G.C.WHITE
    cfg.scale  = cfg.scale or 0.9
    cfg.sounds = cfg.sounds or {'card1', 'coin1'}
    cfg.top_txt = cfg.top_txt or localize({
        type = 'name_text',
        set = card.config.center.set,
        key = card.config.center.key
    })
    cfg.btm_txt = localize('k_redeemed_ex')

    local function redeem_dynatext(args)
        return DynaText {
            colours = { cfg.colour }, scale = cfg.scale,
            shadow = true, bump = true, float = true,

            string = args.string,
            rotate = args.rotate,
            pop_in = args.pop_in / G.SPEEDFACTOR,
            pop_in_rate = 1.5 * G.SPEEDFACTOR,
            pitch_shift = args.pitch_shift
        }
    end
    local function redeem_uibox(pos, dynatext)
        return UIBox({
            definition =
            {n=G.UIT.ROOT, config={ align="tm", r=0.15, colour=G.C.CLEAR, padding=0.15 }, nodes={
                {n=G.UIT.O, config={ object=dynatext } },
            }},
            config = {
                align = pos,
                offset = {x=0, y=0},
                parent = card
            },
        })
    end

    card.states.hover.can = false
    local top_dynatext, btm_dynatext

    Spectrallib.event{
        function ()
            top_dynatext = redeem_dynatext{
                string = cfg.top_txt,
                rotate = 1, pop_in = 0.6
            }
            btm_dynatext = redeem_dynatext{
                string = cfg.btm_txt,
                rotate = 2, pop_in = 1.4,
                pitch_shift = 0.25,
            }

            card:juice_up(0.3, 0.5)
            for _,sound_key in ipairs(cfg.sounds) do
                play_sound(sound_key)
            end

            card.children.top_disp = redeem_uibox("tm", top_dynatext)
            card.children.bot_disp = redeem_uibox("bm", btm_dynatext)

            return true
        end,
        trigger = 'after',
        delay = 0.4,
    }

    if cfg.during_func then cfg.during_func() end

    Spectrallib.event(0.6)
    Spectrallib.event{
        function ()
            top_dynatext:pop_out(4)
            btm_dynatext:pop_out(4)
            return true
        end,
        trigger = 'after',
        delay = 2.6
    }
    Spectrallib.event{
        function ()
            card.children.top_disp:remove()
            card.children.top_disp = nil
            card.children.bot_disp:remove()
            card.children.bot_disp = nil
            return true
        end,
        trigger = 'after',
        delay = 0.5
    }
end

-- Get the interest rate;
-- intended to be hooked for additional sources.
---@return number
function Spectrallib.interest_rate()
    return 5
end

-- Calculate interest given the amount of currently held dollars.
---@param add_rows? any Unused
---@return number
function Spectrallib.get_interest(add_rows)
    local rate = Spectrallib.interest_rate()
    local interest = math.min(math.floor(G.GAME.dollars / rate), G.GAME.interest_cap / 5)
    interest = interest * G.GAME.interest_amount
    for card in Spectrallib.iter.areacards(SMODS.get_card_areas("jokers")) do
        if card.config.center.calculate_interest then
            interest = card.config.center:calculate_interest(card, interest)
        elseif card.config.center.cry_calc_interest then
            interest = card.config.center:cry_calc_interest(card, interest)
        end
    end

    return interest
end

---------------
-- ITERATORS --
---------------

Spectrallib.iter = {}

local blinds_warn = "[SPLIB.ITER.BLINDS] Blind %s is not defined!"
local areacards_warn = "[SPLIB.ITER.AREACARDS] Cardlist %s is not a cardlist!"
local areacards_warn_onelist = "[SPLIB.ITER.AREACARDS] Card %s is not a card!"
local areacards_warn_manylist = "[SPLIB.ITER.AREACARDS] Card %s in cardlist %s is not a card!"

-- Iterator function: On each blind key, return the blind prototype.
-- Can either input keys as separate args, or in a table in one single arg.
---@param ... string|string[] List of blind keys.
---@return fun(): (SMODS.Blind|table|nil)
function Spectrallib.iter.blinds(...)
    ---@diagnostic disable-next-line: param-type-mismatch
    local blind_keys = #... == 1 and ... or {unpack(...)}
    local i = 0
    return function ()
        while true do
            i = i + 1
            if i > #blind_keys then return end
            local blind_key = blind_keys[i]
            local blind_proto = G.P_BLINDS[blind_key]
            if blind_proto then
                return blind_proto
            else
                sendWarnMessage(blinds_warn:format(blind_key))
            end
        end
    end
end

---@alias IterableCardList Card[]|CardArea Can be iterated by Spectrallib.iter.areacards

-- Iterator function: Iterate through each card in each collection of cards.
-- Can either input keys as separate args, or in a table in one single arg.
---@param ... IterableCardList|IterableCardList[]
---| `CardArea`   # Iterate through each card in the `cards` property
---| `Card[]`     # Iterate through each card
---@return fun(): (Card|table|nil)
function Spectrallib.iter.areacards(...)
    local a,b = ...
    local areas
    if type(a) == "table" and not b then
        areas = a
    else
        areas = {...}
    end

    local card_i = 0
    local cardlist
    if getmetatable(areas[1]) == Card then
        cardlist = areas
    elseif getmetatable(areas) == CardArea then
        cardlist = areas.cards
    elseif #areas == 0 then
        return function () end
    end

    -- Simple case: Input is a cardlist
    if cardlist ~= nil then
        return function ()
            while true do
                card_i = card_i + 1
                if card_i > #cardlist then return end
                local card = cardlist[card_i]
                if getmetatable(card) == Card then
                    return card
                else
                    sendWarnMessage(areacards_warn_onelist:format(card_i))
                end
            end
        end
    end

    -- Complex case: Input is a list of cardlists
    local area_i = 0
    return function()
        while true do
            while cardlist == nil do
                area_i = area_i + 1
                if area_i > #areas then return end -- Halt
                local target = areas[area_i]
                if getmetatable(target) == CardArea then
                    cardlist = target.cards
                elseif type(target) == "table" then
                    cardlist = target
                elseif target ~= nil then
                    sendWarnMessage(areacards_warn:format(area_i))
                end
                if cardlist and #cardlist <= 0 then cardlist = nil end
            end
            card_i = card_i + 1
            if card_i > #cardlist then
                card_i = 0
                cardlist = nil
            else
                local card = cardlist[card_i]
                if getmetatable(card) == Card then
                    return card -- Halt
                else
                    sendWarnMessage(areacards_warn_manylist:format(card_i, area_i))
                end
            end
        end
    end
end

-----------
-- HOOKS --
-----------

--allow selecting multiple jokers/consumables. should probably go elsewhere but since this is pretty generically useful to a lot of features idk where it would go
local start_run_ref = Game.start_run
function Game:start_run(args)
    start_run_ref(self, args)
    G.consumeables.config.highlighted_limit = 99
    G.jokers.config.highlighted_limit = 99
    if G.GAME.selected_back_key.use then
        G.GAME.selected_usable_deck = G.GAME.selected_back_key.key
        local cfg = Spectrallib.gather_button_config(G.P_CENTERS[G.GAME.selected_usable_deck] or G.GAME.selected_back_key)
        G.slib_active_deck_button = UIBox {
            definition = Spectrallib.create_UIBox_use_deck(cfg),
            config = { major = G.deck, align = 'tm', offset = { x = 0, y = -0.35 }, bond = 'Weak' }
        }
    end
end

G.FUNCS.slib_can_use_deck = function (e) --checks if the currently selected usable deck can be used.
    local center = G.P_CENTERS[G.GAME.selected_usable_deck] or G.GAME.selected_back_key
    local cfg = Spectrallib.gather_button_config(center)
    if
        center.can_use and center:can_use(e.config.ref_table) --and not e.config.ref_table.debuff --Decks can't be debuffed
        and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT
        and not (((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)))
    then
        e.config.colour = cfg.colour
        e.config.button = "slib_use_deck"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
G.FUNCS.slib_use_deck = function (e) --uses the currently selected usable deck.
    local int = G.TAROT_INTERRUPT
    G.TAROT_INTERRUPT = true
    local center = G.P_CENTERS[G.GAME.selected_usable_deck] or G.GAME.selected_back_key
    if center.use then
        center:use()
    end
    G.TAROT_INTERRUPT = int
end

-- Allow clicking the deck or any usable deck in the redeemed deck menu to change the deck that will be used + update the ui accordingly
local card_click = Card.click
function Card:click()
    card_click(self)
    if Spectrallib.safe_get(self, "area", "config", "slib_run_info_redeemed_decks") and self.config.center.use then
        self:juice_up()
        G.GAME.selected_usable_deck = self.config.center_key
        Spectrallib.update_deck_use_button()
    elseif G.deck and G.deck.cards and self == G.deck.cards[1] and G.GAME.selected_back_key.use then
        self:juice_up()
        G.GAME.selected_usable_deck = G.GAME.selected_back_key.key
        Spectrallib.update_deck_use_button()
    end
end
local cardarea_click = CardArea.click
function CardArea:click()
    cardarea_click(self)
    if self == G.deck and G.GAME.selected_back_key.use then
        self:juice_up()
        G.GAME.selected_usable_deck = G.GAME.selected_back_key.key
        Spectrallib.update_deck_use_button()
    end
end
function Spectrallib.update_deck_use_button()
    local cfg = Spectrallib.gather_button_config(G.P_CENTERS[G.GAME.selected_usable_deck] or G.GAME.selected_back_key)
    if G.GAME.selected_usable_deck and not G.slib_active_deck_button then
        G.slib_active_deck_button = UIBox {
            definition = Spectrallib.create_UIBox_use_deck(cfg),
            config = { major = G.deck, align = 'tm', offset = { x = 0, y = -0.35 }, bond = 'Weak' }
        }
    end
    local ui = G.slib_active_deck_button:get_UIE_by_ID("slib_use_deck_text")
    if ui then
        ui.config.text = localize(cfg.key)
        ui.config.text_drawable = nil
        ui.UIBox:recalculate()
    end
end

-- Fractional/negative ante support
local blindamt_ref = get_blind_amount
function get_blind_amount(ante)
    if not ante then return 0 end

    local ante_fraction = ante - math.floor(ante) -- 0 <= ante_fraction < 1
    if ante_fraction ~= 0 then
        local lower_bound = get_blind_amount(math.floor(ante))
        local upper_bound = get_blind_amount(math.floor(ante) + 1)
        return Spectrallib.blind_amount_interpolate(lower_bound, upper_bound, ante_fraction)
    elseif ante < 0 then
        -- -1 = 95
        -- -2 = 90.25
        -- -3 = 85.7375
        -- -4 = 81.45...
        -- As ante approaches -inf, blind amount approaches 0
        return Spectrallib.negative_ante_value(ante)
    else
        return blindamt_ref(ante)
    end
end

-- This function defines how values from `get_blind_amount` should be interpolated with fractional antes.
-- It uses linear interpolation.
-- This can be overridden if you do not want to use linear interpolation.
---@param lower number Given rational ante `x`, this is the blind amount on the integer ante directly before `x`.
---@param upper number Given rational ante `x`, this is the blind amount on the integer ante directly *after* `x`.
---@param percent number The "progress" made between `lower` and `upper`.
---@return number
function Spectrallib.blind_amount_interpolate(lower, upper, percent)
    return lower*(1-percent) + upper*percent
end

-- This function defines how values from `get_blind_amount` should be extrapolated with negative antes.
-- It follows the formula `100*0.95^(-ante).
-- `It can be overridden if you wish to use a different formula.
---@param ante integer
---@return number
function Spectrallib.negative_ante_value(ante)
    return 100*0.95^(-ante)
end

---Returns the colour to use in text or message colours for a given card's type.<br>
---By default, this is used for the number in the multiuse text and popup for multiuse ticking down.<br>
---Can be hooked if a card type's text/message colour should be different from its badge/type colour
---@param card Card
---@return [number, number, number, number]
function Spectrallib.get_text_colour(card, _c)
    local set = card and card.ability.set or _c.set
    if set == "Joker" then
        return G.C.FILTER
    end
    if set == "Code" then --back compat thingy
        return G.C.SET.Code
    end
    return get_type_colour(_c, card) or G.C.UI.TEXT_DARK
end

---Hookable function to modify the factor for ascension power. `base` is the base factor.<br>
---By default, takes into account the effect of Sol from Cryptid.<br>
---Note that this may be called outside of a run.
---@param base number
---@return number
function Spectrallib.get_ascension_factor(base)
    -- Sun number fallback (thing that Sol (Cryptid) increases)
	G.GAME.sunnumber = G.GAME.sunnumber or {not_modest = 0, modest = 0}
    local sun_number
    if type(G.GAME.sunnumber) == "table" then
		sun_number = G.GAME.sunnumber.not_modest or 0
    else
		sun_number = G.GAME.sunnumber
	end
    return base + sun_number + G.GAME.asc_factor_bonus
end

---Utility function that runs a get_id check for the given rank keys
---@param card Card card object to check the rank of
---@param rank_key string|Rank rank key to check the card against
---@return boolean
function Spectrallib.is_rank(card, rank_key)
    assert(SMODS.Ranks[rank_key], "Invalid rank key for Spectrallib.is_rank: "..rank_key)
    local id = SMODS.Ranks[rank_key].id
    return card:get_id() == id
end

local pool_ref = SMODS.add_to_pool
function SMODS.add_to_pool(prototype_obj, args)
    if G.GAME.slib_banished_keys[prototype_obj.key] then
        return false
    end
    return pool_ref(prototype_obj, args)
end

function Spectrallib.should_display_ban(card)
    if card.config.blind then
        return G.GAME.slib_banished_keys[card.config.blind.key]
    else
        return card.config.center_key ~= "c_base" and G.GAME.slib_banished_keys[card.config.center_key]
    end
end

---Gets a random poker hand
---@param include_hidden? boolean Wether roll should include currently non-visible hands
---@param seed? any RNG seed to use for polling
---@param in_pool? (fun(v: string, args: table): boolean?) in_pool function to pass into pseudorandom_element
---@param fallback? PokerHand|string? Fallback hand if no hand could be rolled, defaults to `High Card`
---@return PokerHand|string
function Spectrallib.get_random_hand(include_hidden, seed, in_pool, fallback)
    local hands = {}
    for _,name in ipairs(G.handlist) do
        if include_hidden or SMODS.is_poker_hand_visible(name) then
            hands[#hands+1] = name
        end
    end
    local hand = pseudorandom_element(hands, seed, {in_pool = in_pool})
    return hand or fallback or "High Card"
end

function Spectrallib.get_blind_font(blind)
    local bl = blind and G.P_BLINDS[blind.name or blind.config and blind.config.name]
    if bl then
        return bl.font
    end
end
