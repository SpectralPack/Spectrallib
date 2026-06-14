-- we can figure out where to put this later
Spectrallib_config = SMODS.current_mod.config

-- done so amulet can access them
Spectrallib.config_opts = {}

Spectrallib.config_opts.exponential_colours = function()
    return create_option_cycle({
        label = localize("slib_exp_colours"),
        scale = 0.8,
        w = 6,
        options = {localize("slib_exp_colour_1"), localize("slib_exp_colour_2")},
        opt_callback = "slib_update_exp_colours",
        current_option = Spectrallib_config.exp_colours,
    })
end

SMODS.current_mod.config_tab = function()
    local nodes = {}
    nodes[#nodes+1] = Spectrallib.config_opts.exponential_colours()
    return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = {
			{ n = G.UIT.R, config = { align = "cm", r = 0.1, colour = {0,0,0,0}, emboss = 0.05 }, nodes = nodes },
        }
    }
end

function G.FUNCS.slib_update_exp_colours(e)
    Spectrallib_config.exp_colours = e.to_key
end