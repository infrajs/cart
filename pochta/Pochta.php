<?php
namespace infrajs\cart\pochta;


use infrajs\cart\Cart;
use infrajs\load\Load;
use infrajs\access\Access;

class Pochta {
	public static $limit = [
		'max'=> 53,
		'min'=> 26
	];
	public static function calc($type, $weight, $to) {
		//53 х 38 х 26,5
		$weight = (int) ($weight * 1000);
		$objects = [
			"pochta_simple" => 27030,
			"pochta_courier" => 28030,
			"pochta_1" => 47030
		];

		$object = $objects[$type];
		$ans = Access::cache('Pochta-calc', function ($object, $weight, $to) {
			$ans = [];
			$from = Cart::$conf['zip_from'];
			$base = 'https://tariff.pochta.ru/tariff/v1/calculate?json&object='.$object;
			$src = $base.'&from='.$from.'&to='.$to.'&weight='.$weight.'&pack=10';
			$text = @file_get_contents($src);
			if (!$text) return false;
			$data = Load::json_decode($text);
			
			if (!empty($data['error'])) return false;
			$ans['cost'] = $data['paynds'] ?? false;
			if ($ans['cost']) $ans['cost'] = $ans['cost']/100;


			$base = 'https://tariff.pochta.ru/delivery/v1/calculate?json&object='.$object;
			$src = $base.'&from='.$from.'&to='.$to.'&weight='.$weight.'&pack=10';
			$text = @file_get_contents($src);
			if (!$text) return false;
			$data = Load::json_decode($text);
			$ans['min'] = $data['delivery']['min'] ?? false;
			$ans['max'] = $data['delivery']['max'] ?? false;

			return $ans;
		},[$object, $weight, $to]);


		return $ans;
		//https://tariff.pochta.ru/tariff/v1/calculate?html&object=2000&weight=20&from=445028
	}
}