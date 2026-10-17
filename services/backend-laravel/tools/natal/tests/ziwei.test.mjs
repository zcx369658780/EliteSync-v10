import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { calculate } from '../ziwei.mjs';

const entry = fileURLToPath(new URL('../ziwei.mjs', import.meta.url));
const require = createRequire(import.meta.url);
const { astro, util } = require('../../ziwei/iztro-runner/node_modules/iztro');
const sample = { effective_civil_date: '1990-06-15', effective_time: '10:30:00', algorithm_sex: 'male', target_year: 2026 };
function run(value, raw = false) {
  const result = spawnSync(process.execPath, [entry], { input: raw ? value : JSON.stringify(value), encoding: 'utf8' });
  assert.equal(result.stderr, '', 'stderr must not disclose input or engine traces');
  return { ...result, json: JSON.parse(result.stdout) };
}

test('official upstream three-cell brightness corrections retain raw values and unverified status', () => {
  // Inputs selected by the independent placement reference, not by engine search.
  // These assertions certify the backport contract, not an independent full brightness table.
  const fixtures = [
    ['2015-02-19', '10:30:00', 'male', 5],
    ['2015-03-05', '10:30:00', 'female', 5],
    ['2023-03-26', '04:30:00', 'female', 2],
  ];
  const corrected = new Set();
  const expected = { '太阳': ['陷', '平'], '太阴': ['不', '旺'], '七杀': ['庙', '旺'] };
  for (const [date, time, sex, timeIndex] of fixtures) {
    const input = { effective_civil_date: date, effective_time: time, algorithm_sex: sex, target_year: 2030 };
    const chart = calculate(input);
    const native = astro.withOptions({ type: 'solar', dateStr: date, timeIndex, gender: sex === 'male' ? '男' : '女',
      fixLeap: true, language: 'zh-CN', config: { yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal', dayDivide: 'current', algorithm: 'default' } });
    assert.equal(chart.engine.version, '2.5.8');
    for (const p of chart.palaces) {
      for (const star of p.major_stars) {
        const raw = native.palaces[p.index].majorStars.find(s => s.name === star.name).brightness;
        if (p.earthly_branch === '酉' && expected[star.name]) {
          assert.deepEqual([star.engine_brightness, star.brightness], expected[star.name]);
          assert.equal(star.engine_brightness, raw);
          assert.equal(star.brightness_correction, chart.effective_profile.brightness_correction_profile);
          corrected.add(star.name);
        } else {
          assert.equal(star.brightness, raw || null);
          assert.equal('brightness_correction' in star, false);
          assert.equal('engine_brightness' in star, false);
        }
        assert.equal(star.brightness_status, 'UNVERIFIED');
      }
    }
    assert.equal(chart.flying_transformations.length, 48);
    assert.equal(chart.selected_horoscope.yearly.palaceNames.length, 12);
  }
  assert.deepEqual([...corrected].sort(), Object.keys(expected).sort());
});

test('JSON-only complete engine structure with provenance, without an oracle claim', () => {
  const result = run(sample);
  assert.equal(result.status, 0);
  const chart = result.json;
  assert.equal(chart.calculation_status, 'CALCULATED');
  assert.equal(chart.oracle_status, 'UNVERIFIED');
  assert.equal(chart.engine.version, '2.5.8');
  assert.match(chart.engine.package_json_sha256, /^[a-f0-9]{64}$/);
  assert.match(chart.engine.package_lock_sha256, /^[a-f0-9]{64}$/);
  assert.equal(chart.palaces.length, 12);
  assert.equal(new Set(chart.palaces.map(p => p.name)).size, 12);
  assert.equal(chart.palaces.flatMap(p => p.major_stars).length, 14);
  assert.ok(chart.palaces.some(p => p.minor_stars.length));
  assert.ok(chart.palaces.some(p => p.adjective_stars.length));
  assert.ok(chart.palaces.some(p => p.major_stars.some(s => s.brightness)));
  assert.equal(chart.palaces.filter(p => p.is_body_palace).length, 1);
  assert.equal(chart.mutagen_table.length, 10);
  assert.ok(chart.mutagen_table.every(row => row.transformations.length === 4));
  assert.equal(chart.flying_transformations.length, 48);
  assert.equal(chart.soul_palace_flying_transformations.length, 4);
  assert.equal(chart.decadal_periods.length, 12);
  assert.equal(chart.selected_horoscope.target_year, 2026);
  assert.equal(chart.selected_horoscope.reference_date, '2026-07-01');
  assert.equal(chart.selected_horoscope.yearly.palaceNames.length, 12);
});

test('every directed flight resolves the source stem transformation to the actual target star palace', () => {
  const chart = run(sample).json;
  // This is adapter consistency testing against the pinned native API, not an independent oracle.
  const native = astro.withOptions({ type: 'solar', dateStr: sample.effective_civil_date, timeIndex: 5, gender: '男', fixLeap: true,
    language: 'zh-CN', config: { yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal', dayDivide: 'current', algorithm: 'default' } });
  for (const edge of chart.flying_transformations) {
    const source = native.palaces[edge.source_palace_index];
    const star = util.getMutagensByHeavenlyStem(source.heavenlyStem)[['禄', '权', '科', '忌'].indexOf(edge.transformation)];
    const target = native.star(star).palace();
    assert.equal(edge.star, star);
    assert.equal(edge.target_palace_index, target.index);
    assert.equal(edge.source_palace, source.name);
    assert.equal(edge.target_palace, target.name);
    assert.equal(edge.is_self_transformation, source.index === target.index);
  }
  assert.deepEqual(chart.self_transformations, chart.flying_transformations.filter(e => e.is_self_transformation));
  assert.deepEqual(chart.soul_palace_flying_transformations, chart.flying_transformations.filter(e => e.source_palace === '命宫'));
});

test('birth hour/date/algorithm sex and target year affect the corresponding real calculation', () => {
  const original = run(sample).json;
  assert.notDeepEqual(run({ ...sample, effective_time: '14:30' }).json.palaces, original.palaces);
  assert.notDeepEqual(run({ ...sample, effective_civil_date: '1991-09-23' }).json.palaces, original.palaces);
  assert.notDeepEqual(run({ ...sample, algorithm_sex: 'female' }).json.decadal_periods, original.decadal_periods);
  const nextYear = run({ ...sample, target_year: 2027 }).json;
  assert.deepEqual(nextYear.palaces, original.palaces);
  assert.notDeepEqual(nextYear.selected_horoscope.yearly, original.selected_horoscope.yearly);
});

test('unknown hour or algorithm sex yields UNKNOWN without invented chart or noon substitution', () => {
  for (const input of [{ ...sample, effective_time: null }, { ...sample, algorithm_sex: 'unknown' }]) {
    const result = run(input);
    assert.equal(result.status, 0);
    assert.equal(result.json.calculation_status, 'UNKNOWN');
    assert.equal(result.json.oracle_status, 'UNVERIFIED');
    assert.equal('palaces' in result.json, false);
  }
});

test('civil early/late Zi hours stay explicit and the caller effective date is never shifted twice', () => {
  for (const [time, expectedIndex] of [['00:00', 0], ['00:59:59', 0], ['01:00', 1], ['22:59', 11], ['23:00', 12]]) {
    const chart = run({ ...sample, effective_civil_date: '2000-02-29', effective_time: time }).json;
    assert.equal(chart.effective_input.effective_civil_date, '2000-02-29');
    assert.equal(chart.effective_input.time_index, expectedIndex);
    assert.equal(chart.effective_profile.dayDivide, 'current');
  }
});

test('supported domain endpoints and valid leap date remain calculated but explicitly unverified', () => {
  for (const date of ['1900-01-01', '1901-01-01', '2000-02-29', '2100-12-31']) {
    const result = run({ ...sample, effective_civil_date: date, target_year: null });
    assert.equal(result.status, 0);
    assert.equal(result.json.calculation_status, 'CALCULATED');
    assert.equal(result.json.oracle_status, 'UNVERIFIED');
    assert.equal(result.json.palaces.length, 12);
    assert.equal(result.json.selected_horoscope.calculation_status, 'NOT_REQUESTED');
  }
  assert.equal(run({ ...sample, effective_civil_date: '2100-02-29', target_year: null }).status, 2);
});

test('a birth-year selected horoscope never queries a date before birth', () => {
  const chart = run({ ...sample, effective_civil_date: '2000-12-31', target_year: 2000 }).json;
  assert.equal(chart.selected_horoscope.reference_date, '2000-12-31');
  assert.equal(chart.selected_horoscope.reference_policy, 'MID_YEAR_OR_BIRTH_DATE_IF_LATER');
});

test('invalid JSON, dates, times, range, sex, target and unsupported rule overrides fail closed', () => {
  const bad = [[], null, { ...sample, effective_civil_date: '2001-02-29' }, { ...sample, effective_civil_date: '1800-01-01' },
    { ...sample, effective_time: '24:00' }, { ...sample, effective_time: '10:60' }, { ...sample, algorithm_sex: 'M' },
    { ...sample, target_year: 2101 }, { ...sample, target_year: 1989 }, { ...sample, requested_profile: { algorithm: 'zhongzhou' } }];
  for (const input of bad) {
    const result = run(input);
    assert.equal(result.status, 2);
    assert.equal(result.json.calculation_status, 'ERROR');
    assert.ok(result.json.error_code);
    assert.equal('palaces' in result.json, false);
  }
  assert.equal(run('{broken', true).status, 2);
  assert.equal(run('x'.repeat(65537), true).status, 2);
});
