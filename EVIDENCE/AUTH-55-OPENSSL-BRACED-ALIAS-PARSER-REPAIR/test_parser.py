"""Only synthetic strings; no host or server access."""

import sys
import unittest

sys.dont_write_bytecode = True
from parser import (
    LISTED, NOT_LISTED, UNKNOWN, MAX_OUTPUT_CHARS,
    parse_aes_256_gcm_listing, parse_openssl_version,
)


class OpenSslParserTests(unittest.TestCase):
    def test_version_interface(self):
        self.assertEqual("3.0.13", parse_openssl_version(0, "OpenSSL 3.0.13 30 Jan 2024\n"))
        self.assertEqual(UNKNOWN, parse_openssl_version(0, "OpenSSL 3.0.13\nOpenSSL 3.0.13\n"))
        self.assertEqual(UNKNOWN, parse_openssl_version(1, "OpenSSL 3.0.13\n"))

    def test_bare_and_oid_formats(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "Legacy:\nAES-128-GCM, aes-256-gcm\n"))
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "Provided:\n{ 2.16.840.1, id-aes256-GCM } @ default\n"))

    def test_alias_format_checks_both_names(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "aes-256-gcm => OTHER\n"))
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "OTHER => id-aes256-GCM\n"))

    def test_provider_format_checks_algorithm_only(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "id-aes256-gcm @ default\n"))
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, "AES-128-GCM @ aes-256-gcm\n"))

    def test_valid_mixed_without_target_is_not_listed(self):
        value = "Legacy:\nAES-128-GCM\nOTHER => CHACHA20\nCHACHA20 @ default\n{ 1.2.3, AES-128-CBC } @ default\n{ AES-128-CBC, alias } @ default\n"
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, value))

    def test_braced_alias_target_in_any_name(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "{ AES-256-GCM, alias } @ default\n"))
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "{ other, ID-AES256-GCM, third } @ default\n"))

    def test_braced_alias_ignores_provider_and_similar_names(self):
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, "{ AES-128-GCM, alias } @ aes-256-gcm\n"))
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, "{ AES-256-GCM-SIV, X-AES-256-GCM } @ default\n"))

    def test_braced_alias_malformed_and_empty_are_unknown(self):
        for value in ("{} @ default\n", "{ } @ default\n", "{ AES-256-GCM } @ default\n",
                      "{ AES-256-GCM, } @ default\n", "{ AES-256-GCM; alias } @ default\n",
                      "{ AES-256-GCM, alias } -> default\n", "{ AES-256-GCM, alias } @\n",
                      "{ AES-256-GCM, alias } @ default extra\n"):
            with self.subTest(value=value):
                self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, value))

    def test_similar_names_and_prose_do_not_match(self):
        value = "AES-256-GCM-SIV\nX-AES-256-GCM\nAES-256-GCMX\n"
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, value))
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "AES-256-GCM is supported\n"))

    def test_wrong_separators_or_partial_lines_are_unknown(self):
        for value in ("AES-256-GCM -> OTHER\n", "AES-256-GCM =>\n",
                      "AES-256-GCM @\n", "AES-256-GCM @ default extra\n",
                      "AES-128-GCM\n...\n", "AES-256-GCM=>OTHER\n"):
            with self.subTest(value=value):
                self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, value))

    def test_nonzero_empty_nul_and_oversize_are_unknown(self):
        for code, value in ((1, "AES-256-GCM\n"), (0, ""),
                            (0, "AES-256-GCM\x00"),
                            (0, "AES-256-GCM\n" + "A" * MAX_OUTPUT_CHARS)):
            with self.subTest(code=code, length=len(value)):
                self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(code, value))

    def test_section_without_algorithm_is_unknown(self):
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "Provided:\n"))


if __name__ == "__main__":
    unittest.main()
