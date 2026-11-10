"""Offline derivation of the fixed, attributed Lowell Chiron element record.

This limited model is used by the explicit offline builder, never at request
time. Numerical convergence alone does not prove physical accuracy; independent
sampled comparisons and the documented model limitations remain separate.
"""
import hashlib
import json
import math
import re
from pathlib import Path

import numpy as np
from jplephem.spk import SPK
from skyfield.api import load

AU_KM = 149597870.700
DAY_SECONDS = 86400.0
C_AU_DAY = 299792.458 * DAY_SECONDS / AU_KM
KERNEL_SHA = 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2'
GM_SHA = '924ddf4fb9ead9fe8a1aa55780bcabde40b09d00065d58226e24b68d8092f140'
ELEMENTS_SHA = '2e3654ab1c3448c816d0462a05ffa704e272e270fb6b23f1b0284b7909e07c46'


def checked_bytes(path, expected):
    raw = path.read_bytes()
    if hashlib.sha256(raw).hexdigest() != expected:
        raise ValueError('fixed research data identity mismatch: ' + path.name)
    return raw


def read_record(path):
    raw = checked_bytes(Path(path), ELEMENTS_SHA)
    source = json.loads(raw)
    if source.get('schema') != 'elitesync.chiron.astorb2060.v1':
        raise ValueError('unexpected element record schema')
    row = source['record']
    if row['Planet'] != '2060' or row['Name'] != 'Chiron' or row['CompName'] != 'L.H. Wasserman':
        raise ValueError('unexpected source object')
    return row


def masses(path):
    text = checked_bytes(Path(path), GM_SHA).decode('ascii')
    values = {int(body): float(value.replace('D', 'E')) * DAY_SECONDS**2 / AU_KM**3
              for body, value in re.findall(r'BODY(\d+)_GM\s*=\s*\(\s*([\d.E+D-]+)', text)}
    if not all(body in values for body in [10, 1, 2, 399, 301, 4, 5, 6, 7, 8, 9]):
        raise ValueError('required NAIF GM missing')
    return values


def osculating_state(row, solar_mu):
    """Astorb inertial ecliptic -> ICRF, explicit single x-axis rotation.

    Gaia Collaboration2023 Table1/Fig9 and Appendix B establish the Astorb
    convention: obliquity84381.448 arcsec and zero longitude offsets.
    Retain the cited CC-BY-4.0 source; no extra EME2000 bias is applied.
    """
    a, e = float(row['a']), float(row['e'])
    if not 0 <= e < 1 or a <= 0:
        raise ValueError('elliptic osculating record required')
    mean = math.radians(float(row['M']))
    eccentric = mean
    for _ in range(30):
        delta = (eccentric - e * math.sin(eccentric) - mean) / (1 - e * math.cos(eccentric))
        eccentric -= delta
        if abs(delta) < 1e-14:
            break
    else:
        raise ValueError('Kepler solve failed')
    radius = a * (1 - e * math.cos(eccentric))
    root = math.sqrt(1 - e * e)
    pos = a * np.array([math.cos(eccentric) - e, root * math.sin(eccentric), 0.0])
    vel = math.sqrt(solar_mu * a) / radius * np.array([-math.sin(eccentric), root * math.cos(eccentric), 0.0])
    def rz(angle):
        c, s = math.cos(angle), math.sin(angle)
        return np.array([[c,-s,0.0],[s,c,0.0],[0.0,0.0,1.0]])
    def rx(angle):
        c, s = math.cos(angle), math.sin(angle)
        return np.array([[1.0,0.0,0.0],[0.0,c,-s],[0.0,s,c]])
    angles = {key: math.radians(float(row[key])) for key in ['Omega','omega','i']}
    rotation = rx(math.radians(84381.448 / 3600)) @ rz(angles['Omega']) @ rx(angles['i']) @ rz(angles['omega'])
    return np.concatenate([rotation @ pos, rotation @ vel])


class BuildModel:
    def __init__(self, kernel_path, gm_path, elements_path):
        checked_bytes(Path(kernel_path), KERNEL_SHA)
        self.row = read_record(elements_path)
        self.gm = masses(gm_path)
        self.kernel = SPK.open(str(kernel_path))
        self.ts = load.timescale(builtin=True)
        year, month, day = map(int, self.row['Epoch'].split('-'))
        self.epoch_tt = self.ts.tt(year, month, day)
        self.epoch_tdb = self.epoch_tt.tdb
        self.initial = osculating_state(self.row, self.gm[10])
        self.ids = [1,2,399,301,4,5,6,7,8,9]
        self.planet_mu = np.array([self.gm[body] for body in self.ids])

    def close(self):
        self.kernel.close()

    def planetary_positions(self, offset_days):
        jd = self.epoch_tdb + offset_days
        sun = self.kernel[0,10].compute(jd)
        earth_bary = self.kernel[0,3].compute(jd)
        result=[]
        for body in self.ids:
            position = (earth_bary + self.kernel[3,body].compute(jd)) if body in [399,301] else self.kernel[0,body].compute(jd)
            result.append((position-sun)/AU_KM)
        return np.array(result)

    def rhs(self, offset_days, state):
        position, velocity = state[:3], state[3:]
        r = np.linalg.norm(position)
        planets = self.planetary_positions(offset_days)
        displacement = planets-position
        distance = np.linalg.norm(displacement, axis=1)
        if r <= 0 or np.any(distance <= 1e-7):
            raise ValueError('singular research force geometry')
        acceleration = -self.gm[10]*position/r**3
        acceleration += np.sum(self.planet_mu[:,None]*(displacement/distance[:,None]**3-planets/np.linalg.norm(planets,axis=1)[:,None]**3),axis=0)
        # Central solar first-post-Newtonian term, an explicit limited model.
        acceleration += self.gm[10]/(C_AU_DAY**2*r**3)*((4*self.gm[10]/r-np.dot(velocity,velocity))*position+4*np.dot(position,velocity)*velocity)
        return np.concatenate([velocity,acceleration])

    def identity(self):
        return {'status':'DERIVED_LOWELL_LIMITED_FORCE_MODEL_SAMPLED_REFERENCE_NOT_ACCEPTANCE',
                'epoch_tt':float(self.epoch_tt.tt),'epoch_tdb':float(self.epoch_tdb),
                'kernel_sha256':KERNEL_SHA,'gm_kernel_sha256':GM_SHA,'element_record_sha256':ELEMENTS_SHA,
                'source_attribution':'Lowell Observatory; L.H. Wasserman; NASA NAG5-4741, NNX16AG52G,80NSSC19K0420; Lowell endowment',
                'frame':'Astorb ecliptic to ICRF:Rx(84381.448arcsec),phi=psi=0; GaiaCollaboration2023 Table1, AppendixB',
                'frame_source_doi':'10.1051/0004-6361/202347270',
                'force_model':'Sun+major planet barycentres; Earth/Moon separate; solar1PN',
                'omissions':['10 perturbing asteroids in original Lowell fit','solar J2 and full relativistic model','nongravitational terms/covariance propagation'],
                'source_accuracy_limit':'Archive near-epoch statement is not century accuracy proof',
                'independent_chiron_oracle':'NOT_ESTABLISHED','product_chiron_enabled':False}
