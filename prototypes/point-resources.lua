local f = string.format
local terrain_utils = require 'prototypes.terrain-utils'
local point_resource_multiplier = settings.startup['100k-point-resource-multiplier'].value

-- Point-resources keep their own default frequency/richness autoplace expression -- just scaled
-- up by a configurable factor instead of being confined to a voronoi territory (voronoi territory
-- assignment for ores happens later, in data-final-fixes, once every mod's resources are final).
for _, planet in pairs(data.raw.planet) do
    local map_gen_settings = planet.map_gen_settings
    local entity_settings = map_gen_settings
        and map_gen_settings.autoplace_settings
        and map_gen_settings.autoplace_settings.entity
        and map_gen_settings.autoplace_settings.entity.settings

    if entity_settings then
        local property_expression_names = map_gen_settings.property_expression_names or {}
        local changed = false

        for name in pairs(entity_settings) do
            local resource = data.raw.resource[name]
            if resource and terrain_utils.is_point_resource(resource) then
                local autoplace = resource.autoplace
                if autoplace and autoplace.probability_expression and autoplace.richness_expression then
                    local probability_name = f('100k-%s-%s-probability', planet.name, name)
                    local richness_name = f('100k-%s-%s-richness', planet.name, name)
                    local probability_expression = f('(%s) * %s', autoplace.probability_expression, point_resource_multiplier)
                    local richness_expression = f('(%s) * %s', autoplace.richness_expression, point_resource_multiplier)

                    data:extend({
                        { type = 'noise-expression', name = probability_name, expression = probability_expression },
                        { type = 'noise-expression', name = richness_name, expression = richness_expression },
                    })

                    autoplace.probability_expression = probability_expression
                    autoplace.richness_expression = richness_expression

                    property_expression_names[f('entity:%s:probability', name)] = probability_name
                    property_expression_names[f('entity:%s:richness', name)] = richness_name
                    changed = true
                end
            end
        end

        if changed then
            map_gen_settings.property_expression_names = property_expression_names
        end
    end
end
