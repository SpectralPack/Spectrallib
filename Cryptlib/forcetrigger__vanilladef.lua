local function suit_mult(card, context)
    return { mult = card.ability.extra.s_mult }
end
local function hand_mult(card, context)
    return { mult = card.ability.t_mult }
end
local function hand_chips(card, context)
    return { chips = card.ability.t_chips }
end
local function hand_xmult(card, context)
    return { xmult = card.ability.x_mult }
end

-- Forcetrigger results for Vanilla Jokers
-- (You should really be using context.forcetrigger in Joker calculation)
---@type { [string]: fun(card: Card, context: table): table|nil }
Spectrallib.vanilla_forcetrigger_results = {
    --#region Page 1
    ["Joker"] = function (card, context)
        return { mult = card.ability.mult }
    end,
    ["Greedy Joker"]     = suit_mult,
    ["Lusty Joker"]      = suit_mult,
    ["Wrathful Joker"]   = suit_mult,
    ["Gluttonous Joker"] = suit_mult,
    ["Jolly Joker"]      = hand_mult,
    ["Zany Joker"]       = hand_mult,
    ["Mad Joker"]        = hand_mult,
    ["Crazy Joker"]      = hand_mult,
    ["Droll Joker"]      = hand_mult,
    ["Sly Joker"]        = hand_chips,
    ["Wily Joker"]       = hand_chips,
    ["Clever Joker"]     = hand_chips,
    ["Devious Joker"]    = hand_chips,
    ["Crafty Joker"]     = hand_chips,
    --#endregion
    --#region Page 2
    ["Half Joker"] = function (card, context)
        return { mult = card.ability.extra.mult }
    end,
    ["Joker Stencil"] = function (card, context)
        return { xmult = card.ability.x_mult }
    end,
    -- Four Fingers
    -- Mime
    -- Credit Card
    ["Ceremonial Dagger"] = function (card, context)
        local my_pos = card.rank
        local sliced_card = G.jokers.cards[my_pos + 1]
        if (
            not card.getting_sliced
            and sliced_card
            and not sliced_card.ability.eternal
            and not sliced_card.getting_sliced
        ) then
            sliced_card.getting_sliced = true
            G.GAME.joker_buffer = G.GAME.joker_buffer - 1
            G.E_MANAGER:add_event(Event({
                func = function ()
                    G.GAME.joker_buffer = 0
                    card.ability.mult = card.ability.mult + sliced_card.sell_cost * 2
                    card:juice_up(0.8, 0.8)
                    sliced_card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                    play_sound("slice1", 0.96 + math.random() * 0.08)
                    return true
                end
            }))
        end
        return { mut = card.ability.mult }
    end,
    ["Banner"] = function (card, context)
        return { chips = card.ability.extra }
    end,
    ["Mystic Summit"] = function (card, context)
        return { mult = card.ability.extra.mult }
    end,
    ["Marble Joker"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Base",
                    enhancement = "m_stone",
                    area = G.deck,
                    key_append = 'marb_fr'
                })
                return true
            end,
        }))
    end,
    ["Loyalty Card"] = function (card, context)
        return { xmult = card.ability.extra.Xmult }
    end,
    ["8 Ball"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Tarot",
                    key_append = '8ba'
                })
                return true
            end,
        }))
    end,
    ["Misprint"] = function (card, context)
        return { mult = card.ability.extra.max }
    end,
    -- Dusk
    ["Raised Fist"] = function (card, context)
        return { mult = 22 }
    end,
    -- Chaos the Clown
    --#endregion
    --#region Page 3
    ["Fibonacci"] = function (card, context)
        return { mult = card.ability.extra }
    end,
    ["Steel Joker"] = function (card, context)
        return { xmult = card.ability.extra + 1 }
    end,
    ["Scary Face"] = function (card, context)
        return { chips = card.ability.extra }
    end,
    ["Abstract Joker"] = function (card, context)
        return { mult = card.ability.extra }
    end,
    ["Delayed Gratification"] = function (card, context)
        return { dollars = card.ability.extra }
    end,
    -- Hack
    -- Pareidolia
    ["Gros Michel"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.destroy_cards(card, nil, nil, true)
                return true
            end,
        }))
        G.GAME.pool_flags.gros_michel_extinct = true
        return { mult = card.ability.extra.mult }
    end,
    ["Even Steven"] = function (card, context)
        return { mult = card.ability.extra }
    end,
    ["Odd Todd"] = function (card, context)
        return { chips = card.ability.extra }
    end,
    ["Scholar"] = function (card, context)
        return {
            chips = card.ability.extra.chips,
            mult = card.ability.extra.mult
        }
    end,
    ["Business Card"] = function (card, context)
        -- todo: figure out why not return dollars
        ease_dollars(2)
    end,
    ["Supernova"] = function (card, context)
        local hand = (
            context.other_context
            and context.other_context.scoring_name
            or context.scoring_name
        )
        if hand then
            return { mult = G.GAME.hands[hand].played }
        end
    end,
    ["Ride the Bus"] = function (card, context)
        card.ability.mult = card.ability.mult + card.ability.extra
        return { mult = card.ability.mult }
    end,
    ["Space Joker"] = function (card, context)
        if #G.hand.highlighted > 0 then
            local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
                handname = localize(text, "poker_hands"),
                chips = G.GAME.hands[text].chips,
                mult = G.GAME.hands[text].mult,
                level = G.GAME.hands[text].level,
            })
            level_up_hand(card, text, nil, 1)
            update_hand_text(
                { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
                { mult = 0, chips = 0, handname = "", level = "" }
            )
        elseif context.scoring_name then
            level_up_hand(card, context.scoring_name)
        end
    end,
    --#endregion
    --#region Page 4
    ["Egg"] = function (card, context)
        card.ability.extra_value = card.ability.extra_value + card.ability.extra
        card:set_cost()
    end,
    ["Burglar"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                ease_discard(-G.GAME.current_round.discards_left, nil, true)
                ease_hands_played(card.ability.extra)
                return true
            end,
        }))
    end,
    ["Blackboard"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Runner"] = function (card, context)
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return { chips = card.ability.extra.chips }
    end,
    ["Ice Cream"] = function (card, context)
        card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chip_mod
        -- Had to switch conditional and return; not sure if that results in anything big
        if card.ability.extra.chips - card.ability.extra.chip_mod <= 0 then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    SMODS.destroy_cards(card, nil, nil, true)
                    return true
                end,
            }))
        end
        return { chips = card.ability.extra.chips }
    end,
    ["DNA"] = function (card, context)
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
        _card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, _card)
        G.hand:emplace(_card)
        _card.states.visible = nil

        G.E_MANAGER:add_event(Event({
            func = function()
                _card:start_materialize()
                return true
            end,
        }))
    end,
    -- Splash
    ["Blue Joker"] = function (card, context)
        return { chips = card.ability.extra }
    end,
    ["Sixth Sense"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Spectral",
                    key_append = "sixth"
                })
                return true
            end,
        }))
    end,
    ["Constellation"] = function (card, context)
            card.ability.x_mult = card.ability.x_mult + card.ability.extra
            return { xmult = card.ability.x_mult }
    end,
    -- Hiker
    ["Faceless Joker"] = function (card, context)
        -- todo: figure out why ease_dollars, not return dollars
        ease_dollars(card.ability.extra.dollars)
    end,
    ["Green Joker"] = function (card, context)
        return { mult = card.ability.mult }
    end,
    ["Superposition"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Tarot",
                    key_append = "sup"
                })
                return true
            end,
        }))
    end,
    ["To Do List"] = function (card, context)
        -- todo: figure out why ease_dollars, not return dollar
        ease_dollars(card.ability.extra.dollars)
    end,
    --#endregion
    --#region Page 5
    ["Cavendish"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.destroy_cards(card, nil, nil, true)
                return true
            end,
        }))
        return { xmult = card.ability.extra.Xmult }
    end,
    ["Card Sharp"] = function (card, context)
        return { xmult = card.ability.extra.Xmult }
    end,
    ["Red Card"] = function (card, context)
        card.ability.mult = card.ability.mult + card.ability.extra
        return { mult = card.ability.mult }
    end,
    ["Madness"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        local destructable_jokers = {}
        for _,joker in ipairs(G.jokers.cards) do
            if
                joker ~= card
                and not joker.ability.eternal
                and not joker.getting_sliced
            then
                table.insert(destructable_jokers, joker)
            end
        end
        local joker_to_destroy = (
            #destructable_jokers > 0
            and pseudorandom_element(destructable_jokers, pseudoseed("madness"))
            or nil
        )

        if joker_to_destroy and not card.getting_sliced then
            joker_to_destroy.getting_sliced = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    -- todo: can we use SMODS.destroy_cards here
                    card:juice_up(0.8, 0.8)
                    joker_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
                    return true
                end,
            }))
        end
        return { xmult = card.ability.x_mult }
    end,
    ["Square Joker"] = function (card, context)
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
        return { chips = card.ability.extra.chips }
    end,
    ["Seance"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Spectral",
                    key_append = "sea"
                })
                return true
            end,
        }))
    end,
    ["Riff-raff"] = function (card, context)
        local jokers_to_create = math.min(2, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                for _ = 1, jokers_to_create do
                    SMODS.add_card({
                        set = "Joker",
                        rarity = 0,
                        key_append = "rif"
                    })
                end
            end,
        }))
    end,
    ["Vampire"] = function (card, context)
        local enhanced = {}
        if context.scoring_hand and #context.scoring_hand > 0 then
            for k, v in ipairs(context.scoring_hand) do
                if v.config.center ~= G.P_CENTERS.c_base and not v.debuff and not v.vampired then
                    enhanced[#enhanced + 1] = v
                    v.vampired = true
                    v:set_ability(G.P_CENTERS.c_base, nil, true)
                end
                v.vampired = nil
            end
        elseif G and G.hand and #G.hand.highlighted > 0 then
            for k, v in ipairs(G.hand.highlighted) do
                if v.config.center ~= G.P_CENTERS.c_base and not v.debuff and not v.vampired then
                    enhanced[#enhanced + 1] = v
                    v.vampired = true
                    v:set_ability(G.P_CENTERS.c_base, nil, true)
                end
                v.vampired = nil
            end
        end
        card.ability.x_mult = card.ability.x_mult + (card.ability.extra * (#enhanced or 1))
        return { xmult = card.ability.x_mult }
    end,
    -- Shortcut
    ["Hologram"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    ["Vagabond"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Tarot",
                    key_append = 'vag'
                })
                return true
            end,
        }))
    end,
    ["Baron"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Cloud 9"] = function (card, context)
        if card.ability.nine_tally then
            ease_dollars(card.ability.extra * card.ability.nine_tally)
        else
            ease_dollars(card.ability.extra)
        end
    end,
    ["Rocket"] = function (card, context)
        card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.increase
        ease_dollars(card.ability.extra.dollars)
    end,
    ["Obelisk"] = function (card, context) -- Sobelisk
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    --#endregion
    --#region Page 6
    ["Midas Mask"] = function (card, context)
        local function convert_cards_in_list(cardlist)
            for _,select_card in ipairs(cardlist) do
                if select_card:is_face() then
                    select_card:set_ability(G.P_CENTERS.m_gold, nil, true)
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.4,
                        func = function()
                            v:juice_up()
                            return true
                        end,
                    }))
                end
            end
        end

        if context.scoring_hand then
            convert_cards_in_list(context.scoring_hand)
        elseif G and G.hand and #G.hand.highlighted > 0 then
            convert_cards_in_list(G.hand.highlighted)
        end
    end,
    ["Luchador"] = function (card, context)
        if G.GAME.blind and ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == "Boss")) then
            G.GAME.blind:disable()
        end
    end,
    ["Photograph"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Gift Card"] = function (card, context)
        for _,cardlist in ipairs({G.jokers.cards, G.consumeables.cards}) do
            for _, select_card in ipairs(cardlist) do
                if select_card.set_cost then
                    select_card.ability.extra_value = (select_card.ability.extra_value or 0) + card.ability.extra
                    select_card:set_cost()
                end
            end
        end
    end,
    ["Turtle Bean"] = function (card, context)
        G.hand:change_size(-card.ability.extra.h_size)
        card.ability.extra.h_size = card.ability.extra.h_size - card.ability.extra.h_mod
        G.hand:change_size(card.ability.extra.h_size)
    end,
    ["Erosion"] = function (card, context)
        return { mult = card.ability.extra * (G.GAME.starting_deck_size - #G.playing_cards) }
    end,
    ["Reserved Parking"] = function (card, context)
        ease_dollars(card.ability.extra.dollars)
    end,
    ["Mail-In Rebate"] = function (card, context)
       ease_dollars(card.ability.extra) 
    end,
    -- To the Moon
    ["Hallucination"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Tarot",
                    key_append = 'hal'
                })
                return true
            end,
        }))
    end,
    ["Fortune Teller"] = function (card, context)
        return { mult = G.GAME.consumeable_usage_total.tarot or 1 }
    end,
    ["Juggler"] = function (card, context)
        G.hand:change_size(card.ability.h_size)
    end,
    ["Drunkard"] = function (card, context)
        ease_discard(card.ability.d_size)
    end,
    ["Stone Joker"] = function (card, context)
        return { chips = card.ability.extra * card.ability.stone_tally }
    end,
    ["Golden Joker"] = function (card, context)
        ease_dollars(card.ability.extra)
    end,
    --#endregion
    --#region Page 7
    ["Lucky Cat"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    ["Baseball Card"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Bull"] = function (card, context)
        return { chips = card.ability.extra * math.max(0, (G.GAME.dollars + (G.GAME.dollar_buffer or 0))) }
    end,
    ["Diet Cola"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                add_tag(Tag("tag_double"))
                play_sound("generic1", 0.9 + math.random() * 0.1, 0.8)
                play_sound("holo1", 1.2 + math.random() * 0.1, 0.4)
                return true
            end,
        }))
    end,
    ["Trading Card"] = function (card, context)
        ease_dollars(card.ability.extra)
    end,
    ["Flash Card"] = function (card, context)
        card.ability.mult = card.ability.mult + card.ability.extra
        return { mult = card.ability.mult }
    end,
    ["Popcorn"] = function (card, context)
        card.ability.mult = card.ability.mult - card.ability.extra
        return { mult = card.ability.mult }
    end,
    ["Spare Trousers"] = function (card, context)
        card.ability.mult = card.ability.mult + card.ability.extra
        return { mult = card.ability.mult }
    end,
    ["Ancient Joker"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Ramen"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult - card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    ["Walkie Talkie"] = function (card, context)
        return { mult = card.ability.extra.mult, chips = card.ability.extra.chips }
    end,
    -- Seltzer
    ["Castle"] = function (card, context)
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
        return { chips = card.ability.extra.chips }
    end,
    ["Smiley Face"] = function (card, context)
        return { mult = card.ability.extra }
    end,
    ["Campfire"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    --#endregion
    --#region Page 8
    ["Golden Ticket"] = function (card, context)
        ease_dollars(card.ability.extra)
    end,
    -- Mr Bones
    ["Acrobat"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    -- Sock and Buskin
    ["Swashbuckler"] = function (card, context)
        return { mult = card.ability.mult }
    end,
    ["Troubadour"] = function (card, context)
        G.hand:change_size(card.ability.extra.h_size)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.h_plays
    end,
    ["Certificate"] = function (card, context)
        local _card = SMODS.create_card({
            set = "Base",
            seal = SMODS.poll_seal({
                guaranteed = true,
                type_key = 'certsl'
            }),
            area = G.discard,
            key_append = 'cert_fr'
        })
        _card:set_seal(SMODS.poll_seal({ guaranteed = true, type_key = "certsl" }))
        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:emplace(_card)
                _card:start_materialize()
                G.GAME.blind:debuff_card(_card)
                G.hand:sort()
                return true
            end,
        }))
    end,
    -- Smeared Joker
    ["Throwback"] = function (card, context)
        return { xmult = card.ability.x_mult }
    end,
    -- Hanging Chad
    ["Rough Gem"] = function (card, context)
        ease_dollars(card.ability.extra)
    end,
    ["Bloodstone"] = function (card, context)
        return { xmult = card.ability.extra.Xmult }
    end,
    ["Arrowhead"] = function (card, context)
        return { chips = card.ability.extra }
    end,
    ["Onyx Agate"] = function (card, context)
        return { mult = card.ability.extra }
    end,
    ["Glass Joker"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    --#endregion
    --#region Page 9
    ["Flower Pot"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Blueprint"] = function (card, context)
        local my_pos = card.rank
        local other_joker = G.jokers.cards[my_pos + 1]
        if other_joker then
            local results = Spectrallib.get_forcetrigger_results(other_joker, context)
            if results and results.jokers then
                results.jokers.card = card
                SMODS.calculate_effect(results.jokers)
            end
        end
    end,
    ["Wee Joker"] = function (card, context)
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
        return { chips = card.ability.extra.chips }
    end,
    ["Merry Andy"] = function (card, context)
        ease_discard(card.ability.d_size)
        G.hand:change_size(card.ability.h_size)
    end,
    -- Oops! All 6s
    ["The Idol"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Seeing Double"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Matador"] = function (card, context)
        ease_dollars(card.ability.extra)
    end,
    ["Hit The Road"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra
        return { xmult = card.ability.x_mult }
    end,
    ["The Duo"]    = hand_xmult,
    ["The Trio"]   = hand_xmult,
    ["The Family"] = hand_xmult,
    ["The Order"]  = hand_xmult,
    ["The Tribe"]  = hand_xmult,
    --#endregion
    --#region Page 10
    ["Stuntman"] = function (card, context)
        G.hand:change_size(-card.ability.extra.h_size)
        return { chips = card.ability.extra.chip_mod }
    end,
    ["Invisible Joker"] = function (card, context)
        -- could be cleaned but idk
        card.ability.invis_rounds = card.ability.invis_rounds + 1
        local jokers = {}
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] ~= card then
                jokers[#jokers + 1] = G.jokers.cards[i]
            end
        end
        if #jokers > 0 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local chosen_joker = pseudorandom_element(jokers, pseudoseed("invisible"))
                    local card = copy_card(
                        chosen_joker,
                        nil,
                        nil,
                        nil,
                        chosen_joker.edition and chosen_joker.edition.negative
                    )
                    if card.ability.invis_rounds then
                        card.ability.invis_rounds = 0
                    end
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    return true
                end,
            }))
        end
    end,
    ["Brainstorm"] = function (card, context)
        local other_joker = G.jokers.cards[1]
        if other_joker then
            local results = Spectrallib.get_forcetrigger_results(other_joker, context)
            if results and results.jokers then
                results.jokers.card = card
                SMODS.calculate_effect(results.jokers)
            end
        end
    end,
    ["Satellite"] = function (card, context)
        local planets_used = 0
        for _,consumable in pairs(G.GAME.consumeable_usage) do
            if consumable.set == "Planet" then
                planets_used = planets_used + 1
            end
        end
        ease_dollars(card.ability.extra * (planets_used or 1))
    end,
    ["Shoot The Moon"] = function (card, context)
        return  { mult = 13 }
    end,
    ["Driver's License"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Cartomancer"] = function (card, context)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                SMODS.add_card({
                    set = "Tarot",
                    key_append = 'car'
                })
                return true
            end,
        }))
    end,
    ["Burnt Joker"] = function (card, context)
        if #G.hand.highlighted > 0 then
            local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
                handname = localize(text, "poker_hands"),
                chips = G.GAME.hands[text].chips,
                mult = G.GAME.hands[text].mult,
                level = G.GAME.hands[text].level,
            })
            level_up_hand(card, text, nil, 1)
            update_hand_text(
                { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
                { mult = 0, chips = 0, handname = "", level = "" }
            )
        elseif context.scoring_name then
            level_up_hand(card, context.scoring_name)
        end
    end,
    ["Bootstraps"] = function (card, context)
        return { mult = card.ability.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars) }
    end,
    ["Caino"] = function (card, context)
        card.ability.caino_xmult = card.ability.caino_xmult + card.ability.extra
        return { xmult = card.ability.caino_xmult }
    end,
    ["Triboulet"] = function (card, context)
        return { xmult = card.ability.extra }
    end,
    ["Yorick"] = function (card, context)
        card.ability.x_mult = card.ability.x_mult + card.ability.extra.xmult
        return { xmult = card.ability.x_mult }
    end,
    ["Chicot"] = function (card, context)
        if G.GAME.blind and G.GAME.blind:get_type() == "Boss" then
            G.GAME.blind:disable()
        end
    end,
    ["Perkeo"] = function (card, context)
        local eligibleJokers = {}
        for i = 1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.consumeable then
                eligibleJokers[#eligibleJokers + 1] = G.consumeables.cards[i]
            end
        end
        if #eligibleJokers > 0 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local card_copy = copy_card(pseudorandom_element(eligibleJokers, pseudoseed("perkeo")), nil)
                    card_copy:set_edition({ negative = true }, true)
                    card_copy:add_to_deck()
                    G.consumeables:emplace(card_copy)
                    return true
                end,
            }))
        end
    end,
    ["Perkeo (Incantation)"] = function (card, context)
        if G.consumeables.cards[1] then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local total, checked, center = 0, 0, nil
                    for i = 1, #G.consumeables.cards do
                        total = total + (G.consumeables.cards[i]:getQty())
                    end
                    local poll = pseudorandom(pseudoseed("perkeo")) * total
                    for i = 1, #G.consumeables.cards do
                        checked = checked + (G.consumeables.cards[i]:getQty())
                        if checked >= poll then
                            center = G.consumeables.cards[i]
                            break
                        end
                    end
                    local _card = copy_card(center, nil)
                    _card:set_edition({ negative = true }, true)
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                    return true
                end,
            }))
        end
    end
    --#endregion
}