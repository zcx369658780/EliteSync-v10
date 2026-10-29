<?php
declare(strict_types=1);
/** Future explicit runtime probe. Not executed by this zero-runtime R1. */
require_once __DIR__.'/MainlineEnvironment.php';
require_once __DIR__.'/PhpRuntimeQualification.php';
try {
    $ctx=json_decode(stream_get_contents(STDIN),true,512,JSON_THROW_ON_ERROR);
    MainlineEnvironment::assertProbeContext($ctx);
    PhpRuntimeQualification::assertCurrent($ctx);
    echo json_encode(['state'=>'CAPABILITIES_MATCHED_WITHOUT_LARAVEL','php_version'=>PHP_VERSION,'sapi'=>PHP_SAPI,'laravel_bootstrap'=>false,'pdo_connection'=>false]);
}catch(Throwable $e){fwrite(STDERR,$e->getMessage()."\n");exit(1);}
