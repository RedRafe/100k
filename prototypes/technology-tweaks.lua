local f = string.format
local difficulty = settings.startup['100k-technology-difficulty'].value

-- Hard leaves technology costs untouched at the proto stage -- control.lua alone enforces the
-- 100k multiplier there. Normal and Easy let a couple of early techs bypass that multiplier so
-- the run isn't gated on grinding them out at x100k cost.
if difficulty == 'normal' or difficulty == 'easy' then
    for _, name in ipairs({ 'logistics', 'electric-mining-drill' }) do
        local technology = data.raw.technology[name]
        if technology then
            technology.ignore_tech_cost_multiplier = true
        end
    end
end

-- Easy additionally pushes enemy-base spawners/worms further from spawn than vanilla, giving a
-- larger buffer before the player has to deal with biters. Gated on distance rather than a flat
-- tile count so it scales with the "starting area" map-gen setting instead of a fixed radius.
if difficulty == 'easy' then
    local function push_back(entities)
        for _, entity in pairs(entities) do
            local autoplace = entity.autoplace
            if autoplace and autoplace.control == 'enemy-base' and autoplace.probability_expression then
                autoplace.probability_expression = f(
                    '(%s) * clamp((distance - 4 * starting_area_radius) / starting_area_radius, 0, 1)',
                    autoplace.probability_expression
                )
            end
        end
    end

    push_back(data.raw['unit-spawner'] or {})
    push_back(data.raw['turret'] or {})
end
