<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserDynamicChart extends Model
{
    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['request' => 'array', 'settings' => 'array', 'prepared' => 'array',
            'results' => 'array', 'input_revision' => 'integer', 'result_revision' => 'integer',
            'selected_event_index' => 'integer'];
    }
}
