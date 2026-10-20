import pathlib,subprocess,json,hashlib,datetime
E=pathlib.Path(__file__).parent
assert not (E/'final-db-dump.json').exists()
def run(args): return subprocess.run(args,capture_output=True)
r=run(['docker','exec','elitesync-v1011-relationships-db','sh','-c','exec mariadb-dump -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" --single-transaction --skip-comments elitesync_v10_1_1_dev'])
(E/'secrets/final-r1.sql').write_bytes(r.stdout);(E/'final-db-dump.stderr').write_bytes(r.stderr)
(E/'final-db-dump.json').write_text(json.dumps({'exit':r.returncode,'bytes':len(r.stdout),'sha256':hashlib.sha256(r.stdout).hexdigest()}))
assert r.returncode==0 and len(r.stdout)>233777
r=run(['docker','stop','elitesync-v1011-relationships-db'])
(E/'db-stop.stdout').write_bytes(r.stdout);(E/'db-stop.stderr').write_bytes(r.stderr)
assert r.returncode==0
before=json.loads((E/'protected-before.json').read_text())
results=[]
for b in before:
    root=pathlib.Path(b['root'])
    def git(*args): return subprocess.check_output(['git','-C',str(root),*args])
    index=pathlib.Path(git('rev-parse','--git-path','index').decode().strip())
    if not index.is_absolute(): index=root/index
    status=git('status','--porcelain=v1','--untracked-files=all')
    status_default=git('status','--porcelain=v1')
    def sha(v): return hashlib.sha256(v).hexdigest()
    status_hash=sha(status)
    if status_hash!=b['status_sha256'] and sha(status_default)==b['status_sha256']:
        status=status_default;status_hash=sha(status)
    row={'root':str(root),'head':git('rev-parse','HEAD').decode().strip(),'index_sha256':sha(index.read_bytes()),'status_sha256':status_hash,'status_entries':len(status.splitlines())}
    row['unchanged']=all(row[k]==b[k] for k in ['head','index_sha256','status_sha256'])
    results.append(row)
(E/'protected-final.json').write_text(json.dumps(results,indent=2))
resources={
    'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'db_container':json.loads(subprocess.check_output(['docker','inspect','elitesync-v1011-relationships-db','--format','{{json .State}}'])),
    'adb_devices':subprocess.check_output(['adb','devices']).decode(),
    'ports':subprocess.check_output(['powershell','-NoProfile','-Command',"@(Get-NetTCPConnection -State Listen -LocalPort 8012,8013,43322,5554,5556 -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,OwningProcess) | ConvertTo-Json -Compress"]).decode().strip(),
    'no_phone_or_rtc_operations':True,'no_firewall_or_dnat_or_uac_window':True,
    'volumes_and_backups_retained':True,
}
(E/'resources-final.json').write_text(json.dumps(resources,indent=2))
print(json.dumps({'protected_unchanged':[r['unchanged'] for r in results],'db_running':resources['db_container']['Running'],'ports':resources['ports'],'adb_devices':resources['adb_devices']}))
assert all(r['unchanged'] for r in results)
assert not resources['db_container']['Running'] and not resources['ports']
