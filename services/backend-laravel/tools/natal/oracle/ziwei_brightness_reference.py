#!/usr/bin/env python3
"""Independent classical grades at independently calculated natal positions.

Standard library and the separate source-rule oracle only; no product/vendor
imports, actual-result reads or solar-calendar conversion. Input is the same
independently established lunar input as ziwei_reference.py. Accepts one object
or an array on stdin. Published matrix/prose conflicts remain in source metadata.
"""
import hashlib
import json
from pathlib import Path
import sys

from ziwei_reference import chart

SOURCE = Path(__file__).with_name("ziwei_classical_brightness_sources.json")


def reference(data):
    raw = SOURCE.read_bytes()
    source = json.loads(raw)
    independent = chart(data)
    branches = source["branches"]
    grades = source["grade_aliases"]
    assert branches == list("子丑寅卯辰巳午未申酉戌亥")
    assert len(source["stars"]) == 20
    assert sum(len(table) for table in source["stars"].values()) == 232
    results = {}
    for name, table in source["stars"].items():
        position = independent["starPositions"][name]
        branch = branches[position]
        raw_grade = table.get(branch)
        results[name] = {
            "branchIndex": position,
            "branch": branch,
            "sourceGrade": raw_grade,
            "grade": grades[raw_grade] if raw_grade is not None else None,
            "referenceStatus": "PUBLISHED_MATRIX_FACT" if raw_grade is not None
            else "NOT_LISTED_BY_SOURCE",
        }
    return {
        "oracle": "independent-ziwei-position-and-classical-brightness-v1",
        "input": data,
        "source_sha256": hashlib.sha256(raw).hexdigest(),
        "position_rule_sha256": hashlib.sha256(
            Path(__file__).with_name("ziwei_reference.py").read_bytes()
        ).hexdigest(),
        "starBrightness": results,
        "limits": source["limits"] + [
            "Positions come from the separate independent lunar-rule oracle; "
            "a legal solar/lunar correspondence must be supplied independently.",
            "Reference facts do not change production verification labels or "
            "certify whole-school equivalence, unlisted fields or a version AC.",
        ],
    }


if __name__ == "__main__":
    if sys.argv[1:]:
        raise SystemExit("usage: ziwei_brightness_reference.py < lunar-input.json")
    value = json.load(sys.stdin)
    output = [reference(item) for item in value] if isinstance(value, list) else reference(value)
    print(json.dumps(output, ensure_ascii=False, sort_keys=True, indent=2))
