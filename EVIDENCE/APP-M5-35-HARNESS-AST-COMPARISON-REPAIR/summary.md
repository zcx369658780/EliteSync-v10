# APP-M5-35｜AST比较修复候选

2026-09-30；SOURCE-ONLY REPAIR CANDIDATE / WORK LEVEL 2 REVIEW PENDING。A 1/1、B 1/1 均成功并关闭；两新 script 按 B 最终 hash 冻结。Python 语法/AST/生产/测试/launcher/monitor 均未执行；不自接受或派后继。

## 入口与唯一范围

唯一 D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。执行会话 01a0f1ec-ff46-7311-a52f-780a64e3d4fb；顶部 TASK_CURRENT ISSUED、assignee 与明确派发一致，沿用 elitesync-local-workflow。仅本目录新增 check_frozen_sources.py、Invoke-FrozenAarValidation.ps1、summary.md。旧两 script、原算法两 source、旧 summary/证据及 authority 未修改。

M5-34 保持 REJECT AS EXECUTABLE VALIDATION HARNESS/CLOSED，A/B 各 1/1 关闭；M5-33 及全部旧预算保持原关闭状态。本轮无运行授权，不追认旧候选为可执行或已验证。

## 最小差异与两 Required

1. 表达式 shape/same 完全保持，不修改目标 AST，不归一上下文。新增 name_store_target：只接受准确 Name.id 且 ctx 为 ast.Store；用于 suite/outcome 赋值目标。新增 module_store_target：只接受 Subscript 且 ctx 为 ast.Store，value 必须与 Load 表达式 sys.modules 严格相同，slice 必须是准确字符串 Constant aar_entry_materials；用于登记目标。旧唯一登记/单目标赋值/准确 _module RHS/登记顺序/loader/exit 门保持。
2. 新增 raw 字符串 FIXED_PRODUCTION_PATH，准确为任务固定生产路径；fixed_spec_call 直接核 Call 函数、恰好两位置参数、无 kwargs、两个 exact str Constant.value。模块固定 aar_entry_materials，路径直接与上述 raw 字符串值比较，不对 path 进行第二次 expression/非raw解析。special host 与 FIXED_SPEC_ASSIGNMENT 共用该 helper，未降级为函数名或后缀检查。
3. launcher 仅将唯一固定 checkerPath 从 M5-34 目录移到 M5-35；字节数 8091→8089 的差额来自目录名长度。Mode/CheckerSha256、固定 Python/cwd/原两source与hash门、raw BaseStream双流限额、截止/cleanup、最多一次 Start、返回/退出行为全部继承。

旧 receiver-aware runner、oracle/fixture身份、方法/整返回/scratch结构门保持，没有新增宽泛拒绝规则或新特性。代码从 A 已读入内存的旧 script 文本做准确替换后保存；没有再读取来源正文，原 test 正文不回显。两 Required 的修复尚未通过 Python/AST 执行，不能把作者文本说明当运行证明。

## A 同次完整原回执

chunk b736fb；exit 0；wall_time_seconds 0.1795362。三 source 各 ReadAllBytes 一次、普通非 reparse、准确大小/hash、单份与总量≤128KiB门通过；合计 100771 bytes。回显三身份行/总量/旧两 script 文本；原 test 正文不回显。主动 UTF8 payload 27005 bytes，末计数行后仍小于 32768；未启用 launcher 正文省略分支、未截断、失败或重跑。下列旧 script 内容只是原始来源回显，不是运行结果，也不是本目录修复后源码：

```text
SOURCE EVIDENCE/APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY/check_frozen_sources.py BYTES=18304 SHA256=6427B8EA143C8DD39BEA248A040E3C2FAEE48D745990FA4E7F9C117D2E4B15B4
SOURCE EVIDENCE/APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY/Invoke-FrozenAarValidation.ps1 BYTES=8091 SHA256=DCE5752BED51E3C710338024DD852306921CEB47D26C3DFFB52355D62AC7F574
SOURCE apps/android_synthetic_demo/tools/test_aar_entry_materials.py BYTES=74376 SHA256=F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2
TOTAL_BYTES=100771 READ_COUNT=3 A_BUDGET=1/1
CHECKER_BODY_BEGIN
"""Fixed-source structural checker. Requires a separate Work execution task.

Only parses the two frozen files; never imports or executes either file.
AST structure is evidence of these named gates, not a formal safety proof.
"""
import ast
import hashlib
from pathlib import Path
import stat
import sys


ROOT = Path('D:/EliteSync-v10/apps/android_synthetic_demo/tools')
SOURCES = (
    ('aar_entry_materials.py', 20338,
     'B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7'),
    ('test_aar_entry_materials.py', 74376,
     'F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2'),
)
ORIGINAL_HASHES = (
    ('tasks-full', 'B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE'),
    ('repo-block', '4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534'),
    ('init-full', '5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC'),
    ('plugin-deps', '5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F'),
)
CODE_HASHES = {
    'repo-before': '4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534',
    'repo-after': '6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17',
    'tasks-before': 'B9AC68E2DC9DCCE8C2F2EB1F642FF674ED0AC23501D33499C1145A04E793D236',
    'tasks-after': '1CB68D8BB90ABD8A67CD6ACCB8CDB728DEDB5D8D7E1B7D8F124B592C6DF33BAE',
    'init-all-before': '027A4434FFF6F23894D41BDFF3F3483268F9DFF7DF08F7D071E7D1EECDC60D56',
    'init-all-after': '2AABBDC10A6B4E1A7ED84A49BAAD75AB2CFE50346178A43DA63E6F3265E8ACC4',
    'init-afterProject-before': '4B80E184109EF9F5CDAA0858FBB90F65A199B99A912C11C769613200AE2778E7',
    'init-afterProject-after': 'BA75137EFFEE607DA26DD746BD10B337FD6A844009768599DEAA370811BB20EF',
    'init-projectsEvaluated-before': '6C44D5256325F80C7A45180733525AB18DA7C3965AC60D7B8596781AD9806851',
    'init-projectsEvaluated-after': '0B01A220A0980091ED7D4B6E94969306EFE2C53FA215E2DBD149FCEC869CC05E',
    'apply-helper': '44503DD02B3F0B12E4713670BFB799D08A15A59195D0EF5C9FC45172D98719DE',
    'preflight-before': '7A69ABFDFACB460AFFC96ED2443A9F77E5D60C4FC280AA6FDEB44298032B3965',
    'preflight-after': '3C085E0AF7BA0EB36970E3D7122522EB621103311A919C922B4AF693EA99E111',
    'init-helpers': '0256AE1A42DDD3AA7D592D053A97103D6B5BCAF67A0F7854285F7FDCDF183112',
}
SCRATCH_HASHES = {
    'repo-block': '6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17',
    'tasks-full': 'B951D53A72DA69E88FBBAB601EE83DE77AB5220E5458B55D4E3EB95ED683A20A',
    'init-full': 'C85D24FDDBBCC05F296FA56E16BEF7187EF316B45969DB6BEC5C31605B347C05',
}
METHODS = {
    'test_complete_p1_p2', 'test_complete_scratch',
    'test_installation_logical_and_dynamic_id', 'test_frozen_detached_deterministic',
    'test_top_and_nested_types', 'test_material_integrity_order_and_anchors',
    'test_config_keys_fixed_values_and_paths', 'test_ids_and_bindings',
    'test_projects_and_tasks', 'test_property_schema_scope_and_types',
    'test_mode_matrix_is_source_only', 'test_keyword_only',
}


class GateError(Exception):
    pass


def gate(identifier, condition):
    print('CHECK', identifier, 'PASS' if condition else 'FAIL', flush=True)
    if not condition:
        raise GateError(identifier)


def shape(node):
    return ast.dump(node, include_attributes=False)


def expression(text):
    # Only fixed checker-owned expressions, never target source evaluation.
    return ast.parse(text, mode='eval').body


def same(node, text):
    return shape(node) == shape(expression(text))


def dotted(node):
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        prefix = dotted(node.value)
        return prefix + '.' + node.attr if prefix else ''
    return ''


def calls(tree, name):
    return [n for n in ast.walk(tree)
            if isinstance(n, ast.Call) and dotted(n.func) == name]


def assignment(tree, name):
    values = [n.value for n in tree.body if isinstance(n, ast.Assign)
              and any(isinstance(t, ast.Name) and t.id == name for t in n.targets)]
    gate('ASSIGNMENT_' + name, len(values) == 1)
    return values[0]


def encoded(node, identifier):
    ok = (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
          and node.func.attr == 'encode' and isinstance(node.func.value, ast.Constant)
          and type(node.func.value.value) is str and len(node.args) == 1
          and isinstance(node.args[0], ast.Constant) and node.args[0].value == 'utf-8'
          and not node.keywords)
    gate(identifier, ok)
    return node.func.value.value.encode('utf-8')


def embedded(tree, name):
    value = assignment(tree, name)
    gate('DICT_' + name, isinstance(value, ast.Dict))
    gate('DICT_KEYS_' + name, all(isinstance(k, ast.Constant)
         and type(k.value) is str for k in value.keys))
    keys = [k.value for k in value.keys]
    gate('DICT_UNIQUE_' + name, len(keys) == len(set(keys)))
    return {key: encoded(v, 'LITERAL_' + name + '_' + key)
            for key, v in zip(keys, value.values)}


def check_imports(tree, is_test):
    allowed = ({'__future__', 'importlib.util', 'sys', 'unittest', 'dataclasses'}
               if is_test else {'__future__', 'dataclasses', 'hashlib', 're', 'typing'})
    nodes = [n for n in ast.walk(tree) if isinstance(n, (ast.Import, ast.ImportFrom))]
    ok = True
    for n in nodes:
        if isinstance(n, ast.Import):
            ok = ok and all(a.name in allowed and a.asname is None for a in n.names)
        else:
            ok = ok and n.level == 0 and n.module in allowed
            ok = ok and all(a.name != '*' and a.asname is None for a in n.names)
    gate('IMPORTS_TEST' if is_test else 'IMPORTS_PRODUCTION', ok)


def check_host_nodes(tree, is_test):
    # These are concrete I/O, dynamic execution and dynamic-namespace APIs.
    # Data Constants and comments are never searched for command words.
    denied_names = {'open', 'input', 'eval', 'exec', 'compile', '__import__',
                    'getattr', 'setattr', 'delattr', 'globals', 'locals', 'vars'}
    io_methods = {'read', 'read_text', 'read_bytes', 'write', 'write_text',
                  'write_bytes', 'system', 'Popen', 'resolve', 'stat', 'lstat',
                  'exists', 'unlink', 'mkdir', 'rmdir', 'rename', 'replace',
                  'chmod', 'chown', 'touch', 'glob', 'rglob', 'iterdir'}
    # str.replace is a pure memory operation, so only block replace on
    # file-capable imported receivers (all file/OS imports are disallowed).
    io_methods.remove('replace')
    allowed_special = {
        'spec_from_file_location': "importlib.util.spec_from_file_location('aar_entry_materials', 'D:\\EliteSync-v10\\apps\\android_synthetic_demo\\tools\\aar_entry_materials.py')",
        'module_from_spec': 'importlib.util.module_from_spec(_spec)',
        'exec_module': '_spec.loader.exec_module(_module)',
        'loadTestsFromModule': 'unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])',
        'run': 'unittest.TextTestRunner(verbosity=2).run(suite)',
    }
    ok = True
    for n in ast.walk(tree):
        if isinstance(n, ast.Attribute) and dotted(n) == 'sys.path':
            ok = False
        if not isinstance(n, ast.Call):
            continue
        if isinstance(n.func, ast.Name):
            ok = ok and n.func.id not in denied_names
        if isinstance(n.func, ast.Attribute):
            method = n.func.attr
            ok = ok and method not in io_methods and method != 'discover'
            if method in allowed_special:
                ok = ok and is_test and same(n, allowed_special[method])
    gate('HOST_NODES_TEST' if is_test else 'HOST_NODES_PRODUCTION', ok)


def check_interface(tree):
    candidates = [n for n in tree.body if isinstance(n, ast.FunctionDef)
                  and n.name == 'adapt_module_debug_entry']
    gate('INTERFACE_UNIQUE', len(candidates) == 1)
    args = candidates[0].args
    gate('INTERFACE_KEYWORD_ONLY', not args.posonlyargs and not args.args
         and args.vararg is None and args.kwarg is None
         and [n.arg for n in args.kwonlyargs] == ['materials', 'config']
         and args.kw_defaults == [None, None])
    classes = [n for n in tree.body if isinstance(n, ast.ClassDef)]
    gate('OUTPUT_CLASSES_SEVEN', len(classes) == 7)
    for cls in classes:
        decorator = cls.decorator_list[0] if len(cls.decorator_list) == 1 else None
        frozen = (isinstance(decorator, ast.Call) and dotted(decorator.func) == 'dataclass'
                  and not decorator.args and len(decorator.keywords) == 2
                  and {k.arg: shape(k.value) for k in decorator.keywords}
                  == {'frozen': shape(expression('True')), 'slots': shape(expression('True'))})
        gate('FROZEN_' + cls.name, frozen)
        annotations = [n.annotation for n in cls.body if isinstance(n, ast.AnnAssign)]
        gate('IMMUTABLE_ANNOTATIONS_' + cls.name,
             not any(isinstance(n, ast.Name) and n.id in
                     {'dict', 'list', 'set', 'Dict', 'List', 'Set', 'MutableMapping',
                      'MutableSequence', 'MutableSet'}
                     for a in annotations for n in ast.walk(a)))


def check_oracle(production, test):
    code = embedded(production, '_CODE')
    oracle = embedded(test, 'EXPECTED_CODE')
    gate('CODE_ORACLE_KEYS', set(code) == set(oracle) == set(CODE_HASHES))
    for key, digest in CODE_HASHES.items():
        gate('CODE_IDENTITY_' + key, code[key] == oracle[key]
             and hashlib.sha256(oracle[key]).hexdigest().upper() == digest)
    for key in ('apply-helper', 'init-helpers'):
        gate('MODE_PRESENCE_' + key, b'own.has(key)' in oracle[key])
    gate('NULL_NOT_LEGACY', b'?: return false' not in oracle['apply-helper']
         and b'if (raw == null)' not in oracle['init-helpers'])
    originals = assignment(test, 'ORIGINALS')
    gate('ORIGINALS_TUPLE', isinstance(originals, ast.Tuple)
         and len(originals.elts) == 4)
    declared = assignment(test, 'EXPECTED_DIGESTS')
    # literal_eval only reads a literal AST; no target function execution.
    try:
        digest_values = ast.literal_eval(declared)
    except (ValueError, TypeError):
        raise GateError('EXPECTED_DIGESTS_LITERAL') from None
    gate('EXPECTED_DIGESTS_FIXED', tuple(digest_values) == ORIGINAL_HASHES)
    for pair, (key, digest) in zip(originals.elts, ORIGINAL_HASHES):
        gate('ORIGINAL_PAIR_' + key, isinstance(pair, ast.Tuple)
             and len(pair.elts) == 2 and isinstance(pair.elts[0], ast.Constant)
             and pair.elts[0].value == key)
        value = encoded(pair.elts[1], 'ORIGINAL_LITERAL_' + key)
        gate('ORIGINAL_HASH_' + key, hashlib.sha256(value).hexdigest().upper() == digest)
    scratch = embedded(test, 'EXPECTED_SCRATCH')
    gate('SCRATCH_KEYS', set(scratch) == set(SCRATCH_HASHES))
    for key, digest in SCRATCH_HASHES.items():
        gate('SCRATCH_HASH_' + key, hashlib.sha256(scratch[key]).hexdigest().upper() == digest)
    expected_functions = [n for n in test.body if isinstance(n, ast.FunctionDef)
                          and n.name == 'expected']
    gate('EXPECTED_FUNCTION_UNIQUE', len(expected_functions) == 1)
    # Public frozen constructors may be used to construct the expected record.
    # Neither private production constants nor the adapter may supply oracle
    # values. Literal expected source blocks are independently hash-bound.
    fn = expected_functions[0]
    gate('EXPECTED_NO_PRODUCTION_DEPENDENCY', not any(
        (isinstance(n, ast.Name) and n.id in {'_CODE', '_DIGESTS', '_PROJECTS', '_KEYS'})
        or (isinstance(n, ast.Attribute) and n.attr in
            {'adapt_module_debug_entry', '_CODE', '_DIGESTS', '_PROJECTS', '_KEYS'})
        for n in ast.walk(fn)))
    public_types = {'EntryMaterials', 'PatchOperation', 'Attachment',
                    'InvocationContract', 'InstallationGroup', 'LiteralString',
                    'RootProjectDirFilePath'}
    gate('EXPECTED_ONLY_PUBLIC_CONSTRUCTORS', all(
        n.attr in public_types for n in ast.walk(fn)
        if isinstance(n, ast.Attribute) and dotted(n.value) == '_module'))


def check_loader(tree):
    spec_value = assignment(tree, '_spec')
    module_value = assignment(tree, '_module')
    gate('FIXED_SPEC_ASSIGNMENT', same(spec_value,
         "importlib.util.spec_from_file_location('aar_entry_materials', 'D:\\EliteSync-v10\\apps\\android_synthetic_demo\\tools\\aar_entry_materials.py')"))
    gate('FIXED_MODULE_ASSIGNMENT', same(module_value, 'importlib.util.module_from_spec(_spec)'))
    specs = calls(tree, 'importlib.util.spec_from_file_location')
    modules = calls(tree, 'importlib.util.module_from_spec')
    execution = calls(tree, '_spec.loader.exec_module')
    registrations = [n for n in tree.body if isinstance(n, ast.Assign)
                     and len(n.targets) == 1
                     and same(n.targets[0], "sys.modules['aar_entry_materials']")
                     and same(n.value, '_module')]
    gate('FIXED_LOADER_COUNTS', len(specs) == len(modules) == len(execution)
         == len(registrations) == 1)
    gate('REGISTER_BEFORE_EXEC', specs[0].lineno < modules[0].lineno
         < registrations[0].lineno < execution[0].lineno)
    gate('EXEC_TOP_LEVEL', any(isinstance(n, ast.Expr) and n.value is execution[0]
         for n in tree.body))
    loader_calls = calls(tree, 'unittest.defaultTestLoader.loadTestsFromModule')
    gate('UNIQUE_EXPLICIT_LOADER', len(loader_calls) == 1 and same(loader_calls[0],
         'unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])'))
    runs = [n for n in ast.walk(tree) if isinstance(n, ast.Call)
            and isinstance(n.func, ast.Attribute) and n.func.attr == 'run']
    gate('EXACT_RUNNER_RECEIVER', len(runs) == 1 and same(runs[0],
         'unittest.TextTestRunner(verbosity=2).run(suite)'))
    gate('SUITE_BEFORE_RUN', loader_calls[0].lineno < runs[0].lineno)
    suite_assign = [n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                    and n.value is loader_calls[0]
                    and len(n.targets) == 1 and same(n.targets[0], 'suite')]
    outcome_assign = [n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                      and n.value is runs[0] and len(n.targets) == 1
                      and same(n.targets[0], 'outcome')]
    gate('SUITE_OUTCOME_BINDINGS', len(suite_assign) == len(outcome_assign) == 1)
    nonzero = [n for n in ast.walk(tree) if isinstance(n, ast.Compare)
               and same(n, 'outcome.testsRun > 0')]
    gate('NONZERO_TESTS_RUN_PRESENT', bool(nonzero))
    # Gate verifies exact exit expression carries both nonzero and success,
    # rather than accepting an unrelated comparison as sufficient.
    exits = calls(tree, 'sys.exit')
    gate('EXIT_USES_NONZERO_AND_SUCCESS', len(exits) == 1 and len(exits[0].args) == 1
         and isinstance(exits[0].args[0], ast.IfExp)
         and same(exits[0].args[0].body, '0') and same(exits[0].args[0].orelse, '1')
         and any(same(n, 'outcome.testsRun > 0') for n in ast.walk(exits[0].args[0].test))
         and any(same(n, 'outcome.wasSuccessful()') for n in ast.walk(exits[0].args[0].test)))


def check_coverage(tree):
    methods = [n for n in ast.walk(tree) if isinstance(n, ast.FunctionDef)
               and n.name.startswith('test_')]
    gate('METHOD_COUNT_AND_NAMES', len(methods) == 12
         and {n.name for n in methods} == METHODS)
    by_name = {n.name: n for n in methods}
    positive = by_name['test_complete_p1_p2']
    comparisons = calls(positive, 'self.assertEqual')
    gate('P1_P2_COMPLETE_RETURN_COMPARISONS', all(any(
        len(c.args) == 2 and same(c.args[0], var)
        and isinstance(c.args[1], ast.Call) and dotted(c.args[1].func) == 'expected'
        for c in comparisons) for var in ('a', 'b')))
    scratch_fn = by_name['test_complete_scratch']
    gate('COMPLETE_SCRATCH_COMPARISON', any(same(n,
         'self.assertEqual(actual[target], EXPECTED_SCRATCH[target])')
         for n in ast.walk(scratch_fn) if isinstance(n, ast.Call)))
    for name in METHODS - {'test_complete_p1_p2', 'test_complete_scratch'}:
        method = by_name[name]
        # Presence of a substantive assertion/helper call only; no behavioral
        # claim that each negative case is effective is made by this gate.
        gate('METHOD_BODY_' + name, any(isinstance(n, ast.Call)
             for n in ast.walk(method)))
    print('STATIC_TEST_METHOD_COUNT', len(methods), flush=True)
    print('METHODS', ','.join(sorted(METHODS)), flush=True)


def main():
    gate('NO_PATH_ARGUMENTS', len(sys.argv) == 1)
    trees = []
    for name, size, digest in SOURCES:
        path = ROOT / name
        metadata = path.lstat()
        gate('FILE_GATE_' + name, stat.S_ISREG(metadata.st_mode)
             and not stat.S_ISLNK(metadata.st_mode)
             and not (getattr(metadata, 'st_file_attributes', 0) & 0x400)
             and metadata.st_size == size)
        data = path.read_bytes()  # Exactly one read for this fixed source.
        actual = hashlib.sha256(data).hexdigest().upper()
        gate('HASH_' + name, len(data) == size and actual == digest)
        print('FROZEN_SOURCE', name, 'BYTES', len(data), 'SHA256', actual, flush=True)
        try:
            tree = ast.parse(data.decode('utf-8-sig'))
        except (SyntaxError, UnicodeError):
            raise GateError('AST_PARSE_' + name) from None
        gate('AST_PARSE_' + name, True)
        trees.append(tree)
    for tree, is_test in zip(trees, (False, True)):
        check_imports(tree, is_test)
        check_host_nodes(tree, is_test)
    check_interface(trees[0])
    check_oracle(trees[0], trees[1])
    check_loader(trees[1])
    check_coverage(trees[1])
    print('STATIC_STRUCTURE_GATES_PASS', flush=True)
    print('LIMIT_AST_STRUCTURE_NOT_FORMAL_PURITY_OR_RUNTIME_PROOF', flush=True)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except GateError as error:
        print('CHECK_FAILED:' + str(error), file=sys.stderr, flush=True)
        sys.exit(1)
    except Exception:
        # Do not echo target source, paths, or arbitrary exception messages.
        print('CHECK_FAILED:CHECKER_INTERNAL_OR_FILE_ERROR', file=sys.stderr, flush=True)
        sys.exit(1)
CHECKER_BODY_END
LAUNCHER_BODY_BEGIN
# Source-only candidate. Execution requires a new explicit Work task.
# Test mode additionally requires Work's accepted Static original receipt.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Static','Test')]
    [string]$Mode,
    [Parameter(Mandatory=$true)]
    [ValidatePattern('\A[0-9A-Fa-f]{64}\z')]
    [string]$CheckerSha256
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$pythonPath = 'C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe'
$repoPath = 'D:\EliteSync-v10'
$checkerPath = 'D:\EliteSync-v10\EVIDENCE\APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY\check_frozen_sources.py'
$productionPath = 'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py'
$testPath = 'D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_entry_materials.py'
$byteLimit = 32768
$hardSeconds = 60.0
# Reserve one second within the overall deadline for termination observation.
$executionSeconds = 59.0
$clock = [Diagnostics.Stopwatch]::new()
$process = $null
$started = $false
$startCount = 0
$startAttemptCount = 0
$timeout = $false
$limitExceeded = $false
$failure = $null
$childExit = $null
$stdoutText = $null
$stderrText = $null
$cleanupObservedExit = $false
$streams = @()

function Assert-FixedFile {
    param([string]$Path, [long]$ExpectedSize, [long]$MaximumSize, [string]$ExpectedHash)
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'FILE_GATE'
    }
    if ($item.Length -le 0 -or $item.Length -gt $MaximumSize -or
        ($ExpectedSize -gt 0 -and $item.Length -ne $ExpectedSize)) { throw 'SIZE_GATE' }
    if ($ExpectedHash -ne '') {
        $bytes = [IO.File]::ReadAllBytes($Path)
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
        if ($hash -cne $ExpectedHash.ToUpperInvariant()) { throw 'HASH_GATE' }
    }
}

function Start-StreamRead {
    param($State)
    # One outstanding asynchronous raw-byte read per stream; no characters
    # are counted or decoded until both pipes reach EOF.
    $State.Pending = $State.Stream.ReadAsync($State.Buffer, 0, $State.Buffer.Length)
}

try {
    Assert-FixedFile $pythonPath 0 1073741824 ''
    Assert-FixedFile $checkerPath 0 32768 $CheckerSha256
    Assert-FixedFile $productionPath 20338 20338 'B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7'
    Assert-FixedFile $testPath 74376 74376 'F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2'
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $pythonPath
    $info.WorkingDirectory = $repoPath
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.ArgumentList.Add('-I')
    $info.ArgumentList.Add('-B')
    if ($Mode -ceq 'Static') { $info.ArgumentList.Add($checkerPath) }
    elseif ($Mode -ceq 'Test') { $info.ArgumentList.Add($testPath) }
    else { throw 'MODE_GATE' }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    $clock.Start()
    $startAttemptCount = 1
    if (-not $process.Start()) { throw 'START_FAILED' }
    $started = $true
    $startCount = 1
    foreach ($baseStream in @($process.StandardOutput.BaseStream, $process.StandardError.BaseStream)) {
        $state = [pscustomobject]@{
            Stream = $baseStream
            Buffer = [byte[]]::new(4096)
            Data = [IO.MemoryStream]::new()
            Total = [long]0
            Eof = $false
            Pending = $null
        }
        $streams += $state
        Start-StreamRead $state
    }
    while ($true) {
        if ($clock.Elapsed.TotalSeconds -ge $executionSeconds) {
            $timeout = $true
            throw 'DEADLINE'
        }
        foreach ($state in $streams) {
            if (-not $state.Eof -and $state.Pending.IsCompleted) {
                $count = $state.Pending.GetAwaiter().GetResult()
                $state.Pending = $null
                if ($count -eq 0) { $state.Eof = $true; continue }
                $state.Total += $count
                $remaining = $byteLimit - $state.Data.Length
                if ($remaining -gt 0) {
                    $kept = [int][Math]::Min([long]$remaining, [long]$count)
                    $state.Data.Write($state.Buffer, 0, $kept)
                }
                if ($state.Total -gt $byteLimit) {
                    $limitExceeded = $true
                    throw 'OUTPUT_LIMIT'
                }
                Start-StreamRead $state
            }
        }
        if ($process.HasExited -and $streams[0].Eof -and $streams[1].Eof) {
            $childExit = $process.ExitCode
            $cleanupObservedExit = $true
            break
        }
        # Polling interval is capped by the remaining execution deadline.
        $remainingMs = [Math]::Max(0, ($executionSeconds - $clock.Elapsed.TotalSeconds) * 1000)
        if ($remainingMs -gt 0) { [Threading.Thread]::Sleep([int][Math]::Min(5, $remainingMs)) }
    }
    $decoder = [Text.UTF8Encoding]::new($false, $true)
    try {
        $stdoutText = $decoder.GetString($streams[0].Data.ToArray())
        $stderrText = $decoder.GetString($streams[1].Data.ToArray())
    } catch { throw 'UTF8_DECODE' }
    if ($childExit -ne 0) { $failure = 'CHILD_NONZERO' }
} catch {
    # Only fixed gate labels are emitted, never arbitrary exception contents.
    $label = $_.Exception.Message
    if ($label -cin @('FILE_GATE','SIZE_GATE','HASH_GATE','MODE_GATE','START_FAILED',
                      'DEADLINE','OUTPUT_LIMIT','UTF8_DECODE')) { $failure = $label }
    else { $failure = 'LAUNCHER_INTERNAL_OR_FILE_ERROR' }
} finally {
    if ($started -and $null -ne $process) {
        try {
            if (-not $process.HasExited) { $process.Kill() }
            while (-not $process.HasExited -and $clock.Elapsed.TotalSeconds -lt $hardSeconds) {
                $remainingMs = ($hardSeconds - $clock.Elapsed.TotalSeconds) * 1000
                if ($remainingMs -gt 0) { [Threading.Thread]::Sleep([int][Math]::Min(5, $remainingMs)) }
            }
            $cleanupObservedExit = $process.HasExited
            if ($cleanupObservedExit -and $null -eq $childExit) { $childExit = $process.ExitCode }
            if (-not $cleanupObservedExit) { $failure = 'CLEANUP_EXIT_NOT_OBSERVED' }
        } catch { $failure = 'CLEANUP_FAILURE' }
    }
    if ($clock.Elapsed.TotalSeconds -ge $hardSeconds) {
        $timeout = $true
        if ($null -eq $failure) { $failure = 'DEADLINE' }
    }
    $clock.Stop()
}

$stdoutBytes = if ($streams.Count -ge 1) { $streams[0].Total } else { [long]0 }
$stderrBytes = if ($streams.Count -ge 2) { $streams[1].Total } else { [long]0 }
# On failure raw captured bytes remain available without pretending valid UTF8.
$stdoutRaw = if ($streams.Count -ge 1) { [Convert]::ToBase64String($streams[0].Data.ToArray()) } else { '' }
$stderrRaw = if ($streams.Count -ge 2) { [Convert]::ToBase64String($streams[1].Data.ToArray()) } else { '' }
$launcherExit = if ($null -eq $failure -and $childExit -eq 0) { 0 } else { 1 }
$receipt = [pscustomobject]@{
    Mode = $Mode
    Failure = $failure
    Exit = $launcherExit
    ChildExit = $childExit
    ElapsedSeconds = $clock.Elapsed.TotalSeconds
    Timeout = $timeout
    OutputLimitExceeded = $limitExceeded
    StartCount = $startCount
    StartAttemptCount = $startAttemptCount
    CleanupObservedExit = $cleanupObservedExit
    StdoutRawBytes = $stdoutBytes
    StderrRawBytes = $stderrBytes
    Stdout = $stdoutText
    Stderr = $stderrText
    StdoutCapturedBase64 = $stdoutRaw
    StderrCapturedBase64 = $stderrRaw
}
# Closing streams cancels/disposes any outstanding read; no WaitForExit,
# Task.Wait, ReadToEnd or a second process is used for failure cleanup.
foreach ($state in $streams) {
    try { $state.Stream.Dispose() } catch { }
    $state.Data.Dispose()
}
if ($null -ne $process) { $process.Dispose() }
$receipt | ConvertTo-Json -Depth 4 -Compress
exit $launcherExit
LAUNCHER_BODY_END

A_OUTPUT_UTF8_BYTES=27005
```

## B 同次完整原回执与最终冻结身份

chunk 54da34；exit 0；wall_time_seconds 0.1970575。两新 script 各一次 ReadAllBytes/hash，普通非 reparse、checker≤32KiB/launcher≤16KiB门通过。仅对内存 launcher 调用 PowerShell Parser.ParseInput；没有执行 script、没有 Python AST parse/compile/import 或 syntax smoke。

```text
SCRIPT EVIDENCE/APP-M5-35-HARNESS-AST-COMPARISON-REPAIR/check_frozen_sources.py BYTES=19323 SHA256=D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A
SCRIPT EVIDENCE/APP-M5-35-HARNESS-AST-COMPARISON-REPAIR/Invoke-FrozenAarValidation.ps1 BYTES=8089 SHA256=7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E
POWERSHELL_PARSE_ERRORS=0
B_READ_COUNT=2 B_BUDGET=1/1 POWERSHELL_PARSE=PASS PYTHON_SYNTAX=NOT_CHECKED SCRIPTS_EXECUTED=0
```

B 成功后两 script 完全冻结，不再修改。PowerShell 解析零错误只证明文本语法解析；Python 语法、AST gate 接受性、实际 loader/runner、算法行为、双流/超时/异常cleanup与OS级截止保证均 NOT_CHECKED，仍待 Work 独立审查和新准确运行任务。

## 保留与停点

只读 Git status 对照保存的 183 条接管清单加 M5-33/M5-34 两目录：185 条既有成员缺项 0；当前 186 条，唯一新增为 M5-35 证据目录（派发入口已存在）。成员保留不代表逐字节核验全部既有文件。无 commit/pull/push/reset/clean/stash。

A 1/1、B 1/1 关闭。Python/AST/生产/测试fixture/scratch/launcher/monitor/SDK/Gradle/Flutter/JVM/ADB/构建安装启动预算和实际执行均 0；未访问旧 D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/metadata/properties，无目录索引搜索、下载复制或UAC。

交候选停 Work 独立 LEVEL 2 ACCEPT/REJECT；SOURCE-ONLY 接受不授权执行或测试，不恢复任何旧预算。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false、真实账号/Conversation/恢复/UAC与全部保护门保持。

