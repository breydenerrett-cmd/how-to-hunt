# Current hunting build — 0.1.2-hunt, 2026-09-08

Continue `codex/hunting-art`, production checkpoint **6b6330f**. The broader hunting goal remains active. This is an original art and animation milestone, not a finished quality target. Godot 4.5.2 standard/Compatibility, hunting protocol 1, schema 1, independent saves and authoritative gameplay are preserved. Update the entire hunting party to 0.1.2 together. Fishing and sealed hunting 0.1.0/0.1.1 remain untouched.

**Implemented:** original rounded deer bodies, tapered necks/muzzles, pointed ears, curved branching antlers, jointed legs and cloven hooves. Walk/gallop, alert, tail flagging, breathing/blinking, hit reaction and folded fall poses are presentation-only. Falling now compensates around the torso, keeping the harvest centered above the terrain instead of rolling it underground. Reduced motion retains essential gait while suppressing decorative movement. The controller still owns simplified physical hitboxes; decorative anatomy is not exact shot geometry.

A carved walnut rifle has local wood grain, barrel/trigger/bolt details, purchased scope model and reload mechanism motion. First-person meshes no longer cast floating world shadows; lowered aim pose clears more of the target. The scope upgrade still changes field of view/steadiness: its colored lens is cosmetic, not a through-the-optic magnifying render. This view and third-person weapon visibility remain refinement work.

The lodge and exchange gain framing, braces, lanterns, barrels, crates and counter props, with smaller fixed building signs. Physical shop locations/footprints and interactions are unchanged; the exchange remains a canopy stand. A procedural blue/cloud sky replaces the uniform gray background. Clouds are static, not a weather/day-night system. Plants, terrain, decorative rocks and the overall composition still need refinement.

**Validation: 111 selected Godot assertions and five separate packaging unit tests pass**, including four independent local ENet processes. Exact source windows are recorded in `evidence/release_v0_1_2/checks.json`. The earned route uses normal resources, purchased gear, actual movement/rays and three sales including Crownback: 75.8 seconds, 373 credits, eight rounds, health 100, max step 0.115856m. Exact scripted aim is not human difficulty or enjoyment evidence. No owner saves were edited.

Staged native views cover 720p/1080p with 120% HUD, including shop, close animals, scope, reload, fall and encounter poses. Selected images were inspected. Final batching and lower aim have a further 720p run; exact export captures provide final 1080p menu/solo. Earlier failed black-sky captures and intermediate geometry remain diagnostic evidence. A review720 and baseline benchmark log retain ObjectDB shutdown warnings; do not describe all fixtures as warning-free.

Performance: paired six-second 1080p cap60 camp samples measured prior0.1.1 median17.362/18.273ms versus initial art18.402/18.386ms. Combining rigid creature surfaces while retaining animated joints cuts final draw calls from1862 to1403 (prior build1600); final343-frame sample median17.500,p9518.877,p9919.343ms. It recovers the initial art overhead in this sample, but does not establish sustained60FPS, co-op combat or weaker-machine performance.

**Next:** HUNT-08 extract session/economy orchestration before story/region expansion, then HUNT-06 an original camp character and a meaningful opening story/replay objective. Human playtest findings take priority. Scope presentation, harvest dragging/collision, visible guest weapons, audio, richer species/gear and environmental detail remain open. The full game goal and existing hourly continuation remain active. No purchases, publication, public hosting or security/network changes occurred.

Final production6b6330f exports pass: strict ad-hoc Mac signature and native arm64 menu/solo rendering, with both exact-export images inspected and no ERROR/WARNING in their logs. Windows export passes resource startup through Mac Godot only; no native Windows claim. Four independent local ENet processes all exit0 and pass19 checks, covering guest movement, wildlife/trail history, paid purchase, actual shot/retrieval/single sale and disconnect/rejoin. All43 frozen runtime files remain unchanged. Archive/source verification is appended after sealing.

Sealed v0.1.2 Mac, Windows and source ZIPs pass CRC. Mac has arm64/x86_64, matching0.1.2 bundle versions and the exact nativearm64 runtime evidence above. Windows passes PE x86_64/embedded pack structure, with resources separately loaded outside the project through Mac Godot; native Windows remains untested. Exact source matches all43 frozen runtime files and fresh-imports in Godot4.5.2, exit0. Archives contain documentation/evidence checkpointcb4672d; this sealing receipt is added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_2.zip: `1c112b3c63674b2fd75f94207bd905871bd1c7ae0b05405a020e2f38d3fcbe2b`
- How_To_Hunt_Mac_v0_1_2.zip: `7d0254ac59e79e3860065f0d5005df3c7f297d19e164b2d0ad40c984bc1dba0e`
- How_To_Hunt_Source_v0_1_2.zip: `393c074e1801a101f9e355f481cd38ce49fce8f748e148a11e59088da236b5f8`

---

# Current hunting build — 0.1.1-hunt, 2026-09-08

Continue `codex/wildlife-navigation`, production checkpoint **8d58216** (navigation/encounter checkpoint0053119). The broader arcade hunting goal remains active and unfinished. Godot4.5.2 standard, Compatibility, hunting protocol1, schema1 and independent How to Hunt saves remain. Update all hunting players to0.1.1 together; preserve sealed0.1.0 and every fishing archive/world.

**Implemented:** a shared static wildlife clearance map routes walking/fleeing deer around collidable tree trunks and lodge/exchange footprints. Path smoothing respects clearance; finite routes, periodic replanning and stuck checks remain host-owned. Boundary destinations stay inside emergency recovery limits. Perception considers the party, sight, nearby movement noise and scent from an upwind hunter; an alert pause/head raise precedes flight. This is static navigation, not dynamic herd avoidance or complete collision for decorative rocks. No animal warping was observed in the selected physical detours.

Crownback faces a marked, committed rush direction. It no longer steers back toward a dodging hunter; contact with a wall stops the rush. Braced hide takes45% shot damage; the3.2-second recovery takes full damage. Sidestep, steady and counterattack is an earned winning strategy. Rendering exposed a world-space marker with inherited animal translation; its global transform is now identity, so the orange lane coincides with the attack. New prompts and journal explain alert, wind and recovery. Simplified body/hit geometry and human difficulty remain open.

Guests receive the host's bounded100-track history, preserving position, animal identity, heading and relative age. Subsequent trail events use the same ordered reliable channel as bootstrap; reconnect clears stale local trails. Four-process evidence covers this; no new home-Wi-Fi hunting result is claimed.

**113 selected Godot assertions pass**, plus five packaging metadata tests. Includes31 rules,10 storage,15 navigation,10 physical behavior,11 charge/counterattack,17 earned full route and19 four-process network. The final earned route uses normal40 credits, purchases, real movement/rays, three harvests and the Crownback counterattack;75.534seconds,373 credits,eight rounds,health100,max step0.115856m. Scripted exact aim/routing is not novice play or an enjoyment rating. Source windows are explicit in `evidence/release_v0_1_1/checks.json`; not every earlier suite ran after every presentation change.

Ten staged native poses at720p/1080p and120% HUD, plus corrected lane views and exact exported native arm64 menu/solo, were inspected selectively. A Dummy-audio fixture retains AudioStreamWAV/playback shutdown warnings; the exact exported Mac menu/solo logs have no errors or warnings. Native Windows/Intel, clean installs, human audio/control quality, sustained performance and real two-machine hunting remain unverified.

Foliage grouping increased from16m to28m cells; fern/grass meshes now use distinct groups instead of whichever mesh was first in a cell. Identical instance placements and collisions remain. Draw calls1911→1600 in the camp sample; final six-second1080p capped60 median17.931ms,p9518.899ms,p9919.561ms. The earlier isolated16.654ms result was not reproduced: two paired current-machine baseline medians17.361–18.069ms versus pre-batching new18.577–18.580ms. Sustained60FPS remains open; do not claim a proved navigation performance win from these small samples.

Matching Mac/Windows exports complete; exact Mac ad-hoc signature/nativearm64 menu/solo pass. Windows embedded resources load through Mac Godot, not Windows execution. Versioned0.1.1 archive/source-integrity receipts follow sealing below. README contains controls and exact launch instructions.

**Next:** HUNT-03 original creature/weapon/camp artwork and animation readability, then HUNT-08 session/economy extraction before richer story or region expansion. The current deer silhouette, weapon, signs and buildings remain prototype-like; avoid declaring the visual target reached. Human feedback takes priority when supplied. Other species, crafting/tree regrowth/thirst, broad gear families and Steam features remain future work. Keep the full game goal active; hourly continuation remains in this task. No external/security/network changes, purchases, publication or owner-save edits occurred.

Sealed v0.1.1 Mac, Windows and source archives pass CRC. Mac has arm64/x86_64 and matching 0.1.1 plist versions; Windows passes PE x86_64 and embedded-pack structure. Exact packaged source matches all 33 frozen runtime files and fresh-imports with Godot 4.5.2, exit 0. Native Mac arm64 runtime was checked against the exact export; native Windows/Intel remain untested. Archives contain the preceding b55f6e1 documentation/evidence snapshot; this receipt is added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_1.zip: `0476f8bcba9d7d94495081654eb2a99ac0241ed51579609ebabc3cffdfe9a6bf`
- How_To_Hunt_Mac_v0_1_1.zip: `e273ddcbf1ac662177e480a6c2f6b13dc6aa45211d27a78cbd3e0e329a6a4718`
- How_To_Hunt_Source_v0_1_1.zip: `45223cda022762770e8625072e4f51782d56eb7241b2a2cc3469fbcf61290f21`

---

# How to Hunt — first playable prototype, 2026-09-08

**Active goal:** a distinct, polished arcade hunting game reusing proven support systems from Catch Catastrophe. The owner superseded the earlier fish-first goal. End-of-day and end-of-week quality are aspirations requiring reassessment, not verified delivery guarantees. Keep the goal active; this prototype is not completion of the desired game.

Continue this sibling project this repository, branch `codex/hunting-foundation`, production checkpoint **875c183**. Godot 4.5.2 standard/GDScript, Compatibility, version 0.1.0-hunt, hunting protocol 1, schema 1 with `game=how_to_hunt`. App/bundle/save identity and UDP 27951 are separate from fishing. Never overwrite fishing worlds or its sealed archives. Fishing source 5b526ee and transition 564f750 remain preserved; v0.3.8 is its latest sealed release. The later fish 0.3.9 raw exports were checked but not packaged into a new sealed release after the goal changed.

## Implemented scope

One original Pinefall forest basin with rolling collidable terrain, reused batched evergreen/fern/grass builders, rock ridges, timber walk-in lodge, visible item displays, game exchange and watchtower. Five ordinary deer use new host-owned graze/walk/perception/flee behavior, tracks and continuous body-size/value variation. A larger Crownback warns with an orange terrain-following charge lane, rushes and recovers. There is one two-deer introductory contract and one Crownback contract, followed by continued free hunting.

The loop starts empty-handed with 40 credits: purchase rifle/12 rounds for 25, track, hold aim to steady, shoot through real collision rays, retrieve/drag, sell, buy upgrades and complete the Crownback contract. One clean shot earns 25% value above ordinary base; two shots ordinary value, more shots 85%. Upgrades: sight, dragging harness and faster action; ammunition is a shared pool, with four-round magazines and free recovery when fully out and unable to buy. Shared kit/economy, input, shots, animal identity, money and saves are host-authoritative.

Explicit reuse: avatar movement/animation, admission/rate/sequence guards, bounded chunk assembly, save replacement/backup recovery, procedural primitives/hand/plant builders, sound synthesis and adapted session patterns. Hunting catalogue/validation, scene, animal controller, hunting interactions/progression and UI are new/adapted. `docs/REUSE_MANIFEST.json` records starting file hashes. This is selected source reuse, not a maintained shared library or a measured majority of the finished hunting game. `hunt/game.gd` still combines session and transaction orchestration; extract these before adding a second region/campaign.

## Evidence and release

**83 selected assertions pass:** rules 31, storage 10, physical behavior 10, earned full route 17, four-process network 15. Five packaging-metadata tests pass separately. The shorter 13-check route overlaps and is not added. Exact logs/source windows are in `evidence/release_v0_1_0/checks.json`; fishing tests are not counted as hunting tests.

The earned route uses normal 40 credits, real movement, purchased rifle, naturally simulated animals and actual rays. It hunts/sells two ordinary deer, buys the harness, hunts/sells Crownback, and ends after 74.627 s with 373 credits, eight rounds, health 100 and no teleport-sized steps. The fixture knows exact routes/aiming and is much faster than a novice. The Crownback can be killed before completing a charge by two well-timed steady shots; difficulty and replay value are not established. Rule fixtures prepare some state; the earned route does not grant gear/money or force health/death.

Four independent local ENet processes cover shared wildlife, guest movement, paid purchase plus duplicate sequence, shooting/retrieval/sale and disconnect/rejoin. These are loopback, not the older owner's fishing home-Wi-Fi result. Native staged menu/camp/shop/deer/charge captures cover 720p / 1080p and 120% HUD text; selected final views were inspected. A six-second native 1080p/capped 60 camp sample with five live deer has median 16.654ms, p95 17.284ms, p99 17.568ms, 1893 draw calls. Not sustained co-op or weaker-machine performance.

Versioned targets: `exports/releases/How_To_Hunt_Mac_v0_1_0.zip`, `How_To_Hunt_Windows_v0_1_0.zip`, `How_To_Hunt_Source_v0_1_0.zip`. Exact export/archive receipts are appended when sealed. Mac and Windows exports must match; native Windows/Intel, clean installs and real two-machine hunting remain open. Launch instructions are in README.md.

## Next bounded work

Read `docs/01_LIVING_BACKLOG.md`. First inspect human controls/aim/retrieval and real home-Wi-Fi findings when available. Independently improve animal perception/navigation and encounter balance, directions/tutorial/reward feedback, original animal/weapon/forest presentation and a stronger opening story. The target is a warm, readable arcade woodland game with enough detail to avoid the blocky placeholder feel; the current procedural art is still visibly simple. No finished quality rating or addiction claim.

Known limits: reactive tree avoidance is not robust navigation; decorative rocks and tower platform are not fully collidable/climbable; warning signs/item labels can dominate close views; wildlife hitboxes are simplified. Head hitboxes advance in host physics and replicate pose, while decorative gait stays cosmetic. Dragging is positional, without rope/drag collision, and can cross obstacles. Recent trail history is not bootstrapped to late joiners; footsteps are generic, sound quality is unreviewed, third-person guns are not yet shown. Settings cover motion/HUD scale, not full remapping/gamepad or all dialog text. Pause opens a menu while the world keeps running. Personal inventories, large ammo/weapon families, other species, harvest crafting/tree regrowth/thirst, richer story, multiple biomes and Steam features remain unimplemented.

Hourly continuation was updated in this same task to **How to Hunt development**, retaining automation id `catch-catastrophe-development`. Each bounded run reads this project and avoids overlapping active work/owner playtests. It requires the app/computer running. Do not create another automation. No purchases, publication, public hosting, network/security changes or owner-save edits occurred. Test saves used unique high-number slots and were removed.

Final production875c183 raw exports completed. Exact Mac export8fc8844360224b4f9f4e749d644dd12f36db64103178e6104c982a5861510ac9 passed strict ad-hoc signature and native arm64 menu/solo rendering with clean exit; both final images were inspected. Windows executable713862ac23c46df2ba366aebd41922ebe8b3da0238229c95e1945ebc036cc729 embedded resources load through the Mac engine, not native Windows. The separate sealed1080 eight-pose fixture completed but retains an ObjectDB exit warning; it is not represented as a warning-free run. Packaging receipts follow sealing.

Sealed first hunting release v0.1.0: all three archives pass CRC. Mac contains arm64/x86_64 and matching0.1.0 plist versions; Windows passes x86_64 PE and embedded-pack structure. Exact source ZIP matches all31 frozen production files and fresh-imports with Godot4.5.2, exit0. Native Windows and Intel execution remain untested. Archives contain the preceding49ed89b documentation/evidence snapshot; this receipt is recorded afterward. SHA-256:
- How_To_Hunt_Windows_v0_1_0.zip: `d0fa6e1ddb02dfed1e8befdc65f441578e9bd34b3c47e7d62232202efc7e24d0`
- How_To_Hunt_Mac_v0_1_0.zip: `96167e2286ac351190987cde3ea8d5341d9b7290d5224b821277af767fe747da`
- How_To_Hunt_Source_v0_1_0.zip: `82a09c2bac5831207c243becb58a282c15798c2149c2e428ca6cbf2ff52f0dcf`
