<?php

use infrajs\db\Db;
use infrajs\path\Path;

$db = &Db::pdo();

$filesql = Path::theme('-cart/update.sql');
$sql = file_get_contents($filesql);

$r = $db->exec($sql);
//if ($r === false) die('asdf');
