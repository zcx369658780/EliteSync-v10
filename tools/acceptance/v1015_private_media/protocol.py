"""Small pure helpers for a separately authorized real private-media probe."""
import json
import re
import struct
import zlib
from urllib.parse import urlsplit


def require(condition, message):
    if not condition:
        raise ValueError(message)


def content_path(url, asset_id):
    parsed = urlsplit(url)
    path = f'/api/v1/media/{asset_id}/content'
    require(parsed.scheme == 'http' and parsed.netloc == '127.0.0.1:8021'
            and parsed.path == path and not parsed.query and not parsed.fragment,
            'Media URL must identify the exact asset on the task loopback origin')
    return path


def validate_media_bytes(status, headers, body, fixture, byte_range=None, *, expected_mime='image/png'):
    headers = {k.lower(): v for k, v in headers.items()}
    require(status == (206 if byte_range else 200), 'Wrong full/range HTTP status')
    expected = fixture if byte_range is None else fixture[byte_range[0]:byte_range[1]+1]
    require(body == expected and int(headers.get('content-length', -1)) == len(expected), 'Media bytes/length differ from fixture')
    require(expected_mime in ('image/png', 'video/mp4')
            and headers.get('content-type', '').split(';')[0].strip() == expected_mime,
            'Unexpected content MIME')
    cache = {part.strip().lower() for part in headers.get('cache-control', '').split(',')}
    vary = {part.strip().lower() for part in headers.get('vary', '').split(',')}
    require({'private', 'no-store', 'max-age=0'} <= cache and 'public' not in cache, 'Private no-store cache policy required')
    require({'authorization', 'cookie'} <= vary and headers.get('accept-ranges') == 'bytes'
            and headers.get('x-content-type-options') == 'nosniff', 'Private range/security headers required')
    if byte_range:
        require(headers.get('content-range') == f'bytes {byte_range[0]}-{byte_range[1]}/{len(fixture)}', 'Wrong Content-Range')


def validate_denied_media(status, body, fixture, private_markers=()):
    require(type(status) is int and status in (401, 403, 404), 'Only explicit authentication/authorization denial accepted')
    require(fixture not in body and fixture[:16] not in body, 'Denied response contains fixture bytes')
    try:
        payload = json.loads(body)
    except (ValueError, UnicodeError) as error:
        raise ValueError('Denied response must be JSON, not media or an HTML error') from error
    require(isinstance(payload, dict), 'Denied response must be an object')
    def walk(value):
        if isinstance(value, dict):
            require(not any(k in value for k in ('id', 'asset', 'asset_id', 'media_asset_id', 'message_id',
                    'conversation_id', 'attachments', 'public_url', 'storage_key', 'client_message_id', 'idempotent_replay', 'content'))
                    and value.get('ok') is not True, 'Denied response contains media/success identity')
            for item in value.values(): walk(item)
        elif isinstance(value, list):
            for item in value: walk(item)
        elif isinstance(value, str):
            require('/api/v1/media/' not in value and '/storage/' not in value
                    and not any(marker in value for marker in private_markers),
                    'Decoded denial contains a private pointer or marker')
    walk(payload)
    require(b'/api/v1/media/' not in body and b'/storage/' not in body, 'Denied response contains a private media pointer')


def multipart_file(media_type, filename, data, mime, boundary):
    require(media_type in ('image', 'video') and re.fullmatch(r'[A-Za-z0-9._-]+', filename)
            and '..' not in filename and re.fullmatch(r'[A-Za-z0-9-]{8,80}', boundary)
            and mime in ('image/png', 'video/mp4'), 'Unsafe multipart header field')
    require(boundary.encode() not in data, 'Multipart boundary collision')
    body = (f'--{boundary}\r\nContent-Disposition: form-data; name="media_type"\r\n\r\n{media_type}\r\n'
            f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{filename}"\r\n'
            f'Content-Type: {mime}\r\n\r\n').encode() + data + f'\r\n--{boundary}--\r\n'.encode()
    return 'multipart/form-data; boundary=' + boundary, body


def fixture_png():
    """Generate32x32 RGB synthetic pixels, no personal or historical media input."""
    def chunk(tag, data):
        return struct.pack('!I', len(data)) + tag + data + struct.pack('!I', zlib.crc32(tag+data) & 0xffffffff)
    pixels = b''.join(b'\0' + bytes([40, 120, 200])*32 for _ in range(32))
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!IIBBBBB', 32, 32, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(pixels)) + chunk(b'IEND', b''))
