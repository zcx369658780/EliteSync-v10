<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\LiveConsentService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

final class V1007DevelopmentSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment('local') || ! app(LiveConsentService::class)->enabled()) {
            throw new \RuntimeException('Wrong development database');
        }
        $data = json_decode(file_get_contents(env('V1007_CREDENTIALS_FILE')), true, flags: JSON_THROW_ON_ERROR);
        $names = array_keys($data['accounts']);
        sort($names);
        if ($names !== ['admin', 'alice', 'bob', 'disabled', 'incomplete']) {
            throw new \RuntimeException('Unexpected accounts');
        }
        foreach ($data['accounts'] as $kind => $account) {
            $existing = User::where('phone', $account['phone'])->first();
            if ($existing) {
                if ($existing->generation_version !== 'v10.0.7') {
                    throw new \RuntimeException('Account collision');
                }

continue;
            }
            User::create(['phone' => $account['phone'], 'password' => Hash::make($account['password']), 'name' => 'V1007 Fictional '.$kind,
                'role' => $kind === 'admin' ? 'admin' : 'user', 'gender' => $kind === 'alice' ? 'female' : 'male', 'city' => 'V1007 Development City',
                'birthday' => $kind === 'alice' ? '1994-03-18' : '1989-09-05', 'relationship_goal' => 'long_term', 'account_type' => 'test',
                'generation_version' => 'v10.0.7', 'is_synthetic' => false, 'disabled' => $kind === 'disabled', 'realname_verified' => false]);
        }
    }
}
