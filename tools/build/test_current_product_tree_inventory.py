"""Temporary trees exercise complete enumeration, bounds and drift rejection."""
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_product_tree_inventory as tree


class TreeInventoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'lib').mkdir()
        (self.root / 'lib' / 'source.dart').write_bytes(b'source')
        (self.root / 'native.dll').write_bytes(b'native')

    def inventory(self, **kwargs):
        args = dict(roots={'fixture': str(self.root)}, file_limit=10,
                    entry_limit=20, byte_limit=100, depth_limit=5)
        args.update(kwargs)
        return tree.inventory_trees(**args)

    def test_all_files_including_hidden_and_empty_directories(self):
        (self.root / '.hidden').write_bytes(b'hidden')
        (self.root / 'empty').mkdir()
        result = self.inventory()
        self.assertEqual(result['total_count'], 3)
        self.assertEqual(result['total_bytes'], 18)
        self.assertEqual(result['directory_count'], 3)
        self.assertEqual({row['relative_path'] for row in result['files']},
                         {'lib/source.dart', 'native.dll', '.hidden'})
        self.assertEqual(result['scope'], 'COMPLETE_DECLARED_TREES_ONLY')
        self.assertIs(result['sampling_non_atomic'], True)
        self.assertIs(result['runtime_read_closure_proven'], False)
        self.assertIs(result['execution_allowed'], False)

    def test_aggregate_bounds_reject_before_hashing(self):
        for cap in [dict(file_limit=1), dict(entry_limit=3), dict(byte_limit=11),
                    dict(depth_limit=1)]:
            with self.subTest(cap=cap), patch.object(tree, 'inventory_files') as hashed:
                with self.assertRaises(ValueError):
                    self.inventory(**cap)
                hashed.assert_not_called()

    def test_directory_only_tree_cannot_evade_entry_cap(self):
        for i in range(5):
            (self.root / str(i)).mkdir()
        with self.assertRaises(ValueError):
            self.inventory(entry_limit=6)

    def test_invalid_limits_and_roots(self):
        for changes in [dict(file_limit=True), dict(byte_limit=0),
                        dict(depth_limit=1.0), dict(entry_limit=-1),
                        dict(roots={}), dict(roots={'': str(self.root)}),
                        dict(roots={'x': '.'}), dict(roots={'x': str(self.root.anchor)}),
                        dict(roots={'x': str(self.root), 'nested': str(self.root / 'lib')})]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                self.inventory(**changes)

    def test_empty_root_is_not_a_complete_sdk(self):
        empty = self.root / 'empty'
        empty.mkdir()
        with self.assertRaises(ValueError):
            self.inventory(roots={'sdk': str(empty)})

    def test_hardlinked_files_are_rejected(self):
        os.link(self.root / 'native.dll', self.root / 'other.dll')
        with self.assertRaises(ValueError):
            self.inventory()

    def test_reparse_is_rejected_without_traversal(self):
        original = tree._checked_stat

        def checked(path):
            if path == self.root / 'lib':
                raise ValueError('reparse fixture')
            return original(path)

        with patch.object(tree, '_checked_stat', side_effect=checked):
            with self.assertRaises(ValueError):
                self.inventory()

    def test_added_file_during_hash_is_rejected(self):
        original = tree.inventory_files

        def changed(*args):
            result = original(*args)
            (self.root / 'late.txt').write_bytes(b'new')
            return result

        with patch.object(tree, 'inventory_files', side_effect=changed):
            with self.assertRaises(ValueError):
                self.inventory()

    def test_file_changed_after_hash_is_rejected(self):
        original = tree.inventory_files

        def changed(*args):
            result = original(*args)
            (self.root / 'native.dll').write_bytes(b'changed size')
            return result

        with patch.object(tree, 'inventory_files', side_effect=changed):
            with self.assertRaises(ValueError):
                self.inventory()


if __name__ == '__main__':
    unittest.main()
