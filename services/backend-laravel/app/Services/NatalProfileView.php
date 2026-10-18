<?php

namespace App\Services;

use App\Models\UserNatalProfile;

final class NatalProfileView
{
    public function profile(UserNatalProfile $row): array
    {
        $status = $row->status;
        $results = $row->results;
        $settings = app(NatalCalculationProfile::class)->settings($row->settings);
        $current = app(NatalInputContext::class)->normalize($row->input,
            app(NatalCalculationProfile::class)->make($settings));
        if ($current['input_signature'] !== $row->input_signature) {
            // Never reuse a cached result across changed code/profile/tzdb/data.
            $status = 'STALE_RECALCULATION_REQUIRED';
            $results = null;
        }
        return ['input' => $row->input, 'settings' => $row->settings, 'context' => $row->context,
            'results' => $results, 'input_revision' => $row->input_revision,
            'result_revision' => $results !== null ? $row->result_revision : null,
            'input_signature' => $row->input_signature, 'status' => $status];
    }

    public function legacyProjection(UserNatalProfile $row, mixed $canonicalBirthday): array
    {
        $natal = $this->profile($row);
        $western = $natal['results']['western'] ?? [];
        $signs = ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座',
            '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'];
        $byName = [];
        foreach ($western['planets'] ?? [] as $body) {
            $byName[$body['name']] = $body;
        }
        $asc = $western['axes']['ascendant'] ?? null;
        return [
            'natal' => $natal, 'source' => 'private_calculation_mirror',
            'canonical_birthday' => $canonicalBirthday?->format('Y-m-d'),
            'birthday' => $row->context['civil_date'], 'birth_time' => $row->context['civil_time'],
            'birth_place' => $row->context['location_label'],
            'birth_lat' => $row->context['latitude'], 'birth_lng' => $row->context['longitude'],
            'tz_str' => $row->context['timezone'],
            'sun_sign' => isset($byName['sun']['sign_index']) ? $signs[$byName['sun']['sign_index']] : null,
            'moon_sign' => isset($byName['moon']['sign_index']) ? $signs[$byName['moon']['sign_index']] : null,
            'asc_sign' => is_numeric($asc) ? $signs[(int) floor($asc / 30)] : null,
            'bazi' => $natal['results']['bazi']['bazi'] ?? null,
            'bazi_details' => $natal['results']['bazi'] ?? null,
            'ziwei' => $natal['results']['ziwei'] ?? null,
            'da_yun' => $natal['results']['bazi']['da_yun'] ?? null,
            'liu_nian' => $natal['results']['bazi']['liu_nian'] ?? null,
            'notes' => ['natal_v1010:UNVERIFIED', 'private_calculation_mirror:canonical_unchanged'],
            'accuracy' => 'UNVERIFIED', 'confidence' => null,
            'western_engine' => 'skyfield-1.55', 'western_precision' => 'UNVERIFIED',
        ];
    }
}
