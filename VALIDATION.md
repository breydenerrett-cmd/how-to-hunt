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
