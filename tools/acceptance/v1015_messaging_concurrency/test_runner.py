import copy
import unittest
import pathlib
import tempfile
from unittest.mock import patch

from run import abort_probe, persisted_state, publish_stop


class PersistedStateTests(unittest.TestCase):
    def setUp(self):
        self.state = dict(message_ids=[1], message_hashes={'1': 'a'*64},
            client_message_ids={'1': 'key'}, notification_ids=[1], message_event_ids=[1],
            attachment_ids=[], cn_state='CN_ACTIVE', mc_states=['MC_REVOKED']*2)

    def test_distinct_snapshot_connections_and_times_do_not_fake_effect_changes(self):
        before = dict(self.state, connection_id=11, php_monotonic_ns=100, db_utc='first')
        after = dict(self.state, connection_id=12, php_monotonic_ns=200, db_utc='second')
        self.assertEqual(persisted_state(before), persisted_state(after))

    def test_message_or_authorization_mutation_is_still_detected(self):
        for field, value in [('message_ids', [1, 2]), ('mc_states', ['MC_ACTIVE']*2)]:
            after = copy.deepcopy(self.state)
            after[field] = value
            self.assertNotEqual(persisted_state(self.state), persisted_state(after))

    def test_missing_capture_cannot_be_silently_ignored(self):
        del self.state['notification_ids']
        with self.assertRaises(KeyError):
            persisted_state(self.state)


class AbortTests(unittest.TestCase):
    def test_published_stop_is_complete_and_has_no_temporary_leftovers(self):
        import json
        with tempfile.TemporaryDirectory(prefix='v1015-probe-unit-') as folder:
            root = pathlib.Path(folder)
            value = {'cleanup_deadline_monotonic': 123.5, 'reason': 'complete'}
            self.assertTrue(publish_stop(root / 'stop.json', value))
            self.assertEqual(json.loads((root / 'stop.json').read_bytes()), value)
            self.assertEqual([path.name for path in root.iterdir()], ['stop.json'])

    def test_existing_stop_is_preserved(self):
        with tempfile.TemporaryDirectory(prefix='v1015-probe-unit-') as folder:
            path = pathlib.Path(folder) / 'stop.json'
            path.write_text('{"first":true}', encoding='utf-8')
            self.assertFalse(publish_stop(path, {'second': True}))
            self.assertEqual(path.read_text(), '{"first":true}')

    def test_stop_failure_does_not_skip_cancel_or_later_clients(self):
        class Client:
            def __init__(self, fails=False): self.called = False; self.fails = fails
            def poll(self): return None
            def terminate(self):
                self.called = True
                if self.fails: raise OSError('termination fixture')
        with tempfile.TemporaryDirectory(prefix='v1015-probe-unit-') as folder:
            root = pathlib.Path(folder)
            (root / 'duplicate').mkdir()
            clients = [Client(True), Client()]
            original = ValueError('original probe failure')
            with patch('run.publish_stop', side_effect=OSError('disk fixture')):
                errors = abort_probe(root / 'stop.json', root, clients, original)
            self.assertTrue(all(client.called for client in clients))
            self.assertTrue((root / 'duplicate/cancel').exists())
            self.assertEqual(len(errors), 2)
            self.assertTrue(hasattr(original, 'probe_cleanup_deadline_monotonic'))


if __name__ == '__main__':
    unittest.main()
