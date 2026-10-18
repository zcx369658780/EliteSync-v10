#!/usr/bin/env python3
"""Independent selected modern ChangSheng rule; no product or actual reads.
Usage: python changsheng-reference.py AUTHORIZED_ORACLE_DIRECTORY OUTPUT_JSON
"""
import hashlib
import json
import sys
from pathlib import Path

STEMS = '甲乙丙丁戊己庚辛壬癸'
BRANCHES = '子丑寅卯辰巳午未申酉戌亥'
NAYIN = '金火木土金火水土金木水土火木水金火木土金火水土金木水土火木水'
BUREAUS = {'水':2,'木':3,'金':4,'土':5,'火':6}
STARTS = {2:8,3:11,4:5,5:8,6:2}
SEQUENCE = ['长生','沐浴','冠带','临官','帝旺','衰','病','死','墓','绝','胎','养']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def idx(value, alphabet):
    if type(value) is int and 0 <= value < len(alphabet):
        return value
    if type(value) is str and len(value) == 1 and value in alphabet:
        return alphabet.index(value)
    raise ValueError('Invalid stem/branch')


def base(data):
    year,month,day = [data[k] for k in ['lunarYear','lunarMonth','lunarDay']]
    if any(type(v) is not int for v in [year,month,day]):
        raise ValueError('Lunar input type')
    if not 1 <= month <= 12 or not 1 <= day <= 30 or type(data['leapMonth']) is not bool:
        raise ValueError('Lunar input range')
    stem,branch,hour = idx(data['yearStem'],STEMS),idx(data['yearBranch'],BRANCHES),idx(data['hourBranch'],BRANCHES)
    if stem != (year-4)%10 or branch != (year-4)%12:
        raise ValueError('Year stem/branch disagreement')
    if data['algorithmSex'] not in ['male','female']:
        raise ValueError('Algorithm sex')
    effective_month = month+int(data['leapMonth'] and day > 15)
    anchor = (effective_month+1)%12
    life,body = (anchor-hour)%12,(anchor+hour)%12
    life_stem = (2*(stem%5)+2+(life-2)%12)%10
    cycle = next(i for i in range(60) if i%10 == life_stem and i%12 == life)
    bureau = BUREAUS[NAYIN[cycle//2]]
    return {'yearStemIndex':stem,'yearBranchIndex':branch,'lifeBranchIndex':life,
            'bodyBranchIndex':body,'bureauNumber':bureau,'element':NAYIN[cycle//2]}


def placement(bureau,stem,sex):
    if bureau not in STARTS or type(stem) is not int or not 0 <= stem < 10 or sex not in ['male','female']:
        raise ValueError('Invalid pure rule parameters')
    direction = 1 if ((stem%2 == 0) == (sex == 'male')) else -1
    at = {}
    branch = STARTS[bureau]
    for stage in SEQUENCE:
        at[branch] = stage
        branch += direction
        if branch == 12:
            branch = 0
        elif branch == -1:
            branch = 11
    assert branch == STARTS[bureau]
    assert set(at) == set(range(12))
    assert set(at.values()) == set(SEQUENCE)
    return {'bureauNumber':bureau,'yearStemIndex':stem,'yearStem':STEMS[stem],
            'algorithmSex':sex,'startBranchIndex':STARTS[bureau],'direction':direction,
            'expectedByBranch':[{'branchIndex':b,'branch':BRANCHES[b],'changSheng':at[b]} for b in range(12)]}


def main():
    root,out = Path(sys.argv[1]),Path(sys.argv[2])
    input_path = root/'ziwei_legal_reference_inputs.json'
    source_path = root/'ziwei_reference_sources.json'
    inputs = json.loads(input_path.read_text(encoding='utf-8-sig'))
    sources = json.loads(source_path.read_text(encoding='utf-8-sig'))
    if type(inputs) is not list or len(inputs) != 72 or len({r['id'] for r in inputs}) != 72:
        raise ValueError('Expected 72 unique HKO legal inputs')
    legal = []
    for case in inputs:
        data = case['independent_lunar_input']
        natal = base(data)
        legal.append({'id':case['id'],'split':case['split'],'independentLunarInput':data,'independentBase':natal,
                      'calendarProvenance':{'source':case['source'],'source_rule':case['source_rule'],'solar':case['solar']},
                      'expected':placement(natal['bureauNumber'],natal['yearStemIndex'],data['algorithmSex'])})
    pure = [{'id':f'pure-bureau-{bureau}-stem-{stem}-{sex}','inputKind':'NOT_A_CIVIL_DATE',
             'expected':placement(bureau,stem,sex)}
            for bureau in [2,3,4,5,6] for stem in range(10) for sex in ['male','female']]
    assert len(pure) == 100
    result = {
        'oracle':'independent-selected-modern-changsheng-v1','referenceSha256':sha(Path(__file__)),
        'sourceHashesSha256':{'ziwei_legal_reference_inputs.json':sha(input_path),'ziwei_reference_sources.json':sha(source_path)},
        'sourceProvenance':{
            'url':'https://www.ziweicn.com/show/3085.html','section':'38',
            'sourceReadByParent':True,'thisScriptNetworkAccess':'NOT_RUN',
            'sourceType':'Modern secondary source; Zhongzhou author rule statement; not iztro documentation',
            'shortFacts':['Use life palace five-element bureau',
                          'Water2/Earth5 start Shen; Wood3 Hai; Metal4 Si; Fire6 Yin',
                          'Jia/Bing/Wu/Geng/Ren are yang stems',
                          'Yang male/yin female forward; yin male/yang female reverse'],
            'sequence':SEQUENCE,
            'programUpstream':'UNKNOWN','wholeSchoolEquivalence':'NOT_ASSERTED',
            'variantsPreserved':['Classical male-forward/female-reverse variant',
                                 'Birth-year NaYin with universally-forward variant'],
            'variantScope':'Retained distinct source variants; no claim of a unified rule across the whole classical book',
            'baseLeapPolicy':sources['explicitProfileChoices']['leapMonth'],
            'method':'Own arithmetic for independent natal bureau; own branch-step loop for twelve stages'},
        'counts':{'legalHkoCases':72,'fresh':sum(r['split']=='fresh' for r in legal),'blind':sum(r['split']=='blind' for r in legal),
                  'legalBranchExpectedCells':864,'pureRuleCases':100,'pureBranchExpectedCells':1200,
                  'pureBureaus':5,'pureYearStems':10,'pureSexInputs':2},
        'limits':['Selected modern Section38 rule only; no whole-school or target-profile equivalence certification',
                  'Program upstream UNKNOWN; no iztro lineage independence certification',
                  '100 pure rules are NOT_A_CIVIL_DATE; no calendar legality claim',
                  '72 input legality inherited from HKO reference provenance; no new calendar conversion',
                  'Independent natal bureau/leap policy inherited from established independent base',
                  'No production/iztro/actual consulted; product comparison NOT_RUN',
                  'No brightness, interpretation or scientific prediction validity claim'],
        'legalCases':legal,'pureRuleCases':pure}
    with out.open('x',encoding='utf-8',newline='\n') as handle:
        json.dump(result,handle,ensure_ascii=False,sort_keys=True,indent=2)
        handle.write('\n')
    print(json.dumps({'counts':result['counts'],'referenceSha256':result['referenceSha256'],'jsonSha256':sha(out)},ensure_ascii=False))


if __name__ == '__main__':
    main()
