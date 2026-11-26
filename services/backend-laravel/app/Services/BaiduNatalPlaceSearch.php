<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class BaiduNatalPlaceSearch
{
    public function __construct(
        private BaiduWebApiSigner $signer,
        private NatalAreaCatalog $areas,
        private NatalPlaceCatalog $places,
    ) {}

    public function search(string $query, string $region): array
    {
        $path = config('natal.baidu_credentials_path');
        $keys = is_string($path) && is_file($path) ? @parse_ini_file($path, false, INI_SCANNER_RAW) : false;
        $ak = $keys['BAIDU_WEB_AK'] ?? null;
        $sk = $keys['BAIDU_WEB_SK'] ?? null;
        abort_if(! is_string($ak) || trim($ak) === '' || ! is_string($sk) || trim($sk) === '',
            503, '地点搜索暂不可用。');

        $city = $this->areas->city($region);
        abort_if($city === null, 422, '请输入可识别的城市全名。');

        $url = $this->signer->buildSignedUrl('/place/v3/region', [
            'query' => $query,
            'region' => $city['name'],
            'region_limit' => 'true',
            'output' => 'json',
        ], trim($ak), trim($sk));
        $request = Http::acceptJson()->withoutRedirecting()->connectTimeout(3)->timeout(8);
        $proxy = config('natal.baidu_lookup_proxy');
        if (is_string($proxy) && $proxy !== '') {
            $request = $request->withOptions(['proxy' => $proxy]);
        }

        try {
            $response = $request->get($url);
        } catch (ConnectionException) {
            abort(503, '地点搜索暂不可用。');
        }
        $data = $response->json();
        abort_if($response->status() === 429 || in_array($data['status'] ?? null, [4, '4', 302, '302'], true),
            429, '地点搜索额度暂不可用。');
        abort_unless($response->successful() && in_array($data['status'] ?? null, [0, '0'], true)
            && is_array($data['results'] ?? null), 503, '地点搜索暂不可用。');

        $matches = [];
        foreach (array_slice($data['results'], 0, 10) as $hit) {
            if (! is_array($hit) || ! is_string($hit['name'] ?? null) || trim($hit['name']) === ''
                || ! $this->areas->includes($city, $hit)) {
                continue;
            }
            $area = is_string($hit['area'] ?? null) ? $hit['area'] : '';
            $local = $this->places->search($hit['name'], $city['name'], exact: true) ?? [];
            $local = array_filter($local, static fn (array $place) => ($area === '' || $place['area'] === $area)
                && in_array($place['point_kind'], ['campus', 'landmark'], true));

            if ($local !== []) {
                foreach ($local as $place) {
                    $matches['osm:'.$place['label']] = $place + ['source' => 'OpenStreetMap'];
                }

                continue;
            }

            $point = $this->areas->representative($city, $area);
            $point['matched_name'] = mb_substr(trim($hit['name']), 0, 120);
            $key = 'geonames:'.$point['point_kind'].':'.$point['label'];
            $matches[$key] ??= $point;
        }

        return array_slice(array_values($matches), 0, 10);
    }
}
