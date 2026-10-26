"""Read-only task-process/TCP/UDP endpoint sampling, not packet observation.

UDP owner-PID tables provide local endpoint ownership only; remote=None cannot
prove datagram transmission. TCP remote/state rows do not prove payload transfer.
No firewall, ETW or global changes.
"""
import ctypes as c
from ctypes import wintypes as w
import ipaddress
import os
import socket


class ProcessEntry(c.Structure):
    _fields_ = [('size', w.DWORD), ('usage', w.DWORD), ('pid', w.DWORD),
                ('heap', c.c_size_t), ('module', w.DWORD), ('threads', w.DWORD),
                ('parent', w.DWORD), ('priority', w.LONG), ('flags', w.DWORD),
                ('name', w.WCHAR * 260)]


class Tcp4(c.Structure):
    _fields_ = [(n, w.DWORD) for n in ('state', 'local', 'local_port', 'remote', 'remote_port', 'pid')]


class Tcp6(c.Structure):
    _fields_ = [('local', c.c_ubyte * 16), ('local_scope', w.DWORD),
                ('local_port', w.DWORD), ('remote', c.c_ubyte * 16),
                ('remote_scope', w.DWORD), ('remote_port', w.DWORD),
                ('state', w.DWORD), ('pid', w.DWORD)]


class Udp4(c.Structure):
    _fields_ = [(n, w.DWORD) for n in ('local', 'local_port', 'pid')]


class Udp6(c.Structure):
    _fields_ = [('local', c.c_ubyte * 16), ('scope', w.DWORD),
                ('local_port', w.DWORD), ('pid', w.DWORD)]


class Observer:
    def __init__(self):
        if os.name != 'nt':
            raise RuntimeError('WINDOWS_OBSERVER_REQUIRED')
        self.kernel = c.WinDLL('kernel32', use_last_error=True)
        self.ip = c.WinDLL('iphlpapi', use_last_error=True)
        self.kernel.CreateToolhelp32Snapshot.argtypes = [w.DWORD, w.DWORD]
        self.kernel.CreateToolhelp32Snapshot.restype = w.HANDLE
        self.kernel.Process32FirstW.argtypes = [w.HANDLE, c.POINTER(ProcessEntry)]
        self.kernel.Process32NextW.argtypes = [w.HANDLE, c.POINTER(ProcessEntry)]
        self.kernel.CloseHandle.argtypes = [w.HANDLE]
        self.kernel.OpenProcess.argtypes = [w.DWORD, w.BOOL, w.DWORD]
        self.kernel.OpenProcess.restype = w.HANDLE
        self.kernel.QueryFullProcessImageNameW.argtypes = [w.HANDLE, w.DWORD, w.LPWSTR, c.POINTER(w.DWORD)]
        self.known = set()

    def image_path(self, pid):
        handle = self.kernel.OpenProcess(0x1000, False, pid)
        if not handle:
            return None  # The sampled process may already have exited.
        try:
            buffer = c.create_unicode_buffer(32768); size = w.DWORD(len(buffer))
            return buffer.value if self.kernel.QueryFullProcessImageNameW(handle, 0, buffer, c.byref(size)) else None
        finally:
            self.kernel.CloseHandle(handle)

    def sample(self, root_pid):
        handle = self.kernel.CreateToolhelp32Snapshot(2, 0)
        if handle == c.c_void_p(-1).value:
            raise OSError('PROCESS_SNAPSHOT_FAILED')
        rows = []
        try:
            item = ProcessEntry(); item.size = c.sizeof(item)
            c.set_last_error(0)
            ok = self.kernel.Process32FirstW(handle, c.byref(item))
            while ok:
                rows.append((int(item.pid), int(item.parent), item.name))
                c.set_last_error(0)
                ok = self.kernel.Process32NextW(handle, c.byref(item))
            if c.get_last_error() != 18:  # ERROR_NO_MORE_FILES is the only normal end.
                raise OSError('PROCESS_ENUMERATION_FAILED')
        finally:
            self.kernel.CloseHandle(handle)
        if not any(pid == root_pid for pid, _, _ in rows):
            raise ProcessLookupError('ROOT_PROCESS_NOT_OBSERVABLE')
        self.known.add(root_pid)
        for _ in range(len(rows)):
            descendants = {pid for pid, parent, _ in rows if parent in self.known}
            if descendants <= self.known:
                break
            self.known.update(descendants)
        processes = [{'pid': pid, 'parent': parent, 'image': name, 'imagePath': self.image_path(pid)}
                     for pid, parent, name in rows if pid in self.known]
        sockets = []
        for family, tcp, structure in [(2, True, Tcp4), (23, True, Tcp6),
                                       (2, False, Udp4), (23, False, Udp6)]:
            function = self.ip.GetExtendedTcpTable if tcp else self.ip.GetExtendedUdpTable
            size = w.ULONG(0)
            status = function(None, c.byref(size), False, family, 5 if tcp else 1, 0)
            if status not in (0, 122):
                raise OSError('NETWORK_TABLE_SIZE_FAILED:' + str(status))
            buffer = c.create_string_buffer(size.value)
            status = function(buffer, c.byref(size), False, family, 5 if tcp else 1, 0)
            if status != 0:
                raise OSError('NETWORK_TABLE_READ_FAILED:' + str(status))
            count = c.cast(buffer, c.POINTER(w.DWORD))[0]
            for i in range(count):
                row = structure.from_buffer_copy(buffer, 4 + i * c.sizeof(structure))
                if row.pid not in self.known:
                    continue
                if tcp and row.state == 2:  # A listening socket has no remote attempt.
                    continue
                address = None
                if tcp:
                    address = (socket.inet_ntoa(int(row.remote).to_bytes(4, 'little'))
                               if family == 2 else str(ipaddress.IPv6Address(bytes(row.remote))))
                    if ipaddress.ip_address(address).is_unspecified:
                        continue
                sockets.append({'pid': int(row.pid), 'protocol': 'TCP' if tcp else 'UDP',
                                'remote': address, 'state': int(row.state) if tcp else None})
        return processes, sockets
