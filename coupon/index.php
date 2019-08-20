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
	if (!empty($data['data']) && sizeof($data['data'])) {
		foreach ($data['data']['data'] as $row) {
			if(empty($coupons[$row['Купон']])) {
				$coupons[$row['Купон']] = $row;	
				$coupons[$row['Купон']]['rows'] = [];
				$coupons[$row['Купон']]['rows'][] = $row;
			} else {
				$coupons[$row['Купон']]['rows'][] = $row;
				if ($coupons[$row['Купон']]["Скидка"] < $row["Скидка"]) {
					$coupons[$row['Купон']]["Скидка"] = $row["Скидка"];
				}
			}
			
		}
		if (isset($coupons[$name])) {
			$coupon = $coupons[$name];
			$coupon['result'] = 1;
		}
	}
}
if(!isset($coupon['Скидка'])) $coupon['Скидка'] = 0;
return Ans::ans($coupon);