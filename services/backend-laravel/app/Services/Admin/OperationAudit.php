<?php
namespace App\Services\Admin;
use Illuminate\Support\Facades\DB;
final class OperationAudit {
 public static function record(?int $actor,string $action,string $type,string|int $id,string $reason,?int $expected,array $before,array $after):void {
  if(DB::transactionLevel()<1)throw new \LogicException('Business audit requires the business transaction');
  DB::table('admin_operation_audits')->insert(['actor_user_id'=>$actor,'action'=>$action,'target_type'=>$type,'target_id'=>(string)$id,'reason'=>$reason,'expected_version'=>$expected,'before_state'=>json_encode($before,JSON_THROW_ON_ERROR),'after_state'=>json_encode($after,JSON_THROW_ON_ERROR),'created_at'=>now()]);
 }
}
