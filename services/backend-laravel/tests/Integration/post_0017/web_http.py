from http_journey import *
import urllib.request,urllib.parse,urllib.error,http.cookiejar,re
class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self,*args,**kwargs):return None
def client():return urllib.request.build_opener(urllib.request.ProxyHandler({}),urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()),NoRedirect())
def web(browser,path,data=None):
    o.reserve('PREPARE_LOCAL_WEB_HTTP',{'loopback_web_http_requests':1},path=path,method='POST' if data else 'GET')
    req=urllib.request.Request('http://127.0.0.1:'+str(c['api_port'])+path,data=urllib.parse.urlencode(data).encode() if data else None)
    try:r=browser.open(req,timeout=20)
    except urllib.error.HTTPError as ex:r=ex
    text=r.read().decode('utf-8',errors='replace');headers=dict(r.headers);raw.append({'path':path,'status':r.code,'html':text,'headers':headers});o.event('WEB_HTTP_RESULT',path=path,status=r.code)
    return r.code,text,headers
def csrf(html):return re.search(r'name="_token"\s+value="([^"]+)"',html).group(1)
try:
    admin=client();status,html,h=web(admin,'/admin/login');check('actual Web login CSRF form',status==200)
    status,html,h=web(admin,'/admin/login',{'_token':csrf(html),'phone':'synthetic-c31-admin','password':'ClosureSyntheticPassword42'})
    check('actual task admin login',status==302 and h.get('Location','').endswith('/admin'))
    status,html,h=web(admin,'/admin');check('operator sees same synthetic database actors',status==200 and 'synthetic-c31-a' in html and 'synthetic-c31-b' in html)
    check('operator list does not expose private chat content','Closure synthetic logical message' not in html and 'Closure synthetic dropped ACK' not in html)
    logout_token=csrf(html)
    status,html,h=web(admin,'/admin/audits');check('existing audit endpoint',status==200)
    status,html,h=web(admin,'/admin/logout',{'_token':logout_token});check('actual Web logout',status==302)
    status,html,h=web(admin,'/admin');check('old Web session denied after logout',status in (302,401,403) and 'synthetic-c31-a' not in html)
    ordinary=client();status,html,h=web(ordinary,'/admin/login')
    web(ordinary,'/admin/login',{'_token':csrf(html),'phone':'synthetic-c31-b','password':'ClosureSyntheticPassword42'})
    status,html,h=web(ordinary,'/admin');check('ordinary actor cannot access administration',status in (302,401,403) and 'synthetic-c31-a' not in html)
    save('test/new-web-http-receipt.json',{'checks':checks,'passed':sum(x['passed'] for x in checks),'classification':'REAL_WEB_HTTP__BROWSER_UI_NOT_RUN_KERNEL_UNAVAILABLE'})
finally:save('runtime/web-http-raw-LOCAL_ONLY.json',raw)
print(json.dumps({'web_http_checks':len(checks),'browser_visual_ui':'NOT_RUN_TOOL_GATE'}))
