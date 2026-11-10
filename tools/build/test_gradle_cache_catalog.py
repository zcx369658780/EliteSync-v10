"""Synthetic cache/metadata fixtures only; no Gradle, SDK or network execution."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import gradle_cache_catalog as catalog


def entry(module='lib', version='1.0', name=None, content=b'payload', group='example'):
    name = name or f'{module}-{version}.jar'
    digests = {k: hashlib.new(k, content).hexdigest() for k in ('sha1', 'sha256', 'sha512', 'md5')}
    return dict(group=group, module=module, version=version, name=name, bytes=len(content),
                digests=digests, relative_path=f'modules-2/files-2.1/{group}/{module}/{version}/{digests["sha1"]}/{name}')


def metadata(owner, variants):
    return json.dumps({'formatVersion': '1.1', 'component': {k: owner[k] for k in ('group','module','version')},
                       'variants': variants}).encode()


class GradleCacheCatalogTests(unittest.TestCase):
    def graph(self, owner, payloads, variants):
        raw = metadata(owner, variants)
        descriptor = entry(owner['module'], owner['version'], owner['module']+'-'+owner['version']+'.module', raw, owner['group'])
        return catalog.analyze_modules([descriptor, *payloads], {descriptor['relative_path']: raw})

    def test_cache_path_coordinates_and_sha1_remain_distinct_from_SHA256(self):
        row = entry()
        parsed = catalog.parse_cache_path(row['relative_path'])
        self.assertEqual(parsed, {'group':'example','module':'lib','version':'1.0',
                                 'sha1':row['digests']['sha1'],'name':'lib-1.0.jar'})
        for relative in ('../'+row['relative_path'], row['relative_path'].replace('/lib/', '//lib/'),
                         row['relative_path'].replace(row['digests']['sha1'], 'a'*64)):
            with self.subTest(relative=relative), self.assertRaises(ValueError):
                catalog.parse_cache_path(relative)

    def test_variant_files_all_advertised_hashes_and_metadata_only_edges(self):
        owner=entry();target=entry('dep','2.0',name='dep-2.0.pom',content=b'opaque POM')
        file={'name':owner['name'],'url':owner['name'],'size':owner['bytes'],**owner['digests']}
        result=self.graph(owner,[owner,target],[{'name':'runtimeElements','attributes':{'org.gradle.usage':'java-runtime'},
            'files':[file],'dependencies':[{'group':'example','module':'dep','version':{'requires':'2.0'}}],
            'dependencyConstraints':[{'group':'example','module':'missing','version':{'requires':'3.0'}}]}])
        self.assertEqual(result['files'][0]['status'],'MATCHED_DECLARED_HASHES')
        self.assertEqual(result['edges'][0]['status'],'DECLARED_COORDINATE_PRESENT')
        self.assertEqual(result['edges'][0]['binary_candidates'],0)
        self.assertEqual(result['edges'][1]['status'],'NOT_IN_DECLARED_SEED')
        self.assertIs(result['offline_resolution_proven'],False)
        self.assertIs(result['variant_selection_performed'],False)

    def test_missing_documentation_variant_is_reported_without_selecting_it(self):
        owner=entry()
        result=self.graph(owner,[owner],[{'name':'sourcesElements','attributes':{'org.gradle.docstype':'sources'},
            'files':[{'name':'lib-1.0-sources.jar','url':'lib-1.0-sources.jar','size':4,'sha256':'a'*64}]}])
        self.assertEqual(result['files'][0]['status'],'NOT_IN_DECLARED_SEED')
        self.assertEqual(result['variants'][0]['attributes']['org.gradle.docstype'],'sources')

    def test_hash_mismatch_or_same_filename_two_contents_are_not_auto_selected(self):
        owner=entry();other=entry(content=b'different')
        file={'name':owner['name'],'url':owner['name'],'size':owner['bytes'],'sha256':'f'*64}
        result=self.graph(owner,[owner],[{'name':'runtime','files':[file]}])
        self.assertEqual(result['files'][0]['status'],'DECLARED_HASH_MISMATCH')
        file.update(size=owner['bytes'],sha256=owner['digests']['sha256'])
        result=self.graph(owner,[owner,other],[{'name':'runtime','files':[file]}])
        self.assertEqual(result['files'][0]['status'],'AMBIGUOUS_DECLARED_FILES')
        self.assertEqual(result['files'][0]['candidates'],2)

    def test_rich_dynamic_and_missing_versions_stay_unresolved(self):
        owner=entry();versions=[{'requires':'1.+'},{'requires':'1.0','strictly':'1.0'},None]
        result=self.graph(owner,[owner],[{'name':'runtime','dependencies':[
            {'group':'example','module':'dep','version':v} for v in versions]}])
        self.assertEqual([e['status'] for e in result['edges']],['UNRESOLVED_VERSION_POLICY']*3)
        self.assertEqual(result['edges'][1]['version'],versions[1])

    def test_available_at_is_coordinate_only_and_urls_are_never_followed(self):
        owner=entry();target=entry('other','2.0',name='other-2.0.module',content=b'not parsed here')
        result=self.graph(owner,[target],[{'name':'redirect','available-at':{
            'group':'example','module':'other','version':'2.0','url':'../../other/other-2.0.module'}},
            {'name':'remote','files':[{'name':owner['name'],'url':'https://invalid/'+owner['name']}]}])
        self.assertEqual(result['edges'][0]['relation'],'available-at')
        self.assertEqual(result['edges'][0]['status'],'DECLARED_COORDINATE_PRESENT')
        self.assertEqual(result['files'][0]['status'],'UNRESOLVED_FILE_URL')

    def test_duplicate_JSON_component_drift_and_caps_fail_closed(self):
        owner=entry();raw=b'{"formatVersion":"1.1","formatVersion":"1.1"}'
        descriptor=entry(name='lib-1.0.module',content=raw)
        with self.assertRaises(ValueError):
            catalog.analyze_modules([descriptor],{descriptor['relative_path']:raw})
        raw=metadata({**owner,'version':'2.0'},[])
        descriptor=entry(name='lib-1.0.module',content=raw)
        with self.assertRaises(ValueError):
            catalog.analyze_modules([descriptor],{descriptor['relative_path']:raw})

    def test_compact_SHA1_directory_is_zero_padded_not_treated_as_prefix(self):
        for i in range(256):
            row=entry(content=('fixture-'+str(i)).encode())
            if row['digests']['sha1'].startswith('0'):break
        full=row['digests']['sha1'];self.assertTrue(full.startswith('0'))
        compact=row['relative_path'].replace('/'+full+'/', '/'+full.lstrip('0')+'/')
        self.assertEqual(catalog.parse_cache_path(compact)['sha1'],full)

    def test_latest_status_is_unresolved_for_dependencies_constraints_and_redirects(self):
        owner=entry()
        for value in ('latest.milestone','latest.custom'):
            result=self.graph(owner,[],[{'name':'runtime','dependencies':[
                {'group':'example','module':'dep','version':{'requires':value}}],
                'dependencyConstraints':[{'group':'example','module':'dep','version':{'requires':value}}],
                'available-at':{'group':'example','module':'dep','version':value,'url':'not-followed'}}])
            self.assertEqual([e['status'] for e in result['edges']],['UNRESOLVED_VERSION_POLICY']*3)

    def test_attributes_are_stored_once_and_relation_cap_is_checked_before_append(self):
        owner=entry();attrs={'large':'x'*30000}
        variants=[{'name':'runtime','attributes':attrs,'dependencies':[
            {'group':'example','module':'dep','version':{'requires':'2.0'}} for _ in range(5)]}]
        result=self.graph(owner,[],variants)
        self.assertEqual(result['variants'][0]['attributes'],attrs)
        self.assertTrue(all('attributes' not in edge for edge in result['edges']))
        with patch.object(catalog,'RELATION_LIMIT',3):
            with self.assertRaises(ValueError):self.graph(owner,[],variants)

    def test_wrong_SHA1_directory_and_extra_membership_fail_closed(self):
        for defect in ('sha1','extra'):
            with self.subTest(defect=defect),tempfile.TemporaryDirectory() as directory:
                root=Path(directory);row=entry()
                relative=row['relative_path']
                if defect=='sha1':relative=relative.replace(row['digests']['sha1'],'0'*40)
                path=root/relative;path.parent.mkdir(parents=True);path.write_bytes(b'payload');s=path.stat()
                records=[dict(role=catalog.ROLE,path=str(path),relative_path=relative,bytes=s.st_size,
                    sha256=row['digests']['sha256'],file_id={'device':s.st_dev,'inode':s.st_ino})]
                if defect=='extra':(root/'unexpected').write_bytes(b'undeclared')
                with self.assertRaises(ValueError):catalog.inspect_seed(str(root),records)

    def test_variant_filename_can_differ_from_coordinate_filename(self):
        owner=entry(name='runtime-release.aar')
        self.assertEqual(catalog.parse_cache_path(owner['relative_path'])['version'],'1.0')
        result=self.graph(owner,[owner],[{'name':'runtime','files':[
            {'name':owner['name'],'url':owner['name'],'size':owner['bytes'],**owner['digests']}]}])
        self.assertEqual(result['files'][0]['status'],'MATCHED_DECLARED_HASHES')

    def test_repeated_candidate_fanout_has_an_aggregate_cap(self):
        owner=entry();file={'name':owner['name'],'url':owner['name'],'sha256':owner['digests']['sha256']}
        with patch.object(catalog,'CANDIDATE_REFERENCE_LIMIT',2):
            with self.assertRaises(ValueError):
                self.graph(owner,[owner],[{'name':'runtime','files':[file,file,file]}])

    def test_same_owner_variant_in_distinct_descriptors_has_unique_references(self):
        owner=entry();entries=[];payloads={}
        for value in ('first','second'):
            raw=metadata(owner,[{'name':'runtime','attributes':{'which':value},'dependencies':[
                {'group':'example','module':value,'version':{'requires':'1.0'}}]}])
            desc=entry(name='lib-1.0.module',content=raw);entries.append(desc);payloads[desc['relative_path']]=raw
        result=catalog.analyze_modules(entries,payloads)
        table={(v['descriptor'],v['owner'],v['variant']):v['attributes'] for v in result['variants']}
        self.assertEqual(len(table),2)
        for edge in result['edges']:
            self.assertEqual(table[(edge['descriptor'],edge['owner'],edge['variant'])]['which'],edge['module'])

    def test_component_origin_link_stays_unresolved_without_rebinding_variants(self):
        owner=entry();doc={'formatVersion':'1.1','component':{'group':'example','module':'parent',
            'version':'1.0','url':'../../parent/1.0/parent-1.0.module'},'variants':[
            {'name':'runtime','dependencies':[{'group':'example','module':'dep','version':{'requires':'2.0'}}]}]}
        raw=json.dumps(doc).encode();desc=entry(name='lib-1.0.module',content=raw)
        result=catalog.analyze_modules([desc],{desc['relative_path']:raw})
        self.assertEqual(result['parsed_module_files'],0)
        self.assertEqual(len(result['unresolved_component_origins']),1)
        self.assertEqual(result['unresolved_component_origins'][0]['cached_coordinate'],['example','lib','1.0'])
        self.assertEqual(result['edges'],[])
        self.assertEqual(result['variants'],[])
        self.assertIs(result['offline_resolution_proven'],False)

    def test_inventory_bound_read_hashes_layout_and_preserves_opaque_metadata(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);binary=entry();raw=metadata(binary,[{'name':'runtime','files':[
                {'name':binary['name'],'url':binary['name'],'size':binary['bytes'],**binary['digests']}]}])
            descriptor=entry(name='lib-1.0.module',content=raw)
            contents=[(binary['relative_path'],b'payload'),(descriptor['relative_path'],raw),
                      ('modules-2/metadata-2.107/descriptors/example/lib/1.0/key/descriptor.bin',b'opaque cache')]
            rows=[]
            for relative,data in contents:
                path=root/relative;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data);s=path.stat()
                rows.append(dict(role=catalog.ROLE,path=str(path),relative_path=relative,bytes=len(data),
                    sha256=hashlib.sha256(data).hexdigest(),file_id={'device':s.st_dev,'inode':s.st_ino}))
            result=catalog.inspect_seed(str(root),rows)
            self.assertEqual(result['freshly_hashed_files'],3)
            self.assertEqual(result['opaque_binary_metadata_files'],1)
            self.assertEqual(result['analysis']['files'][0]['status'],'MATCHED_DECLARED_HASHES')
            self.assertIs(result['G2'],False)
            real=catalog.analyze_modules
            def analyze_then_drift(*args,**kwargs):
                result=real(*args,**kwargs)
                (root/binary['relative_path']).write_bytes(b'mutated late')
                return result
            with patch.object(catalog,'analyze_modules',side_effect=analyze_then_drift):
                with self.assertRaises(ValueError):
                    catalog.inspect_seed(str(root),rows)


if __name__=='__main__':
    unittest.main()
