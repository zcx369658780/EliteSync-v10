"""Pure framing and command-boundary tests; no SSH or certificate process."""

import sys
import unittest

sys.dont_write_bytecode = True
from run import REMOTE, SSH_EXE, TAG, parse_frame, ssh_command


class FixedBoundaryTests(unittest.TestCase):
    def test_complete_success_and_failure_frames(self):
        self.assertEqual(0, parse_frame(TAG + b"0\n"))
        self.assertEqual(1, parse_frame(TAG + b"1\n"))

    def test_reject_extra_missing_mixed_and_noncanonical_bytes(self):
        for raw in (b"", TAG + b"0", b"x" + TAG + b"0\n", TAG + b"0\nX",
                    TAG + b"0\n" + TAG + b"0\n", TAG + b"00\n",
                    TAG + b"256\n", TAG + b"-1\n", TAG + b"a\n",
                    TAG + b"0\r\n"):
            with self.subTest(raw=raw), self.assertRaises(ValueError):
                parse_frame(raw)

    def test_fixed_ssh_boundary(self):
        command = ssh_command()
        self.assertEqual(str(SSH_EXE), command[0])
        self.assertEqual("root@101.133.161.203", command[-2])
        self.assertEqual(REMOTE, command[-1])
        self.assertIn("StrictHostKeyChecking=yes", command)
        self.assertIn("BatchMode=yes", command)
        self.assertIn("IdentitiesOnly=yes", command)
        self.assertIn("ConnectTimeout=8", command)
        self.assertIn("openssl x509 -in /dev/fd/3 -noout", REMOTE)
        self.assertNotIn("cms", REMOTE)


if __name__ == "__main__":
    unittest.main()
