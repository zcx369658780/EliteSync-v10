"""Explicit local Desktop endpoint; task tags and labels only, never daemon start."""
import json,os,re,tarfile,hashlib
from pathlib import Path
TASK='V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030'
PARENT='debe4a11d19f25179efef1d90d04e346980c2867'
PREFIX='elitesync-v1015-running-20261030'
def validate_args(args,root):
 """Fail closed on daemon/global operations and non-task resource targets."""
 if not args:raise ValueError('DOCKER_OPERATION')
 op=args[0]
 def own(value):
  if not isinstance(value,str) or not value.startswith(PREFIX+('-' if '/' not in value else '/')):raise ValueError('NON_TASK_RESOURCE')
 def option(key):
  if key not in args:raise ValueError('REQUIRED_'+key)
  return args[args.index(key)+1]
 def path(value):
  if not Path(value).resolve().is_relative_to(root.resolve()):raise ValueError('NON_TASK_PATH')
 if op in ('version','info'):return
 if op=='image':
  if len(args)<3 or args[1] not in ('inspect','save'):raise ValueError('IMAGE_OPERATION')
  own(args[-1])
  if args[1]=='save':path(option('--output'))
 elif op in ('start','stop'):
  targets=[a for a in args[1:] if not a.startswith('-') and not a.isdigit()]
  if not targets:raise ValueError('TASK_TARGET_REQUIRED')
  for target in targets:own(target)
 elif op=='rename':
  if len(args)!=3:raise ValueError('RENAME_ARGUMENTS')
  own(args[1]);own(args[2])
 elif op=='logs':own(args[-1])
 elif op in ('exec','inspect'):
  index=1
  if op=='exec':
   while index<len(args) and args[index].startswith('-'):
    index+=2 if args[index] in ('--user','--workdir','--env') else 1
  own(args[index])
  if op=='inspect' and len(args)!=2:raise ValueError('ONE_TASK_INSPECT_TARGET')
 elif op in ('network','volume'):
  if len(args)<3 or args[1] not in ('create','inspect'):raise ValueError('RESOURCE_OPERATION')
  own(args[-1])
  if args[1]=='create':
   if 'elitesync.task='+TASK not in args or 'elitesync.parent='+PARENT not in args:raise ValueError('TASK_LABELS')
   if op=='network' and '--internal' not in args:raise ValueError('INTERNAL_NETWORK_REQUIRED')
 elif op=='load':path(option('--input'))
 elif op=='cp':
  if len(args)!=3:raise ValueError('COPY_ARGUMENTS')
  own(args[1].split(':',1)[0]);path(args[2])
 elif op in ('run','create'):
  own(option('--name'))
  if 'elitesync.task='+TASK not in args or 'elitesync.parent='+PARENT not in args:raise ValueError('TASK_LABELS')
  if option('--network') not in ('none',PREFIX+'-net'):raise ValueError('TASK_NETWORK')
  if '--privileged' in args or any(a.startswith(('--pid','--ipc','--volumes-from','--device','--cap-add')) for a in args):raise ValueError('SHARED_PRIVILEGE')
  if option('--cap-drop')!='ALL' or 'no-new-privileges' not in args or '--read-only' not in args:raise ValueError('ISOLATION_REQUIRED')
  if option('--user') not in ('1000:1000','999:999'):raise ValueError('TASK_UID')
  for i,a in enumerate(args):
   if a in ('-v','--volume'):raise ValueError('EXPLICIT_MOUNT_REQUIRED')
   if a=='--mount':
    parts=dict(x.split('=',1) for x in args[i+1].split(',') if '=' in x)
    source=parts.get('source',parts.get('src',''))
    if parts.get('type')=='bind':path(source)
    elif parts.get('type')=='volume':own(source)
    else:raise ValueError('MOUNT_TYPE')
 elif op=='build':
  if option('--network')!='none':raise ValueError('OFFLINE_BUILD_REQUIRED')
  own(option('--tag'));path(args[-1])
 else:raise ValueError('DOCKER_OPERATION')

class Engine:
 def __init__(self,control):
  self.c=control;self.cli=Path(r'C:\Program Files\Docker\Docker\resources\bin\docker.exe')
  self.cli_identity=(self.cli.stat().st_ino,self.cli.stat().st_size,self.cli.stat().st_mtime_ns)
  frozen=next(x for x in json.loads((control.R/'runtime/installed-binary-source-lock.json').read_text(encoding='utf-8')) if x['installation_file']=='docker.exe')
  if self.cli_identity!=(frozen['file_id'],frozen['bytes'],frozen['mtime_ns']) or hashlib.sha256(self.cli.read_bytes()).hexdigest()!=frozen['sha256']:raise RuntimeError('FROZEN_DOCKER_CLI_CHANGED')
  s=control.rows()[0]
  if s['task_id']!=TASK or s['sole_parent']!=PARENT:raise RuntimeError('ENGINE_TASK_BINDING')
  self.env={k:v for k,v in os.environ.items() if not k.startswith(('DOCKER_','COMPOSE_'))}
  self.env['DOCKER_CONFIG']=str(control.R/'docker-config');self.env['DOCKER_HOST']='npipe:////./pipe/dockerDesktopLinuxEngine'
 def call(self,name,args,timeout=60,categories=()):
  validate_args(args,self.c.R)
  if (self.cli.stat().st_ino,self.cli.stat().st_size,self.cli.stat().st_mtime_ns)!=self.cli_identity:raise RuntimeError('DOCKER_CLI_CHANGED')
  # No host reactivation, plugin, prune, pull, push, or global config operations.
  if not args or args[0] not in ('version','info','load','image','run','create','start','stop','exec','inspect','logs','network','volume','build','cp','rename'):raise ValueError('DOCKER_OPERATION')
  if args[0]=='network' and (len(args)<2 or args[1] not in ('create','inspect')):raise ValueError('NETWORK_OPERATION')
  if args[0]=='volume' and (len(args)<2 or args[1] not in ('create','inspect')):raise ValueError('VOLUME_OPERATION')
  return self.c.run(name,[str(self.cli),*args],timeout=timeout,env=self.env,categories=categories)
 def load(self,name,receipt):
  if not receipt['task_tag'].startswith(PREFIX+'/'):raise ValueError('IMAGE_TAG')
  self.reserve_image(name,receipt['uncompressed_bytes']*3+67108864)
  r,b,e=self.call(name+'-image-load',['load','--input',receipt['archive']],timeout=300)
  if r['exit']!=0:raise RuntimeError('IMAGE_LOAD_FAILED')
  return self.verify_loaded(name,receipt)
 def reserve_image(self,name,maximum):
  p=self.c.R/'daemon-space.json';v=json.loads(p.read_text()) if p.is_file() else {'images':{}}
  v.setdefault('images',{})[name]=maximum;v['upper_bound_bytes']=sum(v['images'].values());v['classification']='CONSERVATIVE_ADDITIVE_TASK_IMAGE_AND_BUILD_SIZE'
  self.c.jwrite('daemon-space.json',v,replace=p.exists());self.c.space()
 def verify_loaded(self,name,receipt):
  r,b,e=self.call(name+'-image-inspect-verified',['image','inspect',receipt['task_tag']],timeout=30);v=json.loads(b)
  if r['exit']!=0 or len(v)!=1 or v[0]['Os']!='linux' or v[0]['Architecture']!='amd64':raise RuntimeError('LOADED_IMAGE_PLATFORM')
  path=self.c.R/'oci'/(name+'-export.tar')
  if not path.exists():
   current=self.c.space()
   if max(current['logical'],current['allocated'])+receipt['uncompressed_bytes']*2>=17179869184-67108864:raise RuntimeError('IMAGE_EXPORT_SPACE')
   self.c.event('PREPARE_OWN_IMAGE_EXPORT',path=str(path),task_tag=receipt['task_tag'])
   r,b,e=self.call(name+'-image-config-export',['image','save','--output',str(path),receipt['task_tag']],timeout=180)
   if r['exit']!=0:raise RuntimeError('IMAGE_EXPORT')
  with tarfile.open(path,'r') as tar:
   manifests=json.loads(tar.extractfile('manifest.json').read())
   if len(manifests)!=1 or manifests[0]['RepoTags']!=[receipt['task_tag']]:raise RuntimeError('EXPORTED_TASK_TAG')
   config=tar.extractfile(manifests[0]['Config']).read()
  if 'sha256:'+hashlib.sha256(config).hexdigest()!=receipt['image_id']:raise RuntimeError('EXPORTED_CONFIG_ID')
  c=json.loads(config)
  if v[0]['RootFS']['Layers']!=c['rootfs']['diff_ids']:raise RuntimeError('LOADED_DIFF_IDS')
  self.c.jwrite('supply/'+name+'-loaded-identity.json',{'source_manifest_digest':receipt['manifest_digest'],'source_config_digest':receipt['image_id'],'engine_image_id':v[0]['Id'],'descriptor':v[0].get('Descriptor'),'exported_config_verified':True,'complete_diff_ids_match':True,'size_observed':v[0].get('Size')})
  self.reserve_image(name,max(receipt['uncompressed_bytes']*3+67108864,v[0].get('Size',0)+67108864))
  return v[0]
 def labels(self):return ['--label','elitesync.task='+TASK,'--label','elitesync.parent='+PARENT]
 def owned_container(self,name):
  if not name.startswith(PREFIX+'-'):raise ValueError('CONTAINER_NAME')
  r,b,e=self.call('inspect-'+name,['inspect',name],timeout=20);v=json.loads(b)[0]
  if r['exit']!=0 or v['Config'].get('Labels',{}).get('elitesync.task')!=TASK or v['Config']['Labels'].get('elitesync.parent')!=PARENT:raise RuntimeError('CONTAINER_OWNERSHIP')
  return v
