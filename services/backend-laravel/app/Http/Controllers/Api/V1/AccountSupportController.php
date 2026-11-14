<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;

final class AccountSupportController extends Controller
{
    public function capabilities()
    {
        return response()->json([
            'password_recovery' => ['available' => false, 'status' => 'VERIFICATION_PROVIDER_NOT_CONFIGURED'],
            'password_change' => ['available' => true, 'requires' => ['active_login', 'current_password']],
            'closure_receipt_recovery' => ['available' => true, 'requires' => ['phone', 'original_closure_key', 'current_password']],
        ])->header('Cache-Control', 'no-store');
    }
}
