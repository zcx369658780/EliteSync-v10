<?php

namespace Tests\Unit;

use App\Services\NatalBaziCalculator;
use App\Services\NatalBaziLuckProjection;
use App\Services\NatalBaziTimeScale;
use com\nlf\calendar\Solar;
use DateTimeImmutable;
use DateTimeZone;
use PHPUnit\Framework\TestCase;

/** Discrete adapter/compatibility checks. Independent astronomy is a separate receipt. */
class V1010NatalBaziTimeScaleTest extends TestCase
{
    public function test_shen_gong_chou_uses_the_selected_year_five_tigers_stem(): void
    {
        // Given-year Five Tigers: 甲己丙寅 ...; advance eleven branches to 丑.
        // Literal expectations, not the library's getShenGong output.
        $stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
        $expected = ['丁丑', '己丑', '辛丑', '癸丑', '乙丑', '丁丑', '己丑', '辛丑', '癸丑', '乙丑'];
        $method = new \ReflectionMethod(NatalBaziCalculator::class, 'gong');
        $calculator = new NatalBaziCalculator;
        foreach ($stems as $i => $stem) {
            $eight = Solar::fromYmdHms(1985 + $i, 1, 15, 22, 30, 0)->getLunar()->getEightChar();
            $this->assertSame($stem, $eight->getYearGan());
            $this->assertSame($expected[$i], $method->invoke($calculator, $eight, $eight, true));
        }
    }

    public function test_raw_jie_partition_is_half_open_including_all_twelve_boundaries(): void
    {
        $scale = new NatalBaziTimeScale;
        $terms = $scale->roots(2100);
        $tested = 0;
        foreach ($terms as $i => $term) {
            if (substr($term['id'], 0, 4) !== '2100') {
                continue;
            }
            $tt = $term['tt_jd'];
            $this->assertSame($terms[$i - 1]['id'], $scale->bracket($terms, [$tt[0], $tt[1] - 1 / 86400])['previous_jie']['id']);
            $this->assertSame($term['id'], $scale->bracket($terms, $tt)['previous_jie']['id']);
            $this->assertSame($term['id'], $scale->bracket($terms, [$tt[0], $tt[1] + 1 / 86400])['previous_jie']['id']);
            $tested++;
        }
        $this->assertSame(12, $tested);
    }

    public function test_yun_projection_replays_library_with_identical_civil_endpoints(): void
    {
        // This validates only the projection rewrite, not library term timestamps.
        foreach (['1901-01-01 00:00:00', '1961-07-31 23:59:59', '2000-02-29 01:00:00',
            '2024-12-31 23:30:59', '2100-03-01 00:00:01'] as $label) {
            $birth = new DateTimeImmutable($label, new DateTimeZone('+08:00'));
            $eight = Solar::fromYmdHms(...array_map('intval', explode(' ', $birth->format('Y n j G i s'))))->getLunar()->getEightChar();
            $terms = [];
            foreach (['previous_jie' => $eight->getLunar()->getPrevJie(), 'next_jie' => $eight->getLunar()->getNextJie()] as $key => $term) {
                $terms[$key] = ['cst_datetime' => (new DateTimeImmutable($term->getSolar()->toYmdHms(), new DateTimeZone('+08:00')))->format(DATE_ATOM)];
            }
            foreach (['male', 'female'] as $sex) {
                foreach ([1, 2] as $sect) {
                    $result = (new NatalBaziLuckProjection)->compute(['utc' => $birth->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
                        'timezone' => 'America/New_York', 'algorithm_sex' => $sex], $eight, $terms,
                        ['yun_sect' => $sect, 'yun_calendar_policy' => [], 'da_yun_count' => 10]);
                    $old = $eight->getYunBySect($sex === 'male' ? 1 : 0, $sect);
                    $this->assertSame($old->isForward(), $result['yun']['forward']);
                    $this->assertSame(['years' => $old->getStartYear(), 'months' => $old->getStartMonth(), 'days' => $old->getStartDay(),
                        'hours' => $old->getStartHour()], $result['yun']['start_offset']);
                    $this->assertSame(str_replace(' ', 'T', $old->getStartSolar()->toYmdHms()), $result['yun']['start_solar_datetime']);
                    foreach ($old->getDaYunBy(10) as $cycle) {
                        $row = $result['da_yun'][$cycle->getIndex()];
                        $this->assertSame($cycle->getStartYear(), $row['start_year']);
                        $this->assertSame($cycle->getEndYear(), $row['end_year']);
                        $this->assertSame($cycle->getStartAge(), $row['start_age']);
                        $this->assertSame($cycle->getEndAge(), $row['end_age']);
                        $this->assertSame($cycle->getIndex() === 0 ? null : $cycle->getGanZhi(), $row['gan_zhi']);
                        foreach ($cycle->getLiuNian() as $j => $annual) {
                            $this->assertSame($annual->getGanZhi(), $row['liu_nian'][$j]['gan_zhi']);
                            $this->assertSame($annual->getXun(), $row['liu_nian'][$j]['xun']);
                            $this->assertSame($annual->getXunKong(), $row['liu_nian'][$j]['xun_kong']);
                            $this->assertSame($annual->getAge(), $row['liu_nian'][$j]['age']);
                        }
                    }
                }
            }
        }
    }
}
