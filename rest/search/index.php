<?php
use infrajs\rest\Rest;
use infrajs\catalog\Catalog;
use infrajs\excel\Xlsx;
use infrajs\ans\Ans;
use infrajs\path\Path;

return Rest::get( function () {
	$ans = array();
	header('Content-Type: application/javascript; charset=utf-8');
	return Ans::err($ans,'Не указана строка поиска');
}, function ($search) {
	$data = Catalog::init();
	$search = Path::encode($search);
	$v = preg_split("/[\s\-]+/", mb_strtolower($search));
	foreach($v as $i => $s) {
		$v[$i] = preg_replace("/ы$/","",$s);
	}
	$list = array();

	Xlsx::runPoss( $data, function &($pos) use ($v, &$list) {
		
		$items = Xlsx::getItemsFromPos($pos);

		foreach ($items as $item) {
			$r = Catalog::searchTestItem($item, $v);
			if (!$r) continue;
			$list[] = Catalog::getPos($item);	
		}
		if (sizeof($list) > 20) {
			$r = false;
			return $r;
		}
		$r = null;
		return $r;
	});
	$ans = array();
	$ans['list'] = $list;
	header('Content-Type: application/javascript; charset=utf-8');
	return Ans::ret($ans);
});