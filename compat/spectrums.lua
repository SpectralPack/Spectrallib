-- Ascension numbers for Bunco and SpectrumAPI hands
local ascnum = Spectrallib.ascension_numbers

ascnum["bunc_Spectrum"]          = 5
ascnum["bunc_Straight Spectrum"] = 5
ascnum["bunc_Spectrum House"]    = 5
ascnum["bunc_Spectrum Five"]     = 5

local function spectrum_num()
    return (
        SpectrumAPI
        and SpectrumAPI.configuration.misc.four_fingers_spectrums
        and next(SMODS.find_card("j_four_fingers"))
        and Spectrallib.gameset() ~= "modest"
        and 4
        or 5
    )
end

ascnum["spa_Spectrum"]                = spectrum_num()
ascnum["spa_Straight_Spectrum"]       = spectrum_num()
ascnum["spa_Spectrum_House"]          = spectrum_num()
ascnum["spa_Spectrum_Five"]           = spectrum_num()
ascnum["spa_Flush_Spectrum"]          = spectrum_num()
ascnum["spa_Straight_Flush_Spectrum"] = spectrum_num()
ascnum["spa_Flush_Spectrum_House"]    = spectrum_num()
ascnum["spa_Flush_Spectrum_Five"]     = spectrum_num()