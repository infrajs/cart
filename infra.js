Event.handler('Controller.onshow', function () {
	var activate = function (a, prodart) {
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';
		var name = ['orders', orderid, 'basket', prodart];
		var r = Session.get(name);
		if (r || orderid != 'my') {
			a.next().stop().slideDown();
			a.addClass('selected');
			a.attr('title','Удалить из корзины');
		} else {
			a.next().stop().slideUp();	
			a.removeClass('selected');
			a.attr('title','Добавить в корзину');
		}
	}
	$('.cart .abasket').filter("[data-crumb!=false]").attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		var prodart = a.data('producer')+' '+a.data('article');
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';
		Cart.toggle(orderid, prodart, function () {
			activate(a, prodart);	
		});	
	}).each(function(){
		var a = $(this);
		var prodart = a.data('producer')+' '+a.data('article');
		activate(a, prodart)
	});
});


Event.one('Controller.oninit', function () {
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	};
});
