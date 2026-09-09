# Stealth, noise and realism — owner-requested plan

Implementation update0.1.3: HUNT-11/12 now implemented with Ctrl/C crouch, full-shape standing clearance, physical speeds, replicated eye height/noise, actual surface-dependent movement sound and HUD meter. Protocol2, schema1. Selected physical/network checks pass; human stealth balance remains unverified. The original design below is historical intent. HUNT-13/14 are implemented in0.1.4: permanent shared boots/wool/scent cover and muffled barrel, with host distance falloff and physical-impact tests. HUNT-15/16 remain future work.

Captured 2026-09-08 from direct owner feedback, written against the source at `7c300d5`
(v0.1.2). Registered as HUNT-11 through HUNT-16. This is design input for a future bounded
session, not a claim that any of it is implemented.

Owner's words: *"there's no crouching mechanism to stalk and not deter deer from running,
and there should be rates at which animals flee depending on your sneaky level. There should
be upgrades to help deter sounds and become quieter, and shots fired should scare other
animals away unless you have a silencer."*

| ID | Outcome | Current state | Next evidence/action |
| --- | --- | --- | --- |
| HUNT-11 | Deliberate stalking via a crouch stance | Absent. `scripts/avatar.gd` has only sprint/walk. | Add `input_crouch`, third speed tier, lowered camera and capsule. Requires a PROTOCOL bump. |
| HUNT-12 | Flee rate scales continuously with how quietly you move | Binary: alert gain 0.9 sprinting / 0.45 otherwise. | Replace with a 0..1 `noise` value; add a HUD stealth meter so the system is learnable. |
| HUNT-13 | Gear that makes you quieter and harder to smell | No stealth items exist in `ITEMS`. | Add boots, overshirt and scent cover with tuned costs. Save-safe; see note below. |
| HUNT-14 | Shots spook nearby animals unless suppressed | Fixed 30 m hard snap to `alert=1`. | Add a silencer item, gear-dependent radius and distance falloff. |
| HUNT-15 | Wind is a live variable, not a memorised constant | Hardcoded `Vector3(.8,0,.6)`; HUD says "south-east". | Host-owned rotating wind, replicated and shown in world and HUD. |
| HUNT-16 | Supporting realism that rewards patience | Partly present via `head_pitch` tells and existing tracks. | Freeze-to-calm, herd awareness, readable pre-flee tell, wounded trails, stamina, light-dependent sight. |

---

## What already works — do not rebuild this

`hunt/deer.gd` already implements three independent senses feeding one `alert` value:

| Sense | Current rule |
| --- | --- |
| Sight | line-of-sight raycast, radius 18 sprinting / 6.5 aiming / 11 walking |
| Scent | within 9 m **and** hunter is downwind (`dot(wind) < -0.4`) |
| Hearing | moving **and** within 9 m sprinting / 3 m otherwise |

Alert drives graduated states `graze` → `alert` (>0.35) → `flee` (>0.72), with the Crownback
winding up at >0.65, decaying 0.18/s when undetected. `hunt/game.gd` already alerts every
animal within 30 m of a shot. Everything below extends this foundation rather than
replacing it.

## HUNT-11 — Crouch

`scripts/avatar.gd` computes `speed = 6.5 if input_sprint else 4.5`. Two stances, so there is
no way to deliberately move slowly, and aiming is currently the only quiet option — which
overloads a combat control with a movement job.

- Add `input_crouch` beside `input_sprint`, bound to **Ctrl**.
- Third speed tier near `1.8`, lowered camera (1.58 → ~1.05) and a shorter collision capsule
  so ferns, rocks and deadfall genuinely conceal.
- Crouch sharply cuts hearing radius and modestly reduces sight radius.

**Networking cost.** `submit_input()` and the `player_input` RPC carry a fixed argument list
`(move, yaw, pitch, jump, sprint, aim)`. Adding crouch changes that signature, so `PROTOCOL`
in `hunt/catalog.gd` must increment and every player needs a matching build. Batch this with
any other input change rather than bumping the protocol twice.

## HUNT-12 — Continuous sneak level

Replace the two-value alert gain with one host-side `noise` in 0..1 built from:

- stance base — sprint 1.0 · walk 0.55 · crouch 0.2 · standing still 0.0
- multiplied by actual `visual_speed`, so stopping is immediately quiet
- multiplied by surface (leaf litter louder than trail or moss)
- multiplied by the HUNT-13 gear factor

Then swap the constants: hearing radius becomes `lerp(2, 14, noise)`; alert gain becomes
`lerp(0.15, 1.0, noise)`.

**A HUD stealth meter is not optional.** A hidden continuous system reads as random
unfairness. The player has to see the needle fall when they crouch and stop, or the whole
mechanic is invisible.

## HUNT-13 — Stealth gear

| Item | Effect | Rough cost |
| --- | --- | --- |
| Softstep boots | ~40% movement noise reduction | 35 |
| Wool overshirt | further noise cut, lower visual contrast | 55 |
| Scent cover | shrinks the 9 m downwind scent radius | 40 |
| Muffled barrel | HUNT-14 | 130 |

Stealth gear should be reachable early — it is a core verb, not a luxury. The silencer is the
exception and belongs above `rifle2` as a real progression goal.

**Save compatibility is free.** `Catalog.valid_progress()` validates upgrades with
`ITEMS.has(id)`, so *adding* keys is automatically schema-safe and old saves still load with
no schema bump. The reverse does not hold: **never remove an item id**, as that invalidates
every save holding it.

## HUNT-14 — Silencer and shot propagation

Today every animal within 30 m snaps to `alert=1` — binary, fixed, no counterplay.

- Radius from gear: 30 m default, ~10 m with the muffled barrel.
- Falloff rather than a snap: `alert += clamp(1 - d/radius)`, so distant deer grow wary
  instead of instantly bolting.
- A silenced *miss* should still produce a local impact cue. Silence must not mean
  consequence-free.

## HUNT-15 — Dynamic wind

Wind is baked into the scent check and the HUD string, so players memorise one safe approach
forever. Make it a slowly rotating host-owned value, replicate it in the state packet, and
show it — a vane at camp, drifting grass, a HUD indicator. Approach direction then becomes a
fresh decision every hunt.

## HUNT-16 — Supporting realism, in priority order

1. **Freeze-to-calm.** Standing still should decay alert faster than the flat 0.18/s. This is
   the heart of stalking: spooked → freeze → wait → resume.
2. **Herd awareness.** One deer fleeing raises nearby deer's alert. Cheap, large payoff.
3. **Readable pre-flee tell.** `head_pitch` already animates; make the head-up stare
   unmistakable so the player gets a fair beat to freeze before the deer bolts.
4. **Distinct wounded tracks**, so following a hit animal is legible.
5. **Sprint stamina**, making sprint a real tradeoff rather than a free default.
6. **Light-dependent sight radius**, riding along with the lighting and sky work.

## Sequencing

| Phase | Contents | Why this order |
| --- | --- | --- |
| 1 | HUNT-11, HUNT-12 | The core verb. Nothing else matters if stalking does not feel good. |
| 2 | HUNT-13, HUNT-14 | Attaches progression to the verb. |
| 3 | HUNT-15, HUNT-16 items 1-2 | Makes each hunt situationally different. |
| 4 | HUNT-16 items 3-6 | Polish once the loop is proven fun. |

## Cross-cutting risks

- **Protocol bump** for the crouch input; all builds must match.
- **Host authority is non-negotiable.** All noise and detection math runs host-side in
  `deer.step()`; guests only render. Never compute stealth client-side — that is both a
  desync and a cheat vector.
- **Tests need updating in the same change.** `tests/hunt_network.gd` walks a guest toward a
  deer and assumes it can close the distance; harsher detection can break that flow.
- **Every number here is a starting point, not a result.** Automated checks can prove the
  system runs; only a human playtest proves stalking is fun.
