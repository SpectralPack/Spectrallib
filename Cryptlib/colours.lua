local function update_exp_colour(self, _)
    local opt = Spectrallib_config.exp_colours
    if opt == 1 then
        local interp = math.cos(G.TIMERS.REAL * 2 * math.pi / self.cycle) * 0.5 + 0.5

        for i = 1, 4 do
            self[i] = self.colours[1][i] * (1-interp) + self.colours[2][i] * interp
        end
    elseif opt == 2 then
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
        HEX("ff895e"),
        HEX("ff73ad")
    },
    cycle = 4,
    update = update_exp_colour,
}