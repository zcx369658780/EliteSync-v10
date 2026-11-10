<?php
namespace App\Jobs;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Artisan;
final class ExecuteMatchingRun implements ShouldQueue {
 use Queueable;
 public int $tries=1;
 public int $timeout=180;
 public function __construct(public int $runId){$this->onQueue('v1008-matching');$this->afterCommit();}
 public function handle():void {if(Artisan::call('app:matching:execute-pending',['--once'=>true,'--run-id'=>$this->runId])!==0)throw new \RuntimeException('matching execution failed; inspect durable run and retry explicitly');}
}
