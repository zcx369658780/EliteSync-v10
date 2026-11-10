<?php

namespace App\Services;

use com\nlf\calendar\EightChar;
use com\nlf\calendar\Solar;
use com\nlf\calendar\util\LunarUtil;
use DateTimeImmutable;
use DateTimeZone;

/** Same discrete Yun rules, anchored to real civil birth and converted jie labels. */
final class NatalBaziLuckProjection
{
    public function compute(array $context, EightChar $termEight, array $terms, array $rules): array
    {
        $birth = (new DateTimeImmutable($context['utc']))->setTimezone(new DateTimeZone('+08:00'));
        $yearGanIndex = array_search($termEight->getYearGan(), LunarUtil::$GAN, true) - 1;
        $forward = ($yearGanIndex % 2 === 0) === ($context['algorithm_sex'] === 'male');
        $endpoint = new DateTimeImmutable($terms[$forward ? 'next_jie' : 'previous_jie']['cst_datetime']);
        [$from, $to] = $forward ? [$birth, $endpoint] : [$endpoint, $birth];
        if ($rules['yun_sect'] === 1) {
            $bucket = fn ($t) => 12 * (int) floor(($t->getTimestamp() + 28800) / 86400)
                + min(11, intdiv((int) $t->format('G') + 1, 2));
            $units = $bucket($to) - $bucket($from);
            $offset = ['years' => intdiv($units, 36), 'months' => intdiv($units % 36, 3),
                'days' => ($units % 3) * 10, 'hours' => 0];
        } else {
            $minutes = (int) floor($to->getTimestamp() / 60) - (int) floor($from->getTimestamp() / 60);
            $offset = ['years' => intdiv($minutes, 4320), 'months' => intdiv($minutes % 4320, 360),
                'days' => intdiv($minutes % 360, 12), 'hours' => ($minutes % 12) * 2];
        }
        // Reuse the admitted sequential Gregorian clamps, starting at actual birth.
        $start = $this->calendarStart(Solar::fromYmdHms(...array_map('intval', explode(' ', $birth->format('Y n j G i s')))), $offset);
        $startLabel = $start->toYmdHms();
        $startInstant = new DateTimeImmutable($startLabel, new DateTimeZone('+08:00'));
        $preUtc = $startInstant->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d') < '1960-01-01';
        $yun = ['status' => 'COMPUTED_UNVERIFIED', 'algorithm_sex' => $context['algorithm_sex'],
            'forward' => $forward, 'start_offset' => $offset,
            'start_solar_datetime' => str_replace(' ', 'T', $startLabel),
            'timestamp_frame' => $preUtc ? 'model_UT1+08:00' : 'UTC+08:00',
            'start_utc' => $preUtc ? null : $startInstant->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
            'start_user_datetime' => $startInstant->setTimezone(new DateTimeZone($context['timezone']))->format(DATE_ATOM),
            'start_time_policy' => 'Gregorian_civil_label_projection_not_elapsed_TT_seconds',
            'start_time_interpretation' => $preUtc ? 'PRE_1960_CIVIL_LABEL_AS_UT1' : 'CIVIL_UTC_LABEL',
            'future_leap_seconds_actual' => 'UNKNOWN',
            'resolution' => $rules['yun_sect'] === 1 ? 'double_hour_conversion' : 'minute_conversion',
            'calendar_policy' => $rules['yun_calendar_policy'],
            'precision_note' => 'retained_birth_seconds_are_not_independent_second_precision_of_jie_or_qiyun',
            'oracle_status' => 'UNVERIFIED'];
        $birthYear = (int) $birth->format('Y');
        $startYear = $start->getYear();
        $monthIndex = LunarUtil::getJiaZiIndex($termEight->getMonth());
        $cycles = $annuals = [];
        for ($i = 0; $i < $rules['da_yun_count']; $i++) {
            $fromYear = $i === 0 ? $birthYear : $startYear + ($i - 1) * 10;
            $toYear = $i === 0 ? $startYear - 1 : $fromYear + 9;
            $annual = [];
            for ($y = $fromYear; $y <= $toYear; $y++) {
                // Year label after Li Chun; not an instantaneous January-1 boundary.
                $gz = LunarUtil::$JIA_ZI[(($y - 4) % 60 + 60) % 60];
                $entry = ['year' => $y, 'age' => $y - $birthYear + 1, 'gan_zhi' => $gz,
                    'xun' => LunarUtil::getXun($gz), 'xun_kong' => LunarUtil::getXunKong($gz), 'da_yun_index' => $i];
                $annual[] = $entry;
                $annuals[] = $entry;
            }
            $cycles[] = ['index' => $i, 'kind' => $i === 0 ? 'pre_yun' : 'da_yun',
                'gan_zhi' => $i === 0 ? null : LunarUtil::$JIA_ZI[($monthIndex + ($forward ? $i : -$i) + 60) % 60],
                'start_year' => $fromYear, 'end_year' => $toYear,
                'start_age' => $fromYear - $birthYear + 1, 'end_age' => $toYear - $birthYear + 1, 'liu_nian' => $annual];
        }

        return ['yun' => $yun, 'da_yun' => $cycles, 'liu_nian' => $annuals];
    }

    public function calendarStart(Solar $birth, array $offset): Solar
    {
        return $birth->nextYear($offset['years'])->nextMonth($offset['months'])
            ->next($offset['days'])->nextHour($offset['hours']);
    }
}
