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
