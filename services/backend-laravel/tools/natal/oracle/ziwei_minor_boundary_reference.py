#!/usr/bin/env python3
"""Rule-level minor-star boundary reference; standard library only.

Accept explicit lunar inputs on stdin (one object or a list). No calendar
conversion, product, vendor, actual-output, or prior expected-data access.
Only ziwei_reference.py is imported; the older minor generator is not imported.
See the accompanying sources JSON for the selected profile and inference limits.
"""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
SOURCE_NAME = "ziwei_minor_boundary_sources.json"
REQUIRED_FIELDS = frozenset(("lunarYear", "lunarMonth", "lunarDay", "algorithmSex",
                             "yearStem", "yearBranch", "hourBranch"))
ALLOWED_FIELDS = REQUIRED_FIELDS | {"leapMonth"}


def strict_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON key: " + key)
        result[key] = value
    return result


def reject_constant(value):
    raise ValueError("non-JSON numeric constant: " + value)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"),
                      object_pairs_hook=strict_object, parse_constant=reject_constant)


def load_reference():
    spec = importlib.util.spec_from_file_location(
        "independent_ziwei_boundary_base", HERE / "ziwei_reference.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def chart(data, base, minor_sources, boundary_sources, identities):
    if not isinstance(data, dict):
        raise ValueError("each input must be an object")
    missing, extra = REQUIRED_FIELDS - data.keys(), data.keys() - ALLOWED_FIELDS
    if missing or extra:
        raise ValueError("input fields: missing=" + repr(sorted(missing))
                         + "; unknown=" + repr(sorted(extra)))
    # The independent base validates all lunar values, sex, stem/branch and hour,
    # including consistency of the explicit lunar year with the supplied ganzhi.
    independent_base = base.chart(data)
    month_index = (independent_base["effectiveLunarMonth"] - 1) % 12
    stem_index = base.index(data["yearStem"], base.STEMS, "yearStem")
    year_index = base.index(data["yearBranch"], base.BRANCHES, "yearBranch")
    day = data["lunarDay"]
    positions = {}
    for name, rule in minor_sources["monthRules"].items():
        positions[name] = rule["monthPositions"][month_index]
    # These table lookups never use month/day (including leap status).
    for name, rule in minor_sources["yearStemRules"].items():
        positions[name] = rule["positions"][stem_index]
    for name, rule in minor_sources["yearBranchRules"].items():
        positions[name] = rule["positions"][year_index]
    positions["天才"] = (independent_base["lifeBranchIndex"] + year_index) % 12
    positions["天寿"] = (independent_base["bodyBranchIndex"] + year_index) % 12
    positions["恩光"] = (independent_base["starPositions"]["文昌"] + day - 2) % 12
    positions["天贵"] = (independent_base["starPositions"]["文曲"] + day - 2) % 12
    by_star = {}
    for group in ("monthRules", "yearStemRules", "yearBranchRules", "derivedRules"):
        for name, rule in minor_sources[group].items():
            profile = boundary_sources["ruleProfiles"][group]
            at = positions[name]
            # Preserve the original transcription's warnings as historical scope;
            # only the separately registered boundary profile extends that scope.
            by_star[name] = {
                "status": "RULE_LEVEL_EXPECTED_WITH_PROFILE_LIMITS",
                "branch_index": at, "branch": base.BRANCHES[at],
                "source": {"group": group, "transcribedRule": rule,
                           "boundaryProfile": profile,
                           "fieldProfile": boundary_sources["fieldProfiles"].get(name, {})},
            }
    return {
        "schema": boundary_sources["outputSchema"],
        "status": "RULE_LEVEL_EXPECTED_WITH_PROFILE_LIMITS",
        "input": data,
        "source_input_identities": identities,
        "effectiveLunarMonth": independent_base["effectiveLunarMonth"],
        "normalizedMonthIndex": month_index,
        "independent_base_reference": {
            "lifeBranchIndex": independent_base["lifeBranchIndex"],
            "bodyBranchIndex": independent_base["bodyBranchIndex"],
            "starPositions": {name: independent_base["starPositions"][name]
                              for name in ("文昌", "文曲")},
        },
        "minor_positions_by_star": by_star,
        "unresolved_star_fields": minor_sources["unresolved"],
        "profile": boundary_sources["profile"],
        "limitations": boundary_sources["limitations"],
    }


def main():
    if sys.argv[1:]:
        raise ValueError("usage: ziwei_minor_boundary_reference.py < input.json")
    value = json.load(sys.stdin, object_pairs_hook=strict_object,
                      parse_constant=reject_constant)
    if not isinstance(value, (dict, list)):
        raise ValueError("stdin must contain an object or a list of objects")
    sources = read_json(HERE / SOURCE_NAME)
    minor_sources = read_json(HERE / "ziwei_minor_rule_sources.json")
    identities = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
                  for name in sources["dependencyFiles"]}
    base = load_reference()
    result = ([chart(item, base, minor_sources, sources, identities) for item in value]
              if isinstance(value, list)
              else chart(value, base, minor_sources, sources, identities))
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(result, ensure_ascii=True, allow_nan=False, sort_keys=True, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError) as error:
        raise SystemExit(str(error))
