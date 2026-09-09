# Visual polish 0.1.5 — validation window

Productionef3d619 includes the shared theme428669a and benchmark737cedf. Godot4.5.2 standard/Compatibility; protocol2/schema1. Local evidence under `evidence/hunting_materials/` and `evidence/release_v0_1_5/` remains ignored. This is a visual milestone, not complete-game or reference-quality acceptance.

Earlier selected checks passed134 assertions: materials7,art13,rules31,gear16,services12,storage10,earned route17 and four-process network28. These precede the inherited UI theme and are historical until the frozen source is rerun. Route75.969seconds,373credits,eight rounds,health100,max step0.115727m. Materials test shared maps, local mipmapped triplanar mapping, distinct fur/metal response and batch geometry/colors/exclusions. Native720/1080 staged views were inspected; initial overly striped timber/bright lighting were reduced. Baseline/pass fixtures retain ObjectDB shutdown warnings; do not call every capture warning-free. Final UI/export evidence follows.

Matched benchmark results and limitations are detailed at the top of HANDOFF.md. Original capped-only baselines are not compared to the newly added uncapped stage. Two new uncapped medians near7ms do not establish a speedup against a highly variable baseline. Short capped samples near16.65ms do not prove sustained60FPS. Drawcall/video-memory increases are retained, not hidden. Native Windows/Intel, clean installs, current home-Wi-Fi hunting, audio quality, human reward/stealth balance and long sessions remain open.

Final production **046fee9** adds the guidance-layout correction toef3d619. The frozen material/theme source reran all **134 selected assertions**, failures0; five packaging units also pass. The final earned route took75.978seconds with373credits/eight rounds/health100 and max physics step0.115727m. Logs/source windows are in `evidence/release_v0_1_5/checks.json`; these checks precede only the final guidance-placement change. Final720/1080 native staged renders cover that change at120% interface scale: guidance stays outside the HUD panels and shop/journal panels hide the gameplay HUD. Representative corrected camp/purchase images were inspected. Oversized world landmark labels and hauling-camera obstruction remain open.

An additional final frozen-source1080p sample gives uncapped median16.294ms,p9518.388ms; capped median16.652ms,p9517.621ms,359frames;1517draws/about114MB tracked video memory. Uncapped timings vary substantially across sessions, including the baseline. This does not establish a stable rendering cost or a speedup; capped timing alone cannot quantify headroom. Keep the limitations visible and measure representative combat/co-op before a performance claim. Final native exports, archive CRC and source-import receipts follow sealing.

---

# Current stealth gear build — 0.1.4-hunt, 2026-09-08

Branch `codex/hunting-stealth-gear`, production **8d46b61**. Full hunting goal remains active. Godot4.5.2 standard/Compatibility, hunting protocol2 and schema1 are unchanged. Matching0.1.4 versions are required for party play; older packaged releases and fishing saves remain intact.

**HUNT-13/14 implemented:** Softstep boots35 credits reduce movement noise40%; Wool overshirt55 reduces remaining movement noise20% and sight radius15%; Pine scent cover40 permanently reduces scent radius9→4m; Muffled barrel130 reduces shot sound radius30→10m. Purchases are permanent shared party upgrades. These add IDs without removing old IDs or changing schema1. Journal lists owned stalking kit and shop descriptions give the effects. No consumable scent timing, personal clothing inventory or visual clothing swaps are claimed.

Host movement noise and wildlife sight/scent use the owned kit. Shots now add distance-dependent suspicion, with a separate6m local impact disturbance; a suppressed miss can alert quarry beside the actual surface hit. Near animals still hear muffled shots and direct hits retain their alert response. The first-person rifle gains a visible attachment, local shot playback is quieter, and impact sparks are presentation-only. This is an arcade suppression model, not real-world acoustics.

Four original equipment props occupy reachable side shelves. Existing five rear displays remain, labels are lifted clear of new props and disappear beyond6.5m. Static gear surfaces are batched. Native staged720/1080 views cover both shelves, the purchase panel, journal and attached rifle, including120% HUD. Selected views and final batched720 were inspected. Camera-only fixture yaw initially left the interaction prompt aimed elsewhere; fixture input yaw now follows the camera. World/art quality and human interaction/audio appeal remain open.

**140 selected assertions pass:** gear16,rules31,services12,storage10,earned route17,stalking15,charge11,network28. Local ignored log hashes/source windows: `evidence/release_v0_1_4/checks.json`. Gear tests use actual raycasts for unsuppressed/muffled shots and wall-impact misses, actual unique-slot write/reload for new item persistence, exact prices/duplicates and reachable prop checks. The earned route uses normal starting resources and real shots/movement:75.991seconds,373credits,eight rounds,health100,max step0.115727m. Four local processes buy boots with earned harvest credits, replicate them to both other guests and retain them on rejoin. No new home-Wi-Fi result is claimed.

An initial journal local-variable conflict caused parse failure; it was corrected before selected runs. The first network run asserted standing after a fixed20 ticks before the guest had the update; a bounded wait now requires the actual replicated stance/noise and the rerun passes. This is a test timing correction, not a claimed latency fix. Failed logs remain local and are excluded.

A six-second1080p sample measured median13.396ms but p95114.958/p99118.098ms,150frames,1389drawcalls. An owner0.1.3 game process was observed running afterward; this sample cannot establish an isolated performance comparison. It is retained as a poor sample, not discarded or presented as a win. After that observation, further graphical launches were avoided; the owner process was not stopped. Exact0.1.4 Mac verification uses headless native resource startup, not exported graphical gameplay. Native Windows/Intel, isolated performance, clean installs, long sessions and human stealth balance remain open.

**Next:** honor newly registered HUNT-17/18 visual polish requests in `docs/04_VISUAL_POLISH_PLAN.md`: one measured lighting/material pass while preserving Compatibility and gameplay. Verify any renderer-specific claim before applying it. HUNT-15/16 changing wind/herd cues and HUNT-06 original story remain planned. Keep the full goal active. No purchases, publication, public servers, security/network changes or owner-save edits occurred; evidence stays local/ignored. Exact export/archive receipts follow sealing.

Final8d46b61 exports complete. Exact Mac ad-hoc signature and nativearm64 headless menu/solo resource startup pass; graphical exported runtime is pending. Windows PE resources load through Mac Godot in an isolated directory, not native Windows. Five packaging metadata tests pass. Archive/source-integrity receipts follow.

Sealed v0.1.4 Mac/Windows/source ZIPs pass CRC. Mac contains arm64/x86_64 and matching0.1.4 versions; nativearm64 headless menu/solo startup passes, graphical exact-export testing remains pending. Windows x86_64 PE/embedded pack passes structure and isolated Mac-engine resource loading, not Windows execution. Exact source matches all51 frozen runtime files and fresh-imports with pinned Godot4.5.2, exit0; local evidence is excluded. Archives contain documentation checkpointbc4706e; this sealing receipt is added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_4.zip: `8397e69b4d18435383e04dd83c3c1326c5e190b4adc2632c2247cdcb6d059bba`
- How_To_Hunt_Mac_v0_1_4.zip: `6f8f8f458ba4410a72ec3ea73548e3f7e2774baad7ab5a22d0879c3400073f4a`
- How_To_Hunt_Source_v0_1_4.zip: `3a48564a356a3ab88b98970d712b11dbf1012fcabbc1c63ef35ad6d6bc5c0f13`

---

# Current stalking build — 0.1.3-hunt, 2026-09-08

Branch `codex/hunting-stalking`, production **0b42788**, following service checkpoint52897cb. The full hunting game goal remains active. Godot4.5.2 standard/Compatibility and hunting schema1 remain; **hunting protocol2 requires matching0.1.3 builds for every player**. Earlier archives and fishing worlds are preserved.

**Implemented HUNT-11/12:** hold Ctrl or C to crouch. Host movement has1.8m/s crouch,4.5 walk,6.5 run, with crouch overriding sprint. The capsule changes1.7→1.25m; standing uses a full-shape headroom query and remains crouched under a ceiling. Crouched jumping is disabled. Host eye height smoothly changes1.58→1.05m and is also the shot origin; snapshots carry stance, eye height, noise and surface. Third-person legs bend with knees and shortened/bunched coat presentation. This remains a stylized pose, not a finished human rig.

Movement noise depends continuously on actual speed and stance, with quieter trail/camp surfaces and louder leaf litter. Stopping yields zero movement noise; quieter, slower local footstep playback reflects it. Hearing radius and suspicion gain use this host-computed value. Crouch reduces sight radius and lowers the sight ray, but close sight and upwind scent still detect stationary hunters. Existing physical cover can block rays; decorative foliage/rocks have no new concealment or collision system. The HUD labels stance, NOISE percentage/bar and surface, including larger text. Quiet is not invisibility or a universal detection meter.

**148 selected assertions pass**, plus a separate actual prior0.1.2-client/new-host mismatch test and five package metadata units. Local ignored evidence: `evidence/release_v0_1_3/checks.json`, with source windows. Stalking15 covers actual movement under a low ceiling, blocked standing/jump, recovery outside cover, three speeds/noise levels, surface/stop behavior, sight/scent, real crouched ray hit and stale-input rejection. Joint pose2 preserves authoritative state and feet near ground. Network25 uses four independent local processes and checks guest crouch/noise/eye height and stand/stop alongside paid purchases, shot/retrieval/sale and rejoin. Not a new real-machine result.

The earned full route passes17 with normal gear/resources, real movement and shots:75.709seconds,373credits,eight rounds,health100,max step0.115727m. Rules31/services12/storage10/behavior10/charge11/navigation15 also pass. An older behavior fixture treated stationary sprint input as loud; it now actually runs. Quiet scent evaluation allows more time for the lower suspicion rate. Failed intermediate logs remain local and are excluded. Human difficulty, stalking satisfaction and reward balance remain open.

Native staged views cover720p/1080p at120% HUD. Final720 noise text and standing/crouched third-person views were inspected; the initial shortened-leg pose looked sunk, so joints, boot height and coat clearance were corrected. Final cosmetic pose can still be refined. Six-second1080p camp sample before final jointed legs:341frames,median17.591ms,p9519.058,p9919.684,1408drawcalls. Not sustained60FPS or co-op combat performance. Exact export/platform and archive receipts follow sealing. Native Windows/Intel, clean installs, new home-Wi-Fi hunting, audio quality and long-session play remain unverified.

**Next:** HUNT-13/14 early quiet gear, scent cover and a muffled barrel with shot-distance falloff and local impact consequences; then changing wind/freeze-to-calm/herd cues. HUNT-06 original character/story remains planned. Keep the arcade tone, original artwork and explicit shared party economy. No purchases, publication, public hosting, security/network changes or owner-save edits occurred. Local evidence stays ignored; no new evidence was committed.

Final0b42788 Mac export passes strict ad-hoc signature and native arm64 menu/solo rendering; both final captures were inspected and logs have no ERROR/WARNING. Five packaging metadata tests pass. Source packaging now excludes ignored local evidence, tools and exports, consistent with repository policy; verification receipts remain local. Archive integrity is appended after sealing.

Sealed v0.1.3: all three ZIPs pass CRC. Mac bundle includes arm64/x86_64 and matching0.1.3 versions; exact native arm64 launch is verified. Windows x86_64 PE/embedded-pack structure passes, and its resources load in an isolated directory through Mac Godot; native Windows remains untested. Exact source matches all49 frozen runtime files and fresh-imports with Godot4.5.2, exit0. The source archive omits local evidence and includes documentation checkpoint106625e; this receipt was added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_3.zip: `f9e235bbfa98c04b1dfb627063c53afa27a6885b67194618c046efa7ce641b1e`
- How_To_Hunt_Mac_v0_1_3.zip: `32ed4f87f2d515a158f8dd8dad5837c7e6a10cc54490f3df2a03457b65df77fd`
- How_To_Hunt_Source_v0_1_3.zip: `4a7e5050e55cea48e72c253bf89992996336a116332bb1f2121ae5002e1c7ea7`

---

# Development checkpoint — session and economy extraction, 2026-09-08

Current branch `codex/hunting-services`, source **0.1.3-dev**. Latest packaged playtest remains0.1.2; its archives are unchanged. This is source progress, not a new exported release or completed game. Protocol1 and schema1 remain unchanged; the development version rejects mixed release clients.

HUNT-08 first extraction is implemented: `hunt/session.gd` handles hosting/joining, departure, teardown and save orchestration through an explicit scene context, without retaining a scene reference. Stable RPC endpoints and snapshots remain in `hunt/game.gd`, which still owns runtime actors/input/rendering. `hunt/economy.gd` owns catalogue-price purchase, bank/contract rewards and bankrupt ammunition recovery; it has no scene, network or storage dependencies. Host scene adapters consume unique harvests before feedback and spawning. This is a first module boundary, not a finished shared engine/library.

Direct buy/sell adapters now require an active authoritative host, the registered living actor and local shop/exchange proximity. Foreign-held or repeated harvests cannot bank. Existing action sequence/payload gates and save behavior remain. No save schema migration or fishing changes.

**89 selected assertions pass:** service12, rules31, storage10, earned route17 and four-process network19. Local ignored logs and hashes: `evidence/hunting_services/checks.json`. All include the extraction/guards; the source label was bumped afterward without gameplay changes. The earned route uses normal resources and real movement/rays:75.896seconds,373credits,eight rounds,health100,max step0.115856m. Local network covers host+three guests and reconnect, not new real-machine acceptance. No rendered-art or performance change is claimed; this source checkpoint is not exported.

Additional service tests cover blocked guest/downed purchases, exchange distance, foreign holder, duplicate sale, independent party ledgers, full teardown and a fresh hunt in the same process. Save/backup and route tests retain their prior scope. Broad quality and human play remain open.

The worktree contains newly registered owner stealth feedback in `docs/02_STEALTH_AND_REALISM_PLAN.md`. Preserve it. **Next priority: HUNT-11/12 crouch and a visible host-owned noise meter**, with the required input protocol bump, capsule/ceiling clearance, camera and guest replication checks. Follow with quiet gear/shot falloff before richer story. HUNT-06 remains on the backlog. Keep the full game goal active and preserve owner policy that local evidence stays ignored; no public actions or security/network changes were taken this session.

---

# Current validation — hunting 0.1.2

Production **6b6330f**, frozen runtime manifest in `evidence/release_v0_1_2/source_files.json`. This release changes original presentation and model geometry; authoritative movement, shots, damage, rewards, schema and network protocol remain unchanged.

**111 selected Godot assertions pass:** rules31, storage10, behavior10, charge11, earned route17, art13 and network19. Five packaging units pass separately. Navigation15 from0.1.1 is historical and not added. Source windows and selected log hashes are recorded in `evidence/release_v0_1_2/checks.json`.

Art13 verifies five animals across poses without changing saved/controller/hitbox transforms, above-ground fall center, reduced-motion essential gait, finite geometry, purchased scope/bolt poses, unchanged equipment/ammo/rewards, no first-person-only world shadows and retained camp vertex colors. It does not establish realistic anatomy or human animation quality. Earned route passes17: 75.8seconds,373credits,eight rounds,health100,max physics step0.115856m; normal40-credit start and purchased gear, real rays and movement, ordinary plus Crownback sales. Prepared tests and exact scripted aiming remain separate from human play.

Found and corrected during native rendering: projected cross-section frames prevent twisted bent meshes; static batches preserve vertex colors instead of whitening barrels; direct sky shading avoids the black radiance-dependent initial shader; torso-centered falling keeps harvests above terrain; rigid head/antler/hoof batching reduces rendering overhead without merging animated joints. Lower aim leaves more target space. Colored scope lenses are still cosmetic and are not a true magnifying optic.

Staged review720/review1080 cover13 menu/shop/animal/weapon/encounter poses at120% HUD. Final batched720 rechecks13 poses after static batching and lowered aim. Representative scope, fall, profile and camp images were inspected; all captures are fixtures, not a fully mouse-played campaign. Earlier black-sky images are retained as failures. Review720 and baseline benchmark logs retain an ObjectDB shutdown warning; exact export logs are evaluated separately.

Paired short native1080p cap60 baseline168423c samples: median17.362/18.273ms,p9519.110/19.311,1600drawcalls. Initial art: median18.402/18.386,p9519.619/19.562,1862drawcalls. Final rigid-part batching:343frames,median17.500,p9518.877,p9919.343ms,1403drawcalls. One idle avatar/five live deer, six seconds, excludes first-person gun view. No sustained60FPS, four-player combat or weak-hardware conclusion.

Native Mac/export, Windows structure/resources and archive verification receipts follow below. Windows/Intel native execution, new real-machine hunting co-op, clean-install launch, long soak, human controls/audio/replay value and final visual quality remain unverified. Existing fishing Wi-Fi success does not validate this hunting executable. Independent hunting saves and every sealed earlier archive remain preserved.

Final production6b6330f exports pass: strict ad-hoc Mac signature and native arm64 menu/solo rendering, with both exact-export images inspected and no ERROR/WARNING in their logs. Windows export passes resource startup through Mac Godot only; no native Windows claim. Four independent local ENet processes all exit0 and pass19 checks, covering guest movement, wildlife/trail history, paid purchase, actual shot/retrieval/single sale and disconnect/rejoin. All43 frozen runtime files remain unchanged. Archive/source verification is appended after sealing.

Sealed v0.1.2 Mac, Windows and source ZIPs pass CRC. Mac has arm64/x86_64, matching0.1.2 bundle versions and the exact nativearm64 runtime evidence above. Windows passes PE x86_64/embedded pack structure, with resources separately loaded outside the project through Mac Godot; native Windows remains untested. Exact source matches all43 frozen runtime files and fresh-imports in Godot4.5.2, exit0. Archives contain documentation/evidence checkpointcb4672d; this sealing receipt is added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_2.zip: `1c112b3c63674b2fd75f94207bd905871bd1c7ae0b05405a020e2f38d3fcbe2b`
- How_To_Hunt_Mac_v0_1_2.zip: `7d0254ac59e79e3860065f0d5005df3c7f297d19e164b2d0ad40c984bc1dba0e`
- How_To_Hunt_Source_v0_1_2.zip: `393c074e1801a101f9e355f481cd38ce49fce8f748e148a11e59088da236b5f8`

---

# Current validation — hunting0.1.1

Production8d58216,33 frozen runtime files. **113 selected Godot assertions + five separate packaging tests**. Selection/hashes/source windows: `evidence/release_v0_1_1/checks.json`. No fishing or previous release counts added.

- Navigation15: actual lodge/tree detours through character physics, conservative route clearance, safe boundary destinations, scent/alert/flight, and track identity/age restoration. Lodge detour26.917s and tree11.575s in the initial successful physical run; max steps below0.029m. Final navigation rerun passes15 after adding boundary coverage. Prepared starts/destinations are fixtures, not natural player hunts.
- Charge11: warning before movement, marker world transform/facing,45% braced damage, fixed lane, real strafing without damage, rush distance, full recovery damage/window, defeating the animal, and actual lodge collision ending a rush. Final production run passes.
- Earned route17: final production75.534s, normal resources, three actual harvested/sold animals, harness and completed Crownback contract;373 credits,eight rounds,health100. Fixture now strafes during windup/rush and shoots while exposed. This does not prove human balance, replay value or fun.
- Rules31/storage10/behavior10/network19 cover existing authority/transaction/recovery and new navigation/trail bootstrap. Four independent local processes, including an exact pre-join marker and post-sale reconnect history; all exit0. Network ran before later counterattack/marker changes; field structure and ordinary shooting/sales remained unchanged. Other source windows are in checks.json.

Final staged native poses cover720p/1080p at120% HUD; selected alert, charge/recovery, exported menu and solo views inspected. Initial charge screenshot showed the marker translated away from the animal. Resetting the world-space mesh transform and facing the rush fixes it; final720_crownback and lane1080_crownback show the lane underneath and toward the hunter. The separate Dummy-audio fixture retains two audio playback resources at shutdown, identified by verbose log; exported native menu/solo logs are warning-free. No claim of a fully manually played campaign.

Performance: initial new camp median18.838ms prompted two alternating baseline/current samples. Baseline875c183 median18.069/17.361ms,p9519.763/19.321; new pre-batching18.580/18.577,p9519.819/19.663. After grouping foliage and separating fern/grass meshes,333frames median17.931,p9518.899,p9919.561ms,1600drawcalls versus1911. All are six-second1080p cap60 with one idle hunter/five live deer, not sustained combat/co-op. Current measurements do not establish the60FPS target.

Mac Universal2 and Windows exports complete. Exact Mac nativearm64 menu/solo and strict ad-hoc signing pass; final images inspected. Windows PE resources load through Mac engine only. CRC,33-file source match and fresh engine import are appended after sealing. Native Windows/Intel, clean install, human audio/controls/difficulty and two-machine hunting remain open. Earlier0.1.0 evidence is historical below.

Sealed v0.1.1 Mac, Windows and source archives pass CRC. Mac has arm64/x86_64 and matching 0.1.1 plist versions; Windows passes PE x86_64 and embedded-pack structure. Exact packaged source matches all 33 frozen runtime files and fresh-imports with Godot 4.5.2, exit 0. Native Mac arm64 runtime was checked against the exact export; native Windows/Intel remain untested. Archives contain the preceding b55f6e1 documentation/evidence snapshot; this receipt is added afterward. SHA-256:

- How_To_Hunt_Windows_v0_1_1.zip: `0476f8bcba9d7d94495081654eb2a99ac0241ed51579609ebabc3cffdfe9a6bf`
- How_To_Hunt_Mac_v0_1_1.zip: `e273ddcbf1ac662177e480a6c2f6b13dc6aa45211d27a78cbd3e0e329a6a4718`
- How_To_Hunt_Source_v0_1_1.zip: `45223cda022762770e8625072e4f51782d56eb7241b2a2cc3469fbcf61290f21`

---

# How to Hunt 0.1.0-hunt — validation

This validates the first hunting prototype, not the completed quality goal. Godot 4.5.2 standard/Compatibility on Apple M5 arm64. Source production checkpoint 875c183; exact 31-file hashes are in `evidence/release_v0_1_0/source_files.json`.

## Selected checks

- `rules_support.log`:31. Paid start, finite save fields, independent identity, purchase distance/duplicate guards, real ray hit, clean harvest bonus/cooldown, retrieve/drop/sell, contract transitions, snapshot roundtrip, ammo recovery, reload, input clamp and cosmetic-state preservation. Prepared fixtures do not prove a whole human campaign.
- `storage_retry.log`:10. Actual unique-slot writes, exact JSON-normalized readback, equipment/ammo persistence, two backups, corrupt-primary recovery/repair and rejected invalid save. Test slot files are cleaned up; owner saves untouched.
- `hunt_behavior_final.log`:10. All five ordinary animals stand on actual terrain, close loud approach triggers flight, wildlife moves, Crownback windup/charge/single damage hit, subdued telegraph clearing and unchanged saved identity.
- `earned_crownback.log`:17. Actual movement from camp, normal 40 credits, purchased rifle, three hunted/retrieved/sold animals including Crownback, earned harness upgrade, both contracts, no teleport step, solvency and survival.74.627s,373 credits,eight rounds,health 100,max per-step displacement0.11582m. The overlapping shorter 13-check route is excluded from 83.
- `network_retry2_{host,guest0,guest1,guest2}.log`:15. Four independent ENet processes, host-owned wildlife, guest movement, shared paid purchase with duplicate sequence, real guest shooting/pickup/sale, disconnect/rejoin and retained host equipment/progress. `network_retry2.json` records four exit0/pass receipts. Loopback only.
- `package_units.log`:five Python metadata fixtures; separate from 83 Godot assertions.

The selected rule/behavior/network tests ran before final presentation-only input-capture guards, cache cleanup, direction/wind text, or equivalent diagnostic changes where applicable. Full earned Crownback route includes the support/hitbox fix and state-based host head pose. Export/import/native evidence covers the final production freeze. These windows are explicit in checks.json; no false claim that old fishing or every earlier test ran against this exact hunting archive.

## Found and corrected

Initial earned-route fixture incorrectly tried to walk through the solid side of the lodge. Its path planner now marks actual shop/exchange footprints; production collision was correct. Initial storage fixture compared typed integers directly with JSON-loaded numbers; it now compares exact JSON-normalized snapshots. Initial rejoin fixture closed the host after guests left before the reconnect handshake; it now waits for an actual accepted fourth guest session. Earlier failed logs are retained and excluded from the selected total.

Native renders exposed overbright lighting, enlarged-HUD clipping and deer feet sinking: lighting/UI dimensions were corrected; wildlife now has a ground-support capsule and separate torso/head shot areas. The head hitbox pose advances in host physics, while decorative animation cannot change saved identity. A720p staged camera was affected by synthetic mouse capture; bot/capture sessions now ignore live unhandled input and verified720 images are clean. Static plant resources produced shutdown leak warnings in early captures; cache cleanup removes that warning in the later native benchmark. Explicit audio shutdown is also applied for exported app exits; final logs record the result.

## Render and performance scope

Eight staged native poses each at 720p / 1080p with 120% HUD scale: menu, camp, lodge, purchase, graze, flee, down, Crownback. Representative inspected final images include verified720_camp, verified720_purchase, verified1080_deer_graze, and exact exported menu/solo when recorded. This is not a manual mouse/keyboard campaign. Some staged poses reposition actors and set states; physical behavior and earned-route evidence are separate.

Six-second native 1080p cap 60 sample, one idle hunter and five simulated deer:360 samples, median 16.654ms,p95 17.284ms,p99 17.568ms, 1893 draw calls. It does not establish sustained smooth60 FPS, co-op combat performance or weaker-machine behavior.

## Release/platform limits

Mac Universal 2 and Windows x86_64 exports are targeted. Exact Mac ad-hoc signature, native arm64 menu/solo, archive CRC/platform structure, source 31-file match and fresh pinned-engine import are recorded in release receipts. Windows embedded resources may be checked through the Mac engine; that is not Windows native execution. No new Windows/Intel/native two-machine hunting acceptance, clean-download Gatekeeper/SmartScreen, audio, long soak or human fun/difficulty validation is claimed.

The goal remains active. End-of-day/week targets, richer original art/story, animal behavior, interaction quality and replay value require more work and playtesting. Existing fishing Wi-Fi success is historical for another executable.

Final production875c183 raw exports completed. Exact Mac export8fc8844360224b4f9f4e749d644dd12f36db64103178e6104c982a5861510ac9 passed strict ad-hoc signature and native arm64 menu/solo rendering with clean exit; both final images were inspected. Windows executable713862ac23c46df2ba366aebd41922ebe8b3da0238229c95e1945ebc036cc729 embedded resources load through the Mac engine, not native Windows. The separate sealed1080 eight-pose fixture completed but retains an ObjectDB exit warning; it is not represented as a warning-free run. Packaging receipts follow sealing.

Sealed first hunting release v0.1.0: all three archives pass CRC. Mac contains arm64/x86_64 and matching0.1.0 plist versions; Windows passes x86_64 PE and embedded-pack structure. Exact source ZIP matches all31 frozen production files and fresh-imports with Godot4.5.2, exit0. Native Windows and Intel execution remain untested. Archives contain the preceding49ed89b documentation/evidence snapshot; this receipt is recorded afterward. SHA-256:
- How_To_Hunt_Windows_v0_1_0.zip: `d0fa6e1ddb02dfed1e8befdc65f441578e9bd34b3c47e7d62232202efc7e24d0`
- How_To_Hunt_Mac_v0_1_0.zip: `96167e2286ac351190987cde3ea8d5341d9b7290d5224b821277af767fe747da`
- How_To_Hunt_Source_v0_1_0.zip: `82a09c2bac5831207c243becb58a282c15798c2149c2e428ca6cbf2ff52f0dcf`
