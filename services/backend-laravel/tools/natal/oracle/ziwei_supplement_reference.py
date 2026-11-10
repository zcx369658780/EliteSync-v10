#!/usr/bin/env python3
"""Independent source-only supplementary Ziwei oracle. No product imports/values.
Usage: python reference.py ORACLE_DIRECTORY OUTPUT_JSON
Reads only the four explicitly authorized independent files. Lunar validity is
inherited from supplied HKO evidence; no calendar conversion is performed.
"""
import hashlib
import json
import sys
from pathlib import Path

STEMS = '甲乙丙丁戊己庚辛壬癸'
BRANCHES = '子丑寅卯辰巳午未申酉戌亥'
NAYIN = '金火木土金火水土金木水土火木水金火木土金火水土金木水土火木水'
BUREAUS = {'水': 2, '木': 3, '金': 4, '土': 5, '火': 6}
LU = [2, 3, 5, 6, 5, 6, 8, 9, 11, 0]
BOSHI = ['博士', '力士', '青龙', '小耗', '将军', '奏书', '飞廉', '喜神', '病符', '大耗', '伏兵', '官府']
CLASSICAL_URL = 'https://zh.wikisource.org/zh/紫微斗數全書/卷二'
FILES = ['ziwei_reference.py', 'ziwei_reference_sources.json', 'ziwei_minor_rule_sources.json', 'ziwei_legal_reference_inputs.json']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def idx(value, alphabet):
    if type(value) is int and 0 <= value < len(alphabet):
        return value
    if type(value) is str and len(value) == 1 and value in alphabet:
        return alphabet.index(value)
    raise ValueError('Invalid independent stem/branch input')


def base(data):
    # Independent base arithmetic from authorized rule oracle, not its outputs.
    year, month, day = [data[k] for k in ('lunarYear', 'lunarMonth', 'lunarDay')]
    if any(type(v) is not int for v in (year, month, day)):
        raise ValueError('Lunar input type')
    if not 1 <= month <= 12 or not 1 <= day <= 30 or type(data['leapMonth']) is not bool:
        raise ValueError('Lunar input range')
    stem, branch, hour = idx(data['yearStem'], STEMS), idx(data['yearBranch'], BRANCHES), idx(data['hourBranch'], BRANCHES)
    if stem != (year-4) % 10 or branch != (year-4) % 12:
        raise ValueError('Year stem/branch disagreement')
    if data['algorithmSex'] not in ('male', 'female'):
        raise ValueError('Sex input')
    effective_month = month + int(data['leapMonth'] and day > 15)
    anchor = (effective_month + 1) % 12
    life, body = (anchor-hour) % 12, (anchor+hour) % 12
    life_stem = (2*(stem % 5)+2+(life-2) % 12) % 10
    cycle = next(i for i in range(60) if i % 10 == life_stem and i % 12 == life)
    bureau = BUREAUS[NAYIN[cycle//2]]
    return stem, branch, life, body, bureau


def chart(case, rules):
    data = case['independent_lunar_input']
    stem, branch, life, body, bureau = base(data)
    positions = {}
    for group, key, index in [('yearStemRules', 'positions', stem), ('yearBranchRules', 'positions', branch)]:
        for name, rule in rules[group].items():
            positions[name] = rule[key][index]
    positions.update({'天才': (life+branch) % 12, '天寿': (body+branch) % 12})
    not_asserted = {}
    for name, rule in rules['monthRules'].items():
        if data['leapMonth']:
            not_asserted[name] = 'NOT_ASSERTED: source leapMonth policy UNKNOWN'
        else:
            positions[name] = rule['monthPositions'][data['lunarMonth']-1]
    # 卷二: 寅午戌辰, 申子辰戌, 巳酉丑未, 亥卯未丑.
    small_start = [10, 7, 4, 1][branch % 4]
    small_direction = 1 if data['algorithmSex'] == 'male' else -1
    ages = sorted({1, 2, 11, 12, 13, 31, bureau-1, bureau, bureau+1})
    small_limits = [{'nominalAge': age, 'branchIndex': (small_start+small_direction*(age-1)) % 12} for age in ages]
    boshi_direction = 1 if ((stem % 2 == 0) == (data['algorithmSex'] == 'male')) else -1
    return {
        'id': case['id'], 'split': case['split'], 'input': data,
        'calendarEvidence': {'source': case['source'], 'source_rule': case['source_rule'], 'solar': case['solar']},
        'independentBase': {'lifeBranchIndex': life, 'bodyBranchIndex': body, 'bureauNumber': bureau},
        'additionalStarPositions': dict(sorted(positions.items())),
        'notAsserted': not_asserted,
        'smallLimit': {'nominalAgeOneStartBranchIndex': small_start, 'direction': small_direction, 'ages': small_limits},
        'boshiTwelve': {'luCunBranchIndex': LU[stem], 'direction': boshi_direction,
                        'starPositions': {name: (LU[stem]+boshi_direction*i) % 12 for i, name in enumerate(BOSHI)}},
    }


def main():
    root, out = Path(sys.argv[1]), Path(sys.argv[2])
    hashes = {name: sha(root/name) for name in FILES}
    source = json.loads((root/FILES[1]).read_text(encoding='utf-8-sig'))
    rules = json.loads((root/FILES[2]).read_text(encoding='utf-8-sig'))
    inputs = json.loads((root/FILES[3]).read_text(encoding='utf-8-sig'))
    if type(inputs) is not list or len(inputs) != 72:
        raise ValueError('Expected precisely 72 independent legal inputs')
    if len({case['id'] for case in inputs}) != 72:
        raise ValueError('Duplicate case IDs')
    rows = [chart(case, rules) for case in inputs]
    unknown = {
        'additionalMonthDayStarLeapPolicy': rules['leapMonth'],
        'unresolvedNamedAdditionalStars': rules['unresolved'],
        'baseUnknown': ['brightness', 'unlistedMinorStars', 'calendarConversion', 'lunarMonthExistenceAndLength', 'birthTimeConversion', 'interpretation'],
        'sourceLimitations': source['limitations'],
        'excluded': {'恩光': 'NOT_ASSERTED: day1 exceptional handling not established', '天贵': 'NOT_ASSERTED: day1 exceptional handling not established'},
        'otherModernSmallLimitFields': 'UNKNOWN; only specified branch placement and ages asserted',
        'otherModernBoshiFields': 'UNKNOWN; only specified sequence, direction, LuCun anchor asserted',
    }
    result = {
        'oracle': 'independent-ziwei-15-additional-smalllimit-boshi-v1',
        'sourceHashesSha256': hashes,
        'referenceSha256': sha(Path(__file__)),
        'provenance': {'additionalRules': rules['sources'], 'smallLimitAndBoshi': CLASSICAL_URL,
                       'classicalFactsSuppliedByParent': True, 'networkRetrieval': 'NOT_RUN',
                       'boshiVariantMapping': {'天耗': '大耗'},
                       'variantMappingScope': 'Explicit synonym for this sequence only; certifies no other modern field',
                       'leapBase': source['explicitProfileChoices']['leapMonth'],
                       'lineage': rules['upstreamLineage'],
                       '蜚廉与飞廉': 'Different names/rules retained separately'},
        'counts': {'cases': len(rows), 'fresh': sum(c['split']=='fresh' for c in rows), 'blind': sum(c['split']=='blind' for c in rows),
                   'nonLeapCases': sum(not c['input']['leapMonth'] for c in rows), 'leapCases': sum(c['input']['leapMonth'] for c in rows),
                   'additionalPositionAssertions': sum(len(c['additionalStarPositions']) for c in rows),
                   'monthNotAssertedCells': sum(len(c['notAsserted']) for c in rows),
                   'smallLimitAgeAssertions': sum(len(c['smallLimit']['ages']) for c in rows),
                   'boshiPositionAssertions': 12*len(rows),
                   'day1Cases': sum(c['input']['lunarDay']==1 for c in rows), 'day2Cases': sum(c['input']['lunarDay']==2 for c in rows)},
        'limits': unknown, 'cases': rows,
    }
    with out.open('x', encoding='utf-8', newline='\n') as handle:
        json.dump(result, handle, ensure_ascii=False, sort_keys=True, indent=2)
        handle.write('\n')
    print(json.dumps({'counts': result['counts'], 'referenceSha256': result['referenceSha256'], 'expectedSha256': sha(out)}, ensure_ascii=False))


if __name__ == '__main__':
    main()