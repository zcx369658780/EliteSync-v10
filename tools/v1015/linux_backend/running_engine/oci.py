"""Download official Docker Library images through Meter; import only task tags.

No docker pull, build network, credential-store lookup, or shared-image cleanup.
"""
import gzip,hashlib,json,os,tarfile,re
from pathlib import Path
from urllib.parse import urlencode

ACCEPT=', '.join(['application/vnd.oci.image.index.v1+json','application/vnd.docker.distribution.manifest.list.v2+json','application/vnd.oci.image.manifest.v1+json','application/vnd.docker.distribution.manifest.v2+json'])
class LibraryImage:
 def __init__(self,meter,control,repository):
  if repository not in ('library/php','library/mariadb'):raise ValueError('OCI_REPOSITORY')
  self.meter=meter;self.control=control;self.repository=repository
  r=meter.fetch('https://auth.docker.io/token?'+urlencode({'service':'registry.docker.io','scope':'repository:'+repository+':pull'}),max_size=1048576)
  if r['status']!=200:raise RuntimeError('OCI_AUTH_SOURCE')
  self.token=json.loads(r['path'].read_bytes())['token']
 def get(self,kind,reference,expected=None):
  return self.meter.fetch('https://registry-1.docker.io/v2/'+self.repository+'/'+kind+'/'+reference,headers={'Authorization':'Bearer '+self.token,'Accept':ACCEPT},expected_sha256=expected,max_size=536870912)
 def resolve(self,tag):
  r=self.get('manifests',tag)
  if r['status']!=200:raise RuntimeError('OCI_MANIFEST_STATUS_'+str(r['status']))
  top='sha256:'+r['sha256'];self.control.cost('digests',repository=self.repository,digest=top,role='tag_index_or_manifest')
  header=next((v for k,v in r['headers'].items() if k.lower()=='docker-content-digest'),None)
  if header is not None and header!=top:raise RuntimeError('OCI_MANIFEST_HEADER_DIGEST')
  doc=json.loads(r['path'].read_bytes());selected=top
  if 'manifests' in doc:
   choices=[x for x in doc['manifests'] if x.get('platform',{}).get('os')=='linux' and x.get('platform',{}).get('architecture')=='amd64']
   if len(choices)!=1:raise RuntimeError('OCI_AMD64_SELECTION')
   selected=choices[0]['digest'];self.control.cost('digests',repository=self.repository,digest=selected,role='linux_amd64')
   r=self.get('manifests',selected,selected.removeprefix('sha256:'))
   if r['status']!=200:raise RuntimeError('OCI_PLATFORM_MANIFEST_STATUS')
   doc=json.loads(r['path'].read_bytes())
  if doc.get('schemaVersion')!=2 or 'config' not in doc or 'layers' not in doc:raise RuntimeError('OCI_SCHEMA')
  if len(doc['layers'])>128:raise RuntimeError('OCI_LAYER_LIMIT')
  for descriptor in [doc['config'],*doc['layers']]:
   if not re.fullmatch(r'sha256:[0-9a-f]{64}',descriptor['digest']) or not 0<=descriptor['size']<=536870912:raise RuntimeError('OCI_DESCRIPTOR')
  return dict(repository=self.repository,tag_observation=tag,index_digest=top,manifest_digest=selected,platform='linux/amd64',manifest=doc,manifest_sha256=r['sha256'])
 def materialize(self,resolved,directory,task_tag):
  if not task_tag.startswith('elitesync-v1015-running-20261030/'):raise ValueError('TASK_TAG')
  directory=Path(directory).resolve()
  if not directory.is_relative_to(self.control.R):raise ValueError('OCI_OWNED_DIRECTORY')
  directory.mkdir(parents=True,exist_ok=False);doc=resolved['manifest']
  cfg=doc['config']['digest'];r=self.get('blobs',cfg,cfg.removeprefix('sha256:'))
  if r['status']!=200 or r['bytes']!=doc['config']['size']:raise RuntimeError('OCI_CONFIG')
  config=r['path'].read_bytes();c=json.loads(config)
  if c.get('architecture')!='amd64' or c.get('os')!='linux':raise RuntimeError('OCI_CONFIG_PLATFORM')
  config_name=cfg.removeprefix('sha256:')+'.json'
  with (directory/config_name).open('xb') as f:f.write(config);f.flush();os.fsync(f.fileno())
  ids=c['rootfs']['diff_ids'];layers=[];layer_receipts=[]
  if len(ids)!=len(doc['layers']):raise RuntimeError('OCI_LAYER_COUNT')
  for i,layer in enumerate(doc['layers']):
   # Reserve a conservative per-layer expansion ceiling before writing it.
   current=self.control.space()
   if max(current['logical'],current['allocated'])+layer['size']+2147483648>=17179869184-67108864:raise RuntimeError('OCI_SPACE_RESERVE')
   digest=layer['digest'];r=self.get('blobs',digest,digest.removeprefix('sha256:'))
   if r['status']!=200 or r['bytes']!=layer['size']:raise RuntimeError('OCI_LAYER_SOURCE')
   media=layer['mediaType'];name=digest.removeprefix('sha256:')+'/layer.tar';p=directory/name;p.parent.mkdir()
   self.control.event('PREPARE_OCI_DECOMPRESS',digest=digest,output=str(p))
   opener=gzip.open if media.endswith('+gzip') or media.endswith('.gzip') else open
   if not (media.endswith('+gzip') or media.endswith('.gzip') or media.endswith('.tar')):raise RuntimeError('OCI_COMPRESSION')
   uncompressed=0;h=hashlib.sha256()
   with opener(r['path'],'rb') as src,p.open('xb') as dst:
    while True:
     b=src.read(1048576)
     if not b:break
     uncompressed+=len(b)
     if uncompressed>2147483648:raise RuntimeError('OCI_LAYER_UNCOMPRESSED_LIMIT')
     dst.write(b);h.update(b)
    dst.flush();os.fsync(dst.fileno())
   if 'sha256:'+h.hexdigest()!=ids[i]:raise RuntimeError('OCI_DIFF_ID')
   layers.append(name);layer_receipts.append(dict(digest=digest,compressed=r['bytes'],uncompressed=uncompressed,diff_id=ids[i]))
   self.control.space()
  with (directory/'manifest.json').open('xb') as f:f.write(json.dumps([{'Config':config_name,'RepoTags':[task_tag],'Layers':layers}]).encode());f.flush();os.fsync(f.fileno())
  archive=directory/'image.tar';self.control.event('PREPARE_DOCKER_ARCHIVE',task_tag=task_tag,archive=str(archive))
  current=self.control.space();archive_bound=sum((directory/n).stat().st_size+4096 for n in [config_name,'manifest.json',*layers])+1048576
  if max(current['logical'],current['allocated'])+archive_bound>=17179869184-67108864:raise RuntimeError('OCI_ARCHIVE_SPACE')
  with tarfile.open(archive,'w') as tar:
   for name in [config_name,'manifest.json',*layers]:tar.add(directory/name,arcname=name,recursive=False)
  with archive.open('r+b') as f:os.fsync(f.fileno())
  return {**resolved,'image_id':cfg,'task_tag':task_tag,'layers':layer_receipts,'archive':str(archive),'uncompressed_bytes':sum(x['uncompressed'] for x in layer_receipts)}
