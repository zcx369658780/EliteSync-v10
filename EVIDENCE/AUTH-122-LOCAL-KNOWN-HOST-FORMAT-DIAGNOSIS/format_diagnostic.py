"""Pure first-rejection classifier for synthetic AUTH-120 known_hosts bytes."""

import re


MAX_COUNT = 256
STAGES = frozenset(
    {
        "INPUT_TYPE", "INPUT_BYTES", "INPUT_NUL", "INPUT_CR", "INPUT_LINES",
        "LINE_BYTES", "LINE_ENCODING", "LINE_WHITESPACE", "MARKER",
        "FIELD_COUNT", "HOST_FIELD", "ALGORITHM", "KEY_BASE64",
        "KEY_STRUCTURE", "TARGET_REPEAT", "NONE", "INTERNAL",
    }
)
CATEGORIES = frozenset(
    {
        "INVALID_INPUT", "INPUT_LIMIT", "FORMAT_INVALID", "MARKER_UNSUPPORTED",
        "HOST_FORMAT_INVALID", "PORT_OR_PATTERN_UNSUPPORTED", "AMBIGUOUS_TARGET",
        "ALGORITHM_UNSUPPORTED", "KEY_FORMAT_INVALID", "NO_REJECTION",
        "DIAGNOSTIC_FAILED",
    }
)


def _result(stage, category, checked, prior_target):
    if stage not in STAGES or category not in CATEGORIES:
        stage, category = "INTERNAL", "DIAGNOSTIC_FAILED"
    return {
        "stage": stage,
        "category": category,
        "checked_entries": min(checked, MAX_COUNT),
        "prior_target_candidate": "YES_CANDIDATE" if prior_target else "NO",
        "port": "UNKNOWN",
        "host_key_trust": "UNKNOWN",
    }


def diagnose_format(data, api):
    """Classify the first rejection using frozen AUTH-120's private validators.

    ``api`` is a caller-supplied, already authenticated AUTH-120 module. This
    function itself performs no I/O, repair, fallback, or target enumeration.
    """

    checked = 0
    prior_target = False
    try:
        if type(data) is not bytes:
            return _result("INPUT_TYPE", "INVALID_INPUT", checked, prior_target)
        if len(data) > api.MAX_BYTES:
            return _result("INPUT_BYTES", "INPUT_LIMIT", checked, prior_target)
        if b"\x00" in data:
            return _result("INPUT_NUL", "FORMAT_INVALID", checked, prior_target)
        if b"\r" in data:
            return _result("INPUT_CR", "FORMAT_INVALID", checked, prior_target)
        lines = data.split(b"\n")
        if len(lines) - (1 if data.endswith(b"\n") else 0) > api.MAX_LINES:
            return _result("INPUT_LINES", "INPUT_LIMIT", checked, prior_target)
        for raw in lines:
            if len(raw) > api.MAX_LINE_BYTES:
                return _result("LINE_BYTES", "INPUT_LIMIT", checked, prior_target)
            if not raw or raw.startswith(b"#"):
                continue
            try:
                line = raw.decode("ascii", errors="strict")
            except UnicodeError:
                return _result("LINE_ENCODING", "FORMAT_INVALID", checked, prior_target)
            if line[:1].isspace() or line[-1:].isspace():
                return _result("LINE_WHITESPACE", "FORMAT_INVALID", checked, prior_target)
            if line.startswith("@"):
                return _result("MARKER", "MARKER_UNSUPPORTED", checked, prior_target)
            fields = re.split(r"[ \t]+", line)
            if len(fields) != 3:
                return _result("FIELD_COUNT", "FORMAT_INVALID", checked, prior_target)
            host_field, algorithm, key_token = fields
            try:
                applies, _kind = api._host_match(host_field)
            except api._Reject as error:
                return _result("HOST_FIELD", error.category, checked, prior_target)
            if algorithm not in api.ALGORITHMS:
                return _result("ALGORITHM", "ALGORITHM_UNSUPPORTED", checked, prior_target)
            try:
                blob = api._base64_canonical(key_token, api.MAX_BLOB_BYTES)
            except api._Reject as error:
                return _result("KEY_BASE64", error.category, checked, prior_target)
            try:
                api._validate_key_blob(algorithm, blob)
            except api._Reject as error:
                return _result("KEY_STRUCTURE", error.category, checked, prior_target)
            if applies and prior_target:
                return _result("TARGET_REPEAT", "AMBIGUOUS_TARGET", checked, prior_target)
            if applies:
                prior_target = True
            checked += 1
        return _result("NONE", "NO_REJECTION", checked, prior_target)
    except Exception:
        return _result("INTERNAL", "DIAGNOSTIC_FAILED", checked, prior_target)
