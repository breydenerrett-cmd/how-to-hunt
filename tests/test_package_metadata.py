"""Mac packaging metadata guards, using tiny temporary ZIPs and no Godot runtime."""
from __future__ import annotations

import importlib.util
import plistlib
import struct
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import zipfile


PACKAGE_PATH = Path(__file__).resolve().parents[1] / "tools/package.py"
SPEC = importlib.util.spec_from_file_location("catch_package", PACKAGE_PATH)
package = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(package)


class MacBundleVersionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        identity = patch.object(package, "release_identity", return_value=("0.3.4-polish", "v0_3_4", self.root))
        identity.start()
        self.addCleanup(identity.stop)

    def make_export(self, short_version="0.3.4", bundle_version="0.3.4"):
        path = self.root / "HowToHunt.zip"
        plist = {"CFBundleIdentifier": "com.hollowtrail.howtohunt.prototype"}
        if short_version is not None:
            plist["CFBundleShortVersionString"] = short_version
        if bundle_version is not None:
            plist["CFBundleVersion"] = bundle_version
        # Only the structure consumed by validate_macos is needed. These are
        # deliberately tiny fixtures, not executable/export-runtime evidence.
        fat_header = struct.pack(">II", 0xCAFEBABE, 2)
        fat_header += struct.pack(">IIIII", 0x01000007, 0, 0, 0, 0)
        fat_header += struct.pack(">IIIII", 0x0100000C, 0, 0, 0, 0)
        executable = zipfile.ZipInfo("How to Hunt.app/Contents/MacOS/HowToHunt")
        executable.create_system = 3
        executable.external_attr = 0o100755 << 16
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr(executable, fat_header)
            archive.writestr("How to Hunt.app/Contents/Resources/HowToHunt.pck", b"GDPC")
            archive.writestr("How to Hunt.app/Contents/Info.plist", plistlib.dumps(plist))
        return path

    def test_matching_release_versions_are_recorded(self):
        report = package.validate_macos(self.make_export())
        self.assertEqual(report["CFBundleShortVersionString"], "0.3.4")
        self.assertEqual(report["CFBundleVersion"], "0.3.4")
        self.assertEqual(report["structure_and_game_pack"], "passed")

    def test_old_export_versions_are_rejected(self):
        with self.assertRaisesRegex(RuntimeError, r"CFBundleShortVersionString.*0\.3\.2.*0\.3\.4"):
            package.validate_macos(self.make_export("0.3.2", "0.3.2"))

    def test_stale_bundle_version_is_rejected_independently(self):
        with self.assertRaisesRegex(RuntimeError, r"CFBundleVersion.*0\.3\.2.*0\.3\.4"):
            package.validate_macos(self.make_export("0.3.4", "0.3.2"))

    def test_missing_version_fields_are_rejected(self):
        for short_version, bundle_version, field in [
            (None, "0.3.4", "CFBundleShortVersionString"),
            ("0.3.4", None, "CFBundleVersion"),
        ]:
            with self.subTest(field=field), self.assertRaisesRegex(RuntimeError, field):
                package.validate_macos(self.make_export(short_version, bundle_version))

    def test_plist_versions_require_the_numeric_release(self):
        for short_version, bundle_version, field in [
            ("0.3.4-polish", "0.3.4", "CFBundleShortVersionString"),
            ("0.3.4", "0.3.4-polish", "CFBundleVersion"),
        ]:
            with self.subTest(field=field), self.assertRaisesRegex(RuntimeError, field):
                package.validate_macos(self.make_export(short_version, bundle_version))


if __name__ == "__main__":
    unittest.main()
