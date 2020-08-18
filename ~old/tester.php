<?php
use infrajs\db\Db;
use infrajs\ans\Ans;
use infrajs\config\Config;


$ans = array();

$db = Db::pdo();
if (!$db) return Ans::err($ans, 'Требуется соединение с базой данных');

$conf = Config::get('session');
if (!$conf['sync']) return Ans::err($ans, 'Требуется синхронизация сессии');

return Ans::ret($ans);