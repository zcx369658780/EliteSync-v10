"""Bounded native MariaDB concurrency observations on an already-owned task backend.

No service start, migration, grant, isolation change, phone, or fixture deletion.
Credentials/configs and all raw results must stay LOCAL_ONLY.
"""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import subprocess
import time
import uuid

from protocol import EFFECT_FIELDS, validate_duplicate, validate_revocation

WAIT_SQL = (
    'SELECT r.trx_mysql_thread_id,b.trx_mysql_thread_id,l.lock_table,l.lock_index,l.lock_data '
    'FROM information_schema.INNODB_LOCK_WAITS w '
    'JOIN information_schema.INNODB_TRX r ON r.trx_id=w.requesting_trx_id '
    'JOIN information_schema.INNODB_TRX b ON b.trx_id=w.blocking_trx_id '
    'JOIN information_schema.INNODB_LOCKS l ON l.lock_id=w.requested_lock_id'
)
# Fixed shell text only: the instance's own root password stays in its existing
# environment, never a command argument, config output, or observer result.
OBSERVER_COMMAND = ('MYSQL_PWD="$MARIADB_ROOT_PASSWORD" exec mariadb --protocol=socket '
                    '-u root --batch --raw --skip-column-names -e \'' + WAIT_SQL + "'")


def write(path: pathlib.Path, value) -> None:
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def read(path):
    return json.loads(path.read_bytes())


def persisted_state(snapshot):
    """Compare business evidence, not independent observer clocks/connections."""
    return {field: snapshot[field] for field in (*EFFECT_FIELDS, 'cn_state', 'mc_states')}


def publish_stop(path, value):
    """Publish complete JSON atomically, without replacing an existing STOP."""
    temporary = path.with_name(path.name + '.tmp-' + uuid.uuid4().hex)
    try:
        write(temporary, value)
        try:
            os.link(temporary, path)
        except FileExistsError:
            return False
        return True
    finally:
        temporary.unlink(missing_ok=True)


def abort_probe(stop, output, processes, original_error):
    deadline = time.monotonic() + 45
    # The owning driver can retain the same deadline even if STOP publication
    # itself fails. One failed evidence write must never skip later teardown.
    original_error.probe_cleanup_deadline_monotonic = deadline
    errors = []
    try:
        publish_stop(stop, dict(reason='Messaging concurrency probe stopped',
            cleanup_deadline_monotonic=deadline))
    except BaseException as error:
        errors.append('stop publication: ' + repr(error))
    for case in ('duplicate', 'revocation'):
        folder = output / case
        try:
            if folder.exists() and not (folder / 'cancel').exists():
                with (folder / 'cancel').open('x', encoding='ascii') as stream:
                    stream.write('stop\n')
        except BaseException as error:
            errors.append('worker cancellation: ' + repr(error))
    for proc in processes:
        try:
            if proc.poll() is None:
                proc.terminate()
        except BaseException as error:
            errors.append('client termination: ' + repr(error))
    for note in errors:
        original_error.add_note(note)
    return errors


def run_probe(config_path: pathlib.Path) -> dict:
    cfg = read(config_path)
    if not re.fullmatch(r'V1015_MSG_CONCURRENCY_[0-9]{8}_[0-9]{2}', cfg['task_id']):
        raise ValueError('Explicit messaging concurrency scope required')
    if not all(re.fullmatch(r'[a-f0-9]{64}', cfg[key]) for key in ('api_container_id', 'db_container_id')):
        raise ValueError('Held immutable container IDs required')
    docker = [cfg['docker_exe'], '--context', 'desktop-linux']
    for key in ('api_container_id', 'db_container_id'):
        q = subprocess.run(docker + ['inspect', '--format', '{{json .}}', cfg[key]],
                           capture_output=True, timeout=10, check=True)
        item = json.loads(q.stdout)
        if item['Config']['Labels'].get('elitesync.task') != cfg['task_id'] or not item['State']['Running']:
            raise ValueError('Only active containers owned by this task are allowed')
    output = pathlib.Path(cfg['host_output_dir'])
    output.mkdir(parents=True, exist_ok=False)
    processes: list[subprocess.Popen] = []
    streams = []
    summary = {}

    def start(mode, label, case):
        if pathlib.Path(cfg['stop_request']).exists() or pathlib.Path(cfg['backend_outcome']).exists():
            raise RuntimeError('Owned backend already stopping or terminal')
        folder = output / case
        stdout = (folder / (label + '.stdout')).open('xb')
        stderr = (folder / (label + '.stderr')).open('xb')
        streams.extend([stdout, stderr])
        proc = subprocess.Popen(docker + ['exec', cfg['api_container_id'], 'php',
            '/task/messaging-worker.php', mode, label, case, cfg['container_config']],
            stdout=stdout, stderr=stderr)
        processes.append(proc)
        return proc

    def wait(folder, label, event, proc, seconds=40):
        deadline = time.monotonic() + seconds
        path = folder / (label + '.' + event + '.json')
        while time.monotonic() < deadline:
            if path.exists():
                return read(path)
            if proc.poll() is not None:
                raise RuntimeError(f'{label} exited {proc.returncode} before {event}')
            time.sleep(.03)
        raise TimeoutError(f'{label} did not publish {event}')

    def finish(folder, label, proc):
        result = wait(folder, label, 'done', proc)
        if proc.wait(timeout=5) != 0:
            raise RuntimeError(f'{label} nonzero exit')
        return result

    def snapshot(case, label):
        folder = output / case
        return finish(folder, label, start('snapshot', label, case))

    def waits(folder, expected_ids, holder_id):
        deadline = time.monotonic() + 25
        observations = []
        while time.monotonic() < deadline:
            q = subprocess.run(docker + ['exec', cfg['db_container_id'], 'sh', '-c', OBSERVER_COMMAND],
                               capture_output=True, timeout=10)
            if q.returncode:
                (folder / 'observer.stderr').write_bytes(q.stderr)
                raise RuntimeError('Independent lock observer failed')
            rows = []
            for line in q.stdout.decode('utf-8').splitlines():
                waiting, blocking, table, index, data = line.split('\t')
                rows.append(dict(waiting_connection=int(waiting), blocking_connection=int(blocking),
                                 table=table, index=index, lock_data=data))
            observations.append(dict(host_monotonic_ns=time.monotonic_ns(), rows=rows))
            matched = {row['waiting_connection'] for row in rows
                if row['blocking_connection'] == holder_id
                and row['table'] == f"`{cfg['database']}`.`users`"
                and row['index'] == 'PRIMARY' and row['lock_data'] == str(min(cfg['participants']))}
            if set(expected_ids) <= matched:
                write(folder / 'independent-lock-waits.json', dict(observations=observations,
                    expected_request_connections=expected_ids, holder_connection=holder_id,
                    observer='Independent new-instance root client; existing permissions, SELECT only'))
                return rows
            if any(p.poll() is not None for p in active_requests):
                raise RuntimeError('Request finished before exact server lock-wait witness')
            time.sleep(.1)
        write(folder / 'independent-lock-waits-timeout.json', observations)
        raise TimeoutError('No exact request->holder qualified users PRIMARY waits')

    try:
        for case in ('duplicate', 'revocation'):
            folder = output / case
            folder.mkdir()
            before = snapshot(case, 'snapshot-before')
            holder = start('hold', 'holder', case)
            held = wait(folder, 'holder', 'held', holder)
            active_requests = [start('request', label, case) for label in ('request-a', 'request-b')]
            request_ids = []
            for label, proc in zip(('request-a', 'request-b'), active_requests):
                request_ids.append(wait(folder, label, 'started', proc)['connection_id'])
                wait(folder, label, 'lock-attempt', proc)
            server_waits = waits(folder, request_ids, held['connection_id'])
            # Publish the release only after the independent database witness.
            with (folder / 'allow-release').open('x', encoding='ascii') as stream:
                stream.write('exact waits observed\n')
            revoker_result = finish(folder, 'holder', holder)
            replies = [finish(folder, label, proc) for label, proc in zip(('request-a', 'request-b'), active_requests)]
            for label in ('request-a', 'request-b'):
                acquired = read(folder / (label + '.lock-acquired.json'))
                if acquired['connection_id'] not in request_ids:
                    raise ValueError('Lock handoff identity mismatch')
            after = snapshot(case, 'snapshot-after')
            args = (before, after, replies, server_waits, held['connection_id'], request_ids,
                    cfg['database'], min(cfg['participants']))
            if case == 'duplicate':
                decision = validate_duplicate(*args, cfg['client_message_id'])
                positive = finish(folder, 'positive-read', start('request', 'positive-read', case))
                if positive['status'] != 200 or not positive['private_marker_present'] or positive['transaction_level'] != 0:
                    raise ValueError('Authorized message history positive control failed')
            else:
                decision = validate_revocation(*args, revoker_result)
                replay = finish(folder, 'old-key-replay', start('request', 'old-key-replay', case))
                if replay['status'] != 404 or replay['private_marker_present'] or replay['transaction_level'] != 0:
                    raise ValueError('Committed revoke must deny same-key replay')
                if persisted_state(snapshot(case, 'snapshot-after-replay')) != persisted_state(after):
                    raise ValueError('Denied old-key replay changed tracked effects')
            write(folder / 'validated-result.json', decision)
            summary[case] = decision
        write(output / 'summary-private.json', dict(status='PASS', cases=summary,
            scope='Backend HTTP-kernel/MariaDB only; no APP/WS/cache concurrency acceptance',
            commit_order='Exact DB lock wait and handoff; post-commit ACK may follow resumed request'))
        return summary
    except BaseException as error:
        # Share the caller/backend controller's45s deadline, including client
        # teardown. Owned backend shutdown ultimately terminates worker children.
        abort_probe(pathlib.Path(cfg['stop_request']), output, processes, error)
        raise
    finally:
        for stream in streams:
            stream.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=pathlib.Path, required=True)
    run_probe(parser.parse_args().config)
