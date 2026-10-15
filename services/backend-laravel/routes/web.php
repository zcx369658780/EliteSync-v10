<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\AdminController;
Route::get('/', fn () => view('welcome'));
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminController::class, 'login'])->name('login');
    Route::post('/login', [AdminController::class, 'authenticate'])->middleware('throttle:10,1')->name('authenticate');
    Route::middleware(['auth:web', 'account.active', 'admin.phone'])->group(function () {
        Route::get('/', [AdminController::class, 'users'])->name('users');
        Route::get('/users/{id}', [\App\Http\Controllers\Web\AdminOperationsController::class,'user'])->whereNumber('id')->name('user');
        Route::post('/users/{id}/review',[\App\Http\Controllers\Web\AdminOperationsController::class,'review'])->whereNumber('id')->name('review');
        Route::post('/users/{id}/punishment',[\App\Http\Controllers\Web\AdminOperationsController::class,'punishment'])->whereNumber('id')->name('punishment');
        Route::get('/reports',[\App\Http\Controllers\Web\AdminOperationsController::class,'reports'])->name('reports');
        Route::get('/reports/{id}',[\App\Http\Controllers\Web\AdminOperationsController::class,'report'])->whereNumber('id')->name('report');
        Route::post('/reports/{id}',[\App\Http\Controllers\Web\AdminOperationsController::class,'reportAction'])->whereNumber('id')->name('report.action');
        Route::get('/matching',[\App\Http\Controllers\Web\AdminMatchingWebController::class,'index'])->name('matching');
        Route::post('/matching',[\App\Http\Controllers\Web\AdminMatchingWebController::class,'action'])->middleware('matching.operation')->name('matching.action');
        Route::get('/audits' ,[\App\Http\Controllers\Web\AdminOperationsController::class,'audits'])->name('audits');
        Route::get('/questions',[\App\Http\Controllers\Web\AdminQuestionController::class,'index'])->name('questions');
        Route::post('/questions/preview',[\App\Http\Controllers\Web\AdminQuestionController::class,'preview'])->name('questions.preview');
        Route::post('/questions/apply',[\App\Http\Controllers\Web\AdminQuestionController::class,'apply'])->name('questions.apply');
        Route::get('/releases',[\App\Http\Controllers\Web\AdminReleaseController::class,'index'])->name('releases');
        Route::post('/releases',[\App\Http\Controllers\Web\AdminReleaseController::class,'store'])->name('releases.store');

        Route::post('/users/{userId}/disable', [AdminController::class, 'disable'])->whereNumber('userId')->name('disable');
        Route::post('/logout', [AdminController::class, 'logout'])->name('logout');
    });
});
