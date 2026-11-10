<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Validation\ValidationException;
use Symfony\Component\Process\Process;
use Throwable;

/** Validates content, never client metadata; deliberately does not transcode. */
class PrivateVideoValidator
{
    public function validate(UploadedFile $file): array
    {
        $size = (int) $file->getSize();
        if ($size <= 0 || $size > min(25 * 1024 * 1024, (int) config('media.video.max_bytes', 25 * 1024 * 1024))) {
            $this->reject('Video must be no larger than 25 MiB.');
        }
        if ($file->getMimeType() !== 'video/mp4') {
            $this->reject('Only MP4 video content is accepted.');
        }
        try {
            $probe = $this->probe((string) $file->getRealPath());
        } catch (Throwable) {
            $this->reject('Video verification is unavailable or the file is invalid.');
        }
        $format = $probe['format'] ?? [];
        $duration = filter_var($format['duration'] ?? null, FILTER_VALIDATE_FLOAT);
        if (!in_array('mp4', explode(',', (string) ($format['format_name'] ?? '')), true)
            || $duration === false || !is_finite($duration) || $duration <= 0
            || $duration > min(30, (float) config('media.video.max_duration_seconds', 30))) {
            $this->reject('Video must be a valid MP4 of at most 30 seconds.');
        }
        $video = [];
        $audio = [];
        foreach ($probe['streams'] ?? [] as $stream) {
            if (($stream['codec_type'] ?? '') === 'video') {
                $video[] = $stream;
            } elseif (($stream['codec_type'] ?? '') === 'audio') {
                $audio[] = $stream;
            } else {
                $this->reject('Unsupported MP4 stream.');
            }
        }
        if (count($video) !== 1 || ($video[0]['codec_name'] ?? '') !== 'h264'
            || (int) ($video[0]['width'] ?? 0) < 1 || (int) ($video[0]['height'] ?? 0) < 1
            || count($audio) > 1 || ($audio && ($audio[0]['codec_name'] ?? '') !== 'aac')) {
            $this->reject('Video must contain one H.264 track and optionally one AAC audio track.');
        }
        foreach (array_merge($video, $audio) as $stream) {
            if (isset($stream['duration']) && (!is_numeric($stream['duration'])
                || !is_finite((float) $stream['duration']) || (float) $stream['duration'] > 30)) {
                $this->reject('Video track exceeds 30 seconds.');
            }
        }

        return [
            'media_type' => 'video', 'mime_type' => 'video/mp4', 'size_bytes' => $size,
            'width' => (int) $video[0]['width'], 'height' => (int) $video[0]['height'],
            'duration_ms' => (int) ceil($duration * 1000),
            'sha256' => hash_file('sha256', $file->getRealPath()),
            'metadata' => ['validation' => 'ffprobe-mp4-h264-v1', 'video_codec' => 'h264',
                'audio_codec' => $audio ? 'aac' : null, 'audio_present' => (bool) $audio,
                'processing' => 'validated_passthrough_no_transcode'],
        ];
    }

    protected function probe(string $path): array
    {
        $binary = trim((string) config('media.video.ffprobe_path', ''));
        // Explicit local executable only: no PATH discovery, shell, URLs or uploaded commands.
        if ($binary === '' || !is_file($binary) || !is_file($path)) {
            throw new \RuntimeException('Video verifier unavailable');
        }
        $process = new Process([$binary, '-v', 'error', '-protocol_whitelist', 'file',
            '-show_format', '-show_streams', '-of', 'json', $path]);
        $process->setTimeout(15);
        $process->mustRun();
        if (strlen($process->getOutput()) > 1024 * 1024) {
            throw new \RuntimeException('Invalid probe output');
        }
        return json_decode($process->getOutput(), true, 32, JSON_THROW_ON_ERROR);
    }

    private function reject(string $message): never
    {
        throw ValidationException::withMessages(['file' => $message]);
    }
}
