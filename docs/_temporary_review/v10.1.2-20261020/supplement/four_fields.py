import pathlib,json,requests
E=pathlib.Path(__file__).parent;f=json.loads((E/'race-fourfields.private.json').read_text());receipts=[];a=f['owner'];b=f['viewer'];base='http://127.0.0.1:8015/api/v1'
def call(actor,method,path,data=None):
 r=requests.request(method,base+path,json=data,headers={'Accept':'application/json','Authorization':'Bearer '+actor['session']['access_token']},timeout=20);assert r.status_code==200,(path,r.status_code);j=r.json();receipts.append({'method':method,'path':path,'status':r.status_code,'cache_control':r.headers.get('Cache-Control'),'body':j});return j
fields=['birthday','interests','resume','zodiac'];expected={'birthday':'1994-02-03','interests':['SYNTHETIC_INTEREST'],'resume':'SYNTHETIC_PRIVATE_RESUME','zodiac':'SYNTHETIC_ZODIAC'}
pref=call(a,'GET','/privacy');rev=pref['revision'];path='/profile-peers/'+str(a['id']);allself={x:'SELF' for x in fields}
call(a,'PUT','/privacy',{'fields':allself,'expected_revision':rev});rev+=1;assert not set(fields)&call(b,'GET',path)['profile'].keys()
for field in fields:
 sel=allself|{field:'RELATIONSHIP_SHARED'};call(a,'PUT','/privacy',{'fields':sel,'expected_revision':rev});rev+=1
 profile=call(b,'GET',path)['profile'];assert profile[field]==expected[field],field;assert not (set(fields)-{field})&profile.keys(),field
call(a,'PUT','/privacy/resume',{'resume':None});call(a,'PUT','/privacy',{'fields':allself|{'resume':'RELATIONSHIP_SHARED'},'expected_revision':rev});assert 'resume' not in call(b,'GET',path)['profile']
(E/'four-fields-http-receipts.private.json').write_text(json.dumps(receipts,ensure_ascii=False,indent=2));out={'real_entry':'HTTP PrivacyController/SocialPolicy + owned MariaDB','statuses':[x['status'] for x in receipts],'all_four_individual_exact_values':True,'unselected_fields_absent':True,'SELF_all_absent':True,'null_resume_omitted':True,'side_effect':'only explicitly registered synthetic fourfields fixture','cache_private_no_store':all('no-store' in (x['cache_control'] or '') for x in receipts)};(E/'four-fields-result.json').write_text(json.dumps(out,indent=2));assert out['cache_private_no_store'];print(json.dumps(out))
