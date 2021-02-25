<?php
namespace infrajs\cart\cdek;
use infrajs\cart\Cart;
use infrajs\load\Load;
use infrajs\sequence\Seq;

class CDEK {
	public static function calc($goods, $type, $city_to_id) 
	{	
		$city_from_id = Cart::$conf['city_from_id'];
		//type: courier, pickup
		
		$get = [
			"isdek_action" => "calc",
			"shipment" => [
				"timestamp" => time(),
				"cityFromId" => $city_from_id, //Москва
				"cityToId" => $city_to_id,
				"type" => $type,
				"goods" => $goods
			]
		];
		
		$src = '-cart/cdek/service.php?'.http_build_query($get);
		$res = Load::loadJSON($src);
		$res['get'] = $get;

		if (!empty($res['result']['price'])) {
			$cost = $res['result']['price'] ?? false;
			$min = $res['result']['deliveryPeriodMin'] ?? false;
			$max = $res['result']['deliveryPeriodMax'] ?? false;
			return [
				'cost' => $cost,
				'min' => $min,
				'max' => $max
			];
		}
		return false;
	}
	public static function getGoods($basket) 
	{
		//basket[] = position_id, count
		if (empty($basket)) return [];
		$goods = [];
		foreach ($basket as $item) {
			$model = Cart::getModel($item['position_id']);
			if (!$model) continue;
			$dim = CDEK::getDim($model);
			if (!$dim) return [];
			for ($i = 0; $i < $item['count']; $i++) {
				array_push($goods, $dim);
			}
		}
		return $goods;
	}
	public static function getDim($model) {
		//$model['Габариты']//WxHxL
		return Cart::getDim($model);
	}
	
}