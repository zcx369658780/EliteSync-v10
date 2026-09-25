"""Pure synthetic frame and command tests; no SSH or certificate generation."""

import sys
import unittest

sys.dont_write_bytecode = True
from run import END, FIXED, FIXED_SHA256, REMOTE, TAG, parse_frame, ssh_command

PEM = b"-----BEGIN CMS-----\nYQ==\n-----END CMS-----"


def frame(payload=PEM, code=0):
    return TAG + str(code).encode() + b":" + str(len(payload)).encode() + b"\n" + payload + END


class FixedBoundaryTests(unittest.TestCase):
    def test_fixed_input_and_command(self):
        self.assertEqual(21, len(FIXED))
        self.assertEqual("9377120FCEF0E6143F500E7FDF934B1AC1F9F01BFDC873004BA80B162ACFFA97", FIXED_SHA256)
        command = ssh_command()
        self.assertEqual("root@101.133.161.203", command[-2])
        self.assertEqual(REMOTE, command[-1])
        for option in ("BatchMode=yes", "IdentitiesOnly=yes", "StrictHostKeyChecking=yes", "ConnectTimeout=8"):
            self.assertIn(option, command)
        self.assertIn("openssl cms -encrypt -binary -stream -aes-256-gcm", REMOTE)
        self.assertIn("-recip /dev/fd/3", REMOTE)
        self.assertNotIn("-decrypt", REMOTE)

    def test_complete_frames(self):
        self.assertEqual((0, PEM), parse_frame(frame()))
        self.assertEqual((1, b""), parse_frame(frame(b"", 1)))

    def test_reject_incomplete_extra_or_mixed_frames(self):
        examples = (
            b"", frame()[:-1], b"x" + frame(), frame() + b"x", frame() + frame(),
            frame().replace(b":" + str(len(PEM)).encode() + b"\n", b":1\n", 1),
            frame().replace(TAG + b"0", TAG + b"00", 1),
            frame().replace(END, b"\nAUTH61_END\r\n"), frame(b"not pem"),
            frame(PEM, 1),
        )
        for raw in examples:
            with self.subTest(length=len(raw)), self.assertRaises(ValueError):
                parse_frame(raw)


if __name__ == "__main__":
    unittest.main()
