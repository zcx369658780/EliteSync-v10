<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\MatchingInputService;
use Illuminate\Http\Request;

final class MatchingInputController extends Controller
{
    public function show(Request $request, MatchingInputService $service)
    {
        return response()->json($service->read($request->user()));
    }

    public function update(Request $request, MatchingInputService $service)
    {
        $data = $request->validate([
            'revision' => 'required|integer|min:0', 'confirm' => 'required|accepted',
            'birthday' => 'required|date_format:Y-m-d|before_or_equal:today',
            'gender' => 'required|in:male,female', 'city_key' => 'required|string|max:64|regex:/^[\pL\pN _-]+$/u',
            'relationship_goal' => 'required|in:marriage,dating,friendship',
            'age_mode' => 'required|in:adult_any,range',
            'age_min' => 'required_if:age_mode,range|nullable|integer|min:18',
            'age_max' => 'required_if:age_mode,range|nullable|integer|min:18|gte:age_min',
            'region_mode' => 'required|in:same_city,long_distance',
            'height_cm' => 'present|nullable|integer|between:50,250',
            'education' => 'present|nullable|in:secondary,college,bachelor,master,doctor,undisclosed',
            'occupation' => 'present|nullable|string|max:100',
            'marital_history' => 'present|nullable|in:never_married,divorced,widowed,undisclosed',
            'children_status' => 'present|nullable|in:none,has_children,undisclosed',
            'children_intention' => 'present|nullable|in:want,not_want,unsure,undisclosed',
        ]);
        return response()->json($service->save((int) $request->user()->id, $data));
    }
}
