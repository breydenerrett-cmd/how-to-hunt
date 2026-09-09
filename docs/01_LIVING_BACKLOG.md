# Hunting goal and ordered work

Owner changed the goal on 2026-09-08 to a distinct arcade hunting game reusing the fishing foundation. The current first forest prototype is a starting point. Preserve the separate fishing project and all prior user ideas; do not restart either game or silently treat the prototype as a finished1:1 reference match.

| ID | Outcome | Current state | Next evidence/action |
| --- | --- | --- | --- |
| HUNT-01 | A compelling camp → track → hunt → retrieve → reward loop | Implemented prototype; 83 selected checks, earned 3-harvest route. | Human novice/relaxed/active timing, discoverability, aiming and reward feedback. Avoid confusing state readouts or enormous world labels. |
| HUNT-02 | Wildlife feels alive, challenging and fair | Graze/walk/perception/flee; one charging Crownback. | Better path recovery/obstacle avoidance, idle/alert/hit/death transitions, detection tells and balance. Two clean shots can kill Crownback before its charge; reassess threat/reward. |
| HUNT-03 | Detailed stylized woodland and creatures, between blocks and realism | Original procedural terrain/lodge/animals plus reused plant/primitives. | Improve one cohesive forest/animal/weapon art pass from actual renders. Current shapes remain simple; don't declare target met. Add terrain-aligned detail and more natural landmark composition. |
| HUNT-04 | Strong multiplayer reuse and responsiveness | Four local processes pass purchase/shot/retrieve/sale/rejoin. | Native Mac/Windows same-Wi-Fi hunting, camera/input feel,30-minute soak. Bootstrap recent trails, show other hunters' weapons, improve session feedback. No public hosting/security changes. |
| HUNT-05 | Useful gear, ammo choices and physical shopping | Rifle, field rounds, sight, harness, faster action; physical lodge displays. | Better physical selection/purchase feedback, pricing/progression, ammo UI clarity. Choose bounded additional weapon/ammo family after this loop is fun. Shared kit remains explicit. |
| HUNT-06 | Distinct story and rewarding discovery | Pinefall introductory two-deer and Crownback contracts. | Original camp character, mystery/tracks/environmental storytelling and one meaningful next objective. Do not expand regions before service extraction and navigation quality. |
| HUNT-07 | Persistent recoverable progress | Independent namespace/schema/identity; backup recovery passes. | Transaction durability/failure feedback, animal state restoration and human resume. No fishing-save writes. |
| HUNT-08 | Architecture reusable without two drifting monoliths | Selected foundation copies tracked by original hashes. | Extract session/transaction interfaces from hunt/game.gd; version shared modules once real common behavior is proven. Do not claim a finished-game reuse percentage. |
| HUNT-09 | More wildlife and survival/crafting | Deferred beyond first loop. | Deer first, then elk/birds with actual new behavior/rigs. Resource gathering, recipes, daily tree regrowth and thirst need separate authoritative systems and recovery rules. |
| HUNT-10 | End-of-day playable milestone; end-of-week quality aspiration | First versioned hunting prototype being delivered. | Human quality, native platform and clean-install gates; update estimates from evidence. Steam release/publication, marketing and paid services remain unapproved. |
| HUNT-11 | Deliberate stalking via a crouch stance | Absent; avatar has only sprint/walk. | Owner-requested. See docs/02_STEALTH_AND_REALISM_PLAN.md. Needs PROTOCOL bump. |
| HUNT-12 | Flee rate scales continuously with how quietly you move | Binary alert gain 0.9 sprint / 0.45 otherwise. | Replace with 0..1 noise value plus a HUD stealth meter so it is learnable. |
| HUNT-13 | Gear that makes you quieter and harder to smell | No stealth items in ITEMS. | Add boots, overshirt, scent cover. Adding item ids is save-safe; never remove one. |
| HUNT-14 | Shots spook nearby animals unless suppressed | Fixed 30 m hard snap to alert=1. | Add silencer item, gear-dependent radius and distance falloff. |
| HUNT-15 | Wind is a live variable, not a memorised constant | Hardcoded direction; HUD string says south-east. | Host-owned rotating wind, replicated, shown in world and HUD. |
| HUNT-16 | Supporting realism that rewards patience | Partly present via head tells and tracks. | Freeze-to-calm, herd awareness, wounded trails, stamina, light-dependent sight. |

Latest0.1.1: HUNT-02 static routes/scent/alert/committed rush and counterattack are implemented;113 selected checks. HUNT-04 bounded trail bootstrap/rejoin is implemented. Human balance and dynamic navigation remain open.

Latest0.1.2: HUNT-03 adds rounded original creatures and articulated poses, detailed rifle/reload, camp props and a cloud sky. This is one art pass, not the finished visual target. The cosmetic scope, forest composition, rocks and third-person weapons remain open.

Next bounded session: inspect owner feedback if present; otherwise HUNT-08 session/economy extraction with targeted authority/save/network regressions, then HUNT-06 one original camp character and meaningful opening/replay objective. Preserve actual footsteps, collision, hitbox and reward tests. Keep the original arcade tone; avoid heavy survival chores until hunting is enjoyable.

Hourly continuation uses the existing task automation. Keep meaningful milestone/failure/input notifications only, and avoid overlapping implementation or owner gameplay. The broader hunting goal remains active.
