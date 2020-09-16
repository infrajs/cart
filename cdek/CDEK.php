<?php
namespace infrajs\cart\cdek;
use infrajs\cart\Cart;
use infrajs\load\Load;
use infrajs\sequence\Seq;

class CDEK {
	public static $conf;
	public static function calc($basket, $type, $city_from_id, $city_to_id) 
	{	
		//basket[] = position_id, count
		$conf = CDEK::$conf;
		//type: courier, pickup
		$get = [
			"isdek_action" => "calc",
			"shipment" => [
				"timestamp" => mktime(),
				"cityFromId" => $city_from_id, //Москва
				"cityToId" => $city_to_id,
				"type" => $type,
				//"type" => "pickup",
				//"type" => "courier",
				"goods" => CDEK::getGoods($basket)
			]
		];
		
		$src = '-cart/cdek/service.php?'.http_build_query($get);
		$json = Load::loadJSON($src);
		$json['get'] = $get;
		
		return $json;
	}
	public static function getGoods($basket) 
	{
		if (empty($basket)) return [];
		$goods = [];
		foreach ($basket as $item) {
			$dim = CDEK::getDim($item['position_id']);
			if (!$dim) continue;
			for ($i = 0; $i < $item['count']; $i++) {
				array_push($goods, $dim);
			}
		}
		return $goods;
	}
	public static function getDim($position_id) {
		$model = Cart::getModel($position_id);
		if (!$model) return false;
		//$model['Габариты']//WxHxL
		$model += $model['more'];
		$dim = $model['Упаковка, см'] ?? $model['Габариты, см'] ?? $model['Габариты'] ?? '';
		$d = preg_split('/[хx]/i', $dim, 3, PREG_SPLIT_NO_EMPTY);
		$d[0] = $d[0] ?? $model['Длина, см'] ?? $model['Длина (см)'] ?? 6;
		$d[1] = $d[1] ?? $model['Ширина, см'] ?? $model['Ширина (см)'] ?? 15;
		$d[2] = $d[2] ?? $model['Высота, см'] ?? $model['Высота (см)'] ?? 12;

		$weight = $model['Вес, кг'] ?? 0.5;

		
		
		$weight = (float) $weight;

		return [ 
			"width" => $d[0], 
			"height" => $d[1], 
			"length" => $d[2], 
			"weight" => $weight
		];
	}
	
}