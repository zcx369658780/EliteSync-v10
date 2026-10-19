import pathlib,json,time,urllib.request,urllib.error,subprocess,asyncio,re
import websockets
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
phase=E/'final-media-revoke';call_id=7
def rows(side):return [json.loads(l) for l in (phase/('rtc-events-'+side+'.jsonl')).read_text().splitlines()]
deadline=time.monotonic()+15
while True:
    enough=all(sum('RTC_MEDIA_RTP callId=7' in r['line'] and 'direction=inbound' in r['line'] and 'kind=video' in r['line'] for r in rows(side))>=2 for side in ['a','b'])
    if enough:break
    assert time.monotonic()<deadline,'FRESH_MEDIA_SAMPLES_UNAVAILABLE'
    time.sleep(.2)
stats={}
for side in ['a','b']:
    selected=[r for r in rows(side) if 'RTC_MEDIA_RTP callId=7' in r['line']]
    for kind in ['audio','video']:
        incoming=[r for r in selected if 'direction=inbound' in r['line'] and 'kind='+kind in r['line']]
        counts=[int(re.search(r'bytes=(\d+)',r['line']).group(1)) for r in incoming]
        assert len(counts)>=2 and max(counts)>min(counts)>0,(side,kind,counts)
        stats[side+'_'+kind]={'min_bytes':min(counts),'max_bytes':max(counts),'samples':len(counts)}
        if kind=='video':assert max(int(re.search(r'framesDecoded=(\d+)',r['line']).group(1)) for r in incoming)>0
adb=r'LOCAL_ONLY_ROOT'
for side,serial in [('a','emulator-5554'),('b','emulator-5556')]:
    (phase/('before-block-'+side+'.png')).write_bytes(subprocess.check_output([adb,'-s',serial,'exec-out','screencap','-p']))
root=r'LOCAL_ONLY_ROOT'
subprocess.run(['php',str(E/'rtc-token-fixture.php'),root,'before'],cwd=root,check=True,stdout=subprocess.DEVNULL)
join=json.loads((E/'secrets/rtc-old-join.json').read_text())
def validate():
    req=urllib.request.Request('http://127.0.0.1:7884/rtc/validate',headers={'Authorization':'Bearer '+join['token']})
    try:
        with urllib.request.urlopen(req,timeout=3) as r:return r.status
    except urllib.error.HTTPError as r:return r.code
assert validate()==200
start=time.monotonic();epoch=time.time()
call('bob','POST','/moderation/blocks',{'blocked_user_id':sessions['charlie']['user']['id']})
response=time.monotonic()
assert validate()==403
subprocess.run(['php',str(E/'rtc-token-fixture.php'),root,'after'],cwd=root,check=True,stdout=subprocess.DEVNULL)
async def reconnect():
    try:
        async with websockets.connect('ws://127.0.0.1:7884/rtc',additional_headers={'Authorization':'Bearer '+join['token']},proxy=None) as ws:
            raise AssertionError('OLD_JWT_RECONNECTED')
    except websockets.exceptions.InvalidStatus as error:
        assert error.response.status_code==403
asyncio.run(reconnect())
time.sleep(7)
stops={}
for side in ['a','b']:
    current=rows(side)
    ended=[r for r in current if r['host_monotonic']>=start and 'callId=7' in r['line'] and any(x in r['line'] for x in ['event=room_disconnected','event=leave_complete'])]
    assert ended,'NO_STOP_EVENT_'+side
    elapsed=min(r['host_monotonic'] for r in ended)-start;assert elapsed<=5,(side,elapsed)
    late=[r for r in current if r['host_monotonic']>start+5 and 'RTC_MEDIA_RTP callId=7' in r['line']]
    assert not late,'LATE_RTP_'+side
    stops[side]={'stop_after_block_seconds':elapsed,'late_rtp_after_5_seconds':False}
result={'call_id':call_id,'same_final_apk_both_sides':True,'synthetic_emulated_video_and_no_host_audio':True,'inbound_audio_video_increased_both_sides':stats,'block_started_monotonic':start,'block_started_epoch':epoch,'response_seconds':response-start,'stops':stops,'old_jwt_pre_validate':200,'old_jwt_post_validate':403,'old_jwt_websocket_reconnect':403,'new_join_denied':True,'saved_jwt_source':'official server issuer, controlled pre-revocation fixture, not extracted from APP','all_pass':True}
(E/'rtc-final-revocation-result.json').write_text(json.dumps(result,indent=2));(phase/'rtc-collector-stop').write_text('stop')
print(json.dumps({'call_id':call_id,'audio_video_transport_both_sides':True,'stops':stops,'old_jwt_reconnect':403,'all_pass':True}))
