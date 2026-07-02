local difficulty = settings.startup['100k-technology-difficulty'].value

script.on_init(function()
    if difficulty == 'hard' then
        game.difficulty_settings.technology_price_multiplier = 1e5
    elseif difficulty == 'normal' then
        if game.difficulty_settings.technology_price_multiplier == 1 then
            game.difficulty_settings.technology_price_multiplier = 1e5
        end
    end
    -- Easy leaves the multiplier alone entirely, so playing at whatever the map/exchange string set is possible.
end)
