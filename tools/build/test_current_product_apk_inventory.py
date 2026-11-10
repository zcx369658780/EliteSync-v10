"""Only newly-created temporary files are inventoried by these tests."""
import hashlib
import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import current_product_apk_inventory as inventory


class InventoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.file = self.root / "selected.bin"
        self.file.write_bytes(b"fixture")

    def run_inventory(self, entries=None, roots=None, count=3, size=100):
        return inventory.inventory_files(
            entries if entries is not None else [("input", str(self.file))],
            roots if roots is not None else [str(self.root)], count, size)

    def test_selected_identity_and_explicit_scope(self):
        (self.root / "unselected.bin").write_bytes(b"not selected")
        result = self.run_inventory(count=1, size=7)
        self.assertEqual(result["total_count"], 1)
        self.assertEqual(result["total_bytes"], 7)
        self.assertEqual(result["scope"], "SELECTED_DECLARED_FILES_ONLY")
        self.assertIs(result["execution_allowed"], False)
        self.assertIs(result["G2"], False)
        row = result["files"][0]
        self.assertEqual(row["role"], "input")
        self.assertEqual(row["path"], str(self.file))
        self.assertEqual(row["bytes"], 7)
        self.assertEqual(row["sha256"], hashlib.sha256(b"fixture").hexdigest())
        self.assertEqual(row["file_id"], {"device": self.file.stat().st_dev,
                                          "inode": self.file.stat().st_ino})

    def test_root_boundary(self):
        sibling = self.root / "allowed-other"
        sibling.mkdir()
        outside = sibling / "file"
        outside.write_bytes(b"x")
        allowed = self.root / "allowed"
        allowed.mkdir()
        with self.assertRaises(ValueError):
            self.run_inventory([("x", str(outside))], [str(allowed)])

    def test_duplicate_casefold_path(self):
        with self.assertRaises(ValueError):
            self.run_inventory([("a", str(self.file)), ("b", str(self.file).upper())])

    def test_missing_relative_and_non_normal_paths(self):
        for candidate in [str(self.root / "missing"), "selected.bin",
                          str(self.root) + os.sep + "." + os.sep + "selected.bin"]:
            with self.subTest(candidate=candidate), self.assertRaises((ValueError, OSError)):
                self.run_inventory([("x", candidate)])

    def test_invalid_roots(self):
        for roots in [[], ["relative"], [str(self.file)], "not a list"]:
            with self.subTest(roots=roots), self.assertRaises((ValueError, TypeError)):
                self.run_inventory(roots=roots)

    def test_invalid_entries(self):
        for entries in [[], True, "file", [("", str(self.file))], [("x", True)],
                        [("x", str(self.file), "extra")]]:
            with self.subTest(entries=entries), self.assertRaises((ValueError, TypeError)):
                self.run_inventory(entries=entries)

    def test_caps_and_bool_rejected_before_open(self):
        for count, size in [(0, 100), (True, 100), (3, False), (3, 0),
                            (3.0, 100), (3, "100"), (3, 6)]:
            with self.subTest(count=count, size=size), patch.object(inventory.os, "open") as opened:
                with self.assertRaises((ValueError, TypeError)):
                    self.run_inventory(count=count, size=size)
                opened.assert_not_called()

    def test_aggregate_limits_before_hash(self):
        second = self.root / "second.bin"
        second.write_bytes(b"1234")
        entries = [("a", str(self.file)), ("b", str(second))]
        for count, size in [(1, 100), (2, 10)]:
            with patch.object(inventory.os, "open") as opened:
                with self.assertRaises(ValueError):
                    self.run_inventory(entries, count=count, size=size)
                opened.assert_not_called()

    def test_regular_file_required(self):
        with self.assertRaises(ValueError):
            self.run_inventory([("dir", str(self.root))])

    def test_hardlink_rejected(self):
        link = self.root / "hardlink"
        os.link(self.file, link)
        with self.assertRaises(ValueError):
            self.run_inventory()

    def test_mock_reparse_ancestor_rejected(self):
        original = inventory.os.lstat

        def reparse(path):
            result = original(path)
            if Path(path) == self.root:
                class Reparse:
                    st_mode = result.st_mode
                    st_file_attributes = 0x400
                return Reparse()
            return result

        with patch.object(inventory.os, "lstat", side_effect=reparse):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_symlink_rejected_with_portable_mock(self):
        import stat
        original = inventory.os.lstat

        def symlink(path):
            if Path(path) == self.file:
                class Link:
                    st_mode = stat.S_IFLNK | 0o777
                    st_file_attributes = 0
                return Link()
            return original(path)

        with patch.object(inventory.os, "lstat", side_effect=symlink):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_read_time_drift_rejected(self):
        original = inventory.os.read
        changed = False

        def drift(fd, count):
            nonlocal changed
            data = original(fd, count)
            if not changed:
                changed = True
                self.file.write_bytes(b"changed-size")
            return data

        with patch.object(inventory.os, "read", side_effect=drift):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_actual_read_exceeding_cap_rejected(self):
        with patch.object(inventory.os, "read", return_value=b"x" * 8):
            with self.assertRaises(ValueError):
                self.run_inventory(size=7)

    def test_short_read_rejected(self):
        with patch.object(inventory.os, "read", return_value=b""):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_open_handle_identity_mismatch_rejected(self):
        original = inventory.os.fstat

        def different_inode(fd):
            info = original(fd)
            return SimpleNamespace(st_dev=info.st_dev, st_ino=info.st_ino + 1,
                                   st_size=info.st_size, st_mtime_ns=info.st_mtime_ns,
                                   st_mode=info.st_mode, st_nlink=info.st_nlink)

        with patch.object(inventory.os, "fstat", side_effect=different_inode):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_same_size_mtime_drift_rejected(self):
        original = inventory.os.fstat
        calls = 0

        def changed_mtime(fd):
            nonlocal calls
            calls += 1
            info = original(fd)
            return SimpleNamespace(st_dev=info.st_dev, st_ino=info.st_ino,
                                   st_size=info.st_size,
                                   st_mtime_ns=info.st_mtime_ns + (calls > 1),
                                   st_mode=info.st_mode, st_nlink=info.st_nlink)

        with patch.object(inventory.os, "fstat", side_effect=changed_mtime):
            with self.assertRaises(ValueError):
                self.run_inventory()

    def test_path_identity_drift_after_read_rejected(self):
        original_stat, original_read = inventory.os.lstat, inventory.os.read
        read_started = False

        def read(fd, count):
            nonlocal read_started
            read_started = True
            return original_read(fd, count)

        def changed_path(path):
            info = original_stat(path)
            if read_started and Path(path) == self.file:
                return SimpleNamespace(st_dev=info.st_dev, st_ino=info.st_ino + 1,
                                       st_size=info.st_size, st_mtime_ns=info.st_mtime_ns,
                                       st_mode=info.st_mode, st_nlink=info.st_nlink)
            return info

        with patch.object(inventory.os, "read", side_effect=read), \
                patch.object(inventory.os, "lstat", side_effect=changed_path):
            with self.assertRaises(ValueError):
                self.run_inventory()


if __name__ == "__main__":
    unittest.main()
