<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Validation\ValidationException;
use Symfony\Component\Process\Process;
use Throwable;

final class PrivateAudioValidator
{
    public function validate(UploadedFile $file): array
    {
        $size = (int) $file->getSize();
        if ($size < 1 || $size > 5 * 1024 * 1024) $this->reject();
        $probe = (string) config('media.video.ffprobe_path');
        $decoder = dirname($probe).'/ffmpeg';
        $path = (string) $file->getRealPath();
        try {
            if (! is_file($probe) || ! is_file($decoder)) $this->reject();
            $process = new Process([$probe, '-v', 'error', '-protocol_whitelist', 'file',
                '-show_format', '-show_streams', '-of', 'json', $path]);
            $process->setTimeout(15);
            $process->mustRun();
            if (strlen($process->getOutput()) > 1024 * 1024) $this->reject();
            $info = json_decode($process->getOutput(), true, 32, JSON_THROW_ON_ERROR);
            $duration = (float) ($info['format']['duration'] ?? 0);
            $streams = $info['streams'] ?? [];
            if (! in_array('mp4', explode(',', $info['format']['format_name'] ?? ''), true)
                || count($streams) !== 1 || ($streams[0]['codec_type'] ?? '') !== 'audio'
                || ($streams[0]['codec_name'] ?? '') !== 'aac' || ($streams[0]['profile'] ?? '') !== 'LC'
                || ! is_finite($duration) || $duration < 1 || $duration > 60) $this->reject();
            // A valid header alone is insufficient. Decode the complete bounded recording.
            $decode = new Process([$decoder, '-v', 'error', '-xerror', '-protocol_whitelist', 'file',
                '-i', $path, '-map', '0:a:0', '-f', 'null', '-']);
            $decode->setTimeout(15);
            $decode->mustRun();
        } catch (Throwable) {
            $this->reject();
        }
        return ['media_type' => 'audio', 'mime_type' => 'audio/mp4', 'size_bytes' => $size,
            'width' => null, 'height' => null, 'duration_ms' => (int) ceil($duration * 1000),
            'sha256' => hash_file('sha256', $path),
            'metadata' => ['validation' => 'm4a-aac-lc-full-decode-v1', 'audio_codec' => 'aac',
                'processing' => 'validated_passthrough_no_transcode']];
    }

    private function reject(): never
    {
        throw ValidationException::withMessages(['file' => '语音须为可解码的 AAC-LC/M4A，1–60秒且不超过5 MiB。']);
    }
}
