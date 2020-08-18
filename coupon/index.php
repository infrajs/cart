<?php

use infrajs\ans\Ans;
use infrajs\load\Load;
use infrajs\cart\Cart;
use infrajs\path\Path;

$name = Ans::REQ('name');
$coupon = [
	'result' => 0,
	'Купон' => $name
];
if ($name) {

	$data = Load::loadJSON('-excel/get/group/Купоны/?src=' . Cart::$conf['paramsrc']);
	$coupons = [];
	if (!empty($data['data']) && sizeof($data['data'])) {
		foreach ($data['data']['data'] as $row) {
			if (empty($coupons[$row['Купон']])) {
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
			foreach ($coupon['rows'] as $k => $row) {
				if (isset($coupon['rows'][$k]['Производители'])) {
					$r = explode(',', $coupon['rows'][$k]['Производители']);
					$coupon['rows'][$k]['Производители'] = array_map(function ($v) {
						return Path::encode($v);
					}, $r);
				}
				if (isset($coupon['rows'][$k]['Группы'])) {
					$r = explode(',', $coupon['rows'][$k]['Группы']);
					$coupon['rows'][$k]['Группы'] = array_map(function ($v) {
						return Path::encode($v);
					}, $r);
				}
			}
		}
	}
}
if (!isset($coupon['Скидка'])) $coupon['Скидка'] = 0;
return Ans::ans($coupon);
