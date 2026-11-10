"""Pure parsers for bounded OpenSSL capability observations.

The functions intentionally accept only already-captured command stdout and an
exit code.  They do not execute commands or inspect the host environment.
"""

from __future__ import annotations

import re
from enum import Enum
from typing import Final


MAX_OUTPUT_CHARS: Final = 65_536
UNKNOWN: Final = "UNKNOWN"


class CipherListingStatus(str, Enum):
    """A conservative classification of one captured cipher-list result."""

    LISTED = "LISTED"
    NOT_LISTED = "NOT_LISTED"
    UNKNOWN = UNKNOWN


LISTED: Final = CipherListingStatus.LISTED
NOT_LISTED: Final = CipherListingStatus.NOT_LISTED

_VERSION_LINE = re.compile(
    r"^\s*OpenSSL\s+(?P<version>\d+\.\d+\.\d+(?:[a-z]+)?)\b(?:\s+.*)?$",
    re.IGNORECASE,
)
_NAME = r"[A-Za-z][A-Za-z0-9-]*"
_PLAIN_ALGORITHM_LINE = re.compile(rf"^{_NAME}(?:\s*,\s*{_NAME})*$")
_SECTION_LINE = re.compile(r"^(?:Legacy|Provided):$", re.IGNORECASE)
_PROVIDED_LINE = re.compile(
    rf"^\{{\s*\d+(?:\.\d+)+(?:\s*,\s*{_NAME})*\s*\}}\s*@\s*[A-Za-z0-9_-]+$"
)
_TARGET_NAMES: Final = frozenset({"aes-256-gcm", "id-aes256-gcm"})


def _usable_output(output: object) -> str | None:
    if not isinstance(output, str) or not output or len(output) > MAX_OUTPUT_CHARS:
        return None
    if "\x00" in output:
        return None
    return output.replace("\r\n", "\n").replace("\r", "\n")


def parse_openssl_version(exit_code: object, output: object) -> str:
    """Return a confirmed OpenSSL version token, otherwise ``UNKNOWN``.

    A version is trusted only when a successful command contains exactly one
    explicit OpenSSL version line.  Other text, malformed values, empty input,
    or oversized output deliberately remain unknown.
    """

    if exit_code != 0:
        return UNKNOWN
    normalized = _usable_output(output)
    if normalized is None:
        return UNKNOWN

    matches = [_VERSION_LINE.fullmatch(line) for line in normalized.split("\n") if line.strip()]
    confirmed = [match.group("version") for match in matches if match]
    return confirmed[0] if len(matches) == 1 and len(confirmed) == 1 else UNKNOWN


def _is_complete_cipher_list(output: str) -> bool:
    """Recognize the bounded, line-oriented formats accepted for this preflight."""

    lines = [line.strip() for line in output.split("\n") if line.strip()]
    if not lines:
        return False
    saw_algorithm = False
    for line in lines:
        if _SECTION_LINE.fullmatch(line):
            continue
        if _PLAIN_ALGORITHM_LINE.fullmatch(line) or _PROVIDED_LINE.fullmatch(line):
            saw_algorithm = True
            continue
        return False
    return saw_algorithm


def parse_aes_256_gcm_listing(exit_code: object, output: object) -> CipherListingStatus:
    """Classify a captured cipher list without inferring server support.

    ``NOT_LISTED`` means only that a successful, complete list in the accepted
    local format contained no exact target token.  An unsupported command,
    malformed or partial-looking output, and every other ambiguity are
    ``UNKNOWN``.
    """

    if exit_code != 0:
        return CipherListingStatus.UNKNOWN
    normalized = _usable_output(output)
    if normalized is None or not _is_complete_cipher_list(normalized):
        return CipherListingStatus.UNKNOWN

    tokens = re.findall(_NAME, normalized.casefold())
    return (
        CipherListingStatus.LISTED
        if any(token in _TARGET_NAMES for token in tokens)
        else CipherListingStatus.NOT_LISTED
    )
