<?php

declare(strict_types=1);

/**
 * AUTH-21: an isolated, repeatable SQLite memory example with fictional refs.
 * It is not a Laravel migration, an authentication writer, or an authority.
 */
function auth21_new_memory_database(): PDO
{
    $db = new PDO('sqlite::memory:', null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    $db->exec('PRAGMA foreign_keys = ON');
    $db->exec(<<<'SQL'
CREATE TABLE fictional_accounts (
    account_ref TEXT PRIMARY KEY CHECK (length(account_ref) > 0),
    enabled INTEGER NOT NULL CHECK (enabled IN (0, 1))
)
SQL);
    $db->exec(<<<'SQL'
CREATE TABLE fictional_login_events (
    event_key TEXT PRIMARY KEY CHECK (length(event_key) > 0),
    account_ref TEXT NOT NULL REFERENCES fictional_accounts(account_ref),
    device_ref TEXT NOT NULL CHECK (length(device_ref) > 0),
    event_kind TEXT NOT NULL CHECK (event_kind = 'INTERACTIVE_LOGIN'),
    event_order INTEGER NOT NULL CHECK (event_order > 0),
    t0_tick INTEGER NOT NULL CHECK (t0_tick >= 0),
    UNIQUE (account_ref, device_ref, event_order)
)
SQL);

    return $db;
}

function auth21_add_fictional_account(PDO $db, string $accountRef, bool $enabled = true): void
{
    if ($accountRef === '') {
        throw new InvalidArgumentException('Empty fictional account ref.');
    }
    $stmt = $db->prepare('INSERT INTO fictional_accounts (account_ref, enabled) VALUES (?, ?)');
    $stmt->execute([$accountRef, $enabled ? 1 : 0]);
}

/**
 * All success/source flags, refs, event order, and ticks are caller claims.
 * The function demonstrates storage constraints only and grants no access.
 *
 * @return 'INSERTED'|'DUPLICATE'|'REJECTED'|'CONFLICT'
 */
function auth21_record_fictional_event(
    PDO $db,
    string $accountRef,
    string $deviceRef,
    string $eventKey,
    string $eventKind,
    bool $callerClaimsAuthenticationSucceeded,
    bool $callerClaimsServerConfirmed,
    int $eventOrder,
    int $t0Tick,
): string {
    if ($accountRef === '' || $deviceRef === '' || $eventKey === ''
        || $eventKind !== 'INTERACTIVE_LOGIN'
        || ! $callerClaimsAuthenticationSucceeded || ! $callerClaimsServerConfirmed
        || $eventOrder <= 0 || $t0Tick < 0) {
        return 'REJECTED';
    }

    $db->beginTransaction();
    try {
        $account = $db->prepare('SELECT enabled FROM fictional_accounts WHERE account_ref = ?');
        $account->execute([$accountRef]);
        if ((int) $account->fetchColumn() !== 1) {
            $db->rollBack();
            return 'REJECTED';
        }

        $sameKey = $db->prepare(
            'SELECT account_ref, device_ref, event_order, t0_tick FROM fictional_login_events WHERE event_key = ?'
        );
        $sameKey->execute([$eventKey]);
        $existing = $sameKey->fetch();
        if ($existing !== false) {
            $sameEvent = $existing['account_ref'] === $accountRef
                && $existing['device_ref'] === $deviceRef
                && (int) $existing['event_order'] === $eventOrder
                && (int) $existing['t0_tick'] === $t0Tick;
            $db->rollBack();
            return $sameEvent ? 'DUPLICATE' : 'CONFLICT';
        }

        $latest = $db->prepare(
            'SELECT event_order, t0_tick FROM fictional_login_events '
            .'WHERE account_ref = ? AND device_ref = ? ORDER BY event_order DESC LIMIT 1'
        );
        $latest->execute([$accountRef, $deviceRef]);
        $anchor = $latest->fetch();
        if ($anchor !== false
            && ($eventOrder <= (int) $anchor['event_order'] || $t0Tick < (int) $anchor['t0_tick'])) {
            $db->rollBack();
            return 'CONFLICT';
        }

        $insert = $db->prepare(
            'INSERT INTO fictional_login_events '
            .'(event_key, account_ref, device_ref, event_kind, event_order, t0_tick) '
            .'VALUES (?, ?, ?, ?, ?, ?)'
        );
        $insert->execute([$eventKey, $accountRef, $deviceRef, $eventKind, $eventOrder, $t0Tick]);
        $db->commit();
        return 'INSERTED';
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $error;
    }
}

/** @return array{status: 'UNKNOWN'}|array{status: 'KNOWN', event_order: int, t0_tick: int} */
function auth21_fictional_anchor(PDO $db, string $accountRef, string $deviceRef): array
{
    $query = $db->prepare(
        'SELECT event_order, t0_tick FROM fictional_login_events '
        .'WHERE account_ref = ? AND device_ref = ? ORDER BY event_order DESC LIMIT 1'
    );
    $query->execute([$accountRef, $deviceRef]);
    $row = $query->fetch();
    if ($row === false) {
        return ['status' => 'UNKNOWN'];
    }

    return [
        'status' => 'KNOWN',
        'event_order' => (int) $row['event_order'],
        't0_tick' => (int) $row['t0_tick'],
    ];
}

function auth21_fictional_event_count(PDO $db): int
{
    return (int) $db->query('SELECT COUNT(*) FROM fictional_login_events')->fetchColumn();
}
