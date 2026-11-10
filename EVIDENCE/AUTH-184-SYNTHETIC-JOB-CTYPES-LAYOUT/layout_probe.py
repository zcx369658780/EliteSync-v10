"""Measure a synthetic ctypes layout; do not use it for Windows calls."""

import ctypes
import json
import platform
import struct
import sys


# These are candidate Python mappings, not verified Windows ABI typedefs.
DWORD = ctypes.c_uint32
LONG = ctypes.c_int32
LONGLONG = ctypes.c_int64
ULONGLONG = ctypes.c_uint64
SIZE_T = ctypes.c_size_t
ULONG_PTR = ctypes.c_size_t


class LARGE_INTEGER_DUMMYSTRUCTNAME(ctypes.Structure):
    _fields_ = [("LowPart", DWORD), ("HighPart", LONG)]


class LARGE_INTEGER_u(ctypes.Structure):
    _fields_ = [("LowPart", DWORD), ("HighPart", LONG)]


class LARGE_INTEGER(ctypes.Union):
    _fields_ = [
        ("DUMMYSTRUCTNAME", LARGE_INTEGER_DUMMYSTRUCTNAME),
        ("u", LARGE_INTEGER_u),
        ("QuadPart", LONGLONG),
    ]


class IO_COUNTERS(ctypes.Structure):
    _fields_ = [
        ("ReadOperationCount", ULONGLONG),
        ("WriteOperationCount", ULONGLONG),
        ("OtherOperationCount", ULONGLONG),
        ("ReadTransferCount", ULONGLONG),
        ("WriteTransferCount", ULONGLONG),
        ("OtherTransferCount", ULONGLONG),
    ]


class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):
    _fields_ = [
        ("PerProcessUserTimeLimit", LARGE_INTEGER),
        ("PerJobUserTimeLimit", LARGE_INTEGER),
        ("LimitFlags", DWORD),
        ("MinimumWorkingSetSize", SIZE_T),
        ("MaximumWorkingSetSize", SIZE_T),
        ("ActiveProcessLimit", DWORD),
        ("Affinity", ULONG_PTR),
        ("PriorityClass", DWORD),
        ("SchedulingClass", DWORD),
    ]


class JOBOBJECT_EXTENDED_LIMIT_INFORMATION(ctypes.Structure):
    _fields_ = [
        ("BasicLimitInformation", JOBOBJECT_BASIC_LIMIT_INFORMATION),
        ("IoInfo", IO_COUNTERS),
        ("ProcessMemoryLimit", SIZE_T),
        ("JobMemoryLimit", SIZE_T),
        ("PeakProcessMemoryUsed", SIZE_T),
        ("PeakJobMemoryUsed", SIZE_T),
    ]


BASE_TYPES = {
    "DWORD": ("ctypes.c_uint32", DWORD, 4),
    "LONG": ("ctypes.c_int32", LONG, 4),
    "LONGLONG": ("ctypes.c_int64", LONGLONG, 8),
    "ULONGLONG": ("ctypes.c_uint64", ULONGLONG, 8),
    "SIZE_T": ("ctypes.c_size_t", SIZE_T, struct.calcsize("P")),
    "ULONG_PTR": ("ctypes.c_size_t", ULONG_PTR, struct.calcsize("P")),
}


def layout(aggregate):
    offsets = {name: getattr(aggregate, name).offset for name, _ in aggregate._fields_}
    if aggregate is LARGE_INTEGER:
        for member, nested in (
            ("DUMMYSTRUCTNAME", LARGE_INTEGER_DUMMYSTRUCTNAME),
            ("u", LARGE_INTEGER_u),
        ):
            for name, _ in nested._fields_:
                offsets[member + "." + name] = offsets[member] + getattr(nested, name).offset
    return {"sizeof": ctypes.sizeof(aggregate), "field_offsets": offsets}


def main():
    base_types = {
        name: {"candidate": label, "sizeof": ctypes.sizeof(candidate)}
        for name, (label, candidate, _) in BASE_TYPES.items()
    }
    width_conflicts = [
        name
        for name, (_, candidate, expected) in BASE_TYPES.items()
        if ctypes.sizeof(candidate) != expected
    ]
    pointer_bytes = struct.calcsize("P")
    if pointer_bytes not in (4, 8):
        width_conflicts.append("POINTER_WIDTH")

    result = {
        "schema": "AUTH-184-SYNTHETIC-JOB-CTYPES-LAYOUT/v1",
        "status": "UNAVAILABLE" if width_conflicts else "STATIC_LAYOUT_ONLY",
        "runtime": {
            "python_implementation": sys.implementation.name,
            "python_version": ".".join(str(part) for part in sys.version_info[:3]),
            "os": platform.system(),
            "pointer_bits": pointer_bytes * 8,
        },
        "candidate_base_types": base_types,
        "aggregates": {
            "LARGE_INTEGER": layout(LARGE_INTEGER),
            "IO_COUNTERS": layout(IO_COUNTERS),
            "JOBOBJECT_BASIC_LIMIT_INFORMATION": layout(JOBOBJECT_BASIC_LIMIT_INFORMATION),
            "JOBOBJECT_EXTENDED_LIMIT_INFORMATION": layout(JOBOBJECT_EXTENDED_LIMIT_INFORMATION),
        },
        "width_conflicts": width_conflicts,
        "unverified": [
            "DUMMYSTRUCTNAME macro expansion and nested member aliases: NOT_FIXED",
            "Python typedef mappings and target C ABI alignment/padding: NOT_FIXED",
            "Windows calling convention and DLL interoperation: NOT_CHECKED",
            "Job setting/readback, cleanup, total wall clock, and AUTH-155: NOT_CHECKED",
        ],
    }
    print(json.dumps(result, ensure_ascii=True, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    main()
