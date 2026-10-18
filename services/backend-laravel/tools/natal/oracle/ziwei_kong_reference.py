#!/usr/bin/env python3
"""Independent two-void pairs and selected Zhongzhou regular/secondary rule.

Only an explicit sexagenary year label is consumed. This is neither a civil
calendar converter nor an oracle for every historical/product display alias.
No product, vendor, actual output or third-party runtime is imported.
"""
import hashlib
import json
from pathlib import Path

STEMS = "甲乙丙丁戊己庚辛壬癸"
BRANCHES = "子丑寅卯辰巳午未申酉戌亥"
SOURCES = {
    "pair": {
        "url": "https://zh.wikisource.org/zh/紫微斗數全書/卷二",
        "scope": "截路空亡 paired branches; sexagenary-decade unpaired branches",
        "evidence": "CLASSICAL_TRANSCRIPTION_BASE_EDITION_UNVERIFIED",
    },
    "polarity": {
        "url": "https://www.guoxuedashi.com/a/22312bxfo/281042u.html",
        "section": "杂曜总论：截空、旬空",
        "scope": "Both void pairs: regular member has branch polarity equal to birth-year polarity",
        "evidence": "SELECTED_ZHONGZHOU_TRANSCRIPTION_EDITION_UNVERIFIED",
    },
    "corroboration": {
        "url": "https://www.ziweicn.com/show/3084.html",
        "section": "安截空诀、安旬空",
        "scope": "Explicit year-stem parity rule and ten-stem regular-member table; Xun follows same rule",
        "evidence": "MODERN_TRANSCRIPTION_COMMON_LINEAGE_NOT_EXCLUDED",
    },
}


def regular_pair(pair, stem):
    regular = [branch for branch in pair if branch % 2 == stem % 2]
    if len(regular) != 1:
        raise ValueError("registered pair must have one branch of each polarity")
    return {"pair": [{"index": b, "branch": BRANCHES[b]} for b in pair],
            "regular": {"index": regular[0], "branch": BRANCHES[regular[0]]},
            "secondary": {"index": next(b for b in pair if b != regular[0]),
                          "branch": next(BRANCHES[b] for b in pair if b != regular[0])}}


def calculate(cycle_index):
    """cycle_index is 0..59 for 甲子..癸亥, never a Gregorian year."""
    if type(cycle_index) is not int or not 0 <= cycle_index < 60:
        raise ValueError("sexagenary cycle index must be an integer in 0..59")
    stem, branch = cycle_index % 10, cycle_index % 12
    # The classical five paired locations run backwards from 申/酉 to 子/丑.
    jie_start = 8 - 2 * (stem % 5)
    # Ten stems exhaust ten consecutive branches; the other two are 旬空.
    used = {(branch - stem + offset) % 12 for offset in range(10)}
    xun_pair = [b for b in range(12) if b not in used]
    return {"cycle_index": cycle_index, "year_label": STEMS[stem] + BRANCHES[branch],
            "status": "SOURCE_SCOPED_RULE_REFERENCE_NOT_ACCEPTANCE", "blind": False,
            "jie": regular_pair([jie_start, jie_start + 1], stem),
            "xun": regular_pair(xun_pair, stem), "sources": SOURCES,
            "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            "alias_limit": "Regular/secondary roles do not independently prove which product split label is called 截路 or 空亡.",
            "limits": ["Selected Zhongzhou polarity rule, not all-school historical equivalence.",
                       "No civil date, lunar conversion, leap month or year-boundary assertion.",
                       "No predictive efficacy assertion; no interpretation or matching signal."]}
