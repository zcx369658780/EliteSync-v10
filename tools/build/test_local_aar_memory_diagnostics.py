"""Pure fixtures only: never create a Job, execute Main, or invoke an SDK."""
from pathlib import Path
import subprocess
import tempfile
import unittest

HERE = Path(__file__).resolve().parent


class MemoryDiagnosticsTests(unittest.TestCase):
    def test_pure_csharp_fixture(self):
        with tempfile.TemporaryDirectory(prefix='local-aar-memory-fixture-') as directory:
            exe = Path(directory) / 'fixture.exe'
            command = [r'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe',
                       '/nologo', '/warnaserror', '/platform:x64', '/r:System.Web.Extensions.dll',
                       '/main:LocalAarMemoryDiagnosticsTest', '/out:' + str(exe)]
            command += [str(HERE / name) for name in ['local_aar_memory_diagnostics.cs',
                        'local_aar_memory_diagnostics_test.cs', 'local_aar_supervisor.cs',
                        'producer_process_boundary.cs']]
            compiled = subprocess.run(command, capture_output=True, text=True, timeout=60)
            self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
            fixture = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            self.assertEqual(fixture.returncode, 0, fixture.stdout + fixture.stderr)
            self.assertIn('PASS 11 pure memory cases', fixture.stdout)

if __name__ == '__main__':
    unittest.main()
