<?php
declare(strict_types=1);
// Task-only metadata endpoint. No sockets to the Internet, no shell execution.
$path = (string) parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];
if (!(($path === '/packages.json' && $method === 'GET')
    || (preg_match('~^/p2/[a-z0-9_.-]+/[a-z0-9_.-]+(?:\x7edev)?\.json$~D', $path) && $method === 'GET')
    || ($path === '/security-advisories/' && in_array($method, ['GET', 'POST'], true)))) {
    http_response_code(403); echo '{"error":"metadata route denied"}'; return;
}
$body = file_get_contents('php://input');
if (strlen($body) > 1048576) { http_response_code(413); return; }
$id = bin2hex(random_bytes(16));
$request = json_encode(['id'=>$id, 'path'=>$path, 'method'=>$method,
    'query'=>$_SERVER['QUERY_STRING'] ?? '', 'content_type'=>$_SERVER['CONTENT_TYPE'] ?? '',
    'body_base64'=>base64_encode($body)], JSON_THROW_ON_ERROR);
$f = fopen('/queue/'.$id.'.pending', 'x');
if (!$f) { http_response_code(500); return; }
fwrite($f, $request); fflush($f); fsync($f); fclose($f);
rename('/queue/'.$id.'.pending', '/queue/'.$id.'.request');
$deadline = microtime(true) + 120;
while (!is_file('/queue/'.$id.'.reply')) {
    if (microtime(true) > $deadline) { http_response_code(504); return; }
    usleep(20000); clearstatcache();
}
$reply = json_decode(file_get_contents('/queue/'.$id.'.reply'), true, 512, JSON_THROW_ON_ERROR);
if (!is_int($reply['status']) || $reply['status'] < 100 || $reply['status'] > 599
    || !preg_match('/^[a-f0-9]{32}\.body$/D', $reply['body'])) { http_response_code(500); return; }
http_response_code($reply['status']); header('Content-Type: application/json');
if (($reply['encoding'] ?? '') === 'gzip') { header('Content-Encoding: gzip'); }
readfile('/queue/'.$reply['body']);
