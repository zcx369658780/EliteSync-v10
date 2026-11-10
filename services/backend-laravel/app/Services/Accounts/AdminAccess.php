<?php

namespace App\Services\Accounts;

use App\Models\User;

final class AdminAccess
{
    public function allows(?User $user): bool
    {
        return $user && ! $user->disabled && $user->isAdminRole()
            && in_array((string) $user->phone, config('app.admin_phones', []), true);
    }
}
