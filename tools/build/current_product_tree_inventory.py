"""Bounded, read-only full inventories of explicitly declared directory trees.

No exclusions, copies, tool launches or qualification claims. Two enumerations
detect persistent membership/metadata drift; they are not an atomic snapshot or
a proof of the files a production build actually consumes.
"""
import os
import stat

from current_product_apk_inventory import (
    _absolute_path, _checked_stat, _regular, inventory_files,
)


def _metadata(info):
    return (info.st_dev, info.st_ino, info.st_mode, info.st_size,
            info.st_mtime_ns, info.st_nlink,
            getattr(info, 'st_file_attributes', 0))


def _enumerate(roots, file_limit, entry_limit, byte_limit, depth_limit):
    snapshot, files, total_bytes, directories = {}, [], 0, 0
    for role, root in roots.items():
        pending, role_files = [(root, 0)], 0
        while pending:
            path, depth = pending.pop()
            if depth > depth_limit:
                raise ValueError('tree depth limit exceeded')
            info = _checked_stat(path)
            key = str(path).casefold()
            if key in snapshot:
                raise ValueError('duplicate casefold tree path')
            snapshot[key] = _metadata(info)
            if len(snapshot) > entry_limit:
                raise ValueError('tree entry limit exceeded')
            if stat.S_ISDIR(info.st_mode):
                directories += 1
                # Bound queued paths as well as visited paths, including dirs.
                with os.scandir(path) as children:
                    for child in children:
                        if len(snapshot) + len(pending) >= entry_limit:
                            raise ValueError('tree entry limit exceeded')
                        pending.append((path / child.name, depth + 1))
            else:
                _regular(info)
                files.append((role, str(path)))
                role_files += 1
                total_bytes += info.st_size
                if len(files) > file_limit or total_bytes > byte_limit:
                    raise ValueError('aggregate tree file or byte limit exceeded')
        if not role_files:
            raise ValueError('declared input trees must contain files')
    return snapshot, sorted(files, key=lambda row: row[1].casefold()), directories


def inventory_trees(*, roots, file_limit, entry_limit, byte_limit, depth_limit):
    """Hash every file under disjoint named roots, or reject the entire result.

    Caller selects the exact roots and aggregate caps. Files and directories
    both count toward entry_limit; root depth is zero. Reparse paths, links,
    empty trees, filesystem roots and overlapping trees are rejected.
    """
    for cap in (file_limit, entry_limit, byte_limit, depth_limit):
        if type(cap) is not int or cap <= 0:
            raise ValueError('limits must be positive integers, excluding bool')
    if type(roots) is not dict or not roots:
        raise ValueError('a nonempty role-to-root dictionary is required')
    checked = {}
    for role, raw in roots.items():
        if type(role) is not str or not role.strip():
            raise ValueError('nonempty role required')
        root = _absolute_path(raw)
        if root.parent == root or not stat.S_ISDIR(_checked_stat(root).st_mode):
            raise ValueError('only non-root directories are allowed')
        # Casefold also rejects alias spellings on a case-sensitive test host.
        key = str(root).casefold()
        for other in checked.values():
            previous = str(other).casefold()
            if (key == previous or key.startswith(previous + os.sep)
                    or previous.startswith(key + os.sep)):
                raise ValueError('declared trees must not overlap')
        checked[role] = root
    before, entries, directories = _enumerate(
        checked, file_limit, entry_limit, byte_limit, depth_limit)
    result = inventory_files(entries, [str(p) for p in checked.values()],
                             file_limit, byte_limit)
    after, final_entries, final_directories = _enumerate(
        checked, file_limit, entry_limit, byte_limit, depth_limit)
    if before != after or entries != final_entries or directories != final_directories:
        raise ValueError('tree membership or metadata changed during inventory')
    for row in result['files']:
        row['relative_path'] = _absolute_path(row['path']).relative_to(
            checked[row['role']]).as_posix()
    return {**result, 'roots': {role: str(path) for role, path in checked.items()},
            'scope': 'COMPLETE_DECLARED_TREES_ONLY',
            'directory_count': directories, 'entry_count': len(before),
            'sampling_non_atomic': True, 'runtime_read_closure_proven': False,
            'native_tools_qualified': False}
