"""Pure validation/reservation data for an independently authorized diagnostic.

This module does not verify the Owner message, files, persistent claims, commands,
or runtime eligibility. The caller retains those responsibilities.
"""
from copy import deepcopy
import re


TASK = 'v1015-current-product-config-20261101'
MAX_ATTEMPTS = 3
_LEDGER_FIELDS = {'schema', 'task', 'owner_authorized', 'max_attempts',
                  'legacy_claims_reused', 'G2', 'reservations'}
_RESERVATION_FIELDS = {'attempt', 'manifest_sha256', 'command_sha256', 'refundable'}
_SHA256 = re.compile(r'[0-9a-f]{64}')


def _fields(value, expected, label):
    if (type(value) is not dict or any(type(key) is not str for key in value)
            or set(value) != expected):
        raise ValueError('Unexpected or missing ' + label + ' fields')


def _hash(value):
    if type(value) is not str or _SHA256.fullmatch(value) is None:
        raise ValueError('A lowercase 64-hex SHA256 identity is required')


def validate_ledger(ledger):
    """Validate only data consistency, without attesting authority or storage."""
    _fields(ledger, _LEDGER_FIELDS, 'ledger')
    if type(ledger['schema']) is not int or ledger['schema'] != 1:
        raise ValueError('Unknown ledger schema')
    if type(ledger['task']) is not str or ledger['task'] != TASK:
        raise ValueError('Wrong diagnostic task')
    if ledger['owner_authorized'] is not True:
        raise ValueError('An explicit authorization declaration is required')
    if type(ledger['max_attempts']) is not int or ledger['max_attempts'] != MAX_ATTEMPTS:
        raise ValueError('The fixed diagnostic limit cannot be changed')
    if ledger['legacy_claims_reused'] is not False or ledger['G2'] is not False:
        raise ValueError('Legacy claims and G2 are outside this diagnostic')
    reservations = ledger['reservations']
    if type(reservations) is not list or len(reservations) > MAX_ATTEMPTS:
        raise ValueError('Invalid reservation list or exhausted limit')
    identities = set()
    for number, reservation in enumerate(reservations, 1):
        _fields(reservation, _RESERVATION_FIELDS, 'reservation')
        if type(reservation['attempt']) is not int or reservation['attempt'] != number:
            raise ValueError('Attempts must be consecutive integers starting at one')
        if reservation['refundable'] is not False:
            raise ValueError('Reservations are not refundable')
        _hash(reservation['manifest_sha256'])
        _hash(reservation['command_sha256'])
        identity = (reservation['manifest_sha256'], reservation['command_sha256'])
        if identity in identities:
            raise ValueError('An unchanged manifest/command pair cannot be retried')
        identities.add(identity)


def next_reservation(ledger, *, manifest_sha256, command_sha256):
    """Return a deep-copied ledger with one reservation; never mutate input."""
    validate_ledger(ledger)
    _hash(manifest_sha256)
    _hash(command_sha256)
    if len(ledger['reservations']) >= MAX_ATTEMPTS:
        raise ValueError('All three diagnostic attempts are reserved')
    identity = (manifest_sha256, command_sha256)
    if any((row['manifest_sha256'], row['command_sha256']) == identity
           for row in ledger['reservations']):
        raise ValueError('An unchanged manifest/command pair cannot be retried')
    result = deepcopy(ledger)
    result['reservations'].append({'attempt': len(result['reservations']) + 1,
        'manifest_sha256': manifest_sha256, 'command_sha256': command_sha256,
        'refundable': False})
    validate_ledger(result)
    return result
