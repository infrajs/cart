<?php
use akiyatkin\boo\Cache;
use infrajs\ans\Ans;
use infrajs\cart\cdek\ISDEKservice;



@header('Access-Control-Allow-Origin: *');



ISDEKservice::setTarifPriority(
	array(233, 137, 139, 16, 18, 11, 1, 3, 61, 60, 59, 58, 57, 83),
    array(234, 136, 138, 62, 15, 17, 10, 12, 5, 63)
);


$action = $_REQUEST['isdek_action'];

if (method_exists('infrajs\cart\cdek\ISDEKservice', $action)) {
	return ISDEKservice::$action($_REQUEST);
}