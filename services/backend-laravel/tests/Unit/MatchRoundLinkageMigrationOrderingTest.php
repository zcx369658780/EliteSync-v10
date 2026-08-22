<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class MatchRoundLinkageMigrationOrderingTest extends TestCase
{
    public function test_down_drops_dependent_foreign_keys_before_composite_unique_index(): void
    {
        $migration = file_get_contents(dirname(__DIR__, 2).'/database/migrations/2026_07_12_000200_add_round_run_linkage_to_dating_matches.php');

        $this->assertIsString($migration);

        $userStateForeignKey = '$table->dropForeign([\'dating_match_id\'])';
        $userStateSupportingIndex = '$table->dropIndex(\'dating_round_user_states_dating_match_id_foreign\')';
        $roundForeignKey = '$table->dropForeign([\'round_id\'])';
        $runForeignKey = '$table->dropForeign([\'matching_run_id\'])';
        $pairUniqueIndex = '$table->dropUnique([\'round_id\', \'pair_key\'])';
        $linkageColumns = '$table->dropColumn([\'round_id\', \'matching_run_id\', \'pair_key\', \'pair_key_version\', \'released_at\'])';

        foreach ([$userStateForeignKey, $userStateSupportingIndex, $roundForeignKey, $runForeignKey, $pairUniqueIndex, $linkageColumns] as $statement) {
            $this->assertStringContainsString($statement, $migration);
        }

        $this->assertLessThan(strpos($migration, $userStateSupportingIndex), strpos($migration, $userStateForeignKey));
        $this->assertLessThan(strpos($migration, $roundForeignKey), strpos($migration, $userStateSupportingIndex));
        $this->assertLessThan(strpos($migration, $runForeignKey), strpos($migration, $roundForeignKey));
        $this->assertLessThan(strpos($migration, $pairUniqueIndex), strpos($migration, $runForeignKey));
        $this->assertLessThan(strpos($migration, $linkageColumns), strpos($migration, $pairUniqueIndex));
    }
}
