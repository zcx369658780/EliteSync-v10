"""Real isolated Edge/Blade operation. Credentials and session never leave LOCAL_ONLY."""
import pathlib,sys,json,time
q=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(q/'tools/python-browser'))
from playwright.sync_api import sync_playwright
action=sys.argv[2];label=sys.argv[3];user=int(sys.argv[4]) if len(sys.argv)>4 else 3
account=json.loads((q/'secrets/accounts.json').read_text())['accounts']['admin']
with sync_playwright() as p:
    context=p.chromium.launch_persistent_context(str(q/'secrets/edge-profile'),executable_path='C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',headless=True,viewport={'width':1280,'height':1000})
    page=context.pages[0] if context.pages else context.new_page()
    page.goto('http://127.0.0.1:8000/admin/users/'+str(user))
    if page.locator('#password').count():
        page.locator('#phone').fill(account['phone']);page.locator('#password').fill(account['password'])
        page.get_by_role('button',name='登录管理端').click();page.wait_for_url('**/admin')
        page.goto('http://127.0.0.1:8000/admin/users/'+str(user))
    assert page.get_by_role('heading',name='分级处罚与受控恢复').count()==1
    if action in ['restrict','banned','restore']:
        form=page.locator('form').filter(has=page.locator('select[name="action"]'))
        form.locator('select[name="action"]').select_option(action)
        if action=='restore':form.locator('[name="sanction_id"]').fill(sys.argv[5])
        form.locator('[name="reason"]').fill('V1009 fictional RTC permission regression '+label)
        form.locator('[name="confirm"]').check()
        started=time.time()
        with page.expect_response(lambda r:'/punishment' in r.url and r.request.method=='POST') as response:
            form.get_by_role('button',name='执行处罚操作').click()
        status=response.value.status;ended=time.time();assert status==302,status
        page.wait_for_load_state('networkidle')
        (q/(label+'-web-operation.json')).write_text(json.dumps({'operation':action,'user_id':user,'submitted_at':started,'response_at':ended,'status':status,'browser':'isolated real Edge','csrf':'Blade form token submitted by browser'},indent=2))
    else:assert action=='view'
    page.screenshot(path=str(q/(label+'-blade.png')),full_page=True)
    print('Real Blade operation',action,'user',user,'completed')
    context.close()
