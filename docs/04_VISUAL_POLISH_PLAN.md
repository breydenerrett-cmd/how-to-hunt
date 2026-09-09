# Visual polish — why it reads as generated, and the fixes

Written 2026-09-08 against `hunt/forest.gd` and `scripts/visuals.gd`. Registered as HUNT-17
to HUNT-20. None of this needs Blender, imported textures or an art pipeline; it is all code.

| ID | Outcome | Current state | Next evidence/action |
| --- | --- | --- | --- |
| HUNT-17 | Image reads as graded and lit, not raw | Linear tonemap, no glow, no grade, sky lights nothing. | Environment pass. One small diff, changes every frame. Compare before/after 1080p captures. |
| HUNT-18 | Surfaces read as different materials | Every object shares one flat colour and roughness 0.82. | Surface families with procedural noise normal/roughness maps. |
| HUNT-19 | Repeated props stop reading as clones | Props placed with uniform scale, rotation and colour. | Per-instance hue/scale/rotation jitter. |
| HUNT-20 | Objects sit in the world instead of on it | Compatibility has no SSAO, so nothing has contact shading. | Cheap grounding: darkened contact geometry at object bases. |

---

## HUNT-17 — Environment pass, highest return per line

`hunt/forest.gd:19-26` currently suppresses most of Godot's image quality:

| Setting | Now | Change to | Why |
| --- | --- | --- | --- |
| `tonemap_mode` | `TONE_MAPPER_LINEAR` | `TONE_MAPPER_AGX` (or `ACES`) | Linear is the flattest option. This is the single largest perceived-quality change available. Set `tonemap_white` and re-check `tonemap_exposure` after. |
| `ambient_light_sky_contribution` | `0` | ~`0.4`-`0.6` | The sky is drawn but lights nothing, so ambient is one flat grey-green from all directions. This is the main reason the scene looks evenly lit and depthless. |
| `glow_enabled` | unset | `true`, low intensity/bloom | Lets sun, sky and bright highlights read. Keep subtle; heavy bloom reads as cheap. |
| `adjustment_enabled` | unset | `true`, contrast ~1.05-1.15, saturation ~1.05-1.10 | Free colour grading. Small values only. |
| `msaa_3d` (project.godot) | `1` (2x) | `2` (4x) | Cleaner silhouettes, cheap at this geometry density. |

Verify with matched 1080p before/after captures of the same camera position, not from memory.

## HUNT-18 — Surface families, the actual "generated" tell

`scripts/visuals.gd:10` gives every object in the game a flat `albedo_color` and
**`roughness = 0.82`**. Deer coat, bark, stone, timber, dirt and the rifle therefore all
respond to light identically and differ only in hue. That uniformity is what reads as
painted plastic, and it is a materials problem rather than a modelling one.

The project already has the right technique in hand — `hunt/forest.gd:23-24` builds a
`FastNoiseLite` + `NoiseTexture2D` for sky clouds. It is simply never applied to a surface.
Godot can generate albedo, roughness **and** normal maps procedurally at runtime with no
image files; `NoiseTexture2D` exposes `as_normal_map` and `bump_strength` directly.

Add a surface-family layer above the existing `material()`:

| Family | Roughness | Character |
| --- | --- | --- |
| bark | 0.9-1.0 | strong vertical-biased normal, low bump frequency |
| stone | 0.7-0.85 | mid-frequency normal, slight speckle in albedo |
| fur | 0.85-0.95 | fine high-frequency normal, near-zero specular |
| cloth | 0.8-0.9 | soft weave normal |
| metal | 0.25-0.45 | `metallic` raised, smooth, minimal normal |
| foliage | 0.75-0.9 | some translucency, high-frequency detail |
| ground | 0.9-1.0 | large-scale normal to break flatness underfoot |

Keep `material()` working so nothing breaks; families call into it and then attach the
generated maps. Generate each family's textures **once** and share them — do not build a
NoiseTexture2D per object, which would wreck load time and memory.

## HUNT-19 — Per-instance variation

Identical repeated props are the other strong tell. Where props, trees, rocks and foliage
are placed, apply small deterministic jitter seeded from position or index so it stays
save-stable and identical on host and guests:

- hue ±0.02, value ±0.06 on the base colour
- uniform scale ±8%, plus non-uniform ±4% on height
- yaw fully random; slight tilt ±3 degrees where it does not break collision

Determinism matters: seed from entity id or grid position, never from `randf()` at runtime,
or host and guests will disagree.

## HUNT-20 — Grounding without SSAO

The Compatibility renderer has no screen-space ambient occlusion, so nothing casts short
contact shading and objects read as stickers placed on the terrain. Cheapest effective fix
is an explicit darkened contact element at the base of trees, rocks, buildings and props — a
small flattened dark translucent mesh, or vertex-darkening on the lowest geometry ring.

## Open decision — renderer

Compatibility caps this work: no SSAO, no SSIL, no volumetric fog. Forward+ would unlock
them, at the cost of a higher GPU requirement that may exclude older machines, including the
Intel Mac case noted in VALIDATION. **Do not switch renderers as part of the above.** It is a
separate decision needing the owner's call on minimum hardware, and it must be re-validated
on both platforms.

## Order

HUNT-17 first — smallest diff, largest visible change, and it recalibrates judgement of
everything after it. Then HUNT-18, which is the real fix. HUNT-19 and HUNT-20 are cheap
finishers. Judge each from native captures; automated checks cannot evaluate a look.
