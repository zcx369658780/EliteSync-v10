"""Actual loopback HTTP journey against the guarded synthetic v1015 database.
Credentials stay in memory; receipts contain status/identities/hashes only.
"""
import base64
import hashlib
import io
import json
import os
import socket
import struct
import sys
import uuid
from pathlib import Path
import requests

BASE = 'http://127.0.0.1:8021'
receipts = []

def request(method, path, token=None, expected=200, **kw):
    headers = {'Accept': 'application/json'}
    if token: headers['Authorization'] = 'Bearer ' + token
    headers.update(kw.pop('headers', {}))
    reply = requests.request(method, BASE + path, headers=headers, timeout=25, **kw)
    receipts.append({'method': method, 'path': path, 'status': reply.status_code, 'body_sha256': hashlib.sha256(reply.content).hexdigest()})
    assert reply.status_code == expected, (path, reply.status_code, reply.text[:120])
    return reply

def login(index, device):
    reply = request('POST', '/api/v1/auth/login', json={'phone': '1990000150'+str(index), 'password': 'V1015-Test-Only-Password', 'device_id': device}).json()
    assert reply['session_retention']['device_id'] == device
    return reply

def websocket(token, user, peer):
    sock = socket.create_connection(('127.0.0.1', 8022), timeout=6)
    key = base64.b64encode(os.urandom(16)).decode()
    sock.sendall((f'GET /api/v1/messages/ws/{user}?peer_id={peer} HTTP/1.1\r\nHost: 127.0.0.1:8022\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\nAuthorization: Bearer {token}\r\n\r\n').encode())
    response = b''
    while b'\r\n\r\n' not in response: response += sock.recv(1)
    assert response.startswith(b'HTTP/1.1 101'), response[:40]
    return sock

def frame(sock):
    def take(n):
        b = b''
        while len(b) < n:
            part = sock.recv(n-len(b))
            if not part: raise EOFError()
            b += part
        return b
    first, length = take(2)
    size = length & 127
    if size == 126: size = struct.unpack('!H', take(2))[0]
    if size == 127: size = struct.unpack('!Q', take(8))[0]
    assert size < 65536
    payload = take(size)
    if first & 15 == 8: raise EOFError()
    return json.loads(payload)

def positive():
    a, b, c = login(1, 'v1015-http-device-a'), login(2, 'v1015-http-device-b'), login(3, 'v1015-http-device-c')
    ta, tb, tc = [u['access_token'] for u in (a,b,c)]
    # First HTTP write also creates the canonical conversation before scoped WS.
    key = str(uuid.uuid4())
    data = {'receiver_id': 2, 'content': 'V1015 synthetic reliable text', 'client_message_id': key}
    first = request('POST', '/api/v1/messages', ta, json=data).json()
    again = request('POST', '/api/v1/messages', ta, json=data).json()
    assert first['id'] == again['id'] and again['idempotent_replay']
    request('POST', '/api/v1/messages', ta, expected=409, json={**data, 'content': 'different payload'})
    items = request('GET', '/api/v1/messages?peer_id=1', tb).json()['items']
    assert any(i['id'] == first['id'] and i['client_message_id'] == key for i in items)
    request('GET', '/api/v1/messages?peer_id=1', tc, expected=404)
    # Authenticated WS sends minimal invalidation only; actual text stays HTTP.
    ws = websocket(tb, 2, 1)
    signal_key = str(uuid.uuid4())
    signal = request('POST', '/api/v1/messages', ta, json={**data, 'client_message_id': signal_key}).json()
    observed = []
    for _ in range(8):
        event = frame(ws)
        observed.append(event)
        assert 'content' not in event and 'sender_id' not in event and 'receiver_id' not in event
        if event.get('id') == signal['id']: break
    assert any(e.get('id') == signal['id'] and e.get('type') == 'conversation_changed' for e in observed)
    ws.close()
    # A real uploaded synthetic image is private, associated exactly once.
    from PIL import Image
    image = io.BytesIO(); Image.new('RGB', (32,32), (40,90,140)).save(image, format='PNG')
    content = image.getvalue()
    asset = request('POST', '/api/v1/media', ta, data={'media_type':'image'}, files={'file':('synthetic.png', content, 'image/png')}).json()['asset']
    assert asset['status'] == 'ready'
    body = {'receiver_id': 2, 'content': '', 'attachment_ids':[asset['id']], 'client_message_id':str(uuid.uuid4())}
    sent = request('POST', '/api/v1/messages', ta, json=body).json()
    replay = request('POST', '/api/v1/messages', ta, json=body).json()
    assert sent['id'] == replay['id']
    media = request('GET', f"/api/v1/media/{asset['id']}/content", tb)
    assert media.content == content
    request('GET', f"/api/v1/media/{asset['id']}/content", tc, expected=404)
    # Preferences and TEST_ONLY registration use the actual login family/device.
    request('POST', '/api/v1/notification-devices', tb, json={'device_id':'v1015-http-device-b','transport':'test_only','token':'synthetic-test-token','permission':'granted'})
    request('PUT', '/api/v1/notification-preferences', tb, json={'categories':{'message':False},'silent':True})
    hidden = request('GET', '/api/v1/notifications', tb).json()
    assert not any(n['kind'] == 'message' for n in hidden['items'])
    request('PUT', '/api/v1/notification-preferences', tb, json={'categories':{'message':True},'silent':False})
    notices = request('GET', '/api/v1/notifications', tb).json()['items']
    assert all('V1015 synthetic reliable text' not in json.dumps(n) for n in notices)
    refresh = request('POST', '/api/v1/auth/refresh', a['refresh_token']).json()
    assert a['session_retention']['login_at'] == refresh['session_retention']['login_at']
    assert a['session_retention']['online_expires_at'] == refresh['session_retention']['online_expires_at']
    request('GET', '/api/v1/profile/basic', ta, expected=401)
    return {'result':'PASS','source':'NEW_RUN_REAL_HTTP_MARIADB','message_ids':[first['id'],signal['id'],sent['id']],
        'image_asset_id':asset['id'],'image_sha256':hashlib.sha256(content).hexdigest(),'t0_unchanged_after_refresh':True,'websocket_frames':observed,'receipts':receipts}

if __name__ == '__main__':
    result = positive()
    print(json.dumps(result, ensure_ascii=False, indent=2))
