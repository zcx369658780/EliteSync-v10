<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private const INDEX = 'media_owner_upload_unique';

    public function up(): void
    {
        $hasColumn = Schema::hasColumn('media_assets', 'client_upload_id');
        $hasIndex = Schema::hasIndex('media_assets', ['owner_user_id', 'client_upload_id'], 'unique');
        if (! $hasColumn && ! $hasIndex && in_array(DB::getDriverName(), ['mariadb', 'mysql'], true)) {
            $uuidType = DB::getDriverName() === 'mariadb'
                && version_compare(DB::connection()->getServerVersion(), '10.7.0', '>=')
                ? 'UUID' : 'CHAR(36)';
            DB::statement('ALTER TABLE media_assets ADD client_upload_id '.$uuidType.' NULL, ADD UNIQUE '.self::INDEX.' (owner_user_id, client_upload_id)');

            return;
        }

        // Also recover an installation interrupted between earlier split DDL
        // statements or after DDL completed but before the migration was logged.
        Schema::table('media_assets', function (Blueprint $table) use ($hasColumn, $hasIndex) {
            if (! $hasColumn) {
                $table->uuid('client_upload_id')->nullable();
            }
            if (! $hasIndex) {
                $table->unique(['owner_user_id', 'client_upload_id'], self::INDEX);
            }
        });
    }

    public function down(): void
    {
        $hasColumn = Schema::hasColumn('media_assets', 'client_upload_id');
        $hasIndex = Schema::hasIndex('media_assets', self::INDEX, 'unique');
        if ($hasColumn && $hasIndex && in_array(DB::getDriverName(), ['mariadb', 'mysql'], true)) {
            // InnoDB may have replaced the implicit foreign-key index when
            // the composite unique index was added.
            $ownerIndexed = collect(Schema::getIndexes('media_assets'))->contains(
                fn ($index) => $index['name'] !== self::INDEX && ($index['columns'][0] ?? null) === 'owner_user_id',
            );
            $ownerIndex = $ownerIndexed ? '' : 'ADD INDEX media_assets_owner_lookup (owner_user_id), ';
            DB::statement('ALTER TABLE media_assets '.$ownerIndex.'DROP INDEX '.self::INDEX.', DROP COLUMN client_upload_id');

            return;
        }

        Schema::table('media_assets', function (Blueprint $table) use ($hasColumn, $hasIndex) {
            if ($hasIndex) {
                $table->dropUnique(self::INDEX);
            }
            if ($hasColumn) {
                $table->dropColumn('client_upload_id');
            }
        });
    }
};
