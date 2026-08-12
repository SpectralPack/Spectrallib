-- Update function for exponential colors
local function update_exp_colour(self, _)
    local color_option = Spectrallib_config.exp_colours

    -- Option 1 - Fancy red/blue gradients
    if color_option == 1 then
        local interp = math.cos(G.TIMERS.REAL * 2 * math.pi / self.cycle) * 0.5 + 0.5

        for i = 1, 4 do
            self[i] = self.colours[1][i] * (1-interp) + self.colours[2][i] * interp
        end

    -- Option 2 - Classic sblue background
    elseif color_option == 2 then
        for i = 1, 4 do
            self[i] = G.C.DARK_EDITION[i]
        end
    end
end

Spectrallib.echips = SMODS.Gradient {
    key = "echips",
    colours = {
        HEX("41bed9"),
        HEX("5674e9"),
    },
    cycle = 4,
    update = update_exp_colour,
}

Spectrallib.emult = SMODS.Gradient {
    key = "emult",
    colours = {
        HEX("ff73ad"),
        HEX("db005f")
    },
    cycle = 4,
    update = update_exp_colour,
}

--Still subject to change
Spectrallib.escore = SMODS.Gradient {
    key = "escore",
    colours = {
        HEX("c96bff"),
        HEX("a10de0"),
    },
    cycle = 4,
    --update = update_exp_colour, --needed or no?
}

Spectrallib.eblindsize = SMODS.Gradient {
    key = "eblindsize",
    colours = {
        HEX("4f6569"),
        G.C.DYN_UI.MAIN, --Main is brighter than dark, also changes more often
        HEX("4d5354")
    },
    cycle = 4,
    --update = update_exp_colour, --needed or no?
}

local lc = loc_colour
function loc_colour(_c, _default, ...)
	if _c == "emult" then _c = "slib_emult" end
    if _c == "echips" then _c = "slib_echips" end
	return lc(_c, _default, ...)
end

loc_colour() --rahhhhh

local new_colours = {
    slib_eqmult = HEX("cb7f7f"),
    slib_eqchips = HEX("5b89a6"),
}
for k, v in pairs(new_colours) do
    G.ARGS.LOC_COLOURS[k] = v
end