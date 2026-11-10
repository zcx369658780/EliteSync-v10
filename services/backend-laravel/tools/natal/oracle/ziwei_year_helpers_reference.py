"""Source-derived natal year helpers for a selected modern rule profile.

This reference is not an all-school certification or an acceptance verdict.
Its documentary basis and alternatives are recorded in the adjacent manifest.
No product implementation, seed case, or observed product output is used here.
"""

from hashlib import sha256
from pathlib import Path


BRANCH_NAMES = ("子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥")
ORIGIN = "natal_birth_year_branch"


def _walk_from_zi(start_branch: int, direction: int, year_branch: int) -> int:
    """Place 子 at the start palace, then walk to the birth-year branch."""
    palace = start_branch
    for _ in range(year_branch):
        palace = (palace + direction) % len(BRANCH_NAMES)
    return palace


def calculate(year_branch: int) -> dict[str, dict[str, int | str]]:
    """Return 月德, 天德, 年解 using birth-year 子=0 through 亥=11.

    Selected rules: 月德 starts at 巳 and walks forward; 天德 starts at
    酉 and walks forward; 年解 starts at 戌 and walks backward. 月解 and
    annual/transiting 年解 are outside this natal-only reference.
    """
    if type(year_branch) is not int:
        raise TypeError("year_branch must be an int, excluding bool")
    if not 0 <= year_branch < len(BRANCH_NAMES):
        raise ValueError("year_branch must be between 0 and 11 inclusive")

    positions = {}
    for label, start, direction in (("月德", 5, 1), ("天德", 9, 1), ("年解", 10, -1)):
        branch = _walk_from_zi(start, direction, year_branch)
        positions[label] = {
            "branch_index": branch,
            "branch_name": BRANCH_NAMES[branch],
            "origin": ORIGIN,
        }
    return positions


def source_sha256() -> str:
    """Hash both reference files, including source bytes and manifest bytes.

    Names and byte lengths frame each payload. The digest is computed rather
    than embedded in either hashed file, avoiding a self-referential digest.
    It identifies these local artifacts; it does not authenticate web sources.
    """
    root = Path(__file__).resolve().parent
    digest = sha256()
    for name in ("ziwei_year_helpers_reference.py", "ziwei_year_helpers_sources.json"):
        payload = (root / name).read_bytes()
        digest.update(name.encode("utf-8") + b"\0")
        digest.update(str(len(payload)).encode("ascii") + b"\0")
        digest.update(payload)
    return digest.hexdigest()
