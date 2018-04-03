Event.handler('Controller.onshow', function () {
	$('.cart .abasket').filter("[data-crumb!=false]").attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		var prodart = a.data('producer') + ' ' + a.data('article') + ' ' + a.data('index');
		var orderid = a.data('order');
		var place = a.data('place');
		if (!place) place = 'orders';
		if (!orderid) orderid = 'my';
		Cart.toggle(place, orderid, prodart, function () {
			Cart.activate(a);	
		});	
	}).each(function(){
		var a = $(this);
		Cart.activate(a)
	});
});
Event.one('Controller.onshow', function () {
	var layer = {
		external: "-cart/rest/search/layer.json"
	};
	Event.handler('Controller.onshow', function () {
		$('.cart-search').filter("[data-search!=false]").attr("data-search","false").each( function () {
			var el = this;
			$(el).click( function () {
				layer.config = $(el).data();
				Popup.open(layer);
			});
		});
		$('.cart-clear').filter("[data-clear!=false]").attr("data-clear","false").click( function () {
			var el = this;
			var orderid = $(el).data('orderid');
			var place = $(el).data('place');
			Cart.clear(place, orderid);
		});
	});
});

Event.one('Controller.oninit', function () {
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	};
});
