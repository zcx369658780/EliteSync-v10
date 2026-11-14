<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

final class SupportFeedback extends Model
{
    protected $table = 'support_feedback';

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['revision' => 'integer'];
    }
}
