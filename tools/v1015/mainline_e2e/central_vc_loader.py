"""Real central-image file verification used by static and post-Popen guards.

Windows trust is captured separately before launch. Every use rebinds actual
SystemDirectory/FileId/Volume/hash; no system DLL is copied or loaded by this module.
"""
import ntpath
from contracts import need, digest, canonical
from os_images import norm, system_root_fact, readonly_fact
from windows_vc_trust import evaluate_trust, CENTRAL_NAME

CLASS='MICROSOFT_CENTRAL_V14_RUNTIME'


def validate_snapshot(snapshot):
    need(isinstance(snapshot,dict) and snapshot.get('schema')==1
         and snapshot.get('source_class')==CLASS and snapshot.get('module')==CENTRAL_NAME,
         'CENTRAL_SNAPSHOT_CLASS')
    evaluate_trust(snapshot.get('trust',{}))
    need(snapshot.get('qualification',{}).get('state')=='CENTRAL_VC_EVIDENCE_QUALIFIED',
         'CENTRAL_SNAPSHOT_NOT_QUALIFIED')
    need(snapshot.get('trust_evidence_sha256')==digest(canonical(snapshot['trust'])),
         'CENTRAL_TRUST_RECEIPT_HASH')
    root=snapshot['system_root'];file=snapshot['file']
    need(root.get('from_system_directory_api') is True and not root.get('reparse')
         and norm(ntpath.dirname(file['path']))==norm(root['path'])
         and norm(file['canonical_path'])==norm(file['path'])
         and ntpath.basename(file['path']).lower()==CENTRAL_NAME,'CENTRAL_SNAPSHOT_PATH')
    need(file.get('links')==1 and file.get('reparse') is False
         and file.get('architecture')=='x64' and file.get('readonly_handle') is True,
         'CENTRAL_SNAPSHOT_FILE')
    need(file.get('sha256')=='d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7'
         and file.get('file_version')=='14.51.36247.0','CENTRAL_FROZEN_SOURCE_CHANGED')
    for key in ('file_id','volume','bytes'):
        need(type(file.get(key)) is int and file[key]>0,'CENTRAL_SNAPSHOT_IDENTITY')
    need(file['volume']==root['volume'],'CENTRAL_SNAPSHOT_VOLUME')
    return snapshot


def verify_current(snapshot, loaded_path=None):
    snapshot=validate_snapshot(snapshot);pin=snapshot['file'];system=system_root_fact()
    need(norm(system['path'])==norm(snapshot['system_root']['path'])
         and system['file_id']==snapshot['system_root']['file_id']
         and system['volume']==snapshot['system_root']['volume'],'CENTRAL_SYSTEM_ROOT_REPLACED')
    path=loaded_path or pin['path']
    need(norm(path)==norm(pin['path']),'CENTRAL_LOADED_WRONG_PATH')
    fact=readonly_fact(path)
    for key in ('file_id','volume','sha256','links','bytes','reparse'):
        need(fact.get(key)==pin.get(key),'CENTRAL_IMAGE_REPLACED')
    need(norm(fact['canonical_path'])==norm(pin['path']) and fact['readonly_handle'],
         'CENTRAL_LOADED_ALIAS')
    return dict(path=fact['canonical_path'],sha256=fact['sha256'],source_class=CLASS,
                file_id=fact['file_id'],volume=fact['volume'],links=fact['links'],
                file_version=pin['file_version'],trust_evidence_sha256=snapshot['trust_evidence_sha256'])


def check_loaded_receipt(image,snapshot):
    snapshot=validate_snapshot(snapshot);pin=snapshot['file']
    need(image.get('source_class')==CLASS and norm(image['path'])==norm(pin['path']),
         'CENTRAL_LOADED_SOURCE_CLASS')
    for key in ('sha256','file_id','volume','links','file_version'):
        need(image.get(key)==pin.get(key),'CENTRAL_LOADED_RECEIPT_MISMATCH')
    need(image.get('trust_evidence_sha256')==snapshot['trust_evidence_sha256'],
         'CENTRAL_LOADED_TRUST_MISMATCH')
