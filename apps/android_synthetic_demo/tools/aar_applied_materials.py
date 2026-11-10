"""Pure in-memory application of the accepted module-debug materials contract.

No file/path installation, SDK evaluation or externally supplied patch package.
The importing test must register the exact accepted aar_entry_materials first.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib
import aar_entry_materials as _adapter


@dataclass(frozen=True, slots=True)
class ModelProjectInstallation:
    project: str
    scope: str
    phase: str
    root_token: str
    own_properties: tuple[tuple[str, str], ...]
    model_only: bool


@dataclass(frozen=True, slots=True)
class AppliedModuleMaterials:
    fragments: tuple[tuple[str, bytes], tuple[str, bytes], tuple[str, bytes], tuple[str, bytes]]
    attachments: tuple[_adapter.Attachment, _adapter.Attachment]
    invocation: _adapter.InvocationContract
    model_installation: tuple[ModelProjectInstallation, ModelProjectInstallation,
                              ModelProjectInstallation, ModelProjectInstallation]
    model_only: bool


_PHASE = 'BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'
_ROOT_MODEL = 'B/module/.android'
_PROJECTS = (':', ':flutter', ':sample_alpha', ':sample_beta')
_KEYS = ('elitesync.aar-entry', 'is-plugin', 'output-dir', 'buildNumber',
         'elitesync.sdk-identity', 'elitesync.aar-projects')
_FLOW = (
    ('repo-block', 'REPLACE_UNIQUE', 'repo-before'),
    ('tasks-full', 'REPLACE_UNIQUE', 'tasks-before'),
    ('init-full', 'INSERT_BEFORE_UNIQUE', 'init-all-before'),
    ('init-full', 'REPLACE_UNIQUE', 'init-all-before'),
    ('init-full', 'REPLACE_UNIQUE', 'init-afterProject-before'),
    ('init-full', 'REPLACE_UNIQUE', 'init-projectsEvaluated-before'),
)


def _exact(value, cls):
    if type(value) is not cls:
        raise TypeError('TYPE')


def _type_preflight(materials, config):
    """Check all supplied known typed slots before adapter schema validation.

    Wrong tuple lengths remain adapter CONTRACT errors; missing slots are
    not filled. Exact containers avoid invoking subclass/custom methods.
    """
    _exact(materials, tuple)
    _exact(config, dict)
    for pair in materials:
        _exact(pair, tuple)
        if len(pair) >= 1:
            _exact(pair[0], str)
        if len(pair) >= 2:
            _exact(pair[1], bytes)
    for key in config:
        _exact(key, str)
    for key in ('mode', 'flutter_identity', 'init_identity', 'input_id',
                'sdk_root', 'maven_root', 'publication_root', 'repositories_mode'):
        if key in config:
            _exact(config[key], str)
    for key in ('projects', 'tasks'):
        if key in config:
            _exact(config[key], tuple)
            for value in config[key]:
                _exact(value, str)
    if 'properties' in config:
        _exact(config['properties'], tuple)
        for group in config['properties']:
            _exact(group, tuple)
            if len(group) >= 1:
                _exact(group[0], str)
            if len(group) >= 2:
                _exact(group[1], tuple)
                for prop in group[1]:
                    _exact(prop, tuple)
                    if len(prop) >= 1:
                        _exact(prop[0], str)
                    if len(prop) >= 2:
                        _exact(prop[1], str)


def _contract(condition):
    if not condition:
        raise ValueError('CONTRACT')


def apply_module_debug_materials(*, materials, config) -> AppliedModuleMaterials:
    """Return the entire immutable result only after all local work succeeds."""
    _type_preflight(materials, config)
    package = _adapter.adapt_module_debug_entry(materials=materials, config=config)
    originals = dict(materials)
    scratch = dict(originals)
    _contract(len(package.operations) == 6)
    for order, operation in enumerate(package.operations):
        target, kind, anchor = _FLOW[order]
        _contract(type(operation) is _adapter.PatchOperation
                  and type(operation.order) is int and operation.order == order
                  and operation.target == target and operation.kind == kind
                  and operation.anchor_id == anchor
                  and type(operation.before) is bytes and bool(operation.before)
                  and type(operation.after) is bytes)
        # Hash the original immutable bytes, never the already altered init.
        _contract(operation.input_fragment_sha256 ==
                  hashlib.sha256(originals[target]).hexdigest().upper())
        current = scratch[target]
        _contract(current.count(operation.before) == 1)
        if kind == 'REPLACE_UNIQUE':
            scratch[target] = current.replace(operation.before, operation.after, 1)
        else:
            left, before, right = current.partition(operation.before)
            scratch[target] = left + operation.after + before + right
    _contract(scratch['plugin-deps'] == originals['plugin-deps'])

    invocation = package.invocation
    _contract(invocation.projects == _PROJECTS
              and invocation.property_install_phase == _PHASE
              and len(invocation.property_installation) == 4
              and invocation.runtime_ready is False)
    installations = []
    for project, group in zip(_PROJECTS, invocation.property_installation):
        _contract(group.project == project and group.scope == 'LOCAL_EXTRA')
        properties = []
        for recipe in group.recipes:
            if type(recipe) is _adapter.LiteralString:
                properties.append((recipe.key, recipe.value))
            elif type(recipe) is _adapter.RootProjectDirFilePath:
                _contract(recipe.key == 'output-dir' and recipe.base == 'ROOT_PROJECT_DIR'
                          and recipe.child_components == ('..', '..', 'publication')
                          and recipe.result == 'FILE_PATH' and recipe.install_phase == _PHASE)
                # Fixed lexical string projection only. Retain both '..'.
                properties.append((recipe.key, _ROOT_MODEL + '/' + '/'.join(recipe.child_components)))
            else:
                raise ValueError('CONTRACT')
        _contract(tuple(key for key, _ in properties) == _KEYS)
        installations.append(ModelProjectInstallation(
            project, 'LOCAL_EXTRA', _PHASE, _ROOT_MODEL, tuple(properties), True))
    fragments = tuple((name, scratch[name]) for name, _ in materials)
    return AppliedModuleMaterials(fragments, package.attachments, invocation,
                                  tuple(installations), True)
