from http_journey import *
import time
try:
    # Real logical recovery copy is retained/read back; no restore execution is claimed.
    dump='exec mariadb-dump --protocol=tcp --host="$(hostname -i)" --port=55417 --user="$MARIADB_USER" --password="$MARIADB_PASSWORD" --single-transaction --skip-lock-tables --skip-comments --databases "$MARIADB_DATABASE"'
    v,body,e=o.run('save-populated-new-schema-recovery-copy',[o.DOCKER,'--context','desktop-linux','exec',c['db'],'sh','-c',dump],timeout=45,cost={'synthetic_recovery_dumps':1})
    check('own populated recovery SQL produced',v['exit']==0 and b'CREATE TABLE' in body and b'INSERT INTO' in body)
    o.write('runtime/recovery/populated-schema-LOCAL_ONLY.sql',body);check('own recovery SQL readback hash',o.sha((R/'runtime/recovery/populated-schema-LOCAL_ONLY.sql').read_bytes())==o.sha(body))
    before=fixture('snapshot');save('runtime/before-db-restart-LOCAL_ONLY.json',before)
    v,body,e=o.run('own-db-before-restart-identity',[o.DOCKER,'--context','desktop-linux','inspect',c['db']],cost={'docker_readonly':1});check('own DB inspect',v['exit']==0);i=json.loads(body)[0]
    check('new isolated volume before real restart',i['Config']['Labels']['elitesync.task']==o.TASK and [m.get('Name') for m in i['Mounts'] if m['Type']=='volume']==[c['volume']]);started=i['State']['StartedAt']
    v,_,_=o.run('stop-own-mariadb-process',[o.DOCKER,'--context','desktop-linux','stop','--time','20',c['db']],timeout=40,cost={'db_process_stops':1});check('own MariaDB real stop',v['exit']==0)
    v,body,e=o.run('own-db-stopped-proof',[o.DOCKER,'--context','desktop-linux','inspect',c['db']],cost={'docker_readonly':1});state=json.loads(body)[0]['State'];check('real DB process absent',not state['Running'] and state['Pid']==0)
    try:
        try:code,_,_,_=http('GET','/api/v1/app/health',status=None,timeout=3);down={'kind':'HTTP_RESPONSE','status':code};check('DB down cannot report healthy',code in (500,503))
        except TimeoutError:down={'kind':'BOUNDED_HOST_TIMEOUT','seconds':3};check('DB down observed as bounded timeout',True)
    finally:
        v,_,_=o.run('start-own-mariadb-process',[o.DOCKER,'--context','desktop-linux','start',c['db']],cost={'db_process_starts':1});check('own DB actual start',v['exit']==0)
    for n in range(5):
        v,body,e=o.run('new-db-restart-readiness-'+str(n),[o.DOCKER,'--context','desktop-linux','exec',c['api'],'php','tests/Integration/post_0017/scenario.php','snapshot','{}'],timeout=25,cost={'db_readiness_queries':1})
        if v['exit']==0:after=json.loads(body);break
        time.sleep(2)
    else:raise RuntimeError('Own DB recovery readiness failed')
    save('runtime/after-db-restart-LOCAL_ONLY.json',after);check('all actual table row counts and full hashes preserved',before==after)
    v,body,e=o.run('own-db-new-process-identity',[o.DOCKER,'--context','desktop-linux','inspect',c['db']],cost={'docker_readonly':1});state=json.loads(body)[0]['State'];check('new DB process start identity',state['Running'] and state['StartedAt']!=started)
    http('GET','/api/v1/app/health');b=actors()['b'];a=actors()['a'];http('GET',f"/api/v1/messages?peer_id={a['id']}",token=b['access'],status=(404,));http('GET','/api/v1/notification-preferences',token=b['access'])
    save('test/new-db-persistence-receipt.json',{'checks':checks,'passed':sum(x['passed'] for x in checks),'tables':len(after['tables']),'rows':sum(x['rows'] for x in after['tables'].values()),'full_rows_aggregate_sha256':after['aggregate'],'db_down_observation':down,'recovery_SQL_readback':True,'logical_restore_executed':False,'classification':'ACTUAL_NEW_MARIADB_PROCESS_RESTART_NOT_APP_DEVICE'})
finally:save('runtime/db-restart-http-raw-LOCAL_ONLY.json',raw)
print(json.dumps({'persistence_checks':len(checks),'db_down':down}))
