-- adaptions from https://easings.net/ by Andrey Sitnik and Ivan Solovev

local easings = {}

function easings:ease_out_elastic(x)
    if x <= 0 then return 0 end
    if x >= 1 then return 1 end

    local c4 = (2 * math.pi) / 3
    return (2 ^ (-10 * x)) * math.sin((x * 10 - 0.75) * c4) + 1
end

return easings