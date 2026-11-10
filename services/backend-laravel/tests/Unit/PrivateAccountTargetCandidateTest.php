<?php

namespace Tests\Unit;

use App\Domain\PrivateAccount\PrivateAccountTargetCandidate;
use PHPUnit\Framework\TestCase;

final class PrivateAccountTargetCandidateTest extends TestCase
{
    public function test_explicit_nickname_wins_without_rewriting_legacy_name(): void
    {
        $input = $this->candidate();
        $input['legacy_name']['value'] = 'Legacy Label';
        $input['explicit_nickname']['value'] = '  Chosen Label  ';

        self::assertSame([
            'value' => 'Chosen Label',
            'selected_source' => 'explicit_nickname',
            'missing' => false,
            'conflict' => 'different_legacy_name',
        ], PrivateAccountTargetCandidate::normalize($input)['nickname']);
        self::assertSame('Legacy Label', $input['legacy_name']['value']);
    }

    public function test_legacy_name_alone_does_not_supply_a_nickname(): void
    {
        $input = $this->candidate();
        $input['legacy_name']['value'] = 'Old Name';
        $input['explicit_nickname']['value'] = " \t ";

        self::assertSame([
            'value' => null,
            'selected_source' => null,
            'missing' => true,
            'conflict' => null,
        ], PrivateAccountTargetCandidate::normalize($input)['nickname']);
    }

    public function test_first_non_empty_birth_place_wins_and_conflict_is_visible(): void
    {
        $input = $this->candidate();
        $input['private_birth_place']['value'] = '  Fictional Place A  ';
        $input['astro_birth_place']['value'] = 'Fictional Place B';

        self::assertSame([
            'value' => 'Fictional Place A',
            'selected_source' => 'users.private_birth_place',
            'missing' => false,
            'conflict' => 'different_non_empty_sources',
        ], PrivateAccountTargetCandidate::normalize($input)['birth_place']);
    }

    public function test_blank_first_birth_place_falls_back_to_second(): void
    {
        $input = $this->candidate();
        $input['private_birth_place']['value'] = " \t\n ";
        $input['astro_birth_place']['value'] = '  Fictional Place B  ';

        self::assertSame([
            'value' => 'Fictional Place B',
            'selected_source' => 'user_astro_profiles.birth_place',
            'missing' => false,
            'conflict' => null,
        ], PrivateAccountTargetCandidate::normalize($input)['birth_place']);
    }

    public function test_two_blank_birth_places_are_missing(): void
    {
        $input = $this->candidate();
        $input['private_birth_place']['value'] = ' ';
        $input['astro_birth_place']['value'] = null;

        self::assertSame([
            'value' => null,
            'selected_source' => null,
            'missing' => true,
            'conflict' => null,
        ], PrivateAccountTargetCandidate::normalize($input)['birth_place']);
    }

    public function test_string_zero_is_present_and_numeric_zero_is_rejected(): void
    {
        $input = $this->candidate();
        $input['explicit_nickname']['value'] = ' 0 ';
        $input['private_birth_place']['value'] = '0';
        $result = PrivateAccountTargetCandidate::normalize($input);

        self::assertSame('0', $result['nickname']['value']);
        self::assertSame('0', $result['birth_place']['value']);
        self::assertFalse($result['birth_place']['missing']);

        $input['private_birth_place']['value'] = 0;
        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_mismatched_source_account_is_rejected(): void
    {
        $input = $this->candidate();
        $input['astro_birth_place']['account_id'] = 'synthetic-other';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_unknown_or_cross_database_source_order_is_rejected(): void
    {
        $input = $this->candidate();
        $input['source_order'] = ['backup_current', 'backup_2_6'];

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_missing_synthetic_label_is_rejected(): void
    {
        $input = $this->candidate();
        unset($input['synthetic_only']);

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_source_label_mismatch_is_rejected_even_if_values_are_blank(): void
    {
        $input = $this->candidate();
        $input['private_birth_place']['source'] = 'backup_current';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_missing_explicit_candidate_field_is_rejected(): void
    {
        $input = $this->candidate();
        unset($input['explicit_nickname']);

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_legacy_name_from_another_account_is_rejected(): void
    {
        $input = $this->candidate();
        $input['legacy_name']['account_id'] = 'synthetic-other';
        $input['legacy_name']['value'] = 'Other Account Name';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_explicit_nickname_from_another_account_is_rejected(): void
    {
        $input = $this->candidate();
        $input['explicit_nickname']['account_id'] = 'synthetic-other';
        $input['explicit_nickname']['value'] = 'Other Account Nickname';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_legacy_name_source_label_mismatch_is_rejected(): void
    {
        $input = $this->candidate();
        $input['legacy_name']['source'] = 'backup_current.name';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_explicit_nickname_source_label_mismatch_is_rejected(): void
    {
        $input = $this->candidate();
        $input['explicit_nickname']['source'] = 'users.name';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_blank_legacy_name_still_requires_matching_account(): void
    {
        $input = $this->candidate();
        $input['legacy_name']['account_id'] = 'synthetic-other';
        $input['legacy_name']['value'] = " \t ";

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_null_explicit_nickname_still_requires_matching_account(): void
    {
        $input = $this->candidate();
        $input['explicit_nickname']['account_id'] = 'synthetic-other';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    public function test_bare_name_value_has_no_compatibility_path(): void
    {
        $input = $this->candidate();
        $input['explicit_nickname'] = 'Bare Nickname';

        $this->expectException(\InvalidArgumentException::class);
        PrivateAccountTargetCandidate::normalize($input);
    }

    /** @return array<string, mixed> */
    private function candidate(): array
    {
        return [
            'synthetic_only' => true,
            'account_id' => 'synthetic-account-1',
            'source_order' => ['users.private_birth_place', 'user_astro_profiles.birth_place'],
            'legacy_name' => [
                'source' => 'users.name',
                'account_id' => 'synthetic-account-1',
                'value' => null,
            ],
            'explicit_nickname' => [
                'source' => 'explicit_nickname',
                'account_id' => 'synthetic-account-1',
                'value' => null,
            ],
            'private_birth_place' => [
                'source' => 'users.private_birth_place',
                'account_id' => 'synthetic-account-1',
                'value' => null,
            ],
            'astro_birth_place' => [
                'source' => 'user_astro_profiles.birth_place',
                'account_id' => 'synthetic-account-1',
                'value' => null,
            ],
        ];
    }
}
