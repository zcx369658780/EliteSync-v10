import test from 'node:test';
import assert from 'node:assert/strict';
import { calculate, serializeHoroscopeLayer } from '../ziwei.mjs';

test('exhausted selected periods expose no default JiaZi or negative palace index', () => {
  const chart = calculate({ effective_civil_date: '1901-03-01', effective_time: '12:30:00',
    algorithm_sex: 'male', target_year: 2100 });
  assert.equal(chart.calculation_status, 'CALCULATED');
  assert.equal(chart.palaces.length, 12);
  assert.equal(chart.selected_horoscope.age.nominalAge, 200);
  for (const layer of ['decadal', 'age']) {
    const result = chart.selected_horoscope[layer];
    assert.equal(result.calculation_status, 'NOT_APPLICABLE');
    assert.deepEqual(result.reason_codes, ['OUTSIDE_DEFINED_PERIOD_RANGE']);
    for (const field of ['index', 'heavenlyStem', 'earthlyBranch', 'palaceNames', 'mutagen', 'stars']) {
      assert.equal(field in result, false, `unavailable ${layer} must not fabricate ${field}`);
    }
  }
  assert.equal(chart.selected_horoscope.yearly.calculation_status, 'CALCULATED');
  assert.equal(chart.selected_horoscope.yearly.heavenlyStem, '庚');
  assert.equal(chart.selected_horoscope.yearly.earthlyBranch, '申');
});

test('small-limit boundary preserves the valid decade and yearly layers', () => {
  const birth = { effective_civil_date: '1901-03-01', effective_time: '12:30:00', algorithm_sex: 'male' };
  const last = calculate({ ...birth, target_year: 2020 });
  const next = calculate({ ...birth, target_year: 2021 });
  assert.equal(last.selected_horoscope.age.nominalAge, 120);
  assert.equal(last.selected_horoscope.age.calculation_status, 'CALCULATED');
  assert.ok(last.selected_horoscope.age.index >= 0 && last.selected_horoscope.age.index < 12);
  assert.equal(next.selected_horoscope.age.nominalAge, 121);
  assert.equal(next.selected_horoscope.age.calculation_status, 'NOT_APPLICABLE');
  assert.equal(next.selected_horoscope.decadal.calculation_status, 'CALCULATED');
  assert.equal(next.selected_horoscope.yearly.calculation_status, 'CALCULATED');
  assert.equal(next.selected_horoscope.oracle_status, 'UNVERIFIED');
});

test('negative yearly indices and malformed engine outputs remain errors', () => {
  for (const value of [null, {}, { index: -2 }, { index: 12 }, { index: 0.5 }, { index: -1 }]) {
    assert.throws(() => serializeHoroscopeLayer(value, 'yearly'),
      error => error.code === 'ENGINE_HOROSCOPE_INDEX_INVALID');
  }
  for (const layer of ['decadal', 'age']) {
    assert.equal(serializeHoroscopeLayer({ index: -1, name: '运限' }, layer).calculation_status, 'NOT_APPLICABLE');
  }
});
