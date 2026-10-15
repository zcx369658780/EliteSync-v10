<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
return new class extends Migration {
 public function up():void {
  Schema::table('users',function(Blueprint $t){$t->unsignedInteger('admin_revision')->default(0);$t->unsignedInteger('verify_revision')->default(0);$t->string('verify_reason',1000)->nullable();});
  Schema::table('moderation_reports',fn(Blueprint $t)=>$t->unsignedInteger('admin_revision')->default(0));
  Schema::create('admin_versions',function(Blueprint $t){$t->string('key')->primary();$t->unsignedInteger('revision')->default(0);});
  DB::table('admin_versions')->insert([['key'=>'questionnaire','revision'=>0],['key'=>'releases:android:development','revision'=>0]]);
  Schema::create('admin_operation_audits',function(Blueprint $t){$t->id();$t->unsignedBigInteger('actor_user_id')->nullable();$t->string('action',80);$t->string('target_type',80);$t->string('target_id',120);$t->string('reason',1000);$t->unsignedInteger('expected_version')->nullable();$t->json('before_state')->nullable();$t->json('after_state')->nullable();$t->timestamp('created_at');});
  Schema::create('admin_sanctions',function(Blueprint $t){$t->id();$t->unsignedBigInteger('user_id')->index();$t->unsignedBigInteger('report_id')->nullable();$t->string('kind',24);$t->boolean('active')->default(true);$t->unsignedBigInteger('actor_user_id');$t->string('reason',1000);$t->unsignedBigInteger('restored_by')->nullable();$t->timestamp('restored_at')->nullable();$t->timestamps();});
  Schema::table('messaging_consents',function(Blueprint $t){$t->dropUnique(['connection_id','purpose']);$t->unsignedInteger('generation')->default(1);$t->unique(['connection_id','purpose','generation'],'mc_generation_unique');});
 }
 public function down():void {
  // Consent generations are historical authorization evidence; do not collapse them.
  throw new \LogicException('Admin/consent history requires an explicit non-destructive rollback plan');
 }
};
