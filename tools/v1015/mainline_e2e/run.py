"""Future same-source HTTP/DB driver. No service/build/device launcher. Default inspect."""
import sys
sys.dont_write_bytecode=True
import argparse,base64,json,os,subprocess,uuid,urllib.request,urllib.error
from pathlib import Path
from contracts import *
PNG=base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/l9sAAAAASUVORK5CYII=")
class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self,*a,**kw): raise Gate("HTTP_REDIRECT_REJECTED")
class Ledger:
    def __init__(self,root,grant,max_bytes):
        self.root=root;self.path=root/"mainline_execution_ledger.jsonl";self.grant=grant;self.limit=max_bytes
        need(not self.path.exists(),"EXISTING_ATTEMPT_RECONCILIATION_REQUIRED")
        self.path.touch(exist_ok=False);self.counts={"http":0,"php":0};self.previous="0"*64
        self.record("INITIALIZED",task_blob=grant["task_blob"],source_binding=grant["source_binding"],root=str(root))
    def record(self,event,**values):
        row=dict(event=event,prev=self.previous,**values);row["hash"]=digest(canonical(row));self.previous=row["hash"]
        with self.path.open("ab",buffering=0) as f:f.write(canonical(row)+b"\n");os.fsync(f.fileno())
    def reserve(self,kind):
        cap=self.grant[kind+"_operations"];need(self.counts[kind]<cap,"BUDGET_EXHAUSTED")
        logical,allocated=measured_space(self.root)
        need(max(logical,allocated)+2097152<=self.limit,"SPACE_GATE_CLOSED")
        self.counts[kind]+=1;self.record("PREPARE",kind=kind,number=self.counts[kind],limit=cap)
        return self.counts[kind]
class Runner:
    def __init__(self,c,g,root):
        self.c=c;self.g=g;self.root=root;self.ledger=Ledger(root,g,c["max_bytes"])
        self.raw=root/"raw";need(not self.raw.exists(),"RAW_DESTINATION_EXISTS");self.raw.mkdir()
        self.results=[];self.tokens={};self.fixture=None
    def http(self,method,path,token=None,body=None,status=(200,),headers=None,upload=None,discard=False):
        need(method in ("GET","POST","PUT","DELETE") and path.startswith("/") and "://" not in path,"HTTP_PATTERN")
        number=self.ledger.reserve("http");h={"Accept":"application/json",**(headers or {})}
        if token:h["Authorization"]="Bearer "+token
        data=None
        if upload:
            kind,payload=upload;need(kind in ("image","video") and len(payload)<=131072,"SYNTHETIC_MEDIA_LIMIT")
            boundary="elitesync-"+uuid.uuid4().hex
            data=("--"+boundary+"\r\nContent-Disposition: form-data; name=\"media_type\"\r\n\r\n"+kind+"\r\n--"+boundary+"\r\nContent-Disposition: form-data; name=\"file\"; filename=\"synthetic."+("png" if kind=="image" else "mp4")+"\"\r\nContent-Type: "+("image/png" if kind=="image" else "video/mp4")+"\r\n\r\n").encode()+payload+("\r\n--"+boundary+"--\r\n").encode()
            h["Content-Type"]="multipart/form-data; boundary="+boundary
        elif body is not None:data=json.dumps(body).encode();h["Content-Type"]="application/json"
        request=urllib.request.Request(self.c["api"]+path,data=data,headers=h,method=method)
        # No proxies, redirects, DNS aliases or retry handler.
        opener=urllib.request.build_opener(urllib.request.ProxyHandler({}),NoRedirect())
        try:response=opener.open(request,timeout=15)
        except urllib.error.HTTPError as e:response=e
        with response:
            raw=response.read(1048577);need(len(raw)<=1048576,"HTTP_BODY_LIMIT")
            code=response.code;content_type=response.headers.get("Content-Type","")
            value=json.loads(raw) if "json" in content_type else None
        record=dict(method=method,path=path,status=code,request_body=body,response_headers=dict(response.headers),response_base64=base64.b64encode(raw).decode(),ack_suppressed=discard)
        (self.raw/("http-"+str(number)+".json")).write_bytes(canonical(record))
        self.ledger.record("HTTP_ENDED",number=number,status=code,body_sha256=digest(raw),ack_suppressed=discard)
        need(code in status,"HTTP_STATUS_"+str(code))
        return None if discard else value
    def php(self,mode,**args):
        need(mode in ("seed","snapshot","fail_asset","disable","projection"),"PHP_MODE")
        exe=local(self.c["php"],self.root);script=local(self.c["bridge"],self.root)
        need(exe.name.lower()=="php.exe" and digest(exe.read_bytes())==self.g["php_sha256"] and digest(script.read_bytes())==self.g["bridge_sha256"],"PHP_SOURCE_IDENTITY")
        n=self.ledger.reserve("php")
        context=dict(config=self.c,grant=self.g,mode=mode,args=args,fixture=self.fixture)
        env={k:v for k,v in os.environ.items() if k in ("SystemRoot","WINDIR")}
        env.update(HOME=str(self.root/"home"),TEMP=str(self.root/"tmp"),TMP=str(self.root/"tmp"),APP_ENV="testing")
        command=[str(exe),"-n","-d","extension_dir="+str(local(self.c["php_extension_dir"],self.root)),"-d","extension=pdo_mysql","-d","extension=openssl",str(script)]
        # CLI operation only; never php -S, a daemon, shell, database or device launcher.
        reply=subprocess.run(command,input=canonical(context),stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=self.root,env=env,timeout=30,shell=False)
        (self.raw/("php-"+str(n)+".stdout")).write_bytes(reply.stdout);(self.raw/("php-"+str(n)+".stderr")).write_bytes(reply.stderr)
        self.ledger.record("PHP_ENDED",number=n,exit=reply.returncode,stdout_sha256=digest(reply.stdout),stderr_sha256=digest(reply.stderr))
        need(reply.returncode==0,"PHP_BRIDGE_FAILED")
        return json.loads(reply.stdout)
    def login(self,who,device):
        v=self.http("POST","/auth/login",body=dict(phone=who["phone"],password=self.c["fixture_password"],device_id=device))
        check_login(v["session_retention"],who["id"],device);return v
    def send(self,a,b,content,assets=()):
        body=dict(receiver_id=b["id"],content=content,client_message_id=str(uuid.uuid4()))
        if assets:body["attachment_ids"]=list(assets)
        # Deliberate application-level acknowledgement loss, not physical packet loss.
        self.http("POST","/messages",a["token"],body,discard=True)
        replay=self.http("POST","/messages",a["token"],body)
        need(replay["client_message_id"]==body["client_message_id"] and replay["idempotent_replay"] is True,"REPLAY_IDENTITY")
        self.http("POST","/messages",a["token"],dict(body,content=content+"-conflict"),status=(409,))
        counts=self.php("snapshot",sender=a["id"],key=body["client_message_id"])
        check_counts(counts,len(assets));need(counts["message_id"]==replay["id"],"DB_IDENTITY")
        return body,replay,counts
    def run(self):
        self.fixture=self.php("seed")
        for name,pair in self.fixture["pairs"].items():
            for side,who in pair.items():
                who["device"]="e2e-"+name+"-"+side
                who.update(self.login(who,who["device"]));who["token"]=who["access_token"]
        pair=self.fixture["pairs"]["base"];a,b=pair["a"],pair["b"]
        original=a["session_retention"]
        refreshed=self.http("POST","/auth/refresh",a["refresh_token"])
        for k in ("login_at","online_expires_at","purge_at","session_id","device_id","user_id"):need(original[k]==refreshed["session_retention"][k],"REFRESH_RENEWED_T0")
        self.http("GET","/profile/basic",a["token"],status=(401,))
        a["token"]=refreshed["access_token"]
        self.results.append(dict(scenario="trusted_login_refresh",status="API_DB_CONTRACT_OBSERVED",physical_15_30_days="NOT_PROVEN"))
        body,reply,counts=self.send(a,b,"SYNTHETIC-MAINLINE-TEXT")
        self.results.append(dict(scenario="message_unknown_retry",status="API_DB_CONTRACT_OBSERVED",physical_packet_loss="NOT_PROVEN"))
        image=self.http("POST","/media",a["token"],upload=("image",PNG))["asset"]
        need(image["status"]=="ready","IMAGE_NOT_READY")
        media_body,media_reply,media_counts=self.send(a,b,"SYNTHETIC-IMAGE",[image["id"]])
        self.http("GET","/media/"+str(image["id"])+"/content",b["token"])
        self.php("fail_asset",asset=image["id"],owner=a["id"])
        recovered=self.http("POST","/messages",a["token"],media_body)
        need(recovered["id"]==media_reply["id"],"FAILED_ASSET_REPLAY_CHANGED")
        self.http("GET","/media/"+str(image["id"])+"/content",b["token"],status=(403,404))
        self.results.append(dict(scenario="image_failed_replay",status="API_DB_CONTRACT_OBSERVED"))
        self.http("POST","/notification-devices",b["token"],dict(device_id=b["device"],transport="test_only",token="SYNTHETIC-"+str(uuid.uuid4()),permission="granted"))
        projection=self.php("projection",notice=counts["notice_id"],owner=b["id"],device=b["device"]);check_projection(projection)
        self.http("PUT","/notification-preferences",b["token"],dict(categories=dict(message=False),silent=True))
        suppressed=self.php("projection",notice=counts["notice_id"],owner=b["id"],device=b["device"])
        need(suppressed["status"]=="SUPPRESSED","PREFERENCES_IGNORED")
        self.http("POST","/notification-devices",b["token"],dict(device_id=b["device"],transport="test_only",token="SYNTHETIC-DENIED",permission="denied"),status=(422,))
        self.http("GET","/profile/basic",b["token"])
        self.results.append(dict(scenario="notification_privacy_preferences",status="API_DB_CONTRACT_OBSERVED",real_push="NOT_RUN_GATE_CLOSED"))
        for mode in ("block","mc","cn","disabled"):
            x,y=self.fixture["pairs"][mode]["a"],self.fixture["pairs"][mode]["b"]
            asset=self.http("POST","/media",x["token"],upload=("image",PNG))["asset"]
            sent,_,saved=self.send(x,y,"SYNTHETIC-"+mode,[asset["id"]])
            self.http("GET","/media/"+str(asset["id"])+"/content",y["token"])
            if mode=="block":self.http("POST","/moderation/blocks",y["token"],dict(blocked_user_id=x["id"]))
            elif mode in ("mc","cn"):
                state=self.http("GET","/connections/"+str(x["id"]),y["token"])
                kind="consent" if mode=="mc" else "connection";v=state[kind]
                self.http("POST","/connections/"+str(x["id"])+"/"+kind,y["token"],dict(action="revoke" if mode=="mc" else "close",expected_revision=v["revision"]))
            else:self.php("disable",user=x["id"])
            self.http("POST","/messages",x["token"],sent,status=(401,403,404))
            self.http("GET","/media/"+str(asset["id"])+"/content",y["token"],status=(403,404))
            denied=self.http("GET","/notifications/"+str(saved["notice_id"]),y["token"],status=(200,404))
            if denied is not None:need(denied["item"].get("available") is False or denied["item"]["title"]=="通知已不可用","STALE_NOTIFICATION_AVAILABLE")
            final=self.php("snapshot",sender=x["id"],key=sent["client_message_id"]);check_counts(final,1)
            self.results.append(dict(scenario="revocation_"+mode,status="API_DB_CONTRACT_OBSERVED"))
        self.http("POST","/auth/logout",b["token"])
        self.http("GET","/notifications",b["token"],status=(401,))
        video=self.c.get("synthetic_mp4")
        if video:
            p=local(video,self.root);need(digest(p.read_bytes())==self.g.get("synthetic_mp4_sha256"),"VIDEO_SOURCE_NOT_QUALIFIED")
            asset=self.http("POST","/media",a["token"],upload=("video",p.read_bytes()))["asset"];need(asset["status"]=="ready","VIDEO_NOT_READY")
            new_b=self.login(b,b["device"]);b["token"]=new_b["access_token"]
            self.send(a,b,"SYNTHETIC-VIDEO",[asset["id"]])
            self.http("GET","/media/"+str(asset["id"])+"/content",b["token"],headers={"Range":"bytes=0-15"},status=(206,))
            self.results.append(dict(scenario="private_video_range",status="API_DB_CONTRACT_OBSERVED",app_player="NOT_RUN_GATE_CLOSED"))
        else:self.results.append(dict(scenario="private_video_range",status="NOT_RUN_GATE_CLOSED",reason="QUALIFIED_SYNTHETIC_MP4_REQUIRED"))
        rows=[]
        if self.c.get("app_receipts"):
            p=local(self.c["app_receipts"],self.root);rows=[json.loads(s) for s in p.read_bytes().splitlines()]
        required=["unknown_edit_retry","account_switch_late_http_ws","media_picker_player","offline_restart_readonly","cleanup_failure","old_notification_navigation"]
        app=check_app_receipts(rows,self.c["source_binding"],required,self.root)
        result=dict(classification="API_DB_OBSERVATIONS_NOT_FUNCTIONAL_ACCEPTANCE",results=self.results,app_observations=app,source_binding=self.c["source_binding"],elapsed_15_30_days="NOT_PROVEN",keystore_physical_purge="NOT_PROVEN",rtc_ac05="OPEN",real_push="PENDING",e2e_pass=False)
        self.ledger.record("COMPLETED",report_sha256=digest(canonical(result)))
        (self.root/"run-result-LOCAL_ONLY.json").write_bytes(canonical(result));return result
def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("action",choices=("inspect","execute"),nargs="?",default="inspect");p.add_argument("--config");p.add_argument("--grant");a=p.parse_args(argv)
    if a.action=="inspect":
        cases=json.loads(Path(__file__).with_name("scenarios.json").read_bytes())
        print(json.dumps(dict(state="NOT_RUN_GATE_CLOSED",execute="DISABLED_WITHOUT_NEW_OWNER_AUTHORITY",scenarios=cases)));return 0
    config=json.loads(local(a.config).read_bytes());grant=json.loads(local(a.grant).read_bytes());root=validate_authority(config,grant)
    lock=root/".mainline-running";handle=os.open(lock,os.O_CREAT|os.O_EXCL|os.O_WRONLY);os.close(handle)
    try:print(json.dumps(Runner(config,grant,root).run()));return 0
    finally:lock.unlink()
if __name__=="__main__":
    try:raise SystemExit(main())
    except (Gate,ValueError,KeyError,OSError) as e:
        print(json.dumps(dict(state="BLOCKED_OR_FAILED",reason=type(e).__name__,e2e_pass=False)));raise SystemExit(2)
