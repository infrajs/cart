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
$lang = Ans::REQ('lang', Cart::$conf['lang']['list'], Cart::$conf['lang']['def']); //Для сайтов с 1 языком
$userlang = Ans::REQ('lang', User::$conf['lang']['list'], User::$conf['lang']['def']); //Для сайтов с 1 языком

$place = Ans::REQ('place', ['orders', 'admin'], 'orders');

$city_id = null;
$city = null; //Для сайтов без выбора города, когда заказ без расчёта доставки. Расширение City работает в холостую по дефолту.
$email = null;
$timezone = null;

$silence = Ans::REQ('silence', 'bool');

$token = Ans::REQ('token', 'string', '');
$user = User::fromToken($token);
if ($token && !$user) return Cart::fail($ans, $lang, 'CR061.1I');

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
