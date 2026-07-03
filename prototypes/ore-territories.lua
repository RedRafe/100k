local f = string.format
local terrain_utils = require 'prototypes.terrain-utils'
local territory_size = settings.startup['100k-territory-size'].value

for _, planet in pairs(data.raw.planet) do
    local map_gen_settings = planet.map_gen_settings
    local entity_settings = map_gen_settings
        and map_gen_settings.autoplace_settings
        and map_gen_settings.autoplace_settings.entity
        and map_gen_settings.autoplace_settings.entity.settings

    -- find ore resources on this planet: autoplace_settings.entity.settings lists every entity
    -- autoplaced on this planet (ores, rocks, fish, ...) -- keep only the ones that are
    -- resources, excluding point-resources since those don't get a voronoi territory.
    local resources = {}
    if entity_settings then
        for name in pairs(entity_settings) do
            local resource = data.raw.resource[name]
            if resource and not terrain_utils.is_point_resource(resource) then
                table.insert(resources, name)
            end
        end
    end

    if #resources > 0 then
        table.sort(resources) -- deterministic ordering, independent of table iteration order

        -- weigh each resource by its control name's whitelisted weight (default 100 -- see
        -- prototypes/ore-weights.lua), so its share of the voronoi cell-id space [0, 1) is
        -- proportional to weight instead of split evenly across #resources.
        local weights = {}
        local total_weight = 0
        for _, name in ipairs(resources) do
            local control_name = terrain_utils.resource_control_name(data.raw.resource[name])
            local weight = _100k.get_ore_weight(control_name)
            weights[name] = weight
            total_weight = total_weight + weight
        end

        -- define a voronoi expression for this planet: each cell is assigned to exactly one
        -- resource. seed1 includes planet.name so every planet gets an independent voronoi layout.
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
        local cumulative_weight = 0

        for index, name in ipairs(resources) do
            local resource = data.raw.resource[name]
            local low = cumulative_weight / total_weight
            cumulative_weight = cumulative_weight + weights[name]

            local territory_expression
            if index == #resources then
                -- last fragment stays open-ended above `low`, so floating-point rounding can
                -- never leave a sliver of cell-id space unclaimed by any resource.
                territory_expression = f([[(var('%s') >= %.10f)]], cell_id_name, low)
            else
                local high = cumulative_weight / total_weight
                territory_expression = f(
                    [[((var('%s') >= %.10f) * (var('%s') < %.10f))]],
                    cell_id_name, low, cell_id_name, high
                )
            end

            local probability_name = f('100k-%s-%s-probability', planet.name, name)
            local richness_name = f('100k-%s-%s-richness', planet.name, name)

            -- define resource richness: two-regime curve fit to target distance|richness pairs
            -- (0|1.5k, 700|15k, 1k|20k, 2.5k|25k, 5k|30k, 20k|150k, 100k|800k, 250k|2.2M) -- a
            -- log2 term for the steep near-spawn ramp, maxed against a power-law term that takes
            -- over for the long-run growth -- scaled by the resource's own control:<name>:richness
            -- slider so map-gen settings still work.
            local control_name = terrain_utils.resource_control_name(resource)
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
