Event.handler('Controller.onshow', function () {
	$('.cart .abasket').filter("[data-crumb!=false]").attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		var prodart = a.data('producer')+' '+a.data('article');
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


Event.one('Controller.oninit', function () {
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	};
});
