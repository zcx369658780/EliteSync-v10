"""Read-only task-process/TCP/UDP endpoint sampling, not packet observation.

UDP owner-PID tables provide local endpoint ownership only; remote=None cannot
prove datagram transmission. TCP remote/state rows do not prove payload transfer.
No firewall, ETW or global changes.
"""
import ipaddress
import os
import socket
import time
import json
import hashlib


def _load_native_types():
    global c, w, ProcessEntry, Tcp4, Tcp6, Udp4, Udp6
    import ctypes as c
    from ctypes import wintypes as w
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
    def __init__(self, *, kernel=None, ip=None, get_error=None, clock=None, event_sink=None, native_api=None, types_api=None):
        self.known = set()
        self.instances = {}
        self.get_error = get_error
        self.clock = clock or time.monotonic
        self.event_sink = event_sink
        self.last_failure = None
        self.root_identity = None
        self.parents = {}
        self.root_job_associated = False
        self.snapshot_monotonic = None
        if kernel is not None:
            self.kernel = kernel
            self.ip = ip
            self.c = native_api
            self.w = types_api
            return
        if os.name != 'nt':
            raise RuntimeError('WINDOWS_OBSERVER_REQUIRED')
        _load_native_types()
        self.c = c
        self.w = w
        self.get_error = get_error or c.get_last_error
        self.kernel = c.WinDLL('kernel32', use_last_error=True)
        self.ip = c.WinDLL('iphlpapi', use_last_error=True)
        self.kernel.CreateToolhelp32Snapshot.argtypes = [w.DWORD, w.DWORD]
        self.kernel.CreateToolhelp32Snapshot.restype = w.HANDLE
        self.kernel.Process32FirstW.argtypes = [w.HANDLE, c.POINTER(ProcessEntry)]
        self.kernel.Process32NextW.argtypes = [w.HANDLE, c.POINTER(ProcessEntry)]
        self.kernel.CloseHandle.argtypes = [w.HANDLE]
        self.kernel.CloseHandle.restype = w.BOOL
        self.kernel.OpenProcess.argtypes = [w.DWORD, w.BOOL, w.DWORD]
        self.kernel.OpenProcess.restype = w.HANDLE
        self.kernel.QueryFullProcessImageNameW.argtypes = [w.HANDLE, w.DWORD, w.LPWSTR, c.POINTER(w.DWORD)]
        self.kernel.QueryFullProcessImageNameW.restype = w.BOOL
        self.kernel.GetProcessTimes.argtypes = [w.HANDLE, *([c.POINTER(w.FILETIME)] * 4)]
        self.kernel.GetProcessTimes.restype = w.BOOL

    def _error(self):
        # Called immediately after a failed API, before any other native call.
        try:
            value = self.get_error()
            return value if isinstance(value, int) and value > 0 else 'API_ERROR_UNKNOWN'
        except Exception:
            return 'API_ERROR_UNKNOWN'

    def _fail(self, event, stage, error=None):
        event.update(apiFailureStage=stage, apiError=error,
                     failureReason='PROCESS_INSTANCE_PATH_UNREADABLE')
        self.last_failure = event
        try:
            if len(json.dumps(event).encode('utf-8')) > 16384:
                raise ValueError('DIAGNOSTIC_EVENT_TOO_LARGE')
            if self.event_sink is not None:
                self.event_sink(event)
        except Exception as exc:
            raise OSError('DIAGNOSTIC_WRITE_FAILED') from exc
        raise OSError('PROCESS_INSTANCE_PATH_UNREADABLE:' + stage)

    def process_identity(self, pid, parent, name, root_pid, *, snapshot_seen=True):
        c, w = self.c, self.w
        chain=[];seen=set();ancestor=parent
        while ancestor is not None and ancestor not in seen and len(chain)<64:
            seen.add(ancestor);chain.append(ancestor);ancestor=self.parents.get(ancestor)
        observed_at = self.clock()
        snapshot_image = str(name) if name is not None else None
        event = dict(phase='PROCESS_IDENTITY_FAILURE', sampleMonotonic=observed_at,
                     snapshotSampleMonotonic=(self.snapshot_monotonic if self.snapshot_monotonic is not None else observed_at),
                     snapshotImage=snapshot_image[:260] if snapshot_image is not None else None,
                     snapshotImageLength=len(snapshot_image) if snapshot_image is not None else None,
                     imageQueryStartedMonotonic=None,imageQueryMonotonic=None,
                     imagePathPrefix=None,imagePathLength=None,imagePathSha256=None,
                     pid=pid, parent=parent, parentChain=chain, rootPid=root_pid,
                     rootJobAssociated=self.root_job_associated,
                     rootCreationFiletime=self.root_identity, snapshotSeen=snapshot_seen,
                     imagePathQueried=False, creationFiletime=None,
                     creationIdentityAvailable=False,
                     ancestryEvidence='SAMPLED_PARENT_CHAIN_NOT_INITIAL_OWNERSHIP')
        handle = self.kernel.OpenProcess(0x1000, False, pid)
        if not handle:
            error = self._error()
            self._fail(event, 'OpenProcess', error)
        failure = None
        path = None
        try:
            buffer = c.create_unicode_buffer(32768)
            size = w.DWORD(len(buffer))
            event['imagePathQueried'] = True
            event['imageQueryStartedMonotonic'] = self.clock()
            ok = self.kernel.QueryFullProcessImageNameW(handle, 0, buffer, c.byref(size))
            if not ok:
                error = self._error()
                failure = ('QueryFullProcessImageNameW', error)
                event['imageQueryApiError'] = error
            elif not buffer.value:
                failure = ('IMAGE_PATH_EMPTY', None)
            else:
                path = buffer.value
                event['imagePathPrefix'] = path[:1024]
                event['imagePathLength'] = len(path)
                event['imagePathSha256'] = hashlib.sha256(path.encode('utf-8',errors='surrogatepass')).hexdigest()
            # Any failed query error was saved before this clock read or GetProcessTimes.
            event['imageQueryMonotonic'] = self.clock()
            times = [w.FILETIME() for _ in range(4)]
            ok = self.kernel.GetProcessTimes(handle, *[c.byref(t) for t in times])
            if not ok:
                error = self._error()
                event['creationFailureStage'] = 'GetProcessTimes'
                event['creationApiError'] = error
                failure = failure or ('GetProcessTimes', error)
            else:
                creation = times[0].dwHighDateTime << 32 | times[0].dwLowDateTime
                event['creationFiletime'] = creation or None
                event['creationIdentityAvailable'] = bool(creation)
                if not creation:
                    failure = failure or ('CREATION_IDENTITY_UNKNOWN', None)
                elif pid == root_pid and self.root_identity is not None and self.root_identity != creation:
                    failure = failure or ('ROOT_INSTANCE_CHANGED', None)
                elif pid in self.instances and self.instances[pid] != creation:
                    failure = failure or ('PID_INSTANCE_CHANGED', None)
            if failure:
                self._fail(event, *failure)
            self.instances[pid] = event['creationFiletime']
            if pid == root_pid:
                self.root_identity = event['creationFiletime']
            return dict(pid=pid, parent=parent, image=name, imagePath=path,
                        creationFiletime=event['creationFiletime'],
                        ancestryEvidence=event['ancestryEvidence'])
        except Exception:
            if self.last_failure is event:
                raise
            self._fail(event, 'IDENTITY_QUERY_EXCEPTION', 'API_ERROR_UNKNOWN')
        finally:
            closed=self.kernel.CloseHandle(handle)
            if closed is False or closed == 0:
                error=self._error()
                self._fail(event, 'CloseHandle', error)

    def image_path(self, pid):
        # Compatibility helper remains fail-closed; None is never an exit signal.
        return self.process_identity(pid, None, None, pid, snapshot_seen=False)['imagePath']

    def _snapshot_rows(self):
        c = self.c
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
        return rows

    def sample(self, root_pid):
        self.snapshot_monotonic = self.clock()
        try:
            rows = self._snapshot_rows()
        except Exception:
            self._fail(dict(phase='PROCESS_SNAPSHOT_FAILURE', sampleMonotonic=self.clock(),
                            pid=root_pid, parent=None, rootPid=root_pid,
                            rootCreationFiletime=self.root_identity, snapshotSeen=False,
                            imagePathQueried=False, creationFiletime=None,
                            creationIdentityAvailable=False), 'PROCESS_SNAPSHOT_OR_ENUMERATION')
        self.parents = {pid: parent for pid, parent, _ in rows}
        if not any(pid == root_pid for pid, _, _ in rows):
            self._fail(dict(phase='ROOT_SNAPSHOT_FAILURE',sampleMonotonic=self.clock(),
                            pid=root_pid,parent=None,rootPid=root_pid,
                            rootCreationFiletime=self.root_identity,snapshotSeen=False,
                            imagePathQueried=False,creationFiletime=None,
                            creationIdentityAvailable=False),'ROOT_PROCESS_NOT_OBSERVABLE')
        self.known.add(root_pid)
        for _ in range(len(rows)):
            descendants = {pid for pid, parent, _ in rows if parent in self.known}
            if descendants <= self.known:
                break
            self.known.update(descendants)
        processes = [self.process_identity(pid, parent, name, root_pid)
                     for pid, parent, name in rows if pid in self.known]
        return processes, self._socket_rows()

    def _socket_rows(self):
        c, w = self.c, self.w
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
        return sockets
