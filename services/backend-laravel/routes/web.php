<?php

use App\Http\Controllers\Web\AccountSecurityAuditController;
use App\Http\Controllers\Web\AdminController;
use App\Http\Controllers\Web\AdminMatchingWebController;
use App\Http\Controllers\Web\AdminOperationsController;
use App\Http\Controllers\Web\AdminQuestionController;
use App\Http\Controllers\Web\AdminReleaseController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => view('welcome'));
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminController::class, 'login'])->name('login');
    Route::post('/login', [AdminController::class, 'authenticate'])->middleware('throttle:10,1')->name('authenticate');
    Route::middleware(['auth:web', 'account.active', 'admin.phone'])->group(function () {
        Route::get('/', [AdminController::class, 'users'])->name('users');
        Route::get('/users/{id}', [AdminOperationsController::class, 'user'])->whereNumber('id')->name('user');
        Route::post('/users/{id}/review', [AdminOperationsController::class, 'review'])->whereNumber('id')->name('review');
        Route::post('/users/{id}/punishment', [AdminOperationsController::class, 'punishment'])->whereNumber('id')->name('punishment');
        Route::get('/reports', [AdminOperationsController::class, 'reports'])->name('reports');
        Route::get('/reports/{id}', [AdminOperationsController::class, 'report'])->whereNumber('id')->name('report');
        Route::post('/reports/{id}', [AdminOperationsController::class, 'reportAction'])->whereNumber('id')->name('report.action');
        Route::get('/matching', [AdminMatchingWebController::class, 'index'])->name('matching');
        Route::post('/matching', [AdminMatchingWebController::class, 'action'])->middleware('matching.operation')->name('matching.action');
        Route::get('/account-security', AccountSecurityAuditController::class)->name('account-security');
        Route::get('/audits', [AdminOperationsController::class, 'audits'])->name('audits');
        $platform = \App\Http\Controllers\Web\PlatformController::class;
        Route::get('/platform-events', [$platform, 'index'])->name('platform-events');
        Route::post('/platform-events', [$platform, 'store']);
        Route::post('/platform-events/{id}/actions', [$platform, 'action'])->whereUuid('id');
        Route::get('/safety-cases/{id}', [$platform, 'detail'])->whereUuid('id');
        Route::get('/safety-cases/{id}/evidence', [$platform, 'evidence'])->whereUuid('id');
        Route::get('/safety-cases/{id}/appeal-review', [$platform, 'appealWorkspace'])->whereUuid('id');
        Route::post('/safety-cases/{id}/decisions', [$platform, 'decide'])->whereUuid('id');
        Route::post('/safety-cases/{id}/reviews', [$platform, 'review'])->whereUuid('id');
        Route::get('/buddy-community', [\App\Http\Controllers\Web\BuddyCommunityController::class, 'index'])->name('buddy-community');
        Route::post('/buddy-community/comments/{reportId}/hide', [\App\Http\Controllers\Web\BuddyCommunityController::class, 'hide'])->whereNumber('reportId')->name('buddy-community.hide');
        Route::get('/questions', [AdminQuestionController::class, 'index'])->name('questions');
        Route::post('/questions/preview', [AdminQuestionController::class, 'preview'])->name('questions.preview');
        Route::post('/questions/apply', [AdminQuestionController::class, 'apply'])->name('questions.apply');
        Route::get('/releases', [AdminReleaseController::class, 'index'])->name('releases');
        Route::post('/releases', [AdminReleaseController::class, 'store'])->name('releases.store');

        Route::post('/users/{userId}/disable', [AdminController::class, 'disable'])->whereNumber('userId')->name('disable');
        Route::post('/logout', [AdminController::class, 'logout'])->name('logout');
    });
});
