# APP-M5-34｜可审查冻结源码验证 harness 候选

2026-09-30；SOURCE-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。A 1/1 成功、B 1/1 成功并关闭；两新 script 已按 B 最终身份冻结。没有 Python/AST/生产/测试/launcher/监控试跑。作者未自接受或派发后继。

## 入口与唯一差异

唯一仓库 D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。执行会话 01a0f1ec-ff46-7311-a52f-780a64e3d4fb；TASK_CURRENT 顶部 ISSUED 与明确派发匹配，沿用 elitesync-local-workflow。仅新增本目录 check_frozen_sources.py、Invoke-FrozenAarValidation.ps1、summary.md。两原算法 source 不改。M5-29 DOCS-ONLY ACCEPT、M5-30/31/32 REJECT/CLOSED、M5-33 HARNESS NOT_DELIVERED/REJECT/CLOSED 与全部旧预算保持。

入口 status 185：任务要求保留的 184 条既有成员加 Work 已创建的 M5-34 任务目录。只读 Git 对照保存的 183 条接管清单及 M5-33 目录：184 条无缺项，当前 185 条，唯一新增 status 为 M5-34 证据目录。这是成员保持证明，不宣称所有既有文件的逐字节完整性。无 Git mutation。

## 完整脚本的设计边界

checker 固定两源路径/大小/hash，每源一次 bytes 读取；普通非 reparse 门、utf-8-sig/AST、分离的生产/测试 imports 与执行节点门。固定 receiver 识别 spec/module/exec_module、登记顺序、明确 loader、唯一 unittest.TextTestRunner(verbosity=2).run(suite)、suite/outcome 绑定及非零和成功退出表达式。其它 run 或 exec_module 不获得自由豁免；不对 fixture 字符串/注释做宿主命令禁词。七 frozen/slots 类型与无 mutable 注解、keyword-only 接口、四原 fixture、14 个独立 EXPECTED_CODE block hash、三个完整 EXPECTED_SCRATCH hash、独立 expected 不调用 adapter/私有常量、12 方法、P1/P2 整返回与完整 scratch 比较均具名检查。expected 可以使用公开 frozen 类型构造器，不能用生产输出回算 oracle。

这些检查尚未执行。方法存在/比较 AST 形状及字面量身份只构成静态结构门，不是全面负例有效性、形式化纯度或算法正确性证明。固定 hash 不追认旧验证。旧 checker 仅作为 JS 模板字面文本参考，新 checker 重新编写，不执行或直接复制恢复模板。

launcher 无默认 Mode，仅显式 Static/Test 和必填 ASCII64hex CheckerSha256；固定 Python/cwd/checker/两源、文件和 hash 门、ArgumentList 直接传参、最多一次 Start。Test 不自动接续 Static，也不自判断 Work 权限。两 BaseStream 各一个异步原始 byte read，逐块主动累计 32768 bytes；限额内保留完整原字节、严格 UTF8 解码，失败也返回已捕获 raw base64 与具名状态。子进程退出和两路 EOF 同受截止；59 秒执行窗口为同一 60 秒总截止预留 cleanup，Kill 后只在剩余时间轮询退出，没有 WaitForExit/ReadToEnd/Task.Wait、第二进程或重试。exit 非零或监控失败不能被 launcher exit 0 掩盖。

launcher 与 checker 的 Python 语法、实际 AST gate 接受性、Windows/.NET 异步行为、UTF8/超量/超时/异常清理、原生 API 调用耗时及真正 OS 级终止保证均未验证。此源码不证明进程树隔离或硬 OS 截止；Work 须独立审查后另立准确运行预算，不以 PowerShell ParseInput 代替这些证明。

## A 原始同次回执

chunk efb104；exit 0；wall_time_seconds 0.1849397。五来源各一次 ReadAllBytes，普通非 reparse/单份≤256KiB/总≤512KiB，固定两 source 大小/hash与 plan hash门通过。总 146279 bytes。输出仅五身份行、总量/read_count、≤16KiB 旧 checker 文本；两原 source、plan、M5-32 summary 正文全部不回显。payload UTF8 主动累计 7111 bytes，末计数行后仍远小于 32KiB。无来源补读、Python/AST子进程或新增 SDK 事实。

下面完整保留同次工具 stdout；旧 checker 区域是不能执行的来源文本，不是新脚本：

```text
SOURCE apps/android_synthetic_demo/tools/aar_entry_materials.py BYTES=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7
SOURCE apps/android_synthetic_demo/tools/test_aar_entry_materials.py BYTES=74376 SHA256=F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2
SOURCE EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md BYTES=40085 SHA256=B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382
SOURCE EVIDENCE/APP-M5-31-FROZEN-AAR-MATERIALS-VALIDATION/static-original-checker.txt BYTES=6273 SHA256=7E66FFC018E043E99BF136BFBBDADA6F3ADA5A9EA69CC95C62210ABBE6A29D91
SOURCE EVIDENCE/APP-M5-32-AST-CHECKER-CORRECTION-FROZEN-VALIDATION/summary.md BYTES=5207 SHA256=D9B9ED3E17843DAEEF54EA99A8A0C3C0DEE9F0730FDA4723008CBAC7B45E7404
TOTAL_BYTES=146279 READ_COUNT=5 A_BUDGET=1/1
import ast
import hashlib
from pathlib import Path
paths = [Path('D:/EliteSync-v10/apps/android_synthetic_demo/tools/aar_entry_materials.py'),Path('D:/EliteSync-v10/apps/android_synthetic_demo/tools/test_aar_entry_materials.py')]
expected = [(20338,'B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7'),(74376,'F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2')]
trees=[]
texts=[]
for p,(size,digest) in zip(paths,expected):
    assert p.is_file() and not p.is_symlink() and p.stat().st_size==size
    b=p.read_bytes()
    h=hashlib.sha256(b).hexdigest().upper()
    print('FROZEN_SOURCE',p.name,'BYTES',len(b),'SHA256',h)
    assert len(b)==size and h==digest
    text=b.decode('utf-8-sig')
    texts.append(text)
    trees.append(ast.parse(text))
allow=[{'__future__','dataclasses','hashlib','re','typing'},{'__future__','importlib.util','sys','unittest','dataclasses'}]
for tree,whitelist in zip(trees,allow):
    for n in ast.walk(tree):
        if isinstance(n,ast.Import):
            assert all(a.name in whitelist for a in n.names)
        if isinstance(n,ast.ImportFrom):
            assert n.level==0 and n.module in whitelist
for n in ast.walk(trees[0]):
    if isinstance(n,ast.Call) and isinstance(n.func,ast.Name):
        assert n.func.id not in {'open','eval','exec','__import__','getattr','setattr','globals','locals','input','compile'}
    if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute):
        assert n.func.attr not in {'read','read_text','read_bytes','write','write_text','write_bytes','system','Popen','run','resolve','stat','exists','unlink'}
fn=next(n for n in trees[0].body if isinstance(n,ast.FunctionDef) and n.name=='adapt_module_debug_entry')
assert not fn.args.posonlyargs and not fn.args.args and not fn.args.vararg and not fn.args.kwarg
assert [x.arg for x in fn.args.kwonlyargs]==['materials','config'] and fn.args.kw_defaults==[None,None]
classes=[n for n in trees[0].body if isinstance(n,ast.ClassDef)]
assert len(classes)==7
for n in classes:
    d=n.decorator_list[0]
    assert isinstance(d,ast.Call) and isinstance(d.func,ast.Name) and d.func.id=='dataclass'
    assert {k.arg:k.value.value for k in d.keywords}=={'frozen':True,'slots':True}
    for member in n.body:
        if isinstance(member,ast.AnnAssign):
            assert not (isinstance(member.annotation,ast.Subscript) and isinstance(member.annotation.value,ast.Name) and member.annotation.value.id in {'dict','list','set'})
def assignment(tree,name):
    return next(n.value for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id==name for t in n.targets))
def encoded(v):
    assert isinstance(v,ast.Call) and isinstance(v.func,ast.Attribute) and v.func.attr=='encode'
    assert isinstance(v.func.value,ast.Constant) and isinstance(v.func.value.value,str)
    assert len(v.args)==1 and v.args[0].value=='utf-8' and not v.keywords
    return v.func.value.value.encode('utf-8')
def embedded_dict(tree,name):
    v=assignment(tree,name)
    assert isinstance(v,ast.Dict)
    return {k.value:encoded(b) for k,b in zip(v.keys,v.values)}
production=embedded_dict(trees[0],'_CODE')
oracle=embedded_dict(trees[1],'EXPECTED_CODE')
assert production==oracle and len(production)==14
assert b'own.has(key)' in production['apply-helper'] and b'own.has(key)' in production['init-helpers']
assert b'?: return false' not in production['apply-helper'] and b'if (raw == null)' not in production['init-helpers']
originals=assignment(trees[1],'ORIGINALS')
assert isinstance(originals,ast.Tuple) and len(originals.elts)==4
digests=ast.literal_eval(assignment(trees[1],'EXPECTED_DIGESTS'))
for pair,(name,digest) in zip(originals.elts,digests):
    assert isinstance(pair,ast.Tuple) and pair.elts[0].value==name
    assert hashlib.sha256(encoded(pair.elts[1])).hexdigest().upper()==digest
scratch=embedded_dict(trees[1],'EXPECTED_SCRATCH')
assert set(scratch)=={'repo-block','tasks-full','init-full'}
scratch_hashes={'repo-block':'6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17','tasks-full':'B951D53A72DA69E88FBBAB601EE83DE77AB5220E5458B55D4E3EB95ED683A20A','init-full':'C85D24FDDBBCC05F296FA56E16BEF7187EF316B45969DB6BEC5C31605B347C05'}
for k,v in scratch.items():
    assert hashlib.sha256(v).hexdigest().upper()==scratch_hashes[k]
    print('INDEPENDENT_EXPECTED_FULL',k,'BYTES',len(v),'SHA256',scratch_hashes[k])
expected_fn=next(n for n in trees[1].body if isinstance(n,ast.FunctionDef) and n.name=='expected')
assert not any(isinstance(n,ast.Attribute) and n.attr in {'adapt_module_debug_entry','_CODE','_DIGESTS','_PROJECTS','_KEYS'} for n in ast.walk(expected_fn))
loads=[n for n in ast.walk(trees[1]) if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute) and n.func.attr=='spec_from_file_location']
assert len(loads)==1 and loads[0].args[0].value=='aar_entry_materials'
assert loads[0].args[1].value=='D:\\\\EliteSync-v10\\\\apps\\\\android_synthetic_demo\\\\tools\\\\aar_entry_materials.py'
assert "sys.modules['aar_entry_materials'] = _module" in texts[1]
assert texts[1].index("sys.modules['aar_entry_materials'] = _module") < texts[1].index('_spec.loader.exec_module(_module)')
assert 'unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])' in texts[1]
assert 'outcome.testsRun > 0' in texts[1]
assert 'discover' not in texts[1] and 'sys.path' not in texts[1]
methods=[n.name for n in ast.walk(trees[1]) if isinstance(n,ast.FunctionDef) and n.name.startswith('test_')]
assert len(methods)==12
assert 'self.assertEqual(a, expected(' in texts[1] and 'self.assertEqual(b, expected(' in texts[1]
assert "self.assertEqual(actual[target], EXPECTED_SCRATCH[target])" in texts[1]
for name in ['test_top_and_nested_types','test_material_integrity_order_and_anchors','test_config_keys_fixed_values_and_paths','test_ids_and_bindings','test_projects_and_tasks','test_property_schema_scope_and_types','test_mode_matrix_is_source_only']:
    assert name in methods
print('STATIC_AST_HASH_IMPORT_KEYWORD_ONLY_FROZEN_TUPLE_FIXTURE_SCOPE_PASS')
print('STATIC_TEST_METHOD_COUNT',len(methods))
print('METHODS',','.join(methods))
print('COVERAGE_P1_P2_COMPLETE_RETURN_AND_THREE_COMPLETE_SCRATCH_PRESENT')
print('LIMIT_STATIC_TEXT_AND_AST_NOT_FORMAL_SAFETY_OR_RUNTIME_PROOF')


A_OUTPUT_UTF8_BYTES=7111
```

## B 原始同次回执与冻结身份

chunk 662519；exit 0；wall_time_seconds 0.1927225。两新 script 各一次 ReadAllBytes/hash；checker≤32KiB、launcher≤16KiB，普通非 reparse门通过。只对内存 launcher 调用 System.Management.Automation.Language.Parser.ParseInput；未执行任一 script，未 Python AST parse/compile/import/语法试跑。

```text
SCRIPT EVIDENCE/APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY/check_frozen_sources.py BYTES=18304 SHA256=6427B8EA143C8DD39BEA248A040E3C2FAEE48D745990FA4E7F9C117D2E4B15B4
SCRIPT EVIDENCE/APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY/Invoke-FrozenAarValidation.ps1 BYTES=8091 SHA256=DCE5752BED51E3C710338024DD852306921CEB47D26C3DFFB52355D62AC7F574
POWERSHELL_PARSE_ERRORS=0
B_READ_COUNT=2 B_BUDGET=1/1 POWERSHELL_PARSE=PASS PYTHON_SYNTAX=NOT_CHECKED SCRIPTS_EXECUTED=0
```

B 后两 script 不再修改。PowerShell 解析零错误只证明本次文本解析；Python 语法 NOT_CHECKED，实际静态门/算法测试/监控行为 NOT_CHECKED。

## 关闭预算与停点

A 1/1、B 1/1 均关闭。Python/AST子进程、生产算法/测试 fixture/scratch、launcher/monitor、SDK/Gradle/Flutter/JVM/ADB/构建/安装/启动预算全部 0，实际执行全部 0。未修改 authority 或旧证据，未访问旧 D:\EliteSync、SDK/cache/config/env/home/真实 metadata/properties、真实数据/备份/密钥/生产 DB/API/SSH；无目录索引搜索、下载复制、构建安装启动/UAC。

候选停 Work 独立 LEVEL 2 ACCEPT/REJECT。SOURCE-ONLY 接受也不自动授权运行；只有新明确任务才能执行固定 checker/launcher，Test 还须 Work 确认 Static 原回执成功。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false、真实账号/Conversation/恢复/UAC 与全部保护门保持。

