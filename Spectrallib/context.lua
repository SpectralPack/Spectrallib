
local use_ref = Card.use_consumeable

local bulk_use_ref
if Overflow then
    bulk_use_ref = Overflow.bulk_use
    function Overflow.bulk_use(card, area, amount)
        bulk_use_ref(card, area, amount)
        local effects = {}
        SMODS.calculate_context({
            retrigger_consumable = true,
            consumeable = card,
            bulk_use = true,
            bulk_use_amount = amount,
            area = area,
        }, effects)
        local retrig_total = 0 --this is for future use in potentially bulk using for high retrigger amounts
        local retrig_effects = {}
        for i = 1, #effects do
            local eff = Spectrallib.safe_get(effects, i, "jokers")
            while eff do
                if eff.repetitions then
                    retrig_effects[#retrig_effects+1] = eff
                    retrig_total = retrig_total + math.floor(math.max(0, eff.repetitions))
                else
                    sendWarnMessage("Found effect table during repetition check with no assigned repetitions", "Spectrallib")
                end
                eff = eff.extra
            end
        end
        --two loops for reason mentioned above
        for _, eff in ipairs(retrig_effects) do
            for _ = 1, math.floor(eff.repetitions or 0) do
                if not card:can_use_consumeable(true, true) then return end --if the consumable can no longer be used, abort
                if not eff.no_message then card_eval_status_text(eff.message_card or eff.card or card, "extra", nil, nil, nil, { message = eff.message or localize("k_again_ex"), colour = eff.colour or G.C.FILTER }) end
                use_ref(card, area)
            end
        end
    end
end

function Card:use_consumeable(area, copier)
    use_ref(self, area, copier)
    local effects = {}
    SMODS.calculate_context({
        retrigger_consumable = true,
        consumeable = self,
        area = area,
    }, effects)
    local retrig_total = 0 --this is for future use in potentially bulk using for high retrigger amounts
    local retrig_effects = {}
    for i = 1, #effects do
        local eff = Spectrallib.safe_get(effects, i, "jokers")
        while eff do
            if eff.repetitions then
                retrig_effects[#retrig_effects + 1] = eff
                retrig_total = retrig_total + math.floor(math.max(0, eff.repetitions))
            else
                sendWarnMessage("Found effect table during repetition check with no assigned repetitions", "Spectrallib")
            end
            eff = eff.extra
        end
    end
    --two loops for reason mentioned above
    for _, eff in ipairs(retrig_effects) do
        for _ = 1, math.floor(eff.repetitions or 0) do
            if not self:can_use_consumeable(true, true) then return end --if the consumable can no longer be used, abort
            if not eff.no_message then card_eval_status_text(eff.message_card or eff.card or self, "extra", nil, nil, nil, { message = eff.message or localize("k_again_ex"), colour = eff.colour or G.C.FILTER }) end
            use_ref(self, area)
        end
    end
end