import pathlib,subprocess,json,re,hashlib,datetime
E=pathlib.Path(__file__).parent
C='elitesync-v1011-relationships-db'
before=(E/'secrets/before-r1.sql').read_bytes()
assert len(before)==233777 and before.count(b'CREATE TABLE')==62
assert (E/'secrets/incident-after-feature.sql').is_file()
assert not (E/'recovery.json').exists()
cmd=['docker','exec','-i',C,'sh','-c','exec mariadb -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" elitesync_v10_1_1_dev']
r=subprocess.run(cmd,input=before,capture_output=True)
(E/'recovery.stdout').write_bytes(r.stdout);(E/'recovery.stderr').write_bytes(r.stderr)
assert r.returncode==0
d=subprocess.run(['docker','exec',C,'sh','-c','exec mariadb-dump -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" --single-transaction --skip-comments --skip-extended-insert elitesync_v10_1_1_dev'],capture_output=True)
(E/'secrets/recovered-before-r1.sql').write_bytes(d.stdout)
assert d.returncode==0
def inserts(data):
    # The recovery point uses one INSERT statement with newline-separated VALUES.
    return {m.group(1).decode():m.group(2).replace(b'\n',b'').replace(b'\r',b'') for m in re.finditer(rb'INSERT INTO `([^`]+)` VALUES\s*(.*?);(?:\r?\n)',data,re.S)}
a=inserts(before)
# Re-dump in the exact original INSERT layout to compare original logical bytes.
original_style=subprocess.run(['docker','exec',C,'sh','-c','exec mariadb-dump -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" --single-transaction --skip-comments --skip-extended-insert=FALSE elitesync_v10_1_1_dev'],capture_output=True)
assert original_style.returncode==0
b=inserts(original_style.stdout)
# Original --skip-extended-insert=FALSE may differ in statement grouping; use a
# second import-free dump with --complete-insert? Compare normalized VALUES list.
def normalize(data):
    rows={}
    for m in re.finditer(rb'INSERT INTO `([^`]+)` VALUES\s*(.*?);(?:\r?\n)',data,re.S):
        rows.setdefault(m.group(1).decode(),[]).append(m.group(2).replace(b'\n',b'').replace(b'\r',b''))
    return {k:hashlib.sha256(b','.join(v)).hexdigest() for k,v in rows.items()}
na,nb=normalize(before),normalize(original_style.stdout)
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'restore_exit':r.returncode,'dump_exit':d.returncode,'before_sha256':hashlib.sha256(before).hexdigest(),'recovery_insert_tables':len(na),'all_original_insert_tables_identical':na==nb,'changed_or_missing_tables':sorted(k for k in na if na.get(k)!=nb.get(k)),'before_insert_hashes':na,'recovered_insert_hashes':nb,'note':'Original pre-R1 logical data restored. R1 fixtures lost by erroneous RefreshDatabase are recorded separately; original test evidence is retained.'}
(E/'recovery.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if not k.endswith('hashes')}))
assert na and na==nb
