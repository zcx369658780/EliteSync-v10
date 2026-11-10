<?php

namespace App\Services;

use com\nlf\calendar\Lunar;
use com\nlf\calendar\LunarYear;
use com\nlf\calendar\Solar;
use com\nlf\calendar\util\ShouXingUtil;
use RuntimeException;
use Symfony\Component\Process\Process;

/** Map library roots through TT; no vendor or reference table is modified. */
final class NatalBaziTimeScale
{
    public function __construct(private readonly ?string $python = null) {}

    public function resolve(array $context, ?array $expectedTimeContext = null): array
    {
        $year = (int) substr($context['utc'], 0, 4);
        $terms = $this->roots($year);
        $python = $this->python ?? getenv('NATAL_PYTHON');
        if (! is_string($python) || $python === '') {
            throw new RuntimeException('bazi_time_executable_not_configured');
        }
        $root = dirname(__DIR__, 2);
        $process = new Process([$python, $root.'/tools/natal/bazi_time.py'], $root, null,
            json_encode(['utc' => $context['utc'], 'expected_time_context' => $expectedTimeContext,
                'terms' => array_map(fn ($t) => ['id' => $t['id'], 'tt_jd' => $t['tt_jd']], $terms)], JSON_THROW_ON_ERROR), 45);
        $process->run();
        if (! $process->isSuccessful() || strlen($process->getOutput()) > 262144) {
            throw new RuntimeException('bazi_time_conversion_failed');
        }
        $result = json_decode($process->getOutput(), true, 64, JSON_THROW_ON_ERROR);
        if (($result['status'] ?? null) !== 'CALCULATED' || count($result['terms'] ?? []) !== count($terms)) {
            throw new RuntimeException('bazi_time_result_invalid');
        }
        foreach ($terms as $i => &$term) {
            if (($result['terms'][$i]['id'] ?? null) !== $term['id']) {
                throw new RuntimeException('bazi_term_identity_mismatch');
            }
            $term = [...$term, ...$result['terms'][$i]];
        }
        unset($term);
        $birth = $result['time_context']['tt_jd'];
        $selected = $this->bracket($terms, $birth);

        return [...$selected, 'time_context' => $result['time_context'],
            'conversion_profile' => 'lunar-model-ut1-via-tt-to-declared-civil-v1'];
    }

    /** Raw unrounded JD roots. Even IN_USE indices are jie, including aliases. */
    public function roots(int $year): array
    {
        $rows = [];
        foreach ([$year - 1, $year, $year + 1] as $y) {
            foreach (LunarYear::fromYear($y)->getJieQiJulianDays() as $i => $jd) {
                if ($i % 2 !== 0) {
                    continue;
                }
                $label = Solar::fromJulianDay($jd);
                $key = $label->toYmd();
                $u = $jd - Solar::$J2000 - 1 / 3;
                $tt = $u;
                for ($j = 0; $j < 4; $j++) {
                    $tt = $u + ShouXingUtil::dtT($tt);
                }
                $whole = floor(Solar::$J2000 + $tt);
                $fraction = (Solar::$J2000 - $whole) + $tt;
                $rows[$key] = ['id' => $key, 'name' => Lunar::$JIE_QI[($i + 23) % 24],
                    'library_jd' => $jd, 'library_calendar_label' => $label->toYmdHms(),
                    'library_frame' => 'lunar_php_model_UT1_plus_08',
                    'library_delta_t_seconds' => ShouXingUtil::dtT($tt) * 86400,
                    'tt_jd' => [$whole, $fraction]];
            }
        }
        ksort($rows);

        return array_values($rows);
    }

    /** Exact half-open TT comparison; serialization rounding never classifies birth. */
    public function bracket(array $terms, array $birth): array
    {
        $previous = null;
        foreach ($terms as $term) {
            $difference = ($term['tt_jd'][0] - $birth[0]) + ($term['tt_jd'][1] - $birth[1]);
            if ($difference > 0) {
                if ($previous === null) {
                    break;
                }
                // Only this safe interior label supplies the library year/month.
                $representative = ($previous['library_jd'] + $term['library_jd']) / 2;

                return ['previous_jie' => $previous, 'next_jie' => $term,
                    'representative_library_jd' => $representative];
            }
            $previous = $term;
        }
        throw new RuntimeException('bazi_term_bracket_unavailable');
    }
}
