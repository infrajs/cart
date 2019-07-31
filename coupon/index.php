<?php
use infrajs\ans\Ans;
use infrajs\load\Load;


$name = Ans::REQ('name');
$coupon = [
	'result'=>0,
	'Купон'=>$name
];
if ($name) {
	$data = Load::loadJSON('-excel/get/group/Купоны/?src=~pages/Параметры.xlsx');
	
	$coupons = [];
	if (sizeof($data['data'])) {
		foreach ($data['data']['data'] as $row) {
			$coupons[$row['Купон']] = $row;
		}
		if (isset($coupons[$name])) {
			$coupon = $coupons[$name];
			$coupon['result'] = 1;
		}
	}
}
if(!isset($coupon['Скидка'])) $coupon['Скидка'] = 0;
return Ans::ans($coupon);