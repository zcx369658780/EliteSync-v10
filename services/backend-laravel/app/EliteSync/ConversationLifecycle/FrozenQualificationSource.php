<?php
declare(strict_types=1);
namespace App\EliteSync\ConversationLifecycle;
use App\EliteSync\ConversationQualification\ConversationQualificationSource;
/** Internal immutable candidate view for pure contract checking; never a trusted issuer. */
final class FrozenQualificationSource implements ConversationQualificationSource
{
    public function __construct(private readonly array $bundle) {}
    public function readAtUsePoint(array $context): array { return $this->bundle; }
}
