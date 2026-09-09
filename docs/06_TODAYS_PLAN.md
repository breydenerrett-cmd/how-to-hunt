# Plan — 2026-09-09, single owner

Ownership consolidated: presentation, systems, narrative, content, platform and distribution
are all one lane now. Ordered by what the owner is actually blocked on.

## Phase 1 — Play it on your phone, today

The owner is away from the machine and cannot try anything. Everything else is worth less
until that is fixed, because untested work is unverified work.

**Route: a web build hosted on GitHub Pages.** No app store, no signing, no install — a link
that works on any phone, and it doubles as the fix for friends who will not download an
unsigned Mac app past a Gatekeeper warning.

1. **Single-threaded export.** `web_nothreads_release` is already inside the template pack
   that was downloaded for this project, so nothing needs fetching. It matters for two
   reasons: threaded Godot web builds need `SharedArrayBuffer`, which needs COOP/COEP headers
   that GitHub Pages will not send, and threaded builds are exactly where iOS Safari is least
   reliable. Single-threaded costs frame time we can afford — desktop sits near 8 ms.
2. **Touch controls.** Nothing exists today. A left-thumb virtual stick to move, right-half
   drag to look, and on-screen buttons for fire, aim, interact, retrieve, crouch and reload.
   Yesterday's **aim TOGGLE** is the enabling piece: a finger cannot hold a button and drag to
   look at the same time, so hold-to-aim is impossible on a touchscreen. Toggle already solves
   it, and touch will select it automatically while leaving the setting user-switchable.
3. **Host on `gh-pages`** in the existing public repo. The snapshot publisher only writes
   `main`, so the two never collide.
4. **Verify on a real mobile viewport**, not a desktop window scaled down.

Known limits to state honestly rather than discover later: web forces the Compatibility
renderer, so ambient occlusion and glow are absent — the phone build looks plainer than the
desktop one. Multiplayer over ENet/UDP does not work in a browser, so the web build is
single-player only. It is for trying the game, not for co-op.

## Phase 2 — Make the loop tense

The single highest-value gameplay change available, already designed as HUNT-21 to HUNT-23,
and the owner's own idea. The walk home is currently dead time: you have already won and you
are just travelling. Making the haul dangerous converts the dullest stretch into the tensest.

- **Field dressing.** A timed action at a downed animal yields a pelt worth less than the
  whole carcass but leaves you armed and quick. The whole-animal haul stays worth more.
- **Rifle stowed while hauling** a whole carcass, with `Q` to drop as the panic release.
- **A predator that contests the kill** rather than killing the player — losing the prize is
  the better arcade beat and it motivates the transport ladder without punishing.

## Phase 3 — A front door

Addresses the owner's most repeated complaint: no intro, no context, no reason to care.

- **Cold open** built from the existing camera, geometry and synthesised audio: a trail dolly,
  a deer that crosses and looks at the lens, the lit lodge, then one glimpse of an oversized
  antler silhouette on the ridge. Skippable, and `JOIN` must stay live throughout.
- **Backstory in props, not text walls.** A camp noticeboard: you are a seasonal contract
  ranger hired after the Fallow Mill closed, paid per harvest to thin an overgrown herd.
- **A practice hollow** teaching the four verbs by doing — noise, wind, tracks, a steady shot.

## Phase 4 — Cleanup

Remaining audit findings, chiefly unvalidated network packet decoding in `apply_state` and
peers that are refused but never disconnected. Controller prompts still name keyboard keys and
menus are not stick-navigable.

## Verification

Every phase ends with evidence, not assertion: captures at a real mobile viewport for Phase 1,
the full suite plus four networked processes before any release, and matched before/after
captures for anything visual. Nothing ships claiming a quality nobody has observed.
