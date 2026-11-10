"""Read candidate ctypes layout only; never load a DLL or call an API."""

import ctypes
import json
import platform
import struct
import sys


# These are candidate Python types, not verified Windows ABI mappings.
DWORD = ctypes.c_ulong
WORD = ctypes.c_ushort
BOOL = ctypes.c_int
HANDLE = ctypes.c_void_p
POINTER_VALUE = ctypes.c_void_p


class STARTUPINFOW(ctypes.Structure):
    _fields_ = [
        ("cb", DWORD),
        ("lpReserved", POINTER_VALUE),
        ("lpDesktop", POINTER_VALUE),
        ("lpTitle", POINTER_VALUE),
        ("dwX", DWORD),
        ("dwY", DWORD),
        ("dwXSize", DWORD),
        ("dwYSize", DWORD),
        ("dwXCountChars", DWORD),
        ("dwYCountChars", DWORD),
        ("dwFillAttribute", DWORD),
        ("dwFlags", DWORD),
        ("wShowWindow", WORD),
        ("cbReserved2", WORD),
        ("lpReserved2", POINTER_VALUE),
        ("hStdInput", HANDLE),
        ("hStdOutput", HANDLE),
        ("hStdError", HANDLE),
    ]


class PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [
        ("hProcess", HANDLE),
        ("hThread", HANDLE),
        ("dwProcessId", DWORD),
        ("dwThreadId", DWORD),
    ]


def layout(structure):
    return {
        "size": ctypes.sizeof(structure),
        "offsets": {
            name: getattr(structure, name).offset for name, _ in structure._fields_
        },
    }


def main():
    sizes = {
        "BYTE_candidate_c_ubyte": ctypes.sizeof(ctypes.c_ubyte),
        "BOOL_candidate_c_int": ctypes.sizeof(BOOL),
        "DWORD_candidate_c_ulong": ctypes.sizeof(DWORD),
        "HANDLE_candidate_c_void_p": ctypes.sizeof(HANDLE),
        "POINTER_candidate_c_void_p": ctypes.sizeof(POINTER_VALUE),
        "WCHAR_candidate_c_wchar": ctypes.sizeof(ctypes.c_wchar),
        "WORD_candidate_c_ushort": ctypes.sizeof(WORD),
    }
    fixed_widths_match = (
        sizes["BYTE_candidate_c_ubyte"] == 1
        and sizes["DWORD_candidate_c_ulong"] == 4
        and sizes["WCHAR_candidate_c_wchar"] == 2
        and sizes["WORD_candidate_c_ushort"] == 2
    )
    result = {
        "classification": "STATIC_LAYOUT_ONLY",
        "status": "MEASURED" if platform.system() == "Windows" and fixed_widths_match else "UNAVAILABLE",
        "interpreter": {
            "implementation": platform.python_implementation(),
            "version": platform.python_version(),
        },
        "os": platform.system(),
        "pointer_size_bytes": struct.calcsize("P"),
        "candidate_type_sizes_bytes": sizes,
        "candidate_structures": {
            "STARTUPINFOW": layout(STARTUPINFOW),
            "PROCESS_INFORMATION": layout(PROCESS_INFORMATION),
        },
        "unverified": [
            "Windows C ABI alignment and exact typedef-to-ctypes mapping",
            "target process bitness and layout",
            "calling convention and argtypes/restype",
            "string buffer mutability and lifetime",
            "process creation and failure cleanup",
            "Job behavior and process-tree cleanup",
            "hard total wall-clock bound",
        ],
    }
    json.dump(result, sys.stdout, ensure_ascii=True, sort_keys=True)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
