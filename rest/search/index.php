<?php
use infrajs\rest\Rest;
use infrajs\excel\Xlsx;
use infrajs\ans\Ans;
use infrajs\path\Path;
use infrajs\load\Load;

return Rest::get( function () {
	$ans = array();
	header('Content-Type: application/javascript; charset=utf-8');
	return Ans::err($ans,'Не указана строка поиска');
}, function ($search) {
	$search = Path::encode($search);
	$data = Load::loadJSON('-showcase/api/search?val='.$search);
	$ans = array();
	$ans['list'] = $data['list'];
	header('Content-Type: application/javascript; charset=utf-8');
	return Ans::ret($ans);
});