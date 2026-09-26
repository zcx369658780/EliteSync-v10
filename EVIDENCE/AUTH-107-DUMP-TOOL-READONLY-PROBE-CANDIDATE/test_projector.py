"""Single synthetic negative suite; no external process or filesystem access."""

from projector import OPTIONS, project_capture


BANNER = b"mysqldump  Ver 10.11.14-MariaDB for synthetic\n"
HELP = BANNER + b"Usage: synthetic only\n  --events  synthetic description\n"


def run(**changes):
    args = {
        "tool_name": "mysqldump",
        "tool_sha256": "a" * 64,
        "tool_is_regular": True,
        "alias_is_symlink": False,
        "version_argv": ("--no-defaults", "--version"),
        "help_argv": ("--no-defaults", "--help"),
        "version_stdout": BANNER,
        "version_stderr": b"",
        "version_exit": 0,
        "help_stdout": HELP,
        "help_stderr": b"",
        "help_exit": 0,
        "version_complete": True,
        "help_complete": True,
    }
    args.update(changes)
    return project_capture(**args)


def suite():
    checks = 0

    def check(condition):
        nonlocal checks
        assert condition
        checks += 1

    good = run()
    check(good["error_class"] == "NONE")
    check(good["version_candidate"] == "10.11.14")
    check(all(good["option_states"][x] == "UNKNOWN" for x in OPTIONS))
    check(good["help_text_state"] == "BOUNDED_UNPARSED")
    check(run(version_argv=("--version", "--no-defaults"))["error_class"] == "DEFAULTS_NOT_DISABLED_FIRST")
    check(run(help_argv=("--help",))["error_class"] == "DEFAULTS_NOT_DISABLED_FIRST")
    check(run(alias_is_symlink=True)["error_class"] == "TOOL_IDENTITY_UNRESOLVED")
    check(run(tool_is_regular=False)["error_class"] == "TOOL_IDENTITY_UNRESOLVED")
    check(run(help_complete=False)["error_class"] == "CAPTURE_INCOMPLETE")
    check(run(help_stderr=b"raw warning")["error_class"] == "STDERR_PRESENT")
    check(run(help_exit=2)["error_class"] == "NONZERO_EXIT")
    check(run(help_stdout=HELP + b"\x1b[31m\n")["error_class"] == "CONTROL_CHAR")
    check(run(help_stdout=HELP + b"\xff")["error_class"] == "INVALID_UTF8")
    check(run(help_stdout=HELP[:-1])["error_class"] == "TRUNCATED_OR_UNTERMINATED")
    check(run(help_stdout=HELP + b"x" * 25_000)["error_class"] == "OUTPUT_LIMIT")
    check(run(help_stdout=HELP + b"  --events  synthetic description\n")["error_class"] == "DUPLICATE_OPTION_LINE")
    check(run(version_stdout=BANNER.replace(b"10.11.14", b"11.4.1"))["error_class"] == "VERSION_UNKNOWN")
    check(run(help_stdout=HELP.replace(b"10.11.14", b"10.11.15"))["error_class"] == "HELP_LAYOUT_UNKNOWN")
    check(run(help_stdout=HELP + b"password=example\n")["option_states"]["--events"] == "UNKNOWN")
    check("raw warning" not in str(run(help_stderr=b"raw warning")))
    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    suite()
