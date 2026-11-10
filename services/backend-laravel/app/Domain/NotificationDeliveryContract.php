<?php
declare(strict_types=1);
namespace App\Domain;

final class NotificationDeliveryContract
{
    public const CATEGORIES=['message','rtc','match','buddy','status','platform_event','safety_case','system'];
    public static function category(string $kind): string
    {
        return match(true) {
            $kind==='message'=>'message',str_starts_with($kind,'rtc_')=>'rtc',
            str_starts_with($kind,'match')=>'match',$kind==='buddy'=>'buddy',
            str_starts_with($kind,'status')=>'status',$kind==='platform_event'=>'platform_event',
            $kind==='safety_case'=>'safety_case',default=>'system',
        };
    }
    public static function preferences(array $stored): array
    {
        $out=[];
        foreach(self::CATEGORIES as $category) $out[$category]=!array_key_exists($category,$stored) || $stored[$category]===true;
        return $out;
    }
    /** Inputs are re-read server facts, never client claims. */
    public static function mayAttempt(bool $ownerMatches,bool $deviceCurrent,bool $sessionCurrent,
        bool $silent,bool $categoryEnabled,bool $noticeCurrent): bool
    {
        return $ownerMatches && $deviceCurrent && $sessionCurrent && !$silent && $categoryEnabled && $noticeCurrent;
    }
    public static function envelope(int $noticeId): array
    {
        if($noticeId<=0)throw new \InvalidArgumentException('Invalid notification locator');
        return ['notification_id'=>$noticeId,'title'=>'EliteSync','body'=>'请打开应用查看当前有权通知。'];
    }
}
