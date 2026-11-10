"""Pure gate tests; no OpenSSL invocation or filesystem material."""

import hashlib
import sys
import unittest

sys.dont_write_bytecode = True
from run import PLAIN_SHA256, SIZE, gate


class ConsumerGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.plain = bytearray(i % 251 for i in range(SIZE))
        assert hashlib.sha256(cls.plain).hexdigest().upper() == PLAIN_SHA256
        cls.cipher = bytearray(b"synthetic-ciphertext-only-for-pure-gate-tests")
        cls.length = len(cls.cipher)
        cls.digest = hashlib.sha256(cls.cipher).hexdigest().upper()

    def check(self, label, cipher, code, staged, error, release):
        result = gate(label, cipher, self.length, self.digest, code, staged, error, release)
        self.assertEqual("PASS", result["status"])
        self.assertEqual((1, SIZE) if release else (0, 0),
                         (result["consumer_calls"], result["consumer_bytes"]))
        self.assertTrue(result["buffer_cleared"])
        if staged is not None:
            self.assertFalse(any(staged))
        return result

    def test_normal_and_forged_success_identity(self):
        self.check("normal", self.cipher, 0, bytearray(self.plain), None, True)
        tampered = bytearray(self.cipher)
        tampered[-1] ^= 1
        result = self.check("forged_success", tampered, 0, bytearray(self.plain), None, False)
        self.assertFalse(result["identity_match"])

    def test_nonzero_with_staged_bytes_and_truncation(self):
        self.check("nonzero_staged", self.cipher, 4, bytearray(self.plain), None, False)
        result = self.check("truncated", self.cipher[:-1], 0, bytearray(self.plain), None, False)
        self.assertFalse(result["identity_match"])

    def test_over_limit_timeout_and_incomplete_capture(self):
        for reason in ("CAPTURE_LIMIT", "TIMEOUT", "CAPTURE_EXCEPTION"):
            with self.subTest(reason=reason):
                self.check(reason, self.cipher, 0, bytearray(self.plain), reason, False)
        self.check("short_plaintext", self.cipher, 0, bytearray(self.plain[:-1]), None, False)
        wrong = bytearray(self.plain)
        wrong[-1] ^= 1
        self.check("wrong_digest", self.cipher, 0, wrong, None, False)


if __name__ == "__main__":
    unittest.main()
