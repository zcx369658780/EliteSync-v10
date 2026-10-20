import requests,pathlib,json,base64,hashlib,sys
E=pathlib.Path(__file__).parent
c=json.loads((E/'secrets/app-target.json').read_text())
base='http://127.0.0.1:8012/api/v1'
def request(who,method,path,**kw):
    r=requests.request(method,base+path,headers={'Authorization':'Bearer '+c[who+'_token'],'Accept':'application/json'},timeout=20,**kw)
    return r
if sys.argv[1]=='prepare':
    png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAKklEQVR4nGNIaDhAU8QwasGoBaMWjFowasGoBaMWjFowasGoBaMWDBULANs4gFsEScpzAAAAAElFTkSuQmCC')
    r=request('owner','POST','/media',data={'media_type':'image'},files={'file':('r1-app.png',png,'image/png')}); assert r.status_code==200,r.status_code
    a=r.json()['asset']['id']
    r=request('owner','POST','/status/posts',json={'title':'R1_APP_COVER','body':'R1_APP_PRIVATE_BODY','audience':'FRIENDS','cover_media_asset_id':a});assert r.status_code==201,r.status_code
    p=r.json()['item']['id']
    r=request('viewer','GET',f'/media/{a}/content');assert r.status_code==200 and r.content==png
    # Retire the earlier invalid-CRC synthetic cover via the product owner flow.
    r=request('owner','DELETE',f'/status/posts/{c["post_id"]}');assert r.status_code==200
    (E/'secrets/app-product-target.json').write_text(json.dumps({'post_id':p,'asset_id':a}))
    print(json.dumps({'product_upload_and_create':True,'authorized_image_status':200,'image_sha256':hashlib.sha256(png).hexdigest(),'old_synthetic_cover_soft_deleted':True}))
else:
    t=json.loads((E/'secrets/app-product-target.json').read_text());p=t['post_id'];a=t['asset_id']
    if sys.argv[1]=='revoke':
        r=request('owner','PUT',f'/status/posts/{p}/audience',json={'audience':'SELF'});assert r.status_code==200
    if sys.argv[1]=='restore':
        r=request('owner','PUT',f'/status/posts/{p}/audience',json={'audience':'FRIENDS'});assert r.status_code==200
    r=request('viewer','GET',f'/status/posts/{p}'); image=request('viewer','GET',f'/media/{a}/content')
    out={'post_status':r.status_code,'cover_status':image.status_code,'private_body_returned':b'R1_APP_PRIVATE_BODY' in r.content,'private_image_returned':image.headers.get('Content-Type','').startswith('image/')}
    if sys.argv[1]=='revoke':
        assert r.status_code==404 and image.status_code==404 and not out['private_body_returned'] and not out['private_image_returned']
    else:
        assert r.status_code==200 and image.status_code==200
        out.update({k:r.json()['item'][k] for k in ['liked_by_viewer','likes_count']})
    print(json.dumps(out))
