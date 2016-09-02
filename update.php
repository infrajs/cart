<?php
use infrajs\once\Once;
use infrajs\path\Path;
use infrajs\cart\Cart;


$src = Cart::getPath();
Path::mkdir($src);