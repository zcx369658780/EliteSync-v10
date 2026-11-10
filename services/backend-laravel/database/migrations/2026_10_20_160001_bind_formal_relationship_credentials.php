<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up():void { foreach(['credential_a','credential_b'] as $c) { if(!Schema::hasColumn('formal_relationships',$c)) Schema::table('formal_relationships',fn(Blueprint $t)=>$t->uuid($c)->nullable()); } }
 public function down():void { Schema::table('formal_relationships',fn(Blueprint $t)=>$t->dropColumn(['credential_a','credential_b'])); }
};
