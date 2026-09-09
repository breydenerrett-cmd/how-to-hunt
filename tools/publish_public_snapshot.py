#!/usr/bin/env python3
"""Publish a clean snapshot of the current checkpoint to the public GitHub repository.

The public repository is a snapshot lineage, not a mirror of development history.
Development commits track evidence/ captures, which are large and record local machine
paths, so they are excluded here rather than rewritten later.

Snapshots are taken from a commit, not the worktree, so this is safe to run while another
session has uncommitted work in progress. Uncommitted changes are simply not included.

    python3 tools/publish_public_snapshot.py --repo breydenerrett-cmd/how-to-hunt
    python3 tools/publish_public_snapshot.py --repo ... --ref v0.1.2 --dry-run
"""
import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

EXCLUDE = ["evidence"]
# Anything matching these must never reach a public repository.
FORBIDDEN = [
    (re.compile(r"/Users/[a-z]", re.I), "absolute home path"),
    (re.compile(r"\b(?:192\.168|10)\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"), "private IP address"),
]


def run(cmd, cwd=None, capture=True):
    r = subprocess.run(cmd, cwd=cwd, capture_output=capture, text=True)
    if r.returncode != 0:
        sys.exit(f"failed: {' '.join(cmd)}\n{(r.stderr or '').strip()}")
    return (r.stdout or "").strip()


def scan(root: Path) -> list[str]:
    """Return human-readable findings for any forbidden content in the staged tree."""
    findings = []
    for path in sorted(root.rglob("*")):
        if not path.is_file() or ".git" in path.parts:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue  # binary or unreadable: no text to leak
        for pattern, label in FORBIDDEN:
            m = pattern.search(text)
            # The hygiene rule in AGENTS.md documents the placeholder form itself.
            if m and "<name>" not in text[max(0, m.start() - 12):m.end() + 12]:
                findings.append(f"{path.relative_to(root)}: {label} ({m.group(0)})")
    return findings


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True, help="owner/name of the public repository")
    ap.add_argument("--ref", default="HEAD", help="commit to snapshot (default: HEAD)")
    ap.add_argument("--dry-run", action="store_true", help="verify and diff without pushing")
    args = ap.parse_args()

    source = Path(run(["git", "rev-parse", "--show-toplevel"]))
    head = run(["git", "rev-parse", "--short", args.ref], cwd=source)
    # The snapshot comes from the commit, so in-progress work elsewhere is harmless.
    # Say so plainly rather than failing: another session may always be running.
    if run(["git", "status", "--porcelain"], cwd=source):
        print(f"note: worktree has uncommitted changes; snapshotting committed {args.ref} ({head})")

    with tempfile.TemporaryDirectory(prefix="public-snapshot-") as tmp:
        tree, clone = Path(tmp) / "tree", Path(tmp) / "clone"
        tree.mkdir()

        archive = subprocess.run(["git", "archive", args.ref], cwd=source, capture_output=True)
        subprocess.run(["tar", "-x", "-C", str(tree)], input=archive.stdout, check=True)
        for name in EXCLUDE:
            shutil.rmtree(tree / name, ignore_errors=True)

        findings = scan(tree)
        if findings:
            print("refusing to publish; forbidden content found:", file=sys.stderr)
            for f in findings:
                print("  " + f, file=sys.stderr)
            sys.exit(1)
        print(f"verified {sum(1 for p in tree.rglob('*') if p.is_file())} files, no forbidden content")

        run(["gh", "repo", "clone", args.repo, str(clone), "--", "--quiet"])
        for item in clone.iterdir():
            if item.name != ".git":
                shutil.rmtree(item) if item.is_dir() else item.unlink()
        for item in tree.iterdir():
            shutil.copytree(item, clone / item.name) if item.is_dir() else shutil.copy2(item, clone / item.name)

        run(["git", "add", "-A"], cwd=clone)
        if not run(["git", "status", "--porcelain"], cwd=clone):
            print("public repository already matches this checkpoint; nothing to do")
            return
        print(run(["git", "diff", "--cached", "--stat"], cwd=clone))
        if args.dry_run:
            print("dry run: not pushing")
            return

        run(["git", "-c", "user.name=Codex", "-c", "user.email=codex@local",
             "commit", "-m", f"Publish snapshot of checkpoint {head}"], cwd=clone)
        run(["git", "push", "origin", "HEAD:main"], cwd=clone)
        print(f"published {head} to https://github.com/{args.repo}")


if __name__ == "__main__":
    main()
