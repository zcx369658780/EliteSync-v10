<?php

declare(strict_types=1);

namespace App\EliteSync\ConversationQualification;

/**
 * Read-only source seam. A provider returns independently sourced identity,
 * connection, read_consent, send_consent, conversation entries (or null).
 * Each entry is {record, evidence: Common SOURCE_EVIDENCE, provenance}.
 * No implementation here establishes authenticated injection or real authority.
 */
interface ConversationQualificationSource
{
    public function readAtUsePoint(array $context): array;
}
