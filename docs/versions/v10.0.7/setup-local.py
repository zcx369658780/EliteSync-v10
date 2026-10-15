"""Create only the named isolated development resources. Credentials remain local."""
import pathlib,secrets,base64,json,subprocess,sys,time,socket
ROOT=pathlib.Path(__file__).resolve().parents[3]
E=pathlib.Path(sys.argv[1]).resolve(); PRIVATE=E/'secrets';PRIVATE.mkdir(parents=True,exist_ok=True)
BACKEND=ROOT/'services/backend-laravel'
def run(name,args,cwd=None):
    r=subprocess.run(args,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    (E/(name+'.stdout')).write_bytes(r.stdout);(E/(name+'.stderr')).write_bytes(r.stderr)
    (E/(name+'.json')).write_text(json.dumps({'command':args,'exit':r.returncode},indent=2))
    if r.returncode:raise RuntimeError(name+' failed; preserved local streams')
    return r.stdout.decode().strip()
cfg=PRIVATE/'configuration.json'
if not cfg.exists():
    data={'database_password':secrets.token_urlsafe(30),'root_password':secrets.token_urlsafe(30),
        'app_key':'base64:'+base64.b64encode(secrets.token_bytes(32)).decode(), 'digest':secrets.token_hex(32),
        'port':43317,'accounts':{k:{'phone':'1990000070'+str(i),'password':secrets.token_urlsafe(18)}for i,k in enumerate(['admin','alice','bob','incomplete','disabled'],1)}}
    cfg.write_text(json.dumps(data));
data=json.loads(cfg.read_text())
dockerfile=PRIVATE/'docker.env'
dockerfile.write_text('MARIADB_DATABASE=elitesync_v1007_dev\nMARIADB_USER=v1007\nMARIADB_PASSWORD='+data['database_password']+'\nMARIADB_ROOT_PASSWORD='+data['root_password']+'\n')
existing=run('container-names',['docker','ps','-a','--format','{{.Names}}']).splitlines()
if 'elitesync-v1007-db' not in existing:
    probe=socket.socket();probe.bind(('127.0.0.1',data['port']));probe.close()
    run('volume-create',['docker','volume','create','--label','elitesync.version=v10.0.7','elitesync-v1007-db-data'])
    run('container-create',['docker','run','-d','--name','elitesync-v1007-db','--label','elitesync.version=v10.0.7',
        '--env-file',str(dockerfile),'-p',f"127.0.0.1:{data['port']}:3306",'-v','elitesync-v1007-db-data:/var/lib/mysql',
        'mariadb@sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008'])
else:
    label=run('container-label',['docker','inspect','--format','{{index .Config.Labels "elitesync.version"}}','elitesync-v1007-db'])
    if label!='v10.0.7':raise RuntimeError('container ownership mismatch')
    run('container-start',['docker','start','elitesync-v1007-db'])
for i in range(30):
    r=subprocess.run(['docker','exec','elitesync-v1007-db','healthcheck.sh','--connect','--innodb_initialized'],capture_output=True)
    (E/f'db-health-{i}.json').write_text(json.dumps({'exit':r.returncode}))
    if r.returncode==0:break
    time.sleep(1)
else:raise RuntimeError('database health timeout')
env=BACKEND/'.env';preserved=PRIVATE/'v1006-retained.env'
if env.exists() and not preserved.exists():preserved.write_bytes(env.read_bytes())
values={'APP_NAME':'EliteSync','APP_ENV':'local','APP_DEBUG':'false','APP_KEY':data['app_key'],'APP_URL':'http://127.0.0.1:8000',
    'DB_CONNECTION':'mysql','DB_HOST':'127.0.0.1','DB_PORT':str(data['port']),'DB_DATABASE':'elitesync_v1007_dev',
    'DB_USERNAME':'v1007','DB_PASSWORD':data['database_password'],'APP_SESSION_DRIVER':'database','APP_SESSION_CONNECTION':'mysql',
    'SESSION_COOKIE':'elitesync_v1007_session','SESSION_SECURE_COOKIE':'false','CACHE_STORE':'file','QUEUE_CONNECTION':'sync',
    'MAIL_MAILER':'log','ADMIN_PHONES':data['accounts']['admin']['phone'],'V1007_LOCAL_RESTORATION':'true',
    'V1007_CREDENTIALS_FILE':str(cfg).replace('\\','/'),'FEATURE_MBTI_ENABLED':'true','FEATURE_PERSONALITY_TEST_ENABLED':'false',
    'MATCH_WEIGHT_PERSONALITY':'0','MATCH_WEIGHT_MBTI':'0','MATCHING_FOUNDATION_READ_ENABLED':'true','MATCHING_FOUNDATION_ADMIN_ENABLED':'true',
    'MATCHING_FOUNDATION_EXECUTION_ENABLED':'true','MATCHING_FOUNDATION_DIGEST_KEY':data['digest'],
    'MATCHING_C2_MANUAL_CONSUMER_CONFIGURED':'true','MEDIA_STORAGE_DISK':'v1007','FILESYSTEM_DISK':'v1007',
    'V1007_MEDIA_ROOT':str(E/'media').replace('\\','/'),'ALLOW_PUBLIC_DEV_MATCHING':'false','ZIWEI_IZTRO_MODE':'off',
    'PY_ASTRO_API_BASE':'','PY_ASTRO_RENDER_URL':''}
env.write_text(''.join(k+'='+v+'\n'for k,v in values.items()))
for rel in ['storage/framework/views','storage/framework/cache/data','storage/framework/sessions','storage/logs']:(BACKEND/rel).mkdir(parents=True,exist_ok=True)
(E/'media').mkdir(exist_ok=True)
print(json.dumps({'database':'elitesync_v1007_dev','container':'elitesync-v1007-db','volume':'elitesync-v1007-db-data','loopback_port':data['port'],'credentials':'LOCAL_ONLY','health_exit':r.returncode}))
