#!/usr/bin/env python3
"""Source-scoped fixed 截路/空亡 labels, distinct from Zhongzhou roles.

This reference consumes a sexagenary cycle index, not a civil calendar date.
It imports no engine, product, vendor, actual output or external runtime.
The parent knows actual output; this author has not read it (NOT_BLIND).
"""
import hashlib
from pathlib import Path


STEMS = "甲乙丙丁戊己庚辛壬癸"
BRANCHES = "子丑寅卯辰巳午未申酉戌亥"

# Named ten-stem lookup into the five classical paired locations.
PAIRED_LOCATIONS = {
    "申酉": ("申", "酉"),
    "午未": ("午", "未"),
    "辰巳": ("辰", "巳"),
    "寅卯": ("寅", "卯"),
    "子丑": ("子", "丑"),
}
STEM_TO_PAIR = {
    "甲": "申酉", "己": "申酉",
    "乙": "午未", "庚": "午未",
    "丙": "辰巳", "辛": "辰巳",
    "丁": "寅卯", "壬": "寅卯",
    "戊": "子丑", "癸": "子丑",
}


def calculate(cycle_index):
    """Return fixed labels and a separate selected Zhongzhou regular member."""
    if type(cycle_index) is not int or not 0 <= cycle_index < 60:
        raise ValueError("sexagenary cycle index must be an integer in 0..59")

    stem_index = cycle_index % 10
    stem = STEMS[stem_index]
    jielu, kongwang = PAIRED_LOCATIONS[STEM_TO_PAIR[stem]]
    # Positive/regular role follows polarity; fixed split labels do not.
    regular = next(
        member for member in (jielu, kongwang)
        if BRANCHES.index(member) % 2 == stem_index % 2
    )
    return {
        "cycle_index": cycle_index,
        "year_label": stem + BRANCHES[cycle_index % 12],
        "jielu_branch": jielu,
        "kongwang_branch": kongwang,
        "regular_branch": regular,
        "selected_zhongzhou_regular_member": regular,
        "status": "SOURCE_SCOPED_LABEL_CONVENTION_AND_COMMENTARY",
        "blind": False,
        "blindness": "NOT_BLIND_PARENT_KNOWS_ACTUAL_AUTHOR_DID_NOT_READ_ACTUAL",
        "source_manifest": "ziwei_void_label_sources.json",
        "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    }
