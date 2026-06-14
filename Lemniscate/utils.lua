--- Merges tables into a singular, flattened table. Taken from Handy
--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function Spectrallib.deep_table_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				target[k] = target[k] or {}
				target[k] = Spectrallib.deep_table_merge(target[k], v)
			else
				target[k] = v
			end
		end
	end

	return target
end

---@class Spectrallib.event.input
---@field [1]? function Function to repeatedly run during the event; must return `true` to stop repetition. Overrides `func`.
---@field func? function Function to repeatedly run during the event; must return `true` to stop repetition. Overridden by `1`.
---@field delay? number
---@field trigger? string
---| "immediate" `func` runs immediately.
---| "after" `func` runs after `delay` amount of time.
---| "before" `func` runs immediately; the next event runs after `delay` amount of time, or `func` returns true, whichever comes last.
---| "condition" Event sustains until `ref_table[ref_value] == ref.stop_val` or `func`, if defined, returns true; `func` is prioritized.
---| "ease" Event gradually changes `ref_table[ref_value]` to `ease_to` over `delay` amount of time.
---@field blocking? boolean If true, `func` must return true before the next event can occur, otherwise `func` runs in the background until it returns `true`.
---@field blockable? boolean If true, the event must wait for the preceeding blocking event to finish, otherwise it will always run.
---@field pause_force? boolean If true, event continues to run while game is paused. Overrides `force_pause`.
---@field force_pause? boolean If true, event continues to run while game is paused. Overriden by `pause_force`.
---@field no_delete? boolean If true, `clear_queue` will not delete this event.
---@field timer? string Key of a timer in `G.TIMERS` that the event follows.
---@field ref_table? table
---@field ref_value? string|any Key in `ref_table`.
---@field ease? "lerp"|"elastic"|"quad" The type of ease to use if `trigger = "ease"`. Overrides `type`.
---@field type? "lerp"|"elastic"|"quad" The type of ease to use if `trigger = "ease"`. Overridden by `ease`.
---@field ease_to? number If `trigger == "ease"`, this is the number `ref_table[ref_value]` transforms into.
---@field stop_val? any If `trigger == "condition"`, this is the value `ref_table[ref_value]` must equal to for the event to stop.
---@field extra? any An additional Event object to merge with this function's Event object. 
---@field instant? boolean If true, `func` runs independently of the Event object, which is *not* added to a queue.
---@field no_insert? boolean If true, the Event object is not added to `G.E_MANAGER`.
---@field queue? string The queue to add the event to. Overrides the argument `_queue`.
---@field prepend? boolean If true, the Event object is added to the front of the queue, otherwise it is added to the back. Overrides the argument `_prepend`.

--- Event function. Only here to avoid a massive boilerplate.
--- @param input function|number|Spectrallib.event.input? If number, delays the next event in seconds.
--- @param _queue string?
--- @param _prepend boolean?
--- @return Event|table
function Spectrallib.event(input, _queue, _prepend)
    -- thanks SleepyG11 for this event function
    input = input or {}
    if type(input) == "number" then input = { delay = input } end
    if type(input) == "function" then input = { input } end
    local queue = input.queue or _queue
    local prepend = input.prepend or _prepend

    local event_definition = {
        trigger = input.trigger or "immediate",
        func = input[1] or input.func or function(t) return t or true end,
        blocking = input.blocking,
        blockable = input.blockable,
        delay = input.delay,
        pause_force = input.pause_force or input.force_pause,
        no_delete = input.no_delete,
        timer = input.timer,

        ref_table = input.ref_table,
        ref_value = input.ref_value,
        ease = input.ease or input.type,
        ease_to = input.ease_to,
        stop_val = input.stop_val,
    }
    -- delay doesnt work on immediate events
    if event_definition.delay and event_definition.trigger == "immediate" then
        event_definition.trigger = "after"
    end
    local event = Event(event_definition)
    if input.extra then
        Spectrallib.deep_table_merge(event, input.extra)
    end
    -- option to call function inside immediately
    if input.instant then
        if event.trigger ~= "ease" then
            event.func()
            return event
        end
    end
    -- only returns the event as a standalone object
    if not input.no_insert then
        G.E_MANAGER:add_event(event, queue, prepend)
    end
    return event
end
--[[

    -- empty event
Spectrallib.event() 
    -- delay in specified queue, basically vanilla's delay() function
Spectrallib.event(0.5, "handy_config")
    -- simple event
Spectrallib.event(function() G.STATE = G.STATES.SHOP return true end) 
    -- delay with own func in queue, various forms how to do the same
Spectrallib.event({
    function() G.STATE = G.STATES.SHOP return true end, -- syntax sugar
    delay = 0.5,
    queue = "handy_config"
})
Spectrallib.event({
    func = function() G.STATE = G.STATES.SHOP return true end, -- syntax sugar
    delay = 0.5,
}, "handy_config")
    -- conditional event
Spectrallib.event({
    function() play_sound("coin1") return true end, -- syntax sugar
    instant = math.random() > 0.5
})

]]

--- Cleaner interface for `copy_card()` that automatically handles adding the card to the deck.
--- Modified from code by somethingcom515: https://discord.com/channels/1116389027176787968/1233186615086813277/1442656562249466026
--- @param args {card: Card, new_card: Card?, area: CardArea?, card_scale: number?, strip_edition: boolean?, auto_materialize: boolean?} Contains arguments passed to the function.
--- @return Card
function Spectrallib.copy_card(args)
    -- can return nil but if you follow the annotations it won't do that
    if not args or not args.card then return end

    local area = args.area or (args.new_card and args.new_card.area) or args.card.area or G.jokers
    local cardwasindeck = args.new_card and args.new_card.added_to_deck or nil
    local playing_card = args.card.playing_card

    -- handle G.playing_card
    if playing_card then
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
    end

    -- create the fucking card
    local copy = copy_card(
        args.card,
        args.new_card,
        args.card_scale,
        playing_card and G.playing_card or nil,
        args.strip_edition
    )

    -- death-like effects
    if args.new_card and cardwasindeck then copy:remove_from_deck() end

    -- handle card limit
    if playing_card then
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, copy)
    end

    -- handle add to deck/emplace
    if (args.new_card and cardwasindeck) or not args.new_card then copy:add_to_deck() end
    if not args.new_card then area:emplace(copy) end

    if args.auto_materialize then
        copy.states.visible = nil

        Spectrallib.event(function()
            copy:start_materialize()
            return true
        end)
    end

    return copy
end

--- Forces an object's hover description to update
--- @param obj Moveable|table
--- @return nil
function Spectrallib.force_hover_desc_update(obj)
    if obj.states.hover.is and obj.discovered ~= false and obj.locked ~= false then
        obj:stop_hover()
        obj:hover()
    end
end