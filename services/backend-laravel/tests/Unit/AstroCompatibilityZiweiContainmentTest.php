<?php

namespace Tests\Unit;

use App\Services\AstroCompatibilityService;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class AstroCompatibilityZiweiContainmentTest extends TestCase
{
    public function test_ziwei_main_star_factor_is_low_weight_and_capped_when_available(): void
    {
        Config::set('match_rules.weights.ziwei', 0.10);
        Config::set('match_rules.ziwei_main_star_affinity.enabled', true);
        Config::set('match_rules.ziwei_main_star_affinity.max_weight', 0.05);

        $svc = app(AstroCompatibilityService::class);
        $result = $svc->score($this->profile('命宫'), $this->profile('命宫'));

        $this->assertGreaterThan(0, (int) data_get($result, 'ziwei'));
        $this->assertSame('available', (string) data_get($result, 'ziwei_main_star_affinity.status'));
        $this->assertSame('low_weight_auxiliary', (string) data_get($result, 'module_details.ziwei.weight_policy'));
        $this->assertSame(0.05, (float) data_get($result, 'module_details.ziwei.weight'));
        $this->assertLessThanOrEqual(5.0, (float) data_get($result, 'module_details.ziwei.score_delta'));
        $this->assertSame(
            'low_weight_auxiliary',
            (string) data_get($result, 'module_details.ziwei.evidence.scoring_status')
        );
        $this->assertStringContainsString('紫微主星参考5%', (string) data_get($result, 'summary'));
        $this->assertStringContainsString(
            '紫微主星关系参考',
            (string) data_get($result, 'module_details.ziwei.reason_short')
        );
    }

    public function test_ziwei_main_star_factor_can_be_disabled_without_affecting_score(): void
    {
        Config::set('match_rules.weights.ziwei', 0.10);
        Config::set('match_rules.ziwei_main_star_affinity.enabled', false);

        $svc = app(AstroCompatibilityService::class);
        $result = $svc->score($this->profile('命宫'), $this->profile('命宫'));

        $this->assertSame(0, (int) data_get($result, 'ziwei'));
        $this->assertSame(0.0, (float) data_get($result, 'module_details.ziwei.confidence'));
        $this->assertSame('disabled', (string) data_get($result, 'ziwei_main_star_affinity.status'));
        $this->assertSame('ziwei_affinity_disabled', (string) data_get($result, 'module_details.ziwei.degrade_reason'));
        $this->assertSame(0.0, (float) data_get($result, 'module_details.ziwei.weight'));
        $this->assertStringContainsString('紫微主星参考0%', (string) data_get($result, 'summary'));
    }

    public function test_missing_ziwei_data_has_no_penalty(): void
    {
        Config::set('match_rules.weights.ziwei', 0.05);
        Config::set('match_rules.ziwei_main_star_affinity.enabled', true);

        $svc = app(AstroCompatibilityService::class);
        $a = $this->profile('命宫');
        $b = $this->profile('命宫');
        $a['private_ziwei'] = [];

        $result = $svc->score($a, $b);

        $this->assertSame(0, (int) data_get($result, 'ziwei'));
        $this->assertSame('unavailable', (string) data_get($result, 'ziwei_main_star_affinity.status'));
        $this->assertSame(0.0, (float) data_get($result, 'module_details.ziwei.score_delta'));
        $this->assertSame('missing_ziwei_main_star_data', (string) data_get($result, 'module_details.ziwei.degrade_reason'));
    }

    public function test_accepted_advanced_fields_are_explanation_only_without_extra_score(): void
    {
        Config::set('match_rules.weights.ziwei', 0.05);
        Config::set('match_rules.ziwei_main_star_affinity.enabled', true);

        $svc = app(AstroCompatibilityService::class);
        $a = $this->profile('命宫');
        $b = $this->profile('命宫');
        $a['private_ziwei']['ziwei_advanced_fields'] = $this->acceptedAdvancedFields();

        $result = $svc->score($a, $b);

        $this->assertSame('available', (string) data_get($result, 'module_details.ziwei.status'));
        $this->assertContains('ziwei_advanced_affinity_v1', (array) data_get($result, 'module_details.ziwei.evidence_tags', []));
        $this->assertSame(true, (bool) data_get($result, 'module_details.ziwei.evidence.advanced_field_status_a.accepted'));
        $this->assertSame('missing', (string) data_get($result, 'module_details.ziwei.evidence.advanced_field_status_b.status'));
        $this->assertLessThanOrEqual(5.0, (float) data_get($result, 'module_details.ziwei.score_delta'));
        $this->assertStringContainsString(
            '不会进入匹配分',
            (string) data_get($result, 'module_details.ziwei.boundary_note')
        );
    }

    /**
     * @return array<string,mixed>
     */
    private function profile(string $lifePalace): array
    {
        return [
            'zodiac_animal' => '马',
            'public_zodiac_sign' => '巨蟹座',
            'private_bazi' => '甲子年 丙寅月 丁卯日 庚午时',
            'private_natal_chart' => [
                'moon_sign' => '双鱼座',
                'asc_sign' => '天秤座',
                'wu_xing' => ['木' => 2, '火' => 3, '土' => 2, '金' => 1, '水' => 2],
            ],
            'private_ziwei' => [
                'engine' => 'ziwei_seed_estimate',
                'precision' => 'approximate_not_validated',
                'external_oracle_status' => 'not_validated',
                'display_only' => true,
                'life_palace' => $lifePalace,
                'body_palace' => '身宫',
                'major_themes' => [
                    'relationship_bias' => '夫妻宫',
                    'career_bias' => '官禄宫',
                    'wealth_bias' => '财帛宫',
                ],
                'palaces' => [[
                    'name' => $lifePalace,
                    'palace_name' => $lifePalace,
                    'branch' => '寅',
                    'main_star' => '紫微',
                    'main_stars' => ['紫微', '天府'],
                ], [
                    'name' => '身宫',
                    'palace_name' => '身宫',
                    'branch' => '申',
                    'main_star' => '天相',
                    'main_stars' => ['天相'],
                ]],
            ],
            'birthday' => '1990-01-01',
            'gender' => 'female',
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function acceptedAdvancedFields(): array
    {
        return [
            'status' => 'accepted_selected_fields_only',
            'field_status' => [
                'sihua' => 'accepted_selected_fields_only',
                'auxiliary_stars' => 'accepted_selected_fields_only',
                'brightness' => 'accepted_selected_fields_only',
                'flying_stars' => 'pending_oracle',
                'ming_gong_flying_star' => 'pending_oracle',
            ],
            'sihua' => [
                'items' => [
                    ['transform' => '化禄', 'star' => '武曲', 'palace' => '财帛宫'],
                ],
            ],
            'matching_policy' => 'eligible_for_low_weight_explanation_only_no_hard_filter',
        ];
    }
}
