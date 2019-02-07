Event.handler('Controller.onshow', function () {
	$('.cart .abasket').filter("[data-crumb!=false]").attr("data-crumb","false").click( function (event) {
		event.preventDefault();
		var a = $(this);
		
		var prodart = a.data('producer') + ' ' + a.data('article');
		var id = a.data('id');
		if (id) prodart += ' ' + a.data('id');
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
	var activate = function(a){
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';
		
		var prodart = a.data('producer') + ' ' + a.data('article');
		var id = a.data('id');
		if (id) prodart += ' ' + a.data('id');

		var name = ['orders', orderid, 'basket', prodart, 'count'];
		var r = Session.get(name, 0);
		
		if (r) a.parents('.cart-basket').find('input').val(r);

		var c = a.parents('.cart-basket');
		if (r || orderid != 'my') {
			a.text('Оформить');
			a.addClass('active');
			//c.addClass('has-warning');c.removeClass('has-success');
			a.addClass('btn-danger');a.removeClass('btn-success');
		} else {
			a.text('В корзину');
			a.removeClass('active');
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass('btn-success');a.removeClass('btn-danger');
		}
	}
	$('.cart-basket').filter("[data-basket!=true]").attr("data-basket","true").each(function(){
		var a = $(this).find('.add');
		var c = $(this);
		$(this).find('input').click(function(){
			a.text('В корзину');
			a.removeClass('active');
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass('btn-success');a.removeClass('btn-danger');
		}).change(function(){
			a.text('В корзину');
			a.removeClass('active');
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass('btn-success');a.removeClass('btn-danger');
		});
		$(this).find('.add').click( function (event) {
			event.preventDefault();
			var a = $(this);
			var count = a.parents('.cart-basket').find('input').val();
			
			var prodart = a.data('producer') + ' ' + a.data('article');
			var id = a.data('id');
			if (id) prodart += ' ' + a.data('id');
			
			var orderid = a.data('order');
			var place = a.data('place');
			if (!place) place = 'orders';
			if (!orderid) orderid = 'my';
			if ($(this).hasClass('active')) {
				Crumb.go('/cart/orders/my');
				return;
			}
			Cart.set(place, orderid, prodart, count, function () {
				Global.check('cart');
				activate(a);
			});
		}).each(function(){
			var a = $(this);
			activate(a);
		});
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
