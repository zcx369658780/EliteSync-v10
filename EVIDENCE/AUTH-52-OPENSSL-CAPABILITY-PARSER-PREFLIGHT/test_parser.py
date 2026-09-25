import unittest

from parser import LISTED, NOT_LISTED, UNKNOWN, parse_aes_256_gcm_listing, parse_openssl_version


class OpenSslCapabilityParserTests(unittest.TestCase):
    def test_extracts_version_from_explicit_openssl_line(self):
        self.assertEqual("3.0.13", parse_openssl_version(0, "OpenSSL 3.0.13 30 Jan 2024\n"))

    def test_version_accepts_case_difference(self):
        self.assertEqual("1.1.1w", parse_openssl_version(0, "openssl 1.1.1w 11 Sep 2023\n"))

    def test_version_rejects_nonzero_exit(self):
        self.assertEqual(UNKNOWN, parse_openssl_version(1, "OpenSSL 3.0.13\n"))

    def test_version_rejects_prose_and_malformed_values(self):
        self.assertEqual(UNKNOWN, parse_openssl_version(0, "version: OpenSSL 3.0.13\n"))
        self.assertEqual(UNKNOWN, parse_openssl_version(0, "OpenSSL unknown\n"))

    def test_version_rejects_empty_and_oversized_output(self):
        self.assertEqual(UNKNOWN, parse_openssl_version(0, ""))
        self.assertEqual(UNKNOWN, parse_openssl_version(0, "OpenSSL 3.0.13 " + "x" * 65_536))

    def test_cipher_target_is_listed_case_insensitively(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "Legacy:\n  aes-256-gcm\n"))

    def test_cipher_oid_alias_is_listed(self):
        self.assertEqual(LISTED, parse_aes_256_gcm_listing(0, "Provided:\n  id-aes256-GCM\n"))

    def test_cipher_exact_token_boundary_rejects_similar_algorithms(self):
        output = "AES-256-GCM-SIV\nX-AES-256-GCM\nAES-256-GCMX\n"
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, output))

    def test_cipher_nonzero_exit_is_unknown(self):
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(1, "AES-256-GCM\n"))

    def test_cipher_valid_list_without_target_is_not_listed(self):
        self.assertEqual(NOT_LISTED, parse_aes_256_gcm_listing(0, "AES-128-GCM\nCHACHA20-POLY1305\n"))

    def test_cipher_rejects_prose_and_partial_output_as_unknown(self):
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "AES-256-GCM is supported\n"))
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "AES-128-GCM\n...\n"))

    def test_cipher_rejects_empty_malformed_and_oversized_output(self):
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, ""))
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "AES_256_GCM\n"))
        self.assertEqual(UNKNOWN, parse_aes_256_gcm_listing(0, "AES-128-GCM\n" + "x" * 65_536))


if __name__ == "__main__":
    unittest.main()
