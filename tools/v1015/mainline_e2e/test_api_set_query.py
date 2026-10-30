import unittest
from contracts import Gate
from api_set_query import validate_query


class SupportedSchemaQuery(unittest.TestCase):
    def setUp(self):self.value=dict(hresult=0,available=True,host='inert.dll',provider_module='kernelbase.dll',provider_owner_matches=True,actual_name_length=10,buffer_capacity=260)
    def test_candidate_alone_is_not_runtime_lookup_proof(self):self.assertEqual('inert.dll',validate_query('inert.dll',self.value))
    def test_failed_supported_lookup_rejected(self):
        self.value['hresult']=-1
        with self.assertRaises(Gate):validate_query('inert.dll',self.value)
    def test_raw_vs_running_schema_disagreement_rejected(self):
        with self.assertRaisesRegex(Gate,'DISAGREE'):validate_query('other.dll',self.value)
    def test_query_from_unqualified_provider_rejected(self):
        self.value['provider_owner_matches']=False
        with self.assertRaisesRegex(Gate,'PROVIDER'):validate_query('inert.dll',self.value)
    def test_query_does_not_allow_host_path(self):
        self.value['host']='../inert.dll'
        with self.assertRaisesRegex(Gate,'PATH'):validate_query('../inert.dll',self.value)

    def test_returned_length_must_match_actual_host(self):
        self.value['actual_name_length']=200
        with self.assertRaisesRegex(Gate,'LENGTH'):validate_query('inert.dll',self.value)

    def test_e_notimpl_cannot_be_promoted_to_host_proof(self):
        self.value.update(hresult=-2147467263,host='',actual_name_length=0,available=False)
        with self.assertRaisesRegex(Gate,'SUPPORTED_QUERY_FAILED'):validate_query('inert.dll',self.value)
