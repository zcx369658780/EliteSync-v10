"""Declaration fixtures only: never execute Maven, Gradle, SDKs or URL requests."""
import hashlib
import json
import unittest
from unittest.mock import patch

import gradle_metadata_declarations as declarations


def descriptor(group='example', module='child', version='1.0', suffix='module', data=None):
    if data is None:
        data = json.dumps({'formatVersion':'1.1', 'component':{
            'group':group, 'module':module, 'version':version}, 'variants':[]}).encode()
    sha1 = hashlib.sha1(data).hexdigest()
    name = f'{module}-{version}.{suffix}'
    return dict(group=group, module=module, version=version, name=name,
                relative_path=f'modules-2/files-2.1/{group}/{module}/{version}/{sha1}/{name}',
                digests={'sha256':hashlib.sha256(data).hexdigest()}, bytes=len(data)), data


def origin(url='../../parent/1.0/parent-1.0.module'):
    return descriptor(data=json.dumps({'formatVersion':'1.1','component':{
        'group':'example','module':'parent','version':'1.0','url':url},
        'variants':[{'name':'runtime','dependencies':[{'group':'never','module':'merged'}]}]}).encode())


def pom(body, group='example', module='child', version='1.0', namespace=True):
    ns=' xmlns="http://maven.apache.org/POM/4.0.0"' if namespace else ''
    raw=(f'<project{ns}><modelVersion>4.0.0</modelVersion>{body}</project>').encode()
    return descriptor(group,module,version,'pom',raw)


class MetadataDeclarationsTests(unittest.TestCase):
    def analyze(self, *pairs):
        return declarations.analyze_declarations([p[0] for p in pairs],
            {e['relative_path']:raw for e,raw in pairs})

    def test_exact_component_link_has_two_identities_and_never_merges_variants(self):
        child=origin();parent=descriptor(module='parent')
        result=self.analyze(child,parent)
        link=result['component_origins'][0]
        self.assertEqual(link['status'],'EXACT_LOCAL_ORIGIN_LINK')
        self.assertEqual(link['cached_coordinate'],['example','child','1.0'])
        self.assertEqual(link['declared_coordinate'],['example','parent','1.0'])
        self.assertEqual(link['candidate_paths'],[parent[0]['relative_path']])
        self.assertNotIn('variants',link)
        self.assertFalse(result['variant_selection_performed'])
        self.assertFalse(result['offline_resolution_proven'])

    def test_remote_encoded_query_absolute_or_escaping_links_stay_unresolved(self):
        for url in ('https://invalid/parent.module','/parent.module','../../../parent.module',
                    '../../parent/1.0/parent-1.0.module?x=1','../../%70arent/1.0/parent-1.0.module',
                    '..\\parent.module','../../parent/1.0/parent-1.0.module#x'):
            with self.subTest(url=url):
                self.assertNotEqual(self.analyze(origin(url),descriptor(module='parent'))[
                    'component_origins'][0]['status'],'EXACT_LOCAL_ORIGIN_LINK')

    def test_url_coordinate_mismatch_missing_and_ambiguous_targets(self):
        self.assertEqual(self.analyze(origin('../../other/1.0/other-1.0.module'))[
            'component_origins'][0]['status'],'URL_COORDINATE_MISMATCH')
        self.assertEqual(self.analyze(origin())['component_origins'][0]['status'],
                         'TARGET_DESCRIPTOR_ABSENT')
        parent=descriptor(module='parent');other=descriptor(module='parent', data=json.dumps({
            'formatVersion':'1.1','component':{'group':'example','module':'parent','version':'1.0'},
            'variants':[{'name':'other'}]}).encode())
        self.assertEqual(self.analyze(origin(),parent,other)['component_origins'][0]['status'],
                         'AMBIGUOUS_TARGET_DESCRIPTORS')

    def test_target_with_another_origin_is_not_recursively_rebound(self):
        parent=descriptor(module='parent',data=json.dumps({'formatVersion':'1.1','component':{
            'group':'example','module':'grandparent','version':'1.0',
            'url':'../../grandparent/1.0/grandparent-1.0.module'}}).encode())
        result=self.analyze(origin(),parent)
        self.assertEqual(result['component_origins'][0]['status'],'TARGET_IDENTITY_UNRESOLVED')

    def test_origin_URL_filename_must_match_the_actual_target_descriptor(self):
        row,raw=descriptor(module='parent')
        alias={**row,'name':'unrelated.module','relative_path':row['relative_path'].replace(
            '/parent-1.0.module','/unrelated.module')}
        result=self.analyze(origin(),(alias,raw))
        self.assertEqual(result['component_origins'][0]['status'],'TARGET_DESCRIPTOR_ABSENT')

    def test_duplicate_properties_are_preserved_without_choosing_a_value(self):
        result=self.analyze(pom('<artifactId>child</artifactId><properties><v>one</v><v>two</v>'
            '</properties>'))['poms'][0]
        self.assertEqual(result['property_declarations'],[{'name':'v','value':'one'},{'name':'v','value':'two'}])
        self.assertEqual(result['duplicate_property_names'],['v'])
        self.assertNotIn('v',result['properties'])

    def test_relation_candidate_and_payload_bounds_fail_closed(self):
        with patch.object(declarations,'CANDIDATE_LIMIT',0):
            with self.assertRaises(ValueError):self.analyze(origin(),descriptor(module='parent'))
        root=pom('<artifactId>child</artifactId><dependencies><dependency><groupId>x</groupId>'
            '<artifactId>y</artifactId><version>1</version></dependency></dependencies>')
        with patch.object(declarations,'RELATION_LIMIT',0):
            with self.assertRaises(ValueError):self.analyze(root)
        with patch.object(declarations,'FILE_BYTES',4):
            with self.assertRaises(ValueError):self.analyze(root)

    def test_unknown_module_format_is_not_silently_accepted_as_an_origin(self):
        pair=descriptor(data=json.dumps({'formatVersion':'2.0','component':{
            'group':'example','module':'child','version':'1.0'}}).encode())
        self.assertEqual(self.analyze(pair)['unsupported_module_formats'],[pair[0]['relative_path']])

    def test_pom_dependency_management_and_bom_are_distinct_declarations(self):
        root=pom('<groupId>example</groupId><artifactId>child</artifactId><version>1.0</version>'
            '<dependencyManagement><dependencies><dependency><groupId>example</groupId>'
            '<artifactId>bom</artifactId><version>2.0</version><type>pom</type><scope>import</scope>'
            '</dependency></dependencies></dependencyManagement><dependencies><dependency>'
            '<groupId>example</groupId><artifactId>api</artifactId><version>2.0</version>'
            '<optional>true</optional><scope>provided</scope><classifier>jdk8</classifier>'
            '<exclusions><exclusion><groupId>x</groupId><artifactId>y</artifactId></exclusion>'
            '</exclusions></dependency></dependencies>')
        result=self.analyze(root,pom('<artifactId>bom</artifactId>',module='bom',version='2.0'))
        edges=result['poms'][0]['relations']
        self.assertEqual([e['kind'] for e in edges],['bom_import','dependency'])
        self.assertEqual(edges[0]['status'],'DECLARED_POM_COORDINATE_PRESENT')
        self.assertEqual(edges[1]['declaration']['classifier'],'jdk8')
        self.assertEqual(edges[1]['declaration']['optional'],'true')
        self.assertEqual(edges[1]['exclusions'],[{'groupId':'x','artifactId':'y'}])

    def test_properties_missing_versions_parent_and_profiles_need_effective_model(self):
        root=pom('<parent><groupId>example</groupId><artifactId>parent</artifactId>'
            '<version>1.0</version><relativePath>../../private</relativePath></parent>'
            '<artifactId>child</artifactId><properties><v>2.0</v></properties>'
            '<dependencies><dependency><groupId>example</groupId><artifactId>a</artifactId>'
            '<version>${v}</version></dependency><dependency><groupId>example</groupId>'
            '<artifactId>b</artifactId></dependency></dependencies><profiles><profile><id>x</id>'
            '</profile></profiles>')
        result=self.analyze(root)['poms'][0]
        self.assertEqual(result['coordinate_status'],'NEEDS_EFFECTIVE_MODEL')
        self.assertEqual(result['properties'],{'v':'2.0'})
        self.assertEqual([e['status'] for e in result['relations']],
            ['DECLARED_POM_COORDINATE_ABSENT','NEEDS_EFFECTIVE_MODEL','NEEDS_EFFECTIVE_MODEL'])
        self.assertIn('profiles',result['unevaluated_sections'])
        self.assertEqual(result['relations'][0]['declaration']['relativePath'],'../../private')
        self.assertFalse(result['effective_model_computed'])

    def test_dynamic_and_range_versions_are_not_exact_pom_candidates(self):
        for version in ('latest.release','1.+','[1,2)','${project.version}'):
            root=pom('<artifactId>child</artifactId><dependencies><dependency><groupId>example</groupId>'
                f'<artifactId>a</artifactId><version>{version}</version></dependency></dependencies>')
            self.assertNotEqual(self.analyze(root)['poms'][0]['relations'][0]['status'],
                                'DECLARED_POM_COORDINATE_PRESENT')

    def test_xml_entities_utf16_duplicates_foreign_fields_and_depth_are_rejected(self):
        bad=[b'<!DOCTYPE project [<!ENTITY x "expanded">]><project>&x;</project>',
             '<project><artifactId>child</artifactId></project>'.encode('utf-16'),
             b'<project><artifactId>child</artifactId><artifactId>child</artifactId></project>',
             b'<project xmlns:x="urn:foreign"><x:artifactId>child</x:artifactId></project>',
             ('<project>'+'<x>'*66+'</x>'*66+'</project>').encode()]
        for raw in bad:
            pair=descriptor(suffix='pom',data=raw)
            with self.subTest(raw=raw[:40]),self.assertRaises(ValueError):self.analyze(pair)

    def test_namespace_free_pom_and_utf8_bom_are_supported_without_claiming_selection(self):
        row,raw=pom('<groupId>example</groupId><artifactId>child</artifactId><version>1.0</version>',namespace=False)
        row,raw=descriptor(suffix='pom',data=b'\xef\xbb\xbf'+raw)
        parsed=self.analyze((row,raw))['poms'][0]
        self.assertEqual(parsed['coordinate_status'],'DECLARED_COORDINATE_MATCH')

    def test_payload_hash_path_coordinate_and_duplicate_bindings_fail_closed(self):
        row,raw=pom('<artifactId>child</artifactId>')
        with self.assertRaises(ValueError):
            declarations.analyze_declarations([row],{row['relative_path']:raw+b' '})
        with self.assertRaises(ValueError):self.analyze((row,raw),(row,raw))
        with self.assertRaises(ValueError):self.analyze(({**row,'module':'other'},raw))


if __name__=='__main__':
    unittest.main()
