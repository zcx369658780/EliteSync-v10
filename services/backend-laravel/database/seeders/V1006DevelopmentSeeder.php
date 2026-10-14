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
        if (! app()->environment('local') ||
            config('database.connections.mysql.host') !== '127.0.0.1' ||
            (int) config('database.connections.mysql.port') !== 43316 ||
            DB::connection()->getDatabaseName() !== 'elitesync_v1006_dev') {
            throw new \RuntimeException('V1006 seeding requires the dedicated local database.');
        }
        $path = env('V1006_CREDENTIALS_FILE');
        $data = json_decode(file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);
        $kinds = array_keys($data['accounts']);
        sort($kinds);
        if ($kinds !== ['admin', 'control', 'target']) {
            throw new \RuntimeException('Only the three named fictional accounts are permitted.');
        }
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
