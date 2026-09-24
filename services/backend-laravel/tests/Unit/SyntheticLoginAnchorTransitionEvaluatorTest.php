<?php

namespace Tests\Unit;

use App\Domain\SyntheticLoginAnchorTransitionEvaluator as Evaluator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class SyntheticLoginAnchorTransitionEvaluatorTest extends TestCase
{
    public function testFirstConfirmedInteractiveLoginFormsOnlyASyntheticCandidate(): void
    {
        $result = Evaluator::evaluate(null, $this->event(), $this->context());

        self::assertTrue($result['can_form_candidate']);
        self::assertSame('INTERACTIVE_LOGIN_CANDIDATE', $result['reason']);
        self::assertSame($this->anchor(), $result['proposed_anchor']);
        $this->assertNoGrant($result);
    }

    public function testStrictlyNewerConfirmedEventCanAdvanceTheSameAnchor(): void
    {
        $newer = $this->event(['sequence' => 8, 't0_epoch_seconds' => 2000]);
        $result = Evaluator::evaluate($this->anchor(), $newer, $this->context());

        self::assertTrue($result['can_form_candidate']);
        self::assertSame(8, $result['proposed_anchor']['sequence']);
        self::assertSame(2000, $result['proposed_anchor']['t0_epoch_seconds']);
        $this->assertNoGrant($result);
    }

    #[DataProvider('nonInteractiveKinds')]
    public function testNonInteractiveEventsNeverReanchor(string $kind): void
    {
        $result = Evaluator::evaluate(
            $this->anchor(),
            $this->event(['kind' => $kind, 'sequence' => 8, 't0_epoch_seconds' => 2000]),
            $this->context(),
        );

        self::assertFalse($result['can_form_candidate']);
        self::assertSame('NON_INTERACTIVE_EVENT', $result['reason']);
        self::assertSame($this->anchor(), $result['proposed_anchor']);
        $this->assertNoGrant($result);
    }

    /** @return iterable<string, array{string}> */
    public static function nonInteractiveKinds(): iterable
    {
        yield 'refresh' => ['REFRESH'];
        yield 'register' => ['REGISTER'];
        yield 'restore' => ['RESTORE'];
        yield 'token rotation' => ['TOKEN_ROTATION'];
        yield 'unknown' => ['UNKNOWN'];
    }

    public function testNonInteractiveEventCannotCreateFirstAnchor(): void
    {
        $result = Evaluator::evaluate(null, $this->event(['kind' => 'REFRESH']), $this->context());

        self::assertFalse($result['can_form_candidate']);
        self::assertNull($result['proposed_anchor']);
        $this->assertNoGrant($result);
    }

    public function testReplayAndOutOfOrderEventsKeepCurrentAnchor(): void
    {
        foreach ([
            ['sequence' => 7, 'reason' => 'REPLAYED_EVENT'],
            ['sequence' => 6, 'reason' => 'OUT_OF_ORDER_EVENT'],
        ] as $case) {
            $result = Evaluator::evaluate(
                $this->anchor(),
                $this->event(['sequence' => $case['sequence'], 't0_epoch_seconds' => 2000]),
                $this->context(),
            );

            self::assertFalse($result['can_form_candidate']);
            self::assertSame($case['reason'], $result['reason']);
            self::assertSame($this->anchor(), $result['proposed_anchor']);
            $this->assertNoGrant($result);
        }
    }

    public function testCrossAccountOrDeviceEventIsRejected(): void
    {
        foreach (['account_id' => 'other-account', 'device_id' => 'other-device'] as $field => $wrong) {
            $result = Evaluator::evaluate(
                $this->anchor(),
                $this->event([$field => $wrong, 'sequence' => 8]),
                $this->context(),
            );

            self::assertFalse($result['can_form_candidate']);
            self::assertSame('IDENTITY_MISMATCH', $result['reason']);
            self::assertSame($this->anchor(), $result['proposed_anchor']);
            $this->assertNoGrant($result);
        }
    }

    public function testMissingOrInvalidClaimsFailClosed(): void
    {
        $cases = [
            [$this->event(['source_confirmed' => false]), 'SOURCE_NOT_CONFIRMED'],
            [$this->event(['source_confirmed' => null]), 'SOURCE_NOT_CONFIRMED'],
            [$this->event(['account_id' => '']), 'MISSING_EVENT_IDENTITY'],
            [$this->event(['device_id' => null]), 'MISSING_EVENT_IDENTITY'],
            [$this->event(['sequence' => null]), 'INVALID_SEQUENCE'],
            [$this->event(['sequence' => 0]), 'INVALID_SEQUENCE'],
            [$this->event(['sequence' => '8']), 'INVALID_SEQUENCE'],
            [$this->event(['t0_epoch_seconds' => null]), 'INVALID_T0'],
            [$this->event(['t0_epoch_seconds' => -1]), 'INVALID_T0'],
            [$this->event(['t0_epoch_seconds' => '2000']), 'INVALID_T0'],
        ];

        foreach ($cases as [$event, $reason]) {
            $result = Evaluator::evaluate($this->anchor(), $event, $this->context());

            self::assertFalse($result['can_form_candidate']);
            self::assertSame($reason, $result['reason']);
            self::assertSame($this->anchor(), $result['proposed_anchor']);
            $this->assertNoGrant($result);
        }
    }

    public function testTimeCannotMoveBackwardEvenWithIncreasingSequence(): void
    {
        $result = Evaluator::evaluate(
            $this->anchor(),
            $this->event(['sequence' => 8, 't0_epoch_seconds' => 999]),
            $this->context(),
        );

        self::assertFalse($result['can_form_candidate']);
        self::assertSame('T0_MOVED_BACKWARD', $result['reason']);
        self::assertSame($this->anchor(), $result['proposed_anchor']);
        $this->assertNoGrant($result);
    }

    public function testInvalidContextOrCurrentAnchorCannotBecomeACandidate(): void
    {
        $badContext = Evaluator::evaluate(null, $this->event(), ['account_id' => '', 'device_id' => 'device-A']);
        self::assertSame('INVALID_CONTEXT', $badContext['reason']);
        self::assertNull($badContext['proposed_anchor']);
        $this->assertNoGrant($badContext);

        $badAnchor = $this->anchor();
        $badAnchor['device_id'] = 'other-device';
        $result = Evaluator::evaluate($badAnchor, $this->event(['sequence' => 8]), $this->context());
        self::assertSame('INVALID_CURRENT_ANCHOR', $result['reason']);
        self::assertNull($result['proposed_anchor']);
        $this->assertNoGrant($result);
    }

    /** @return array<string, mixed> */
    private function context(): array
    {
        return ['account_id' => 'account-A', 'device_id' => 'device-A'];
    }

    /** @return array<string, mixed> */
    private function anchor(): array
    {
        $anchor = $this->event();
        unset($anchor['kind']);

        return $anchor;
    }

    /**
     * @param array<string, mixed> $overrides
     * @return array<string, mixed>
     */
    private function event(array $overrides = []): array
    {
        return array_replace([
            'kind' => Evaluator::INTERACTIVE_LOGIN,
            'account_id' => 'account-A',
            'device_id' => 'device-A',
            'sequence' => 7,
            't0_epoch_seconds' => 1000,
            'source_confirmed' => true,
        ], $overrides);
    }

    /** @param array<string, mixed> $result */
    private function assertNoGrant(array $result): void
    {
        self::assertSame('SYNTHETIC_LOGIN_ANCHOR_TRANSITION_CANDIDATE', $result['record_kind']);
        self::assertTrue($result['caller_claims_only']);
        self::assertFalse($result['server_source_verified']);
        self::assertFalse($result['authentication_grant']);
        self::assertFalse($result['offline_read_grant']);
        self::assertFalse($result['online_read_grant']);
        self::assertFalse($result['send_grant']);
        self::assertTrue($result['zero_writer']);
    }
}
