"""SOURCE-ONLY M5-69. Static and Test each require a separate issued budget."""
import sys
sys.dont_write_bytecode = True
import ast
import hashlib
import json
import os
from pathlib import Path
import stat

ROOT = Path("D:/EliteSync-v10")
SOURCE = ("apps/android_synthetic_demo/tools/aar_scoped_crlf_kotlin_transform.py",
          9600, "8BBE07645FA2E181CCCA5546267E5912B432F1007506C32CFF35AFA5C29DB5B7")
FIXTURE = ("EVIDENCE/APP-M5-52-RAW-NEWLINE-SOURCE-FIXTURE/flutter_plugin_original.bin",
           42405, "1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313")
EXPECTED = ("EVIDENCE/APP-M5-68-FROZEN-INDEPENDENT-EXPECTED-ONCE/flutter_plugin_expected.bin",
            45907, "911647D43C25333D2BED7FCB4ECAE6172C8B4536D882501AAFDE1A07125A5C90")
ENTRY = "render_scoped_flutter_plugin"
REPARSE = 0x400


class GateFailure(Exception):
    pass


def require(condition, tag):
    if not condition:
        raise GateFailure(tag)


def ordinary(path, size):
    # Inspect original literal paths, never resolve a link before inspecting it.
    require(os.name == "nt", "PLATFORM_WINDOWS_REQUIRED")
    require(path.is_absolute(), "PATH_NOT_ABSOLUTE")
    node = path
    first = True
    while True:
        info = os.lstat(node)
        require(not stat.S_ISLNK(info.st_mode), "PATH_SYMLINK")
        require(hasattr(info, "st_file_attributes"), "ATTRIBUTES_UNAVAILABLE")
        require(not (info.st_file_attributes & REPARSE),
                "PATH_REPARSE")
        if first:
            require(stat.S_ISREG(info.st_mode), "FILE_TYPE")
            require(info.st_size == size, "FILE_SIZE")
            first = False
        else:
            require(stat.S_ISDIR(info.st_mode), "DIRECTORY_TYPE")
        parent = node.parent
        if parent == node:
            break
        node = parent


def read_fixed(spec, label, counts):
    relative, size, digest = spec
    path = ROOT / relative
    ordinary(path, size)
    counts[label + "Reads"] += 1
    data = path.read_bytes()
    counts[label + "CompletedReads"] += 1
    require(len(data) == size, label.upper() + "_SIZE")
    require(hashlib.sha256(data).hexdigest().upper() == digest,
            label.upper() + "_IDENTITY")
    return data


def literal(node):
    # Structural inspection only: no literal_eval, table extraction or oracle.
    if isinstance(node, ast.Constant):
        return type(node.value) in (str, bytes, int, bool, type(None))
    if isinstance(node, ast.Tuple):
        return all(literal(item) for item in node.elts)
    return False


def check_structure(text, counts):
    counts["Parses"] += 1
    tree = ast.parse(text, filename=SOURCE[0], mode="exec")
    counts["CompletedParses"] += 1
    assignments = {"_SOURCE_SIZE", "_SOURCE_SHA256", "_OUTPUT_SIZE",
                   "_PATCHES", "_DECLARATIONS"}
    functions = {"_count_overlapping", "_line_span", ENTRY}
    found_assignments = set()
    found_functions = {}
    imports = 0
    for index, node in enumerate(tree.body):
        if (index == 0 and isinstance(node, ast.Expr)
                and isinstance(node.value, ast.Constant)
                and type(node.value.value) is str):
            continue
        if isinstance(node, ast.Import):
            require(len(node.names) == 1 and node.names[0].name == "hashlib"
                    and node.names[0].asname is None, "IMPORT_POLICY")
            imports += 1
        elif isinstance(node, ast.Assign):
            require(len(node.targets) == 1
                    and isinstance(node.targets[0], ast.Name), "TOP_ASSIGNMENT")
            name = node.targets[0].id
            require(name in assignments and name not in found_assignments
                    and literal(node.value), "TOP_LITERAL_ONLY")
            found_assignments.add(name)
        elif isinstance(node, ast.FunctionDef):
            require(node.name in functions and node.name not in found_functions,
                    "FUNCTION_SET")
            require(not node.decorator_list and not node.args.defaults
                    and not node.args.kw_defaults and not node.args.posonlyargs
                    and not node.args.kwonlyargs and node.args.vararg is None
                    and node.args.kwarg is None, "FUNCTION_PARAMETERS")
            found_functions[node.name] = node
        else:
            raise GateFailure("TOP_LEVEL_EXECUTION")
    require(imports == 1 and found_assignments == assignments
            and set(found_functions) == functions, "TOP_LEVEL_STRUCTURE")
    entry = found_functions[ENTRY]
    require(len(entry.args.args) == 1 and entry.args.args[0].arg == "source"
            and isinstance(entry.args.args[0].annotation, ast.Name)
            and entry.args.args[0].annotation.id == "bytes"
            and isinstance(entry.returns, ast.Name)
            and entry.returns.id == "bytes", "PUBLIC_ENTRY_SIGNATURE")
    allowed_calls = {"type", "len", "range", "ValueError",
                     "_count_overlapping", "_line_span"}
    allowed_methods = {"find", "sha256", "hexdigest", "upper", "endswith"}
    for node in ast.walk(tree):
        require(not isinstance(node, (ast.ImportFrom, ast.AsyncFunctionDef,
                    ast.ClassDef, ast.Global, ast.Nonlocal, ast.Lambda,
                    ast.With, ast.AsyncWith, ast.Await, ast.Yield,
                    ast.YieldFrom)), "FORBIDDEN_STRUCTURE")
        if isinstance(node, ast.Import):
            require(node in tree.body, "NESTED_IMPORT")
        if isinstance(node, ast.FunctionDef):
            require(node in tree.body, "NESTED_FUNCTION")
        if isinstance(node, ast.Name):
            require(node.id not in {"__main__", "__import__", "eval", "exec",
                    "compile", "open", "globals", "locals", "getattr",
                    "setattr", "delattr", "os", "sys", "socket", "subprocess",
                    "importlib", "environ"}, "FORBIDDEN_NAME")
        if isinstance(node, ast.Attribute):
            require(node.attr in allowed_methods, "ATTRIBUTE_POLICY")
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name):
                require(node.func.id in allowed_calls, "CALL_POLICY")
            elif isinstance(node.func, ast.Attribute):
                require(node.func.attr in allowed_methods, "METHOD_POLICY")
                if node.func.attr == "sha256":
                    require(isinstance(node.func.value, ast.Name)
                            and node.func.value.id == "hashlib", "HASH_CALL")
            else:
                raise GateFailure("DYNAMIC_CALL")
    return tree


def invoke_negative(function, value, expected_tag, name, original, snapshot,
                    counts, cases):
    counts["CandidateInvocation"] += 1
    try:
        function(value)
    except ValueError as error:
        require(type(error) is ValueError and str(error) == expected_tag,
                "NEGATIVE_EXCEPTION_OR_TAG")
    except Exception:
        raise GateFailure("NEGATIVE_EXCEPTION_CLASS") from None
    else:
        raise GateFailure("NEGATIVE_NO_EXCEPTION")
    require(original == snapshot, "SOURCE_MUTATED")
    cases.append({"Case": name, "Result": "PASS",
                  "ExceptionClass": "ValueError", "Tag": expected_tag})


def run_test(text, original, expected, counts, cases):
    namespace = {"__name__": "_elitesync_fixed_crlf_candidate"}
    counts["Compiles"] += 1
    code = compile(text, SOURCE[0], "exec")
    counts["CompletedCompiles"] += 1
    counts["CandidateImport"] += 1
    counts["CandidateModuleLoad"] += 1
    exec(code, namespace, namespace)
    counts["CompletedCandidateModuleLoad"] += 1
    function = namespace[ENTRY]
    snapshot = original
    counts["CandidateInvocation"] += 1
    result = function(original)
    require(type(result) is bytes, "POSITIVE_RESULT_TYPE")
    require(len(result) == 45907 and result == expected, "POSITIVE_FULL_BYTES")
    require(hashlib.sha256(result).hexdigest().upper() == EXPECTED[2],
            "POSITIVE_HASH")
    require(original == snapshot, "SOURCE_MUTATED")
    cases.append({"Case": "positive", "Result": "PASS", "Bytes": len(result),
                  "IndependentExpectedEqual": True, "SourceUnchanged": True})

    class BytesSubclass(bytes):
        pass

    invoke_negative(function, bytearray(original), "ES_SOURCE_TYPE",
                    "bytearray", original, snapshot, counts, cases)
    invoke_negative(function, BytesSubclass(original), "ES_SOURCE_TYPE",
                    "bytes_subclass", original, snapshot, counts, cases)
    invoke_negative(function, "", "ES_SOURCE_TYPE",
                    "str_empty", original, snapshot, counts, cases)
    invoke_negative(function, b"", "ES_SOURCE_SIZE",
                    "bytes_empty", original, snapshot, counts, cases)
    invoke_negative(function, original[:-1], "ES_SOURCE_SIZE",
                    "short_bytes", original, snapshot, counts, cases)
    mutated = bytes([original[0] ^ 1]) + original[1:]
    invoke_negative(function, mutated, "ES_SOURCE_IDENTITY",
                    "offset0_xor1", original, snapshot, counts, cases)


def emit(report):
    line = json.dumps(report, ensure_ascii=True, separators=(",", ":")) + "\n"
    # Bound the complete JSON before emitting any bytes. Preserve failure/counts.
    if len(line.encode("utf-8")) > 4096:
        report["Result"] = "FAIL"
        report["FailureTag"] = report.get("FailureTag") or "REPORT_LIMIT"
        report.pop("Cases", None)
        line = json.dumps(report, ensure_ascii=True, separators=(",", ":")) + "\n"
    if len(line.encode("utf-8")) > 4096:
        raise GateFailure("REPORT_LIMIT_UNEMITTABLE")
    sys.stdout.write(line)
    return 0 if report["Result"] == "PASS" else 1


def main():
    counts = {
        "SourceReads": 0, "SourceCompletedReads": 0,
        "FixtureReads": 0, "FixtureCompletedReads": 0,
        "ExpectedReads": 0, "ExpectedCompletedReads": 0,
        "Parses": 0, "CompletedParses": 0,
        "Compiles": 0, "CompletedCompiles": 0,
        "CandidateImport": 0,
        "CandidateModuleLoad": 0, "CompletedCandidateModuleLoad": 0,
        "CandidateInvocation": 0,
    }
    report = {"Mode": "UNSELECTED", "Phase": "CLI", "Result": "FAIL",
              "Counts": counts, "Cases": [],
              "InternalScopeAnchorScratchPaths": "NOT_CHECKED",
              "SDKCompatibility": "NOT_CHECKED"}
    try:
        require(len(sys.argv) == 2
                and sys.argv[1] in ("--static", "--test"), "CLI_MODE")
        mode = sys.argv[1]
        report["Mode"] = "STATIC" if mode == "--static" else "TEST"
        report["Phase"] = "SOURCE_IDENTITY"
        source = read_fixed(SOURCE, "Source", counts)
        text = source.decode("utf-8", errors="strict")
        report["Phase"] = "STATIC_STRUCTURE"
        check_structure(text, counts)
        if mode == "--test":
            report["Phase"] = "FIXTURE_IDENTITY"
            original = read_fixed(FIXTURE, "Fixture", counts)
            report["Phase"] = "EXPECTED_IDENTITY"
            expected = read_fixed(EXPECTED, "Expected", counts)
            report["Phase"] = "FIXED_SEVEN_CASES"
            run_test(text, original, expected, counts, report["Cases"])
            require(counts["CandidateInvocation"] == 7
                    and len(report["Cases"]) == 7, "CASE_COUNT")
        report["Phase"] = "COMPLETE"
        report["Result"] = "PASS"
    except GateFailure as error:
        report["FailureTag"] = str(error)
    except Exception:
        report["FailureTag"] = "UNEXPECTED_EXCEPTION"
    return emit(report)


if __name__ == "__main__":
    sys.exit(main())
