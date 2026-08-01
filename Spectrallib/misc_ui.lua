--File for general ui functions not related to one of the present mods and not for the mod's page
--Includes drawsteps and the like because idk where else those would go

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

Spectrallib.create_UIBox_use_deck = function (cfg)
    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR, minw = G.deck.T.w, minh = 0.5 }, nodes = {
        { n = G.UIT.R, nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "tm",
                    minw = 2,
                    padding = 0.1,
                    r = 0.1,
                    hover = true,
                    colour = G.C.UI.BACKGROUND_DARK,
                    shadow = true,
                    button = "slib_use_deck",
                    func = "slib_can_use_deck",
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "bcm", padding = 0 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = localize(cfg.key),
                                    scale = 0.35,
                                    colour = G.C.UI.TEXT_LIGHT,
                                    id = "slib_use_deck_text"
                                }
                            }
                        }
                    },
                }
            }
        } }
    } }
end

--Banished cards drawstep (thank you bandisplay :pray:)
SMODS.DrawStep({
	key = "banished_card",
	order = 69,
	func = function(card, layer)
		if
			not G.GAME.USING_POINTER
			and card.area
			and card.area.config.collection
			and Spectrallib.should_display_ban(card)
		then
			card.children.center:draw_shader("debuff", nil, card.ARGS.send_to_shader)
		end
	end,
})