<?php

namespace App\Services;

use App\Models\RtcSession;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpKernel\Exception\HttpException;

class LiveKitTokenService
{
    public function issueJoinInfo(RtcSession $session, User $user): array
    {
        abort_unless(app(RtcAuthorityService::class)->authorized($session, (int)$user->id, true), 404, 'call unavailable');
        $config = config('livekit');
        if (!($config['enabled'] ?? false)) {
            throw new HttpException(503, 'livekit not configured');
        }

        $url = trim((string) ($config['url'] ?? ''));
        $apiKey = trim((string) ($config['api_key'] ?? ''));
        $apiSecret = trim((string) ($config['api_secret'] ?? ''));
        $ttl = min(120, max(30, (int) ($config['ttl_seconds'] ?? 60)));

        if ($url === '' || $apiKey === '' || $apiSecret === '') {
            throw new HttpException(503, 'livekit not configured');
        }

        $identity = app(RtcAuthorityService::class)->identity($session, (int)$user->id);
        $expiresAt = Carbon::now()->utc()->addSeconds($ttl)->timestamp;
        $notBefore = Carbon::now()->utc()->subSeconds(30)->timestamp;
        $roomName = (string) $session->room_key;

        Log::info('rtc_livekit_join_info', [
            'rtc_session_id' => (int) $session->id,
            'user_id' => (int) $user->id,
            'room_name' => $roomName,
            'identity' => $identity,
            'participant_name' => '通话参与者',
            'mode' => (string) $session->mode,
            'url' => $url,
        ]);

        $token = $this->buildJwt(
            $apiKey,
            $apiSecret,
            [
                'sub' => $identity,
                'nbf' => $notBefore,
                'exp' => $expiresAt,
                'name' => '通话参与者',
                'video' => [
                    'roomJoin' => true,
                    'room' => $roomName,
                    'canPublish' => true,
                    'canSubscribe' => true,
                    'canPublishData' => false,
                    'canPublishSources' => $session->mode === 'video' ? ['microphone','camera'] : ['microphone'],
                ],
            ]
        );

        return [
            'enabled' => true,
            'url' => $url,
            'token' => $token,
            'room_name' => $roomName,
            'identity' => $identity,
            'participant_name' => '通话参与者',
            'mode' => (string) $session->mode,
            'expires_at' => Carbon::createFromTimestampUTC($expiresAt)->toISOString(),
        ];
    }

    private function buildJwt(string $apiKey, string $apiSecret, array $claims): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $headerPart = $this->base64UrlEncode(json_encode(
            $header,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR
        ));
        $claims['iss'] = $apiKey;
        $claimsPart = $this->base64UrlEncode(json_encode(
            $claims,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR
        ));
        $signature = hash_hmac('sha256', $headerPart . '.' . $claimsPart, $apiSecret, true);

        return $headerPart . '.' . $claimsPart . '.' . $this->base64UrlEncode($signature);
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
