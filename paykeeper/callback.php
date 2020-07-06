<?php

use infrajs\ans\Ans;
use infrajs\cart\paykeeper\Paykeeper;


$ans = Paykeeper::callback($_REQUEST);

if ($ans['result']) echo $ans['msg'];
else return Ans::ans($ans);
