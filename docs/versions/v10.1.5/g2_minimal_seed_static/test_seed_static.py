"""Small in-memory XML/JSON fixtures only. Never resolves or starts Gradle."""
import unittest
from seed_static import *
def pom(body=''):return '<project><modelVersion>4.0.0</modelVersion>'+body+'</project>'
def dep(g='g',a='b',v='1',extra=''):return '<dependency><groupId>'+g+'</groupId><artifactId>'+a+'</artifactId>'+('<version>'+v+'</version>' if v else '')+extra+'</dependency>'
def parse(model):return envelope(['g:a:1'],model,{},set(model))
class Seed(unittest.TestCase):
    def test_literal_transitive_edge(self):
        r=parse({'g:a:1':pom('<dependencies>'+dep()+'</dependencies>'),'g:b:1':pom()});self.assertEqual(r['nodes'],['g:a:1','g:b:1'])
    def test_missing_marker(self):self.assertIn('PLUGIN_MARKER_MISSING',[x['code'] for x in envelope(['p:p.gradle.plugin:1'],{}, {},set())['issues']])
    def test_missing_parent(self):
        r=parse({'g:a:1':pom('<parent><groupId>p</groupId><artifactId>parent</artifactId><version>1</version></parent>')});self.assertTrue(any(x['code']=='POM_MISSING' for x in r['issues']))
    def test_missing_bom(self):
        r=parse({'g:a:1':pom('<dependencyManagement><dependencies>'+dep('g','bom','1','<type>pom</type><scope>import</scope>')+'</dependencies></dependencyManagement>')});self.assertTrue(any(x['code']=='BOM_UNRESOLVED' for x in r['issues']))
    def test_bom_managed_version(self):
        models={'g:a:1':pom('<dependencyManagement><dependencies>'+dep('g','bom','1','<type>pom</type><scope>import</scope>')+'</dependencies></dependencyManagement><dependencies>'+dep(v='')+'</dependencies>'),'g:bom:1':pom('<dependencyManagement><dependencies>'+dep(v='2')+'</dependencies></dependencyManagement>'),'g:b:2':pom()};self.assertIn('g:b:2',parse(models)['nodes'])
    def test_cycle(self):
        a='<parent><groupId>g</groupId><artifactId>b</artifactId><version>1</version></parent>';b='<parent><groupId>g</groupId><artifactId>a</artifactId><version>1</version></parent>';r=parse({'g:a:1':pom(a),'g:b:1':pom(b)});self.assertTrue(any(x['code']=='POM_PARENT_OR_BOM_CYCLE' for x in r['issues']))
    def test_classifier_uncertain(self):
        r=parse({'g:a:1':pom('<dependencies>'+dep(extra='<classifier>special</classifier>')+'</dependencies>'),'g:b:1':pom()});self.assertTrue(any(x['code']=='CLASSIFIER_SELECTION_REQUIRED' for x in r['issues']))
    def test_variant_not_silently_selected(self):
        _,issues=module_edges('g:a:1',{'variants':[{'name':'api'},{'name':'runtime'}]});self.assertEqual(issues[0]['code'],'GRADLE_VARIANT_SELECTION_NOT_EMULATED')
    def test_constraints_do_not_add_dependencies(self):
        r=envelope(['g:a:1'],{'g:a:1':pom()},{'g:a:1':{'variants':[{'name':'api','dependencyConstraints':[{'group':'g','module':'b','version':{'requires':'1'}}]}]}},{'g:a:1'});self.assertNotIn('g:b:1',r['nodes'])
    def test_rich_versions_keep_both_declarations(self):
        edges,issues=module_edges('g:a:1',{'variants':[{'name':'runtime','dependencies':[{'group':'g','module':'b','version':{'requires':'2','prefers':'1'}}]}]});self.assertEqual({x['to'] for x in edges},{'g:b:1','g:b:2'});self.assertTrue(issues)
    def test_parent_preexpanded_dependency_not_claimed_as_child_edge(self):
        models={'g:p:1':pom('<properties><v>1</v></properties><dependencies>'+dep(v='${v}')+'</dependencies>'),'g:a:1':pom('<parent><groupId>g</groupId><artifactId>p</artifactId><version>1</version></parent><properties><v>2</v></properties>'),'g:b:1':pom()};r=parse(models);self.assertFalse(any(e['fromNode']=='g:a:1' and e['to']=='g:b:1' for e in r['edges']));self.assertTrue(any(i['code']=='EFFECTIVE_PARENT_MODEL_NOT_GRADLE_RESOLVED' for i in r['issues']))
    def test_duplicate_module_must_match(self):
        c={};unique_module(c,'g:a:1',{'variants':[]});unique_module(c,'g:a:1',{'variants':[]})
        with self.assertRaises(ValueError):unique_module(c,'g:a:1',{'variants':[{'name':'other'}]})
    def test_transitive_gap(self):self.assertTrue(any(x['code']=='COMPONENT_CONTENT_NOT_CACHED' for x in parse({'g:a:1':pom('<dependencies>'+dep()+'</dependencies>')})['issues']))
    def test_conflict_not_resolved_by_highest_guess(self):
        r=parse({'g:a:1':pom('<dependencies>'+dep(v='1')+dep(v='2',extra='<classifier>x</classifier>')+'</dependencies>'),'g:b:1':pom(),'g:b:2':pom()});self.assertTrue(any(x['code']=='MULTI_VERSION_WINNER_NOT_PROVEN' for x in r['issues']))
    def test_profile_unknown(self):self.assertTrue(any(x['code']=='MAVEN_PROFILE_ACTIVATION_UNKNOWN' for x in parse({'g:a:1':pom('<profiles/>')})['issues']))
    def test_dynamic_version_unknown(self):self.assertFalse(fixed('[1,2)'))
    def test_unresolved_property_unknown(self):self.assertFalse(fixed('${x}'))
    def test_entity_forbidden(self):
        with self.assertRaises(ValueError):PomModels(lambda _: '<!DOCTYPE x><project/>').model('g:a:1')
    def check(self,**kw):return decision([],indexes_complete=kw.get('indexes',True),logical_bytes=kw.get('logical',10),peak_bytes=kw.get('peak',20),ro_layout=kw.get('ro',True),hashes_match=kw.get('hash',True),redirected=kw.get('redirect',False))
    def test_index_missing(self):self.assertIn('CACHE_INDEX_CLOSURE_UNKNOWN',self.check(indexes=False)['issues'])
    def test_ro_fallback(self):self.assertIn('RO_LAYER_FALLBACK_FORBIDDEN',self.check(ro=False)['issues'])
    def test_hash_drift(self):self.assertIn('SHA_DRIFT',self.check(hash=False)['issues'])
    def test_redirect(self):self.assertIn('PATH_REDIRECTION',self.check(redirect=True)['issues'])
    def test_disk_cap(self):self.assertIn('LOGICAL_CAP_EXCEEDED',self.check(logical=CAP+1)['issues'])
    def test_peak_cap(self):self.assertIn('PEAK_CAP_EXCEEDED',self.check(peak=CAP+1)['issues'])
    def test_small_fixture_is_not_runtime_release(self):self.assertFalse(self.check()['G2_READY_FOR_POPEN'])
if __name__=='__main__':unittest.main(verbosity=2)
