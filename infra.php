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