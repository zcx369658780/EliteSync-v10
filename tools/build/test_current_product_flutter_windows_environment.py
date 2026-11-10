"""Pure dictionary tests; no SDK, guest, environment mutation or execution."""
import copy
import unittest

from current_product_flutter_windows_environment import with_executable_extensions
import windows_sandbox_flutter_console_probe as prior


class PrivateWindowsEnvironmentTests(unittest.TestCase):
    def test_selected_previous_contract_gets_only_missing_extension(self):
        original = prior.contract()['environment']; before = copy.deepcopy(original)
        self.assertNotIn('PATHEXT', original)
        candidate = with_executable_extensions(original)
        self.assertEqual(candidate, {**original, 'PATHEXT': '.EXE'})
        self.assertEqual(original, before)
        self.assertNotIn('FLUTTER_ALREADY_LOCKED', candidate)
        self.assertEqual(prior.contract()['max_launches'], 1)
        self.assertFalse(prior.contract()['producer_entry_allowed'])

    def test_idempotent_and_windows_key_normalization(self):
        candidate = with_executable_extensions({'pathext': '.EXE', 'PATH': 'fixed-private-path'})
        self.assertEqual(candidate, {'PATH': 'fixed-private-path', 'PATHEXT': '.EXE'})
        self.assertEqual(with_executable_extensions(candidate), candidate)

    def test_host_extension_list_and_script_extensions_rejected(self):
        for value in ['', '.EXE;.BAT', '.COM', '.CMD', '.exe']:
            with self.subTest(value=value), self.assertRaises(ValueError):
                with_executable_extensions({'PATHEXT': value})

    def test_case_duplicate_and_lock_bypass_rejected(self):
        for value in [{'PATH': 'a', 'path': 'b'}, {'PATHEXT': '.EXE', 'pathext': '.EXE'},
                      {'flutter_already_locked': '1'}]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                with_executable_extensions(value)

    def test_invalid_keys_values_and_types_rejected(self):
        for value in [None, [], {'': 'x'}, {'x=y': 'x'}, {'x': True}, {True: 'x'},
                      {'x': 'a\0b'}, {'x\n': 'b'}, {'x': 'a\rb'}]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                with_executable_extensions(value)


if __name__ == '__main__': unittest.main()
