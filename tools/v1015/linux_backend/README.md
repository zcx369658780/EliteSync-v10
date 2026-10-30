# Linux backend migration prepackage

This is a source-only artifact for the Owner-authorized task
`03c40a831ed37d8610c9a9aa2760c9a94e17269b`, parent `89413238`.
It is **not** a qualified Linux runtime or a replacement for the Windows
native qualification tools. The registered WSL2 Ubuntu distribution is stopped;
the explicitly selected local Docker pipe was unavailable. No engine or distro
was activated. The dynamic phase is STOPPED.

## What is executable here

`python prepackage.py` inspects its own capability without writing or launching
anything. `inspect --source-root <fixed backend source>` reads source and emits a
JSON inventory. `prepackage --source-root <task source> --task-root <task root>`
emits three source-only files with an original-task ledger PREPARE+fsync, strict
task/parent/workspace binding, exclusive output creation and byte readback.
`execute` always refuses before any process/network activity. A receipt or JSON
boolean cannot enable it. There is no subprocess, shell, socket or container API.

The two `composer-*.input.json` files are **solver inputs**, not Composer locks
or installed manifests. The primary proposes PHP `~8.4.0`, Laravel `^13.0`,
Tinker `^3.0`, PHPUnit `^12.0` and Collision `^8.6`. The fallback proposes
Laravel12/PHP8.4 with the existing Tinker2/PHPUnit11 constraints. Both disable
scripts/plugins and preserve every other direct requirement and autoload mapping.
They are emitted outside the backend; active composer.json and the Laravel11 lock
stay unchanged. A real future solver must decide every direct/transitive version,
including Sanctum, Workerman, lunar-php and all dev tools. No `config.platform`
override or `--ignore-platform-reqs` is used to impersonate installed extensions.

Official basis (read during this task):

- https://laravel.com/framework/docs/13.x/upgrade
- https://laravel.com/framework/docs/12.x/upgrade
- https://github.com/laravel/laravel/blob/13.x/composer.json
- https://github.com/laravel/framework/blob/13.x/composer.json
- https://github.com/laravel/sanctum/blob/4.x/composer.json

Mutable branch metadata is documentation, not an artifact/version lock.
The inventory records all 114 packages from the original lock as **old-lock
evidence only**, including their complete require/conflict/source/dist/license
fields. It makes no claim that this is a valid Laravel12/13 dependency graph.

## Required later runtime adapter

A later Owner-authorized task needs an already running, legally usable local
Linux OCI executor, real distro/architecture and engine identity, task-private
write roots/UIDs, and qualified immutable image references. Each image must be
pinned by the actual registry digest and platform; no digest is supplied or
invented here. Docker client version is not a server or Desktop license receipt.
Ubuntu-24.04 registration is not proof of `/etc/os-release` or ABI compatibility.
Official PHP images may have Debian/Alpine userlands: never label these Ubuntu24.04
without an explicit compatibility assessment. Composer2 and MariaDB10.11 LTS
remain unresolved patch/digest targets. Redis/Nginx are not needed for the proposed
initial synchronous/file-cache API test group; queue/WS claims remain untested.

The future adapter must enforce all the following before issuing any command:

- One root/attempt/ledger; count failed pulls/builds/starts/retries; monotonic and
  network response-byte/request accounting before costs. The Docker client alone
  does not provide a complete redirect/layer/Composer request counter.
- Separate controlled supply from offline business runtime. No host network,
  privileged containers, Docker socket mount, shared/old volume, host-global
  install/cache, real credential or production connection. Code inputs read-only;
  writable source staging, vendor, cache, storage, datadir and logs task-owned.
- Empty synthetic MariaDB10.11 instance; minimal actor; APP_DB_CONNECTION and all
  APP_DB_* and DB_* selectors agree. No URL/socket fallback or SQLite substitution.
  New loopback ports must be checked then frozen once; historical 43349/43359 and
  occupied ports are forbidden. The blueprint's null ports are not reservations.
- Real Composer `validate`, `update --with-all-dependencies --no-install` and one
  controlled `install`, always `--no-scripts --no-plugins --no-interaction`, with
  no global cache or platform-req bypass. Lock/source/vendor identities must be
  rebound together after the actual solver; do not edit content-hash by hand.
- Existing TestCase.php intentionally protects SQLite-only generic tests. Real
  MariaDB Feature needs its separately qualified existing test entry; never delete
  or weaken this guard. Preserve all negative auth/consent/block/token assertions.
- Record real HTTP status/counts/transactions and service restart persistence.
  Existing Windows `MainlineEnvironment.php` and native loader are not a Linux
  authorization grant: implement a separate Linux source/instance/receipt profile
  rather than weakening their Windows process/signature gate.

The current task has no runtime adapter and no runtime proof. A generated plan,
Python test or documentation is not PHP/Composer/Laravel/MariaDB execution.

## Static tests

`python -m unittest discover -s tools/v1015/linux_backend -p 'test_*.py'`
uses only synthetic inputs and task-private temporary files. During test methods
the listed Popen/connect/create_connection/system/startfile entrypoints are denied;
this is not an all-syscall or import-time isolation claim. Tests check exact
transforms, old lock identification, persistent
write authority, duplicate packages, broken bindings and irrevocable execute STOP.
The writer rechecks STOP, window, root and original ledger identity under a
Windows handle denying concurrent write/delete, held through PREPARE and output.
POSIX flock is cooperative; it is not claimed as a noncooperating-writer barrier.
PHP Feature source delivered with the session compatibility pin is NOT_RUN here.
It tests synthetic serialized fields and the configured array-store name; it does
not establish real HTTP-cookie, authenticated-session continuity or login safety.
