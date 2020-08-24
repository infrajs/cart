<?php

use infrajs\event\Event;
use infrajs\cart\Cart;
use infrajs\lang\Lang;
use infrajs\template\Template;

Event::one('Controller.oninit', function () {
	Template::$scope['Cart'] = array();
	Template::$scope['Cart']['lang'] = function ($stren = null) {
		$lang = Lang::name('cart');
		if (is_null($stren)) return $lang;
		return Cart::lang($lang, $stren);
	};
});
Event::handler('Cart.coupon', function (&$pos){
	if (isset($pos['Наличие']) && in_array($pos['Наличие'],['Акция','Распродажа'])) return false;
	//$pos['coupon'], можно изменить цену $pos['Цена']
	return true;
});
