"""Actual bounded call lifecycle; no microphone/camera, SFU or acoustic claim."""
import json
from journey import login, request, receipts

a,b=login(1,'v1015-rtc-control-a'),login(2,'v1015-rtc-control-b')
ta,tb=a['access_token'],b['access_token']
one=request('POST','/api/v1/rtc/calls',ta,json={'peer_user_id':2,'mode':'voice'}).json()['session']
request('POST',f"/api/v1/rtc/calls/{one['id']}/reject",tb)
request('GET',f"/api/v1/rtc/calls/{one['id']}/livekit",ta,expected=404)
two=request('POST','/api/v1/rtc/calls',ta,json={'peer_user_id':2,'mode':'voice'}).json()['session']
request('POST',f"/api/v1/rtc/calls/{two['id']}/accept",tb)
request('POST',f"/api/v1/rtc/calls/{two['id']}/end",ta)
request('GET',f"/api/v1/rtc/calls/{two['id']}/livekit",tb,expected=404)
print(json.dumps({'result':'PASS_CONTROL_ONLY','call_ids':[one['id'],two['id']],'sfu_media':'NOT_RUN','acoustic_aec':'NOT_RUN_DEVICE_PENDING','receipts':receipts},indent=2))
