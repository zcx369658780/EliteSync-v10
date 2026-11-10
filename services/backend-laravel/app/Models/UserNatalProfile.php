<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserNatalProfile extends Model
{
    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['input' => 'array', 'settings' => 'array', 'context' => 'array', 'results' => 'array',
            'input_revision' => 'integer', 'result_revision' => 'integer'];
    }
}
