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
    local old = G.GAME.chips
    table.insert(G.SCORE_DISPLAY_QUEUE, old)
    G.GAME.chips = amt
end

---@param amt number
---@return nil
function Spectrallib.mod_blindsize(amt) --good version
    G.BLIND_SIZE_DISPLAY_QUEUE = G.BLIND_SIZE_DISPLAY_QUEUE or {}
    table.insert(G.BLIND_SIZE_DISPLAY_QUEUE,amt)
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
function Spectrallib.get_text_colour(card)
    if not card then return G.C.UI.TEXT_DARK end
    if card.config.center.set == "Joker" then
        return G.C.FILTER
    end
    if card.config.center.set == "Code" then --back compat thingy
        return G.C.SET.Code
    end
    return get_type_colour(card.config.center, card) or G.C.UI.TEXT_DARK
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

--Creates the UIBox for Ascended Hands in run info
function Spectrallib.create_UIBox_asc_hands()
    local times_leveled = G.GAME.sunlevel
    local multiplier = Spectrallib.get_ascension_factor(1.25)
    return {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = lighten(G.C.GOLD, 0.2), emboss = 0.05, hover = true, force_focus = true, 
        on_demand_tooltip = {text = localize("slib_asc_hands", 'poker_hand_descriptions'), filler = {func = Spectrallib.create_UIBox_asc_hands_tip, --[[args = "Junk Hands"]] }}
        },
        nodes={
            {n=G.UIT.C, config={align = "cl", padding = 0, minw = 4.5}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, times_leveled)], minw = 1.5, outline = 0.8, outline_colour = G.C.WHITE}, nodes={
                    {n=G.UIT.T, config={text = localize('k_level_prefix')..times_leveled, scale = 0.5, colour = G.C.UI.TEXT_DARK}}
                }},
                {n=G.UIT.C, config={align = "cm", minw = 4.5, maxw = 4.5}, nodes={
                    {n=G.UIT.T, config={text = ' '..localize("slib_asc_hands"), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
                }}
            }},
            {n=G.UIT.C, config={align = "cr", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.GOLD , minw = 2.5}, nodes={
                    {n=G.UIT.T, config={text = "X"..number_format(multiplier, 1000000), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
                    {n=G.UIT.B, config={w = 0.08, h = 0.01}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.T, config={text = '  #', scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.L_BLACK,r = 0.1, minw = 0.9}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = {tostring(G.GAME.cry_asc_played or 0)}, maxw = 0.9, scale = 0.45, colours = {G.C.FILTER}, shadow = true})}},
            }}
        }
    }
end

--Creates the hover tooltip for Ascended Hands in run info
function Spectrallib.create_UIBox_asc_hands_tip()
    local cardarea = CardArea(
        2,2,
        3.5*G.CARD_W,
        0.75*G.CARD_H, 
        {card_limit = 5, type = 'title', highlight_limit = 0})
    for k, v in ipairs{
            {'S_3', true},
            {'D_4', true},
            {'D_5', true},
            {'S_6', true},
            {'S_7', true},
            {'H_8', true},
            {'H_9', true},
        } do
        local card = Card(0,0, 0.5*G.CARD_W, 0.5*G.CARD_H, G.P_CARDS[v[1]], G.P_CENTERS[v.enhancement or 'c_base'])
        if v[2] then card:juice_up(0.3, 0.2) end
        if k == 1 then play_sound('paper1',0.95 + math.random()*0.1, 0.3) end
        ease_value(card.T, 'scale',v[2] and 0.25 or -0.15,nil,'REAL',true,0.2)
        cardarea:emplace(card)
    end

    return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.O, config={object = cardarea}}
        }}
    }}
end