local M = {}

-- Point-resources (e.g. crude-oil, sulfuric-acid-geyser, fluorine-vent) are inexhaustible --
-- a handful of instances already provide sufficient supply, unlike ores that must be mined out
-- bit by bit. All of them yield a fluid rather than a solid item, so use that as the indicator
-- instead of the infinite/infinite_depletion_amount fields (which aren't reliably set by modded
-- resources).
function M.is_point_resource(resource)
    local results = resource.minable and resource.minable.results
    if not results then
        return false
    end

    for _, result in ipairs(results) do
        if result.type == 'fluid' and data.raw.fluid[result.name] then
            return true
        end
    end

    return false
end

-- Richness is not driven by the resource's own name -- e.g. Vulcanus' "tungsten-ore" entity is
-- controlled by the "tungsten_ore" autoplace control. Prefer the resource's own recorded control
-- name and fall back to pattern-matching its vanilla richness_expression, then to its own name.
function M.resource_control_name(resource)
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

return M
