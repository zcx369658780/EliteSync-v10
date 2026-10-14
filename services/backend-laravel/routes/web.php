<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\AdminController;
Route::get('/', fn () => view('welcome'));
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminController::class, 'login'])->name('login');
    Route::post('/login', [AdminController::class, 'authenticate'])->middleware('throttle:10,1')->name('authenticate');
    Route::middleware(['auth', 'account.active', 'admin.phone'])->group(function () {
        Route::get('/', [AdminController::class, 'users'])->name('users');
        Route::post('/users/{userId}/disable', [AdminController::class, 'disable'])->whereNumber('userId')->name('disable');
        Route::post('/logout', [AdminController::class, 'logout'])->name('logout');
    });
});
