<?php

use App\Http\Controllers\Api\V1\AccountSecurityController;
use App\Http\Controllers\Api\V1\AdminController;
use App\Http\Controllers\Api\V1\AdminMatchingController;
use App\Http\Controllers\Api\V1\AppVersionController;
use App\Http\Controllers\Api\V1\AstroProfileController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ConversationController;
use App\Http\Controllers\Api\V1\DynamicChartController;
use App\Http\Controllers\Api\V1\FrontendTelemetryController;
use App\Http\Controllers\Api\V1\GeoController;
use App\Http\Controllers\Api\V1\HomeController;
use App\Http\Controllers\Api\V1\LiveConnectionController;
use App\Http\Controllers\Api\V1\MatchController;
use App\Http\Controllers\Api\V1\MatchRoundController;
use App\Http\Controllers\Api\V1\MbtiProfileController;
use App\Http\Controllers\Api\V1\MediaController;
use App\Http\Controllers\Api\V1\MessageController;
use App\Http\Controllers\Api\V1\ModerationController;
use App\Http\Controllers\Api\V1\NatalProfileController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\PrivacyController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ProfileShowcaseDraftController;
use App\Http\Controllers\Api\V1\ProfileShowcasePublicationController;
use App\Http\Controllers\Api\V1\QuestionnaireController;
use App\Http\Controllers\Api\V1\QuestionnaireDraftController;
use App\Http\Controllers\Api\V1\RelationshipController;
use App\Http\Controllers\Api\V1\RtcController;
use App\Http\Controllers\Api\V1\RtcGuardController;
use App\Http\Controllers\Api\V1\SanctionAppealController;
use App\Http\Controllers\Api\V1\SocialController;
use App\Http\Controllers\Api\V1\StatusPostController;
use App\Http\Controllers\Api\V2\AppHealthController;
use App\Http\Controllers\Api\V2\AppReadinessController;
use App\Http\Controllers\Api\V2\CanonicalMatch\CanonicalMatchEntryController;
use App\Http\Controllers\Api\V2\Contracts\LocationContractController;
use App\Http\Controllers\Api\V2\Contracts\TransportEnvelopeController;
use App\Http\Controllers\Api\V2\RuntimeReadiness\RuntimeReadinessEvaluationController;
use App\Http\Middleware\DenyUnverifiedMessagingLiveAccess;
use App\Http\Middleware\MatchingOperationTransaction;
use App\Http\Middleware\RtcTransaction;
use App\Services\ConversationVisibility;
use App\Services\ProfileReadinessService;
use App\Services\RtcAuthorityService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('v2')->middleware('secure.transport')->group(function () {
    Route::get('/app/health', AppHealthController::class);
    Route::get('/app/readiness', AppReadinessController::class);
    Route::get('/contracts/location', LocationContractController::class);
    Route::post('/contracts/application-envelope', TransportEnvelopeController::class);
    Route::post('/canonical-match/evaluations', [CanonicalMatchEntryController::class, 'evaluate']);
    Route::post('/canonical-match/invalidations', [CanonicalMatchEntryController::class, 'invalidate']);
    Route::post('/runtime-readiness/evaluations', RuntimeReadinessEvaluationController::class);
});

Route::prefix('v1')->group(function () {
    Route::prefix('app')->group(function () {
        Route::get('/health', [AppVersionController::class, 'health']);
        Route::get('/version/check', [AppVersionController::class, 'check']);
    });

    Route::get('/media/{assetId}/content', [MediaController::class, 'content'])
        ->whereNumber('assetId')->middleware(['auth:sanctum', 'account.active']);

    Route::post('/account/closure-recovery', [AccountSecurityController::class, 'recover'])->middleware('throttle:10,1');
    Route::post('/account/closure-receipts/{requestId}', [AccountSecurityController::class, 'receipt'])->middleware('throttle:10,1');
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:auth');
        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:auth');
        Route::post('/refresh', [AuthController::class, 'refresh'])->middleware(['auth:sanctum', 'account.active']);
        Route::post('/password', [AuthController::class, 'changePassword'])->middleware(['auth:sanctum', 'account.active']);
        Route::delete('/account', [AuthController::class, 'deleteSelf'])->middleware(['auth:sanctum', 'account.active']);
    });

    Route::prefix('questionnaire')->middleware(['auth:sanctum', 'account.active'])->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/replace', [QuestionnaireController::class, 'replaceQuestion']);
        Route::post('/answers', [QuestionnaireController::class, 'submitAnswers']);
        Route::get('/history', [QuestionnaireController::class, 'history']);
        // Legacy compatibility endpoints (old Android/Flutter builds)
        Route::post('/submit', [QuestionnaireController::class, 'submitAnswers']);
        Route::get('/draft', [QuestionnaireDraftController::class, 'show']);
        Route::post('/draft', [QuestionnaireDraftController::class, 'save']);
        Route::post('/reset', [QuestionnaireController::class, 'reset']);
        Route::get('/progress', [QuestionnaireController::class, 'progress']);
        Route::get('/profile', [QuestionnaireController::class, 'profile']);
    });

    // 兼容旧客户端路径
    Route::post('/rtc-guard/{action}', function (Request $r, string $action, RtcAuthorityService $authority) {
        abort_unless(in_array($action, ['authorize', 'sweep', 'audit'], true), 404);

        return app(RtcGuardController::class)->$action($r, $authority);
    });

    Route::middleware(['auth:sanctum', 'account.active'])->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/answers', [QuestionnaireController::class, 'submitAnswers']);
    });

    Route::middleware(['auth:sanctum', 'account.active'])->group(function () {
        $comments = \App\Http\Controllers\Api\V1\StatusCommentController::class;
        Route::middleware([\App\Http\Middleware\JourneyPrivateResponse::class])->group(function () use ($comments) {
            Route::get('/status-posts/{postId}/comments', [$comments, 'index'])->whereNumber('postId');
            Route::get('/status-posts/{postId}/comments/{commentId}', [$comments, 'show'])->whereNumber('postId')->whereUuid('commentId');
            Route::post('/status-posts/{postId}/comments', [$comments, 'store'])->whereNumber('postId')->middleware('throttle:10,1');
            Route::delete('/status-posts/{postId}/comments/{commentId}', [$comments, 'destroy'])->whereNumber('postId')->whereUuid('commentId');
            Route::post('/status-posts/{postId}/comments/{commentId}/report', [$comments, 'report'])->whereNumber('postId')->whereUuid('commentId')->middleware('throttle:10,1');
        });
        $buddy = \App\Http\Controllers\Api\V1\BuddyController::class;
        Route::middleware([\App\Http\Middleware\JourneyPrivateResponse::class, 'throttle:30,1'])->group(function () use ($buddy) {
            Route::get('/buddy', [$buddy, 'index']);
            Route::put('/buddy/preferences', [$buddy, 'preferences']);
            Route::post('/buddy/activities', [$buddy, 'store']);
            Route::post('/buddy/redeem', [$buddy, 'redeem']);
            Route::get('/buddy/{id}', [$buddy, 'show'])->whereUuid('id');
            Route::post('/buddy/{id}/actions', [$buddy, 'action'])->whereUuid('id');
            Route::post('/buddy/{id}/invites', [$buddy, 'invite'])->whereUuid('id');
            Route::post('/buddy/{id}/tokens', [$buddy, 'token'])->whereUuid('id');
            Route::delete('/buddy/{id}/tokens', [$buddy, 'token'])->whereUuid('id');
        });
        $journey = \App\Http\Controllers\Api\V1\SlowDatingController::class;
        Route::get('/journey', [$journey, 'show']);
        Route::put('/journey/participation', [$journey, 'participate']);
        Route::post('/journey/proposals/{id}/decision', [$journey, 'decision'])->whereUuid('id');
        Route::get('/formal-relationships', [$journey, 'relationships']);
        Route::post('/formal-relationships', [$journey, 'requestRelationship'])->middleware('throttle:10,1');
        Route::post('/formal-relationships/{id}/actions', [$journey, 'relationshipAction'])->whereUuid('id');
        Route::put('/privacy/resume', [$journey, 'saveResume']);
        Route::get('/privacy/peers/{id}', [PrivacyController::class, 'peer'])->whereNumber('id');
        $social = SocialController::class;
        Route::get('/social', [$social, 'index']);
        Route::post('/social/preferences', [$social, 'preferences']);
        Route::post('/social/invites', [$social, 'invite'])->middleware('throttle:10,1');
        Route::delete('/social/invites/{id}', [$social, 'revokeInvite'])->whereNumber('id');
        Route::post('/social/requests', [$social, 'store'])->middleware('throttle:10,1');
        Route::post('/social/requests/{id}/{action}', [$social, 'transition'])->whereNumber('id');
        Route::delete('/social/friends/{peer}', [$social, 'unfriend'])->whereNumber('peer');
        $privacy = PrivacyController::class;
        Route::get('/privacy', [$privacy, 'show']);
        Route::put('/privacy', [$privacy, 'save']);
        Route::get('/privacy/preview', [$privacy, 'preview']);
        Route::get('/profile-peers/{id}', [$privacy, 'peer'])->whereNumber('id');
        $account = AccountSecurityController::class;
        Route::get('/account/sessions', [$account, 'sessions']);
        Route::delete('/account/sessions/{sessionId}', [$account, 'revoke']);
        Route::post('/conversations/{id}/visibility', function (Request $r, int $id) {
            $d = $r->validate(['hidden' => 'required|boolean']);
            app(ConversationVisibility::class)->set((int) $r->user()->id, $id, $d['hidden']);

            return response()->json(['hidden' => $d['hidden']]);
        })->whereNumber('id');
        Route::get('/account/identity', [$account, 'identity']);
        Route::post('/auth/logout', [$account, 'logout']);
        Route::post('/auth/logout-all', [$account, 'logoutAll']);

        Route::prefix('telemetry')->group(function () {
            Route::post('/events', [FrontendTelemetryController::class, 'store']);
            Route::post('/match-explanation-preview-opened', [FrontendTelemetryController::class, 'store']);
            Route::post('/first-chat-entry', [FrontendTelemetryController::class, 'store']);
            Route::post('/match-feedback-submitted', [FrontendTelemetryController::class, 'store']);
        });

        Route::prefix('profile')->middleware('account.active')->group(function () {
            Route::get('/dynamic', [DynamicChartController::class, 'index']);
            Route::get('/dynamic/{id}', [DynamicChartController::class, 'show'])->whereNumber('id');
            Route::post('/dynamic', [DynamicChartController::class, 'save']);
            Route::post('/dynamic/{id}', [DynamicChartController::class, 'save'])->whereNumber('id');
            Route::get('/natal', [NatalProfileController::class, 'show']);
            Route::post('/natal', [NatalProfileController::class, 'save']);
            Route::get('/operating-status', function (Request $r) {
                $u = $r->user();

                return response()->json(['status' => $u->verify_status, 'reason' => $u->verify_reason ?? '', 'revision' => (int) $u->verify_revision, 'moderation_status' => $u->moderation_status, 'matching_eligibility' => app(ProfileReadinessService::class)->forUser($u)['matching_eligibility']]);
            });

            Route::get('/basic', [ProfileController::class, 'basic']);
            Route::post('/basic', [ProfileController::class, 'saveBasic']);
            Route::post('/city', [ProfileController::class, 'saveCity']);
            Route::get('/showcase/draft', [ProfileShowcaseDraftController::class, 'show']);
            Route::put('/showcase/draft', [ProfileShowcaseDraftController::class, 'update']);
            Route::post('/showcase/draft/submit-review', [ProfileShowcaseDraftController::class, 'submitForReview']);
            Route::delete('/showcase/draft', [ProfileShowcaseDraftController::class, 'destroy']);
            Route::get('/showcase/publication', [ProfileShowcasePublicationController::class, 'show']);
            Route::post('/showcase/publication', [ProfileShowcasePublicationController::class, 'store']);
            Route::get('/astro/summary', [AstroProfileController::class, 'showSummary']);
            Route::get('/astro/chart', [AstroProfileController::class, 'showChart']);
            Route::get('/astro', [AstroProfileController::class, 'show']);
            Route::post('/astro', [AstroProfileController::class, 'save']);
            Route::post('/astro/pair', [AstroProfileController::class, 'pair']);
            Route::post('/astro/transit', [AstroProfileController::class, 'transit']);
            Route::post('/astro/return', [AstroProfileController::class, 'returnChart']);
            Route::get('/mbti/quiz', [MbtiProfileController::class, 'quiz']);
            Route::post('/mbti/submit', [MbtiProfileController::class, 'submit']);
            Route::get('/mbti/result', [MbtiProfileController::class, 'result']);
        });

        Route::prefix('matches')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/confirm', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
            Route::get('/{targetUserId}/explanation', [MatchController::class, 'explanationByTarget'])
                ->whereNumber('targetUserId');
        });

        Route::get('/connections/{peerId}', [LiveConnectionController::class, 'show'])->whereNumber('peerId');
        Route::post('/connections/{peerId}/{kind}', [LiveConnectionController::class, 'transition'])->whereNumber('peerId')->middleware('throttle:conversations');
        Route::get('/match-rounds/current', [MatchRoundController::class, 'current']);

        Route::get('/conversation-peers/{peerUserId}', [ConversationController::class, 'showPeer'])
            ->whereNumber('peerUserId')
            ->middleware(DenyUnverifiedMessagingLiveAccess::class)
            ->middleware('throttle:conversations');

        Route::prefix('conversations')->group(function () {
            Route::get('', [ConversationController::class, 'index'])->middleware(DenyUnverifiedMessagingLiveAccess::class)->middleware('throttle:conversations');
            Route::post('', [ConversationController::class, 'store'])->middleware(DenyUnverifiedMessagingLiveAccess::class)->middleware('throttle:conversations');
            Route::get('/{conversationId}', [ConversationController::class, 'show'])
                ->whereNumber('conversationId')
                ->middleware(DenyUnverifiedMessagingLiveAccess::class)
                ->middleware('throttle:conversations');
        });

        Route::prefix('media')->group(function () {
            Route::get('', [MediaController::class, 'index'])->middleware('throttle:media');
            Route::post('', [MediaController::class, 'store'])->middleware('throttle:media');
            Route::get('/{assetId}', [MediaController::class, 'show'])
                ->whereNumber('assetId')
                ->middleware('throttle:media');
        });

        Route::prefix('relationships')->group(function () {
            Route::get('', [RelationshipController::class, 'index'])->middleware('throttle:relationships');
            Route::post('', [RelationshipController::class, 'store'])->middleware('throttle:relationships');
        });

        Route::prefix('notifications')->middleware('account.active')->group(function () {
            Route::get('', [NotificationController::class, 'index'])->middleware('throttle:notifications');
            Route::get('/unread-count', [NotificationController::class, 'unreadCount'])->middleware('throttle:notifications');
            Route::post('/read-all', [NotificationController::class, 'markAllRead'])->middleware('throttle:notifications');
            Route::post('/{notificationId}/read', [NotificationController::class, 'markRead'])
                ->whereNumber('notificationId')
                ->middleware('throttle:notifications');
        });

        Route::prefix('rtc')->middleware([RtcTransaction::class])->group(function () {
            Route::get('/calls', [RtcController::class, 'index']);
            Route::post('/calls', [RtcController::class, 'store']);
            Route::get('/calls/{callId}', [RtcController::class, 'show'])
                ->whereNumber('callId');
            Route::get('/calls/{callId}/livekit', [RtcController::class, 'livekit'])
                ->whereNumber('callId');
            Route::post('/calls/{callId}/accept', [RtcController::class, 'accept'])
                ->whereNumber('callId');
            Route::post('/calls/{callId}/connect', [RtcController::class, 'connect'])
                ->whereNumber('callId');
            Route::post('/calls/{callId}/heartbeat', [RtcController::class, 'heartbeat'])
                ->whereNumber('callId');
            Route::post('/calls/{callId}/reject', [RtcController::class, 'reject'])
                ->whereNumber('callId');
            Route::post('/calls/{callId}/end', [RtcController::class, 'end'])
                ->whereNumber('callId');
        });

        // 兼容旧设计中的单数路径
        Route::prefix('match')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/like', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
            Route::get('/{targetUserId}/explanation', [MatchController::class, 'explanationByTarget'])
                ->whereNumber('targetUserId');
        });

        Route::prefix('messages')->group(function () {
            Route::post('', [MessageController::class, 'send'])->middleware(DenyUnverifiedMessagingLiveAccess::class)->middleware('throttle:messages');
            Route::get('', [MessageController::class, 'list'])->middleware(DenyUnverifiedMessagingLiveAccess::class)->middleware('throttle:messages');
            Route::post('/read/{messageId}', [MessageController::class, 'markRead'])->middleware(DenyUnverifiedMessagingLiveAccess::class);
            Route::get('/ws/{userId}', [MessageController::class, 'websocketStub']);
        });

        Route::prefix('moderation')->group(function () {
            Route::get('/sanctions', [SanctionAppealController::class, 'index'])->middleware('account.active');
            Route::post('/sanctions/{sanctionId}/appeals', [SanctionAppealController::class, 'store'])->whereNumber('sanctionId')->middleware(['account.active', 'throttle:10,1']);
            Route::post('/reports', [ModerationController::class, 'report']);
            Route::post('/reports/{reportId}/appeal', [ModerationController::class, 'appeal']);
            Route::get('/blocks', [ModerationController::class, 'blocks']);
            Route::post('/blocks', [ModerationController::class, 'block']);
            Route::delete('/blocks/{blockedUserId}', [ModerationController::class, 'unblock'])
                ->whereNumber('blockedUserId');
        });

        Route::prefix('home')->group(function () {
            Route::get('/banner', [HomeController::class, 'banner']);
            Route::get('/shortcuts', [HomeController::class, 'shortcuts']);
            Route::get('/feed', [HomeController::class, 'feed']);
        });

        Route::prefix('status')->middleware(\App\Http\Middleware\JourneyPrivateResponse::class)->group(function () {
            Route::get('/posts', [StatusPostController::class, 'index']);
            Route::get('/posts/{postId}', [StatusPostController::class, 'show'])
                ->whereNumber('postId');
            Route::post('/posts', [StatusPostController::class, 'store']);
            Route::put('/posts/{id}/audience', [StatusPostController::class, 'audience'])->whereNumber('id');
            Route::post('/posts/{postId}/likes', [StatusPostController::class, 'like'])
                ->whereNumber('postId');
            Route::delete('/posts/{postId}/likes', [StatusPostController::class, 'unlike'])
                ->whereNumber('postId');
            Route::post('/posts/{postId}/report', [StatusPostController::class, 'report'])
                ->whereNumber('postId');
            Route::get('/authors/{userId}', [StatusPostController::class, 'author'])
                ->whereNumber('userId');
            Route::delete('/posts/{postId}', [StatusPostController::class, 'destroy'])
                ->whereNumber('postId');
        });

        Route::prefix('discover')->group(function () {
            Route::get('/feed', [HomeController::class, 'discoverFeed']);
        });

        Route::get('/content/{contentId}', [HomeController::class, 'content']);

        Route::prefix('geo')->group(function () {
            Route::get('/places', [GeoController::class, 'places']);
        });

        Route::prefix('admin')->middleware('admin.phone')->group(function () {
            Route::get('/users', [AdminController::class, 'users']);
            Route::get('/reports', [AdminController::class, 'reports']);
            Route::get('/reports/{reportId}', [AdminController::class, 'reportDetail'])
                ->whereNumber('reportId');
            Route::post('/reports/{reportId}/action', [AdminController::class, 'reportAction'])
                ->whereNumber('reportId');
            Route::get('/questionnaire/quality-stats', [AdminController::class, 'questionQualityStats']);
            Route::post('/questionnaire/prune-low-drop', [AdminController::class, 'pruneLowDropQuestions']);
            Route::post('/users/{uid}/disable', [AdminController::class, 'disable']);
            Route::get('/verify-queue', [AdminController::class, 'verifyQueue']);
            Route::post('/verify/{uid}', [AdminController::class, 'updateVerify']);
            Route::post('/dev/run-matching', [AdminController::class, 'devRunMatching']);
            Route::post('/dev/release-drop', [AdminController::class, 'devReleaseDrop']);
            Route::get('/dev/matching-debug', [AdminController::class, 'devMatchingDebugStatus']);
            Route::post('/dev/matching-debug', [AdminController::class, 'devMatchingDebugSwitch']);
        });

        Route::prefix('admin/matching')->middleware(['matching.operation', MatchingOperationTransaction::class])->group(function () {
            Route::get('/rounds', [AdminMatchingController::class, 'rounds']);
            Route::get('/rounds/{roundKey}', [AdminMatchingController::class, 'round']);
            Route::get('/runs/{runKey}', [AdminMatchingController::class, 'run']);
            Route::post('/rounds', [AdminMatchingController::class, 'prepare']);
            Route::post('/rounds/{roundKey}/execution-requests', [AdminMatchingController::class, 'executionRequest']);
            Route::post('/rounds/{roundKey}/reveal', [AdminMatchingController::class, 'reveal']);
            Route::post('/rounds/{roundKey}/retry', [AdminMatchingController::class, 'retry']);
            Route::post('/rounds/{roundKey}/close', [AdminMatchingController::class, 'close']);
            Route::post('/rounds/{roundKey}/compensation', [AdminMatchingController::class, 'compensation']);
        });
    });
})->middleware('secure.transport');
