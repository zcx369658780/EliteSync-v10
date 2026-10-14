<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

final class V1006DevelopmentSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment('local') || DB::connection()->getDatabaseName() !== 'elitesync_v1006_dev') {
            throw new \RuntimeException('V1006 seeding requires the dedicated local database.');
        }
        $path = env('V1006_CREDENTIALS_FILE');
        $data = json_decode(file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);
        foreach ($data['accounts'] as $kind => $account) {
            $existing = User::where('phone', $account['phone'])->first();
            if ($existing) {
                if ($existing->generation_version !== 'v10.0.6') {
                    throw new \RuntimeException('Seed account collision; refusing to overwrite.');
                }
                continue; // Do not reset city/disabled state on a repeat invocation.
            }
            User::create([
                'name' => 'V1006 Fictional '.$kind, 'phone' => $account['phone'],
                'password' => Hash::make($account['password']),
                'role' => $kind === 'admin' ? 'admin' : 'user',
                'city' => 'Initial Development City', 'gender' => 'male',
                'relationship_goal' => 'friendship', 'realname_verified' => false,
                'disabled' => false, 'is_synthetic' => true,
                'account_type' => 'test', 'generation_version' => 'v10.0.6',
            ]);
        }
    }
}
