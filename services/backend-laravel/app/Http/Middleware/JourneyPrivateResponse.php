<?php
namespace App\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
final class JourneyPrivateResponse {
 public function handle(Request $r, Closure $next) {
  $response=$next($r);
  if($r->is('api/v1/journey*','api/v1/formal-relationships*','api/v1/privacy*','api/v1/profile-peers/*','api/v1/match-rounds/*','api/v1/matches/*','api/v1/match/*')) $response->headers->set('Cache-Control','private, no-store');
  return $response;
 }
}
