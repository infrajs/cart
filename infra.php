<?php

use infrajs\event\Event;
use infrajs\cart\Cart;
use infrajs\template\Template;

Event::one('Controller.oninit', function () {
	Template::$scope['Cart'] = array();
	Template::$scope['Cart']['lang'] = function ($str) {
		return Cart::lang($str);
	};
});
Event::handler('Cart.coupon', function (&$pos){
	if (in_array($pos['Наличие на складе'],['Акция','Распродажа'])) return false;
	//$pos['coupon'], можно изменить цену $pos['Цена']
	return true;
});
