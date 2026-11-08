# v10.1.5 private-image lifecycle evidence helpers

These helpers support a separately authorized, bounded real Laravel/MariaDB
probe. They do not start services, migrate/seed a database, install dependencies,
access devices, grant authority, or make full AC04/G2 acceptance decisions.

The caller must bind a new task-owned backend, fictional accounts, immutable
source/config hashes, private storage and a one-shot claim. A current ready
record and absence of STOP/terminal outcome are required for every HTTP request.
Use only the exact task loopback origin; do not follow redirects or send bearer
credentials to a returned arbitrary URL. Keep configs, response bodies, SQL and
tokens LOCAL_ONLY. The caller's held-ID controller owns the shared45s cleanup.

`fixture_png()` creates deterministic32x32 synthetic RGB PNG bytes. The multipart
helper sends those actual bytes; `validate_media_bytes` requires exact full200 or
Range206 bytes, content length/range/MIME and private/no-store/security headers.
The denial validator rejects500, non-JSON bodies, media bytes and success/private
asset pointers. Pure checks validate rejection logic, not real media delivery.

The intended image scope is real upload -> ready private asset -> one message
and attachment -> real persistent DB/hash binding -> authorized history and
full/Range reads -> same-key replay/conflict/foreign-asset rejection -> real MC
revoke -> old full/Range URL and message replay denial without tracked effects.
Malformed image/video uploads must not create fake-ready assets. No storage fake,
HTTP kernel substitution or simulated video verifier is acceptable as runtime
proof. This scope does not include restart, APP picker/rendering, image decoding
on a phone, or complete concurrent media revocation acceptance.

Private short-video positive validation requires an existing qualified ffprobe
and real MP4/H.264 fixture. Without those dependencies it remains NOT_RUN; an
invalid-video422 is only negative input-validation evidence. Do not download,
install or accept licenses automatically to fill that gap.

Pure checks, no backend/device execution:

```powershell
python -B -m unittest discover -s tools/acceptance/v1015_private_media -p 'test_*.py' -v
```

Never reset old claims/STOPs or reuse consumed allowances. A passing backend
subset does not close AC04, AC03, G2, whole-version acceptance or publication.
