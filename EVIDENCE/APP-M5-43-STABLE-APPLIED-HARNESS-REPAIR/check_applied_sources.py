"""Frozen M5-39 source structure checker. A new task must authorize execution.

Never load the inspected modules. Static structures do not prove algorithm behavior.
Oracle fingerprints cover complete M5-38 literal declarations, not names/lengths.
"""
from __future__ import annotations
import ast
import hashlib
import json
import os
import stat
import sys

ROOT = r'D:\EliteSync-v10'
ADAPTER = ROOT + r'\apps\android_synthetic_demo\tools\aar_entry_materials.py'
PRODUCTION = ROOT + r'\apps\android_synthetic_demo\tools\aar_applied_materials.py'
TEST = ROOT + r'\apps\android_synthetic_demo\tools\test_aar_applied_materials.py'
FILES = (
    (ADAPTER, 20338, 'B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7'),
    (PRODUCTION, 6510, '123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224'),
    (TEST, 72513, '29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F'),
)
PLAN_IDENTITY = (137079, '7DB003A4620EEE403A310192DAE2C7BEEAAE5F88AE8D7A5B8CE6D962F8FC34BD')
# Inserted by same-source-A text transcription, never Python/AST evaluation.
ORACLE_DECLARATIONS = {"ORIGINALS":{"bytes":20629,"sha256":"7DBD6C2782EA3A0D748D65F95A61223590EFCF69FA5C3D49552C532E7B4E599E"},"EXPECTED_CODE":{"bytes":11448,"sha256":"DB437FB0752C6BF4782D1E59546D803E5B15EB68CC71631D3D4F2823A1D3D563"},"EXPECTED_SCRATCH":{"bytes":25634,"sha256":"85330CB0FE516DFC059FFD3DD0C0A8E8A506278BC838C473A341FCB762A4B5B9"}}
FROZEN_FUNCTION_TEXT = {"production._exact":{"bytes":86,"sha256":"5B2B6176C0FD4698A2BB4A3ADD49E476A8976F57AC920D304E992420FDA0998C"},"production._type_preflight":{"bytes":1487,"sha256":"427127886855FA28E63F6D36648403F6E64BB047EBBC9BB9B62D7FDF2C68BEC0"},"production._contract":{"bytes":84,"sha256":"DEC3AF1939625C47035264F34F3CD3926CF63E9CD5F6C53B1515D36CA4B309E6"},"production.apply_module_debug_materials":{"bytes":3135,"sha256":"37F1C641121D20A879B1D128FF8D965A107BDBE1FE5FBE1E4330F93637FD8675"},"test.config":{"bytes":726,"sha256":"1512239232E40E57AFEB7550511D6D978CB936C7710F4219CCE7DC7CBE4741A0"},"test.expected":{"bytes":3151,"sha256":"06BC7AD56F2C92A783865A4F0001CA737B55E7E33DC8B86002E0EC8E7069E3A0"},"test.reject":{"bytes":347,"sha256":"96AE50F64F7BD4BDC211330DE64076EEB1489A9BC88278A165BFAC373222A6CD"},"test.test_complete_p1_p2":{"bytes":404,"sha256":"AE0648838AFAE4090745F9065FC40524E026433797D04F891722D637049EA10C"},"test.test_complete_bytes_and_untouched_plugin":{"bytes":483,"sha256":"89D2C7E5B49F4A878A993E9404DF84CC9E626732FD858485F3A52C72A3D3C9D8"},"test.test_shared_anchor_helpers_and_outside_bytes":{"bytes":642,"sha256":"AB83DB540C5922F83EB770C54C51D828CA9480E9267575326114AC4D20DD7A93"},"test.test_full_model_and_logical_separation":{"bytes":890,"sha256":"8D9E2621C8EC9E464E493213330DAB52CD04A34F6142F73F848F7656D4736AE5"},"test.test_frozen_detached_deterministic":{"bytes":854,"sha256":"06029C5ED6443EEF7B020047648642C8DAFC3870D51E879C9D4AD5296B00A7F8"},"test.test_reapplied_output_and_material_changes":{"bytes":729,"sha256":"243CE8F3C7D2ACDF99B5A3A297BE429B11B30B95B9CC88F9DE4D0E1E514BB69E"},"test.test_signature_rejects_external_packages_and_roots":{"bytes":595,"sha256":"9A1AE03B098372D91D41A159C2130C5C097692900C3369D8C8DFEA8303CA16B9"},"test.test_top_exact_types_and_subclasses":{"bytes":833,"sha256":"4BA0612C191B36D9B02B1A1371F7DE16A8BFE97FB239438E33EBE2071A273693"},"test.test_nested_types_before_schema":{"bytes":693,"sha256":"9D166839A3ABB81C840C81CAF4824EFC35A04121D9ECA9AD7F07657BEDAA82D5"},"test.test_config_keys_mode_identity_and_paths":{"bytes":887,"sha256":"189B990B4C2194BCDFBF30A1DB0B6696739A3534D0F58D9F3D7D393B73CA37B0"},"test.test_projects_and_tasks":{"bytes":577,"sha256":"BB50EC33278758B9FCA664B872190B9F04DF7C6482B902ED8C8E345C33B13B6E"},"test.test_ids_and_project_property_conflicts":{"bytes":540,"sha256":"86CC0A8C4F21A922ADC955F9DBB6DF64DBC07D31B8DC8A412891954E676CF53A"},"test.test_property_schema_order_and_path_token":{"bytes":671,"sha256":"3DC577541974081D30541BBD6CA00CA6EF15803139A4B9708FBC697BAD812184"}}
METHODS = (
    'test_complete_p1_p2', 'test_complete_bytes_and_untouched_plugin',
    'test_shared_anchor_helpers_and_outside_bytes', 'test_full_model_and_logical_separation',
    'test_frozen_detached_deterministic', 'test_reapplied_output_and_material_changes',
    'test_signature_rejects_external_packages_and_roots', 'test_top_exact_types_and_subclasses',
    'test_nested_types_before_schema', 'test_config_keys_mode_identity_and_paths',
    'test_projects_and_tasks', 'test_ids_and_project_property_conflicts',
    'test_property_schema_order_and_path_token',
)
checks = []
identities = []


class NotProven(Exception):
    pass


def require(name, condition):
    checks.append({'name': name, 'status': 'PASS' if condition else 'NOT_PROVEN'})
    if not condition:
        raise NotProven(name)


def dotted(node):
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        base = dotted(node.value)
        return (base + '.' if base else '') + node.attr
    if isinstance(node, ast.Call):
        return dotted(node.func) + '()'
    return ''


def expr(node, spelling):
    # Only checker-owned small AST specifications; never eval/compile.
    expected = ast.parse(spelling, mode='eval').body
    return ast.dump(node, include_attributes=False) == ast.dump(expected, include_attributes=False)


def name_store(node, name):
    return isinstance(node, ast.Name) and node.id == name and isinstance(node.ctx, ast.Store)


def assignment(node, name, value):
    return (isinstance(node, ast.Assign) and len(node.targets) == 1
            and name_store(node.targets[0], name) and expr(node.value, value))


def registration(node, key, module):
    return (isinstance(node, ast.Assign) and len(node.targets) == 1
            and isinstance(node.targets[0], ast.Subscript)
            and isinstance(node.targets[0].ctx, ast.Store)
            and expr(node.targets[0].value, 'sys.modules')
            and isinstance(node.targets[0].slice, ast.Constant)
            and node.targets[0].slice.value == key and expr(node.value, module))


def call(node, target, args=()):
    return (isinstance(node, ast.Call) and dotted(node.func) == target
            and not node.keywords and len(node.args) == len(args)
            and all(expr(n, e) for n, e in zip(node.args, args)))


def direct_expr(node, target, args=()):
    return isinstance(node, ast.Expr) and call(node.value, target, args)


def functions(tree):
    return {n.name: n for n in tree.body if isinstance(n, ast.FunctionDef)}


def named_class(tree, name):
    found = [n for n in tree.body if isinstance(n, ast.ClassDef) and n.name == name]
    require('class.unique.' + name, len(found) == 1)
    return found[0]


def named_assignment(tree, name):
    found = [n for n in tree.body if isinstance(n, ast.Assign)
             and len(n.targets) == 1 and name_store(n.targets[0], name)]
    require('constant.unique.' + name, len(found) == 1)
    return found[0]


def literal_utf8_encode(node):
    return (isinstance(node, ast.Call)
            and isinstance(node.func, ast.Attribute)
            and node.func.attr == 'encode'
            and isinstance(node.func.value, ast.Constant)
            and type(node.func.value.value) is str
            and len(node.args) == 1
            and isinstance(node.args[0], ast.Constant)
            and type(node.args[0].value) is str
            and node.args[0].value == 'utf-8'
            and not node.keywords)


def safe_literal(node):
    if literal_utf8_encode(node):
        return True
    if isinstance(node, ast.Constant):
        return type(node.value) in (str, bytes, int, bool, type(None))
    if isinstance(node, (ast.Tuple, ast.List)):
        return all(safe_literal(n) for n in node.elts)
    if isinstance(node, ast.Dict):
        return all(k is not None and safe_literal(k) and safe_literal(v)
                   for k, v in zip(node.keys, node.values))
    return False


def read_exact(path, size, digest):
    info = os.lstat(path)
    require('file.ordinary.' + path, stat.S_ISREG(info.st_mode)
            and not (getattr(info, 'st_file_attributes', 0) & 0x400))
    require('file.stat_size.' + path, info.st_size == size)
    with open(path, 'rb') as stream:
        data = stream.read(size + 1)
    require('file.bytes_hash.' + path, len(data) == size
            and hashlib.sha256(data).hexdigest().upper() == digest)
    text = data.decode('utf-8', errors='strict')
    identities.append({'path': path, 'bytes': len(data), 'sha256': digest,
                       'ordinary_non_reparse': True, 'strict_utf8': True})
    return text


def fingerprint(name, node, text, manifest):
    segment = ast.get_source_segment(text, node)
    require('source_segment.' + name, segment is not None)
    encoded = segment.encode('utf-8')
    record = manifest[name]
    require('complete_text_structure.' + name,
            len(encoded) == record['bytes']
            and hashlib.sha256(encoded).hexdigest().upper() == record['sha256'])


def import_gate(tree, production):
    imports = []
    for n in ast.walk(tree):
        if isinstance(n, ast.Import):
            imports.extend((a.name, a.asname) for a in n.names)
        elif isinstance(n, ast.ImportFrom):
            imports.append((n.module, tuple((a.name, a.asname) for a in n.names)))
    wanted = ([('__future__', (('annotations', None),)),
               ('dataclasses', (('dataclass', None),)), ('hashlib', None),
               ('aar_entry_materials', '_adapter')] if production else
              [('__future__', (('annotations', None),)), ('importlib.util', None),
               ('sys', None), ('unittest', None),
               ('dataclasses', (('FrozenInstanceError', None),))])
    require('imports.exact.production' if production else 'imports.exact.test',
            imports == wanted)


def call_gate(tree, production):
    if production:
        bare = {'dataclass', 'type', 'TypeError', 'ValueError', '_exact',
                '_type_preflight', '_contract', 'dict', 'len', 'enumerate',
                'bool', 'zip', 'tuple', 'ModelProjectInstallation', 'AppliedModuleMaterials'}
        qualified = {'_adapter.adapt_module_debug_entry', 'hashlib.sha256',
                     'hashlib.sha256().hexdigest', 'hashlib.sha256().hexdigest().upper',
                     'current.count', 'current.replace', 'current.partition',
                     'properties.append', 'installations.append'}
    else:
        bare = {'config', 'expected', 'tuple', 'dict', 'list', 'all', 'object', 'str',
                'TupleChild', 'DictChild', 'BytesChild', 'StrChild', 'bytearray', 'zip'}
        qualified = {
            'importlib.util.spec_from_file_location', 'importlib.util.module_from_spec',
            '_spec.loader.exec_module', '_applied_spec.loader.exec_module',
            '_module.LiteralString', '_module.RootProjectDirFilePath',
            '_module.InstallationGroup', '_module.InvocationContract', '_module.Attachment',
            '_applied.ModelProjectInstallation', '_applied.AppliedModuleMaterials',
            '_applied.apply_module_debug_materials', 'bad.pop',
            'self.reject', 'self.assertRaises', 'self.assertEqual', 'self.assertFalse',
            'self.assertTrue', "actual.count",
            'unittest.defaultTestLoader.loadTestsFromModule',
            'unittest.TextTestRunner', 'unittest.TextTestRunner().run',
            'sys.exit', 'outcome.wasSuccessful',
        }
    nodes = list(ast.walk(tree))
    require('nodes.no_async_or_dynamic.' + ('production' if production else 'test'),
            not any(isinstance(n, (ast.AsyncFunctionDef, ast.Await, ast.Lambda)) for n in nodes))
    rejected_calls = []
    rejected_attributes = []
    for n in nodes:
        if isinstance(n, ast.Call):
            target = dotted(n.func)
            # In test the only indexed receiver call is literal init-full.count.
            indexed_count = (not production and isinstance(n.func, ast.Attribute)
                             and n.func.attr == 'count'
                             and expr(n.func.value, "actual['init-full']"))
            lexical_join = (production and isinstance(n.func, ast.Attribute)
                            and n.func.attr == 'join' and expr(n.func.value, "'/'")
                            and len(n.args) == 1 and expr(n.args[0], 'recipe.child_components')
                            and not n.keywords)
            if not (target in bare or target in qualified or indexed_count or lexical_join
                    or (not production and literal_utf8_encode(n))):
                rejected_calls.append(target + ':' + str(n.lineno))
        if isinstance(n, ast.Attribute):
            if n.attr in {'_CODE', '__dict__', '__globals__', '__builtins__',
                          'environ', 'path', 'discover', 'system', 'popen',
                          'read', 'write', 'read_bytes', 'write_bytes',
                          'exec', 'eval', 'compile', 'runpy'}:
                rejected_attributes.append(n.attr + ':' + str(n.lineno))
    require('calls.receiver_allowlist.' + ('production' if production else 'test')
            + ('.' + ','.join(rejected_calls[:3]) if rejected_calls else ''), not rejected_calls)
    require('attributes.no_private_or_host.' + ('production' if production else 'test'),
            not rejected_attributes)
    # Exact loader and runner gates below constrain the otherwise allowed host calls.


def dataclass_gate(tree):
    specs = {
        'ModelProjectInstallation': [
            ('project', 'str'), ('scope', 'str'), ('phase', 'str'),
            ('root_token', 'str'), ('own_properties', 'tuple[tuple[str, str], ...]'),
            ('model_only', 'bool')],
        'AppliedModuleMaterials': [
            ('fragments', 'tuple[tuple[str, bytes], tuple[str, bytes], tuple[str, bytes], tuple[str, bytes]]'),
            ('attachments', 'tuple[_adapter.Attachment, _adapter.Attachment]'),
            ('invocation', '_adapter.InvocationContract'),
            ('model_installation', 'tuple[ModelProjectInstallation, ModelProjectInstallation, ModelProjectInstallation, ModelProjectInstallation]'),
            ('model_only', 'bool')],
    }
    for name, spec in specs.items():
        cls = named_class(tree, name)
        require('dataclass.frozen_slots.' + name, not cls.bases and not cls.keywords
                and len(cls.decorator_list) == 1
                and expr(cls.decorator_list[0], 'dataclass(frozen=True, slots=True)'))
        require('dataclass.exact_fields.' + name, len(cls.body) == len(spec)
                and all(isinstance(n, ast.AnnAssign) and name_store(n.target, key)
                        and n.value is None and expr(n.annotation, annotation)
                        for n, (key, annotation) in zip(cls.body, spec)))


def has_expr(tree, spelling):
    return any(isinstance(n, ast.expr) and expr(n, spelling) for n in ast.walk(tree))


def production_gate(tree, text):
    import_gate(tree, True)
    call_gate(tree, True)
    dataclass_gate(tree)
    fs = functions(tree)
    require('production.exact_functions',
            tuple(fs) == ('_exact', '_type_preflight', '_contract', 'apply_module_debug_materials'))
    for name, fn in fs.items():
        fingerprint('production.' + name, fn, text, FROZEN_FUNCTION_TEXT)
    fn = fs['apply_module_debug_materials']
    args = fn.args
    require('entry.keyword_only', not args.posonlyargs and not args.args and not args.defaults
            and args.vararg is None and args.kwarg is None
            and tuple(a.arg for a in args.kwonlyargs) == ('materials', 'config')
            and args.kw_defaults == [None, None])
    require('entry.return_annotation', expr(fn.returns, 'AppliedModuleMaterials'))
    require('entry.preflight_before_adapter',
            direct_expr(fn.body[1], '_type_preflight', ('materials', 'config'))
            and assignment(fn.body[2], 'package',
                           '_adapter.adapt_module_debug_entry(materials=materials, config=config)'))
    require('entry.local_originals_and_scratch',
            assignment(fn.body[3], 'originals', 'dict(materials)')
            and assignment(fn.body[4], 'scratch', 'dict(originals)'))
    flow = named_assignment(tree, '_FLOW')
    require('six.flow.literal', safe_literal(flow.value) and expr(flow.value, """(
        ('repo-block','REPLACE_UNIQUE','repo-before'),
        ('tasks-full','REPLACE_UNIQUE','tasks-before'),
        ('init-full','INSERT_BEFORE_UNIQUE','init-all-before'),
        ('init-full','REPLACE_UNIQUE','init-all-before'),
        ('init-full','REPLACE_UNIQUE','init-afterProject-before'),
        ('init-full','REPLACE_UNIQUE','init-projectsEvaluated-before'))"""))
    expectations = (
        ('six.operation_order', 'enumerate(package.operations)'),
        ('six.original_digest', 'hashlib.sha256(originals[target]).hexdigest().upper()'),
        ('six.unique_anchor', 'current.count(operation.before) == 1'),
        ('six.nonempty_before', 'bool(operation.before)'),
        ('six.replace_one', 'current.replace(operation.before, operation.after, 1)'),
        ('six.insert_shared_anchor', 'current.partition(operation.before)'),
        ('plugin_deps.unchanged', "scratch['plugin-deps'] == originals['plugin-deps']"),
        ('types.exact_not_isinstance', 'type(value) is not cls'),
        ('return.whole_immutable', 'AppliedModuleMaterials(fragments, package.attachments, invocation, tuple(installations), True)'),
        ('model.four_projects', "(':', ':flutter', ':sample_alpha', ':sample_beta')"),
        ('model.fixed_root', "'B/module/.android'"),
        ('model.lexical_children', "_ROOT_MODEL + '/' + '/'.join(recipe.child_components)"),
        ('model.true', "ModelProjectInstallation(project, 'LOCAL_EXTRA', _PHASE, _ROOT_MODEL, tuple(properties), True)"),
        ('invocation.runtime_false', 'invocation.runtime_ready is False'),
        ('recipe.fixed_children', "recipe.child_components == ('..', '..', 'publication')"),
    )
    for name, spelling in expectations:
        require(name, has_expr(tree, spelling))
    require('immutable.no_external_package_parameters',
            all(a.arg not in {'operations', 'package', 'model_root'} for a in args.kwonlyargs))
    require('return.invocation_unmodified', any(assignment(n, 'invocation', 'package.invocation')
                                                for n in fn.body))


def loader_gate(tree):
    # Only these eight top-level statements may load a module.
    body = [n for n in tree.body if not isinstance(n, (ast.Import, ast.ImportFrom))
            and not (isinstance(n, ast.Expr) and isinstance(n.value, ast.Constant)
                     and isinstance(n.value.value, str))]
    require('loader.enough_statements', len(body) >= 8)
    for offset, spec, module, key, path in (
        (0, '_spec', '_module', 'aar_entry_materials', ADAPTER),
        (4, '_applied_spec', '_applied', 'aar_applied_materials', PRODUCTION),
    ):
        n = body[offset]
        require('loader.constant_path.' + key, isinstance(n, ast.Assign)
                and len(n.targets) == 1 and name_store(n.targets[0], spec)
                and isinstance(n.value, ast.Call)
                and dotted(n.value.func) == 'importlib.util.spec_from_file_location'
                and not n.value.keywords and len(n.value.args) == 2
                and all(isinstance(a, ast.Constant) for a in n.value.args)
                and n.value.args[0].value == key and n.value.args[1].value == path)
        require('loader.create.' + key,
                assignment(body[offset + 1], module, 'importlib.util.module_from_spec(' + spec + ')'))
        require('loader.register_before_exec.' + key,
                registration(body[offset + 2], key, module))
        require('loader.exec_exact.' + key,
                direct_expr(body[offset + 3], spec + '.loader.exec_module', (module,)))
    exact_host_nodes = {id(n.value) for n in body[:8] if isinstance(n, (ast.Assign, ast.Expr))}
    for n in ast.walk(tree):
        if isinstance(n, ast.Call) and dotted(n.func) in {
            'importlib.util.spec_from_file_location', 'importlib.util.module_from_spec',
            '_spec.loader.exec_module', '_applied_spec.loader.exec_module',
        }:
            require('loader.no_third_or_nested.' + str(n.lineno), id(n) in exact_host_nodes)
    registrations = [n for n in ast.walk(tree) if isinstance(n, ast.Assign)
                     and any(isinstance(t, ast.Subscript) and expr(t.value, 'sys.modules')
                             for t in n.targets)]
    require('loader.only_two_registrations', len(registrations) == 2)


def oracle_gate(tree, text):
    for name in ('ORIGINALS', 'EXPECTED_CODE', 'EXPECTED_SCRATCH'):
        node = named_assignment(tree, name)
        require('oracle.literal_only.' + name, safe_literal(node.value))
        fingerprint(name, node, text, ORACLE_DECLARATIONS)
    fs = functions(tree)
    require('oracle.only_config_and_expected_functions', tuple(fs) == ('config', 'expected'))
    for name in ('config', 'expected'):
        fingerprint('test.' + name, fs[name], text, FROZEN_FUNCTION_TEXT)
    cfg = fs['config']
    require('config.return_complete_dictionary', isinstance(cfg.body[-1], ast.Return)
            and isinstance(cfg.body[-1].value, ast.Dict)
            and tuple(k.value for k in cfg.body[-1].value.keys if isinstance(k, ast.Constant)) == (
                'mode', 'flutter_identity', 'init_identity', 'input_id', 'projects',
                'properties', 'tasks', 'sdk_root', 'maven_root', 'publication_root', 'repositories_mode'))
    expected = fs['expected']
    constructors = [n for n in ast.walk(expected) if isinstance(n, ast.Call)]
    require('oracle.no_production_call_or_private_constants', all(
        dotted(n.func) in {'config', 'tuple', '_module.LiteralString', '_module.RootProjectDirFilePath',
                          '_module.InstallationGroup', '_module.InvocationContract', '_module.Attachment',
                          '_applied.ModelProjectInstallation', '_applied.AppliedModuleMaterials'}
        for n in constructors))
    invocations = [n for n in constructors if dotted(n.func) == '_module.InvocationContract']
    expected_fields = (
        'mode', 'requested_tasks', 'projects', 'logical_properties', 'property_installation',
        'property_install_phase', 'sdk_root', 'maven_root', 'publication_root',
        'publication_repository', 'repositories_mode', 'module_project', 'module_variant',
        'plugin_projects', 'plugin_variants', 'aar_task_edges', 'publish_finalizers',
        'sdk_identity', 'init_identity', 'input_id', 'runtime_ready')
    require('oracle.complete_invocation_fields', len(invocations) == 1 and not invocations[0].args
            and tuple(k.arg for k in invocations[0].keywords) == expected_fields)
    for name, spelling in (
        ('oracle.four_complete_fragments', """(
            ('tasks-full',EXPECTED_SCRATCH['tasks-full']),
            ('repo-block',EXPECTED_SCRATCH['repo-block']),
            ('init-full',EXPECTED_SCRATCH['init-full']),
            ('plugin-deps',ORIGINALS[3][1]))"""),
        ('oracle.own_complete', """(
            ('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),
            ('output-dir','B/module/.android/../../publication'),('buildNumber',input_id),
            ('elitesync.sdk-identity',F),
            ('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))"""),
        ('oracle.attachment_helper', "_module.Attachment('apply-helper','FLUTTER_PLUGIN_CLASS_MEMBER',F,b'',EXPECTED_CODE['apply-helper'],False)"),
        ('oracle.attachment_preflight', "_module.Attachment('apply-preflight-proposal','APPLY_AFTER_THIS_PROJECT_ASSIGNMENT',F,EXPECTED_CODE['preflight-before'],EXPECTED_CODE['preflight-after'],False)"),
        ('oracle.whole_return', '_applied.AppliedModuleMaterials(fragments, attachments, invocation, installed, True)'),
    ):
        require(name, has_expr(expected, spelling))


def tests_gate(tree, text):
    import_gate(tree, False)
    call_gate(tree, False)
    loader_gate(tree)
    oracle_gate(tree, text)
    cls = named_class(tree, 'AppliedMaterialsTests')
    require('tests.base', len(cls.bases) == 1 and expr(cls.bases[0], 'unittest.TestCase'))
    methods = [n for n in cls.body if isinstance(n, ast.FunctionDef)]
    require('tests.exact_names_and_count', tuple(n.name for n in methods)
            == ('reject',) + METHODS and len(methods) == 14)
    for method in methods:
        fingerprint('test.' + method.name, method, text, FROZEN_FUNCTION_TEXT)
        if method.name != 'reject':
            require('tests.nonempty_assertion_structure.' + method.name, any(
                isinstance(n, ast.Call) and dotted(n.func) in {
                    'self.assertEqual','self.assertRaises','self.assertTrue','self.assertFalse','self.reject'}
                for n in ast.walk(method)))
    p1 = next(n for n in methods if n.name == 'test_complete_p1_p2')
    require('tests.p1_p2_independent_expected', all(has_expr(p1, e) for e in (
        'config(IDA)', 'config(IDB)', 'expected(IDA)', 'expected(IDB)',
        'self.assertEqual(a, expected(IDA))', 'self.assertEqual(b, expected(IDB))')))
    mains = [n for n in tree.body if isinstance(n, ast.If)]
    require('runner.unique_main_guard', len(mains) == 1
            and expr(mains[0].test, "__name__ == '__main__'") and not mains[0].orelse)
    body = mains[0].body
    require('runner.fixed_current_module', len(body) == 3
            and assignment(body[0], 'suite', 'unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])')
            and assignment(body[1], 'outcome', 'unittest.TextTestRunner(verbosity=2).run(suite)')
            and direct_expr(body[2], 'sys.exit',
                            ('0 if outcome.testsRun > 0 and outcome.wasSuccessful() else 1',)))
    hosts = [n for n in ast.walk(tree) if isinstance(n, ast.Call)
             and dotted(n.func) in {'unittest.defaultTestLoader.loadTestsFromModule',
                                   'unittest.TextTestRunner', 'unittest.TextTestRunner().run', 'sys.exit'}]
    require('runner.only_exact_authorized_hosts', len(hosts) == 4
            and all(n.lineno >= mains[0].lineno for n in hosts))


def main():
    report = {
        'kind': 'STATIC_STRUCTURE_ONLY', 'identities': identities, 'checks': checks,
        'authored_test_methods': list(METHODS), 'tests_run': 'NOT_CHECKED',
        'algorithm_behavior': 'NOT_PROVEN', 'os_isolation': 'NOT_PROVEN',
        'absolute_hard_deadline': 'NOT_PROVEN', 'module_import': 'NOT_CHECKED',
    }
    try:
        sources = [read_exact(*spec) for spec in FILES]
        production_tree = ast.parse(sources[1], filename=PRODUCTION)
        test_tree = ast.parse(sources[2], filename=TEST)
        require('ast.parse.two_new_sources', True)
        production_gate(production_tree, sources[1])
        tests_gate(test_tree, sources[2])
        report['status'] = 'STATIC_STRUCTURE_PASS'
        result = 0
    except Exception as error:
        report['status'] = 'NOT_PROVEN'
        report['terminal_error'] = type(error).__name__ + ':' + str(error)[:256]
        result = 1
    # No source text, byte fixtures or oracle literal bodies in the receipt.
    print(json.dumps(report, ensure_ascii=True, separators=(',', ':')))
    return result


if __name__ == '__main__':
    sys.exit(main())
