<?php
declare(strict_types=1);

// Exact, pure bootstrap. Never load Laravel, Composer, .env, another runner or services.
// The caller owns stdout bytes and hashes; this exporter opens no filesystem output.
try {
    $backend = dirname(__DIR__, 4);
    foreach (['Domain/CommonAuthorityEvidenceContract', 'Domain/ProductConnectionStateTransitionEvaluator',
        'Domain/MessagingConsentConversationLiveGateEvaluator', 'EliteSync/TextAuthority/ExistingEvaluatorEvidenceAdapter',
        'EliteSync/ConversationQualification/ConversationQualificationSource',
        'EliteSync/ConversationQualification/ConversationUsePointQualifier',
        'EliteSync/ConversationLifecycle/FrozenQualificationSource',
        'EliteSync/ConversationLifecycle/LocalTestConversationLifecycle'] as $file) {
        require_once $backend.'/app/'.$file.'.php';
    }
    require_once dirname(__DIR__).'/ConversationLifecycle/FixtureFourFamilySource.php';
    require_once __DIR__.'/DiagnosticScenarioFactory.php';
    $generated = (new EliteSyncQualificationDiagnosticFixture\DiagnosticScenarioFactory())->generate();
    $json = json_encode($generated['envelope'], JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES)."\n";
    $receipt = $generated['receipt'] + ['exported_bytes' => strlen($json),
        'exported_sha256' => hash('sha256', $json)];
    // No partial fixture is emitted before all assertions and serialization succeed.
    fwrite(STDERR, json_encode($receipt, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES)."\n");
    fwrite(STDOUT, $json);
} catch (Throwable $error) {
    fwrite(STDERR, json_encode(['status' => 'FAIL', 'error_class' => $error::class,
        'error' => $error->getMessage(), 'fixture_emitted' => false], JSON_THROW_ON_ERROR)."\n");
    exit(1);
}
