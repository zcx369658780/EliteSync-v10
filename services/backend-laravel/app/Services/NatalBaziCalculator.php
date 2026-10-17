<?php

namespace App\Services;

use com\nlf\calendar\EightChar;
use com\nlf\calendar\JieQi;
use com\nlf\calendar\Solar;
use com\nlf\calendar\util\LunarUtil;
use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;

/** Real lunar-php calculations; independent oracle approval is deliberately separate. */
final class NatalBaziCalculator
{
    public function compute(array $context, ?array $solarContext = null): array
    {
        $rules = $this->rules($context['calculation_profile']['bazi'] ?? []);
        $date = $context['civil_date'] ?? null;
        $time = $context['normalized_time'] ?? null;
        $this->validateDate($date);
        $sex = $context['algorithm_sex'] ?? 'unknown';
        if (! in_array($sex, ['male', 'female', 'unknown'], true)) {
            throw new InvalidArgumentException('invalid_algorithm_sex');
        }
        $base = [
            'status' => 'UNKNOWN',
            'oracle_status' => 'UNVERIFIED',
            'engine' => ['package' => '6tail/lunar-php', 'version' => '1.4.0'],
            'input_signature' => $context['input_signature'] ?? null,
            'calculation_profile' => $context['calculation_profile'] ?? null,
            'rules' => $rules,
            'time_basis' => [
                'mode' => 'civil',
                'civil_date' => $date,
                'civil_time' => $context['civil_time'] ?? null,
                'effective_date' => $date,
                'effective_time' => $time,
                'timezone' => $context['timezone'] ?? null,
                'solar_context' => null,
                'engine_calendar_time_scale' => 'lunar_php_calendar_wall_time_no_timezone_parameter',
                'solar_term_reference_status' => 'UNVERIFIED',
            ],
            'pillars' => null,
            'five_elements' => null,
            'solar_terms' => null,
            'extensions' => null,
            'yun' => $this->unknownYun('birth_time_unknown'),
            'da_yun' => null,
            'liu_nian' => null,
        ];
        // No attempt to compute a precise partial chart with a fabricated 00:00/12:00.
        if ($time === null || ($context['time_precision'] ?? null) === 'unknown') {
            $base['time_basis']['effective_time'] = null;
            $base['reason'] = 'birth_time_unknown';

            return $base;
        }
        $this->validateTime($time);
        if ($solarContext !== null) {
            $solarDate = $solarContext['effective_solar_date'] ?? null;
            $solarTime = $solarContext['effective_solar_time'] ?? null;
            $this->validateDate($solarDate);
            $this->validateTime($solarTime);
            if (! is_string($solarContext['source'] ?? null) || trim($solarContext['source']) === '') {
                throw new InvalidArgumentException('solar_context_source_required');
            }
            $date = $solarDate;
            $time = $solarTime;
            $base['time_basis'] = array_replace($base['time_basis'], [
                'mode' => 'parent_supplied_solar',
                'effective_date' => $date,
                'effective_time' => $time,
                'solar_context' => $solarContext,
            ]);
        }

        [$year, $month, $day] = array_map('intval', explode('-', $date));
        [$hour, $minute, $second] = array_map('intval', explode(':', $time));
        $solar = Solar::fromYmdHms($year, $month, $day, $hour, $minute, $second);
        $lunar = $solar->getLunar();
        $eight = $lunar->getEightChar();
        $eight->setSect($rules['day_sect']);
        $termEight = $eight;
        $termLunar = $lunar;
        $hasInstant = isset($context['utc']);
        $termFrame = $hasInstant ? 'UTC+08:00' : 'compatibility_wall_time';
        $base['time_basis']['year_month_mode'] = $hasInstant ? 'instant_fixed_utc_plus_08' : 'compatibility_wall_time';
        $base['time_basis']['year_month_frame'] = $termFrame;
        $base['time_basis']['year_month_cst_datetime'] = null;
        if ($hasInstant) {
            $instant = $this->utcInstant($context['utc']);
            $cst = $instant->setTimezone(new DateTimeZone('+08:00'));
            $cstSolar = Solar::fromYmdHms(...array_map('intval', explode(' ', $cst->format('Y n j G i s'))));
            $termLunar = $cstSolar->getLunar();
            $termEight = $termLunar->getEightChar();
            $termEight->setSect($rules['day_sect']);
            $base['time_basis']['year_month_cst_datetime'] = $cst->format(DATE_ATOM);
        }
        $base['rules']['year_month_and_yun_frame'] = $termFrame;
        $base['rules']['day_hour_frame'] = $base['time_basis']['mode'];
        $base['pillars'] = $this->pillars($eight, $termEight, $termFrame, $base['time_basis']['mode']);
        $base['bazi'] = implode(' ', array_column($base['pillars'], 'gan_zhi'));
        $base['five_elements'] = $this->fiveElements($base['pillars']);
        $mingGong = $this->gong($termEight, $eight, false);
        $shenGong = $this->gong($termEight, $eight, true);
        $base['extensions'] = [
            'status' => 'UNVERIFIED',
            'source' => 'EightChar.php@1.4.0:getTaiYuan,getTaiXi,getMingGong,getShenGong',
            'tai_yuan' => ['gan_zhi' => $termEight->getTaiYuan(), 'na_yin' => $termEight->getTaiYuanNaYin(), 'frame' => $termFrame],
            'tai_xi' => ['gan_zhi' => $eight->getTaiXi(), 'na_yin' => $eight->getTaiXiNaYin(), 'frame' => $base['time_basis']['mode']],
            'ming_gong' => ['gan_zhi' => $mingGong, 'na_yin' => LunarUtil::$NAYIN[$mingGong], 'frame' => 'term_year_month_plus_effective_hour'],
            'shen_gong' => ['gan_zhi' => $shenGong, 'na_yin' => LunarUtil::$NAYIN[$shenGong], 'frame' => 'term_year_month_plus_effective_hour'],
            'mixed_frame_rule' => ['year_month' => $termFrame, 'day_hour' => $base['time_basis']['mode']],
        ];
        $previous = $termLunar->getPrevJie();
        $next = $termLunar->getNextJie();
        $base['solar_terms'] = [
            'oracle_status' => 'UNVERIFIED',
            'time_scale' => $termFrame,
            'previous_jie' => $this->term($previous, $hasInstant),
            'next_jie' => $this->term($next, $hasInstant),
        ];
        if ($sex === 'unknown') {
            $base['status'] = 'PARTIAL_UNVERIFIED';
            $base['yun'] = $this->unknownYun('algorithm_sex_unknown');

            return $base;
        }

        $yun = $termEight->getYunBySect($sex === 'male' ? 1 : 0, $rules['yun_sect']);
        $startCalendar = $yun->getStartSolar()->toYmdHms();
        $startInstant = $hasInstant ? new DateTimeImmutable($startCalendar, new DateTimeZone('+08:00')) : null;
        $base['status'] = 'COMPUTED_UNVERIFIED';
        $base['yun'] = [
            'status' => 'COMPUTED_UNVERIFIED',
            'algorithm_sex' => $sex,
            'forward' => $yun->isForward(),
            'start_offset' => [
                'years' => $yun->getStartYear(), 'months' => $yun->getStartMonth(),
                'days' => $yun->getStartDay(), 'hours' => $yun->getStartHour(),
            ],
            'start_solar_datetime' => str_replace(' ', 'T', $startCalendar),
            'timestamp_frame' => $termFrame,
            'start_utc' => $startInstant?->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
            'start_user_datetime' => $startInstant !== null && is_string($context['timezone'] ?? null)
                ? $startInstant->setTimezone(new DateTimeZone($context['timezone']))->format(DATE_ATOM) : null,
            'resolution' => $rules['yun_sect'] === 1 ? 'double_hour_conversion' : 'minute_conversion',
            'oracle_status' => 'UNVERIFIED',
        ];
        $base['da_yun'] = [];
        $base['liu_nian'] = [];
        foreach ($yun->getDaYunBy($rules['da_yun_count']) as $cycle) {
            $annual = [];
            foreach ($cycle->getLiuNian() as $annualCycle) {
                $entry = [
                    'year' => $annualCycle->getYear(), 'age' => $annualCycle->getAge(),
                    'gan_zhi' => $annualCycle->getGanZhi(),
                    'xun' => $annualCycle->getXun(), 'xun_kong' => $annualCycle->getXunKong(),
                    'da_yun_index' => $cycle->getIndex(),
                ];
                $annual[] = $entry;
                $base['liu_nian'][] = $entry;
            }
            $base['da_yun'][] = [
                'index' => $cycle->getIndex(),
                'kind' => $cycle->getIndex() === 0 ? 'pre_yun' : 'da_yun',
                'gan_zhi' => $cycle->getIndex() === 0 ? null : $cycle->getGanZhi(),
                'start_year' => $cycle->getStartYear(), 'end_year' => $cycle->getEndYear(),
                'start_age' => $cycle->getStartAge(), 'end_age' => $cycle->getEndAge(),
                'liu_nian' => $annual,
            ];
        }

        return $base;
    }

    private function rules(mixed $input): array
    {
        if (! is_array($input)) {
            throw new InvalidArgumentException('bazi_rules_must_be_array');
        }
        $daySect = $input['day_sect'] ?? 2;
        $yunSect = $input['yun_sect'] ?? 1;
        $count = $input['da_yun_count'] ?? 10;
        if (! in_array($daySect, [1, 2], true) || ! in_array($yunSect, [1, 2], true)
            || ! is_int($count) || $count < 2 || $count > 12) {
            throw new InvalidArgumentException('invalid_bazi_calculation_rules');
        }

        return [
            'day_sect' => $daySect,
            'day_boundary' => $daySect === 1 ? 'late_zi_next_day' : 'late_zi_current_day',
            'yun_sect' => $yunSect,
            'yun_conversion' => $yunSect === 1 ? 'days_and_double_hours' : 'minutes',
            'yun_direction' => 'yang_male_yin_female_forward_otherwise_backward',
            'year_boundary' => 'li_chun_exact', 'month_boundary' => 'jie_exact',
            'age_convention' => 'lunar_php_calendar_year_nominal_age',
            'annual_boundary' => 'li_chun_year_label_not_january_1_instant',
            'da_yun_count' => $count,
            'includes_pre_yun_index_zero' => true,
            'source' => '6tail/lunar-php:EightChar.php,Yun.php,DaYun.php,LiuNian.php@1.4.0',
        ];
    }

    private function pillars(EightChar $eight, EightChar $termEight, string $termFrame, string $dayFrame): array
    {
        $pillars = [];
        $dayMaster = $eight->getDayGan();
        // Same explicit Chang Sheng lookup/sexagenary direction as EightChar::getDiShi.
        $offsets = ['甲' => 1, '丙' => 10, '戊' => 10, '庚' => 7, '壬' => 4, '乙' => 6, '丁' => 9, '己' => 9, '辛' => 0, '癸' => 3];
        foreach (['year' => 'Year', 'month' => 'Month', 'day' => 'Day', 'hour' => 'Time'] as $key => $method) {
            $isTermPillar = in_array($key, ['year', 'month'], true);
            $source = $isTermPillar ? $termEight : $eight;
            $gan = $source->{'get'.$method.'Gan'}();
            $zhi = $source->{'get'.$method.'Zhi'}();
            $hidden = $source->{'get'.$method.'HideGan'}();
            $zhiIndex = array_search($zhi, LunarUtil::$ZHI, true) - 1;
            $diShiIndex = ($offsets[$dayMaster] + ($eight->getDayGanIndex() % 2 === 0 ? $zhiIndex : -$zhiIndex) + 12) % 12;
            $pillars[$key] = [
                'gan_zhi' => $source->{'get'.$method}(),
                'gan' => $gan, 'zhi' => $zhi,
                'hidden_stems' => $hidden,
                'ten_god_stem' => $key === 'day' ? '日主' : LunarUtil::$SHI_SHEN[$dayMaster.$gan],
                'ten_gods_hidden' => array_map(fn ($stem) => LunarUtil::$SHI_SHEN[$dayMaster.$stem], $hidden),
                'na_yin' => $source->{'get'.$method.'NaYin'}(),
                'di_shi' => EightChar::$CHANG_SHENG[$diShiIndex],
                'five_elements' => $source->{'get'.$method.'WuXing'}(),
                'frame' => $isTermPillar ? $termFrame : $dayFrame,
                'day_master_basis' => $dayMaster,
                'oracle_status' => 'UNVERIFIED',
            ];
        }

        return $pillars;
    }

    /** Replays EightChar's published Ming/Shen Gong rule with the selected mixed inputs. */
    private function gong(EightChar $termEight, EightChar $eight, bool $shen): string
    {
        $monthIndex = array_search($termEight->getMonthZhi(), EightChar::$MONTH_ZHI, true);
        $hourIndex = array_search($eight->getTimeZhi(), $shen ? LunarUtil::$ZHI : EightChar::$MONTH_ZHI, true);
        $offset = $monthIndex + $hourIndex;
        if ($shen) {
            while ($offset > 12) {
                $offset -= 12;
            }
        } else {
            $offset = ($offset >= 14 ? 26 : 14) - $offset;
        }
        $yearGanIndex = array_search($termEight->getYearGan(), LunarUtil::$GAN, true) - 1;
        $ganIndex = ($yearGanIndex + 1) * 2 + ($shen ? $offset % 12 : $offset);
        while ($ganIndex > 10) {
            $ganIndex -= 10;
        }

        return LunarUtil::$GAN[$ganIndex].EightChar::$MONTH_ZHI[$offset];
    }

    private function utcInstant(mixed $utc): DateTimeImmutable
    {
        if (! is_string($utc) || ! preg_match('/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/', $utc)) {
            throw new InvalidArgumentException('normalized_utc_instant_required');
        }
        $instant = DateTimeImmutable::createFromFormat('!Y-m-d\TH:i:s\Z', $utc, new DateTimeZone('UTC'));
        if ($instant === false || $instant->format('Y-m-d\TH:i:s\Z') !== $utc) {
            throw new InvalidArgumentException('invalid_normalized_utc_instant');
        }

        return $instant;
    }

    private function term(JieQi $term, bool $hasInstant): array
    {
        $calendar = $term->getSolar()->toYmdHms();
        $instant = $hasInstant ? new DateTimeImmutable($calendar, new DateTimeZone('+08:00')) : null;

        return [
            'name' => $term->getName(),
            'solar_datetime' => $calendar,
            'timestamp_frame' => $hasInstant ? 'UTC+08:00' : 'compatibility_wall_time',
            'cst_datetime' => $instant?->format(DATE_ATOM),
            'utc' => $instant?->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
        ];
    }

    private function fiveElements(array $pillars): array
    {
        $visible = $hidden = ['木' => 0, '火' => 0, '土' => 0, '金' => 0, '水' => 0];
        foreach ($pillars as $pillar) {
            foreach (preg_split('//u', $pillar['five_elements'], -1, PREG_SPLIT_NO_EMPTY) as $element) {
                $visible[$element]++;
            }
            foreach ($pillar['hidden_stems'] as $stem) {
                $hidden[LunarUtil::$WU_XING_GAN[$stem]]++;
            }
        }

        return [
            'interpretation' => 'symbol_distribution_not_strength_score',
            'visible_counts' => $visible,
            'hidden_stem_counts' => $hidden,
            'weighting' => 'one_per_visible_symbol_or_listed_hidden_stem_separate_counts',
            'strength_score' => null,
        ];
    }

    private function unknownYun(string $reason): array
    {
        return ['status' => 'UNKNOWN', 'reason' => $reason, 'forward' => null, 'start_offset' => null, 'start_solar_datetime' => null];
    }

    private function validateDate(mixed $date): void
    {
        if (! is_string($date) || ! preg_match('/\A(\d{4})-(\d{2})-(\d{2})\z/', $date, $parts)
            || ! checkdate((int) $parts[2], (int) $parts[3], (int) $parts[1])) {
            throw new InvalidArgumentException('invalid_bazi_effective_date');
        }
    }

    private function validateTime(mixed $time): void
    {
        if (! is_string($time) || ! preg_match('/\A([01]\d|2[0-3]):[0-5]\d:[0-5]\d\z/', $time)) {
            throw new InvalidArgumentException('invalid_bazi_effective_time');
        }
    }
}
