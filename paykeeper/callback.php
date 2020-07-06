<?php

use infrajs\ans\Ans;
use infrajs\cart\paykeeper\Paykeeper;
use infrajs\nostore\Nostore;

Nostore::on();

$ans = Paykeeper::callback($_REQUEST);

if ($ans['result']) echo $ans['msg'];
else return Ans::ans($ans);
