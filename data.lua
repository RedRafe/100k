require('prototypes.ore-weights')

-- Whitelisted territory weights for known ores: a resource's voronoi fragments are sized
-- proportionally to its weight against the total, so heavier-than-default resources cover more
-- of the map (and are found more often) than default-weight (100) ones, and lighter ones less.
-- Anything not listed here falls back to _100k.default_ore_weight.
_100k.set_ore_weight('iron-ore', 150)
_100k.set_ore_weight('copper-ore', 100)
_100k.set_ore_weight('coal', 100)
_100k.set_ore_weight('stone', 100)
_100k.set_ore_weight('uranium-ore', 10)
_100k.set_ore_weight('tungsten_ore', 200)
_100k.set_ore_weight('vulcanus_coal', 100)
_100k.set_ore_weight('gleba_stone', 100)
_100k.set_ore_weight('calcite', 50)
