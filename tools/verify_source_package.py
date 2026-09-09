"""Verify the exact source ZIP, its frozen gameplay files and a fresh Godot import."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile

from package import OUTPUT, ROOT, release_identity


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True)
    options = parser.parse_args()
    version, tag, evidence = release_identity()
    archive_path = OUTPUT / f"How_To_Hunt_Source_{tag}.zip"
    frozen = json.loads((evidence / "source_files.json").read_text())
    if frozen["version"] != version:
        raise RuntimeError("Frozen gameplay manifest has a different version")
    archive_hash = hashlib.sha256(archive_path.read_bytes()).hexdigest()
    log_path = OUTPUT / f"Source_Import_{tag}.log"
    with tempfile.TemporaryDirectory(prefix=f"hunt-source-{tag}-") as folder:
        with zipfile.ZipFile(archive_path) as archive:
            if archive.testzip():
                raise RuntimeError("Source ZIP CRC failed")
            for name, digest in frozen["files"].items():
                if hashlib.sha256(archive.read("how-to-hunt/" + name)).hexdigest() != digest:
                    raise RuntimeError(f"Frozen source mismatch: {name}")
            for name in archive.namelist():
                parts = Path(name).parts
                if Path(name).is_absolute() or ".." in parts:
                    raise RuntimeError("Unsafe source archive member")
            archive.extractall(folder)
        project = Path(folder) / "how-to-hunt"
        result = subprocess.run(
            [str(Path(options.godot).resolve()), "--headless", "--editor", "--path", str(project), "--import", "--quit"],
            cwd=folder, capture_output=True, text=True, timeout=90,
        )
        output = result.stdout + result.stderr
        log_path.write_text(output)
        if result.returncode or "ERROR:" in output or "Parse Error" in output or "Godot Engine v4.5.2.stable.official" not in output:
            raise RuntimeError(f"Fresh source import failed; inspect {log_path}")
    report = {
        "version": version,
        "source_zip": archive_path.name,
        "source_zip_sha256": archive_hash,
        "zip_crc": "passed",
        "frozen_gameplay_files_matched": len(frozen["files"]),
        "fresh_import_exit_code": result.returncode,
        "log": log_path.name,
        "scope": "Exact packaged source integrity and fresh pinned-engine import; not a gameplay run.",
    }
    (OUTPUT / f"Source_Verification_{tag}.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
