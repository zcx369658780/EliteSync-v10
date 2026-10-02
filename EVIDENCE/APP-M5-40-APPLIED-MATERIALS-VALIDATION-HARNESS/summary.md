# APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS

NOT_DELIVERED AS RELIABLE VALIDATION HARNESS — AUTHOR TEXT REVIEW BLOCKER。
停 Work 独立 LEVEL 2；不自接受、不后继、不修复或补跑。

日期：2026-09-30。
Codex：01a0f1ec-ff46-7311-a52f-780a64e3d4fb；新 Work：01a0f272-76dc-7712-b368-1b6f9e86d179。
仓库 D:\EliteSync-v10；main；HEAD cf8bfaa4a03b8c9a682105617b185141904413be。

## 首个终止问题

A 唯一来源身份链和 CreateNew 保存阶段 exit_code=0。随后主代理仅查看 A 同次已回显的 M5-35 checker 文本，发现旧 oracle 的完整字面使用 Constant(str).encode('utf-8') 形式。旧 checker 的 encoded() 明确识别这一形状，且 ORIGINALS、EXPECTED_CODE、EXPECTED_SCRATCH 都经此机制核完整 bytes。

本次新 checker 的 safe_literal() 只识别 Constant/Tuple/List/Dict，没有识别上述固定字符串字面 encode Call。新 oracle_gate() 先要求 safe_literal(node.value)，因此会误拒绝已接受 oracle。这是主代理构造遗漏。此处是对源码文字的确定性缺陷判断，不是运行所得结果；没有执行 Python/AST/checker 或 oracle 来确认行为。

终止标签：AUTHOR_TEXT_REVIEW_ORACLE_ENCODE_NOT_PROVEN。
无法交付可靠 harness，按 task 的“无法在该方式可靠构造则记录 NOT_DELIVERED 停门”及首失败停点处理。两份新候选保留；不覆盖/修改，不继续 B，不补读任何来源或候选、不启动检查器/启动器/测试。B 未执行，不声称它失败、成功或有回执。

## 新候选与身份限制

A 使用 CreateNew 新增：
- D:\EliteSync-v10\EVIDENCE\APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS\check_applied_sources.py
- D:\EliteSync-v10\EVIDENCE\APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS\Invoke-AppliedAarValidation.ps1

本 summary 也用 CreateNew 保存。三目标在 A 前均不存在；没有覆盖已存在路径。
A 保存前用同次内存 UTF-8 byte count 核 checker <=64 KiB、launcher <=20 KiB；这不是最终文件 B 验证。

最终两个 script SHA256：NOT_CHECKED。最终磁盘大小/严格 UTF-8/普通非 reparse/文本槽/launcher ParseInput：NOT_CHECKED，因为首个作者文字问题后 B 未启动。不得用冻结的六来源 hash 或草稿 hash 冒充两份新 script 的最终身份。Work 如需检查保留候选，应另按自身审查权限核身份；Codex 本 task 不补读或续预算。

## 预算与所有未运行项

A 1/1 成功读取与保存，关闭；B 0/1 未执行，随本次终止关闭，不能转用于修复或后继。
A 读六来源各一次 ReadAllBytes，合计 263852 bytes，单件 <=192 KiB，总 <=384 KiB；普通非 reparse/准确 size/hash/严格 UTF-8 均通过。
输出先在内存限制六身份表 <=4 KiB、旧 checker 正文 <=20 KiB、总 <=24 KiB，再回显；没有全文回显 plan、新 test、新 production、adapter 或旧 launcher。

Python、Python AST、import/exec_module、compile、算法、fixture/scratch、测试、checker、launcher、monitor：全部 NOT_CHECKED，启动 0。
PowerShell Parser.ParseInput 未执行。A 中只有标准库文字操作/摘要/文件保存，没有求值来源声明或被测代码。
未检查算法结果、13 测试可运行性、monitor 可运行性、双流容量/超时/cleanup、单进程隔离或绝对硬截止。B 没有任何同次原回执。

## 同次 A 原始完整回执

下方保留原 A 回显：六身份/总量及 task 明确允许回显的旧 checker 文本。旧 checker 是来源回执，不是本 task 的新主要结果，也不代替新候选的结构/语法/运行证据。未执行它。

chunk_id=7c3a0c；exit_code=0。

```text
A path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_applied_materials.py bytes=6510 SHA256=123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224 ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_applied_materials.py bytes=72513 SHA256=29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py bytes=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\EVIDENCE\APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT\plan.md bytes=137079 SHA256=7DB003A4620EEE403A310192DAE2C7BEEAAE5F88AE8D7A5B8CE6D962F8FC34BD ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\EVIDENCE\APP-M5-35-HARNESS-AST-COMPARISON-REPAIR\check_frozen_sources.py bytes=19323 SHA256=D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\EVIDENCE\APP-M5-35-HARNESS-AST-COMPARISON-REPAIR\Invoke-FrozenAarValidation.ps1 bytes=8089 SHA256=7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E ordinary_non_reparse=PASS strict_UTF8=PASS
A total_bytes=263852 limit=393216 identity=PASS
OLD_CHECKER_BEGIN
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
FIXED_PRODUCTION_PATH = r'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py'
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


def name_store_target(node, name):
    # Assignment targets have Store; expression same() remains Load-strict.
    return (isinstance(node, ast.Name) and isinstance(node.ctx, ast.Store)
            and node.id == name)


def module_store_target(node):
    return (isinstance(node, ast.Subscript) and isinstance(node.ctx, ast.Store)
            and same(node.value, 'sys.modules')
            and isinstance(node.slice, ast.Constant)
            and type(node.slice.value) is str
            and node.slice.value == 'aar_entry_materials')


def fixed_spec_call(node):
    # Compare decoded Constant values directly; never parse a path literal
    # through a second string layer that could interpret backslash escapes.
    return (isinstance(node, ast.Call)
            and dotted(node.func) == 'importlib.util.spec_from_file_location'
            and len(node.args) == 2 and not node.keywords
            and all(isinstance(n, ast.Constant) and type(n.value) is str
                    for n in node.args)
            and node.args[0].value == 'aar_entry_materials'
            and node.args[1].value == FIXED_PRODUCTION_PATH)


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
            if method == 'spec_from_file_location':
                ok = ok and is_test and fixed_spec_call(n)
            elif method in allowed_special:
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
    gate('FIXED_SPEC_ASSIGNMENT', fixed_spec_call(spec_value))
    gate('FIXED_MODULE_ASSIGNMENT', same(module_value, 'importlib.util.module_from_spec(_spec)'))
    specs = calls(tree, 'importlib.util.spec_from_file_location')
    modules = calls(tree, 'importlib.util.module_from_spec')
    execution = calls(tree, '_spec.loader.exec_module')
    registrations = [n for n in tree.body if isinstance(n, ast.Assign)
                     and len(n.targets) == 1
                     and module_store_target(n.targets[0])
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
                    and len(n.targets) == 1 and name_store_target(n.targets[0], 'suite')]
    outcome_assign = [n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                      and n.value is runs[0] and len(n.targets) == 1
                      and name_store_target(n.targets[0], 'outcome')]
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

OLD_CHECKER_END
```

## 已写候选的结构意图与未证明项

新 checker 拟只读取固定 adapter/new production/new test，核文件身份，只 ast.parse 两新源码，不 import 或运行三者。拟保留 exact keyword-only、frozen/slots 类型、六步/原 digest、plugin-deps、type preflight、原附件/Invocation、四模型、两 loader、Store/Load 区分、固定当前模块 runner 和 testsRun>0/wasSuccessful 门。receiver-aware Call 白名单和完整方法正文摘要属于结构检查意图，未执行，且上述 oracle 编码识别缺陷阻止本候选成为可靠验证器。

Oracle 的同次内存文字转录规则：
1. 对新 test 使用多行/单行模式，精确名称 ORIGINALS/EXPECTED_CODE/EXPECTED_SCRATCH 的顶层声明起始；ORIGINALS 的文字范围至首个行首闭合 ')'，两字典至首个行首闭合 '}'，要求随后换行。
2. 每组要求恰好一个匹配，并在准确 SHA256 的 M5-38 plan 同次内存正文中逐字包含该完整声明；没有 Python/AST/声明求值。
3. 对整个选取声明 UTF-8 文本计算 bytes 与 SHA256，嵌入新 checker 的 ORACLE_DECLARATIONS。未来拟以 ast.get_source_segment 对整个 Assign 逐字摘要比较，覆盖声明全部内容，不仅常量名称/长度。该范围是完整选取声明的源码文字；实际字面 bytes 的 encode 形状识别本次漏写，故此完整策略仍 NOT_PROVEN。
4. 同次内存还将四 production 函数、两个 config/expected 函数、reject 和13 test 方法完整 def 文字摘要写入 FROZEN_FUNCTION_TEXT。方法首行去掉四个缩进字符；末尾仅去 CR/LF，与未来 get_source_segment 比较设计对应。未运行 AST 验证这一匹配策略。
5. 未来 checker 不再读取 plan、旧 receipt 或 SDK；不使用生产私有 _CODE 或调用被测函数回算 expected。上述“未来”行为均未授权执行。

13 个准确作者方法名（仅源码声明，不是发现/执行/通过数量）：

- test_complete_p1_p2
- test_complete_bytes_and_untouched_plugin
- test_shared_anchor_helpers_and_outside_bytes
- test_full_model_and_logical_separation
- test_frozen_detached_deterministic
- test_reapplied_output_and_material_changes
- test_signature_rejects_external_packages_and_roots
- test_top_exact_types_and_subclasses
- test_nested_types_before_schema
- test_config_keys_mode_identity_and_paths
- test_projects_and_tasks
- test_ids_and_project_property_conflicts
- test_property_schema_order_and_path_token

## 新旧 launcher 差异

从准确 M5-35 launcher 同次内存文字组织：
- 固定 checker 所在 task 目录换为 M5-40，文件名换为 check_applied_sources.py。
- Test 文件名换为 test_aar_applied_materials.py，准确 test size/hash 从旧 74376/F067...换为 72513/29B2...。
- 原 adapter size/hash 核验保留；在唯一顶层 main try 内、原检查和启动前插入 new production 的固定路径、普通非 reparse、6510 bytes、123A...SHA256、严格 UTF-8 gate。
- 其它原生 monitor 文字保持：Static/Test、外部 mandatory CheckerSha256、固定 Python/cwd/-I/-B、至多一次 Process.Start、raw BaseStream 双流/限制/超时/cleanup/回执结构。本次未解析或运行，保持文字不等于这些门已通过。
- 不运行旧 test、原 checker、任何 candidate 或第二进程；不改全局环境/策略。

## 工作区与保护门

入口实际 192 条 porcelain normal 状态；相对于 Work 接管 191 条，新增加的本 task 折叠目录由 Work 建立。入口成员回执已在本会话内存保存。Codex 新 script 位于该折叠目录，只有 task 精确允许的三路径写入，没有 Git mutation 或无关写入。
首终止后没有再次 Git 状态比对；最终成员逐条保留/全文件字节完整性均不追加宣称为已验证。没有 stage/commit/pull/push/reset/clean/stash。

M5-39 ACCEPT/CLOSED SOURCE-ONLY、M5-35 ACCEPT/CLOSED SOURCE-ONLY 和全部旧 budget 关闭保持；本 task 不改变既有接受结论。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false、真实账号/Conversation/恢复/生产/UAC 门保持。
未访问旧 D:\EliteSync、真实数据/备份/密钥/生产 DB/API/SSH、SDK/cache/config/env/home/真实 metadata/properties；无目录搜索索引/下载、Gradle/Flutter/JVM/ADB/构建安装启动或 UAC。

最后停点：仅此 NOT_DELIVERED 摘要交 Work 独立 LEVEL 2。不得自行修复、新建后继、重新执行 A/B，或把保留候选作为可运行 harness。
