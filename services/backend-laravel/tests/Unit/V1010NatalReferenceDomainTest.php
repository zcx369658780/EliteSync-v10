<?php

namespace Tests\Unit;

use App\Services\NatalCalculationService;
use PHPUnit\Framework\TestCase;

class V1010NatalReferenceDomainTest extends TestCase
{
    public function test_historical_inputs_are_explicitly_unverified_without_starting_any_engine(): void
    {
        foreach (['1899-12-31', '2101-01-01'] as $date) {
            $results = (new NatalCalculationService)->compute(['civil_date' => $date,
                'normalized_time' => null, 'utc' => null], []);
            foreach ($results as $result) {
                $this->assertSame('UNVERIFIED', $result['status']);
                $this->assertSame('outside_current_independent_reference_domain', $result['reason']);
            }
            $this->assertNull($results['ziwei']['palaces']);
        }
    }
}
