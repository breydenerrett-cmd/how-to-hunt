"""Verify an exact Mac export with disposable headless or rendered native sessions."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import tempfile

from package import ROOT, release_identity


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--headless-only", action="store_true",
        help="Check native exported menu/solo startup without creating a GUI window or capture; graphical runtime remains pending.",
    )
    parser.add_argument("--background", action="store_true", help="Capture a minimized native app without bringing it to the foreground.")
    options = parser.parse_args()
    if options.background and options.headless_only:
        parser.error("Choose headless-only or background capture, not both")
    version, release_tag, evidence = release_identity()
    archive = ROOT / "exports/mac/HowToHunt.zip"
    export_hash = hashlib.sha256(archive.read_bytes()).hexdigest()
    evidence.mkdir(parents=True, exist_ok=True)
    results = []
    mode = "headless_native" if options.headless_only else ("rendered_native_background" if options.background else "rendered_native")
    with tempfile.TemporaryDirectory(prefix=f"hunt-{release_tag}-export-") as folder:
        subprocess.run(["ditto", "-xk", str(archive), folder], check=True, timeout=30)
        app = Path(folder) / "How to Hunt.app"
        signed = subprocess.run(
            ["codesign", "--verify", "--deep", "--strict", "--verbose=2", str(app)],
            capture_output=True, text=True, timeout=30,
        )
        (evidence / "mac_signature.log").write_text(signed.stdout + signed.stderr)
        signed.check_returncode()
        executable = app / "Contents/MacOS/How to Hunt"
        for scene in ("menu", "solo"):
            stem = f"native_export_{'headless_' if options.headless_only else ''}{scene}"
            log = evidence / f"{stem}.log"
            picture = None
            if options.headless_only:
                args = [str(executable), "--headless", "--quit-after", "120", "--", "--preview"]
            else:
                picture = evidence / f"{stem}.png"
                picture.unlink(missing_ok=True)
                args = [
                    str(executable), "--resolution", "1920x1080", "--", "--preview",
                    "--capture=" + str(picture), "--capture-quit",
                ]
            if scene == "solo":
                args.append("--solo")
            if options.background:
                log.unlink(missing_ok=True)
                # LaunchServices -g preserves the foreground owner playtest. The
                # exported app writes its own log; open's exit status is not game proof.
                args = ["open", "-g", "-n", "-W", str(app), "--args", "--minimized", "--log-file", str(log)] + args[1:]
                result = subprocess.run(args, cwd=ROOT, capture_output=True, timeout=60)
            else:
                with log.open("w") as output:
                    result = subprocess.run(args, cwd=ROOT, stdout=output, stderr=subprocess.STDOUT, timeout=40)
            output_text = log.read_text()
            valid = (
                result.returncode == 0
                and f"HUNT_BOOT {version} renderer=" in output_text
                and "Godot Engine v4.5.2.stable.official" in output_text
                and "ERROR:" not in output_text
                and "Parse Error" not in output_text
            )
            if scene == "solo":
                valid = valid and "HUNT_HOST_READY" in output_text and "online=false" in output_text
                valid = valid and "Welcome to Pinefall." in output_text
            else:
                valid = valid and "HUNT_HOST_READY" not in output_text
            if picture is not None:
                valid = valid and picture.exists() and f"HUNT_CAPTURE {picture}" in output_text
            elif "HUNT_CAPTURE" in output_text:
                valid = False
            if not valid:
                raise RuntimeError(f"Exported {scene} {mode} validation failed; inspect {log}\n{output_text}")
            entry = {"scene": scene, "launcher_exit_code" if options.background else "exit_code": result.returncode, "log": log.name}
            if picture is not None:
                entry["capture"] = picture.name
            results.append(entry)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != export_hash:
        raise RuntimeError("Mac export changed while validation was running; rerun against one exact archive")
    report = {
        "version": version,
        "release_tag": release_tag,
        "export_sha256": export_hash,
        "mode": mode,
        "machine_architecture": platform.machine(),
        "result": (
            "passed: headless native exported-resource menu and fresh solo tutorial startup, 120 iterations each, clean exit"
            if options.headless_only else
            "passed: native exported-resource menu and fresh solo tutorial rendering, clean exit"
        ),
        "graphical_runtime": "pending for this exact export" if options.headless_only else "rendered menu and solo captures passed",
        "signature": "strict ad-hoc verification passed on temporary extraction; not notarized",
        "scope": (
            "Headless native exported-resource startup only; no GUI window or screenshot. Graphical runtime and human gameplay remain pending. "
            if options.headless_only else
            "Native exported-resource capture sessions only; not a full manual campaign. " + ("Minimized background launch; capture/log completion checked, launcher status is not the app exit code. " if options.background else "")
        ) + "World saving disabled. Tests only the current machine architecture; not another architecture or a clean-download Gatekeeper test.",
        "runs": results,
    }
    (evidence / "native_runtime.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
