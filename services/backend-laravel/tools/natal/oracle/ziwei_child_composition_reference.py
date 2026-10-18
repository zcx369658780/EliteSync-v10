#!/usr/bin/env python3
"""Modern child-profile composition consistency reference, NOT a tradition proof.

stdin: selected-reference {birth, target_lunar_year} object or list. No actual,
vendor, product, calendar conversion or original reference mutation is used.
"""
import hashlib
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
import ziwei_selected_reference as selected

HERE = Path(__file__).resolve().parent


def strict_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON key: " + key)
        result[key] = value
    return result


def reject_constant(value):
    raise ValueError("non-JSON numeric constant: " + value)


def calculate(value, sources, hashes):
    # The registered independent reference owns input validation and child-layer
    # selection; its SCOPE_NOT_ESTABLISHED fields are returned unchanged below.
    original = selected.calculate(value)
    child = original["child_limit"]
    context = {
        "schema": sources["outputSchema"], "input": value,
        "blindness": "NOT_BLIND_NO_ACTUAL_READ",
        "reference_kind": "MODERN_PROFILE_MATHEMATICAL_COMPOSITION_CONSISTENCY",
        "dependency_sha256": hashes,
        "original_child_limit": child,
        "source_registry": sources["sources"],
        "field_provenance": sources["fieldProfiles"],
        "limitations": sources["limitations"],
    }
    if child["status"] != "CALCULATED_REFERENCE":
        return {**context, "status": "NOT_APPLICABLE",
                "reason": child.get("reason", "CHILD_LIMIT_NOT_CALCULATED"),
                "child_composition": {"status": "NOT_APPLICABLE"}}
    natal = selected.base.chart(value["birth"])
    stem = child["life_stem"]["stem_index"]
    branch = child["life_branch"]["branch_index"]
    hua = selected.four_hua(stem, natal, "flow-stem-layer")
    moving = selected.moving_stars(stem, branch, annual=False)
    return {
        **context, "status": "PROFILE_COMPOSITION_REFERENCE_NOT_ACCEPTANCE",
        "child_composition": {
            "status": "CALCULATED_PROFILE_COMPOSITION",
            "nominal_age": original["nominal_age"],
            "life_stem": child["life_stem"], "life_branch": child["life_branch"],
            "natal_palace_role": child["natal_palace_role"],
            "four_hua": hua, "moving_stars": moving,
            "applicability_authority": "FROZEN_IZTRO_COMPATIBLE_MODERN_PRODUCT_PROFILE_CHOICE",
            "source_scope_override": "Reused function source tags describe component formulas only; they do not establish child-layer applicability. See field_provenance and limitations.",
        },
    }


def main():
    if sys.argv[1:]:
        raise ValueError("usage: ziwei_child_composition_reference.py < input.json")
    value = json.load(sys.stdin, object_pairs_hook=strict_object,
                      parse_constant=reject_constant)
    if not isinstance(value, (dict, list)):
        raise ValueError("stdin must contain an object or a list of objects")
    sources = json.loads((HERE / "ziwei_child_composition_sources.json").read_text(encoding="utf-8"),
                         object_pairs_hook=strict_object, parse_constant=reject_constant)
    hashes = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
              for name in sources["dependencyFiles"]}
    result = ([calculate(item, sources, hashes) for item in value]
              if isinstance(value, list) else calculate(value, sources, hashes))
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(result, ensure_ascii=True, allow_nan=False, sort_keys=True, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError) as error:
        raise SystemExit(str(error))
