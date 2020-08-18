<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\mail\Mail;
use akiyatkin\showcase\Showcase;
use infrajs\path\Path;

header('Cache-Control: no-store');

// Блок с глобальными переменными 
$ans = [];
$lang = Ans::REQ('lang', Cart::$conf['lang']['list'], Cart::$conf['lang']['def']);
$userlang = Ans::REQ('lang', User::$conf['lang']['list'], User::$conf['lang']['def']);
$place = Ans::REQ('place', ['orders', 'admin'], 'orders');

$silence = Ans::REQ('silence', 'bool');
$user = User::fromToken(Ans::REQ('token', 'string', ''));

if ($place == 'admin') {
    if (empty($user['admin'])) return Cart::fail($ans, $lang, 'CR003.1I');
}
$meta = Rest::meta();
if (!$meta) return Cart::fail($ans, $lang, 'CR018.1I');

//$ans['user'] = $user;
$action = Rest::first();
$order = null;
$fuser = null;
$pos = null;
$ouser = null;
$rules = $meta['rules'];

$root = Rest::getRoot();

$src = Path::theme($root . '/handlers.php');
$r = include($src);
if ($r !== 1) return $r;

$src = Path::theme($root . '/actions.php');
$r = include($src);
if ($r !== 1) return $r;
