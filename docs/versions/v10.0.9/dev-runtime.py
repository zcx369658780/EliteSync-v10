"""Owned V1009 runtime. Private values are generated/stored only under evidence/secrets."""
import os,sys,json,pathlib,secrets,base64,subprocess,socket,time,hashlib
ROOT=pathlib.Path(__file__).resolve().parents[3]
PHP='C:/tools/php85/php.exe'
BACKEND=ROOT/'services/backend-laravel'
Q=pathlib.Path(sys.argv[1]).resolve()
Q.mkdir(parents=True,exist_ok=True)
PRIVATE=Q/'secrets';PRIVATE.mkdir(exist_ok=True)
def env():
 d=json.loads((PRIVATE/'runtime-env.json').read_text());return {**os.environ,**d}
def run(label,args,cwd=None,environment=None):
 with (Q/(label+'.stdout')).open('wb') as out,(Q/(label+'.stderr')).open('wb') as err:
  p=subprocess.run(args,cwd=cwd or ROOT,env=environment,stdout=out,stderr=err)
 receipt={'command':args,'cwd':str(cwd or ROOT),'exit':p.returncode}
 for stream in ['stdout','stderr']:receipt[stream+'_sha256']=hashlib.sha256((Q/(label+'.'+stream)).read_bytes()).hexdigest()
 (Q/(label+'.json')).write_text(json.dumps(receipt,indent=2));print(label,'exit',p.returncode,flush=True);return p.returncode
def check_ports():
 for n in [8000,8001]:
  with socket.socket() as s:
   if s.connect_ex(('127.0.0.1',n))==0:raise RuntimeError('Required port already owned: '+str(n))
def start_one(label,args,cwd=None):
 out=(Q/(label+'.stdout')).open('ab');err=(Q/(label+'.stderr')).open('ab')
 p=subprocess.Popen(args,cwd=cwd or ROOT,env=env(),stdout=out,stderr=err,creationflags=subprocess.CREATE_NO_WINDOW)
 return {'pid':p.pid,'args':args,'cwd':str(cwd or ROOT)}
action=sys.argv[2]
if action=='init':
 if (PRIVATE/'runtime-env.json').exists():raise RuntimeError('Existing private config retained; do not reinitialize')
 accounts={n:{'phone':'199000008'+str(i+1).zfill(2),'password':secrets.token_urlsafe(18)} for i,n in enumerate(['admin','alice','bob','pending','incomplete','roleonly','listonly','disabled'])}
 (PRIVATE/'accounts.json').write_text(json.dumps({'accounts':accounts},indent=2));password=secrets.token_urlsafe(24)
 (PRIVATE/'db.env').write_text('MARIADB_DATABASE=elitesync_v1009_dev\nMARIADB_USER=elitesync_v1009\nMARIADB_PASSWORD='+password+'\nMARIADB_ROOT_PASSWORD='+secrets.token_urlsafe(28)+'\n')
 d={'APP_ENV':'local','APP_DEBUG':'false','APP_KEY':'base64:'+base64.b64encode(secrets.token_bytes(32)).decode(),'APP_URL':'http://127.0.0.1:8000','APP_DB_CONNECTION':'mysql','DB_CONNECTION':'mysql','APP_DB_HOST':'127.0.0.1','APP_DB_PORT':'43319','APP_DB_DATABASE':'elitesync_v1009_dev','APP_DB_USERNAME':'elitesync_v1009','APP_DB_PASSWORD':password,'APP_DB_SOCKET':'','APP_DB_URL':'','DB_URL':'','APP_SESSION_DRIVER':'database','APP_SESSION_CONNECTION':'mysql','SESSION_COOKIE':'elitesync_v1009_session','SESSION_SECURE_COOKIE':'false','APP_QUEUE_CONNECTION':'database','QUEUE_CONNECTION':'database','APP_CACHE_STORE':'array','CACHE_STORE':'array','V1007_LOCAL_RESTORATION':'true','V1007_DB_PORT':'43319','V1007_MEDIA_ROOT':str(Q/'media'),'MEDIA_STORAGE_DISK':'v1009','V1009_MEDIA_ROOT':str(Q/'media'),'V1009_RTC_ENABLED':'true','V1009_GATEWAY_SECRET':secrets.token_urlsafe(40),'LIVEKIT_ENABLED':'true','LIVEKIT_URL':'http://127.0.0.1:7884','LIVEKIT_API_KEY':'v1009-'+secrets.token_hex(8),'LIVEKIT_API_SECRET':secrets.token_urlsafe(48),'LIVEKIT_TOKEN_TTL_SECONDS':'60','ADMIN_PHONES':accounts['admin']['phone']+','+accounts['listonly']['phone'],'V1009_CREDENTIALS_FILE':str(PRIVATE/'accounts.json'),'FEATURE_MBTI_ENABLED':'true','MATCHING_FOUNDATION_READ_ENABLED':'true','MATCHING_FOUNDATION_ADMIN_ENABLED':'true','MATCHING_FOUNDATION_EXECUTION_ENABLED':'true','MATCHING_C2_MANUAL_CONSUMER_CONFIGURED':'true','MATCHING_FOUNDATION_DIGEST_KEY':secrets.token_urlsafe(32),'APP_CONFIG_CACHE':str(Q/'runtime/config.php'),'APP_ROUTES_CACHE':str(Q/'runtime/routes.php'),'VIEW_COMPILED_PATH':str(Q/'runtime/views')}
 for key in ['DB_HOST','DB_PORT','DB_DATABASE','DB_USERNAME','DB_PASSWORD']:d[key]=d['APP_'+key]
 (Q/'runtime/views').mkdir(parents=True,exist_ok=True);(PRIVATE/'runtime-env.json').write_text(json.dumps(d,indent=2))
 assert subprocess.run(['docker','inspect','elitesync-v1009-db'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode!=0
 code=run('docker-create',['docker','run','-d','--name','elitesync-v1009-db','--label','elitesync.version=v10.0.9','--env-file',str(PRIVATE/'db.env'),'-p','127.0.0.1:43319:3306','-v','elitesync-v1009-db-data:/var/lib/mysql','mariadb:10.11']);sys.exit(code)
elif action in ['migrate','seed']:
 args=[PHP,'artisan','migrate','--force'] if action=='migrate' else [PHP,'artisan','db:seed','--class=V1009DevelopmentSeeder','--force']
 sys.exit(run(action,args,BACKEND,env()))
elif action=='start':
 check_ports();owned={'php':start_one('laravel',[PHP,'-d','upload_max_filesize=26M','-d','post_max_size=27M','-S','127.0.0.1:8001','-t','public','public/index.php'],BACKEND),'front':start_one('front',[sys.executable,str(ROOT/'docs/versions/v10.0.9/local-http-front.py')])};(Q/'owned-processes.json').write_text(json.dumps(owned,indent=2));print('Owned V1009 services started')
elif action=='worker':
 p=start_one('worker',[PHP,'artisan','queue:work','database','--queue=v1009-matching','--sleep=1','--tries=1','--timeout=180'],BACKEND);(Q/'owned-worker.json').write_text(json.dumps(p,indent=2));print('Owned V1009 matching worker started')
elif action=='php':sys.exit(run(sys.argv[3],[PHP,str(ROOT/sys.argv[4])],BACKEND,env()))
elif action=='cmd':sys.exit(run(sys.argv[3],sys.argv[4:],ROOT,env()))
elif action=='artisan':sys.exit(run(sys.argv[3],[PHP,'artisan',*sys.argv[4:]],BACKEND,env()))
else:raise RuntimeError('Unknown action')
