<?php
use infrajs\once\Once;
use infrajs\path\Path;
use infrajs\cart\Cart;


Path::mkdir('~auto/');
$src = Cart::getPath();
Path::mkdir($src);
Path::mkdir($src.'deleted/');
