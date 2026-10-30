import unittest,tempfile
from pathlib import Path
from engine import validate_args,PREFIX
class PolicyTests(unittest.TestCase):
 def test_global_and_foreign_operations_refused(self):
  root=Path(__file__).resolve().parent
  for args in [['image','prune'],['start','other-project'],['stop','other-project'],['exec','other-project','id'],['network','create','other-project'],['system','prune'],['restart',PREFIX+'-api'],['load','--input',str(root.parent/'foreign.tar')]]:
   with self.subTest(args=args),self.assertRaises(ValueError):validate_args(args,root)
 def test_owned_read_and_control_operations_allowed(self):
  root=Path(__file__).resolve().parent
  for args in [['inspect',PREFIX+'-api'],['exec',PREFIX+'-api','php','-v'],['stop','--time','15',PREFIX+'-api'],['start',PREFIX+'-db',PREFIX+'-api'],['image','inspect',PREFIX+'/php:runtime']]:validate_args(args,root)
if __name__=='__main__':unittest.main()
