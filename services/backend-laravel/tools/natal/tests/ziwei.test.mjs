import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const entry = fileURLToPath(new URL('../ziwei.mjs', import.meta.url));
const require = createRequire(import.meta.url);
const { astro, util } = require('../../ziwei/iztro-runner/node_modules/iztro');
const sample = { effective_civil_date: '1990-06-15', effective_time: '10:30:00', algorithm_sex: 'male', target_year: 2026 };
function run(value, raw = false) {
  const result = spawnSync(process.execPath, [entry], { input: raw ? value : JSON.stringify(value), encoding: 'utf8' });
  assert.equal(result.stderr, '', 'stderr must not disclose input or engine traces');
  return { ...result, json: JSON.parse(result.stdout) };
}

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
