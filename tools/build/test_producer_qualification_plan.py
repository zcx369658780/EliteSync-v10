import copy
import unittest

import producer_qualification_plan as plan


class StaticQualificationPlanTests(unittest.TestCase):
    def setUp(self):
        self.mapping = {'host': 'D:/Private/Tools', 'guest': 'C:/Inputs/Tools'}
        self.row = {'role': 'tools', 'relative_path': 'bin/tool.exe',
                    'path': 'D:/Private/Tools/bin/tool.exe', 'bytes': 4,
                    'sha256': 'a' * 64}
        self.inventory = {'roots': {'tools': self.mapping['host']}, 'files': [self.row]}

    def select(self, inventory=None, relatives=('bin/tool.exe',)):
        return plan.selected_records(inventory or self.inventory, 'tools', self.mapping, relatives)

    def test_exact_selection_preserves_unqualified_boundary(self):
        row, = self.select()
        self.assertEqual(row['guest'], 'C:/Inputs/Tools/bin/tool.exe')
        self.assertIs(row['qualified'], False)
        self.assertEqual(row['evidence'], 'INVENTORIED_CONTENT_ONLY')

    def test_missing_or_ambiguous_content_rejected(self):
        with self.assertRaises(ValueError):
            self.select(relatives=('bin/missing.exe',))
        self.inventory['files'].append(copy.deepcopy(self.row))
        with self.assertRaises(ValueError):
            self.select()

    def test_inventory_cannot_redirect_host_or_mapping(self):
        for altered in ('D:/Other/bin/tool.exe', 'D:/Private/ToolsElse/bin/tool.exe'):
            self.row['path'] = altered
            with self.assertRaises(ValueError):
                self.select()
        self.inventory['roots']['tools'] = 'D:/Other'
        with self.assertRaises(ValueError):
            self.select()

    def test_noncanonical_relative_paths_rejected(self):
        for relative in ('../tool.exe', '/bin/tool.exe', 'C:/tool.exe',
                         'bin\\tool.exe', 'bin/../tool.exe', 'bin//tool.exe', ''):
            with self.subTest(relative=relative), self.assertRaises(ValueError):
                self.select(relatives=(relative,))

    def test_invalid_content_identities_rejected(self):
        for key, value in [('sha256', 'invalid'), ('bytes', -1), ('bytes', True)]:
            inventory = copy.deepcopy(self.inventory)
            inventory['files'][0][key] = value
            with self.assertRaises(ValueError):
                self.select(inventory)

    def test_capacity_snapshot_never_grants_execution(self):
        for available, enough in [(4625, False), (10239, False), (10240, True)]:
            candidate = plan.resource_candidate(available)
            self.assertEqual(candidate['snapshot_has_proposed_headroom'], enough)
            self.assertIs(candidate['execution_allowed'], False)
            self.assertIs(candidate['capacity_qualified'], False)
            self.assertIs(candidate['claim_created'], False)
        for invalid in (-1, True, 1.2, '10240'):
            with self.assertRaises(ValueError):
                plan.resource_candidate(invalid)


if __name__ == '__main__':
    unittest.main()
