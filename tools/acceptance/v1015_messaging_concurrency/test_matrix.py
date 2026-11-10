"""Pure rejection cases for the additional permission matrix, not runtime proof."""
import copy
import unittest

from protocol import validate_permission_denial, validate_denied_response
from run import probe_cases, persisted_state
from test_protocol import snapshots, reply, waits


class MatrixTests(unittest.TestCase):
    def arguments(self, case):
        before, _ = snapshots()
        before.update(disabled={'1': False, '2': False}, block_count=0, cn_revision=2, mc_revisions=[2, 2],
                      token_ids={'1': [1], '2': [2]}, active_session_ids={'1': ['a'], '2': ['b']})
        after = copy.deepcopy(before)
        after['cn_state'] = 'CN_CLOSED'
        after['cn_revision'] = 3
        after['mc_states'] = ['MC_REVOKED'] * 2
        after['mc_revisions'] = [3, 3]
        if case == 'block':
            after['block_count'] = 1
            after['mc_states'] = ['MC_REVOKED'] * 2
        elif case == 'cn-close':
            after['cn_state'] = 'CN_CLOSED'
            after['mc_states'] = ['MC_REVOKED'] * 2
        else:
            after['disabled']['2'] = True
            after['mc_states'] = ['MC_REVOKED'] * 2
            after['token_ids']['2'] = []
            after['active_session_ids']['2'] = []
        writer = dict(status=200, committed=True, transaction_level=0,
                      session_isolation='REPEATABLE-READ', connection_id=20, kernel_executed=True)
        return [before, after, [reply(21, denied=True), reply(22, denied=True)],
                waits(), 20, [21, 22], 'task_database', 1, writer, case, [1, 2]]

    def test_three_explicit_scenarios_pass(self):
        for case in ('block', 'cn-close', 'disable'):
            with self.subTest(case=case):
                self.assertTrue(validate_permission_denial(*self.arguments(case))['passed'])

    def test_wrong_authorization_change_is_rejected(self):
        for case, field, value in [('block', 'block_count', 0),
                                   ('cn-close', 'cn_state', 'CN_ACTIVE'),
                                   ('disable', 'disabled', {'1': False, '2': False})]:
            args = self.arguments(case)
            args[1][field] = value
            with self.assertRaises(ValueError):
                validate_permission_denial(*args)

    def test_disable_requires_target_credentials_revoked_and_other_actor_retained(self):
        for field, identity, value in [('token_ids', '2', [2]), ('token_ids', '1', []),
                                       ('active_session_ids', '2', ['b']),
                                       ('active_session_ids', '1', [])]:
            args = self.arguments('disable')
            args[1][field][identity] = value
            with self.assertRaises(ValueError):
                validate_permission_denial(*args)

    def test_wrong_lock_writer_error_private_body_and_effect_change_fail(self):
        for index, field, value in [(3, 'lock_data', '2'), (8, 'committed', False),
                                     (8, 'kernel_executed', False), (8, 'status', 500),
                                     (2, 'status', 401), (2, 'private_marker_present', True),
                                     (1, 'message_ids', [7, 8])]:
            args = self.arguments('block')
            target = args[index][0] if index in (2, 3) else args[index]
            target[field] = value
            with self.assertRaises(ValueError):
                validate_permission_denial(*args)

    def test_unknown_scenario_and_missing_disabled_capture_fail(self):
        args = self.arguments('block')
        args[9] = 'arbitrary'
        with self.assertRaises(ValueError):
            validate_permission_denial(*args)
        args = self.arguments('block')
        del args[1]['disabled']
        with self.assertRaises(ValueError):
            validate_permission_denial(*args)

    def test_cases_require_explicit_distinct_pairs(self):
        cfg = {'scenarios': {name: {'participants': pair} for name, pair in
                            [('block', [1, 2]), ('cn-close', [3, 4]), ('disable', [1, 3])]}}
        self.assertEqual(probe_cases(cfg), ('block', 'cn-close', 'disable'))
        self.assertEqual(probe_cases({}), ('duplicate', 'revocation'))
        for pair in ([1, 1], [True, 2], [1], [0, 2]):
            bad = copy.deepcopy(cfg)
            bad['scenarios']['block']['participants'] = pair
            with self.assertRaises(ValueError):
                probe_cases(bad)
        del cfg['scenarios']['disable']
        with self.assertRaises(ValueError):
            probe_cases(cfg)

    def test_replay_comparison_includes_matrix_authorization_and_credentials(self):
        state = self.arguments('disable')[1]
        for field, value in [('disabled', {'1': False, '2': False}), ('block_count', 1),
                              ('token_ids', {'1': [1], '2': [2]}),
                              ('active_session_ids', {'1': ['a'], '2': ['b']})]:
            after = copy.deepcopy(state)
            after[field] = value
            self.assertNotEqual(persisted_state(state), persisted_state(after))

    def test_postcommit_denials_cannot_leak_success_fields_or_hide_worker_errors(self):
        for status in (404, 401):
            valid = reply(21, denied=True)
            valid['status'] = status
            validate_denied_response(valid, status)
            for field, value in [('id', 7), ('client_message_id', 'old-key'),
                                  ('idempotent_replay', True), ('private_marker_present', True),
                                  ('kernel_executed', False), ('transaction_level', 1),
                                  ('session_isolation', 'READ-COMMITTED'), ('error', 'failed')]:
                bad = dict(valid, **{field: value})
                with self.subTest(status=status, field=field), self.assertRaises(ValueError):
                    validate_denied_response(bad, status)


if __name__ == '__main__':
    unittest.main()
