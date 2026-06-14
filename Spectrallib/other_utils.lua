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
    local areas = #... == 1 and ... or {unpack(...)}
    if type(areas) ~= "table" then return function () end end

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
                else
                    sendWarnMessage(areacards_warn:format(area_i))
                end
                if #cardlist <= 0 then cardlist = nil end
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