"""Synthetic-only tests for the bounded migration-status parser."""

import unittest

from migration_status_parser import MAX_INPUT_BYTES, TARGETS, parse_migration_status


def synthetic_output() -> str:
    return (
        "\nMigration name ...................... Batch / Status\n"
        f"{TARGETS[0]} ........ [3] Ran\n"
        f"{TARGETS[1]}    Pending\n"
        f"{TARGETS[2]} . Pending\n"
        f"{TARGETS[3]} ........... [11] Ran\n"
        "2026_01_02_030405_create_demo_extra ... Pending\n\n"
    )


class MigrationStatusParserTest(unittest.TestCase):
    def assert_safe_error(self, raw: bytes | str, category: str) -> None:
        self.assertEqual(parse_migration_status(raw), {"ok": False, "error": category})

    def test_complete_synthetic_output_returns_only_fixed_targets_and_counts(self) -> None:
        result = parse_migration_status(synthetic_output().encode("utf-8"))

        self.assertEqual(
            result,
            {
                "ok": True,
                "targets": {
                    TARGETS[0]: "Ran",
                    TARGETS[1]: "Pending",
                    TARGETS[2]: "Pending",
                    TARGETS[3]: "Ran",
                },
                "total": 5,
                "ran": 2,
                "pending": 3,
            },
        )
        self.assertNotIn("2026_01_02_030405_create_demo_extra", result["targets"])

    def test_crlf_and_variable_leaders_are_accepted(self) -> None:
        raw = synthetic_output().replace("\n", "\r\n")
        result = parse_migration_status(raw)

        self.assertTrue(result["ok"])
        self.assertEqual((result["total"], result["ran"], result["pending"]), (5, 2, 3))

    def test_ansi_other_controls_and_non_ascii_are_rejected_without_partial_results(self) -> None:
        raw = synthetic_output()
        for unsafe in ("\x1b[32m", "\x00", "\x7f", "秘密"):
            with self.subTest(unsafe=repr(unsafe)):
                self.assert_safe_error(raw.replace("[3] Ran", unsafe + "[3] Ran"), "UNSAFE_OUTPUT")

    def test_duplicate_migration_name_is_rejected(self) -> None:
        raw = synthetic_output().replace(
            f"{TARGETS[1]}    Pending\n",
            f"{TARGETS[1]}    Pending\n{TARGETS[1]} .... [8] Ran\n",
        )
        self.assert_safe_error(raw, "DUPLICATE_ROW")

    def test_missing_target_is_rejected_without_counts(self) -> None:
        raw = synthetic_output().replace(f"{TARGETS[3]} ........... [11] Ran\n", "")
        self.assert_safe_error(raw, "TARGET_MISSING")

    def test_unknown_status_and_bad_batch_are_rejected(self) -> None:
        raw = synthetic_output()
        for replacement in ("Applied", "[0] Ran", "[x] Ran", "[3] ran"):
            with self.subTest(replacement=replacement):
                self.assert_safe_error(raw.replace("[3] Ran", replacement), "MALFORMED_OUTPUT")

    def test_extra_text_duplicate_header_or_internal_blank_line_is_rejected(self) -> None:
        raw = synthetic_output()
        for altered in (
            raw.replace("\n\n", "\nNOTICE: synthetic-only\n\n"),
            raw.replace("Migration name ...................... Batch / Status\n", "Migration name ...................... Batch / Status\nMigration name ...................... Batch / Status\n"),
            raw.replace(f"{TARGETS[1]}    Pending\n", f"{TARGETS[1]}    Pending\n\n"),
        ):
            with self.subTest(altered=altered[:35]):
                self.assert_safe_error(altered, "MALFORMED_OUTPUT")

    def test_invalid_utf8_and_unencodable_string_are_rejected(self) -> None:
        self.assert_safe_error(b"\xff" + synthetic_output().encode("utf-8"), "INVALID_UTF8")
        self.assert_safe_error("\ud800" + synthetic_output(), "INVALID_UTF8")

    def test_oversize_bytes_and_string_are_rejected(self) -> None:
        self.assert_safe_error(b"A" * (MAX_INPUT_BYTES + 1), "OUTPUT_TOO_LARGE")
        self.assert_safe_error("A" * (MAX_INPUT_BYTES + 1), "OUTPUT_TOO_LARGE")

    def test_folded_or_truncated_output_is_rejected(self) -> None:
        raw = synthetic_output()
        self.assert_safe_error(raw.replace(TARGETS[0], TARGETS[0][:20] + "\n" + TARGETS[0][20:]), "MALFORMED_OUTPUT")
        self.assert_safe_error(raw[:-1], "INCOMPLETE_OUTPUT")
        self.assert_safe_error(raw.rstrip("\n"), "INCOMPLETE_OUTPUT")

    def test_missing_header_and_no_rows_are_rejected(self) -> None:
        raw = synthetic_output()
        self.assert_safe_error(raw.replace("Migration name ...................... Batch / Status\n", ""), "MALFORMED_OUTPUT")
        self.assert_safe_error("\nMigration name .... Batch / Status\n\n", "MALFORMED_OUTPUT")
        self.assert_safe_error("No migrations found\n\n", "MALFORMED_OUTPUT")

    def test_unsupported_type_and_standalone_carriage_return_are_rejected(self) -> None:
        self.assert_safe_error(123, "INVALID_INPUT")  # type: ignore[arg-type]
        self.assert_safe_error(synthetic_output().replace("\n", "\r", 1), "UNSAFE_OUTPUT")


if __name__ == "__main__":
    unittest.main()
