#!/usr/bin/env python3
"""Independent selected-limit reference; standard library and independent base only.

stdin: {"birth": <ziwei_reference lunar input>, "target_lunar_year": <int>}
or an array of those objects. The supplied year is a lunar-year label, NOT the
product API's Gregorian target_year. No calendar, service or vendor is invoked.
"""
import sys
sys.dont_write_bytecode = True
import hashlib
import json
from pathlib import Path

import ziwei_reference as base

HERE = Path(__file__).resolve().parent
SOURCE_PATH = HERE / "ziwei_selected_rule_sources.json"
SOURCES = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
TABLES = SOURCES["tables"]
SOURCE_BY_ID = {row["id"]: row for row in SOURCES["sources"]}
STEMS, BRANCHES = base.STEMS, base.BRANCHES


def evidence(source_id):
    return {"source_ids": [source_id], "evidence_status": SOURCE_BY_ID[source_id]["evidence"]}


def dependency_hashes():
    names = ("ziwei_reference.py", "ziwei_reference_sources.json",
             "ziwei_selected_reference.py", "ziwei_selected_rule_sources.json")
    return {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest() for name in names}


def not_applicable(reason):
    return {"status": "NOT_APPLICABLE", "reason": reason}


def roles(anchor):
    return {"values": [{"branch_index": branch, "branch": BRANCHES[branch],
                        "name": base.PALACES[(anchor - branch) % 12]} for branch in range(12)],
            **evidence("cyclic-coordinate-convention")}


def palace_at(natal, branch):
    return next(palace for palace in natal["palaces"] if palace["branchIndex"] == branch)


def location(branch, source_id):
    return {"branch_index": branch, "branch": BRANCHES[branch], **evidence(source_id)}


def four_hua(stem, natal, source_id):
    return {"values": [{"transformation": kind, "star": star,
                        "target_natal_branch_index": natal["starPositions"][star],
                        "target_natal_branch": BRANCHES[natal["starPositions"][star]]}
                       for kind, star in zip(("禄", "权", "科", "忌"), base.HUA[stem])],
            "stem_index": stem, "stem": STEMS[stem],
            "destination_convention": "ACTUAL_INDEPENDENT_NATAL_STAR_POSITION_NO_FLOW_RELOCATION",
            **evidence(source_id)}


def seven_stars(stem):
    kui, yue = TABLES["kuiYue"][stem]
    lu = TABLES["lu"][stem]
    positions = {"天魁": kui, "天钺": yue, "禄存": lu, "擎羊": (lu + 1) % 12,
                 "陀罗": (lu - 1) % 12, "文昌": TABLES["flowChang"][stem],
                 "文曲": TABLES["flowQu"][stem]}
    return {name: location(branch, "selected-flow-seven-series") for name, branch in positions.items()}


def trine_entry(branch, entries):
    matches = [entry for entry in entries if BRANCHES[branch] in entry["branches"]]
    if len(matches) != 1:
        raise ValueError("invalid registered trine table")
    return matches[0]


def horse(branch):
    growth = trine_entry(branch, TABLES["horseTrines"])["growthBranch"]
    return (BRANCHES.index(growth) + 6) % 12


def moving_stars(stem, branch, annual):
    prefix = "流" if annual else "运"
    abbreviations = {"天魁": "魁", "天钺": "钺", "禄存": "禄", "擎羊": "羊",
                     "陀罗": "陀", "文昌": "昌", "文曲": "曲"}
    result = {prefix + abbreviations[name]: value for name, value in seven_stars(stem).items()}
    luan = (BRANCHES.index("卯") - branch) % 12
    result[prefix + "马"] = location(horse(branch), "annual-horse-context" if annual else "decadal-horse")
    luan_source = "annual-luan-joy-reused" if annual else "decadal-luan-joy"
    result[prefix + "鸾"] = location(luan, luan_source)
    result[prefix + "喜"] = location((luan + 6) % 12, luan_source)
    if annual:
        result["年解"] = location((BRANCHES.index("戌") - branch) % 12, "annual-nianjie")
    return result


def selected_decade(natal, age):
    matches = [(index, period) for index, period in enumerate(natal["decades"])
               if period["startAge"] <= age <= period["endAge"]]
    if not matches:
        return not_applicable("BEFORE_FIRST_DECADE_CHILD_LIMIT_AVAILABLE" if age < natal["bureauNumber"]
                              else "OUTSIDE_REGISTERED_TWELVE_DECADES")
    if len(matches) != 1:
        raise ValueError("ambiguous independent decade interval")
    index, period = matches[0]
    branch = period["branchIndex"]
    palace = palace_at(natal, branch)
    stem = STEMS.index(palace["stem"])
    return {"status": "CALCULATED_REFERENCE", "period_index_zero_based": index,
            "start_nominal_age": period["startAge"], "end_nominal_age": period["endAge"],
            "direction": natal["decadeDirection"], "life_branch": location(branch, "modern-decade-start"),
            "life_stem": {"stem_index": stem, "stem": palace["stem"], **evidence("base-natal-profile")},
            "palace_roles": roles(branch), "four_hua": four_hua(stem, natal, "flow-stem-layer"),
            "moving_stars": moving_stars(stem, branch, annual=False),
            "interval_evidence": evidence("modern-decade-start")}


def small_limit(natal, birth, age):
    if not 1 <= age <= 120:
        return not_applicable("OUTSIDE_REGISTERED_SMALL_LIMIT_AGES_1_TO_120")
    start = BRANCHES.index(trine_entry(birth["yearBranch"], TABLES["smallAgeOneTrines"])["start"])
    direction = 1 if birth["algorithmSex"] == "male" else -1
    branch = (start + direction * (age - 1)) % 12
    palace = palace_at(natal, branch)
    stem = STEMS.index(palace["stem"])
    return {"status": "CALCULATED_REFERENCE", "nominal_age": age,
            "age_one_branch_index": start, "direction": direction,
            "life_branch": location(branch, "small-limit-branch"),
            "life_stem": {"stem_index": stem, "stem": palace["stem"], **evidence("base-natal-profile")},
            "natal_palace_role": palace["name"], "palace_roles": roles(branch),
            "four_hua": four_hua(stem, natal, "small-limit-hua-composition"),
            "moving_stars": {"status": "SCOPE_NOT_ESTABLISHED"}}


def child_limit(natal, age):
    if age >= natal["bureauNumber"]:
        return not_applicable("AT_OR_AFTER_FIRST_DECADE")
    if not 1 <= age <= 5:
        return not_applicable("OUTSIDE_REGISTERED_PRE_BUREAU_CHILD_AGES_1_TO_5")
    name = TABLES["childRoleByAge"][str(age)]
    palace = next(palace for palace in natal["palaces"] if palace["name"] == name)
    branch, stem = palace["branchIndex"], STEMS.index(palace["stem"])
    return {"status": "CALCULATED_REFERENCE", "nominal_age": age, "bureau_number": natal["bureauNumber"],
            "natal_palace_role": name, "life_branch": location(branch, "child-limit-table"),
            "life_stem": {"stem_index": stem, "stem": palace["stem"], **evidence("base-natal-profile")},
            "table_corroboration": evidence("child-limit-corollary"), "palace_roles": roles(branch),
            "four_hua": {"status": "SCOPE_NOT_ESTABLISHED"},
            "moving_stars": {"status": "SCOPE_NOT_ESTABLISHED"}}


def annual_limit(natal, year):
    stem, branch = (year - 4) % 10, (year - 4) % 12
    jiang_start = [0, 9, 6, 3][branch % 4]
    return {"status": "CALCULATED_REFERENCE", "lunar_year": year,
            "heavenly_stem": STEMS[stem], "earthly_branch": BRANCHES[branch],
            "stem_index": stem, "branch_index": branch,
            "year_label_evidence": evidence("base-natal-profile"), "palace_roles": roles(branch),
            "four_hua": four_hua(stem, natal, "flow-stem-layer"),
            "moving_stars": moving_stars(stem, branch, annual=True),
            "suiqian12": {"values": {name: location((branch + i) % 12, "selected-flow-seven-series")
                                      for i, name in enumerate(TABLES["suiQian"])},
                           "alias_scope": "SUIQIAN_DAHAO_ALSO_CALLED_SUIPO_ONLY"},
            "jiangqian12": {"values": {name: location((jiang_start + i) % 12, "selected-flow-seven-series")
                                        for i, name in enumerate(TABLES["jiangQian"])}}}


def calculate(value):
    if not isinstance(value, dict) or set(value) != {"birth", "target_lunar_year"}:
        raise ValueError("expected exactly birth and target_lunar_year")
    if not isinstance(value["birth"], dict):
        raise ValueError("birth must be independent lunar-input object")
    year = value["target_lunar_year"]
    if type(year) is not int:
        raise ValueError("target_lunar_year must be integer, not Gregorian API target_year")
    natal = base.chart(value["birth"])
    # The independent base accepts both indices and named characters. Normalize
    # only these already-validated two symbols for local trine arithmetic.
    birth = {**value["birth"], "yearBranch": base.index(value["birth"]["yearBranch"], BRANCHES, "yearBranch")}
    age = year - birth["lunarYear"] + 1
    context = {"oracle": SOURCES["oracle"], "version": SOURCES["version"], "blind": False,
               "input": value, "input_contract": SOURCES["inputContract"],
               "target_lunar_year": year, "nominal_age": age,
               "natal_context": {"bureau_number": natal["bureauNumber"], "life_branch_index": natal["lifeBranchIndex"],
                                 "body_branch_index": natal["bodyBranchIndex"], "unknown": natal["unknown"]},
               "dependency_sha256": dependency_hashes(), "source_registry": SOURCES["sources"],
               "limitations": SOURCES["limits"]}
    if age < 1:
        unavailable = not_applicable("TARGET_LUNAR_YEAR_BEFORE_BIRTH")
        return {**context, "status": "NOT_APPLICABLE", "decadal": unavailable, "child_limit": unavailable,
                "small_limit": not_applicable("OUTSIDE_REGISTERED_SMALL_LIMIT_AGES_1_TO_120"), "yearly": unavailable}
    return {**context, "status": "RULE_REFERENCE_NOT_ACCEPTANCE",
            "decadal": selected_decade(natal, age), "child_limit": child_limit(natal, age),
            "small_limit": small_limit(natal, birth, age), "yearly": annual_limit(natal, year)}


def main():
    try:
        # Keep the replay stream UTF-8 on Windows regardless of console codepage.
        sys.stdout.reconfigure(encoding="utf-8")
        value = json.loads(sys.stdin.buffer.read().decode("utf-8"))
        result = [calculate(row) for row in value] if isinstance(value, list) else calculate(value)
        print(json.dumps(result, ensure_ascii=False))
        return 0
    except (ValueError, KeyError, TypeError) as error:
        # Reference CLI, not a product API: emit only an error type, never input.
        print("independent selected reference rejected input: " + type(error).__name__, file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
