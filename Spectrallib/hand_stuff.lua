function _G.create_UIBox_hand_info(handname)
    local nodes = {}
    if G.GAME.hands[handname].AscensionPower then
        nodes[#nodes+1] = {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, force_focus = true, emboss = 0.05, hover = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}, focus_args = {snap_to = (simple and handname == 'Straight Flush')}}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1}, nodes={
                {n=G.UIT.T, config={text = localize("slib_base_stats"), scale = 0.45, colour = G.C.UI.TEXT_DARK}},
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
            {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = G.C.BLUE, minw = 1.1}, nodes={
                {n=G.UIT.T, config={text = number_format(G.GAME.hands[handname].chips), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
                {n=G.UIT.B, config={w = 0.08, h = 0.01}}
            }},
            {n=G.UIT.T, config={text = "X", scale = 0.45, colour = G.C.RED}},
            {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = G.C.RED, minw = 1.1}, nodes={
                {n=G.UIT.B, config={w = 0.08,h = 0.01}},
                {n=G.UIT.T, config={text = number_format(G.GAME.hands[handname].mult), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
            }}
            }},
        }}
    end
    nodes[#nodes+1] = {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, force_focus = true, emboss = 0.05, hover = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}, focus_args = {snap_to = (simple and handname == 'Straight Flush')}}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1}, nodes={
            {n=G.UIT.T, config={text = localize("slib_per_level"), scale = 0.45, colour = G.C.UI.TEXT_DARK}},
        }},
        {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = G.C.BLUE, minw = 1.1}, nodes={
            {n=G.UIT.T, config={text = number_format(G.GAME.hands[handname].l_chips), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
            {n=G.UIT.B, config={w = 0.08, h = 0.01}}
        }},
        {n=G.UIT.T, config={text = "X", scale = 0.45, colour = G.C.RED}},
        {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = G.C.RED, minw = 1.1}, nodes={
            {n=G.UIT.B, config={w = 0.08,h = 0.01}},
            {n=G.UIT.T, config={text = number_format(G.GAME.hands[handname].l_mult), scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
        }}
        }},
    }}
    for i, v in pairs(Spectrallib.HandBonuses) do
        if G.GAME.hands[handname][v.key] and G.GAME.hands[handname][v.key] ~= v.starting_value then
            nodes[#nodes+1] = v:generate_ui(handname)
        end
    end
    return {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1}, nodes=nodes}
end

Spectrallib.HandBonuses = {}
Spectrallib.HandBonus = SMODS.GameObject:extend{
    obj_table = Spectrallib.HandBonuses,
    obj_buffer = {},
    set = "HandBonus",
	pos = { x = 0, y = 0 },
	config = {},
	class_prefix = "handbonus",
	required_params = {
		"key",
        "colour",
	},
    get_obj = function(self, key) return Spectrallib.HandBonuses[key] end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.HandBonus, self.key, self.loc_txt)
    end,
    text_position = "before",
    inject = function() end,
    colour = G.C.RED,
    starting_value = 0,
    level_up = function(self, hand, amount)
        G.GAME.hands[hand][self.key] = (G.GAME.hands[hand][self.key] or self.starting_value) + amount
        --insert anim here
    end,
    --this will get passed all regular contexts, but most only need to care about before main_scoring and after
    calculate = function(self, hand, context, amount) end,
    format_text = function(self, hand, amount) 
        local text, operator
        local prefix = self.prefix_key and localize(self.prefix_key) or (type(self.prefix) == "function" and self:prefix(hand, amount) or self.prefix)
        if prefix then
            text = (amount < 0 and "-"..prefix or prefix)..number_format(math.abs(amount))
        end
        if self.operator_text then
            operator = self.operator_text
        end
        return text, operator
    end,
    generate_ui = function(self, hand) 
        local colour = type(self.colour) == "function" and self:colour(hand) or self.colour
        local desc = G.localization.descriptions.HandBonus and G.localization.descriptions.HandBonus[self.key] and G.localization.descriptions.HandBonus[self.key].text
        local desc_nodes = {}
        for i, v in pairs(desc or {}) do
            desc_nodes[#desc_nodes+1] = SMODS.localize_box(loc_parse_string(v), {scale = 1.45})[1]
        end
        local text, operator = self:format_text(hand, G.GAME.hands[hand][self.key])
        if not text then
            text = number_format(G.GAME.hands[hand][self.key])
        end
        if operator and type(operator) == "string" then
            operator = {n=G.UIT.T, config={text = operator, scale = 2, colour = self.colour}}
        end
        return {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, emboss = 0.05, hover = true}, nodes={
            self.text_position == "before" and desc and {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1}, nodes=desc_nodes} or nil,
            {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
                operator,
                {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = colour, minw = 1.1}, nodes={
                    {n=G.UIT.B, config={w = 0.08,h = 0.01}},
                    {n=G.UIT.T, config={text = text, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
                }}
            }},
            self.text_position == "after" and desc and {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1}, nodes=desc_nodes} or nil,
        }}
    end
}