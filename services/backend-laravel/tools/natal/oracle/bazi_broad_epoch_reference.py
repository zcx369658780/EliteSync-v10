"""Portable stdlib-only broad-epoch rule reference; NOT_BLIND.

Consumes an explicitly supplied, frozen independent solar-root document. No
product/vendor imports, astronomical calculation, network, or output-file writes.
Pre-1960 calendar tuples are model UT1 labels, never historical UTC instants.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True

ROOTS_SHA256 = "536cd93e7c79ee076bc30bc2c2fe8ca8c744986f25786d064e69c398f9cb3b8a"
SCHEMA = "elitesync.independent.solar-terms.v1"
SOURCE_ID = "SKYFIELD_DE440S_GEOCENTRIC_APPARENT_TRUE_ECLIPTIC_ROOT"
TIME_MODEL = "builtin Skyfield TT/DeltaT/leap tables; future leaps unknown; pre1960 UT1 label not historical UTC"
INDEPENDENCE = "Independent astronomical engine/data from lunar-php; author has read integration code, NOT_BLIND; shared with Western subsystem, not independent observations"
CHOSEN = (
    ("1901-01-01", "00:00:00"), ("1904-02-29", "23:00:00"),
    ("1912-12-31", "23:59:59"), ("1920-03-01", "00:00:00"),
    ("1933-04-30", "01:00:00"), ("1940-05-01", "02:59:59"),
    ("1948-06-30", "03:00:00"), ("1956-07-31", "04:59:59"),
    ("1959-08-31", "05:00:00"), ("1972-09-30", "06:59:59"),
    ("1980-10-31", "07:00:00"), ("1988-11-30", "08:59:59"),
    ("1996-12-31", "09:00:00"), ("1999-01-01", "10:59:59"),
    ("2000-02-29", "11:00:00"), ("2004-03-01", "12:59:59"),
    ("2012-04-30", "13:00:00"), ("2020-05-31", "14:59:59"),
    ("2028-06-30", "15:00:00"), ("2040-07-31", "16:59:59"),
    ("2060-08-31", "17:00:00"), ("2080-09-30", "19:00:00"),
    ("2096-10-31", "21:00:00"), ("2100-12-31", "23:59:59"),
)
LIMITATIONS = [
    "NOT_BLIND: New24 rule samples, not new nonauthor blind selection or official daily lunar calendar matrix",
    "Day labels use proleptic Gregorian ordinal relative to official HKO2024Jan1 JiaZi anchor; original USNO1801..2099 limit unchanged",
    "Pre1960 root labels are modelUT1, not historicalUTC; comparison subtracts a nominal fixed eight hours from the civil label, not a verified historical time-scale conversion",
    "Future leaps/model accuracy remain unknown; root numerical width is not physical error certification",
    "1960..1971 labels not used; sensitivity near actual term boundaries intentionally not claimed",
    "60s solar reference guard retained; roots shared with Western subsystem, no independent observations",
    "Inputs use fixed UTC+08 / Etc/GMT-8; Asia/Shanghai historical DST and IANA transitions are not validated",
    "Direct class comparison only; qiyun exact Gregorian dates/extensions/APP/HTTP/DB not asserted here",
    "Classical rule agreement is not scientific validation of fortune-telling; hidden-stem order/ranking and nayin aliases retain the original reference limits",
]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_terms(path: Path, expected_hash: str) -> tuple[dict, list[dict]]:
    if not re.fullmatch(r"[0-9a-f]{64}", expected_hash):
        raise ValueError("LOWERCASE_SHA256_REQUIRED")
    raw = path.read_bytes()
    actual_hash = hashlib.sha256(raw).hexdigest()
    if actual_hash != expected_hash or actual_hash != ROOTS_SHA256:
        raise ValueError("FROZEN_INDEPENDENT_TERM_FILE_HASH_MISMATCH")
    root = json.loads(raw)
    fixed = {
        "schema": SCHEMA, "reference_engine": "Skyfield1.55;DE440s",
        "coordinate": "geocentric apparent true ecliptic/equinox of date",
        "time_model": TIME_MODEL, "independence": INDEPENDENCE,
    }
    if any(root.get(key) != value for key, value in fixed.items()):
        raise ValueError("INDEPENDENT_TERM_SCHEMA_OR_TIME_MODEL_MISMATCH")
    if not re.fullmatch(r"[0-9a-f]{64}", root.get("kernel_sha256", "")):
        raise ValueError("INDEPENDENT_KERNEL_HASH_REQUIRED")
    if root.get("years") != [1900, 2101]:
        raise ValueError("FROZEN_TERM_YEAR_COVERAGE_MISMATCH")
    rows = root.get("rows")
    if not isinstance(rows, list) or len(rows) != 202 * 24:
        raise ValueError("COMPLETE_FROZEN_TERM_ROWS_REQUIRED")
    jie = []
    for row in rows:
        year = row.get("year")
        if type(year) is not int or not 1900 <= year <= 2101:
            raise ValueError("INVALID_TERM_YEAR")
        frame = "UT1_MODEL_LABEL_PRE_1960" if year < 1960 else "UTC_ERFA_TABLE_COMPATIBLE_ASSUMPTION"
        if row.get("civil_time_frame") != frame or row.get("source_id") != SOURCE_ID:
            raise ValueError("INDEPENDENT_ROOT_IDENTITY_OR_TIME_FRAME_MISMATCH")
        if row.get("uncertainty_seconds") != 60:
            raise ValueError("SIXTY_SECOND_GUARD_REQUIRED")
        calendar = row.get("calendar")
        if not isinstance(calendar, list) or len(calendar) != 6:
            raise ValueError("TERM_CALENDAR_TUPLE_REQUIRED")
        y, month, day, hour, minute, second = calendar
        if any(type(v) is not int for v in calendar[:5]) or not isinstance(second, (int, float)) or not math.isfinite(second) or not 0 <= second < 61:
            raise ValueError("INVALID_TERM_CALENDAR_FIELDS")
        # A naive model-label axis deliberately carries no UTC timezone object.
        point = dt.datetime(y, month, day, hour, minute) + dt.timedelta(seconds=second)
        if row["month_index"] is None or 1960 <= year < 1972:
            continue
        if type(row["month_index"]) is not int or not 0 <= row["month_index"] <= 11:
            raise ValueError("INVALID_JIE_MONTH_INDEX")
        jie.append({**row, "point": point})
    jie.sort(key=lambda item: item["point"])
    if any(a["point"] == b["point"] for a, b in zip(jie, jie[1:])):
        raise ValueError("DUPLICATE_JIE")
    return root, jie


def load_reference():
    # Fresh, unregistered module object. Its globals (including day_index and
    # gregorian_jdn's 1801..2099 restriction) are never reassigned.
    path = Path(__file__).with_name("bazi_reference.py")
    spec = importlib.util.spec_from_file_location("_broad_epoch_rule_dependency", path)
    if spec is None or spec.loader is None:
        raise ValueError("INDEPENDENT_RULE_REFERENCE_UNAVAILABLE")
    reference = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reference)
    return reference


def ordinal_index(value: dt.date) -> int:
    return (value.toordinal() - dt.date(2024, 1, 1).toordinal()) % 60


def expected(reference, civil: str, sex: str, jie: list[dict]) -> dict:
    """Same discrete daysect2 rules, with explicit ordinal and model-label axis."""
    local = dt.datetime.fromisoformat(civil)
    if local.utcoffset() != dt.timedelta(hours=8) or local.microsecond:
        raise ValueError("WHOLE_SECOND_FIXED_PLUS08_CIVIL_REQUIRED")
    if sex not in ("male", "female") or 1960 <= local.year < 1972:
        raise ValueError("SEX_OR_TIME_MODEL_OUT_OF_SCOPE")
    point = local.replace(tzinfo=None) - dt.timedelta(hours=8)
    frame = "UT1_MODEL_LABEL_PRE_1960" if local.year < 1960 else "UTC_ERFA_TABLE_COMPATIBLE_ASSUMPTION"
    terms = [item for item in jie if item["civil_time_frame"] == frame]
    if any(abs((point - item["point"]).total_seconds()) <= 60 for item in terms):
        raise ValueError("SOLAR_TERM_PRECISION_INSUFFICIENT_FOR_BOUNDARY_EXPECTED")
    previous = [item for item in terms if item["point"] <= point]
    following = [item for item in terms if item["point"] > point]
    if not previous or not following:
        raise ValueError("BRACKETING_INDEPENDENT_JIE_REQUIRED")
    prev, nxt = previous[-1], following[0]
    if (nxt["point"] - prev["point"]).days > 35:
        raise ValueError("INDEPENDENT_JIE_SEQUENCE_HAS_GAP")
    lichun = [item for item in terms if item["month_index"] == 0 and (item["point"] + dt.timedelta(hours=8)).year == local.year]
    if len(lichun) != 1:
        raise ValueError("INDEPENDENT_CURRENT_YEAR_LICHUN_REQUIRED")
    solar_year = local.year if point >= lichun[0]["point"] else local.year - 1
    year = reference.annual_pillar(solar_year)
    month_number = prev["month_index"]
    month = reference.STEMS[(reference.STEMS.index(year[0]) % 5 * 2 + 2 + month_number) % 10] + reference.BRANCHES[(2 + month_number) % 12]
    day = reference.CYCLE[ordinal_index(local.date())]
    hour_branch = ((local.hour + 1) // 2) % 12
    hour_date = local.date() + dt.timedelta(days=1 if local.hour == 23 else 0)
    hour_day_stem = ordinal_index(hour_date) % 10
    hour = reference.STEMS[(hour_day_stem % 5 * 2 + hour_branch) % 10] + reference.BRANCHES[hour_branch]
    pillars = {"year": year, "month": month, "day": day, "hour": hour}
    forward = (reference.STEMS.index(year[0]) % 2 == 0) == (sex == "male")
    step = 1 if forward else -1
    selected = nxt if forward else prev
    delta = int(abs((selected["point"] - point).total_seconds()))
    hidden = {key: list(reference.HIDDEN[reference.BRANCHES.index(value[1])]) for key, value in pillars.items()}
    return {
        "profile": "independent-gregorian-ordinal-skyfield-terms-daysect2-v1",
        "effective_civil": local.isoformat(), "pillars": pillars, "hidden_stems": hidden,
        "stem_ten_gods": {key: "日主" if key == "day" else reference.ten_god(day[0], value[0]) for key, value in pillars.items()},
        "hidden_ten_gods": {key: {stem: reference.ten_god(day[0], stem) for stem in stems} for key, stems in hidden.items()},
        "nayin": {key: reference.NAYIN[reference.CYCLE.index(value) // 2] for key, value in pillars.items()},
        "growth": {key: reference.growth(day[0], value[1]) for key, value in pillars.items()},
        "luck_direction": "forward" if forward else "reverse",
        "luck_pillars": [reference.CYCLE[(reference.CYCLE.index(month) + step * i) % 60] for i in range(1, 9)],
        "qiyun": {
            "rule": "SMTH_THREE_DAYS_ONE_YEAR", "selected_jie": selected["name"], "source_id": selected["source_id"],
            "elapsed_seconds_interval": [max(0, delta - 60), delta + 60],
            "traditional_age_interval": [reference.traditional_age(max(0, delta - 60)), reference.traditional_age(delta + 60)],
            "gregorian_start_date": None,
            "gregorian_start_date_status": "NOT_ASSERTED_CLASSICAL_TO_GREGORIAN_POLICY_REQUIRED",
        },
        "annual_pillars": [{"solar_year_label": y, "pillar": reference.annual_pillar(y)} for y in range(solar_year, solar_year + 10)],
        "evidence": ["HKO_CAL_2024_01", "HKO_STEMS", "MLTY_YEAR_MONTH", "MLTY_NIGHT_ZI", "YHZP_CANG", "MLTY_TEN_GODS", "MLTY_NAYIN", "SMTH_GROWTH", "SMTH_THREE_DAYS_ONE_YEAR", "PYTHON_GREGORIAN_ORDINAL_HKO_DAY_ANCHOR", "FROZEN_SKYFIELD_DE440S_TERM_ROOTS"],
        "term_time_semantics": {"civil_time_frame": frame, "comparison_axis": "nominal civil label minus eight hours; naive model labels", "historical_utc_asserted": False, "guard_seconds": 60},
    }


def build_document(terms: Path, terms_hash: str) -> dict:
    root, jie = load_terms(terms, terms_hash)
    reference = load_reference()
    cases, requests = [], []
    for i, (date, time) in enumerate(CHOSEN):
        sex = "male" if i % 2 == 0 else "female"
        key = f"bazi-broad-epoch-{i + 1:02d}"
        cases.append({"id": key, "synthetic": True, "expected": expected(reference, date + "T" + time + "+08:00", sex, jie)})
        requests.append({"id": key, "input": {"civil_date": date, "civil_time": time, "time_precision": "second", "timezone": "Etc/GMT-8", "algorithm_sex": sex}})
    here = Path(__file__).parent
    return {
        "profile": "independent-broad-epoch-v1", "blind": False, "independence_status": "NOT_BLIND",
        "source_sha256": {name: digest(here / name) for name in ("bazi_reference.py", "bazi_reference_sources.json", Path(__file__).name)},
        "term_roots_sha256": terms_hash,
        "term_reference": {key: root[key] for key in ("schema", "kernel_sha256", "reference_engine", "coordinate", "time_model", "independence", "years", "uncertainty_policy")},
        "cases": cases, "requests": requests, "limitations": LIMITATIONS,
        "reference_limits": reference.sources()["limits"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--terms", required=True, type=Path)
    parser.add_argument("--terms-sha256", required=True)
    args = parser.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(build_document(args.terms, args.terms_sha256), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
