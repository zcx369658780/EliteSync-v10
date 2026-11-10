"""Synthetic framing tests. This module never starts SSH."""

import sys
import unittest

sys.dont_write_bytecode = True
from run import FIELD_LIMIT, TAG, classify, decode_frames


def framed(listing="AES-256-GCM", presence=0, list_exit=0):
    return (f"{TAG}:P:{presence}\n{TAG}:L:{len(listing)}\n{listing}\n"
            f"{TAG}:LE:{list_exit}\n")


class FramingTests(unittest.TestCase):
    def test_complete_list_and_missing_target(self):
        self.assertEqual("LISTED", classify(framed())["aes_256_gcm_listing"])
        self.assertEqual("NOT_LISTED", classify(framed("AES-128-GCM"))["aes_256_gcm_listing"])

    def test_missing_mixed_and_extra_frames_fail(self):
        for raw in (framed()[:-2], "junk" + framed(), framed() + "junk",
                    framed().replace(f"{TAG}:P:0\n", "")):
            with self.subTest(size=len(raw)), self.assertRaises(ValueError):
                decode_frames(raw)

    def test_declared_truncation_and_oversize_fail(self):
        with self.assertRaises(ValueError):
            decode_frames(framed().replace(f"{TAG}:L:11\n", f"{TAG}:L:12\n"))
        with self.assertRaises(ValueError):
            decode_frames(framed("A" * (FIELD_LIMIT + 1)))

    def test_nonzero_exits_remain_unknown(self):
        self.assertEqual("UNKNOWN", classify(framed(list_exit=1))["aes_256_gcm_listing"])
        self.assertEqual("UNKNOWN", classify(framed(presence=1))["aes_256_gcm_listing"])

    def test_unrecognized_line_reports_category_without_content(self):
        result = classify(framed("AES-256-GCM is supported"))
        self.assertEqual("UNKNOWN", result["aes_256_gcm_listing"])
        self.assertEqual("OTHER", result["first_bad_line_category"])
        self.assertEqual(len("AES-256-GCM is supported"), result["first_bad_line_length"])


if __name__ == "__main__":
    unittest.main()
