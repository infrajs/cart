import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
import { Event } from '/vendor/infrajs/event/Event.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Cart } from '/vendor/infrajs/cart/Cart.js'
import { Global } from '/vendor/infrajs/layer-global/Global.js'

Event.handler('Controller.onshow', async () => {
	await CDN.on('load','jquery')

	$('.abasket').filter("[data-crumb!=false]").attr("data-crumb", "false").click(function (event) {
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
	}).each(function () {
		var a = $(this);
		Cart.activate(a)
	});
	var conf = Config.get('cart');
	var activate = function (a) {
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';

		var prodart = a.data('producer') + ' ' + a.data('article');
		var id = a.data('id');
		if (id) prodart += ' ' + a.data('id');

		var name = ['orders', orderid, 'basket', prodart, 'count'];
		var r = Session.get(name, 0);

		if (r) a.parents('.cart-basket').find('input').val(r);

		var c = a.parents('.cart-basket');

		//в tpl дефолтный класс надо чтобы был clsadd


		/*var clsadd = 'btn-info';
		var clsready = 'btn-warning';
		var textadd = 'Добавить в корзину';
		var textready = 'Оформить заказ';*/
		if (r || orderid != 'my') {
			let text = a.find('.text');
			if (!text.length) text = a;
			text.text(conf.textready);
			a.addClass('active');
			//c.addClass('has-warning');c.removeClass('has-success');
			a.addClass(conf.clsready);
			a.removeClass(conf.clsadd);
			c.find('.bbasket').slideDown();
		} else {
			let text = a.find('.text');
			if (!text.length) text = a;
			text.text(conf.textadd);
			c.find('.bbasket').slideUp();
			a.removeClass('active');
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass(conf.clsadd);
			a.removeClass(conf.clsready);
		}
	}
	$('.cart-basket').filter("[data-basket!=true]").attr("data-basket", "true").each(function () {
		var a = $(this).find('.add');

		var c = $(this);
		$(this).find('input').click(function () {
			let text = a.find('.text');
			if (!text.length) text = a;
			text.text(conf.textadd);
			a.removeClass('active');
			//c.find('.bbasket').slideUp();
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass(conf.clsadd); a.removeClass(conf.clsready);
		}).change(function () {
			let text = a.find('.text');
			if (!text.length) text = a;
			text.text(conf.textadd);
			a.removeClass('active');
			//c.find('.bbasket').slideUp();
			//c.addClass('has-success');c.removeClass('has-warning');
			a.addClass(conf.clsadd); a.removeClass(conf.clsready);
		});
		a.click( (event) => {
			event.preventDefault();
			var count = a.parents('.cart-basket').find('input').val();
			var prodart = a.data('producer') + ' ' + a.data('article');
			var id = a.data('id');
			if (id) prodart += ' ' + a.data('id');

			var orderid = a.data('order');
			var place = a.data('place');
			if (!place) place = 'orders';
			if (!orderid) orderid = 'my';
			if (a.hasClass('active')) {
				Crumb.go('/cart/orders/my');
				return;
			}
			Cart.set(place, orderid, prodart, count, function () {
				Global.check('cart');
				activate(a);
			});
		}).each(function () {
			var a = $(this);
			activate(a);
		});
	});
});
Event.one('Controller.onshow', async () => {
	var layer = {
		external: "-cart/rest/search/layer.json"
	};
	await CDN.on('load','jquery')
	Event.handler('Controller.onshow', function () {
		$('.cart-search').filter("[data-search!=false]").attr("data-search", "false").each(function () {
			var el = this;
			$(el).click(function () {
				layer.config = $(el).data();
				console.log(layer.config);
				Popup.open(layer);
			});
		});
		/*$('.cart-clear').filter("[data-clear!=false]").attr("data-clear","false").click( function () {
			var el = this;
			var orderid = $(el).data('orderid');
			var place = $(el).data('place');
			Cart.clear(place, orderid);
		});*/
	});
});

Event.one('Controller.oninit', function () {
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	};
});
