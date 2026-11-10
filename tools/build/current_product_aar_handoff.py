"""Verify and copy a generated Maven repository into a fresh private directory.

This checks bytes, coordinates and the requested main AAR's arm64 header. It
does not attest producer provenance, complete ELF validity, offline resolution,
readonly guest mappings, process qualification or any build/install authority.
Flutter's pinned aar_init_script.gradle sets every publication from buildNumber.
"""
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import PurePosixPath
import re
import stat
import xml.etree.ElementTree as ET
import zipfile

from current_product_apk_inventory import _absolute_path, _checked_stat, _identity, _regular
from current_product_tree_inventory import inventory_trees


GROUP = 'com.elitesync.flutter_elitesync_module'
ARTIFACT = 'flutter_release'
_VERSION = re.compile(r'1\.0-v1015-[a-f0-9]{12}-[a-f0-9]{12}')
_TOKEN = re.compile(r'[A-Za-z0-9_][A-Za-z0-9_.+\-]*')


@contextmanager
def _bound_file(root, row):
    """Reopen the inventoried identity and hash that handle again after use."""
    path = root / row['relative_path']
    expected = _checked_stat(path)
    _regular(expected)
    if ({'device': expected.st_dev, 'inode': expected.st_ino} != row['file_id']
            or expected.st_size != row['bytes']):
        raise ValueError('inventoried file identity changed')
    fd = os.open(path, os.O_RDONLY | getattr(os, 'O_BINARY', 0) | getattr(os, 'O_NOFOLLOW', 0))
    with os.fdopen(fd, 'rb') as stream:
        before = os.fstat(stream.fileno())
        _regular(before)
        if _identity(before) != _identity(expected):
            raise ValueError('opened file identity changed')
        yield stream
        stream.seek(0)
        digest, count = hashlib.sha256(), 0
        while chunk := stream.read(min(1024 * 1024, row['bytes'] - count + 1)):
            count += len(chunk)
            if count > row['bytes']:
                raise ValueError('inventoried file grew')
            digest.update(chunk)
        after, current = os.fstat(stream.fileno()), _checked_stat(path)
        _regular(after)
        _regular(current)
        if (count != row['bytes'] or digest.hexdigest() != row['sha256']
                or _identity(after) != _identity(before) or _identity(current) != _identity(before)):
            raise ValueError('inventoried file content or metadata changed')


def _token(value):
    if (type(value) is not str or not _TOKEN.fullmatch(value)
            or '..' in value or value.endswith('-SNAPSHOT') or value in ('LATEST', 'RELEASE')):
        raise ValueError('literal pinned Maven coordinates are required')
    return value


def _coordinate(element):
    values = []
    for name in ('groupId', 'artifactId', 'version'):
        fields = element.findall('{*}' + name)
        if len(fields) != 1:
            raise ValueError('POM coordinates must have unique direct fields')
        value = _token(fields[0].text)
        if name == 'version' and ('+' in value or value.lower().startswith('latest.')):
            raise ValueError('Gradle dynamic version selectors are not pinned')
        values.append(value)
    return tuple(values)


def _aar_header(root, row):
    with _bound_file(root, row) as stream, zipfile.ZipFile(stream) as archive:
        members = archive.infolist()
        if len(members) > 200000 or sum(info.file_size for info in members) > 2 * 1024**3:
            raise ValueError('AAR archive bounds exceeded')
        names = set()
        for info in members:
            name = info.filename.rstrip('/')
            parts = name.split('/')
            if (not name or '\\' in name or ':' in name or name.startswith('/')
                    or any(part in ('', '.', '..') for part in parts)
                    or name.casefold() in names or stat.S_ISLNK(info.external_attr >> 16)
                    or info.flag_bits & 1):
                raise ValueError('ambiguous, linked or encrypted AAR member')
            names.add(name.casefold())
            if parts[0] == 'jni' and len(parts) > 1 and parts[1] != 'arm64-v8a':
                raise ValueError('AAR contains a different native ABI')
        for required in ('AndroidManifest.xml', 'classes.jar', 'jni/arm64-v8a/libapp.so'):
            if required not in archive.namelist() or archive.getinfo(required).file_size <= 0:
                raise ValueError('main AAR required content is missing')
        for info in members:
            if info.filename.startswith('jni/') and info.filename.endswith('.so'):
                with archive.open(info) as native:
                    header = native.read(64)
                if len(header) != 64 or header[:6] != b'\x7fELF\x02\x01' or int.from_bytes(header[18:20], 'little') != 183:
                    raise ValueError('JNI library is not an ELF64 little-endian AArch64 header')


def verify_repository(repository, expected_version, *, file_limit, byte_limit):
    """Return a content manifest, or reject; no filesystem writes or execution."""
    if type(expected_version) is not str or not _VERSION.fullmatch(expected_version):
        raise ValueError('source-and-selected-inventory publication version required')
    root = _absolute_path(repository)
    inventory = inventory_trees(roots={'aar_repo': str(root)}, file_limit=file_limit,
                                entry_limit=file_limit * 8, byte_limit=byte_limit, depth_limit=32)
    rows = {row['relative_path']: row for row in inventory['files']}
    publications, dependencies = {}, set()
    for relative, row in rows.items():
        if not relative.endswith('.pom'):
            continue
        if row['bytes'] > 2 * 1024**2:
            raise ValueError('POM size limit exceeded')
        with _bound_file(root, row) as stream:
            raw = stream.read(2 * 1024**2 + 1)
        try:
            text = raw.decode('utf-8-sig')
        except UnicodeDecodeError as error:
            raise ValueError('only UTF-8 generated POMs are accepted') from error
        if '<!DOCTYPE' in text.upper() or '<!ENTITY' in text.upper() or '\x00' in text:
            raise ValueError('POM DTDs and entities are not allowed')
        try:
            document = ET.fromstring(text)
            if document.tag not in ('project', '{http://maven.apache.org/POM/4.0.0}project'):
                raise ValueError('POM root must be project')
            group, artifact, version = _coordinate(document)
            if len(document.findall('{*}packaging')) > 1:
                raise ValueError('duplicate POM packaging')
            packaging = document.findtext('{*}packaging', 'jar')
            prefix = group.replace('.', '/') + '/' + artifact + '/' + version + '/' + artifact + '-' + version
            if relative != prefix + '.pom' or version != expected_version or packaging not in ('aar', 'jar'):
                raise ValueError('POM location, version or packaging mismatch')
            binary = prefix + '.' + packaging
            if binary not in rows or rows[binary]['bytes'] <= 0:
                raise ValueError('POM publication binary is missing')
            coordinate = ':'.join((group, artifact, version))
            publications[coordinate] = binary
            for dependency in document.findall('{*}dependencies/{*}dependency'):
                dependencies.add(':'.join(_coordinate(dependency)))
        except ET.ParseError as error:
            raise ValueError('invalid POM XML') from error
    main = GROUP + ':' + ARTIFACT + ':' + expected_version
    if main not in publications or not publications[main].endswith('.aar'):
        raise ValueError('expected main AAR publication missing')
    _aar_header(root, rows[publications[main]])
    manifest = [{key: row[key] for key in ('relative_path', 'bytes', 'sha256')}
                for row in sorted(rows.values(), key=lambda item: item['relative_path'])]
    content_sha = hashlib.sha256(json.dumps(manifest, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    final = inventory_trees(roots={'aar_repo': str(root)}, file_limit=file_limit,
                            entry_limit=file_limit * 8, byte_limit=byte_limit, depth_limit=32)
    final_manifest = [{key: row[key] for key in ('relative_path', 'bytes', 'sha256')}
                      for row in sorted(final['files'], key=lambda item: item['relative_path'])]
    if manifest != final_manifest or inventory['directory_count'] != final['directory_count']:
        raise ValueError('repository changed during POM/AAR validation')
    return {'status': 'REPOSITORY_CONTENTS_VERIFIED_ONLY', 'coordinate': main,
            'repository': str(root), 'version': expected_version, 'files': len(rows),
            'bytes': inventory['total_bytes'], 'content_manifest': manifest,
            'content_manifest_sha256': content_sha, 'inventory': inventory,
            'main_aar_sha256': rows[publications[main]]['sha256'],
            'publications': sorted(publications), 'sampling_non_atomic': True,
            'external_dependencies': sorted(dependencies - publications.keys()),
            'producer_provenance_proven': False, 'offline_dependencies_proven': False,
            'readonly_guest_mapping_proven': False, 'execution_allowed': False, 'G2': False}


def stage_repository(repository, destination, task_root, expected_version, *, file_limit, byte_limit):
    """Copy verified bytes to a new direct child of the caller's private task root.

    Partial output is preserved on failure, never cleaned or treated as valid.
    A receipt is returned only after independent destination verification.
    """
    source, target, private = map(_absolute_path, (repository, destination, task_root))
    if (target.parent != private or not stat.S_ISDIR(_checked_stat(private).st_mode)
            or source.is_relative_to(private) or private.is_relative_to(source)):
        raise ValueError('fresh output must be inside a disjoint private task root')
    verified = verify_repository(str(source), expected_version, file_limit=file_limit, byte_limit=byte_limit)
    target.mkdir()  # exclusive; no replacement or deletion
    for row in verified['inventory']['files']:
        output = target / PurePosixPath(row['relative_path'])
        output.parent.mkdir(parents=True, exist_ok=True)
        _checked_stat(output.parent)
        with _bound_file(source, row) as stream, output.open('xb') as copied:
            count = 0
            while chunk := stream.read(min(1024 * 1024, row['bytes'] - count + 1)):
                count += len(chunk)
                if count > row['bytes']:
                    raise ValueError('source grew during copy')
                copied.write(chunk)
    final = verify_repository(str(target), expected_version, file_limit=file_limit, byte_limit=byte_limit)
    if final['content_manifest'] != verified['content_manifest']:
        raise ValueError('private repository differs from verified source')
    return {**final, 'status': 'PRIVATE_REPOSITORY_BYTES_VERIFIED',
            'source_content_manifest_sha256': verified['content_manifest_sha256']}
