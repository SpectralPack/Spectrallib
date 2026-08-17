Spectrallib.CreditsStyles = {}
Spectrallib.CreditsStyle = SMODS.GameObject:extend{
    obj_table = Spectrallib.CreditsStyles,
    obj_buffer = {},
    set = "CreditsStyle",
	pos = { x = 0, y = 0 },
	config = {},
	class_prefix = "creditsstyle",
	required_params = {
		"key",
	},
    get_obj = function(self, key) return Spectrallib.CreditsStyles[key] end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.CreditsStyle, self.key, self.loc_txt)
    end,
    create_badge_text = function(self, card, badges) end,
    card_h_popup = function(self, card, ret_val) end,
    generate_ui = function(self, center, info_queue, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card) end,
    inject = function() end
}

function Spectrallib.get_credits_style()
    if Spectrallib_config.credits_style and not Spectrallib.CreditsStyles[Spectrallib_config.credits_style] then
        Spectrallib_config.credits_style = "creditsstyle_slib_badge_cycle"
    end
    return Spectrallib.CreditsStyles[Spectrallib_config.credits_style or "creditsstyle_slib_badge_cycle"]
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(center, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...)
    full_UI_table = generate_card_ui_ref(center, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...) or full_UI_table
    if center and center.slib_credits then
        local queue = {}
        full_UI_table = Spectrallib.get_credits_style():generate_ui(center, queue, ull_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...) or full_UI_table
        for i, v in pairs(queue) do
            generate_card_ui(v, full_UI_table)
        end
    end
    return full_UI_table
end

local ortalab_card_h_popup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local ret_val = ortalab_card_h_popup_ref(card)
    local AUT = card.ability_UIBox_table
    local obj = card.config.center or (card.config.tag and G.P_TAGS[card.config.tag.key])
    if card.area and card.area.config.collection and not card.config.center.discovered then return ret_val end
    if obj and obj.slib_credits then
        Spectrallib.get_credits_style():card_h_popup(obj, ret_val)
    end
    return ret_val
end

Spectrallib.CreditsStyle {
    key = "badge_cycle",
    create_badge_text = function(self, mod, obj, width, text_height)
        local function calc_scale_fac(text)
			local size = 0.9
			local font = G.LANG.font
			local max_text_width = 2 - 2 * 0.05 - 4 * 0.03 * size - 2 * 0.03
			local calced_text_width = 0
			-- Math reproduced from DynaText:update_text
			for _, c in utf8.chars(text) do
				local tx = font.FONT:getWidth(c) * (0.33 * size) * G.TILESCALE * font.FONTSCALE
					+ 2.7 * 1 * G.TILESCALE * font.FONTSCALE
				calced_text_width = calced_text_width + tx / (G.TILESIZE * G.TILESCALE)
			end
			local scale_fac = calced_text_width > max_text_width and max_text_width / calced_text_width or 1
			return scale_fac
		end
		local scale_fac = {}
        local min_scale_fac = 1
        local strings = {obj.original_mod.display_name}
        for _, v in ipairs({ "idea", "art", "code" }) do
            if obj.slib_credits[v] then
                if type(obj.slib_credits[v]) == "string" then obj.slib_credits[v] = {obj.slib_credits[v]} end
                for i = 1, #obj.slib_credits[v] do
                    strings[#strings + 1] =
                            localize({ type = "variable", key = "slib_" .. v, vars = { obj.slib_credits[v][i] } })
                end
            end
        end        
        for i = 1, #strings do
            scale_fac[i] = calc_scale_fac(strings[i])
            min_scale_fac = math.min(min_scale_fac, scale_fac[i])
        end
        local ct = {}
        if #strings == 0 then
            strings = {obj.original_mod.display_name}
        end
        for i = 1, #strings do
            ct[i] = {
                string = strings[i],
            }
        end
        local max_text_width = (width or 1.732)
        return DynaText({
            string = ct, 
            colours = {mod.badge_text_colour or G.C.WHITE}, 
            maxw = mod.no_marquee and max_text_width, 
            float = true, 
            shadow = true, 
            offset_y = -0.05, 
            silent = true, 
            spacing = 1*min_scale_fac, 
            scale = text_height or 0.297
        })
    end
}

Spectrallib.CreditsStyle {
    key = "below_badge",
    artist_node = function(self, artists, first_string, c)
        local artist_node = {n=G.UIT.R, config = {align = 'tm'}, nodes = {
            {n=G.UIT.T, config={
                text = first_string,
                shadow = true,
                colour = G.C.UI.BACKGROUND_WHITE,
                scale = 0.27}}
        }}
        local total_artists = #artists
        for i, artist in ipairs(artists) do
            if total_artists > 1 and i > 1 then
                if i == total_artists then
                    table.insert(artist_node.nodes,
                        {n=G.UIT.T, config={
                        text = localize('k_slib_and'),
                        shadow = true,
                        colour = G.C.WHITE,
                        scale = 0.27}}
                    )
                else
                    table.insert(artist_node.nodes,
                        {n=G.UIT.T, config={
                        text = ', ',
                        shadow = true,
                        colour = G.C.WHITE,
                        scale = 0.27}}
                    )
                end
            end
            table.insert(artist_node.nodes,
                {n=G.UIT.O, config={
                    object = DynaText({string = artist,
                    colours = {c or G.C.WHITE},
                    bump = true,
                    silent = true,
                    pop_in = 0,
                    pop_in_rate = 4,
                    shadow = true,
                    y_offset = -0.6,
                    scale =  0.27
                    })
                }}
            )
        end
        return artist_node
    end,
    card_h_popup = function(self, card, ret_val)
        local credits = card.slib_credits
		for _, v in ipairs({ "idea", "art", "code" }) do
			if credits and credits[v] then
				if type(credits[v]) == "string" then credits[v] = {credits[v]} end
				local colour = ({
					idea = G.C.ORANGE,
					code = G.C.GREEN,
					art = G.C.PURPLE
				})[v]
				table.insert(ret_val.nodes[1].nodes[1].nodes[1].nodes, self:artist_node(credits[v], localize("slib_" .. v), colour))
			end
		end
    end
}

Spectrallib.CreditsStyle {
    key = "info_queue",
    generate_ui = function(self, center, info_queue)
        local credits = center.slib_credits
        if credits then
            for _, v in ipairs({ "idea", "art", "code" }) do
                if credits and credits[v] then
                    if type(credits[v]) == "string" then credits[v] = {credits[v]} end
                    for i = 1, #credits[v] do
                        info_queue[#info_queue + 1] = { set = "Other", key = "slib_infoqueue_credit_" .. v, vars = { credits[v][i] }}
                    end
                end
            end
        end
    end
}

Spectrallib.CreditsStyle {
    key = "none",
}

function Spectrallib.get_credits_list(name)
    local cred = {}
    for i, v in pairs(Spectrallib.CreditsStyles) do
        if v.key ~= "creditsstyle_slib_none" then
            cred[#cred+1] = name and localize{set = "CreditsStyle", key = v.key, type = "name_text"} or v.key
        end
    end
    cred[#cred+1] = name and localize{set = "CreditsStyle", key = "creditsstyle_slib_none", type = "name_text"} or "creditsstyle_slib_none"
    return cred
end

SMODS.Atlas {
    key = "credits_icons",
    path = "credits_icons.png",
    px = 22, py = 22
}

Spectrallib.CreditsStyle {
    key = "below_popup",
    card_h_popup = function(self, card, ret_val)
        if not Spectrallib.credits_sprites then
            Spectrallib.credits_sprites = {
                art = SMODS.create_sprite(0, 0, 0.5, 0.5, "slib_credits_icons", { x = 0, y = 0 }),
                code = SMODS.create_sprite(0, 0, 0.5, 0.5, "slib_credits_icons", { x = 1, y = 0 }),
                idea = SMODS.create_sprite(0, 0, 0.5, 0.5, "slib_credits_icons", { x = 2, y = 0 })
            }
        end
        local target = ret_val.nodes[1].nodes
        local credits = card.slib_credits
        local colours = {
            idea = G.C.ORANGE,
            code = G.C.GREEN,
            art = G.C.PURPLE
        }
        if credits then
            for _, v in ipairs({ "idea", "art", "code" }) do
                if credits and credits[v] then
                    if type(credits[v]) == "string" then credits[v] = {credits[v]} end
                    for i = 1, #credits[v] do
                        local dev = credits[v][i]
                        local str = {
                            n = G.UIT.R,
                            config = { colour = G.C.CLEAR, align = "cm", w = 0, padding = 0.02 },
                            nodes = {
                                {n=G.UIT.R, config={align = "cm", minh = 0.3, r = 0.12, padding = 0.05, colour = colours[v], emboss = 0.07}, nodes={
                                    {n=G.UIT.R, config={align = "cm", minh = 0.3, r = 0.1, minw = 2.5, padding = 0.04, colour = darken(colours[v], 0.4)}, nodes={
                                        {
                                            n = G.UIT.R,
                                            config = { colour = G.C.CLEAR, align = "cm", w = 0, padding = 0.08 },
                                            nodes = {
                                                {
                                                    n = G.UIT.O,
                                                    config = {
                                                        object = Spectrallib.credits_sprites[v],
                                                    },
                                                },
                                                {
                                                    n = G.UIT.C,
                                                    config = { align = "cl" },
                                                    nodes = {
                                                        {n=G.UIT.R, config={align = "cl"}, nodes={{
                                                            n = G.UIT.T,
                                                            config = { text = localize("slib_by_"..v), shadow = true, colour = G.C.UI.BACKGROUND_WHITE, scale = 0.27 },
                                                        }}},
                                                        {n=G.UIT.R, config={align = "cl"}, nodes={{
                                                            n = G.UIT.O,
                                                            config = {
                                                                object = DynaText({
                                                                    string = dev or "",
                                                                    colours = { G.C.UI.BACKGROUND_WHITE },
                                                                    scale = 0.27,
                                                                    silent = true,
                                                                    shadow = true,
                                                                }),
                                                            },
                                                        }}},
                                                    }
                                                },
                                            }
                                        },
                                    }},
                                }}
                            }
                        }
                        if str then
                            table.insert(target, str)
                        end
                    end
                end
            end
        end
    end
}