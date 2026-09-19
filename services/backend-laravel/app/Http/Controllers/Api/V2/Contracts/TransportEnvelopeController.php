<?php

namespace App\Http\Controllers\Api\V2\Contracts;

use App\Domain\TransportNeutralApplicationRequestResponseContract;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class TransportEnvelopeController extends Controller
{
    public function __construct(
        private readonly TransportNeutralApplicationRequestResponseContract $transport,
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $envelope = $this->transport->handle($request->json()->all());

        return response()->json($envelope, $this->httpStatus($envelope));
    }

    /** @param array<string, mixed> $envelope */
    private function httpStatus(array $envelope): int
    {
        $disposition = $envelope['transport_disposition'] ?? null;
        $condition = $envelope['bounded_error_condition'] ?? null;

        if ($disposition === TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION) {
            return 200;
        }

        return match ([$disposition, $condition]) {
            [TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, 'MALFORMED_REQUEST_ENVELOPE'],
            [TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, 'UNKNOWN_TOP_LEVEL_FIELD'],
            [TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, 'MALFORMED_FAMILY_PAYLOAD'],
            [TransportNeutralApplicationRequestResponseContract::UNKNOWN, 'UNSUPPORTED_FAMILY'] => 400,
            [TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, 'REQUEST_IDENTITY_PAYLOAD_CONFLICT'] => 409,
            [TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, 'APPLICATION_DISPATCH_REJECTED'] => 500,
            default => 500,
        };
    }
}
