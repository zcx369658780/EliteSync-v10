import copy
import subprocess
import unittest

import sandbox_owned_session_cleanup as cleanup


class OwnedSessionTests(unittest.TestCase):
    def setUp(self):
        self.config = r'C:\Owned\Task\qualification.wsb'
        self.launch = {'pid': 101, 'creationUtc': '2026-11-04T00:00:00Z'}
        self.rows = [dict(ProcessId=102, ParentProcessId=101, Name='WindowsSandboxRemoteSession.exe',
            CreationDate='2026-11-04T00:00:00.1Z', ExecutablePath=r'C:\Package\WindowsSandboxRemoteSession.exe',
            CommandLine='session.exe "' + self.config + '"'),
            dict(ProcessId=103, ParentProcessId=102, Name='WindowsSandboxServer.exe',
            CreationDate='2026-11-04T00:00:00.2Z', ExecutablePath=r'C:\Package\WindowsSandboxServer.exe',
            CommandLine='server.exe session')]
        self.recorded = copy.deepcopy(self.rows)

    def bind(self):
        return cleanup.bind_owned_pair(self.launch, self.recorded, self.rows, self.config)

    def test_exact_owned_pair_only_renders_held_handle_termination(self):
        bound = self.bind()
        self.assertEqual((bound['session_pid'], bound['server_pid']), (102, 103))
        command = cleanup.render_cleanup(self.launch, self.recorded, self.rows, self.config)
        self.assertIn('$heldsession = $session.Handle', command)
        self.assertIn('Stop-Process -InputObject $session', command)
        self.assertNotIn('Stop-Process -Name', command)
        self.assertNotIn('Start-Process', command)

    def test_wrong_parent_birth_path_or_command_cannot_bind(self):
        for key, value in [('ParentProcessId', 999), ('ProcessId', True),
            ('CreationDate', '2026-11-04T00:01:00Z'), ('CreationDate', '2026-11-04T00:00:00'),
            ('ExecutablePath', r'C:\Other\WindowsSandboxRemoteSession.exe'),
            ('CommandLine', 'session.exe ' + self.config + '-other')]:
            original = copy.deepcopy(self.rows)
            self.rows[0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError): self.bind()
            self.rows = original

    def test_concurrent_session_or_duplicate_is_not_owned(self):
        for extra in [copy.deepcopy(self.rows[0]), {'Name': 'WindowsSandboxClient.exe', 'ProcessId': 104}]:
            self.rows.append(extra)
            with self.assertRaises(ValueError): self.bind()
            self.rows.pop()
        self.rows[1]['ProcessId'] = self.rows[0]['ProcessId']
        with self.assertRaises(ValueError): self.bind()

    def test_recorded_identity_and_child_parent_are_mandatory(self):
        self.rows[1]['ParentProcessId'] = 999
        self.recorded = copy.deepcopy(self.rows)
        with self.assertRaises(ValueError): self.bind()
        self.setUp()
        self.rows[0]['ParentProcessId'] = 999
        self.recorded = copy.deepcopy(self.rows)
        with self.assertRaises(ValueError): self.bind()

    def test_exact_quoted_config_handles_spaces_and_apostrophes(self):
        self.config = r"C:\Owned\Owner's task\qualification.wsb"
        self.rows[0]['CommandLine'] = 'session.exe "' + self.config + '"'
        self.recorded = copy.deepcopy(self.rows)
        command = cleanup.render_cleanup(self.launch, self.recorded, self.rows, self.config)
        self.assertIn("Owner''s task", command)
        self.assertNotIn('RunAs', command)

    def test_embedded_config_in_a_larger_quoted_argument_is_not_a_token(self):
        self.rows[0]['CommandLine'] = 'session.exe "prefix ' + self.config + ' suffix"'
        self.recorded = copy.deepcopy(self.rows)
        with self.assertRaises(ValueError): self.bind()

    def test_windows_quote_and_backslash_roundtrip(self):
        for arguments in [['session.exe', '', self.config],
            [r'C:\Program Files\Session.exe', 'quoted "value"', self.config],
            ['session.exe', 'C:\\path with spaces\\', 'a\\\\"b', self.config]]:
            with self.subTest(arguments=arguments):
                self.assertEqual(cleanup.windows_arguments(subprocess.list2cmdline(arguments)), arguments)


if __name__ == '__main__':
    unittest.main()
