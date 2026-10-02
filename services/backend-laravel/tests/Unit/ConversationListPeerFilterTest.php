<?php

namespace Tests\Unit;

use App\Http\Controllers\Api\V1\ConversationController;
use App\Models\User;
use App\Services\ConversationCapabilityService;
use App\Services\ConversationDomainService;
use Illuminate\Http\Request;
use Mockery;
use Tests\TestCase;

final class ConversationListPeerFilterTest extends TestCase
{
    public function test_list_excludes_invalid_and_denied_peers_without_recovering_identity_from_id(): void
    {
        $actor = new User();
        $actor->id = 11;
        $request = Request::create('/api/v1/conversations', 'GET');
        $request->setUserResolver(fn () => $actor);

        $service = Mockery::mock(ConversationDomainService::class);
        $service->shouldReceive('listForUser')->once()->with($actor)->andReturn(collect([
            ['id' => '41', 'entry_kind' => 'stored_conversation'],
            ['id' => '42', 'peer_user_id' => null],
            ['id' => '43', 'peer_user_id' => 0],
            ['id' => '44', 'peer_user_id' => -4],
            ['id' => '45', 'peer_user_id' => '5'],
            ['id' => '46', 'peer_user_id' => 6.0],
            ['id' => '47', 'peer_user_id' => true],
            ['id' => '48', 'peer_user_id' => []],
            ['id' => '49', 'peer_user_id' => 9],
            ['id' => 'stored', 'entry_kind' => 'stored_conversation', 'peer_user_id' => 7, 'conversation_id' => 70],
            ['id' => 'eligible', 'entry_kind' => 'eligible_match', 'peer_user_id' => 8, 'conversation_id' => null],
        ]));

        $capabilities = Mockery::mock(ConversationCapabilityService::class);
        $capabilities->shouldReceive('canRead')->once()->with(11, 9)->andReturn(false);
        $capabilities->shouldReceive('canRead')->once()->with(11, 7)->andReturn(true);
        $capabilities->shouldReceive('canRead')->once()->with(11, 8)->andReturn(true);
        $capabilities->shouldReceive('evaluate')->once()->with(11, 7)->andReturn(['can_read' => true]);
        $capabilities->shouldReceive('evaluate')->once()->with(11, 8)->andReturn(['can_read' => true]);

        $response = (new ConversationController())->index($request, $service, $capabilities);
        $body = $response->getData(true);

        self::assertSame(200, $response->getStatusCode());
        self::assertSame(2, $body['total']);
        self::assertSame(['stored', 'eligible'], array_column($body['items'], 'id'));
        self::assertSame([7, 8], array_column($body['items'], 'peer_user_id'));
        self::assertSame(['can_read' => true], $body['items'][0]['conversation_capability']);
        self::assertSame(['can_read' => true], $body['items'][1]['conversation_capability']);
        self::assertNull($body['note']);
    }

    public function test_list_returns_empty_items_and_matching_total_when_no_peer_can_be_read(): void
    {
        $actor = new User();
        $actor->id = 11;
        $request = Request::create('/api/v1/conversations', 'GET');
        $request->setUserResolver(fn () => $actor);

        $service = Mockery::mock(ConversationDomainService::class);
        $service->shouldReceive('listForUser')->once()->with($actor)->andReturn(collect([
            ['id' => '12', 'peer_user_id' => null],
            ['id' => 'denied', 'peer_user_id' => 13],
        ]));
        $capabilities = Mockery::mock(ConversationCapabilityService::class);
        $capabilities->shouldReceive('canRead')->once()->with(11, 13)->andReturn(false);
        $capabilities->shouldNotReceive('evaluate');

        $body = (new ConversationController())->index($request, $service, $capabilities)->getData(true);

        self::assertSame([], $body['items']);
        self::assertSame(0, $body['total']);
        self::assertSame('4.0A conversation domain skeleton only', $body['note']);
    }
}
