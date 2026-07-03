-- Global API for whitelisting ore territory weights. Declared here in the data stage and left
-- open through data-updates.lua so this mod (and, in principle, other mods) can register or
-- override a resource's weight before data-final-fixes.lua reads the final dictionary and builds
-- the weighted voronoi territories. Weight is keyed by the resource's autoplace control name
-- (see terrain-utils.resource_control_name), since that's what's stable across reskinned/renamed
-- ore entities (e.g. Vulcanus' "tungsten-ore" entity uses control "tungsten_ore").
_G._100k = _G._100k or {}

local _100k = _G._100k
_100k.weights = _100k.weights or {}
_100k.default_ore_weight = _100k.default_ore_weight or 100

function _100k.set_ore_weight(control_name, weight)
    _100k.weights[control_name] = weight
end

function _100k.get_ore_weight(control_name)
    return _100k.weights[control_name] or _100k.default_ore_weight
end
