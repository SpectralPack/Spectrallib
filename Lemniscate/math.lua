local NaN = 0/0

--- Approximates W_0(x), the principal branch of the Lambert W function.
--- @param x number
--- @return number
function Spectrallib.lambert_w(x)
    -- Uses Newton's method to approximate
    -- Based on Amulet/Talisman/OmegaNum.js implementation
    -- which were based on https://math.stackexchange.com/a/465183
    local tolerance = 1e-10
    local w, wn
    local OMEGA = 0.56714329040978387299997

    if x == 0 then return 0 end
    if x == 1 then return OMEGA end
    if x < 10 then
        w = 0
    else
        w = math.log(x) - math.log(math.log(x))
    end

    for _ = 0,99 do
        wn = (x*math.exp(-w) + w*w) / (w+1)
        if (math.abs(wn - w) < tolerance*math.abs(wn)) then
            return wn
        end
        w = wn
    end

    error("Lambert W iteration failed to converge")
end

--- Calculates a ^^ b; less precise for high heights.
--- @param base number
--- @param height number
--- @return number
function Spectrallib.tetrate(base, height)
    -- just use Talisman/Amulet's tetration if possible
    if Talisman then return to_big(base):tetrate(height) end

    -- avoid easy cases; taken from omeganum tetrate
    if height <= -2 then return NaN end
    if base == 0 then return height == 0 and NaN or math.ceil(height) % 2 end
    if base == 1 then return height == -1 and NaN or 1 end
    if height == -1 then return 0 end
    if height == 0 then return 1 end
    if height == 1 then return base end
    if base == 2 and height == 2 then return 4 end

    -- the function itself
    if height > 1e6 then
        if base < math.exp(1/math.exp(1)) then
            local negln = -math.log(base)
            return Spectrallib.lambert_w(negln) / negln
        end
        return base == 1 and 1 or (0 < base and base < 1 and 0) or (base < 0 and NaN) or math.huge
    end
    local frac = height - math.floor(height)
    local tower = {}
    for i = 2, math.floor(height) do
        tower[#tower+1] = base
    end
    local tot = tower[#tower] ^ (base ^ frac)
    for i = #tower, 1, -1 do
        tot = tower[i] ^ tot
    end
    return tot
end

--- Creates a pair of normally-distributed pseudorandom numbers using the Box-Muller transform.
--- @param seed string The random seed used.
--- @param mean number The normal distribution's mean. Defaults to 0.
--- @param stdev number The normal distribution's standard deviation. Defaults to 1.
--- @return number
--- @return number
function Spectrallib.pseudorandom_normal(seed, mean, stdev)
    local theta = 2 * math.pi * pseudorandom(seed)
    local r = math.sqrt(-2 * math.log(pseudorandom(seed)))
    local r_stdev = r * stdev

    return mean + (r_stdev * math.cos(theta)), mean + (r_stdev * math.sin(theta))
end

--- Returns 1 if `x` is positive, -1 if x is negative
--- Returns 0 if `x` == 0, so float -0 isn't treated as negative here
--- @param x number
--- @return number
function Spectrallib.sign(x)
    -- fast math.sign for luaJIT
    -- from stack overflow: https://stackoverflow.com/a/64878952
    --[["""
        The reason is that it avoids branches, which can be expensive.
        The double multiplication ensures that the result is correct even with inputs in the denormal range.
        Infinity can't be used because with an input of zero, it would produce NaN.
    """]]
    return Spectrallib.clamp(to_number(x) * 1e200 * 1e200, -1, 1)
end

--- Rounds to the nearest integer.
--- @param num number
--- @return integer
function Spectrallib.round_nearest(num)
    return (to_number(num % 1) >= 0.5) and math.ceil(num) or math.floor(num)
end

--- Rounds `num` to the nearest 10^`power`
--- @param num number 
--- @param power integer? Defaults to 0.
--- @return number
function Spectrallib.round_power(num, power)
    power = power or 0
    return Spectrallib.round_nearest(num * 10^-power) * 10^power
end

--- Alternative to number_format intended to better account for high-precision decimals.
--- @param num number Number being formatted.
--- @param e_switch_point number? Point at which scientific notation begins being used. Defaults to 1e11
--- @param precision_loss_point number? Point at which to revert to default number_format. Defaults to 100
--- @param decimal_places number? Number of decimal places to use. Defaults to 4
--- @param keep_trailing_zeroes boolean? Keeps trailing zeroes.
--- @return string
function Spectrallib.alt_number_format(num, e_switch_point, precision_loss_point, decimal_places, keep_trailing_zeroes)
    -- G.E_SWITCH_POINT = G.E_SWITCH_POINT or 1e11
    e_switch_point = e_switch_point or G.E_SWITCH_POINT or 1e11
    precision_loss_point = precision_loss_point or 100
    decimal_places = decimal_places or 4

    local num_o = num
    num = to_number(num)
    local sign = num >= 0 and "" or "-"
    local abs = math.abs(num)

    local floored_num = math.floor(abs)
    local decimal_num = abs - floored_num

    -- do we need to consider decimals
    if num >= math.min(precision_loss_point, e_switch_point) or decimal_num == 0 then
        return number_format(num_o, e_switch_point)
    end

    -- add commas to the integer portion
    local formatted_int = string.format("%d", floored_num):reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()

    -- format and round decimal portion
    decimal_num = Spectrallib.round_power(decimal_num, -decimal_places)
    local formatted_dec = string.format("%." .. decimal_places .. "f", decimal_num)

    -- remove leading zero
    if formatted_dec:sub(1, 1) == "0" then
        formatted_dec = formatted_dec:sub(2)
    end

    -- remove trailing zeroes
    if not keep_trailing_zeroes then
        while formatted_dec:sub(-1) == "0" do
            formatted_dec = formatted_dec:sub(1, #formatted_dec - 1)
        end
    end

    return sign .. formatted_int .. formatted_dec
end