local f = string.format
local territory_size = settings.startup['100k-territory-size'].value

-- Richness is not driven by the resource's own name -- e.g. Vulcanus' "tungsten-ore" entity is
-- controlled by the "tungsten_ore" autoplace control. Prefer the resource's own recorded control
-- name and fall back to pattern-matching its vanilla richness_expression, then to its own name.
local function resource_control_name(resource)
    local autoplace = resource.autoplace
    if autoplace and autoplace.control then
        return autoplace.control
    end

    local richness_expression = autoplace and autoplace.richness_expression
    if type(richness_expression) == 'string' then
        local control = richness_expression:match('control:([%w_%-]+):richness')
        if control then
            return control
        end
    end

    return resource.name
end

for _, planet in pairs(data.raw.planet) do
    local map_gen_settings = planet.map_gen_settings
    local entity_settings = map_gen_settings
        and map_gen_settings.autoplace_settings
        and map_gen_settings.autoplace_settings.entity
        and map_gen_settings.autoplace_settings.entity.settings

    -- 1. find resources on this planet: autoplace_settings.entity.settings lists every entity
    -- autoplaced on this planet (ores, rocks, fish, ...) -- keep only the ones that are resources.
    local resources = {}
    if entity_settings then
        for name in pairs(entity_settings) do
            if data.raw.resource[name] then
                table.insert(resources, name)
            end
        end
        --table.sort(resources)
    end

    if #resources > 0 then
        -- 2. define a voronoi expression for this planet: each cell is assigned to exactly one
        -- resource, splitting the planet into #resources territories of roughly territory_size.
        -- seed1 includes planet.name so every planet gets an independent voronoi layout.
        local cell_id_name = '100k-territory-cell-id-' .. planet.name
        data:extend({
            {
                type = 'noise-expression',
                name = cell_id_name,
                expression = f([[
                    voronoi_cell_id{
                        x = x,
                        y = y,
                        seed0 = map_seed,
                        seed1 = '100k-territory-%s',
                        grid_size = %s,
                        distance_type = 'euclidean',
                        jitter = 1
                    }
                ]], planet.name, territory_size),
            },
        })

        local property_expression_names = map_gen_settings.property_expression_names or {}

        for index, name in ipairs(resources) do
            local resource = data.raw.resource[name]
            local territory_expression = f([[(floor(var('%s') * %d) == %d)]], cell_id_name, #resources, index - 1)
            local probability_name = f('100k-%s-%s-probability', planet.name, name)
            local richness_name = f('100k-%s-%s-richness', planet.name, name)

            -- 3. define resource richness: two-regime curve fit to target distance|richness pairs
            -- (0|1.5k, 700|15k, 1k|20k, 2.5k|25k, 5k|30k, 20k|150k, 100k|800k, 250k|2.2M) -- a
            -- log2 term for the steep near-spawn ramp, maxed against a power-law term that takes
            -- over for the long-run growth -- scaled by the resource's own control:<name>:richness
            -- slider so map-gen settings still work.
            local control_name = resource_control_name(resource)
            local richness_expression = f(
                [[(var('control:%s:size') > 0) * (var('control:%s:richness') * max(1500 + 4500 * log2(1 + distance / 60), 2.53 * pow(distance, 1.1)))]],
                control_name, control_name
            )

            data:extend({
                { type = 'noise-expression', name = probability_name, expression = territory_expression },
                { type = 'noise-expression', name = richness_name, expression = richness_expression },
            })

            resource.autoplace = resource.autoplace or {}
            resource.autoplace.probability_expression = territory_expression
            resource.autoplace.richness_expression = richness_expression

            property_expression_names[f('entity:%s:probability', name)] = probability_name
            property_expression_names[f('entity:%s:richness', name)] = richness_name
        end

        map_gen_settings.property_expression_names = property_expression_names
    end
end


log(serpent.block(data.raw.resource['iron-ore']))
log(serpent.block(data.raw.resource['crude-oil']))
