<?php

$router = $di->getRouter();

$router->add('/:params', [
    "controller" => 'index',
    "action" => 'index',
]);

$router->add('/bans/{page}', [
    "controller" => 'bans',
    "action" => 'index',
]);

$router->add('/bans/delete/{banid}', [
    "controller" => 'bans',
    "action" => 'delete',
]);

$router->add('/bans/unban/{banid}', [
    "controller" => 'bans',
    "action" => 'unban',
]);

$router->add('/bans/edit/{banid}', [
    "controller" => 'bans',
    "action" => 'edit',
]);

$router->add('/bans/validate', [
    "controller" => 'bans',
    "action" => 'validate',
]);

$router->add('/bans/view/{banid}', [
    "controller" => 'bans',
    "action" => 'view',
]);

$router->add('/adminlist', [
    "controller" => 'adminlist',
    "action" => 'index',
]);

$router->add('/servers', [
    "controller" => 'servers',
    "action" => 'index',
]);

$router->add('/servers/get', [
    "controller" => 'servers',
    "action" => 'get',
]);

$router->add('/signin', [
    "controller" => 'signin',
    "action" => 'index',
]);

$router->add('/signin/login', [
    "controller" => 'signin',
    "action" => 'login',
]);

$router->add('/signin/logout', [
    "controller" => 'signin',
    "action" => 'logout',
]);

$router->add('/admin', [
    "controller" => 'admin',
    "action" => 'index',
]);

$router->handle();
