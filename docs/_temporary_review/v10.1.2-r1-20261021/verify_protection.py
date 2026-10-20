import pathlib,subprocess,hashlib,json,os,socket
E=pathlib.Path(__file__).parent;b=json.loads((E/'protection-before.json').read_text());out={};env=dict(os.environ,GIT_OPTIONAL_LOCKS='0')
def h(x):return hashlib.sha256(x).hexdigest()
for i,(root,v) in enumerate(b.items()):
 row={}
 for key,cmd in [('head',['rev-parse','HEAD']),('index',['rev-parse','--git-path','index'])]:
  r=subprocess.run(['git','-C',root,*cmd],capture_output=True,env=env);(E/f'final-{i}-{key}.raw').write_bytes(r.stdout);row[key]=r.returncode==0 and h(r.stdout)==v[key]['sha256']
 for opts in [['status','--porcelain=v1','--untracked-files=all'],['status','--short','--untracked-files=all'],['status','--porcelain=v1']]:
  r=subprocess.run(['git','-C',root,*opts],capture_output=True,env=env)
  if h(r.stdout)==v['status']['sha256']:break
 (E/f'final-{i}-status.raw').write_bytes(r.stdout);row['status']=h(r.stdout)==v['status']['sha256'];p=pathlib.Path(subprocess.check_output(['git','-C',root,'rev-parse','--git-path','index'],env=env).decode().strip());p=p if p.is_absolute() else pathlib.Path(root)/p;row['index_bytes']=h(p.read_bytes())==v['index_bytes_sha256'];out[root]=row
r=subprocess.run(['docker','ps','-a','--format','{{json .}}'],capture_output=True,check=True);(E/'docker-final.private.raw').write_bytes(r.stdout);before=[json.loads(x) for x in (E/'docker-engine-ready-before.raw').read_text().splitlines() if x];after=[json.loads(x) for x in r.stdout.decode().splitlines() if x];old={x['Names']:(x['ID'],x['State']) for x in before if x['Names']!='elitesync-v1012-journey-db'};new={x['Names']:(x['ID'],x['State']) for x in after if x['Names']!='elitesync-v1012-journey-db'};ports={}
for p in [8015,8016,43323,5554]:
 s=socket.socket();ports[p]=s.connect_ex(('127.0.0.1',p))==0;s.close()
result={'protected_roots':out,'historical_containers_same_id_state':old==new,'owned_ports_listening':ports};(E/'protection-final.json').write_text(json.dumps(result,indent=2));print(json.dumps(result));assert all(all(x.values()) for x in out.values()) and old==new and not any(ports.values())
