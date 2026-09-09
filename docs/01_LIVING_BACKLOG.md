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
| HUNT-08 | Architecture reusable without two drifting monoliths | Selected foundation copies; first session/economy extraction implemented in0.1.3-dev. | Session lifecycle and scene-independent economy are separate; RPC/actor orchestration remains in game.gd. Version shared modules once real common behavior is proven. Do not claim a finished-game reuse percentage. |
| HUNT-09 | More wildlife and survival/crafting | Deferred beyond first loop. | Deer first, then elk/birds with actual new behavior/rigs. Resource gathering, recipes, daily tree regrowth and thirst need separate authoritative systems and recovery rules. |
| HUNT-10 | End-of-day playable milestone; end-of-week quality aspiration | First versioned hunting prototype being delivered. | Human quality, native platform and clean-install gates; update estimates from evidence. Steam release/publication, marketing and paid services remain unapproved. |
| HUNT-11 | Deliberate stalking via a crouch stance | Implemented0.1.3: Ctrl/C stance, headroom, lower camera/rays and replication. | Protocol2; physical/guest tests pass. Human cover/feel playtest remains. |
| HUNT-12 | Flee rate scales continuously with how quietly you move | Implemented0.1.3: actual speed/stance/surface noise and HUD meter. | Tune suspicion and readability from human stalking play. |
| HUNT-13 | Gear that makes you quieter and harder to smell | No stealth items in ITEMS. | Add boots, overshirt, scent cover. Adding item ids is save-safe; never remove one. |
| HUNT-14 | Shots spook nearby animals unless suppressed | Fixed 30 m hard snap to alert=1. | Add silencer item, gear-dependent radius and distance falloff. |
| HUNT-15 | Wind is a live variable, not a memorised constant | Hardcoded direction; HUD string says south-east. | Host-owned rotating wind, replicated, shown in world and HUD. |
| HUNT-16 | Supporting realism that rewards patience | Partly present via head tells and tracks. | Freeze-to-calm, herd awareness, wounded trails, stamina, light-dependent sight. |
| HUNT-17 | Image reads as graded and lit, not raw | Linear tonemap, no glow, no grade, sky contributes no ambient. | Environment pass. See docs/04_VISUAL_POLISH_PLAN.md. Compare 1080p before/after. |
| HUNT-18 | Surfaces read as different materials | Every object shares a flat colour and roughness 0.82. | Surface families with shared procedural noise normal/roughness maps. |
| HUNT-19 | Repeated props stop reading as clones | Uniform scale, rotation and colour on placed props. | Deterministic per-instance hue/scale/yaw jitter, seeded so host and guests agree. |
| HUNT-20 | Objects sit in the world instead of on it | Compatibility has no SSAO; no contact shading anywhere. | Explicit darkened contact geometry at object bases. |

Latest0.1.1: HUNT-02 static routes/scent/alert/committed rush and counterattack are implemented;113 selected checks. HUNT-04 bounded trail bootstrap/rejoin is implemented. Human balance and dynamic navigation remain open.

Latest0.1.2: HUNT-03 adds rounded original creatures and articulated poses, detailed rifle/reload, camp props and a cloud sky. This is one art pass, not the finished visual target. The cosmetic scope, forest composition, rocks and third-person weapons remain open.

Latest development checkpoint: HUNT-08 first service extraction, with89 selected assertions and no new packaged release.

Latest0.1.3 implements HUNT-11/12 crouch and noise with148 selected assertions, plus mixed-version rejection.

Next bounded session: HUNT-13/14 quiet gear and shot falloff/impact cues, then HUNT-15/16 changing wind and herd awareness. HUNT-06 opening story remains planned. Preserve actual footsteps, collision, hitbox and reward tests. Keep the original arcade tone; avoid heavy survival chores until hunting is enjoyable.

Hourly continuation uses the existing task automation. Keep meaningful milestone/failure/input notifications only, and avoid overlapping implementation or owner gameplay. The broader hunting goal remains active.
