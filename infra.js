import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
import { Event } from '/vendor/infrajs/event/Event.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Cart } from '/vendor/infrajs/cart/Cart.js'
import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { DOM } from '/vendor/akiyatkin/load/DOM.js'
import { User } from '/vendor/infrajs/user/User.js'
import { Config } from '/vendor/infrajs/config/Config.js'
import { Global } from '/vendor/infrajs/layer-global/Global.js'


if (~Config.get('cart').transports.indexOf('cdek_pvz')) {
	(async () => {
		const { CDEK } = await import('/vendor/infrajs/cart/cdek/CDEK.js')
		CDEK.done('change', async wat => {
			const order_id = wat.order.order_id
			const city_id = wat.city
			const transport = wat.id == 'courier' ? 'cdek_courier' : 'cdek_pvz'
			const place = "orders"
			if (!wat.PVZ) return;
			const pvz = transport == 'cdek_pvz'? wat.id + ' ' + wat.PVZ.Address : ''
			Cart.post('setcdek', { order_id, place }, { city_id, transport, pvz })
		})
	})()
}

DOM.once('load', async () => {
	await CDN.fire('load','jquery')
})
DOM.once('check', async () => {
	let Template = (await import('/vendor/infrajs/template/Template.js')).Template
	Template.scope['Cart'] = {};
	Template.scope['Cart']['lang'] = function (str) {
		return Cart.lang(str);
	}

	// const token = User.token()
	// const stat = await Cart.posts('mystat', { token })
	// Template.scope['Cart']['getCityId'] = (order_id) => {	
	// 	return stat.city_id
	// }
})
//Event.handler('Controller.onshow', async () => {
// DOM.done('load', () => {
// 	$('.abasket').filter("[data-crumb!=false]").attr("data-crumb", "false").click(function (event) {
// 		event.preventDefault();
// 		var a = $(this);

// 		var prodart = a.data('producer') + ' ' + a.data('article');
// 		var id = a.data('id');
// 		if (id) prodart += ' ' + a.data('id');
// 		var orderid = a.data('order');
// 		var place = a.data('place');
// 		if (!place) place = 'orders';
// 		if (!orderid) orderid = 'my';
// 		Cart.toggle(place, orderid, prodart, function () {
// 			Cart.activate(a);
// 		});
// 	}).each(function () {
// 		var a = $(this);
// 		Cart.activate(a)
// 	});
// 	var conf = Config.get('cart');
// 	var activate = async function (a) {
// 		Session = (await import('/vendor/infrajs/session/Session.js')).Session
// 		var orderid = a.data('order');
// 		if (!orderid) orderid = 'my';

// 		var prodart = a.data('producer') + ' ' + a.data('article');
// 		var id = a.data('id');
// 		if (id) prodart += ' ' + a.data('id');

// 		var name = ['orders', orderid, 'basket', prodart, 'count'];
// 		var r = Session.get(name, 0);

// 		if (r) a.parents('.cart-basket').find('input').val(r);

// 		var c = a.parents('.cart-basket');

// 		//в tpl дефолтный класс надо чтобы был clsadd


// 		/*var clsadd = 'btn-info';
// 		var clsready = 'btn-warning';
// 		var textadd = 'Добавить в корзину';
// 		var textready = 'Оформить заказ';*/
// 		if (r || orderid != 'my') {
// 			let text = a.find('.text');
// 			if (!text.length) text = a;
// 			text.text(conf.textready);
// 			a.addClass('active');
// 			//c.addClass('has-warning');c.removeClass('has-success');
// 			a.addClass(conf.clsready);
// 			a.removeClass(conf.clsadd);
// 			c.find('.bbasket').slideDown();
// 		} else {
// 			let text = a.find('.text');
// 			if (!text.length) text = a;
// 			text.text(conf.textadd);
// 			c.find('.bbasket').slideUp();
// 			a.removeClass('active');
// 			//c.addClass('has-success');c.removeClass('has-warning');
// 			a.addClass(conf.clsadd);
// 			a.removeClass(conf.clsready);
// 		}
// 	}
// 	$('.cart-basket').filter("[data-basket!=true]").attr("data-basket", "true").each(function () {
// 		var a = $(this).find('.add');

// 		var c = $(this);
// 		$(this).find('input').click(function () {
// 			let text = a.find('.text');
// 			if (!text.length) text = a;
// 			text.text(conf.textadd);
// 			a.removeClass('active');
// 			//c.find('.bbasket').slideUp();
// 			//c.addClass('has-success');c.removeClass('has-warning');
// 			a.addClass(conf.clsadd); a.removeClass(conf.clsready);
// 		}).change(function () {
// 			let text = a.find('.text');
// 			if (!text.length) text = a;
// 			text.text(conf.textadd);
// 			a.removeClass('active');
// 			//c.find('.bbasket').slideUp();
// 			//c.addClass('has-success');c.removeClass('has-warning');
// 			a.addClass(conf.clsadd); a.removeClass(conf.clsready);
// 		});
// 		a.click( (event) => {
// 			event.preventDefault();
// 			var count = a.parents('.cart-basket').find('input').val();
// 			var prodart = a.data('producer') + ' ' + a.data('article');
// 			var id = a.data('id');
// 			if (id) prodart += ' ' + a.data('id');

// 			var orderid = a.data('order');
// 			var place = a.data('place');
// 			if (!place) place = 'orders';
// 			if (!orderid) orderid = 'my';
// 			if (a.hasClass('active')) {
// 				Crumb.go('/cart/orders/my');
// 				return;
// 			}
// 			Cart.set(place, orderid, prodart, count, async () => {
// 				let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
// 				Global.check('cart')
// 				activate(a)
// 			})
// 		}).each(function () {
// 			var a = $(this);
// 			activate(a);
// 		});
// 	});
// });


//Event.one('Controller.onshow', async () => {
// let layer = {
// 	external: "-cart/rest/search/layer.json"
// };
// DOM.done('load', () => {
// 	$('.cart-search').filter("[data-search!=false]").attr("data-search", "false").each(function () {
// 		var el = this;
// 		$(el).click(function () {
// 			layer.config = $(el).data();
// 			console.log(layer.config);
// 			Popup.open(layer);
// 		});
// 	});
// });



