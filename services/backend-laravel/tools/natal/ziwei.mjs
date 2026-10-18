/** Local-only JSON adapter. Caller resolves timezone, DST/fold and any solar-time/day policy first. */
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const require = createRequire(import.meta.url);
const engineRoot = new URL('../ziwei/iztro-runner/node_modules/iztro/', import.meta.url);
const { astro, util } = require(fileURLToPath(engineRoot));
const PROFILE_ID = 'iztro-2.5.8-modern-default-v1';
const CONFIG = Object.freeze({ yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal', dayDivide: 'current', algorithm: 'default' });
const MUTAGENS = ['禄', '权', '科', '忌'];
const STEMS = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
// Backport only the three official data-error corrections, without upgrading
// the frozen 2.5.8 engine or selecting values from different school tables.
// https://github.com/SylarLong/iztro/releases/tag/v2.6.1 and issue #270.
const BRIGHTNESS_FIX_ID = 'iztro-2.5.8-with-official-2.6.1-you-data-fix-v1';
const YOU_BRIGHTNESS_FIX = Object.freeze({ '太阳': '平', '太阴': '旺', '七杀': '旺' });
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const fileHash = path => sha(readFileSync(path));
const pkg = JSON.parse(readFileSync(new URL('package.json', engineRoot), 'utf8'));
const lockPath = new URL('../ziwei/iztro-runner/package-lock.json', import.meta.url);
const lock = JSON.parse(readFileSync(lockPath, 'utf8'));

class InputError extends Error {
  constructor(code) { super(code); this.code = code; }
}
function check(condition, code) { if (!condition) throw new InputError(code); }
function dateParts(value) {
  check(typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value), 'INVALID_EFFECTIVE_DATE');
  const [year, month, day] = value.split('-').map(Number);
  check(year >= 1900 && year <= 2100, 'UNSUPPORTED_DATE_RANGE');
  const date = new Date(Date.UTC(year, month - 1, day));
  check(date.getUTCFullYear() === year && date.getUTCMonth() === month - 1 && date.getUTCDate() === day, 'INVALID_EFFECTIVE_DATE');
  return { year, month, day };
}
function timeParts(value) {
  if (value === undefined || value === null) return null;
  check(typeof value === 'string' && /^(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$/.test(value), 'INVALID_EFFECTIVE_TIME');
  const [hour, minute, second = 0] = value.split(':').map(Number);
  return { hour, minute, second, canonical: [hour, minute, second].map(v => String(v).padStart(2, '0')).join(':') };
}
function requestedProfile(value) {
  if (value === undefined) return { id: PROFILE_ID };
  if (typeof value === 'string') {
    check(value === PROFILE_ID, 'UNSUPPORTED_PROFILE');
    return { id: value };
  }
  check(value && typeof value === 'object' && !Array.isArray(value), 'UNSUPPORTED_PROFILE');
  check(Object.keys(value).length === 1 && value.id === PROFILE_ID, 'UNSUPPORTED_PROFILE');
  return { id: value.id };
}
function starData(star, branch = null) {
  const correction = branch === '酉' ? YOU_BRIGHTNESS_FIX[star.name] : undefined;
  return {
    name: star.name, type: star.type, scope: star.scope,
    brightness: correction ?? (star.brightness || null),
    brightness_status: star.brightness ? 'UNVERIFIED' : 'NOT_PROVIDED_BY_ENGINE',
    ...(correction ? { engine_brightness: star.brightness || null, brightness_correction: BRIGHTNESS_FIX_ID } : {}),
    natal_transformation: star.mutagen || null,
  };
}
export function serializeHoroscopeLayer(item, layer) {
  check(['decadal', 'age', 'yearly'].includes(layer) && item && Number.isInteger(item.index)
    && item.index >= -1 && item.index < 12
    && (item.index !== -1 || layer !== 'yearly'),
    'ENGINE_HOROSCOPE_INDEX_INVALID');
  if (item.index === -1) {
    // The engine has finite period/age tables. Its unmatched sentinel retains
    // default Jia/Zi values; they must never become a fabricated selected layer.
    return { name: item.name, calculation_status: 'NOT_APPLICABLE',
      reason_codes: ['OUTSIDE_DEFINED_PERIOD_RANGE'],
      ...(item.nominalAge === undefined ? {} : { nominalAge: item.nominalAge }) };
  }
  const result = { calculation_status: 'CALCULATED', index: item.index, name: item.name, heavenlyStem: item.heavenlyStem,
    earthlyBranch: item.earthlyBranch, palaceNames: [...item.palaceNames], mutagen: [...item.mutagen] };
  if (item.stars) result.stars = item.stars.map(stars => stars.map(starData));
  if (item.nominalAge !== undefined) result.nominalAge = item.nominalAge;
  if (item.yearlyDecStar) result.yearlyDecStar = item.yearlyDecStar;
  return result;
}

export function calculate(input) {
  check(input && typeof input === 'object' && !Array.isArray(input), 'INVALID_INPUT');
  const birth = dateParts(input.effective_civil_date);
  const time = timeParts(input.effective_time);
  check(['male', 'female', 'unknown', null, undefined].includes(input.algorithm_sex), 'INVALID_ALGORITHM_SEX');
  const requested = requestedProfile(input.requested_profile);
  if (input.target_year !== undefined && input.target_year !== null) {
    check(Number.isInteger(input.target_year) && input.target_year >= birth.year && input.target_year <= 2100, 'INVALID_TARGET_YEAR');
  }
  check(pkg.version === '2.5.8' && lock.packages['node_modules/iztro'].version === '2.5.8', 'ENGINE_VERSION_MISMATCH');
  const ruleFiles = ['lib/data/heavenlyStems.js', 'lib/data/stars.js', 'lib/star/location.js', 'lib/astro/palace.js', 'lib/astro/astro.js', 'lib/astro/FunctionalAstrolabe.js'];
  const engine = {
    name: 'iztro', version: pkg.version, license: pkg.license,
    package_json_sha256: fileHash(new URL('package.json', engineRoot)),
    package_lock_sha256: fileHash(lockPath),
    package_integrity: lock.packages['node_modules/iztro'].integrity,
    rule_file_sha256: Object.fromEntries(ruleFiles.map(path => [path, fileHash(new URL(path, engineRoot))])),
  };
  const effectiveProfile = {
    id: PROFILE_ID, ...CONFIG, fixLeap: true, language: 'zh-CN', astroType: 'heaven',
    time_basis: 'CALLER_RESOLVED_EFFECTIVE_CIVIL_TIME',
    year_boundary: 'LUNAR_NEW_YEAR', horoscope_boundary: 'LUNAR_NEW_YEAR',
    leap_month_rule: 'LEAP_DAYS_1_TO_15_CURRENT_MONTH_16_PLUS_NEXT_MONTH',
    late_zi_rule: 'CURRENT_EFFECTIVE_DATE_NO_ADDITIONAL_DAY_SHIFT',
    feng_gao_rule: 'YIN_PALACE_ZI_HOUR_FORWARD',
    flight_definition: 'SOURCE_PALACE_STEM_TO_TRANSFORMED_STAR_NATAL_PALACE',
    rule_source: 'PINNED_IZTRO_2_5_8_TABLES_AND_METHODS_WITH_OFFICIAL_YOU_BRIGHTNESS_DATA_FIX',
    brightness_correction_profile: BRIGHTNESS_FIX_ID,
    brightness_correction_source: 'https://github.com/SylarLong/iztro/releases/tag/v2.6.1',
    brightness_correction_scope: 'SUN_MOON_SEVEN_KILLINGS_AT_YOU_ONLY_NOT_FULL_ORACLE_APPROVAL',
    rule_verification: 'UNVERIFIED',
  };
  const base = {
    schema_version: 'elitesync.ziwei.natal.v1', engine, requested_profile: requested, effective_profile: effectiveProfile,
    oracle_status: 'UNVERIFIED',
    effective_input: { effective_civil_date: input.effective_civil_date, effective_time: time?.canonical ?? null,
      algorithm_sex: input.algorithm_sex ?? 'unknown', time_index: time ? util.timeToIndex(time.hour) : null },
  };
  if (!time || !['male', 'female'].includes(input.algorithm_sex)) {
    return { ...base, calculation_status: 'UNKNOWN', reason_codes: [
      ...(!time ? ['BIRTH_TIME_UNKNOWN'] : []),
      ...(!['male', 'female'].includes(input.algorithm_sex) ? ['ALGORITHM_SEX_UNKNOWN'] : []),
    ] };
  }
  const chart = astro.withOptions({ type: 'solar', dateStr: input.effective_civil_date,
    timeIndex: base.effective_input.time_index, gender: input.algorithm_sex === 'male' ? '男' : '女',
    fixLeap: true, language: 'zh-CN', astroType: 'heaven', config: CONFIG });
  const mutagenTable = STEMS.map(stem => ({ heavenly_stem: stem,
    transformations: util.getMutagensByHeavenlyStem(stem).map((star, i) => ({ transformation: MUTAGENS[i], star })) }));
  const flights = chart.palaces.flatMap(source => {
    const stars = util.getMutagensByHeavenlyStem(source.heavenlyStem);
    return stars.map((star, i) => {
      const target = chart.star(star).palace();
      check(target !== undefined, 'ENGINE_TRANSFORMATION_TARGET_MISSING');
      return { source_palace_index: source.index, source_palace: source.name, source_heavenly_stem: source.heavenlyStem,
        transformation: MUTAGENS[i], star, target_palace_index: target.index, target_palace: target.name,
        is_self_transformation: source.index === target.index, oracle_status: 'UNVERIFIED' };
    });
  });
  let selectedHoroscope = { calculation_status: 'NOT_REQUESTED' };
  if (input.target_year !== undefined && input.target_year !== null) {
    // Mid-year is explicit and safely after either lunar-new-year or Li-Chun boundary.
    // For birth-year queries use the birth instant if it is later, never an unborn reference date.
    // Decadal/age selection is AT this reference date rather than constant throughout the year.
    const midYear = `${input.target_year}-07-01`;
    const useBirthInstant = input.effective_civil_date >= midYear;
    const reference = useBirthInstant ? input.effective_civil_date : midYear;
    const referenceTime = useBirthInstant ? time.canonical : '12:00:00';
    const horoscope = chart.horoscope(`${reference} ${referenceTime}`, useBirthInstant ? base.effective_input.time_index : 6);
    selectedHoroscope = { calculation_status: 'CALCULATED', oracle_status: 'UNVERIFIED', target_year: input.target_year,
      reference_date: reference, reference_time: referenceTime, reference_policy: 'MID_YEAR_OR_BIRTH_DATE_IF_LATER',
      lunar_date: horoscope.lunarDate, decadal: serializeHoroscopeLayer(horoscope.decadal, 'decadal'),
      age: serializeHoroscopeLayer(horoscope.age, 'age'), yearly: serializeHoroscopeLayer(horoscope.yearly, 'yearly') };
  }
  return { ...base, calculation_status: 'CALCULATED',
    lunar_date: chart.lunarDate, chinese_date: chart.chineseDate, raw_dates: chart.rawDates,
    soul_palace_branch: chart.earthlyBranchOfSoulPalace, body_palace_branch: chart.earthlyBranchOfBodyPalace,
    soul_star: chart.soul, body_star: chart.body, five_elements_class: chart.fiveElementsClass,
    palaces: chart.palaces.map(p => ({ index: p.index, name: p.name, is_body_palace: p.isBodyPalace,
      is_original_palace: p.isOriginalPalace, heavenly_stem: p.heavenlyStem, earthly_branch: p.earthlyBranch,
      is_empty: p.majorStars.length === 0, major_stars: p.majorStars.map(star => starData(star, p.earthlyBranch)),
      minor_stars: p.minorStars.map(starData), adjective_stars: p.adjectiveStars.map(starData),
      changsheng12: p.changsheng12, boshi12: p.boshi12, jiangqian12: p.jiangqian12, suiqian12: p.suiqian12,
      decadal: p.decadal, nominal_ages: p.ages })),
    mutagen_table: mutagenTable, mutagen_table_sha256: sha(JSON.stringify(mutagenTable)),
    flying_transformations: flights, self_transformations: flights.filter(edge => edge.is_self_transformation),
    soul_palace_flying_transformations: flights.filter(edge => edge.source_palace === '命宫'),
    decadal_periods: chart.palaces.map(p => ({ palace_index: p.index, palace: p.name, ...p.decadal })),
    selected_horoscope: selectedHoroscope,
  };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const chunks = [];
    let length = 0;
    for await (const chunk of process.stdin) {
      length += chunk.length;
      check(length <= 65536, 'INPUT_TOO_LARGE');
      chunks.push(chunk);
    }
    let input;
    try { input = JSON.parse(Buffer.concat(chunks).toString('utf8')); }
    catch { throw new InputError('INVALID_JSON'); }
    process.stdout.write(`${JSON.stringify(calculate(input))}\n`);
  } catch (error) {
    // Do not expose user birth input, native stack traces, file paths or environment.
    process.stdout.write(`${JSON.stringify({ calculation_status: 'ERROR', oracle_status: 'UNVERIFIED',
      error_code: error instanceof InputError ? error.code : 'ENGINE_CALCULATION_FAILED' })}\n`);
    process.exitCode = 2;
  }
}
