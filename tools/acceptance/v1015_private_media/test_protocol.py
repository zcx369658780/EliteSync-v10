"""Pure media evidence rejection tests; no HTTP, DB, device or service execution."""
import hashlib
import unittest
from protocol import validate_media_bytes, validate_denied_media, content_path, multipart_file, fixture_png


class MediaProtocolTests(unittest.TestCase):
    def setUp(self):
        self.data = b'fictional image bytes'
        self.headers = {'content-type': 'image/png', 'content-length': str(len(self.data)),
                        'cache-control': 'private, no-store, max-age=0',
                        'vary': 'Authorization, Cookie', 'accept-ranges': 'bytes',
                        'x-content-type-options': 'nosniff'}

    def test_full_and_exact_range_must_match_fixture_bytes_and_privacy_headers(self):
        validate_media_bytes(200, self.headers, self.data, self.data)
        headers = dict(self.headers, **{'content-length': '4', 'content-range': f'bytes 0-3/{len(self.data)}'})
        validate_media_bytes(206, headers, self.data[:4], self.data, (0, 3))
        for key, value in [('content-range', 'bytes 1-4/20'), ('cache-control', 'public'),
                           ('vary', 'Accept'), ('content-length', '5'), ('content-type', 'text/html')]:
            bad = dict(headers, **{key: value})
            with self.subTest(header=key), self.assertRaises(ValueError):
                validate_media_bytes(206, bad, self.data[:4], self.data, (0, 3))
        with self.assertRaises(ValueError):
            validate_media_bytes(200, self.headers, b'wrong', self.data)

    def test_denials_reject_500_raw_media_private_urls_and_success_identity(self):
        validate_denied_media(404, b'{"message":"media asset unavailable"}', self.data)
        for status, body in [(500, b'error'), (404, self.data), (404, b'{"id":1}'),
                             (404, b'{"asset":{"public_url":"/api/v1/media/1/content"}}'),
                             (404, b'{"ok":true}'), (404, b'not json')]:
            with self.subTest(status=status, body=body), self.assertRaises(ValueError):
                validate_denied_media(status, body, self.data)

    def test_video_full_range_require_mp4_mime_exact_bytes_and_privacy(self):
        data = b'fictional mp4 fixture bytes'
        headers = dict(self.headers, **{'content-type': 'video/mp4', 'content-length': str(len(data))})
        validate_media_bytes(200, headers, data, data, expected_mime='video/mp4')
        part = dict(headers, **{'content-length': '4', 'content-range': f'bytes 0-3/{len(data)}'})
        validate_media_bytes(206, part, data[:4], data, (0, 3), expected_mime='video/mp4')
        for changes in [{'content-type': 'image/png'}, {'content-length': '9'},
                        {'content-range': 'bytes 1-4/26'}, {'cache-control': 'public'},
                        {'vary': 'Cookie'}]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                validate_media_bytes(206, dict(part, **changes), data[:4], data, (0, 3), expected_mime='video/mp4')
        with self.assertRaises(ValueError):
            validate_media_bytes(200, headers, data, data)

    def test_video_multipart_keeps_actual_file_bytes_and_type(self):
        data = b'fictional mp4 fixture bytes'
        _, body = multipart_file('video', 'synthetic.mp4', data, 'video/mp4', 'video-fixture-boundary')
        self.assertIn(b'name="media_type"\r\n\r\nvideo\r\n', body)
        self.assertIn(b'Content-Type: video/mp4\r\n\r\n' + data, body)

    def test_returned_url_must_stay_on_exact_qualified_origin_and_asset(self):
        self.assertEqual(content_path('http://127.0.0.1:8021/api/v1/media/7/content', 7), '/api/v1/media/7/content')
        for url in ['http://external.invalid/api/v1/media/7/content', 'http://127.0.0.1:8021/storage/a.png',
                    'http://127.0.0.1:8021/api/v1/media/8/content',
                    'http://user:pass@127.0.0.1:8021/api/v1/media/7/content',
                    'http://127.0.0.1:8021/api/v1/media/7/content?token=x']:
            with self.subTest(url=url), self.assertRaises(ValueError):
                content_path(url, 7)

    def test_denial_rejects_decoded_urls_success_fields_and_private_caption(self):
        import json
        escaped = json.dumps({'message': '/api/v1/media/7/content'}).replace('/', '\\/').encode()
        for body in [escaped, b'{"asset_id":7}', b'{"media_asset_id":7}', b'{"message_id":7}',
                     b'{"idempotent_replay":false}', b'{"message":"private-caption"}',
                     b'{"error":{"detail":"private-key"}}']:
            with self.subTest(body=body), self.assertRaises(ValueError):
                validate_denied_media(404, body, self.data, ('private-caption', 'private-key'))

    def test_multipart_uses_actual_bytes_and_safe_fixed_header_fields(self):
        content_type, body = multipart_file('image', 'fixture.png', self.data, 'image/png', 'fixture-boundary')
        self.assertIn('boundary=fixture-boundary', content_type)
        self.assertIn(b'name="media_type"\r\n\r\nimage\r\n', body)
        self.assertIn(self.data, body)
        self.assertTrue(body.endswith(b'--fixture-boundary--\r\n'))
        for name in ['bad\r\nheader', '../secret', 'a"name']:
            with self.assertRaises(ValueError):
                multipart_file('image', name, self.data, 'image/png', 'fixture-boundary')

    def test_png_fixture_is_deterministic_synthetic_content(self):
        import struct, zlib
        data = fixture_png()
        self.assertTrue(data.startswith(b'\x89PNG\r\n\x1a\n'))
        self.assertEqual(hashlib.sha256(data).digest(), hashlib.sha256(fixture_png()).digest())
        offset = 8
        chunks = {}
        while offset < len(data):
            size = struct.unpack('!I', data[offset:offset+4])[0]
            tag, body = data[offset+4:offset+8], data[offset+8:offset+8+size]
            crc = struct.unpack('!I', data[offset+8+size:offset+12+size])[0]
            self.assertEqual(zlib.crc32(tag+body) & 0xffffffff, crc)
            chunks[tag] = body
            offset += 12+size
        self.assertEqual(struct.unpack('!II', chunks[b'IHDR'][:8]), (32, 32))
        self.assertEqual(len(zlib.decompress(chunks[b'IDAT'])), 32*(1+32*3))


if __name__ == '__main__':
    unittest.main()
