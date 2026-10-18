"""Independent Bazi solar-term reference using admitted Skyfield/DE440s.

No lunar-php, production module, production table, network or user input.
Numerical root width is not an assertion of physical/time-model accuracy.
"""
import argparse
from contextlib import closing
import hashlib
import json
import pathlib
import sys
import numpy as np
from skyfield.api import load, load_file
from skyfield.framelib import ecliptic_frame

TERMS = [('小寒',1,6,285,11),('大寒',1,20,300,None),
 ('立春',2,4,315,0),('雨水',2,19,330,None),('惊蛰',3,6,345,1),('春分',3,21,0,None),
 ('清明',4,5,15,2),('谷雨',4,20,30,None),('立夏',5,6,45,3),('小满',5,21,60,None),
 ('芒种',6,6,75,4),('夏至',6,21,90,None),('小暑',7,7,105,5),('大暑',7,23,120,None),
 ('立秋',8,8,135,6),('处暑',8,23,150,None),('白露',9,8,165,7),('秋分',9,23,180,None),
 ('寒露',10,8,195,8),('霜降',10,23,210,None),('立冬',11,7,225,9),('小雪',11,22,240,None),
 ('大雪',12,7,255,10),('冬至',12,22,270,None)]

def reference(kernel, expected_hash, first, last):
    path=pathlib.Path(kernel)
    if hashlib.sha256(path.read_bytes()).hexdigest()!=expected_hash:
        raise ValueError('audited_kernel_hash_mismatch')
    if first<1900 or last>2101 or first>last:
        raise ValueError('explicit_modern_reference_year_range_required')
    ts=load.timescale(builtin=True)
    specs=[(year,*term) for year in range(first,last+1) for term in TERMS]
    middle=np.array([float(ts.tt(y,m,d).tt) for y,n,m,d,a,i in specs])
    target=np.array([r[4] for r in specs]);lo=middle-3.;hi=middle+3.
    with closing(load_file(str(path))) as eph:
        def residual(jd):
            time=ts.tt_jd(jd)
            _,lon,_=eph[399].at(time).observe(eph[10]).apparent().frame_latlon(ecliptic_frame)
            return (lon.degrees-target+180)%360-180
        if not np.all((residual(lo)<0)&(residual(hi)>0)):
            raise ValueError('term_root_not_uniquely_bracketed')
        for _ in range(27):
            mid=(lo+hi)/2;below=residual(mid)<0
            lo=np.where(below,mid,lo);hi=np.where(below,hi,mid)
        roots=(lo+hi)/2;instant=ts.tt_jd(roots)
        rows=[]
        for j,(year,name,month,day,angle,index) in enumerate(specs):
            t=instant[j]
            # Before 1960 there was no UTC; preserve a separately named UT1
            # label using the same frozen Skyfield DeltaT model family.
            if year<1960:
                label=t.ut1_calendar(); frame='UT1_MODEL_LABEL_PRE_1960'
            else:
                label=t.utc;frame='UTC_ERFA_TABLE_COMPATIBLE_ASSUMPTION'
            y,m,d,h,mi,s=label
            # Fractional seconds remain explicit, not rounded into fake exact
            # UTC labels or hard solar-term classification thresholds.
            rows.append(dict(year=year,name=name,longitude_degrees=angle,month_index=index,
                tt_jd=float(roots[j]),root_width_seconds=float((hi[j]-lo[j])*86400),
                civil_time_frame=frame,calendar=[int(y),int(m),int(d),int(h),int(mi),float(s)],
                source_id='SKYFIELD_DE440S_GEOCENTRIC_APPARENT_TRUE_ECLIPTIC_ROOT',
                uncertainty_seconds=60))
    return dict(schema='elitesync.independent.solar-terms.v1',kernel_sha256=expected_hash,
        years=[first,last],coordinate='geocentric apparent true ecliptic/equinox of date',
        reference_engine='Skyfield1.55;DE440s',root_width_max_seconds=max(r['root_width_seconds'] for r in rows),
        uncertainty_policy='60s comparison guard retained; numerical bisection width is not physical error certification',
        time_model='builtin Skyfield TT/DeltaT/leap tables; future leaps unknown; pre1960 UT1 label not historical UTC',
        independence='Independent astronomical engine/data from lunar-php; author has read integration code, NOT_BLIND; shared with Western subsystem, not independent observations',
        sources=['https://www.hko.gov.hk/en/gts/time/24solarterms.htm','https://rhodesmill.org/skyfield/almanac.html','https://naif.jpl.nasa.gov/naif/rules.html'],rows=rows)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--kernel',required=True);p.add_argument('--sha256',required=True)
    p.add_argument('--first',type=int,required=True);p.add_argument('--last',type=int,required=True)
    a=p.parse_args();sys.stdout.reconfigure(encoding='utf-8')
    print(json.dumps(reference(a.kernel,a.sha256,a.first,a.last),ensure_ascii=False,indent=2))
