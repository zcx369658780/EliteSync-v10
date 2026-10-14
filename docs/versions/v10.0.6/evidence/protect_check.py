import os,json,hashlib,subprocess
from pathlib import Path
root=Path(r'D:/EliteSync-v10')
e=Path(__file__).parent
before=json.loads((e/'root-before.json').read_text(encoding='utf8'))
env=dict(os.environ,GIT_OPTIONAL_LOCKS='0')
def git(*args): return subprocess.check_output(['git',*args],cwd=root,env=env)
def sha(b): return hashlib.sha256(b).hexdigest()
index=Path(git('rev-parse','--git-path','index').decode().strip())
if not index.is_absolute(): index=root/index
current={'head':git('rev-parse','HEAD').decode().strip(),'index':sha(index.read_bytes()),
         'status':sha(git('status','--porcelain=v1','--untracked-files=normal')),
         'root_agents':sha((root/'AGENTS.md').read_bytes())}
current['named_files']={p:sha((root/p).read_bytes()) if (root/p).is_file() else None for p in before['named_files']}
changed=[k for k in before if before[k]!=current[k]]
result={'same':not changed,'changed_groups':changed,'named_count':len(current['named_files']),
        'current':current}
(e/'root-after.json').write_text(json.dumps(result,indent=2),encoding='utf8')
print(json.dumps({k:v for k,v in result.items() if k!='current'}))
assert not changed,changed
