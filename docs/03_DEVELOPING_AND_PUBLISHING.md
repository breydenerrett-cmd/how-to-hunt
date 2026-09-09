# Developing on two machines, and publishing releases

Written 2026-09-08 when the project moved from a single Mac to GitHub-backed development.

## Why the public repository is a snapshot, not a mirror

Development commits track `evidence/` captures. Those are large and they record local
machine paths, so they must not enter a public repository. Rather than rewrite history
later, the public repository holds a **clean snapshot per checkpoint**:

- **This repository** — full development history, evidence included, stays private and local.
- **github.com/breydenerrett-cmd/how-to-hunt** — clean snapshots plus release builds.

The two therefore have separate commit histories. That is deliberate. Publish with the
script below rather than adding a remote and pushing this branch directly.

## Publishing a snapshot

Requires a committed checkpoint; the script refuses to run on a dirty worktree, and refuses
to publish if it finds an absolute home path or a private IP in the tree.

```
python3 tools/publish_public_snapshot.py --repo breydenerrett-cmd/how-to-hunt --dry-run
python3 tools/publish_public_snapshot.py --repo breydenerrett-cmd/how-to-hunt
```

## Publishing a playable release

Build and package as usual, then attach the archives to a GitHub release. Friends only ever
need `https://github.com/breydenerrett-cmd/how-to-hunt/releases/latest`, which always
resolves to the newest release.

```
gh release create v0.1.3 \
  exports/releases/How_To_Hunt_Mac_v0_1_3.zip \
  exports/releases/How_To_Hunt_Windows_v0_1_3.zip \
  --title "How to Hunt v0.1.3" --notes "..."
```

Never replace or delete an existing release; sealed builds stay available.

## Working from the PC

1. Install **Godot 4.5.2 standard** (not the .NET build) and its matching export templates,
   plus Python 3.11+, `git` and `gh`.
2. Clone the source: `gh repo clone breydenerrett-cmd/how-to-hunt`.
3. Point tooling at the engine once per shell, so the same commands work on either machine:

   ```
   export GODOT="/path/to/Godot"           # macOS or Linux
   $env:GODOT = "C:\path\to\Godot.exe"     # Windows PowerShell
   ```

4. Run the suite headless, for example:

   ```
   "$GODOT" --headless --path . --script tests/hunt_rules.gd -- --test
   "$GODOT" --headless --path . --script tests/hunt_network.gd -- --role=host
   ```

### What does not transfer between machines

- **Save worlds.** They live in Godot's per-user data directory, not in the repository, so
  the PC starts with fresh world slots. This is intentional and keeps hosts independent.
- **Release archives.** They live on GitHub Releases, not in git.
- **The Godot install and export templates.** Install these per machine.

### Mac builds still require the Mac

Mac release archives are ad-hoc signed with Apple's `codesign`, which only runs on macOS.
Windows builds and all development can happen on the PC, but producing a signed Mac release
means running the packaging step on the Mac. Keep a clone there for milestone builds.

### Switching machines

Commit and publish a checkpoint before switching; pull on arrival. This is also what lets an
agent session on either machine resume from the same tree — read `AGENTS.md`,
`HANDOFF.md`, `VALIDATION.md` and `docs/01_LIVING_BACKLOG.md` before choosing work.
