Implementation note0.1.5: the first lighting/material pass is implemented; see HANDOFF.md for actual rendered evidence and performance limits. The original diagnosis below overstates uniformity: earlier builds already had timber/ground grain, a rifle-stock shader and some distinct roughness. New families extend those techniques. Foliage and overall composition remain unfinished.

Renderer verification: [Godot4.5 Environment](https://docs.godotengine.org/en/4.5/classes/class_environment.html) explicitly says glow levels, strength, blend mode, normalization and map have no effect in Compatibility. The general glow-level advice below therefore does not apply to this renderer. This build uses ACES, ambient sky contribution and adjustments; glow remains disabled. [BaseMaterial3D](https://docs.godotengine.org/en/4.5/classes/class_basematerial3d.html) provides local UV1 triplanar mapping used for the new material families.

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

## Renderer — revised after verification against the Godot 4.5 docs

Earlier guidance in this file said not to touch the renderer. **That was too cautious.**

Verified: Compatibility silently ignores SSAO, SSIL, SDFGI, screen-space reflections,
volumetric fog, depth of field, TAA, FXAA, SMAA and debanding. SSAO specifically is **not**
supported in 4.5 — the 4.6-dev docs mark it supported, so it is coming, but do not plan
around it yet.

The decisive fact is that **since Godot 4.4 the engine falls back to Compatibility at
runtime** when Vulkan, D3D12 or Metal is unavailable
(`rendering/rendering_device/fallback_to_opengl3`). Machines below the Forward+ floor still
run the game; they just get the simpler image. Forward+ needs roughly a 2015-era integrated
GPU or better, and macOS 10.15+.

So Forward+ is worth doing, but it must be **its own change**, validated separately on both
platforms and on the Intel Mac case, with the fallback path actually exercised rather than
assumed. Do not bundle it with the material work below.

**Everything in HUNT-17 and HUNT-18 works on Compatibility today.** Tonemapping, Adjustments
including LUT colour correction, Glow (reduced feature set), depth/height fog and MSAA 3D
are all supported. Do not wait on the renderer to start.

## Order

HUNT-17 first — smallest diff, largest visible change, and it recalibrates judgement of
everything after it. Then HUNT-18, which is the real fix. HUNT-19 and HUNT-20 are cheap
finishers. Judge each from native captures; automated checks cannot evaluate a look.

---

## Verified implementation details

Checked against the Godot 4.5 documentation. Use these rather than guessing.

**Tonemapping.** ACES or AgX. `tonemap_white` 6.0-8.0 applies to filmic/ACES and is
meaningless for Linear and AgX. AgX needs roughly twice the exposure of ACES, so re-check
`tonemap_exposure` after switching.

**Glow.** The docs recommend a *single* level set to 1.0 with the others at 0.0. Blend mode
Additive reads arcade; Softlight is the default. Set `glow_hdr_threshold` near 1.0 so only
genuinely bright surfaces bloom. Pair with `emission_enabled` and
`emission_energy_multiplier > 1.0` on a few accent surfaces — this is how solid-colour
geometry gets punch without textures.

**Fog.** Use depth and height fog, not volumetric. `fog_sun_scatter` and
`fog_aerial_perspective` tie geometry into the sky and give free depth separation. Both work
on Compatibility and do more for stylised depth than volumetrics would.

**Triplanar is the key unlock for HUNT-18.** The meshes here are built in code and have no
UVs, so ordinary texturing cannot work. `StandardMaterial3D` has it built in:
`uv1_triplanar = true`, plus `uv1_triplanar_sharpness`, `uv1_world_triplanar` and `uv1_scale`.
That texturises UV-less procedural geometry with no UV work at all. Known bug: triplanar on
UV2 breaks UV1 normal maps (godot#120312), so keep it on UV1.

**Rim light.** `rim_enabled`, `rim` 1.0, `rim_tint` 0.5 separates silhouettes cheaply and
suits a stylised look.

**Two gotchas that will silently cost time.**
- `SurfaceTool.set_color()` must be called before the **first** `add_vertex()`, or the vertex
  format is locked without colour and every later call is ignored. Then set
  `vertex_color_use_as_albedo = true`.
- On `MultiMeshInstance3D`, set `use_colors = true` **before** any `set_instance_color()`,
  same ordering trap.

**Colour grading.** `adjustment_color_correction` accepts a Texture3D LUT at 17³ or 33³, or a
GradientTexture1D for a cheaper ramp. A single LUT unifies the whole palette in one asset and
is the best quality-per-effort item available here.

**Anti-aliasing.** MSAA 3D at 4x is the documented recommendation for stylised games and does
work on Compatibility. SMAA, FXAA and TAA require Forward+ or Mobile. TAA suits photoreal and
adds blur and ghosting; it is the wrong choice for this look.

**Camera.** Default `fov` is 75 vertical. 55-65 with the camera pulled back reads more
cinematic and, usefully here, reduces the perspective distortion that makes primitive shapes
look like primitives.

**Animation feel (supports HUNT-16).** `Tween` with `TRANS_BACK` and `EASE_OUT` is the
workhorse for overshoot-and-settle. Roughly 0.2s for a scale pop, 0.05-0.1s of anticipation
counter-movement before an action. `parallel()` and `chain()` layer secondary motion in a few
lines. For squash and stretch, a small damped spring driving scale per frame beats a one-shot
tween, because it overshoots and settles on its own.
