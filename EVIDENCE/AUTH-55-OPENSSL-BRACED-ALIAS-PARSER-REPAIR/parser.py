"""Pure, bounded OpenSSL output parsers for synthetic format preflight."""

from __future__ import annotations

import re
from enum import Enum
from typing import Final


MAX_OUTPUT_CHARS: Final = 65_536
UNKNOWN: Final = "UNKNOWN"


class CipherListingStatus(str, Enum):
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
_PLAIN_ALGORITHM_LINE = re.compile(rf"^({_NAME}(?:\s*,\s*{_NAME})*)$")
_SECTION_LINE = re.compile(r"^(?:Legacy|Provided):$", re.IGNORECASE)
_PROVIDED_LINE = re.compile(
    rf"^\{{\s*\d+(?:\.\d+)+(?:\s*,\s*{_NAME})*\s*\}}\s*@\s*[A-Za-z0-9_-]+$"
)
_BRACED_ALIAS_LINE = re.compile(
    rf"^\{{\s*(?P<names>{_NAME}(?:\s*,\s*{_NAME})+)\s*\}}\s+@\s+(?P<provider>[A-Za-z0-9_-]+)$"
)
_ALIAS_LINE = re.compile(rf"^(?P<alias>{_NAME})\s+=>\s+(?P<canonical>{_NAME})$")
_PROVIDER_LINE = re.compile(rf"^(?P<name>{_NAME})\s+@\s+(?P<provider>[A-Za-z0-9_-]+)$")
_TARGET_NAMES: Final = frozenset({"aes-256-gcm", "id-aes256-gcm"})


def _usable_output(output: object) -> str | None:
    if not isinstance(output, str) or not output or len(output) > MAX_OUTPUT_CHARS:
        return None
    if "\x00" in output:
        return None
    return output.replace("\r\n", "\n").replace("\r", "\n")


def parse_openssl_version(exit_code: object, output: object) -> str:
    """Return one explicit version token, or UNKNOWN on ambiguity."""
    if exit_code != 0:
        return UNKNOWN
    normalized = _usable_output(output)
    if normalized is None:
        return UNKNOWN
    matches = [_VERSION_LINE.fullmatch(line) for line in normalized.split("\n") if line.strip()]
    confirmed = [match.group("version") for match in matches if match]
    return confirmed[0] if len(matches) == 1 and len(confirmed) == 1 else UNKNOWN


def _algorithm_names(line: str) -> tuple[str, ...] | None:
    """Extract only algorithm names from one fully recognized list line."""
    match = _ALIAS_LINE.fullmatch(line)
    if match:
        return match.group("alias"), match.group("canonical")
    match = _PROVIDER_LINE.fullmatch(line)
    if match:
        return (match.group("name"),)
    match = _PROVIDED_LINE.fullmatch(line)
    if match:
        inside = line.split("}", 1)[0][1:]
        return tuple(part.strip() for part in inside.split(",")[1:])
    match = _BRACED_ALIAS_LINE.fullmatch(line)
    if match:
        return tuple(part.strip() for part in match.group("names").split(","))
    match = _PLAIN_ALGORITHM_LINE.fullmatch(line)
    if match:
        return tuple(part.strip() for part in line.split(","))
    return None


def parse_aes_256_gcm_listing(exit_code: object, output: object) -> CipherListingStatus:
    """Classify a syntactically valid list, without claiming server support.

    The caller must separately prove that its capture was complete. NOT_LISTED
    describes only this supplied, parseable list.
    """
    if exit_code != 0:
        return CipherListingStatus.UNKNOWN
    normalized = _usable_output(output)
    if normalized is None:
        return CipherListingStatus.UNKNOWN
    saw_algorithm = False
    saw_target = False
    for line in normalized.split("\n"):
        line = line.strip()
        if not line:
            continue
        if _SECTION_LINE.fullmatch(line):
            continue
        names = _algorithm_names(line)
        if names is None:
            return CipherListingStatus.UNKNOWN
        saw_algorithm = True
        saw_target |= any(name.casefold() in _TARGET_NAMES for name in names)
    if not saw_algorithm:
        return CipherListingStatus.UNKNOWN
    return CipherListingStatus.LISTED if saw_target else CipherListingStatus.NOT_LISTED
