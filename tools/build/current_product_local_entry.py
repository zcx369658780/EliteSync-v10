"""Pure rendering of the pinned producer entry for caller-supplied local paths.

No directories, environment, tools, claims or processes are read or created.
The caller owns input identity checks beyond bind_entry and all execution gates.
"""
import json
from pathlib import PureWindowsPath
import re
import subprocess
from urllib.parse import unquote, urlsplit

from producer_boundary_binding import bind_entry
from sandbox_owned_session_cleanup import windows_arguments


# A drive embedded in an HTTPS URL or another path is not a guest path prefix.
_LEFT = r'(?<![\w/\\])'
_RIGHT = r'(?=$|[/\\\s\x22\x27;,)}\]])'
_GUEST = re.compile(_LEFT + r'C:[/\\](?:Inputs|BuildWork)' + _RIGHT, re.I)
_URI = r'file:///[^\s\x22\x27<>]+'


def _absolute(value):
    if type(value) is not str or not value or any(c in value for c in '\x00\r\n\x22\x27'):
        raise ValueError('unquoted absolute Windows path required')
    path = PureWindowsPath(value)
    if not path.is_absolute() or '..' in path.parts:
        raise ValueError('absolute Windows path without traversal required')
    return path.as_posix()


class _Remapper:
    def __init__(self, replacements):
        self.paths = {}
        for source, target in replacements.items():
            source, target = _absolute(source), _absolute(target)
            if not _GUEST.match(source) or _GUEST.search(target):
                raise ValueError('mapping must take a guest prefix to a local absolute path')
            key = source.casefold()
            if key in self.paths:
                raise ValueError('ambiguous duplicate Windows path prefix')
            self.paths[key] = target
        prefixes = sorted(self.paths, key=len, reverse=True)
        alternatives = [re.escape(prefix).replace('/', r'[/\\]') for prefix in prefixes]
        plain = '(?:' + '|'.join(alternatives) + ')' if alternatives else r'(?!)'
        self.plain = re.compile(_LEFT + plain + _RIGHT, re.I)
        self.tokens = re.compile('(?P<uri>' + _URI + ')|' + _LEFT + '(?P<plain>' + plain + ')' + _RIGHT, re.I)

    def _prefix(self, match):
        target = self.paths[match.group().replace('\\', '/').casefold()]
        # Keep drive-root targets absolute without introducing a double slash.
        return target.rstrip('/') if match.string[match.end():].startswith(('/', '\\')) else target

    def text(self, value):
        def substitute(match):
            if match.group('uri') is None:
                return self._prefix(match)
            uri = match.group('uri')
            # file:/// is the local-drive form used by the pinned package files.
            path = unquote(urlsplit(uri).path).lstrip('/')
            mapped = self.plain.sub(self._prefix, path)
            if mapped == path:
                if _GUEST.search(path):
                    raise ValueError('unmapped guest path in file URI')
                return uri
            suffix = '/' if path.endswith(('/', '\\')) else ''
            return PureWindowsPath(mapped).as_uri() + suffix

        result = self.tokens.sub(substitute, value)
        if _GUEST.search(result):
            raise ValueError('unmapped guest absolute path')
        return result


def remap_json(raw: bytes, replacements: dict) -> bytes:
    """Remap nested JSON path values, leaving URLs and relative paths intact."""
    remapper = _Remapper(replacements)

    def visit(value):
        if isinstance(value, str):
            if re.match(r'^[a-z][a-z0-9+.-]*://', value, re.I) and not value.casefold().startswith('file:///'):
                return value
            if _GUEST.match(value):
                value = value.replace('\\', '/')
            return remapper.text(value)
        if isinstance(value, list):
            return [visit(item) for item in value]
        if isinstance(value, dict):
            return {key: visit(item) for key, item in value.items()}
        return value

    return (json.dumps(visit(json.loads(raw)), ensure_ascii=False, indent=2) + '\n').encode('utf-8')


def render_local_entry(entry_raw: bytes, boundary_raw: bytes,
                       replacements: dict[str, str], output_init: str) -> dict:
    """Bind the immutable entry first, then render paths without executing it."""
    bound = bind_entry(entry_raw, boundary_raw)
    entry = json.loads(entry_raw)
    if entry['inherit_environment'] is not False:
        raise ValueError('producer must not inherit the environment')
    remapper = _Remapper(replacements)
    launch = bound['launch_request']
    argv = [remapper.text(arg) for arg in windows_arguments(launch['command_line'])]
    cwd = str(PureWindowsPath(_absolute(remapper.text(launch['cwd']))))
    return {
        'argv': argv,
        'launch_request': {
            'command_line': subprocess.list2cmdline(argv),
            'cwd': cwd,
            'environment': {key: remapper.text(value) for key, value in launch['environment'].items()},
        },
        'inherit_environment': False,
        'overlays': {path: remapper.text(content) for path, content in entry['overlays'].items()},
        'gradle_properties': remapper.text(entry['gradle_properties']),
        'output_init': remapper.text(output_init),
        'publication_version': bound['publication_version'],
        'source_identity': bound['source_identity'],
    }
