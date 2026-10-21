"""One exact MariaDB user PRIMARY wait, committed family revocation, old reader denial."""
import json
import subprocess
import time
from pathlib import Path
from journey import login

php = 'C:/tools/php85/php.exe'
script = str(Path(__file__).with_name('rr.php'))
account = login(1, 'v1015-rr-device')
writer = subprocess.Popen([php, script, 'writer'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
reader = None
try:
    writer.stdin.write(json.dumps({'session_id':account['session_id']})+'\n'); writer.stdin.flush()
    writer_identity = json.loads(writer.stdout.readline())
    locked = json.loads(writer.stdout.readline())
    assert locked['writer_locked']
    reader = subprocess.Popen([php, script, 'reader'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    reader.stdin.write(json.dumps({'token':account['access_token']})+'\n'); reader.stdin.close()
    reader_identity = json.loads(reader.stdout.readline())
    started = json.loads(reader.stdout.readline())
    wait = None
    for _ in range(20):
        probe = subprocess.run([php,script,'probe'],capture_output=True,text=True,timeout=10)
        assert probe.returncode == 0
        waits = json.loads(probe.stdout.strip().splitlines()[-1])['waits']
        for row in waits:
            if int(row['reader_id']) == started['reader_started'] and int(row['writer_id']) == locked['writer_locked'] and row['lock_index'] == 'PRIMARY' and row['lock_table'].endswith('`users`'):
                wait = row
        if wait: break
        time.sleep(.15)
    assert wait, 'EXACT_READER_WRITER_USERS_PRIMARY_WAIT_NOT_OBSERVED'
    writer.stdin.write('COMMIT_REVOKE\n'); writer.stdin.flush(); writer.stdin.close()
    committed = json.loads(writer.stdout.readline())
    finished = json.loads(reader.stdout.readline())
    wexit, rexit = writer.wait(timeout=15), reader.wait(timeout=15)
    assert wexit == rexit == 0
    assert committed['time'] <= finished['time'] and finished['status'] == 401 and finished['private_body_absent']
    print(json.dumps({'result':'PASS','isolation':writer_identity['identity']['isolation_level'], 'locked':locked,'reader':started,'exact_wait':wait,'commit':committed,'denied':finished,'writer_exit':wexit,'reader_exit':rexit},indent=2))
finally:
    for process in (reader,writer):
        if process is not None and process.poll() is None:
            process.kill(); process.wait()
