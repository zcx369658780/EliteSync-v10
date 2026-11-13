<?php

namespace App\Services;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

/** Private self-reported inputs. Saving is independent of participation and publication. */
final class MatchingInputService
{
    public const VERSION = 'matching_input_v1';
    public const RULE_VERSION = 'questionnaire_bilateral_v1017';

    public function read(User $user): array
    {
        $row = DB::table('matching_inputs')->where('user_id', $user->id)->first();
        $payload = $row ? json_decode($row->payload, true, 512, JSON_THROW_ON_ERROR) : [];
        $confirmed = $row && $row->confirmation_version === self::VERSION
            && hash_equals($row->confirmed_profile_hash, $this->profileHash($user))
            && hash_equals($row->confirmed_goal_answer_hash, $this->goalAnswerHash((int) $user->id));

        return array_merge($payload, [
            'revision' => (int) ($row->revision ?? 0),
            'confirmed' => (bool) $confirmed,
            'confirmation_version' => self::VERSION,
            'birthday' => $user->birthday?->format('Y-m-d'),
            'gender' => $user->gender,
            'legacy_city' => $user->city,
            'city_key' => $payload['city_key'] ?? null,
            'relationship_goal' => $user->relationship_goal,
            'age_years' => $this->age($user),
            'business_timezone' => 'Asia/Shanghai',
            'scope' => '本人自述私密匹配输入；保存不报名，不构成年龄或身份认证',
        ]);
    }

    public function save(int $actor, array $data): array
    {
        return DB::transaction(function () use ($actor, $data) {
            app(CurrentQuestionnaire::class)->lock();
            app(JourneyStore::class)->users([$actor]);
            $user = User::findOrFail($actor);
            $row = DB::table('matching_inputs')->where('user_id', $actor)->lockForUpdate()->first();
            abort_unless((int) ($row->revision ?? 0) === (int) $data['revision'], 409, '匹配输入已更新，请重新读取后保存');
            $data['city_key'] = mb_strtolower(preg_replace('/\s+/u', '', trim($data['city_key'])));
            abort_if($data['city_key'] === '', 422, '请确认现居城市键');
            $user->forceFill([
                'birthday' => $data['birthday'], 'gender' => $data['gender'],
                'city' => $data['city_key'], 'relationship_goal' => $data['relationship_goal'],
            ])->save();
            if ($data['age_mode'] === 'adult_any') {
                $data['age_min'] = 18;
                $data['age_max'] = null;
            }
            unset($data['revision'], $data['confirm'], $data['birthday'], $data['gender'], $data['relationship_goal']);
            DB::table('matching_inputs')->updateOrInsert(['user_id' => $actor], [
                'revision' => (int) ($row->revision ?? 0) + 1,
                'payload' => json_encode($data, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE),
                'confirmation_version' => self::VERSION,
                'confirmed_profile_hash' => $this->profileHash($user),
                'confirmed_goal_answer_hash' => $this->goalAnswerHash($actor),
                'created_at' => $row->created_at ?? now(), 'updated_at' => now(),
            ]);
            return $this->read($user);
        });
    }

    public function readinessReason(User $user): ?string
    {
        $input = $this->read($user);
        if (! $input['confirmed']) {
            return 'matching_inputs_unconfirmed';
        }
        if ($input['age_years'] === null || $input['age_years'] < 18) {
            return 'adult_self_report_required';
        }
        if (! in_array($input['relationship_goal'], ['marriage', 'dating'], true)) {
            return 'friendship_only';
        }
        return null;
    }

    public function pairAllowed(User $a, User $b): bool
    {
        if ($this->readinessReason($a) || $this->readinessReason($b)) {
            return false;
        }
        $left = $this->read($a);
        $right = $this->read($b);
        if ($a->gender === $b->gender || ! in_array($a->gender, ['male', 'female'], true)
            || ! in_array($b->gender, ['male', 'female'], true)) {
            return false;
        }
        if (($left['region_mode'] === 'same_city' || $right['region_mode'] === 'same_city')
            && $left['city_key'] !== $right['city_key']) {
            return false;
        }
        return $this->acceptsAge($left, $right['age_years']) && $this->acceptsAge($right, $left['age_years']);
    }

    public function sourceDigest(User $user): string
    {
        return hash('sha256', json_encode([
            'rule' => self::RULE_VERSION, 'profile' => $this->profileHash($user),
            'input' => DB::table('matching_inputs')->where('user_id', $user->id)->first(),
            'answers' => QuestionnaireAnswer::where('user_id', $user->id)->orderBy('questionnaire_question_id')->get([
                'questionnaire_question_id', 'answer_payload', 'selected_answer_json',
                'acceptable_answers_json', 'importance', 'version',
            ])->toArray(),
        ], JSON_THROW_ON_ERROR));
    }

    private function profileHash(User $user): string
    {
        return hash('sha256', json_encode([
            $user->birthday?->format('Y-m-d'), $user->gender, $user->city, $user->relationship_goal,
        ], JSON_THROW_ON_ERROR));
    }

    private function goalAnswerHash(int $id): string
    {
        $ids = QuestionnaireQuestion::where('category', 'relationship_goals')->where('enabled', true)->pluck('id');
        $answers = QuestionnaireAnswer::where('user_id', $id)->whereIn('questionnaire_question_id', $ids)
            ->orderBy('questionnaire_question_id')->get()->map(fn ($answer) => [
                (int) $answer->questionnaire_question_id,
                $answer->selected_answer_json ?? data_get($answer->answer_payload, 'selected_answer', [data_get($answer->answer_payload, 'value')]),
            ])->all();
        return hash('sha256', json_encode($answers, JSON_THROW_ON_ERROR));
    }

    private function age(User $user): ?int
    {
        return $user->birthday ? (int) CarbonImmutable::parse($user->birthday->format('Y-m-d'), 'Asia/Shanghai')
            ->diffInYears(CarbonImmutable::now('Asia/Shanghai')->startOfDay(), false) : null;
    }

    private function acceptsAge(array $input, int $age): bool
    {
        return $age >= (int) $input['age_min'] && ($input['age_max'] === null || $age <= (int) $input['age_max']);
    }
}
