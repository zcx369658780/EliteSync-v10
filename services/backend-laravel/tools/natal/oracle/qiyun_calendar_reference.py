#!/usr/bin/env python3
"""Independent replay of the modern qiyun compatibility contract.

This script imports only the separately authored bazi_reference.py oracle for
its synthetic input rows, original year/month pillars, and direction. It does
not import or invoke production code. By default it writes JSON to stdout. An
--output path must be new; the frozen qiyun-expected.json is always protected.
"""
from __future__ import annotations

import argparse
import calendar
from datetime import date, datetime, timedelta, timezone
import importlib.util
import json
from pathlib import Path
import sys
from typing import Any

sys.dont_write_bytecode = True

DEFAULT_ORACLE = Path(__file__).with_name("bazi_reference.py")
FROZEN_NAME = "qiyun-expected.json"
UTC = timezone.utc
UTC8 = timezone(timedelta(hours=8))

# Reused 30 synthetic calendar inputs from the earlier calendar blind-reference
# exercise. They are embedded as input examples for the sequential clamp path;
# they are not extra natal samples and do not feed the 88 qiyun records.
CALENDAR_CASES = (
    ("leap-day-to-common", "2020-02-29T09:17:43", 1, 0, 0, 0),
    ("leap-day-century-2100", "2096-02-29T23:59:58", 4, 0, 0, 0),
    ("400-year-leap-rule", "2000-02-29T08:00:01", 400, 0, 0, 0),
    ("one-month-jan31", "2023-01-31T06:05:09", 0, 1, 0, 0),
    ("three-months-nov30", "2024-11-30T21:44:12", 0, 3, 0, 0),
    ("eight-months-jun30", "2021-06-30T12:30:45", 0, 8, 0, 0),
    ("year-then-month-nonassoc", "2023-01-31T10:20:30", 1, 1, 0, 0),
    ("year-month-order-nonassoc", "2020-02-29T01:02:03", 1, 1, 0, 0),
    ("month-then-day-crosses-month", "2024-01-31T23:15:16", 0, 1, 1, 0),
    ("hour-crosses-day", "2022-12-31T23:42:51", 0, 0, 0, 3),
    ("day-hour-retain-seconds", "2024-02-28T23:59:37", 0, 0, 1, 2),
    ("subday-from-leap-eve", "2024-02-28T22:11:05", 0, 0, 1, 3),
    ("common-century-1900", "1896-02-29T07:08:09", 4, 0, 0, 0),
    ("century-nonleap-1900", "1899-02-28T00:00:00", 1, 0, 0, 0),
    ("century-leap-2000", "1996-02-29T14:15:16", 4, 0, 0, 0),
    ("end-1901-domain", "1901-12-31T23:00:04", 0, 2, 2, 4),
    ("end-2100-domain-extend", "2100-12-31T22:59:59", 1, 0, 0, 1),
    ("feb-30th-clamp", "2023-01-30T11:12:13", 0, 1, 0, 0),
    ("mar31-to-april", "2024-03-31T16:17:18", 0, 1, 0, 0),
    ("aug31-to-september", "2022-08-31T04:05:06", 0, 1, 0, 0),
    ("year-clamp-then-day", "2023-02-28T19:20:21", 1, 0, 1, 0),
    ("hours-no-calendar-offset", "2020-02-29T23:59:59", 0, 0, 0, 24),
    ("ny-spring-gap-instant", "2024-03-10T15:30:00", 0, 0, 0, 0),
    ("ny-fall-fold-first-instant", "2024-11-03T13:30:00", 0, 0, 0, 0),
    ("ny-fall-fold-second-instant", "2024-11-03T14:30:00", 0, 0, 0, 0),
    ("dateline-east-date-advance", "2024-01-01T00:15:00", 0, 0, 0, 0),
    ("dateline-west-date-retreat", "2024-01-01T00:15:00", 0, 0, 0, 0),
    ("zero-offset-utc", "2024-06-01T12:34:56", 0, 0, 0, 0),
    ("leap-feb-month-plus-hours", "2024-01-31T22:03:07", 0, 1, 0, 5),
    ("max-2111-transition", "2110-12-31T23:59:59", 1, 0, 0, 0),
)

MANUAL_CASES = (
    # Historical probe IDs are retained for frozen-evidence association. The
    # first term is 00:00 UTC = 08:00 UTC+08, so its local endpoints are 23->08
    # across midnight; it is not a 23->00 local endpoint assertion.
    ("spec-23-to-00-forward", "2024-06-01T23:59:00+08:00", "spec-next-jie",
     "2024-06-02T00:00:00Z", 4, "forward"),
    ("spec-00-to-23-reverse", "2024-06-02T00:00:00+08:00", "spec-prev-jie",
     "2024-06-01T15:59:00Z", 4, "reverse"),
    ("spec-23-bucket-guard-boundary", "2024-01-01T20:59:00+08:00",
     "spec-jie-near-bucket", "2024-01-01T13:00:00Z", 10, "forward"),
)


def gregorian_month_length(year: int, month: int) -> int:
    """Month length from Gregorian 4/100/400 leap-year rules."""
    lengths = (31, 29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
               else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    return lengths[month - 1]


def add_years_clamped(value: datetime, years: int) -> datetime:
    year = value.year + years
    return value.replace(year=year, day=min(value.day, gregorian_month_length(year, value.month)))


def add_months_clamped(value: datetime, months: int) -> datetime:
    serial = value.year * 12 + value.month - 1 + months
    year, month0 = divmod(serial, 12)
    month = month0 + 1
    return value.replace(year=year, month=month,
                         day=min(value.day, gregorian_month_length(year, month)))


def add_sequential(value: datetime, offset: dict[str, int]) -> datetime:
    """Clamp year, then clamp month, then add days and hours; retain seconds."""
    if any(offset[k] < 0 for k in ("years", "months", "days", "hours")):
        raise ValueError("offset components must be nonnegative")
    value = add_years_clamped(value, offset["years"])
    value = add_months_clamped(value, offset["months"])
    return value + timedelta(days=offset["days"], hours=offset["hours"])


def parse_utc(value: str) -> datetime:
    result = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if result.utcoffset() is None:
        raise ValueError("source term must contain a UTC offset")
    return result.astimezone(UTC)


def bucket(value: datetime) -> int:
    local = value.astimezone(UTC8)
    return 12 * local.date().toordinal() + min(11, (local.hour + 1) // 2)


def sect1_offset(units: int) -> dict[str, int]:
    years, remainder = divmod(units, 36)
    months, remainder = divmod(remainder, 3)
    return {"years": years, "months": months, "days": remainder * 10, "hours": 0}


def sect2_offset(minutes: int) -> dict[str, int]:
    years, remainder = divmod(minutes, 4320)
    months, remainder = divmod(remainder, 360)
    days, remainder = divmod(remainder, 12)
    return {"years": years, "months": months, "days": days, "hours": remainder * 2}


def result_for_offset(local: datetime, offset: dict[str, int]) -> dict[str, str]:
    calendar_value = add_sequential(local.astimezone(UTC8).replace(tzinfo=None), offset)
    utc_value = calendar_value.replace(tzinfo=UTC8).astimezone(UTC)
    return {
        "calendar": calendar_value.strftime("%Y-%m-%dT%H:%M:%S"),
        "utc": utc_value.strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def elapsed_minute_interval(local: datetime, term: datetime, guard: int,
                            forward: bool) -> list[int]:
    """Apply +/-guard, truncate both endpoints to minute, then subtract."""
    birth_minute = local.astimezone(UTC).replace(second=0, microsecond=0)
    term_bounds = [
        (term - timedelta(seconds=guard)).replace(second=0, microsecond=0),
        (term + timedelta(seconds=guard)).replace(second=0, microsecond=0),
    ]
    values = []
    for endpoint in term_bounds:
        signed = endpoint - birth_minute if forward else birth_minute - endpoint
        values.append(int(signed.total_seconds() // 60))
    if min(values) < 0:
        raise ValueError("term guard crosses the birth instant")
    return sorted(values)


def selected_term(terms: list[dict[str, Any]], local: datetime,
                  forward: bool) -> dict[str, Any]:
    birth_utc = local.astimezone(UTC)
    dated = [(item, parse_utc(item["utc"])) for item in terms]
    eligible = [(item, point) for item, point in dated
                if point > birth_utc] if forward else [
                    (item, point) for item, point in dated if point <= birth_utc]
    if not eligible:
        raise ValueError("independent solar-term source does not bracket the sample")
    return (min(eligible, key=lambda pair: pair[1]) if forward else
            max(eligible, key=lambda pair: pair[1]))[0]


def source_record(item: dict[str, Any]) -> tuple[dict[str, Any], datetime, int]:
    point = parse_utc(item["utc"])
    guard = int(item["uncertainty_seconds"])
    if guard < 0 or not item.get("source_id"):
        raise ValueError("term source id and nonnegative uncertainty are required")
    return item, point, guard


def calculate_sample(sample: dict[str, Any], terms: list[dict[str, Any]]) -> dict[str, Any]:
    source_input = sample["input"]
    local = datetime.fromisoformat(source_input["effective_civil"]).astimezone(UTC8)
    original = sample["expected"]
    direction = original["luck_direction"]
    forward = direction == "forward"
    selected, point, guard = source_record(selected_term(terms, local, forward))
    endpoints = (point - timedelta(seconds=guard), point + timedelta(seconds=guard))
    base = bucket(local)
    differences = sorted((bucket(t) - base if forward else base - bucket(t)
                          for t in endpoints))
    if differences[0] < 0:
        raise ValueError("negative sect1 elapsed bucket difference")
    center = bucket(point) - base if forward else base - bucket(point)

    row: dict[str, Any] = {
        "id": sample["id"],
        "input": source_input,
        "source": {
            "selected_jie": selected["name"],
            "source_id": selected["source_id"],
            "published_utc_minute": selected["utc"],
            "uncertainty_seconds": guard,
            "guard_utc_interval": [t.strftime("%Y-%m-%dT%H:%M:%SZ") for t in endpoints],
        },
        "pillars_and_direction": {
            "year": original["pillars"]["year"],
            "month": original["pillars"]["month"],
            "direction": direction,
        },
    }
    if differences[0] == differences[1]:
        offset = sect1_offset(center)
        row["offset"] = {
            "method": "sect1_bucket_36_3_1", **offset,
            "source_bucket_difference": center,
        }
        row["expected"] = {**result_for_offset(local, offset),
                           "status": "UNIQUE_UNDER_GUARD"}
    else:
        offsets = [sect1_offset(n) for n in differences]
        results = [result_for_offset(local, offset) for offset in offsets]
        row["offset_interval"] = {
            "method": "sect1_bucket_36_3_1",
            "bucket_difference": differences,
            "components_endpoints": offsets,
        }
        row["expected"] = {
            "calendar_interval": [r["calendar"] for r in results],
            "utc_interval": [r["utc"] for r in results],
            "status": "REFERENCE_UNCERTAIN",
        }

    minute_bounds = elapsed_minute_interval(local, point, guard, forward)
    minute_offsets = [sect2_offset(m) for m in minute_bounds]
    minute_results = [result_for_offset(local, o) for o in minute_offsets]
    row["sect2"] = {
        "elapsed_minutes_interval": minute_bounds,
        "offset_interval": {
            "method": "sect2_minutes_4320_360_12_2h",
            "components_endpoints": minute_offsets,
        },
        "expected_interval": {
            "calendar": [r["calendar"] for r in minute_results],
            "utc": [r["utc"] for r in minute_results],
            "status": ("UNIQUE_UNDER_GUARD" if minute_bounds[0] == minute_bounds[1]
                       else "REFERENCE_UNCERTAIN"),
        },
    }
    return row


def manual_sample(case: tuple[Any, ...]) -> dict[str, Any]:
    ident, civil, term_name, term_utc, month_index, direction = case
    local = datetime.fromisoformat(civil).astimezone(UTC8)
    point = parse_utc(term_utc)
    guard = 60
    forward = direction == "forward"
    endpoints = (point - timedelta(seconds=guard), point + timedelta(seconds=guard))
    base = bucket(local)
    differences = sorted((bucket(t) - base if forward else base - bucket(t)
                          for t in endpoints))
    center = bucket(point) - base if forward else base - bucket(point)
    item = {"name": term_name, "month_index": month_index, "utc": term_utc,
            "uncertainty_seconds": guard, "source_id": "SPEC_MANUAL_SYNTHETIC"}
    fake_sample = {
        "id": ident,
        "input": {"effective_civil": civil,
                  "sex": "male" if direction == "forward" else "female"},
        "expected": {"luck_direction": direction,
                     "pillars": {"year": "甲辰", "month": "丙寅"}},
    }
    # Keep this path explicit: manually selected terms are synthetic spec probes,
    # not entries in the cited HKO source.
    row = {
        "id": ident, "synthetic": True, "input": fake_sample["input"],
        "source": {
            "selected_jie": item["name"], "source_id": item["source_id"],
            "published_utc_minute": item["utc"], "uncertainty_seconds": guard,
            "guard_utc_interval": [t.strftime("%Y-%m-%dT%H:%M:%SZ") for t in endpoints],
        },
        "pillars_and_direction": {"year": "甲辰", "month": "丙寅",
                                  "direction": direction},
    }
    if differences[0] == differences[1]:
        offset = sect1_offset(center)
        row["offset"] = {"method": "sect1_bucket_36_3_1", **offset,
                          "source_bucket_difference": center}
        row["expected"] = {**result_for_offset(local, offset),
                           "status": "UNIQUE_UNDER_GUARD"}
    else:
        offsets = [sect1_offset(n) for n in differences]
        results = [result_for_offset(local, o) for o in offsets]
        row["offset_interval"] = {
            "method": "sect1_bucket_36_3_1", "bucket_difference": differences,
            "components_endpoints": offsets,
        }
        row["expected"] = {
            "calendar_interval": [r["calendar"] for r in results],
            "utc_interval": [r["utc"] for r in results],
            "status": "REFERENCE_UNCERTAIN",
        }
    minute_bounds = elapsed_minute_interval(local, point, guard, forward)
    offsets = [sect2_offset(m) for m in minute_bounds]
    results = [result_for_offset(local, offset) for offset in offsets]
    row["sect2"] = {
        "elapsed_minutes_interval": minute_bounds,
        "offset_interval": {"method": "sect2_minutes_4320_360_12_2h",
                             "components_endpoints": offsets},
        "expected_interval": {
            "calendar": [r["calendar"] for r in results],
            "utc": [r["utc"] for r in results],
            "status": "UNIQUE_UNDER_GUARD" if minute_bounds[0] == minute_bounds[1]
                      else "REFERENCE_UNCERTAIN",
        },
    }
    return row


def load_oracle(path: Path):
    if not path.is_file():
        raise FileNotFoundError(f"independent oracle not found: {path}")
    spec = importlib.util.spec_from_file_location("independent_bazi_reference", path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load independent oracle: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def build_document(oracle_path: Path) -> dict[str, Any]:
    oracle = load_oracle(oracle_path)
    source_terms = oracle.sources()["jie_2024"]
    rows = []
    for group in ("fresh", "blind"):
        for sample in oracle.synthetic_samples(group):
            # Original expected is consulted only for year/month pillars and
            # luck direction. Its qiyun output is deliberately not copied.
            rows.append(calculate_sample(sample, source_terms))
    if len(rows) != 88:
        raise AssertionError(f"expected 88 reference inputs, received {len(rows)}")
    return {
        "profile": "bazi-qiyun-modern-compat-independent-v1",
        "status": "INDEPENDENT_MATHEMATICAL_REPLAY_NOT_CLASSICAL_CERTIFICATION",
        "sample_count": len(rows),
        "qiyun_methods": {
            "sect1": ("Use adjacent jie; UTC+08 endpoints map to "
                      "12*Gregorian ordinal + min(11,(hour+1)//2). Nonnegative "
                      "forward/reverse difference; 36 units/year, 3/month, "
                      "1/10 days; zero hours. HKO +/-60s interval must map to "
                      "one difference for a unique result."),
            "sect2": ("Use adjacent jie; truncate both UTC+08 endpoints to "
                      "whole minute before subtraction. 4320 minutes/year, "
                      "360/month, 12/day, remainder*2 hours. HKO precision is "
                      "represented as an interval; no single expected value is "
                      "asserted when endpoints differ."),
            "calendar": ("Sequential Gregorian year clamp, then month clamp, "
                         "then days/hours; start calendar is fixed UTC+08 wall "
                         "time; UTC is calculated after calendar arithmetic."),
        },
        "samples": rows,
        "manual_spec_samples": [manual_sample(case) for case in MANUAL_CASES],
    }


def self_check_calendar_cases() -> None:
    """Cross-check the 30 embedded cases against calendar.monthrange."""
    for ident, start_text, years, months, days, hours in CALENDAR_CASES:
        start = datetime.strptime(start_text, "%Y-%m-%dT%H:%M:%S")
        offset = {"years": years, "months": months, "days": days, "hours": hours}
        actual = add_sequential(start, offset)

        target_year = start.year + years
        expected_day = min(start.day, calendar.monthrange(target_year, start.month)[1])
        direct = start.replace(year=target_year, day=expected_day)
        serial = direct.year * 12 + direct.month - 1 + months
        month_year, month_zero = divmod(serial, 12)
        month = month_zero + 1
        expected_day = min(direct.day, calendar.monthrange(month_year, month)[1])
        direct = direct.replace(year=month_year, month=month, day=expected_day)
        direct += timedelta(days=days, hours=hours)
        if actual != direct:
            raise AssertionError(f"calendar cross-check failed for {ident}: {actual} != {direct}")
        if actual.second != start.second:
            raise AssertionError(f"seconds were not preserved for {ident}")

    # Explicit non-associativity witness: sequential year then month clamps
    # Feb 29 to Feb 28 before moving to March; one combined 13-month move lands
    # on March 29.
    start = datetime(2020, 2, 29, 1, 2, 3)
    sequential = add_months_clamped(add_years_clamped(start, 1), 1)
    combined = add_months_clamped(start, 13)
    if sequential.date() != date(2021, 3, 28) or combined.date() != date(2021, 3, 29):
        raise AssertionError("sequential year/month non-associativity witness changed")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--oracle", type=Path, default=DEFAULT_ORACLE,
                        help="path to the separately authored bazi_reference.py")
    parser.add_argument("--output", type=Path,
                        help="write to a new file; omitted means stdout")
    parser.add_argument("--self-check", action="store_true",
                        help="cross-check the embedded 30 calendar inputs and exit")
    args = parser.parse_args()
    if args.self_check:
        self_check_calendar_cases()
        return 0
    payload = json.dumps(build_document(args.oracle), ensure_ascii=False, indent=2) + "\n"
    if args.output is None:
        sys.stdout.reconfigure(encoding="utf-8", errors="strict")
        sys.stdout.write(payload)
        return 0
    target = args.output.resolve()
    if target.name.casefold() == FROZEN_NAME.casefold():
        parser.error(f"refusing to target frozen {FROZEN_NAME}")
    if target.exists():
        parser.error("refusing to overwrite an existing output; choose a new path")
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("x", encoding="utf-8") as stream:
        stream.write(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
