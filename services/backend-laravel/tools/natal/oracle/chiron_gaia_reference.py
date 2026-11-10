"""Offline external Gaia solution / independent force / DOP853 / ERFA reference.

No product engine/data is read, no network is used, and no data permission is
granted here. Supply the separately admitted Gaia one-object response locally.
This is independent software, not an independent physical force model or a
continuous century uncertainty guarantee. The main reference author is NOT_BLIND.
"""
import argparse
import datetime as dt
import hashlib
import importlib.metadata
import types
import json
import math
from pathlib import Path
import re
import numpy as np
import erfa
from jplephem.spk import SPK
from skyfield.api import load

AU=149597870.700;DAY=86400.;C=299792.458*DAY/AU

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

class GaiaReference:
    def __init__(self,kernel_path,gm_path,gaia_path):
        kernel,gm,gaia=map(Path,(kernel_path,gm_path,gaia_path))
        force=Path(__file__).with_name('chiron_force_reference.py')
        self.source_roles={'kernel':kernel,'gm':gm,'gaia':gaia,'force':force}
        self.pins={kernel:'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2',
            gm:'924ddf4fb9ead9fe8a1aa55780bcabde40b09d00065d58226e24b68d8092f140',
            gaia:'be29b90a286b049717dd72a482c626bb15ad24aeed6214db63b108ad60448b69',
            force:'f984fc4724fe9b689f00f201e70ecfa81a25d3e2abeff7a6ac60c90179ea0acf'}
        for path,digest in self.pins.items():
            if sha(path)!=digest:raise ValueError('fixed reference input identity mismatch: '+path.name)
        for name,version in {'scipy':'1.16.3','numpy':'2.4.6','skyfield':'1.55','pyerfa':'2.0.1.5','jplephem':'2.24'}.items():
            if importlib.metadata.version(name)!=version:raise ValueError('fixed oracle dependency version mismatch: '+name)
        # Execute the same bytes we verified, independent of sys.path/sys.modules.
        force_bytes=force.read_bytes()
        if hashlib.sha256(force_bytes).hexdigest()!=self.pins[force]:
            raise ValueError('fixed reference force changed while loading')
        force_module=types.ModuleType('_elitesync_verified_chiron_force')
        force_module.__file__=str(force.resolve())
        exec(compile(force_bytes,str(force.resolve()),'exec'),force_module.__dict__)
        self.accel=force_module.accel
        raw=json.loads(gaia.read_bytes())
        if len(raw['data'])!=1:raise ValueError('exactly one external object required')
        row=dict(zip([m['name'] for m in raw['metadata']],raw['data'][0]))
        if row['number_mp']!=2060:raise ValueError('wrong external object')
        rho=149597871473.216/149597870700.0
        self.initial=np.array(row['h_state_vector'],dtype=float)*np.array([rho*(1-1.550519768e-8)]*3+[rho]*3)
        self.origin1,self.origin2=erfa.tcbtdb(2455197.5,row['epoch_state_vector'])
        self.constants={int(number):float(value.replace('D','E'))*DAY**2/AU**3 for number,value in
            re.findall(r'BODY(\d+)_GM\s*=\s*\(\s*([\d.E+D-]+)',gm.read_text())}
        self.ids=[1,2,399,301,4,5,6,7,8,9];self.mus=np.array([self.constants[i] for i in self.ids])
        self.eph=SPK.open(str(kernel));self.ts=load.timescale(builtin=True)
        self.solutions={}

    def close(self):self.eph.close()

    def bary(self,body,offset):
        if body in (399,301):
            p,v=self.eph[0,3].compute_and_differentiate(self.origin1,self.origin2+offset)
            q,w=self.eph[3,body].compute_and_differentiate(self.origin1,self.origin2+offset)
            return (p+q)/AU,(v+w)/AU
        p,v=self.eph[0,body].compute_and_differentiate(self.origin1,self.origin2+offset)
        return p/AU,v/AU

    def rhs(self,offset,state):
        sun=self.bary(10,offset)[0]
        planets=np.array([self.bary(body,offset)[0]-sun for body in self.ids])
        return np.r_[state[3:],self.accel(state[:3],state[3:],planets,self.mus,self.constants[10],C)]

    def offset(self,time):return float((time.whole-self.origin1)+(time.tdb_fraction-self.origin2))

    def integrate(self):
        for direction,last in [('past',self.offset(self.ts.tt(1899,12,25))),
                               ('future',self.offset(self.ts.tt(2101,1,3)))]:
            print(json.dumps(dict(reference_phase=direction,status='STARTED')),flush=True)
            from scipy.integrate import solve_ivp
            sol=solve_ivp(self.rhs,(0,last),self.initial,method='DOP853',dense_output=True,
                rtol=2e-12,atol=np.array([1e-13]*3+[1e-15]*3),max_step=8)
            if not sol.success or not np.all(np.isfinite(sol.y)):raise ValueError('reference trajectory integration failed')
            self.solutions[direction]=(min(0,last),max(0,last),sol.sol)
            print(json.dumps(dict(reference_phase=direction,status='COMPLETE',evaluations=sol.nfev)),flush=True)

    def state(self,offset):
        low,high,fn=self.solutions['past' if offset<0 else 'future']
        if not low<=offset<=high:raise ValueError('reference interval exceeded')
        state=fn(offset)
        if state.shape!=(6,) or not np.all(np.isfinite(state)):raise ValueError('invalid reference state')
        return state

    def apparent(self,time):
        received=self.offset(time);observer,velocity=self.bary(399,received);emitted=received-.1
        for _ in range(12):
            source=self.state(emitted)[:3]+self.bary(10,emitted)[0]
            delta=source-observer;distance=float(np.linalg.norm(delta));changed=received-distance/C
            if abs(changed-emitted)<2e-11:break
            emitted=changed
        else:raise ValueError('reference light-time not converged')
        natural=delta/distance
        for body in (10,5,6):
            body_position=self.bary(body,received)[0]
            e=observer-body_position;em=float(np.linalg.norm(e));e/=em
            q=source-body_position;q/=np.linalg.norm(q)
            natural=erfa.ld(self.constants[body]/self.constants[10],natural,q,e,em,1e-8)
            natural/=np.linalg.norm(natural)
        v=velocity/C;sun_distance=float(np.linalg.norm(observer-self.bary(10,received)[0]))
        icrf=erfa.ab(natural,v,sun_distance,math.sqrt(1-float(v@v)))
        _,deps=erfa.nut06a(time.whole,time.tt_fraction);eps=erfa.obl06(time.whole,time.tt_fraction)+deps
        equator=erfa.pnm06a(time.whole,time.tt_fraction)@icrf
        x=equator[0];ey=math.cos(eps)*equator[1]+math.sin(eps)*equator[2]
        ez=-math.sin(eps)*equator[1]+math.cos(eps)*equator[2]
        return dict(longitude=math.degrees(math.atan2(ey,x))%360,
            latitude=math.degrees(math.atan2(ez,math.hypot(x,ey))),distance_au=distance)

    def full(self,time):
        now=self.apparent(time)
        before=self.apparent(self.ts.tt_jd(time.whole,time.tt_fraction-30/DAY))
        after=self.apparent(self.ts.tt_jd(time.whole,time.tt_fraction+30/DAY))
        speed=((after['longitude']-before['longitude']+180)%360-180)*1440
        return {**now,'speed_degrees_per_day':speed,'retrograde':speed<0}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['kernel','gm','gaia','inputs','output']:parser.add_argument('--'+name,required=True)
    args=parser.parse_args()
    output=Path(args.output)
    if output.exists():raise ValueError('output already exists; preserve reference history')
    raw=Path(args.inputs).read_bytes()
    if len(raw)>65536:raise ValueError('synthetic reference inputs too large')
    source=json.loads(raw);inputs=source.get('cases',source.get('inputs'))
    if not isinstance(inputs,list) or not 1<=len(inputs)<=2048:raise ValueError('finite explicit synthetic case list required')
    cases=[];ids=set()
    for item in inputs:
        identifier=item.get('id')
        if not isinstance(identifier,str) or not identifier or identifier in ids:raise ValueError('unique case identifiers required')
        ids.add(identifier)
        values=item.get('tt')
        if values is None:
            date=dt.date.fromisoformat(item['tt_calendar']);values=[date.year,date.month,date.day,0,0,0]
        if not isinstance(values,list) or len(values)!=6 or any(type(v) is not int for v in values):raise ValueError('six integer TT calendar values required')
        calendar=dt.datetime(*values)
        if not dt.datetime(1900,1,1)<=calendar<=dt.datetime(2101,1,1):raise ValueError('outside fixed reference interval')
        cases.append((identifier,values))
    reference=GaiaReference(args.kernel,args.gm,args.gaia)
    try:
        reference.integrate()
        rows=[dict(id=identifier,tt=values,expected=reference.full(reference.ts.tt(*values))) for identifier,values in cases]
        result=dict(status='OFFLINE_EXTERNAL_GAIA_INDEPENDENT_SOFTWARE_SAMPLED_REFERENCE',rows=rows,
            source_sha256={role:reference.pins[path] for role,path in reference.source_roles.items()},
            input_sha256=hashlib.sha256(raw).hexdigest(),reference_source_sha256=sha(Path(__file__)),
            limits=['NOT_BLIND main reference author; input-selector blindness only when separately documented',
                'Shared physical model and planetary data, reception-time deflectors, ERFA2006A versus Skyfield2000A/Capitaine frame convention',
                'No covariance/omitted-asteroid/fullEIH/J2/NG uncertainty bound or universal continuous-date guarantee',
                'Raw Gaia redistribution not admitted by this program; output remains internal research until separately cleared'])
        with output.open('x',encoding='utf-8') as stream:json.dump(result,stream,indent=2,allow_nan=False)
        print(json.dumps(dict(status=result['status'],cases=len(rows),sha256=sha(output))),flush=True)
    finally:reference.close()

if __name__=='__main__':main()
