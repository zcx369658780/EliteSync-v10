"""Independent, offline discrete Bazi reference; NOT an astrology validity claim.

No production imports, lunar/iztro imports, network, fixtures or application calls.
Run this file to emit 64 fresh and 24 held-out synthetic input/expected records.
Expected values follow the cited rules, not the random seed. Sources and limits
live in bazi_reference_sources.json. Gregorian support: USNO AD 1801..2099.
Built-in solar-term coverage is intentionally bounded to HKO's 2024 tables.
"""
from __future__ import annotations

import argparse
from datetime import date, datetime, timedelta, timezone
from fractions import Fraction
import json
from pathlib import Path
import random

STEMS = "甲乙丙丁戊己庚辛壬癸"
BRANCHES = "子丑寅卯辰巳午未申酉戌亥"
CYCLE = tuple(STEMS[i % 10] + BRANCHES[i % 12] for i in range(60))
GROWTH = ("长生", "沐浴", "冠带", "临官", "帝旺", "衰", "病", "死", "墓", "绝", "胎", "养")
GROWTH_START = (11, 6, 2, 9, 2, 9, 5, 0, 8, 3)
# Membership is attested by YHZP_CANG; ordering is a display convention only.
HIDDEN = ("癸", "己癸辛", "甲丙戊", "乙", "戊乙癸", "丙戊庚", "丁己", "己丁乙", "庚壬戊", "辛", "戊辛丁", "壬甲")
NAYIN = (
    "海中金", "炉中火", "大林木", "路旁土", "剑锋金", "山头火",
    "涧下水", "城头土", "白蜡金", "杨柳木", "泉中水", "屋上土",
    "霹雳火", "松柏木", "长流水", "沙中金", "山下火", "平地木",
    "壁上土", "金箔金", "覆灯火", "天河水", "大驿土", "钗钏金",
    "桑柘木", "大溪水", "沙中土", "天上火", "石榴木", "大海水",
)
UTC8 = timezone(timedelta(hours=8))
PROFILE = "independent-usno-hko-classical-daysect2-v1"


class OracleUnavailable(ValueError):
    """Evidence does not justify a single expected value."""


def sources() -> dict:
    return json.loads(Path(__file__).with_name("bazi_reference_sources.json").read_text(encoding="utf-8"))


def gregorian_jdn(value: date) -> int:
    """USNO Almanac for Computers formula at noon, not Python date ordinal.

    All operands are positive in this explicitly restricted range, so // agrees
    with USNO truncation. The Gregorian 1900 Jan/Feb correction is retained.
    """
    year, month, day = value.year, value.month, value.day
    if not 1801 <= year <= 2099:
        raise OracleUnavailable("USNO_FORMULA_YEAR_OUT_OF_SCOPE")
    sign = 1 if 100 * year + month > 190002.5 else -1
    midnight_jd = (367 * year - (7 * (year + (month + 9) // 12)) // 4
                   + (275 * month) // 9 + day + Fraction(3442027, 2)
                   - Fraction(sign, 2) + Fraction(1, 2))
    return int(midnight_jd + Fraction(1, 2))


def day_index(value: date) -> int:
    # Official daily calendar cell: 2024-01-01 甲子 (HKO_CAL_2024_01).
    return (gregorian_jdn(value) - gregorian_jdn(date(2024, 1, 1))) % 60


def ten_god(day_stem: str, other: str) -> str:
    a, b = STEMS.index(day_stem), STEMS.index(other)
    relation = ((b // 2) - (a // 2)) % 5  # 木火土金水 generation cycle
    same_polarity = a % 2 == b % 2
    return {
        0: ("比肩", "劫财"), 1: ("食神", "伤官"),
        2: ("偏财", "正财"), 3: ("七杀", "正官"),
        4: ("偏印", "正印"),
    }[relation][0 if same_polarity else 1]


def growth(day_stem: str, branch: str) -> str:
    stem, target = STEMS.index(day_stem), BRANCHES.index(branch)
    direction = 1 if stem % 2 == 0 else -1
    return GROWTH[((target - GROWTH_START[stem]) * direction) % 12]


def _aware(value: str) -> datetime:
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.utcoffset() is None:
        raise ValueError("explicit UTC offset required")
    return parsed


def _terms(rows: list[dict] | None) -> list[dict]:
    rows = sources()["jie_2024"] if rows is None else rows
    parsed = []
    for item in rows:
        if not item.get("source_id") or "uncertainty_seconds" not in item:
            raise OracleUnavailable("EXTERNAL_TERM_PROVENANCE_AND_UNCERTAINTY_REQUIRED")
        point = _aware(item["utc"]).astimezone(timezone.utc)
        uncertainty = int(item["uncertainty_seconds"])
        month_index = int(item["month_index"])
        if uncertainty < 0 or not 0 <= month_index <= 11:
            raise ValueError("invalid independent solar-term input")
        parsed.append({**item, "point": point, "uncertainty_seconds": uncertainty})
    parsed.sort(key=lambda r: r["point"])
    if not parsed or any(a["point"] == b["point"] for a, b in zip(parsed, parsed[1:])):
        raise OracleUnavailable("MISSING_OR_DUPLICATE_JIE")
    return parsed


def traditional_age(elapsed_seconds: int) -> dict:
    """3 real days = 1 traditional year; 360d/year,30d/month.

    A real shichen (7200 seconds) = 10 traditional days. The hours below are
    arithmetic subdivisions of that ratio, not a claim of classical rounding.
    No Gregorian start date or integer nominal age is inferred from this.
    """
    if elapsed_seconds < 0:
        raise ValueError("negative duration")
    hours = elapsed_seconds // 30
    days, hour = divmod(hours, 24)
    years, remainder = divmod(days, 360)
    months, day = divmod(remainder, 30)
    return {"years": years, "months": months, "days": day, "hours": hour}


def annual_pillar(year_label: int) -> str:
    """Solar-year LABEL (starts at Lichun), not a Jan-1 boundary assertion."""
    # 2024 甲辰 is independently visible in official HKO monthly headings.
    return CYCLE[(year_label - 2024 + 40) % 60]


def expected(effective_civil: str, sex: str, independent_jie: list[dict] | None = None) -> dict:
    """UTC+08 effective civil input, daysect2, year/month exact between jie.

    External jie records must be independently obtained, never read from the
    engine being tested. Uncertainty guard prevents minute tables becoming fake
    second-precision expected values. Sex is only the traditional direction input.
    """
    local = _aware(effective_civil)
    if local.utcoffset() != timedelta(hours=8):
        raise OracleUnavailable("FIXED_UTC_PLUS_08_EFFECTIVE_CIVIL_REQUIRED")
    local = local.astimezone(UTC8)
    if local.microsecond:
        raise ValueError("whole-second input required")
    if sex not in ("male", "female"):
        raise ValueError("sex must be male or female for this rule profile")
    terms = _terms(independent_jie)
    for item in terms:
        if abs((local - item["point"]).total_seconds()) <= item["uncertainty_seconds"]:
            raise OracleUnavailable("SOLAR_TERM_PRECISION_INSUFFICIENT_FOR_BOUNDARY_EXPECTED")
    previous = [r for r in terms if r["point"] <= local]
    following = [r for r in terms if r["point"] > local]
    if not previous or not following:
        raise OracleUnavailable("BRACKETING_INDEPENDENT_JIE_REQUIRED")
    prev, nxt = previous[-1], following[0]
    if (nxt["point"] - prev["point"]).days > 35:
        raise OracleUnavailable("INDEPENDENT_JIE_SEQUENCE_HAS_GAP")
    lichun = [r for r in terms if r["month_index"] == 0 and r["point"].astimezone(UTC8).year == local.year]
    if len(lichun) != 1:
        raise OracleUnavailable("INDEPENDENT_CURRENT_YEAR_LICHUN_REQUIRED")
    solar_year = local.year if local >= lichun[0]["point"] else local.year - 1
    year = annual_pillar(solar_year)
    month_number = prev["month_index"]
    month = STEMS[(STEMS.index(year[0]) % 5 * 2 + 2 + month_number) % 10] + BRANCHES[(2 + month_number) % 12]
    day = CYCLE[day_index(local.date())]
    hour_branch = ((local.hour + 1) // 2) % 12
    # MLTY_NIGHT_ZI: retain civil day pillar, next day's stem for late Zi.
    hour_date = local.date() + timedelta(days=1 if local.hour == 23 else 0)
    hour_day_stem = day_index(hour_date) % 10
    hour = STEMS[(hour_day_stem % 5 * 2 + hour_branch) % 10] + BRANCHES[hour_branch]
    pillars = {"year": year, "month": month, "day": day, "hour": hour}
    forward = (STEMS.index(year[0]) % 2 == 0) == (sex == "male")
    step = 1 if forward else -1
    selected = nxt if forward else prev
    delta = int(abs((selected["point"] - local).total_seconds()))
    uncertainty = selected["uncertainty_seconds"]
    return {
        "profile": PROFILE,
        "effective_civil": local.isoformat(),
        "pillars": pillars,
        "hidden_stems": {k: list(HIDDEN[BRANCHES.index(v[1])]) for k, v in pillars.items()},
        "stem_ten_gods": {k: ("日主" if k == "day" else ten_god(day[0], v[0])) for k, v in pillars.items()},
        "hidden_ten_gods": {k: {h: ten_god(day[0], h) for h in HIDDEN[BRANCHES.index(v[1])]} for k, v in pillars.items()},
        "nayin": {k: NAYIN[CYCLE.index(v) // 2] for k, v in pillars.items()},
        "growth": {k: growth(day[0], v[1]) for k, v in pillars.items()},
        "luck_direction": "forward" if forward else "reverse",
        "luck_pillars": [CYCLE[(CYCLE.index(month) + step * i) % 60] for i in range(1, 9)],
        "qiyun": {
            "rule": "SMTH_THREE_DAYS_ONE_YEAR",
            "selected_jie": selected["name"], "source_id": selected["source_id"],
            "elapsed_seconds_interval": [max(0, delta - uncertainty), delta + uncertainty],
            "traditional_age_interval": [traditional_age(max(0, delta - uncertainty)), traditional_age(delta + uncertainty)],
            "gregorian_start_date": None,
            "gregorian_start_date_status": "NOT_ASSERTED_CLASSICAL_TO_GREGORIAN_POLICY_REQUIRED",
        },
        "annual_pillars": [{"solar_year_label": y, "pillar": annual_pillar(y)} for y in range(solar_year, solar_year + 10)],
        "evidence": ["USNO_JD", "HKO_CAL_2024_01", "HKO_STEMS", "MLTY_YEAR_MONTH", "MLTY_NIGHT_ZI", "YHZP_CANG", "MLTY_TEN_GODS", "MLTY_NAYIN", "SMTH_GROWTH", "SMTH_THREE_DAYS_ONE_YEAR"],
    }


def synthetic_samples(group: str) -> list[dict]:
    """Disjoint synthetic records; held-out group never uses production outputs.

    Samples deliberately stay >60s from every cited term. This generator is not
    a broad-epoch oracle: all solar-term expected evidence is bounded to 2024.
    """
    settings = {"fresh": (64, 10010064), "blind": (24, 10010024)}
    if group not in settings:
        raise ValueError("unknown group")
    size, seed = settings[group]
    rng = random.Random(seed)
    start = date(2024, 1, 7)
    end = date(2024, 12, 5)
    # Separate parity of calendar dates gives independent groups disjoint inputs.
    parity = 0 if group == "fresh" else 1
    days = [start + timedelta(days=i) for i in range((end - start).days + 1)
            if i % 2 == parity]
    rng.shuffle(days)
    times = ("00:00:00", "00:59:59", "01:00:00", "03:00:00",
             "05:00:00", "06:59:59", "07:00:00", "08:59:59", "09:00:00", "10:59:59",
             "11:00:00", "12:59:59", "13:00:00", "14:59:59", "15:00:00", "16:59:59",
             "17:00:00", "18:59:59", "19:00:00", "20:59:59", "21:00:00", "22:59:59",
             "23:00:00", "23:59:59")
    result = []
    for i, value in enumerate(days[:size]):
        civil = f"{value.isoformat()}T{times[i % len(times)]}+08:00"
        sex = "male" if i % 2 == 0 else "female"
        result.append({"id": f"bazi-{group}-{i + 1:03d}", "synthetic": True,
                       "input": {"effective_civil": civil, "sex": sex},
                       "expected": expected(civil, sex)})
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--group", choices=("fresh", "blind", "all"), default="all")
    args = parser.parse_args()
    groups = ("fresh", "blind") if args.group == "all" else (args.group,)
    print(json.dumps({"profile": PROFILE, "groups": {g: synthetic_samples(g) for g in groups}}, ensure_ascii=False, indent=2))
