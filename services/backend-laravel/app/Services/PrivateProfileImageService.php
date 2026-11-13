<?php

namespace App\Services;

use App\Models\MediaAsset;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Validation\ValidationException;

final class PrivateProfileImageService
{
    public function store(User $owner, UploadedFile $input, string $purpose, string $disk, int $maximumDimension = 512): MediaAsset
    {
        // Decode/re-encode to remove EXIF/GPS, comments and original filenames.
        // Bound decoded pixels before allocation as compressed files can be tiny.
        abort_unless(function_exists('imagecreatefromstring'), 503, 'avatar image processor unavailable');
        $info = @getimagesize($input->getPathname());
        if (! $info || ! in_array($info[2], [IMAGETYPE_JPEG, IMAGETYPE_PNG], true)
            || $info[0] < 1 || $info[1] < 1 || $info[0] > 4096 || $info[1] > 4096 || $info[0] * $info[1] > 12000000) {
            throw ValidationException::withMessages(['file' => '请选择尺寸不超过4096且像素不超过1200万的JPEG或PNG图片。']);
        }
        $decoded = @imagecreatefromstring(file_get_contents($input->getPathname()));
        if (! $decoded) throw ValidationException::withMessages(['file' => '图片无法读取。']);
        if ($info[2] === IMAGETYPE_JPEG) {
            abort_unless(function_exists('exif_read_data'), 503, 'avatar image processor unavailable');
            $exif = @exif_read_data($input->getPathname(), 'IFD0', true);
            $orientation = (int) ($exif['IFD0']['Orientation'] ?? 1);
            $angle = match ($orientation) { 3 => 180, 5, 6, 7 => -90, 8 => 90, default => 0 };
            if ($angle) {
                $rotated = imagerotate($decoded, $angle, 0);
                imagedestroy($decoded); $decoded = $rotated;
            }
            if (in_array($orientation, [2, 5], true)) imageflip($decoded, IMG_FLIP_HORIZONTAL);
            if (in_array($orientation, [4, 7], true)) imageflip($decoded, IMG_FLIP_VERTICAL);
        }
        $info[0] = imagesx($decoded); $info[1] = imagesy($decoded);
        $scale = min(1,  $maximumDimension / max($info[0], $info[1]));
        $width = max(1, (int) round($info[0] * $scale)); $height = max(1, (int) round($info[1] * $scale));
        $canvas = imagecreatetruecolor($width, $height);
        imagealphablending($canvas, false); imagesavealpha($canvas, true);
        imagecopyresampled($canvas, $decoded, 0, 0, 0, 0, $width, $height, $info[0], $info[1]);
        $temporary = tempnam(sys_get_temp_dir(), 'elitesync-avatar-');
        try {
            abort_unless(imagepng($canvas, $temporary), 503, 'avatar image processing failed');
            $normalized = new UploadedFile($temporary, 'avatar.png', 'image/png', null, true);
            $asset = app(MediaAssetService::class)->registerUploaded($owner, $normalized, [
                'media_type' => 'image', 'mime_type' => 'image/png', 'width' => $width, 'height' => $height,
                'metadata' => ['purpose' => $purpose], 'original_name' => 'avatar.png',
            ], new MediaStorageService(app(MediaUploadPolicy::class), $disk));
            abort_unless($asset->isBackingObjectAvailable(), 503, 'avatar upload unavailable');
        } finally {
            imagedestroy($decoded); imagedestroy($canvas);
            if (is_string($temporary) && is_file($temporary)) unlink($temporary);
        }
        return $asset;
    }
}
