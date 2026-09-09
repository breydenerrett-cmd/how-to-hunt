# Hauling, risk and the upgrade ladder — owner design direction

Captured 2026-09-08 from owner feedback with gameplay screenshots. Registered HUNT-21 to
HUNT-26. HUNT-21 and HUNT-26 are **observed bugs with photographic evidence**, not proposals.

| ID | Outcome | Current state | Next evidence/action |
| --- | --- | --- | --- |
| HUNT-21 | Hauling a carcass never blocks the view | **BUG.** Carcass occludes the camera; in owner screenshots it fills the screen entirely. | Fix before any other hauling work. Capture a 1080p haul sequence as proof. |
| HUNT-22 | The player chooses between a fast light haul and a slow valuable one | Only option is dragging the whole animal. | Field dressing for pelts: less value, keeps you mobile and armed. |
| HUNT-23 | Carrying is the tense part of the loop, not the boring part | Carrying is currently a safe walk with no downside. | No rifle while hauling; predators contest the kill. |
| HUNT-24 | Hauling looks like effort | No grip, no hand contact, no strain in the pose. | Two-handed grip, lean, slower gait, weight-dependent. |
| HUNT-25 | Transport is a visible upgrade ladder | Dragging by hand only. | Travois, handcart, pack animal, wagon - each removing a real constraint. |
| HUNT-26 | World labels never overlap the HUD | **BUG.** "CROWNBACK RIDGE" overlaps the top-right panel in owner screenshots. | Reserve HUD margins; shrink and fade distant labels. |

---

## Why this direction is right — the design argument

The owner's instinct here is the important part and worth stating explicitly, because it is
what makes the reference fishing game addictive despite being simple.

**Right now the return trip is dead time.** You have already succeeded; you are just walking
home. Every second of it is pure tax on the fun. The owner's proposal — you cannot hold your
rifle while hauling, and predators want your kill — converts that dead time into **the most
tense part of the loop**. Nothing else in this design gets that much return for the work.

It also creates a genuine decision rather than an obvious one:

| Choice | Value | Risk | Speed |
| --- | --- | --- | --- |
| Field dress, carry the pelt | lower | armed, can fight back | fast |
| Drag the whole carcass | higher | defenceless | slow |

That is a real trade the player re-makes on every kill, and it changes with distance from
camp, remaining ammunition, time of day and what they heard in the trees. A choice that
resolves differently depending on context is the engine of replayability. A choice with one
correct answer is a menu.

**The tycoon feeling the owner describes** comes from upgrades that remove a *felt* pain
rather than adding an abstract number. The player who has been jumped twice while dragging a
buck will feel the handcart as relief, not as a stat. So transport upgrades (HUNT-25) must be
introduced **after** the pain of HUNT-23 is real. Shipping the cart first would remove a
problem the player never had.

Keep the arcade tone. Threat should read as comic peril and lost profit, not grimness.

## HUNT-21 — Camera occlusion while hauling (fix first)

Evidence: owner screenshots show the carried deer filling the frame, and in two shots the
camera is fully inside the carcass with no view of the terrain at all. Hauling is currently
close to unplayable.

Likely fixes, cheapest first: hold the carcass lower and further behind the camera; keep it
out of the near-camera cone entirely; use a wider drag offset behind the player rather than
in front; and clamp its rendered position so it can never enter the camera's near plane. A
drag should read from the *player's* silhouette, not by pasting the animal on the lens.
Verify with captures at several camera pitches, including looking straight down.

## HUNT-22 — Field dressing

Add a field-dress action at a downed animal: a short timed interaction producing a **pelt**
(and later meat/trophy parts) that the player carries without giving up the rifle.

- Pelt sells for meaningfully less than the whole animal, so the trade is real.
- Clean single-shot kills should yield a better pelt, reinforcing the existing accuracy
  reward rather than adding a parallel system.
- The whole-carcass route stays available and stays worth more.
- The Crownback should be worth hauling whole, making it a deliberate set-piece risk.

## HUNT-23 — Hauling as a vulnerable state

- While hauling a whole carcass: rifle stowed, movement slowed, sprint limited.
- Dropping the carcass (Q, already implemented) is the panic button — free your hands, fight,
  then recover the kill. That is a good existing verb to build on.
- Introduce a predator that contests kills. It should prefer **stealing the carcass** to
  killing the player; losing your prize is a better arcade beat than a death screen, and it
  motivates the upgrade ladder without being punishing.
- Blood, distance from camp and time carrying should all raise the chance of a contest, so
  the player learns to plan routes rather than being ambushed arbitrarily.
- Multiplayer opportunity: one player hauls while another escorts. That is a genuine co-op
  role and it costs almost nothing to enable once the rifle lock exists.

## HUNT-24 — Carry and drag presentation

Owner note: there is no animation of grabbing or holding the animal. Currently it is simply
positioned behind the player.

- Two-handed grip with visible hand contact on the animal.
- Forward lean and shortened stride that scale with the animal's weight, so a Crownback
  visibly costs more than a small doe.
- Terrain-dependent drag: the carcass should catch and lurch, not glide.
- Audio sells weight more cheaply than animation does. Drag scrape, breathing, effort.

## HUNT-25 — Transport ladder

Introduce only when hauling pain is real, one rung at a time, each removing a felt constraint:

1. **Travois** - drag two animals, still defenceless.
2. **Handcart** - faster, but restricted on rough terrain, forcing route choices.
3. **Pack animal with sacks** - hands free, so the rifle comes back; the animal itself can be
   targeted by predators, which keeps tension rather than deleting it.
4. **Wagon** - bulk hauling, opens multi-kill expeditions and longer trips from camp.

Each rung should also unlock a *bigger task* worth doing, matching the owner's point that the
appeal is bigger tasks alongside bigger gear.

## HUNT-26 — World label and HUD collision

Evidence: "CROWNBACK RIDGE / Beyond the watchtower" overlaps the top-right health and wind
panel in owner screenshots. The living backlog already flags oversized world labels.

Reserve margins around HUD panels that world-space labels may not enter; scale labels down
with distance and fade them near screen edges. Verify at 720p and 1080p, since the overlap
worsens at lower resolution.
