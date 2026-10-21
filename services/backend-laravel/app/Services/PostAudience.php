<?php
namespace App\Services;
use App\Models\StatusPost;use App\Models\User;use Illuminate\Support\Facades\DB;
/** Shared current authorization for posts, comments and private covers. */
final class PostAudience {
 public function allowedLocked(StatusPost $post,int $viewer):bool {
  if($post->is_deleted)return false;
  $users=User::whereIn('id',[$viewer,(int)$post->author_user_id])->orderBy('id')->lockForUpdate()->get();
  if($users->count()!==count(array_unique([$viewer,(int)$post->author_user_id]))||$users->contains(fn($u)=>$u->disabled||$u->account_status!=='active'||$u->moderation_status!=='normal'))return false;
  return app(SocialPolicy::class)->pairAllowed($viewer,(int)$post->author_user_id)&&($viewer===(int)$post->author_user_id||($post->audience==='FRIENDS'&&app(SocialPolicy::class)->friendship($viewer,(int)$post->author_user_id)));
 }
 public function run(int $viewer,int $id,callable $work,array $extra=[],bool $optional=false):mixed {
  $owner=StatusPost::whereKey($id)->value('author_user_id');if($owner===null)return $optional?null:abort(404,'unavailable');
  return DB::transaction(function()use($viewer,$id,$owner,$work,$extra,$optional){app(JourneyStore::class)->users([$viewer,(int)$owner,...$extra],true);$post=StatusPost::whereKey($id)->lockForUpdate()->first();if(!$post||(int)$post->author_user_id!==(int)$owner||!$this->allowedLocked($post,$viewer))return $optional?null:abort(404,'unavailable');return $work($post);},3);
 }
}
