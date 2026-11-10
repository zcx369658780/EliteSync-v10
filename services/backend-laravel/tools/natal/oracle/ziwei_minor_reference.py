#!/usr/bin/env python3
"""Generate expected Ziwei rules for the independently HKO-validated 72 inputs.

Reads only the prior-HKO expected-input matrix, independent rule oracle/source
files, and minor-star source transcription. It never accesses production or
vendor outputs. It writes JSON only to stdout; the original frozen evidence is not overwritten.
"""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
HKO_INPUTS = HERE / "ziwei_legal_reference_inputs.json"
REF_CODE = HERE / "ziwei_reference.py"
REF_SOURCES = HERE / "ziwei_reference_sources.json"
MINOR_SOURCES = HERE / "ziwei_minor_rule_sources.json"


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


spec = importlib.util.spec_from_file_location("independent_ziwei_rule_reference_legal", REF_CODE)
reference = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reference)
reference_sources = json.loads(REF_SOURCES.read_text(encoding="utf-8"))
minor_sources = json.loads(MINOR_SOURCES.read_text(encoding="utf-8"))
hko_rows = json.loads(HKO_INPUTS.read_text(encoding="utf-8"))

STAR_SOURCE = {}
for group_name in ("monthRules", "yearStemRules", "yearBranchRules", "derivedRules"):
    for star_name, rule in minor_sources[group_name].items():
        STAR_SOURCE[star_name] = {"group": group_name, **rule}
STAR_NAMES = list(STAR_SOURCE)


def branch_value(index):
    return {"branch_index": index, "branch": reference.BRANCHES[index]}


def calculate_minor_positions(chart, inp):
    month = inp["lunarMonth"]  # rows are eligible only when the month is non-leap
    day = inp["lunarDay"]
    stem_index = reference.index(inp["yearStem"], reference.STEMS, "yearStem")
    year_branch_index = reference.index(inp["yearBranch"], reference.BRANCHES, "yearBranch")
    result = {}
    for name, rule in minor_sources["monthRules"].items():
        result[name] = rule["monthPositions"][month - 1]
    for name, rule in minor_sources["yearStemRules"].items():
        result[name] = rule["positions"][stem_index]
    for name, rule in minor_sources["yearBranchRules"].items():
        result[name] = rule["positions"][year_branch_index]
    stars = chart["starPositions"]
    life, body = chart["lifeBranchIndex"], chart["bodyBranchIndex"]
    result["天才"] = (life + year_branch_index) % 12
    result["天寿"] = (body + year_branch_index) % 12
    result["恩光"] = (stars["文昌"] + day - 2) % 12
    result["天贵"] = (stars["文曲"] + day - 2) % 12
    return result


def flow_year_ganzhi(year):
    # HKO 2024 is 甲辰, cycle index 40 from 甲子=0; the July 1 target date
    # is after that year's Lunar New Year.
    cycle_index = (year - 2024 + 40) % 60
    return cycle_index, reference.STEMS[cycle_index % 10], reference.BRANCHES[cycle_index % 12]


def selected_luck(chart, inp):
    natal_year = inp["lunarYear"]
    target_year = natal_year + 30
    cycle_index, annual_stem, annual_branch = flow_year_ganzhi(target_year)
    nominal_age = target_year - natal_year + 1
    decade = next((d for d in chart["decades"] if d["startAge"] <= nominal_age <= d["endAge"]), None)
    life = chart["lifeBranchIndex"]
    natal_palace_at = lambda b: reference.PALACES[(life - b) % 12]
    flow_life_branch_index = reference.BRANCHES.index(annual_branch)
    flow_palaces = [
        {"branch_index": b, "branch": reference.BRANCHES[b],
         "palace_name": reference.PALACES[(flow_life_branch_index - b) % 12]}
        for b in range(12)
    ]
    annual_stem_index = reference.STEMS.index(annual_stem)
    transformations = []
    for hua_type, star in zip(reference.HUA_TYPES, reference.HUA[annual_stem_index]):
        target_branch_index = chart["starPositions"].get(star)
        if target_branch_index is None:
            transformations.append({"transformation": hua_type, "star": star,
                                    "status": "NOT_ASSERTED", "reason": "STAR_ABSENT_FROM_INDEPENDENT_BASE_REFERENCE"})
        else:
            transformations.append({"transformation": hua_type, "star": star,
                                    "target_natal_branch_index": target_branch_index,
                                    "target_natal_branch": reference.BRANCHES[target_branch_index],
                                    "target_natal_palace": natal_palace_at(target_branch_index),
                                    "status": "EXPECTED"})
    if decade is None:
        selected_decade = {"status": "NOT_ASSERTED", "reason": "NOMINAL_AGE_OUTSIDE_DERIVED_DECADE_INTERVALS"}
    else:
        selected_decade = {
            "status": "EXPECTED", "branch_index": decade["branchIndex"],
            "branch": reference.BRANCHES[decade["branchIndex"]],
            "palace_name": natal_palace_at(decade["branchIndex"]),
            "start_nominal_age": decade["startAge"], "end_nominal_age": decade["endAge"],
            "direction": chart["decadeDirection"],
        }
    return {
        "status": "RULE_LEVEL_EXPECTED_WITH_PROFILE_LIMITS",
        "target_date": f"{target_year:04d}-07-01",
        "target_year_ganzhi": annual_stem + annual_branch,
        "target_year_cycle_index_from_jiazi_zero": cycle_index,
        "nominal_age": nominal_age,
        "nominal_age_formula": "target_lunar_year - natal_lunar_year + 1; year-based nominal age only, not birthday-exact age",
        "selected_decade": selected_decade,
        "flow_year_life_branch": {"branch_index": flow_life_branch_index, "branch": annual_branch},
        "flow_year_palaces_by_branch": flow_palaces,
        "flow_year_transformations_on_natal_chart": transformations,
        "source_scope": [
            "Sanqing 起大限: 命宫起, 阳男阴女顺/阴男阳女逆, each decade advances one palace; bureau supplies starting age.",
            "ZiweiHome 流年: annual Tai Sui branch is flow-year Life Palace, twelve palace offices are laid out in reverse branch order; annual stem selects four transformations.",
            "Ten-stem transformation rows use the separately transcribed independent HUA table in ziwei_reference.py, with its two cited publishers.",
        ],
        "limitations": [
            "Selected decade and one annual reference date only; not a complete luck-period engine or predictive claim.",
            "No small-limit, child-limit, annual auxiliary-star, monthly, daily, hourly, or fortune interpretation oracle.",
            "Modern source upstream lineage and exact compatibility with the pinned target engine are not established.",
        ],
    }


cases = []
for row in hko_rows:
    inp = row["independent_lunar_input"]
    solar_date = row["solar"]
    # Validate only the input/date mapping fields. Do not read row["expected"].
    assert row["production_input"]["effective_civil_date"] == solar_date
    assert (row["year"], row["month"], row["day"], row["leap"]) == (
        inp["lunarYear"], inp["lunarMonth"], inp["lunarDay"], inp["leapMonth"])
    base = reference.chart(inp)
    base_positions = base["starPositions"]
    minor_eligible = (not inp["leapMonth"] and inp["lunarDay"] >= 3)
    if minor_eligible:
        raw_minor = calculate_minor_positions(base, inp)
        minor_by_star = {
            name: {"status": "EXPECTED", **branch_value(raw_minor[name]), "source": STAR_SOURCE[name]}
            for name in STAR_NAMES
        }
    else:
        reason = "LEAP_MONTH_RULE_UNKNOWN" if inp["leapMonth"] else "DAY_1_2_EXCEPTION_UNVERIFIED"
        minor_by_star = {
            name: {"status": "NOT_ASSERTED", "reason": reason, "source": STAR_SOURCE[name]}
            for name in STAR_NAMES
        }
    cases.append({
        "case_id": row["id"], "sample_split": row["split"],
        "calendar_date": solar_date,
        "input": inp,
        "minor_assertion_scope": "ASSERTED_NONLEAP_DAY_3_PLUS" if minor_eligible else "NOT_ASSERTED",
        "independent_base_reference": {
            "status": "EXPECTED_FROM_SEPARATE_RULE_ORACLE",
            "year_stem_index": inp["yearStem"], "year_stem": reference.STEMS[inp["yearStem"]],
            "year_branch_index": inp["yearBranch"], "year_branch": reference.BRANCHES[inp["yearBranch"]],
            "hour_branch_index": inp["hourBranch"], "hour_branch": reference.BRANCHES[inp["hourBranch"]],
            "lunar_month": inp["lunarMonth"], "lunar_day": inp["lunarDay"], "leap_month": inp["leapMonth"],
            "effective_month": base["effectiveLunarMonth"],
            "life_branch_index": base["lifeBranchIndex"], "life_branch": reference.BRANCHES[base["lifeBranchIndex"]],
            "body_branch_index": base["bodyBranchIndex"], "body_branch": reference.BRANCHES[base["bodyBranchIndex"]],
            "five_element": base["fiveElement"], "bureau_number": base["bureauNumber"],
            "base_star_positions_used_by_minor_rules": {
                name: branch_value(base_positions[name]) for name in ("左辅", "右弼", "文昌", "文曲")
            },
        },
        "minor_positions_by_star": minor_by_star,
        "unresolved_star_fields": {
            name: {"status": "NOT_ASSERTED", "reason": reason}
            for name, reason in minor_sources["unresolved"].items()
        },
        "selected_decade_and_annual_projection": selected_luck(base, inp),
    })

payload = {
    "schema": "elitesync.ziwei.rule-reference.hko-legal-minor-and-selected-luck.v1",
    "status": "FROZEN_EXPECTED_BEFORE_PRODUCT_COMPARISON",
    "generated_at": "2026-10-17",
    "scope": "Independent rule-level expected data over the separate HKO-validated 72-input set. No HKO-row expected output, production output, vendor engine, API, or database is read.",
    "source_input_identities": {
        "hko_legal_input_matrix_sha256": sha256(HKO_INPUTS),
        "independent_reference_code_sha256": sha256(REF_CODE),
        "independent_reference_sources_sha256": sha256(REF_SOURCES),
        "minor_rule_transcription_sha256": sha256(MINOR_SOURCES),
    },
    "minor_star_scope": {
        "source_status": minor_sources["status"],
        "sources": minor_sources["sources"],
        "assertion_filter": "Only rows with a valid HKO input, non-leap lunar month, and lunarDay >= 3 assert any of the 17 listed stars. All 17 names are NOT_ASSERTED for leap-month/day-1/day-2 cases.",
        "star_sources": STAR_SOURCE,
        "unresolved_named_fields": minor_sources["unresolved"],
        "limitations": [
            "The Sanqing/NCC sources are rule transcriptions, not proof of a unique complete lineage.",
            "生月解神 remains distinct from classical year-based 解神 and unresolved alias 年解.",
            "蜚廉 is distinct from 博士十二星飞廉.",
            "No brightness values or other unsourced minor stars are included.",
        ],
    },
    "selected_luck_scope": {
        "decade_source": "https://sanqing.com.tw/en/the-chinese-astrology-chart010/ (起大限), supplemented by the independent oracle's classical-volume-2 five-bureau starting-age references.",
        "annual_flow_source": "https://ziweihome.com/zh-hans/liu-nian (annual Tai Sui branch as flow Life Palace; reverse palace offices; annual stem selects four transformations). Publisher algorithm lineage UNKNOWN.",
        "ten_stem_hua_sources": ["https://sanqing.com.tw/en/the-chinese-astrology-chart010/", "https://minglimr.com/learn/ziwei/si-hua"],
        "target_policy": "For each validated natal lunarYear Y, use target Gregorian calendar year Y+30 and explicit July 1 (after that year's Lunar New Year).",
        "nominal_age_policy": "Y+30 - Y + 1 = 31 traditional year-count; not birthday-exact.",
        "limitations": ["Selected decade and one annual reference date only; not complete luck functionality.", "No small-limit, child-limit, flow auxiliary star, monthly, daily, hourly, or interpretation oracle.", "Modern-source upstream lineage and exact compatibility with pinned target engine remain unproven."],
    },
    "cases": cases,
}
sys.stdout.reconfigure(encoding="utf-8")
print(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True))
