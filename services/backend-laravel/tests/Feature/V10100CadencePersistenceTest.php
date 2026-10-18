<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use PHPUnit\Framework\Attributes\DataProvider;
use RuntimeException;
use Tests\TestCase;

final class V10100CadencePersistenceTest extends TestCase
{
    use RefreshDatabase;

    // SQLite does not enforce VARCHAR lengths. These tests prove data/index preservation
    // and the explicit rollback guard; real length enforcement requires MariaDB validation.
    public function test_widening_preserves_existing_rows_and_indexes_and_stores_full_cadence(): void
    {
        $migration = $this->migration();
        $indexes = Schema::getIndexes('dating_matches');
        $migration->down(); // Empty tables can return to the legacy shape.
        $shortId = $this->insertMatch('2026-W42');

        $migration->up();
        $cadence = str_repeat('c', 120);
        $longId = $this->insertMatch($cadence);

        $this->assertDatabaseHas('dating_matches', ['id' => $shortId, 'week_tag' => '2026-W42']);
        $this->assertDatabaseHas('dating_matches', ['id' => $longId, 'week_tag' => $cadence]);
        $this->assertEqualsCanonicalizing($indexes, Schema::getIndexes('dating_matches'));
    }

    #[DataProvider('longCadences')]
    public function test_rollback_refuses_long_values_without_changing_any_rows(string $cadence): void
    {
        $shortId = $this->insertMatch('2026-W42');
        $longId = $this->insertMatch($cadence);
        $rows = DB::table('dating_matches')->orderBy('id')->get()->toArray();
        $indexes = Schema::getIndexes('dating_matches');

        try {
            $this->migration()->down();
            $this->fail('Rollback must refuse a value longer than 16 characters.');
        } catch (RuntimeException $error) {
            $this->assertSame('week_tag_rollback_blocked_values_exceed_16_characters', $error->getMessage());
        }

        $this->assertEquals($rows, DB::table('dating_matches')->orderBy('id')->get()->toArray());
        $this->assertDatabaseHas('dating_matches', ['id' => $shortId, 'week_tag' => '2026-W42']);
        $this->assertDatabaseHas('dating_matches', ['id' => $longId, 'week_tag' => $cadence]);
        $this->assertEqualsCanonicalizing($indexes, Schema::getIndexes('dating_matches'));
    }

    #[DataProvider('shortCadences')]
    public function test_rollback_preserves_empty_and_short_values(string $cadence): void
    {
        $id = $this->insertMatch($cadence);
        $indexes = Schema::getIndexes('dating_matches');
        $migration = $this->migration();

        try {
            $migration->down();
            $this->assertDatabaseHas('dating_matches', ['id' => $id, 'week_tag' => $cadence]);
            $this->assertEqualsCanonicalizing($indexes, Schema::getIndexes('dating_matches'));
        } finally {
            $migration->up();
        }
    }

    public static function longCadences(): array
    {
        return [
            '17 ASCII characters' => [str_repeat('c', 17)],
            'full 120 character cadence' => [str_repeat('c', 120)],
            '17 multibyte characters' => [str_repeat('界', 17)],
        ];
    }

    public static function shortCadences(): array
    {
        return [
            'empty value' => [''],
            'legacy week' => ['2026-W42'],
            '16 ASCII characters' => [str_repeat('c', 16)],
            '16 multibyte characters' => [str_repeat('界', 16)],
        ];
    }

    private function migration(): Migration
    {
        return require database_path('migrations/2026_10_18_000001_widen_match_week_tag_for_round_cadence.php');
    }

    private function insertMatch(string $cadence): int
    {
        $suffix = bin2hex(random_bytes(6));
        $a = User::create([
            'name' => 'Cadence migration fixture A', 'phone' => 'cadence-a-'.$suffix,
            'password' => 'Cadence-fixture-only-2026!', 'role' => 'user',
        ]);
        $b = User::create([
            'name' => 'Cadence migration fixture B', 'phone' => 'cadence-b-'.$suffix,
            'password' => 'Cadence-fixture-only-2026!', 'role' => 'user',
        ]);

        return DB::table('dating_matches')->insertGetId([
            'week_tag' => $cadence, 'user_a' => $a->id, 'user_b' => $b->id,
            'drop_released' => false, 'created_at' => now(), 'updated_at' => now(),
        ]);
    }
}
