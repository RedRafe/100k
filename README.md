# 100k

Play Factorio at 100k! Massive ore territories and a 100k tech cost multiplier, with configurable settings to tune the challenge to your liking.

---

## Features

- **Voronoi ore territories** — Iron ore, copper ore, coal, stone, and uranium ore are assigned to large territories using the engine's native `voronoi_cell_id` noise function. Each region of the map is claimed entirely by one resource type instead of vanilla's patchy placement, so once you're in a territory you're standing on ore.
- **Weighted territories** — Each ore has a weight (default `100`); a territory's share of the map is proportional to its resource's weight against the total, so heavier-than-default ores are found in more (and larger) territories, lighter ones in fewer/smaller ones. See [Modding API](#modding-api) below to register weights for your own ores.
- **Rebuilt richness curve** — Richness no longer follows vanilla's patch-driven noise (which evaluates near-zero outside the original patch shapes). Instead it uses a two-regime curve — a steep near-spawn ramp that gives way to long-run power-law growth — so richness scales smoothly with distance from spawn across an entire territory. Vanilla's richness control slider still works as a multiplier.
- **Point-resources left alone** — Fluid-yielding resources (crude oil, sulfuric acid geysers, fluorine vents, etc.) are excluded from territory assignment, since a handful of instances already provide sufficient supply. They keep vanilla's own placement, just scaled up.
- **Configurable technology cost scaling** — A startup setting controls how aggressively the technology cost multiplier (100k) is enforced, with early-game exceptions and an easier biter ramp-up available at lower difficulties.

---

## Settings

All settings are **startup** settings (require a new save / map regeneration to take effect).

| Setting | Default | Range | Description |
|---|---|---|---|
| `Territory size` | `76` | 32 – 1024 | Average size, in tiles, of each Voronoi territory. |
| `Point-resource multiplier` | `5` | 1 – 100 | Multiplier applied to the probability, richness, and frequency of point-resources (crude oil, sulfuric acid geysers, fluorine vents, etc.), instead of confining them to a territory. |
| `Technology difficulty` | `normal` | `easy` / `normal` / `hard` | Controls how aggressively technology costs are scaled to match the 100k territory size. See below. |

### Technology difficulty

| Difficulty | Tech adjustments | Cost multiplier | Biters |
|---|---|---|---|
| **Hard** | None. | Always set to 100k. | Vanilla spawn distance. |
| **Normal** | `logistics` and `electric-mining-drill` ignore the cost multiplier, making early game less tedious. | Forced to 100k only if not already set higher (respects a custom map-exchange multiplier). | Vanilla spawn distance. |
| **Easy** | Same as Normal. | Never forced — whatever the map/exchange string sets is used as-is. | Pushed much further from the starting area. |

---

## Modding API

Other mods can register a territory weight for their own ore before territories are built. The API is exposed as a global `_100k` table:

```lua
-- data.lua / data-updates.lua of your mod, after 100k's data.lua has run
_100k.set_ore_weight(control_name, weight)
_100k.get_ore_weight(control_name) -- returns the registered weight, or 100 if none is set
```

- `control_name` is the resource's **autoplace control name**, not necessarily its entity/item name — e.g. Vulcanus' `tungsten-ore` entity is driven by the `tungsten_ore` control. Check the resource's `prototype.autoplace.control` (or `data.raw["autoplace-control"]`) if you're not sure what your ore's control is named.
- `weight` is a plain number, relative to every other ore on the same planet. A weight of `200` gets twice the territory share of a default (`100`) ore on that planet; a weight of `50` gets half.
- Registration must happen **before `data-final-fixes.lua`** — that's the stage where 100k reads the final weight dictionary and builds the voronoi territories. `data.lua` or `data-updates.lua` both work; add a dependency on `100k` (`?` or `~`) in your `info.json` so your `data.lua` doesn't run before 100k's has declared the `_100k` global.
- If you don't register a weight, your ore is simply left at the default of `100`.

---

*Join my [Discord](https://discord.gg/pq6bWs8KTY)*