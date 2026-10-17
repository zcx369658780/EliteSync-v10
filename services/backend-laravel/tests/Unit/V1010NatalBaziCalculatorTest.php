<?php

namespace Tests\Unit;

use App\Services\NatalBaziCalculator;
use App\Services\NatalBaziTimeScale;
use App\Services\NatalInputContext;
use com\nlf\calendar\util\LunarUtil;
use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

/** Contract and metamorphic tests; these are not an independent accuracy oracle. */
class V1010NatalBaziCalculatorTest extends TestCase
{
    private function context(array $changes = [], array $rules = []): array
    {
        return (new NatalInputContext)->normalize(array_replace([
            'civil_date' => '2000-06-15', 'civil_time' => '10:30:00',
            'time_precision' => 'second', 'timezone' => 'Asia/Shanghai',
            'algorithm_sex' => 'male',
        ], $changes), ['id' => 'unit-synthetic', 'version' => '1', 'bazi' => $rules]);
    }

    public function test_real_fields_are_computed_with_explicit_rules_and_unverified_oracle(): void
    {
        $result = (new NatalBaziCalculator)->compute($this->context());
        $this->assertSame('COMPUTED_UNVERIFIED', $result['status']);
        $this->assertSame('UNVERIFIED', $result['oracle_status']);
        $this->assertSame('1.4.0', $result['engine']['version']);
        $this->assertSame(2, $result['rules']['day_sect']);
        $this->assertSame(1, $result['rules']['yun_sect']);
        $this->assertSame('civil', $result['time_basis']['mode']);
        $this->assertCount(4, $result['pillars']);
        foreach ($result['pillars'] as $pillar) {
            $this->assertNotEmpty($pillar['gan_zhi']);
            $this->assertNotEmpty($pillar['hidden_stems']);
            $this->assertCount(count($pillar['hidden_stems']), $pillar['ten_gods_hidden']);
            $this->assertNotEmpty($pillar['na_yin']);
            $this->assertNotEmpty($pillar['di_shi']);
            $this->assertNotEmpty($pillar['five_elements']);
        }
        $this->assertSame(8, array_sum($result['five_elements']['visible_counts']));
        $this->assertSame('symbol_distribution_not_strength_score', $result['five_elements']['interpretation']);
        $this->assertSame('COMPUTED_UNVERIFIED', $result['yun']['status']);
        $this->assertIsBool($result['yun']['forward']);
        foreach (['years', 'months', 'days', 'hours'] as $key) {
            $this->assertIsInt($result['yun']['start_offset'][$key]);
        }
        $this->assertMatchesRegularExpression('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/', $result['yun']['start_solar_datetime']);
        $this->assertCount(10, $result['da_yun']);
        $this->assertSame('pre_yun', $result['da_yun'][0]['kind']);
        $this->assertNull($result['da_yun'][0]['gan_zhi']);
        $this->assertNotEmpty($result['da_yun'][1]['liu_nian']);
        $this->assertNotEmpty($result['solar_terms']['previous_jie']['name']);
    }

    public function test_unknown_time_does_not_generate_pillars_yun_or_noon(): void
    {
        $context = $this->context(['civil_time' => null, 'time_precision' => 'unknown']);
        $result = (new NatalBaziCalculator)->compute($context);
        $this->assertSame('UNKNOWN', $result['status']);
        $this->assertSame('birth_time_unknown', $result['reason']);
        $this->assertNull($result['pillars']);
        $this->assertNull($result['time_basis']['effective_time']);
        $this->assertNull($result['yun']['forward']);
        $this->assertNull($result['da_yun']);
        $this->assertSame('UNVERIFIED', $result['oracle_status']);
    }

    public function test_unknown_algorithm_sex_still_returns_pillars_but_not_direction_or_luck_cycles(): void
    {
        $result = (new NatalBaziCalculator)->compute($this->context(['algorithm_sex' => 'unknown', 'gender' => 'male']));
        $this->assertCount(4, $result['pillars']);
        $this->assertSame('PARTIAL_UNVERIFIED', $result['status']);
        $this->assertSame('UNKNOWN', $result['yun']['status']);
        $this->assertSame('algorithm_sex_unknown', $result['yun']['reason']);
        $this->assertNull($result['yun']['forward']);
        $this->assertNull($result['yun']['start_solar_datetime']);
        $this->assertNull($result['da_yun']);
    }

    public function test_confirmed_algorithm_sex_changes_direction_but_not_natal_pillars(): void
    {
        $calculator = new NatalBaziCalculator;
        $male = $calculator->compute($this->context());
        $female = $calculator->compute($this->context(['algorithm_sex' => 'female']));
        $this->assertSame($male['pillars'], $female['pillars']);
        $this->assertNotSame($male['yun']['forward'], $female['yun']['forward']);
        $this->assertNotSame($male['da_yun'][1]['gan_zhi'], $female['da_yun'][1]['gan_zhi']);
    }

    public function test_late_zi_day_boundary_is_an_explicit_profile_setting(): void
    {
        $calculator = new NatalBaziCalculator;
        $late = ['civil_time' => '23:30:00'];
        $sectOne = $calculator->compute($this->context($late, ['day_sect' => 1]));
        $sectTwo = $calculator->compute($this->context($late, ['day_sect' => 2]));
        $nextDay = $calculator->compute($this->context(['civil_date' => '2000-06-16', 'civil_time' => '00:30:00'], ['day_sect' => 2]));
        $this->assertNotSame($sectOne['pillars']['day']['gan_zhi'], $sectTwo['pillars']['day']['gan_zhi']);
        $this->assertSame($sectOne['pillars']['day']['gan_zhi'], $nextDay['pillars']['day']['gan_zhi']);
        $this->assertSame('late_zi_next_day', $sectOne['rules']['day_boundary']);
        $this->assertSame('late_zi_current_day', $sectTwo['rules']['day_boundary']);
    }

    public function test_yun_conversion_method_is_explicit_and_minute_method_keeps_hours(): void
    {
        $calculator = new NatalBaziCalculator;
        $traditional = $calculator->compute($this->context([], ['yun_sect' => 1]));
        $minute = $calculator->compute($this->context([], ['yun_sect' => 2]));
        $this->assertSame('days_and_double_hours', $traditional['rules']['yun_conversion']);
        $this->assertSame('minutes', $minute['rules']['yun_conversion']);
        $this->assertSame(0, $traditional['yun']['start_offset']['hours']);
        $this->assertNotSame($traditional['yun']['start_offset'], $minute['yun']['start_offset']);
    }

    public function test_explicit_parent_solar_context_can_cross_date_and_is_recorded(): void
    {
        $calculator = new NatalBaziCalculator;
        $solarContext = ['effective_solar_date' => '2000-06-16', 'effective_solar_time' => '00:10:00', 'source' => 'synthetic-parent', 'status' => 'UNVERIFIED'];
        $effective = $calculator->compute($this->context(), $solarContext);
        $sameCivil = $calculator->compute($this->context(['civil_date' => '2000-06-16', 'civil_time' => '00:10:00']));
        foreach ($sameCivil['pillars'] as $key => $pillar) {
            // Numeric/rule results agree, while the newly explicit provenance must differ.
            $this->assertSame(array_diff_key($pillar, ['frame' => true]), array_diff_key($effective['pillars'][$key], ['frame' => true]));
            $this->assertSame(in_array($key, ['year', 'month'], true) ? 'UTC+08:00' : 'parent_supplied_solar', $effective['pillars'][$key]['frame']);
        }
        $this->assertSame('parent_supplied_solar', $effective['time_basis']['mode']);
        $this->assertSame('2000-06-16', $effective['time_basis']['effective_date']);
        $this->assertSame($solarContext, $effective['time_basis']['solar_context']);
    }

    public function test_solar_context_cannot_supply_a_time_for_unknown_birth_time(): void
    {
        $result = (new NatalBaziCalculator)->compute($this->context(['civil_time' => null, 'time_precision' => 'unknown']), [
            'effective_solar_date' => '2000-06-15', 'effective_solar_time' => '12:00:00', 'source' => 'synthetic-parent',
        ]);
        $this->assertSame('UNKNOWN', $result['status']);
        $this->assertNull($result['pillars']);
        $this->assertNull($result['time_basis']['effective_time']);
    }

    public function test_changed_birth_date_changes_pillars_and_result_input_identity(): void
    {
        $calculator = new NatalBaziCalculator;
        $first = $calculator->compute($this->context());
        $second = $calculator->compute($this->context(['civil_date' => '2001-06-15']));
        $this->assertNotSame($first['pillars'], $second['pillars']);
        $this->assertNotSame($first['input_signature'], $second['input_signature']);
    }

    public function test_invalid_rules_and_incomplete_solar_context_are_rejected(): void
    {
        $calculator = new NatalBaziCalculator;
        foreach ([['day_sect' => 3], ['yun_sect' => 0], ['da_yun_count' => 0], ['day_sect' => '2']] as $rules) {
            try {
                $calculator->compute($this->context([], $rules));
                $this->fail('Expected invalid bazi rules');
            } catch (InvalidArgumentException $exception) {
                $this->assertNotEmpty($exception->getMessage());
            }
        }
        $this->expectException(InvalidArgumentException::class);
        $calculator->compute($this->context(), ['effective_solar_date' => '2000-06-15']);
    }

    private function contextAtUtc(string $utc, string $timezone): array
    {
        $local = (new DateTimeImmutable($utc))->setTimezone(new DateTimeZone($timezone));

        return $this->context(['civil_date' => $local->format('Y-m-d'), 'civil_time' => $local->format('H:i:s'), 'timezone' => $timezone]);
    }

    public function test_same_utc_uses_same_cst_year_month_and_yun_across_global_timezones(): void
    {
        $calculator = new NatalBaziCalculator;
        $west = $calculator->compute($this->contextAtUtc('2024-02-04T15:00:00Z', 'America/Los_Angeles'));
        $east = $calculator->compute($this->contextAtUtc('2024-02-04T15:00:00Z', 'Pacific/Kiritimati'));
        foreach (['year', 'month'] as $pillar) {
            $this->assertSame($west['pillars'][$pillar]['gan_zhi'], $east['pillars'][$pillar]['gan_zhi']);
        }
        $this->assertNotSame($west['pillars']['day']['gan_zhi'], $east['pillars']['day']['gan_zhi']);
        $this->assertNotSame($west['pillars']['hour']['gan_zhi'], $east['pillars']['hour']['gan_zhi']);
        $this->assertSame('instant_tt_term_bracket', $west['time_basis']['year_month_mode']);
        $this->assertSame($west['yun']['start_offset'], $east['yun']['start_offset']);
        $this->assertSame($west['yun']['start_utc'], $east['yun']['start_utc']);
        $this->assertSame($west['da_yun'], $east['da_yun']);
        $this->assertSame('UTC+08:00', $west['yun']['timestamp_frame']);
        $this->assertNotSame($west['yun']['start_user_datetime'], $east['yun']['start_user_datetime']);
        $this->assertStringEndsWith('Z', $west['solar_terms']['previous_jie']['utc']);
    }

    public function test_li_chun_boundary_uses_real_instant_rather_than_local_wall_clock(): void
    {
        // Adapter regression at its own root, not an independent accuracy oracle.
        $terms = (new NatalBaziTimeScale)->resolve($this->contextAtUtc('2100-02-01T00:00:00Z', 'UTC'));
        $this->assertSame('立春', $terms['next_jie']['name']);
        $transition = new DateTimeImmutable($terms['next_jie']['cst_datetime']);
        $calculator = new NatalBaziCalculator;
        $before = $calculator->compute($this->contextAtUtc($transition->modify('-2 seconds')->format(DATE_ATOM), 'America/New_York'));
        $after = $calculator->compute($this->contextAtUtc($transition->modify('+2 seconds')->format(DATE_ATOM), 'America/New_York'));
        $this->assertNotSame($before['pillars']['year']['gan_zhi'], $after['pillars']['year']['gan_zhi']);
        $this->assertNotSame($before['pillars']['month']['gan_zhi'], $after['pillars']['month']['gan_zhi']);
        $this->assertSame('UNVERIFIED', $after['solar_terms']['oracle_status']);
        // The old model-UT1 label is >1 minute earlier here and must no longer classify the year.
        $old = new DateTimeImmutable($terms['next_jie']['library_calendar_label'], new DateTimeZone('+08:00'));
        $this->assertGreaterThan(60, $transition->getTimestamp() - $old->getTimestamp());
        $middle = $calculator->compute($this->contextAtUtc($old->modify('+30 seconds')->format(DATE_ATOM), 'America/New_York'));
        $this->assertSame($before['pillars']['year']['gan_zhi'], $middle['pillars']['year']['gan_zhi']);
    }

    public function test_parent_solar_cross_day_does_not_reclassify_instant_year_month_or_yun(): void
    {
        $calculator = new NatalBaziCalculator;
        $context = $this->contextAtUtc('2024-02-04T08:30:00Z', 'America/New_York');
        $civil = $calculator->compute($context);
        $solar = $calculator->compute($context, ['effective_solar_date' => '2024-02-03', 'effective_solar_time' => '23:30:00', 'source' => 'synthetic-parent']);
        foreach (['year', 'month'] as $pillar) {
            $this->assertSame($civil['pillars'][$pillar]['gan_zhi'], $solar['pillars'][$pillar]['gan_zhi']);
        }
        $this->assertNotSame($civil['pillars']['day']['gan_zhi'], $solar['pillars']['day']['gan_zhi']);
        $this->assertSame($civil['yun'], $solar['yun']);
        $this->assertSame('UTC+08:00', $solar['extensions']['tai_yuan']['frame']);
        $this->assertSame('parent_supplied_solar', $solar['extensions']['tai_xi']['frame']);
    }

    public function test_combined_year_month_ten_gods_use_effective_day_master(): void
    {
        $result = (new NatalBaziCalculator)->compute($this->contextAtUtc('2024-02-04T15:00:00Z', 'Pacific/Kiritimati'));
        $dayMaster = $result['pillars']['day']['gan'];
        foreach (['year', 'month'] as $key) {
            $pillar = $result['pillars'][$key];
            $this->assertSame(LunarUtil::$SHI_SHEN[$dayMaster.$pillar['gan']], $pillar['ten_god_stem']);
            foreach ($pillar['hidden_stems'] as $index => $stem) {
                $this->assertSame(LunarUtil::$SHI_SHEN[$dayMaster.$stem], $pillar['ten_gods_hidden'][$index]);
            }
            $this->assertSame($dayMaster, $pillar['day_master_basis']);
        }
        // Rule replay: 己日干逆行，辰距子4步、寅距子2步；库长生表offset=9。
        $this->assertSame('己', $dayMaster);
        $this->assertSame('衰', $result['pillars']['year']['di_shi']);
        $this->assertSame('死', $result['pillars']['month']['di_shi']);
    }

    public function test_context_without_utc_has_visible_compatibility_frame_and_no_fake_utc(): void
    {
        $context = $this->context();
        unset($context['utc']);
        $result = (new NatalBaziCalculator)->compute($context);
        $this->assertSame('compatibility_wall_time', $result['time_basis']['year_month_mode']);
        $this->assertSame('compatibility_wall_time', $result['yun']['timestamp_frame']);
        $this->assertNull($result['yun']['start_utc']);
        $this->assertNull($result['yun']['start_user_datetime']);
        $this->assertSame('UNVERIFIED', $result['oracle_status']);
    }

    public function test_domain_edges_and_pre_utc_birth_crossing_1960_keep_explicit_time_frames(): void
    {
        $calculator = new NatalBaziCalculator;
        $early = $calculator->compute($this->contextAtUtc('1900-01-01T00:00:00Z', 'UTC'));
        $this->assertStringStartsWith('1899-', $early['solar_terms']['previous_jie']['id']);
        $this->assertNull($early['solar_terms']['previous_jie']['utc']);
        $this->assertSame('model_UT1+08:00', $early['solar_terms']['previous_jie']['timestamp_frame']);
        $this->assertSame('model_UT1+08:00', $early['yun']['timestamp_frame']);
        $this->assertNull($early['yun']['start_utc']);
        $late = $calculator->compute($this->contextAtUtc('2100-12-31T23:59:59Z', 'UTC'));
        $this->assertStringStartsWith('2101-', $late['solar_terms']['next_jie']['id']);
        $this->assertSame('FUTURE_ASSUMPTION', $late['time_basis']['term_time_context']['accuracy_status']);
        $this->assertSame('UNKNOWN', $late['yun']['future_leap_seconds_actual']);
        $context = $this->contextAtUtc('1959-12-31T12:00:00Z', 'America/New_York');
        $context['algorithm_sex'] = 'female'; // yin year, forward, start extends past 1960.
        $cross = $calculator->compute($context);
        $this->assertSame('PRE_1960_CIVIL_LABEL_AS_UT1', $cross['time_basis']['term_time_context']['utc_interpretation']);
        $this->assertSame('UTC+08:00', $cross['yun']['timestamp_frame']);
        $this->assertNotNull($cross['yun']['start_utc']);
        $this->assertSame('CIVIL_UTC_LABEL', $cross['yun']['start_time_interpretation']);
        $display = (new DateTimeImmutable($cross['yun']['start_utc']))->setTimezone(new DateTimeZone('America/New_York'))->format(DATE_ATOM);
        $this->assertSame($display, $cross['yun']['start_user_datetime']);
    }
}
