<?php

namespace App\Services;

use App\Models\UserToolRevision;
use Illuminate\Database\Eloquent\Model;

final class ToolRevisionHistory
{
    // Called under the existing owner/record write lock before replacing a revision.
    public function archive(Model $row, string $tool): void
    {
        $fields = $tool === 'natal'
            ? ['input', 'settings', 'context']
            : ['chart_type', 'request', 'settings', 'selected_event_index'];
        UserToolRevision::firstOrCreate([
            'user_id' => $row->user_id, 'tool' => $tool, 'record_id' => $row->id,
            'input_revision' => $row->input_revision,
        ], ['snapshot' => $row->only([...$fields, 'id', 'user_id', 'input_revision',
            'result_revision', 'input_signature', 'status', 'results', 'created_at', 'updated_at'])]);
    }
}
