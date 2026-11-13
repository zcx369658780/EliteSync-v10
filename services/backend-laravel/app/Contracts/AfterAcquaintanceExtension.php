<?php

namespace App\Contracts;

/**
 * Future application-layer availability boundary for participant-scoped features.
 * v10.1.6 defines this contract with no implementation or container binding.
 */
interface AfterAcquaintanceExtension
{
    public const CAPABILITIES = ['icebreaker', 'meetup', 'shared_plan', 'anniversary'];

    public const IMPLEMENTED = false;

    public const STATUS = 'unavailable';

    /**
     * Future callers derive actorId from the authenticated session. Implementations
     * must recheck the participants' current legitimate relationship context and
     * independent purpose authorization before reporting availability. Friendship,
     * Connection and formal relationship states do not grant these purposes.
     *
     * The version constants describe the current unimplemented state. A future
     * implementation must establish its own actual readiness before enabling use.
     *
     * @param 'icebreaker'|'meetup'|'shared_plan'|'anniversary' $capability
     * @return array{implemented: bool, status: 'available'|'unavailable', reason_code: string}
     */
    public function availability(string $capability, int $actorId, int $peerId): array;
}
