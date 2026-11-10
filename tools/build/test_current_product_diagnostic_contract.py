from copy import deepcopy
import unittest

from current_product_diagnostic_contract import TASK, next_reservation, validate_ledger


class DiagnosticContractTests(unittest.TestCase):
    def ledger(self):
        return {'schema': 1, 'task': TASK, 'owner_authorized': True,
                'max_attempts': 3, 'legacy_claims_reused': False, 'G2': False,
                'reservations': []}

    def reserve(self, ledger, number=1):
        return next_reservation(ledger, manifest_sha256=str(number) * 64,
                                command_sha256='a' * 64)

    def test_empty_data_ledger_and_three_contiguous_reservations(self):
        ledger = self.ledger()
        validate_ledger(ledger)
        for number in range(1, 4):
            ledger = self.reserve(ledger, number)
        self.assertEqual([row['attempt'] for row in ledger['reservations']], [1, 2, 3])
        self.assertTrue(all(row['refundable'] is False for row in ledger['reservations']))
        with self.assertRaises(ValueError):
            self.reserve(ledger, 4)

    def test_reservation_is_deep_copy_and_does_not_change_old_fields(self):
        original = self.reserve(self.ledger())
        before = deepcopy(original)
        result = self.reserve(original, 2)
        self.assertEqual(original, before)
        self.assertIsNot(result, original)
        self.assertIsNot(result['reservations'], original['reservations'])
        self.assertIsNot(result['reservations'][0], original['reservations'][0])
        for key in original.keys() - {'reservations'}:
            self.assertEqual(result[key], original[key])
        result['reservations'][0]['manifest_sha256'] = 'f' * 64
        self.assertEqual(original, before)

    def test_unchanged_pair_cannot_be_reserved_again(self):
        original = self.reserve(self.ledger())
        before = deepcopy(original)
        with self.assertRaises(ValueError):
            self.reserve(original)
        self.assertEqual(original, before)
        # A changed command is a distinct pair; this is only a data distinction.
        changed = next_reservation(original, manifest_sha256='1' * 64,
                                   command_sha256='b' * 64)
        self.assertEqual(len(changed['reservations']), 2)

    def test_existing_duplicate_or_fourth_rows_are_rejected(self):
        ledger = self.reserve(self.ledger())
        row = deepcopy(ledger['reservations'][0])
        row['attempt'] = 2
        ledger['reservations'].append(row)
        with self.assertRaises(ValueError):
            validate_ledger(ledger)
        ledger = self.ledger()
        for number in range(1, 5):
            ledger['reservations'].append({'attempt': number, 'manifest_sha256': str(number) * 64,
                                           'command_sha256': 'a' * 64, 'refundable': False})
        with self.assertRaises(ValueError):
            validate_ledger(ledger)

    def test_fixed_ledger_identity_authority_and_types_cannot_be_changed(self):
        changes = [('schema', True), ('schema', 1.0), ('schema', 2),
                   ('task', TASK + '-other'), ('task', None),
                   ('owner_authorized', 1), ('owner_authorized', False),
                   ('owner_authorized', 'true'), ('max_attempts', True),
                   ('max_attempts', 3.0), ('max_attempts', 4),
                   ('legacy_claims_reused', True), ('legacy_claims_reused', 0),
                   ('G2', True), ('G2', 0), ('reservations', ()), ('reservations', None)]
        for key, value in changes:
            with self.subTest(key=key, value=value):
                ledger = self.ledger()
                ledger[key] = value
                with self.assertRaises(ValueError):
                    validate_ledger(ledger)

    def test_missing_and_unknown_ledger_fields_are_rejected(self):
        for key in self.ledger():
            ledger = self.ledger()
            del ledger[key]
            with self.assertRaises(ValueError):
                validate_ledger(ledger)
        ledger = self.ledger()
        ledger['remaining_attempts'] = 3
        with self.assertRaises(ValueError):
            validate_ledger(ledger)

    def test_reservation_shape_sequence_and_refund_types_are_strict(self):
        for key, value in [('attempt', True), ('attempt', 1.0), ('attempt', 0),
                           ('attempt', 2), ('refundable', True), ('refundable', 0),
                           ('refundable', 'false')]:
            ledger = self.reserve(self.ledger())
            ledger['reservations'][0][key] = value
            with self.assertRaises(ValueError):
                validate_ledger(ledger)
        for key in ['attempt', 'manifest_sha256', 'command_sha256', 'refundable']:
            ledger = self.reserve(self.ledger())
            del ledger['reservations'][0][key]
            with self.assertRaises(ValueError):
                validate_ledger(ledger)
        ledger = self.reserve(self.ledger())
        ledger['reservations'][0]['refunded'] = False
        with self.assertRaises(ValueError):
            validate_ledger(ledger)

    def test_hash_format_and_failed_reservation_leave_input_unchanged(self):
        invalid = [None, True, 12, '', 'f' * 63, 'f' * 65, 'A' * 64, 'g' * 64]
        for field in ['manifest_sha256', 'command_sha256']:
            for value in invalid:
                ledger = self.ledger()
                before = deepcopy(ledger)
                values = {'manifest_sha256': '1' * 64, 'command_sha256': 'a' * 64}
                values[field] = value
                with self.assertRaises(ValueError):
                    next_reservation(ledger, **values)
                self.assertEqual(ledger, before)
                ledger = self.reserve(self.ledger())
                ledger['reservations'][0][field] = value
                with self.assertRaises(ValueError):
                    validate_ledger(ledger)

    def test_caller_cannot_repair_tampered_ledger_by_reserving(self):
        ledger = self.reserve(self.ledger())
        ledger['max_attempts'] = 10
        before = deepcopy(ledger)
        with self.assertRaises(ValueError):
            self.reserve(ledger, 2)
        self.assertEqual(ledger, before)


if __name__ == '__main__':
    unittest.main()
