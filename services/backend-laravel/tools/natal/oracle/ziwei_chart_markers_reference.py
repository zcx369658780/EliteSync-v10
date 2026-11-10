#!/usr/bin/env python3
"""Explicit-lunar, source-level chart markers; no product/vendor/actual reads.

CLI stdin is one independent base input object or a list of such objects.
Only the independent base module is imported. No calendar conversion is done.
"""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REQUIRED = frozenset(("lunarYear", "lunarMonth", "lunarDay", "algorithmSex",
                      "yearStem", "yearBranch", "hourBranch"))


def strict_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON key: " + key)
        result[key] = value
    return result


def reject_constant(value):
    raise ValueError("non-JSON numeric constant: " + value)


def load_json(path):
    return json.loads(path.read_text(encoding="utf-8"),
                      object_pairs_hook=strict_object, parse_constant=reject_constant)


def chart(data, base, sources, selected, identities):
    if not isinstance(data, dict):
        raise ValueError("each input must be an object")
    missing = REQUIRED - data.keys()
    extra = data.keys() - (REQUIRED | {"leapMonth"})
    if missing or extra:
        raise ValueError("input fields: missing=" + repr(sorted(missing))
                         + "; unknown=" + repr(sorted(extra)))
    natal = base.chart(data)  # Sole authority for base input validation.
    stem = base.index(data["yearStem"], base.STEMS, "yearStem")
    year_branch = base.index(data["yearBranch"], base.BRANCHES, "yearBranch")
    life = natal["lifeBranchIndex"]
    # Derive from independent five-tigers palace stems, excluding 子/丑.
    matches = [p["branchIndex"] for p in natal["palaces"]
               if p["branchIndex"] not in (0, 1) and p["stem"] == base.STEMS[stem]]
    if len(matches) != 1 or matches[0] != sources["tables"]["laiYinByYearStem"][stem]:
        raise ValueError("independent five-tigers LaiYin derivation disagrees with registered table")
    original = matches[0]
    sui_start = year_branch
    jiang_start = sources["tables"]["jiangStartByYearBranchModFour"][year_branch % 4]
    fields = sources["fieldProfiles"]
    palaces = []
    for palace in natal["palaces"]:
        branch = palace["branchIndex"]
        palaces.append({
            "branch_index": branch, "branch": base.BRANCHES[branch],
            "palace_name": palace["name"], "stem": palace["stem"],
            "is_original_palace": branch == original,
            "sui_qian": selected["tables"]["suiQian"][(branch - sui_start) % 12],
            "jiang_qian": selected["tables"]["jiangQian"][(branch - jiang_start) % 12],
            "field_provenance": {key: fields[key] for key in
                                 ("is_original_palace", "sui_qian", "jiang_qian")},
        })
    return {
        "schema": sources["outputSchema"],
        "status": "RULE_LEVEL_EXPECTED_WITH_PROFILE_LIMITS",
        "input": data, "source_input_identities": identities,
        "soul_star": sources["tables"]["soulByLifeBranch"][life],
        "body_star": sources["tables"]["bodyByYearBranch"][year_branch],
        "original_palace_branch_index": original,
        "palaces": palaces,
        "independent_base_reference": {
            "lifeBranchIndex": life, "bodyBranchIndex": natal["bodyBranchIndex"],
            "effectiveLunarMonth": natal["effectiveLunarMonth"],
        },
        "field_provenance": {key: fields[key] for key in
                             ("soul_star", "body_star", "is_original_palace")},
        "limitations": sources["limitations"],
    }


def main():
    if sys.argv[1:]:
        raise ValueError("usage: ziwei_chart_markers_reference.py < input.json")
    value = json.load(sys.stdin, object_pairs_hook=strict_object,
                      parse_constant=reject_constant)
    if not isinstance(value, (dict, list)):
        raise ValueError("stdin must contain an object or a list of objects")
    sources = load_json(HERE / "ziwei_chart_markers_sources.json")
    selected = load_json(HERE / "ziwei_selected_rule_sources.json")
    identities = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
                  for name in sources["dependencyFiles"]}
    spec = importlib.util.spec_from_file_location("independent_ziwei_markers_base",
                                                HERE / "ziwei_reference.py")
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    result = ([chart(item, base, sources, selected, identities) for item in value]
              if isinstance(value, list) else chart(value, base, sources, selected, identities))
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(result, ensure_ascii=True, allow_nan=False, sort_keys=True, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError) as error:
        raise SystemExit(str(error))
