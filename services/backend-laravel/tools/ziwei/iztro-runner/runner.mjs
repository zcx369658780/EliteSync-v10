import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { astro } = require('iztro');

const STRICT_MAIN_STARS = new Set([
  '紫微',
  '天机',
  '太阳',
  '武曲',
  '天同',
  '廉贞',
  '天府',
  '太阴',
  '贪狼',
  '巨门',
  '天相',
  '天梁',
  '七杀',
  '破军',
]);

const PALACE_ALIASES = {
  仆役: '交友',
  仆役宫: '交友宫',
};

const UNSUPPORTED_POLICY_WARNINGS = [
  'true_solar_time_must_be_precomputed_outside_iztro',
  'dst_must_be_resolved_outside_iztro',
  'timezone_must_be_resolved_outside_iztro',
  'birthplace_geocode_must_be_resolved_outside_iztro',
  'timeIndex_is_policy_decisive_and_must_be_final_before_iztro_call',
  'zi_hour_cross_day_policy_not_validated_by_a_b_c_samples',
];

function readStdin() {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => {
      data += chunk;
    });
    process.stdin.on('end', () => resolve(data));
    process.stdin.on('error', reject);
  });
}

function jsonOut(payload) {
  process.stdout.write(`${JSON.stringify(payload)}\n`);
}

function normalizeDate(value) {
  if (typeof value !== 'string' || value.trim() === '') {
    return '';
  }

  return value.trim().replace(/-0(\d)/g, '-$1');
}

function normalizePalaceName(name) {
  return PALACE_ALIASES[name] || name || '';
}

function starName(star) {
  if (typeof star === 'string') {
    return star.trim();
  }

  if (star && typeof star === 'object' && typeof star.name === 'string') {
    return star.name.trim();
  }

  return '';
}

function strictMainStars(stars) {
  const names = [];

  for (const star of stars || []) {
    const name = starName(star);
    if (STRICT_MAIN_STARS.has(name) && !names.includes(name)) {
      names.push(name);
    }
  }

  return names;
}

function diagnostics(stars) {
  return (stars || []).map((star) => ({
    name: starName(star),
    brightness: star?.brightness || '',
    mutagen: star?.mutagen || '',
    type: star?.type || '',
    scope: star?.scope || '',
  })).filter((star) => star.name !== '');
}

function buildChart(input) {
  const calendarType = input.calendar_type || 'solar';
  const gender = input.gender_for_iztro || input.gender;
  const timeIndex = Number(input.timeIndex);
  const language = input.language || 'zh-CN';
  const fixLeap = input.fixLeap ?? true;

  if (!Number.isInteger(timeIndex) || timeIndex < 0 || timeIndex > 12) {
    throw new Error('invalid_timeIndex');
  }

  if (!['男', '女'].includes(gender)) {
    throw new Error('invalid_gender_for_iztro');
  }

  astro.config({
    algorithm: input.algorithm || 'default',
    yearDivide: input.yearDivide || 'normal',
    dayDivide: input.dayDivide || 'current',
    horoscopeDivide: input.horoscopeDivide || 'normal',
  });

  if (calendarType === 'lunar') {
    const lunarDate = normalizeDate(input.lunar_date);
    if (lunarDate === '') {
      throw new Error('missing_lunar_date');
    }

    return astro.byLunar(lunarDate, timeIndex, gender, Boolean(input.is_leap_month), fixLeap, language);
  }

  const solarDate = normalizeDate(input.gregorian_date);
  if (solarDate === '') {
    throw new Error('missing_gregorian_date');
  }

  return astro.bySolar(solarDate, timeIndex, gender, fixLeap, language);
}

function adaptChart(chart, input) {
  const palaces = (chart.palaces || []).map((palace) => {
    const mainStars = strictMainStars(palace.majorStars);

    return {
      palace_name: normalizePalaceName(palace.name),
      source_palace_name: palace.name || '',
      branch: palace.earthlyBranch || '',
      main_stars: mainStars,
      empty_main_star_status: mainStars.length === 0
        ? 'no_14_main_star_in_strict_subset'
        : 'none',
      diagnostic_auxiliary_stars: [
        ...diagnostics(palace.minorStars),
        ...diagnostics(palace.adjectiveStars),
      ],
      diagnostic_four_transformations: diagnostics(palace.majorStars)
        .filter((star) => star.mutagen !== '')
        .map((star) => ({ star: star.name, mutagen: star.mutagen, brightness: star.brightness })),
      diagnostic_flying_star_capabilities: {
        status: 'diagnostic_only_not_accepted',
      },
    };
  });

  return {
    success: true,
    algorithm_route: 'third_party_candidate_iztro_shadow_tool',
    algorithm_version: 'iztro@2.5.8',
    source_policy: input.source_policy_version || '6.2g_iztro_shadow_adapter_policy_v1',
    input_policy: {
      gregorian_date: input.gregorian_date || null,
      civil_birth_time: input.civil_birth_time || null,
      normalized_chart_time: input.normalized_chart_time || null,
      normalized_time_branch: input.normalized_time_branch || null,
      timeIndex: input.timeIndex,
      calendar_type: input.calendar_type || 'solar',
      lunar_date: input.lunar_date || null,
      algorithm: input.algorithm || 'default',
      yearDivide: input.yearDivide || 'normal',
      dayDivide: input.dayDivide || 'current',
      horoscopeDivide: input.horoscopeDivide || 'normal',
      language: input.language || 'zh-CN',
      upstream_normalization_required: [
        'birthplace_geocode',
        'timezone',
        'dst',
        'true_solar_time',
        'final_timeIndex',
      ],
    },
    lunar_date: chart.lunarDate || null,
    four_pillars: {
      status: 'diagnostic_only',
      chinese_date: chart.chineseDate || null,
    },
    life_palace: {
      branch: chart.earthlyBranchOfSoulPalace || '',
    },
    body_palace: {
      branch: chart.earthlyBranchOfBodyPalace || '',
    },
    five_element_bureau: chart.fiveElementsClass || '',
    life_master: chart.soul || '',
    body_master: chart.body || '',
    palaces,
    warnings: UNSUPPORTED_POLICY_WARNINGS,
    limitations: [
      'shadow_only_no_user_facing_replacement',
      'no_db_write',
      'no_matching_or_scoring_use',
      'auxiliary_four_transform_brightness_flying_star_out_of_scope',
    ],
    display_only: true,
    external_oracle_status: 'not_validated',
    scoring_status: 'excluded_from_core_matching',
    production_runtime_enabled: false,
    user_facing_enabled: false,
    dependency_adopted: 'shadow_tool_only',
  };
}

try {
  const raw = await readStdin();
  const input = JSON.parse(raw || '{}');
  const chart = buildChart(input);
  jsonOut(adaptChart(chart, input));
} catch (error) {
  jsonOut({
    success: false,
    algorithm_version: 'iztro@2.5.8',
    error_code: 'iztro_runner_error',
    error_message: error instanceof Error ? error.message : 'unknown_error',
    warnings: UNSUPPORTED_POLICY_WARNINGS,
    display_only: true,
    external_oracle_status: 'not_validated',
    scoring_status: 'excluded_from_core_matching',
    production_runtime_enabled: false,
    user_facing_enabled: false,
    dependency_adopted: 'shadow_tool_only',
  });
  process.exitCode = 1;
}
