import os
import sys,json,hashlib,uuid,pathlib
sys.path.insert(0,str(pathlib.Path.cwd()/'tests/Integration/v1015'))
from journey import login,request,receipts
r=pathlib.Path(os.environ['V1015_EVIDENCE_ROOT'])
a,b,c=[login(i,'v1015-final-http-'+str(i)) for i in (1,2,3)];ta,tb,tc=[x['access_token'] for x in (a,b,c)]
for asset in (2,3):
 data=request('GET',f'/api/v1/media/{asset}/content',tb).content
 if asset==3:assert hashlib.sha256(data).hexdigest()==hashlib.sha256((r/'v1015-synthetic-video.mp4').read_bytes()).hexdigest()
 part=request('GET',f'/api/v1/media/{asset}/content',tb,expected=206,headers={'Range':'bytes=0-31'});assert part.content==data[:32]
 request('GET',f'/api/v1/media/{asset}/content',tc,expected=404,headers={'Range':'bytes=0-31'})
items=request('GET','/api/v1/messages?peer_id=2',ta).json()['items'];video=next(x for x in items if x['id']==6)
sent=request('POST','/api/v1/messages',ta,json={'receiver_id':2,'content':'','attachment_ids':[3],'client_message_id':video['client_message_id']}).json();assert sent['id']==6 and sent['idempotent_replay']
request('POST','/api/v1/media',ta,expected=422,data={'media_type':'video'},files={'file':('invalid.mp4',b'not-a-valid-mp4','video/mp4')})
print(json.dumps({'result':'PASS_REAL_HTTP_VIDEO_IMAGE_RANGE','asset_ids':[2,3],'video_source_sha256':hashlib.sha256((r/'v1015-synthetic-video.mp4').read_bytes()).hexdigest(),'invalid_video_not_ready':True,'same_video_replay_message_id':6,'receipts':receipts},indent=2))
