"""Synthetic framing and bounded-capture checks; no SSH calls."""

import sys
import unittest

sys.dont_write_bytecode = True
from run import FIELD_LIMIT, TAG, classify, decode_frames


def framed(version="OpenSSL 3.0.13", listing="AES-256-GCM", exits=(0, 0, 0, 0)):
    p, ve, ce, le = exits
    return (f"{TAG}:P:{p}\n{TAG}:V:{len(version)}\n{version}\n"
            f"{TAG}:VE:{ve}\n{TAG}:C:{ce}\n"
            f"{TAG}:L:{len(listing)}\n{listing}\n{TAG}:LE:{le}\n")


class FramingTests(unittest.TestCase):
    def test_complete_synthetic_result(self):
        result = classify(framed())
        self.assertEqual("3.0.13", result["version"])
        self.assertEqual("LISTED", result["aes_256_gcm_listing"])
        self.assertEqual("NONE", result["first_failure_stage"])

    def test_complete_valid_list_without_target(self):
        self.assertEqual("NOT_LISTED", classify(framed(listing="AES-128-GCM"))["aes_256_gcm_listing"])

    def test_missing_or_mixed_frames_fail(self):
        for raw in (framed()[:-4], framed().replace(f"{TAG}:C:0\n", ""),
                    "junk" + framed(), framed() + "junk"):
            with self.subTest(raw_length=len(raw)), self.assertRaises(ValueError):
                decode_frames(raw)

    def test_declared_truncation_and_oversized_field_fail(self):
        raw = framed().replace(f"{TAG}:L:11\n", f"{TAG}:L:12\n")
        with self.assertRaises(ValueError):
            decode_frames(raw)
        with self.assertRaises(ValueError):
            decode_frames(framed(listing="A" * (FIELD_LIMIT + 1)))

    def test_nonzero_and_bad_format_remain_unknown(self):
        self.assertEqual("UNKNOWN", classify(framed(exits=(0, 0, 0, 1)))["aes_256_gcm_listing"])
        self.assertEqual("UNKNOWN", classify(framed(listing="AES-256-GCM is supported"))["aes_256_gcm_listing"])
        self.assertEqual("UNKNOWN", classify(framed(exits=(1, 0, 0, 0)))["aes_256_gcm_listing"])


if __name__ == "__main__":
    unittest.main()
