"""Prepare and run the single AAR guest controller; no implicit runtime authority.

Preparation reuses full prepared source trees read-only. Only a fresh output
folder is host-writable. launch() requires a separately supplied Owner grant.
"""
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import time
import uuid
import xml.etree.ElementTree as ET

from current_product_apk_inventory import _checked_stat
from current_product_producer_entry import PINS
from producer_qualification_plan import TOOL_FILES
from producer_boundary_binding import bind_entry, ENTRY_SHA256
import sandbox_host_observation as observation


HERE = Path(__file__).resolve().parent
LIMITS = dict(memory_mb=6144, guest_seconds=1800, host_seconds=2100,
              cleanup_seconds=45, output_bytes=2 * 1024**3)


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def put(path, data):
    with Path(path).open('x', encoding='utf-8', newline='\n') as stream:
        json.dump(data, stream, indent=2)


def configuration(root, mappings, nonce):
    root = Path(root)
    tree = ET.Element('Configuration')
    for name in ('Networking', 'ClipboardRedirection', 'AudioInput', 'VideoInput',
                 'PrinterRedirection', 'vGPU'):
        ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'MemoryInMB').text = str(LIMITS['memory_mb'])
    folders = ET.SubElement(tree, 'MappedFolders')
    all_maps = [*mappings, dict(host=str(root/'probe'), guest='C:/Probe', readonly=True),
                dict(host=str(root/'output'), guest='C:/ProbeOutput', readonly=False)]
    for item in all_maps:
        folder = ET.SubElement(folders, 'MappedFolder')
        for name, value in (('HostFolder', item['host']), ('SandboxFolder', item['guest']),
                            ('ReadOnly', str(item['readonly']).lower())):
            ET.SubElement(folder, name).text = value
    ET.SubElement(ET.SubElement(tree, 'LogonCommand'), 'Command').text = (
        r'C:\Probe\ProducerSupervisor.exe ' + nonce)
    return ET.tostring(tree, encoding='unicode') + '\n'


def prepare(root, prepared_inputs, entry_file):
    """Copy manifests/controller sources and compile with existing csc; no VM/SDK."""
    root, prepared_inputs, entry_file = map(lambda p: Path(p).resolve(), (root, prepared_inputs, entry_file))
    if root.exists():
        raise FileExistsError('Candidate already exists; preserve it')
    entry_raw = entry_file.read_bytes()
    sources = ['producer_process_boundary.cs', 'producer_supervisor.cs',
               'producer_output.init.gradle', 'producer_boundary_binding.py', 'producer_supervisor.py']
    boundary = (HERE/sources[0]).read_bytes()
    binding = bind_entry(entry_raw, boundary)
    inventories = [('private-flutter-complete-inventory-private.json', PINS['flutter'], 'flutter-inventory.json'),
                   ('private-project-inventory-private.json', PINS['project'], 'project-inventory.json')]
    for name, expected, _ in inventories:
        if sha(prepared_inputs/name) != expected:
            raise ValueError('Prepared full inventory identity differs')
    layout = json.loads((prepared_inputs/'production-layout-private.json').read_bytes())
    # Reuse the already tested app-local CMake tree, including its three DLLs.
    # This is an input mapping change, not another tool-version execution.
    import cmake_vc_candidate as cmake
    cmake.verify_private_tree()
    layout['readonly_mappings']['android_cmake_3_22_1']['host'] = str(cmake.PRIVATE_CMAKE)
    mappings = list(layout['readonly_mappings'].values())
    if any(item['readonly'] is not True for item in mappings):
        raise ValueError('Source mappings must stay read-only')
    mappings += [dict(host=layout[key]['host'], guest=guest, readonly=True) for key, guest in
                 [('owned_flutter','C:/Inputs/PreparedFlutter'), ('owned_project','C:/Inputs/PreparedProject')]]
    for item in mappings:
        _checked_stat(Path(item['host']))
    declared_file = prepared_inputs/'complete-declared-input-trees-private.json'
    if sha(declared_file) != '0b34a527161803e5b783705c3fc07b7fcf5e1818b064b3e42bd5355ea0b14af9':
        raise ValueError('Declared input inventory differs')
    declared = json.loads(declared_file.read_bytes())
    native_inputs = [row for row in declared['files'] if
                     row['relative_path'] in TOOL_FILES.get(row['role'], ()) and row['role'] != 'android_cmake_3_22_1']
    cmake_inventory = json.loads(cmake.MATERIALIZATION.read_bytes())['inventory']
    native_inputs += [row for row in cmake_inventory['files'] if row['relative_path'] in
                      ('bin/cmake.exe','bin/ninja.exe','bin/msvcp140.dll','bin/vcruntime140.dll','bin/vcruntime140_1.dll')]
    root.mkdir(); (root/'probe').mkdir(); (root/'output').mkdir()
    for name in sources:
        shutil.copyfile(HERE/name, root/'probe'/name)
    for name, _, target in inventories:
        shutil.copyfile(prepared_inputs/name, root/'probe'/target)
    (root/'probe'/'producer-entry.json').write_bytes(entry_raw)
    compiler = Path('C:/Windows/Microsoft.NET/Framework64/v4.0.30319/csc.exe')
    command = [str(compiler), '/nologo', '/warnaserror', '/target:exe', '/platform:x64',
               '/r:System.Web.Extensions.dll', '/main:ProducerSupervisor',
               '/out:' + str(root/'probe'/'ProducerSupervisor.exe'),
               *(str(root/'probe'/name) for name in sources[:2])]
    result = subprocess.run(command, capture_output=True, timeout=60)
    (root/'compiler.stdout').write_bytes(result.stdout); (root/'compiler.stderr').write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError('Controller compile failed; candidate preserved')
    nonce = uuid.uuid4().hex
    (root/'qualification.wsb').write_text(configuration(root, mappings, nonce), encoding='utf-8')
    shutil.copyfile(HERE/'windows_sandbox_launch.ps1', root/'launch.ps1')
    payload = {p.relative_to(root).as_posix():sha(p) for p in root.rglob('*') if p.is_file()}
    host_helpers = {str(Path(module.__file__).resolve()):sha(module.__file__) for module in
                    (observation, observation.original_cleanup)}
    host_helpers[str(Path(__file__).resolve())] = sha(__file__)
    contract = dict(kind='current-product-aar-producer', scope=root.name, host_root=str(root), nonce=nonce,
        binary_sha256=sha(root/'probe'/'ProducerSupervisor.exe'), producer_entry_sha256=ENTRY_SHA256,
        flutter_inventory_sha256=PINS['flutter'], project_inventory_sha256=PINS['project'],
        launch_request=binding['launch_request'], payload_sha256=payload, host_helpers=host_helpers,
        readonly_mappings=mappings, native_inputs=native_inputs, **LIMITS)
    put(root/'probe'/'run-contract.json', contract)
    put(root/'prepared.json', dict(status='CONTROLLER_PREPARED_NOT_AUTHORIZED',
        contract_sha256=sha(root/'probe'/'run-contract.json'), claim_created=False, G2=False))
    return contract


def _finish_host(root, launch, recorded, deadline):
    """Close only a fully bound owned session/server pair; reuse existing code."""
    current = observation.observe(timeout_seconds=min(15, max(1, deadline-time.monotonic())))
    put(root/'host-after-guest.json', current['rows'])
    if not current['rows']:
        return
    script = observation.render_corrected_cleanup(launch, recorded, current['rows'], str(root/'qualification.wsb'))
    (root/'close-owned.ps1').write_text(script, encoding='utf-8')
    result = subprocess.run(['pwsh','-NoProfile','-File',str(root/'close-owned.ps1')],
                            capture_output=True, timeout=min(45, max(1, deadline-time.monotonic())))
    (root/'close-owned.stdout').write_bytes(result.stdout); (root/'close-owned.stderr').write_bytes(result.stderr)
    after = observation.observe(timeout_seconds=min(15, max(1, deadline-time.monotonic())))
    put(root/'host-after-cleanup.json', after['rows'])
    if result.returncode or after['rows']:
        raise RuntimeError('Owned Sandbox cleanup not verified; preserve STOP')


def preflight(root, contract):
    """Check live inputs/resources before consuming the grant; no SDK process."""
    for folder in (root, root/'probe', root/'output'):
        _checked_stat(folder)
    for mapping in contract['readonly_mappings']:
        _checked_stat(Path(mapping['host']))
    for row in contract['native_inputs']:
        path = Path(row['path']); info = _checked_stat(path)
        if (info.st_size != row['bytes'] or
                {'device':info.st_dev,'inode':info.st_ino} != row['file_id'] or sha(path) != row['sha256']):
            raise ValueError('Native input identity changed: ' + str(path))
    result = subprocess.run(['pwsh','-NoProfile','-NonInteractive','-Command',
        "$ErrorActionPreference='Stop'; [ordered]@{available_mib=[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024); free_disk_bytes=[long](Get-PSDrive C).Free}|ConvertTo-Json -Compress"],
        capture_output=True, timeout=20)
    if result.returncode:
        raise RuntimeError('Current resource observation failed')
    snapshot = json.loads(result.stdout.decode('utf-8-sig'))
    put(root/('resource-preflight-'+uuid.uuid4().hex+'.json'), snapshot)
    if snapshot['available_mib'] < contract['memory_mb']+4096 or snapshot['free_disk_bytes'] < 12*1024**3:
        raise RuntimeError('Current memory/disk insufficient; claim not consumed')


def output_size(folder, limit):
    """Bounded sampling, not an OS disk quota; STOP on overflow or redirects."""
    pending=[Path(folder)]; total=entries=0
    while pending:
        current=pending.pop(); _checked_stat(current)
        with os.scandir(current) as items:
            for item in items:
                entries+=1
                if entries>50000:
                    raise RuntimeError('Output entry bound exceeded')
                try:
                    info=_checked_stat(Path(item.path))
                except FileNotFoundError:
                    continue  # Normal atomic .pending -> final publication.
                if stat.S_ISDIR(info.st_mode):
                    pending.append(Path(item.path))
                else:
                    total+=info.st_size
                    if total>limit:
                        raise RuntimeError('Sampled output byte bound exceeded')
    return total


def launch(root):
    """One explicit grant, one irreversible claim, one VM launch. Never retry."""
    root = Path(root).resolve()
    contract_raw = (root/'probe'/'run-contract.json').read_bytes()
    contract = json.loads(contract_raw)
    if str(root) != contract['host_root']:
        raise ValueError('Candidate cannot move to renew its attempt')
    if (root/'launch.claim.json').exists() or (root/'probe'/'launch.claim.json').exists():
        raise RuntimeError('This attempt is already consumed')
    grant_path = root/'probe'/'owner-grant.json'
    grant = json.loads(grant_path.read_bytes())
    digest = hashlib.sha256(contract_raw).hexdigest()
    if (grant.get('authorized') is not True or grant.get('contract_sha256') != digest
            or type(grant.get('max_attempts')) is not int or grant['max_attempts'] != 1):
        raise ValueError('Explicit independent one-attempt Owner grant required')
    for name, expected in contract['payload_sha256'].items():
        if sha(root/name) != expected:
            raise ValueError('Frozen execution payload changed: ' + name)
    expected_probe={name for name in contract['payload_sha256'] if name.startswith('probe/')}
    expected_probe.update(('probe/run-contract.json','probe/owner-grant.json'))
    if {p.relative_to(root).as_posix() for p in (root/'probe').iterdir()} != expected_probe:
        raise ValueError('Unexpected executable input in the frozen probe folder')
    for path, expected in contract['host_helpers'].items():
        if sha(path) != expected:
            raise ValueError('Frozen host helper changed: ' + path)
    preflight(root, contract)
    if observation.observe()['rows']:
        raise RuntimeError('Existing Sandbox is not owned by this candidate')
    if any((root/'output').iterdir()):
        raise RuntimeError('Fresh output required')
    claim = dict(contract_sha256=digest, grant_sha256=sha(grant_path), attempt=1,
                 refundable=False, utc=datetime.now(timezone.utc).isoformat())
    # Both files use exclusive creation. Any error or launch failure stays spent.
    start = time.monotonic()
    put(root/'launch.claim.json', claim)
    put(root/'probe'/'launch.claim.json', claim)
    deadline = start + contract['host_seconds']
    launch_info = None; recorded = []; proof = None
    try:
        result = subprocess.run(['pwsh','-NoProfile','-File',str(root/'launch.ps1'),
            '-ConfigPath',str(root/'qualification.wsb')],capture_output=True,timeout=30)
        (root/'launcher.stdout').write_bytes(result.stdout); (root/'launcher.stderr').write_bytes(result.stderr)
        if result.returncode:
            raise RuntimeError('VM launch failed; attempt consumed')
        launch_info = json.loads(result.stdout.decode('utf-8-sig')); put(root/'launched.json', launch_info)
        while time.monotonic() < deadline:
            output_size(root/'output',contract['output_bytes'])
            current = observation.observe(timeout_seconds=min(15,max(1,deadline-time.monotonic())))['rows']
            if time.monotonic() >= deadline:
                raise TimeoutError('Host deadline crossed during observation; attempt consumed')
            if len(current)==2 and {p['Name'] for p in current}=={'WindowsSandboxRemoteSession.exe','WindowsSandboxServer.exe'} and not recorded:
                recorded=current; put(root/'host-recorded-pair.json',recorded)
            terminal = [name for name in ('failure.json','watchdog.json','result.json') if (root/'output'/name).exists()]
            if terminal:
                if terminal != ['result.json']:
                    raise RuntimeError('Guest STOP/failure; attempt consumed')
                proof = json.loads((root/'output'/'result.json').read_bytes())
                if (proof.get('nonce') != contract['nonce'] or
                        proof.get('status') != 'AAR_PRODUCER_EXIT0_OUTPUT_EXPORTED' or
                        type(proof.get('root_exit')) is not int or proof['root_exit'] != 0 or
                        type(proof.get('elapsed_ms')) is not int or
                        not 0 <= proof['elapsed_ms'] < contract['guest_seconds']*1000):
                    raise RuntimeError('Guest producer result binding failed')
                break
            time.sleep(min(1,max(0,deadline-time.monotonic())))
        if proof is None:
            raise TimeoutError('Host deadline; attempt consumed')
    except Exception as error:
        put(root/'STOP.json',dict(reason=str(error),attempt_consumed=True))
        raise
    finally:
        if launch_info is not None:
            try:
                _finish_host(root,launch_info,recorded,time.monotonic()+contract['cleanup_seconds'])
            except Exception as error:
                if not (root/'STOP.json').exists():
                    put(root/'STOP.json',dict(reason=str(error),attempt_consumed=True))
                raise
    if any((root/'output'/name).exists() for name in ('failure.json','watchdog.json')):
        put(root/'STOP.json',dict(reason='late guest failure/watchdog',attempt_consumed=True))
        raise RuntimeError('Late guest STOP; result not accepted')
    output_size(root/'output',contract['output_bytes'])
    if time.monotonic() >= deadline:
        put(root/'STOP.json',dict(reason='Host deadline includes collection and cleanup',attempt_consumed=True))
        raise TimeoutError('Host deadline exceeded during collection/cleanup')
    return proof
