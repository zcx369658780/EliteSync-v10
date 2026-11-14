<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ContactService;
use Illuminate\Http\Request;

final class ContactController extends Controller
{
    public function index(Request $request, ContactService $contacts)
    {
        $data = $request->validate(['purpose' => 'required|in:buddy_invite,friend_request,chat,connection',
            'limit' => 'sometimes|integer|min:1|max:20', 'cursor' => 'nullable|integer|min:0',
            'query' => 'nullable|string|max:60']);
        return response()->json($contacts->listing((int) $request->user()->id, $data['purpose'],
            $data['limit'] ?? 20, (int) ($data['cursor'] ?? 0), trim($data['query'] ?? '')));
    }
}
