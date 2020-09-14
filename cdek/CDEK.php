<?php
namespace infrajs\cart\cdek;
use infrajs\cart\Cart;
use infrajs\load\Load;
use infrajs\sequence\Seq;

class CDEK {
	public static $conf;
	public static function calc($gorder, $type, $city_from_id, $city_to_id) 
	{	
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
				"goods" => CDEK::getGoods($gorder)
			]
		];
		
		$src = '-cart/cdek/service.php?'.http_build_query($get);
		$json = Load::loadJSON($src);
		$json['get'] = $get;
		
		return $json;
	}
	public static function getDim($pos) {
		//$item['Габариты']//WxHxL
		$item = $pos['model'];
		$dim = !empty($item['Упаковка, см']) ? $item['Упаковка, см']: '';
		$weight = !empty($item['Вес, кг']) ? $item['Вес, кг']: '0.4';

		$d = preg_split('/[хx]/i', $dim, 3, PREG_SPLIT_NO_EMPTY);
		if (empty($d[0])) $d[0] = 6;
		if (empty($d[1])) $d[1] = 15;
		if (empty($d[2])) $d[2] = 12;
		$weight = (float) $weight;

		return [ 
			"width" => $d[0], 
			"height" => $d[1], 
			"length" => $d[2], 
			"weight" => $weight
		];
	}
	public static function getGoods($gorder) 
	{
		if (empty($gorder['basket'])) return [];
		$goods = [];
		foreach ($gorder['basket'] as $item) {
			$dim = CDEK::getDim($item);
			for ($i = 0; $i < $item['count']; $i++) {
				array_push($goods, $dim);
			}
		}
		return $goods;
	}
}