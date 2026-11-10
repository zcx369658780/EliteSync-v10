<?php
declare(strict_types=1);
namespace App\Domain;

final class TrustedLoginTimeContract
{
    /** Parse only an absolute server-owned persisted anchor; refresh never supplies a new T0. */
    public static function deadline(string $anchor, \DateTimeImmutable $serverNow): \DateTimeImmutable
    {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})?$/D',$anchor)) {
            throw new \InvalidArgumentException('SESSION_TIME_UNTRUSTED');
        }
        try {
            $time=new \DateTimeImmutable($anchor,new \DateTimeZone('UTC'));
            $errors=\DateTimeImmutable::getLastErrors();
            if (($errors !== false && ($errors['warning_count'] || $errors['error_count'])) || $time>$serverNow) {
                throw new \InvalidArgumentException('SESSION_TIME_UNTRUSTED');
            }
            return $time->setTimezone(new \DateTimeZone('UTC'))->add(new \DateInterval('P15D'));
        } catch (\Throwable $error) {
            throw new \InvalidArgumentException('SESSION_TIME_UNTRUSTED',0,$error);
        }
    }
}
