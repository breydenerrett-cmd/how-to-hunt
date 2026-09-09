"""Package already-exported binaries and the source; no external services needed."""
from __future__ import annotations

import hashlib
import json
import plistlib
import re
import shutil
import struct
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "exports/releases"


def release_identity() -> tuple[str, str, Path]:
    """Read the game version once; keep release records separate from older builds."""
    catalog = (ROOT / "hunt/catalog.gd").read_text()
    match = re.search(r'^const VERSION\s*=\s*"(\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?)"', catalog, re.MULTILINE)
    if not match:
        raise RuntimeError("Could not read a semantic VERSION from hunt/catalog.gd")
    version = match.group(1)
    tag = "v" + version.split("-", 1)[0].replace(".", "_")
    return version, tag, ROOT / "evidence" / f"release_{tag}"


def validate_binary(path: Path, platform: str) -> dict:
    data = path.read_bytes()
    if len(data) < 20_000_000:
        raise RuntimeError(f"Unexpectedly small export: {path}")
    if platform == "windows":
        if data[:2] != b"MZ":
            raise RuntimeError("Windows export is not a PE executable")
        offset = struct.unpack_from("<I", data, 0x3C)[0]
        if data[offset:offset + 4] != b"PE\x00\x00":
            raise RuntimeError("Invalid Windows PE header")
        if struct.unpack_from("<H", data, offset + 4)[0] != 0x8664:
            raise RuntimeError("Expected Windows x86_64 executable")
    elif data[:4] != b"\x7fELF":
        raise RuntimeError("Linux export is not an ELF executable")
    if data[-4:] != b"GDPC":
        raise RuntimeError(f"Embedded Godot pack trailer missing: {path}")
    return {
        "file": path.name,
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "structure_and_embedded_pack": "passed",
        "native_runtime": "not tested",
    }


def write_archive(destination: Path, entries: list[tuple[Path, str]]) -> dict:
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for path, name in entries:
            archive.write(path, name)
    with zipfile.ZipFile(destination) as archive:
        bad = archive.testzip()
        if bad:
            raise RuntimeError(f"Corrupt ZIP entry: {bad}")
        count = len(archive.infolist())
    return {
        "path": str(destination),
        "entries": count,
        "bytes": destination.stat().st_size,
        "sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
        "zip_crc": "passed",
    }


def validate_macos(path: Path) -> dict:
    with zipfile.ZipFile(path) as archive:
        if archive.testzip():
            raise RuntimeError("Mac export ZIP CRC failed")
        executable = next(i for i in archive.infolist() if "/Contents/MacOS/" in i.filename and not i.is_dir())
        data = archive.read(executable)
        if not (executable.external_attr >> 16) & 0o100:
            raise RuntimeError("Mac executable permission missing")
        if data[:4] != b"\xca\xfe\xba\xbe":
            raise RuntimeError("Expected a Universal 2 Mach-O binary")
        count = struct.unpack_from(">I", data, 4)[0]
        architectures = {struct.unpack_from(">I", data, 8 + 20 * i)[0] for i in range(count)}
        if not {0x01000007, 0x0100000C}.issubset(architectures):
            raise RuntimeError("Apple Silicon or Intel architecture missing")
        pack = next(i for i in archive.namelist() if i.endswith(".pck"))
        if archive.read(pack)[:4] != b"GDPC":
            raise RuntimeError("Mac game pack missing")
        plist = plistlib.loads(archive.read(next(i for i in archive.namelist() if i.endswith("Info.plist"))))
        if plist["CFBundleIdentifier"] != "com.hollowtrail.howtohunt.prototype":
            raise RuntimeError("Unexpected Mac bundle identifier")
        expected_version = release_identity()[0].split("-", 1)[0]
        version_fields = ("CFBundleShortVersionString", "CFBundleVersion")
        for key in version_fields:
            if plist.get(key) != expected_version:
                raise RuntimeError(f"Mac {key} is {plist.get(key)!r}; expected release version {expected_version!r}")
    return {
        "file": path.name,
        "bytes": path.stat().st_size,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "structure_and_game_pack": "passed",
        "architectures": ["arm64", "x86_64"],
        **{key: plist[key] for key in version_fields},
        "native_runtime": "not tested",
        "signing": "Godot built-in ad-hoc export; not notarized",
    }


def main() -> None:
    version, release_tag, evidence_dir = release_identity()
    targets = [OUTPUT / f"How_To_Hunt_{platform}_{release_tag}.zip" for platform in ("Windows", "Mac", "Source")]
    existing = [str(path) for path in targets if path.exists()]
    if existing:
        raise FileExistsError("Refusing to overwrite existing release archives: " + ", ".join(existing))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    windows = ROOT / "exports/windows/HowToHunt.exe"
    mac = ROOT / "exports/mac/HowToHunt.zip"
    builds = [validate_binary(windows, "windows"), validate_macos(mac)]
    runtime = evidence_dir / "native_runtime.json"
    evidence = json.loads(runtime.read_text())
    if evidence.get("version") != version or evidence.get("export_sha256") != builds[1]["sha256"]:
        raise RuntimeError(f"Mac runtime evidence does not match this version and exact export: {runtime}")
    if not evidence.get("result", "").startswith("passed:"):
        raise RuntimeError(f"Mac runtime evidence did not pass: {runtime}")
    builds[1]["native_runtime"] = evidence["result"]
    builds[1]["runtime_mode"] = evidence.get("mode", "unspecified")
    builds[1]["graphical_runtime"] = evidence.get("graphical_runtime", "not tested")
    builds[1]["runtime_evidence"] = runtime.relative_to(ROOT).as_posix()
    for build in builds:
        build["version"] = version
    evidence_dir.mkdir(parents=True, exist_ok=True)
    builds_path = evidence_dir / "builds.json"
    builds_path.write_text(json.dumps(builds, indent=2) + "\n")
    docs = ["README.md", "GODOT_LICENSE.txt", "VALIDATION.md"]
    win_entries = [(windows, "HowToHunt/HowToHunt.exe")]
    win_entries += [(ROOT / name, f"HowToHunt/{name}") for name in docs]
    win_entries += [(builds_path, "HowToHunt/builds.json")]
    outputs = [write_archive(targets[0], win_entries)]
    mac_output = targets[1]
    shutil.copyfile(mac, mac_output)
    with zipfile.ZipFile(mac_output, "a", zipfile.ZIP_DEFLATED) as archive:
        for name in docs:
            archive.write(ROOT / name, name)
        archive.write(builds_path, "builds.json")
    with zipfile.ZipFile(mac_output) as archive:
        if archive.testzip():
            raise RuntimeError("Final Mac archive CRC failed")
    outputs.append({"path": str(mac_output), "bytes": mac_output.stat().st_size, "sha256": hashlib.sha256(mac_output.read_bytes()).hexdigest(), "zip_crc": "passed"})
    excluded = {".godot", ".git", ".tools", "exports", "__pycache__", ".DS_Store"}
    source = []
    for path in sorted(ROOT.rglob("*")):
        relative = path.relative_to(ROOT)
        if not path.is_file() or any(part in excluded for part in relative.parts):
            continue
        if path.suffix == ".pyc":
            continue
        if relative.parts[0] == "evidence" and path.suffix == ".import":
            continue
        # This manifest is written after packaging and contains the source ZIP hash.
        # Including it inside that ZIP would make it self-referential/stale.
        if relative.parts[0] == "evidence" and path.name == "release_manifest.json":
            continue
        source.append((path, "how-to-hunt/" + relative.as_posix()))
    outputs.append(write_archive(targets[2], source))
    report = {"version": version, "release_tag": release_tag, "binaries": builds, "archives": outputs}
    (evidence_dir / "release_manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
