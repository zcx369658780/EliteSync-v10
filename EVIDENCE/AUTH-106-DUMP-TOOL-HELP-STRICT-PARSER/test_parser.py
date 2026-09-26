"""One synthetic suite; no subprocess, filesystem, network or real tool output."""

from parser import OPTIONS, parse_dump_text


BANNER = "mysqldump  Ver 10.11.14-MariaDB for synthetic"
VERSION = (BANNER + "\n").encode()
HELP = (
    BANNER
    + "\nUsage: mysqldump [OPTIONS] database [tables]\nOptions:\n"
    + "".join(f"  {name}  Synthetic description\n" for name in OPTIONS)
    + "End options.\n"
).encode()


def run(version=VERSION, help_text=HELP, **overrides):
    args = {
        "version_stdout": version,
        "version_stderr": b"",
        "version_exit": 0,
        "help_stdout": help_text,
        "help_stderr": b"",
        "help_exit": 0,
        "version_complete": True,
        "help_complete": True,
    }
    args.update(overrides)
    return parse_dump_text(**args)


def suite():
    checks = 0

    def check(condition):
        nonlocal checks
        assert condition
        checks += 1

    good = run()
    check(good["error_class"] == "NONE")
    check(good["version_text_state"] == "MATCH_10_11_TEXT")
    check(all(value == "PRESENT_IN_TEXT" for value in good["options"].values()))
    missing = run(help_text=HELP.replace(b"  --events  Synthetic description\n", b""))
    check(missing["options"]["--events"] == "ABSENT_IN_TEXT")
    duplicate = run(help_text=HELP.replace(b"End options.\n", b"  --events  Again\nEnd options.\n"))
    check(duplicate["error_class"] == "DUPLICATE_OPTION_LINE")
    check(all(x == "UNKNOWN" for x in duplicate["options"].values()))
    check(run(help_text=HELP + b"Injected\n")["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_text=HELP.replace(b"Options:\n", b"Example: --events\n"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_text=HELP.replace(b"  --events  Synthetic description", b"The --events flag is available"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_text=HELP.replace(b"Options:\n", b"Flags:\n"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_text=HELP[:-1])["error_class"] == "INCOMPLETE_OR_CONTROL")
    check(run(help_complete=False)["error_class"] == "CAPTURE_INCOMPLETE")
    check(run(help_text=HELP + b"\xff")["error_class"] == "INVALID_UTF8")
    check(run(help_text=HELP + b"x" * 24_577)["error_class"] == "INPUT_TOO_LARGE")
    check(run(version=VERSION.replace(b"10.11.14", b"11.4.1"))["error_class"] == "VERSION_OUT_OF_RANGE")
    check(run(help_exit=1)["error_class"] == "NONZERO_EXIT")
    check(run(help_stderr=b"warning")["error_class"] == "STDERR_PRESENT")
    check(run(version=b"prefix " + VERSION)["error_class"] == "VERSION_LAYOUT_UNKNOWN")
    check(run(help_text=HELP.replace(b"10.11.14", b"10.11.15"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_text=HELP.replace(b"  --events", b"  --events=on"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    suite()
