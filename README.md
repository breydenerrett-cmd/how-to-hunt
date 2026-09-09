# How to Hunt — Pinefall prototype

Stalking build **v0.1.3**: hold **Ctrl or C** to crouch. All multiplayer players need this version (hunting protocol2).

An original arcade woodland hunt for one to four players. This first playable slice reuses selected support systems from Catch Catastrophe, with new terrain, animal behavior, hunting progression and an independent save identity. It is an early prototype, not a finished commercial game or a verified reference match.

## Download and play

**[Download the latest build](https://github.com/breydenerrett-cmd/how-to-hunt/releases/latest)**

Mac and Windows archives are attached to every release. No Godot install, GitHub account or
development tools are needed to play - download, unzip and run. That link always points at
the newest release, so it is safe to bookmark and share.

## Play

- Mac: unzip **How_To_Hunt_Mac_v0_1_3.zip**, then open **How to Hunt.app**. Apple Silicon and Intel are included; native launch was tested on Apple Silicon only. The app is ad-hoc signed, not notarized. If macOS blocks it, report the exact message; this build does not change security settings.
- Windows: unzip **How_To_Hunt_Windows_v0_1_3.zip**, then open **HowToHunt/HowToHunt.exe**. Native Windows playtesting of this hunting build remains pending.
- Choose **PLAY SOLO**, or **HOST A HUNT**. Three hunting world slots are independent of fishing worlds. Normal launches save; preview/test/capture sessions disable saves.

## First hunt

You start with 40 credits and empty hands. Walk to the timber **Pine & Powder** lodge on the left. Look at the rifle display and press **E** to inspect/buy the 25-credit trail rifle; it includes 12 shared rounds. The lodge also offers ammunition, a steadier sight, dragging harness and faster rifle action.

Follow the gold hoofprints out of camp. **E** inspects nearby tracks and gives a temporary direction/distance to the animal. Hold **Ctrl or C** to crouch and stalk. The **NOISE** meter shows how movement and trail/leaf litter affect your sound; stopping silences movement. Quiet is not invisible: nearby sight and upwind scent can still reveal you. You stay crouched beneath low ceilings until there is room to stand. Moving fast and approaching upwind raises suspicion. Hold **right mouse** to move quietly and steady your aim; the center dot turns gold when ready. **Left mouse** fires. A clean single-shot harvest earns 25% more than its ordinary base value. Unsteady shots do less damage; follow the hoofprints if the animal flees.

Walk within reach of a downed deer and press **F** to drag it. Return to **The Game Exchange** on the right of camp and press **E** to sell. **Q** puts a harvest down so it can be retrieved again. After two sales, a contract sends you beyond the watchtower for the larger Crownback. Leave its orange charge lane when it braces: the rush commits to that direction. Its hide reduces damage until the three-second recovery window. Dodge, steady your aim and counterattack; bank its harvest to complete the current contract.

**WASD** move · **Shift** run · **Space** jump · **R** reload · **Tab** journal · **Esc** pause/menu. The journal includes reduced motion, larger HUD text and Save & Return to Menu. Ammo and equipment are shared by the party. The rifle has a four-shot magazine; the displayed second number is the remaining shared ammunition pool, including usable magazine rounds. If the party runs completely out of ammo and cannot afford more, E at the lodge supplies four recovery rounds.

## Two computers

Use this same hunting version on both computers. On your home Wi-Fi, one player chooses **HOST A HUNT**. The other enters that computer's current local IPv4 address and chooses **JOIN HUNT**. This is a separate game and port from fishing: UDP 27951, up to three guests. No router/firewall/security changes are performed by the game or this workflow. The host owns the save. Persistent personal inventories, host migration and Steam invitations are not implemented.

## Source

Open `project.godot` with **Godot 4.5.2 standard/GDScript**, Compatibility renderer. Read AGENTS.md, HANDOFF.md and VALIDATION.md. Original art is procedural code. Foundation provenance is in `docs/REUSE_MANIFEST.json`; the hunting loop is under `hunt/`. Engine executables and export templates are not included in the source ZIP.

The current source uses an independent `How to Hunt` application directory. On macOS, saves normally live under `~/Library/Application Support/Godot/app_userdata/How to Hunt/`; world slots retain two recovery copies. Never copy hunting files into the fishing save folder.

See VALIDATION.md for exact evidence and remaining limitations. Gameplay appeal, polished visual quality, native Windows/Intel, real home-Wi-Fi hunting and long sessions require further testing.

## Copyright

Copyright 2026 breydenerrett-cmd. All rights reserved.

The source here is published so the builds are easy to download and so the code can be read.
It is **not** licensed for reuse, redistribution or derivative works. Godot's own license
notices are in GODOT_LICENSE.txt.
