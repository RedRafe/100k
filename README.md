# 100k

Nauvis resources are arranged into large Voronoi ore territories, each fully covered by its assigned resource, instead of vanilla's sparse, scattered patches.

---

## Features

- **Voronoi ore territories** — Iron ore, copper ore, coal, stone, and uranium ore are assigned to large territories using the engine's native `voronoi_cell_id` noise function. Each region of the map is claimed entirely by one resource type instead of vanilla's patchy placement, so once you're in a territory you're standing on ore.
- **Rebuilt richness curve** — Richness no longer follows vanilla's patch-driven noise (which evaluates near-zero outside the original patch shapes). Instead it uses a two-regime curve — a steep near-spawn ramp that gives way to long-run power-law growth — so richness scales smoothly with distance from spawn across an entire territory. Vanilla's richness control slider still works as a multiplier.
- **Point-resources left alone** — Fluid-yielding resources (crude oil, sulfuric acid geysers, fluorine vents, etc.) are excluded from territory assignment, since a handful of instances already provide sufficient supply. They keep vanilla's own placement, just scaled up.
- **Configurable technology cost scaling** — A startup setting controls how aggressively the technology cost multiplier (100k) is enforced, with early-game exceptions and an easier biter ramp-up available at lower difficulties.

---

## Settings

All settings are **startup** settings (require a new save / map regeneration to take effect).

| Setting | Type | Default | Range | Description |
|---|---|---|---|---|
| `100k-territory-size` | int | `76` | 32 – 1024 | Average size, in tiles, of each Voronoi territory. |
| `100k-point-resource-multiplier` | double | `5` | 1 – 100 | Multiplier applied to the probability, richness, and frequency of point-resources (crude oil, sulfuric acid geysers, fluorine vents, etc.), instead of confining them to a territory. |
| `100k-technology-difficulty` | string | `normal` | `easy` / `normal` / `hard` | Controls how aggressively technology costs are scaled to match the 100k territory size. See below. |

### Technology difficulty

| Difficulty | Tech adjustments | Cost multiplier | Biters |
|---|---|---|---|
| **Hard** | None. | Always set to 100k. | Vanilla spawn distance. |
| **Normal** | `logistics` and `electric-mining-drill` ignore the cost multiplier, making early game less tedious. | Forced to 100k only if not already set higher (respects a custom map-exchange multiplier). | Vanilla spawn distance. |
| **Easy** | Same as Normal. | Never forced — whatever the map/exchange string sets is used as-is. | Pushed much further from the starting area. |
