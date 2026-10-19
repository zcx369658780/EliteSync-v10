<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

final class V1011RelationshipDevelopmentSeeder extends Seeder
{
    public function run(): void
    {
        $db = DB::connection();
        if (! app()->environment('local') || $db->getDriverName() !== 'mysql'
            || $db->getDatabaseName() !== 'elitesync_v10_1_1_dev' || $db->getConfig('host') !== '127.0.0.1'
            || (int) $db->getConfig('port') !== 43322 || $db->getConfig('unix_socket') || User::exists()) {
            throw new \RuntimeException('V1011_FRESH_OWNED_DATABASE_REQUIRED');
        }
        $path = (string) env('V1011_CREDENTIALS_FILE');
        if (! $path || ! is_file($path)) {
            throw new \RuntimeException('V1011_PRIVATE_CREDENTIALS_REQUIRED');
        }
        $accounts = json_decode(file_get_contents($path), true, flags: JSON_THROW_ON_ERROR)['accounts'] ?? [];
        if (array_keys($accounts) !== ['alice', 'bob', 'charlie', 'diana', 'admin']) {
            throw new \RuntimeException('V1011_DATASET_IDENTITY_MISMATCH');
        }
        DB::transaction(function () use ($accounts) {
            foreach ($accounts as $key => $account) {
                $u = User::create(['name' => ucfirst($key).' Development', 'phone' => $account['phone'], 'password' => Hash::make($account['password']),
                    'role' => $key === 'admin' ? 'admin' : 'user', 'account_type' => 'test', 'is_synthetic' => false,
                    'generation_version' => 'v10.1.1-relationships', 'realname_verified' => false, 'verify_status' => 'approved', 'disabled' => false]);
                if ($key !== 'admin') {
                    DB::table('v1011_erasure_members')->insert(['user_id' => $u->id, 'dataset' => 'v10.1.1-controlled-synthetic',
                        'provenance' => 'V1011RelationshipDevelopmentSeeder:owner-authorized-fictional-dataset', 'registered_at' => now()]);
                }
            }
        });
    }
}
