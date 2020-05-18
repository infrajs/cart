import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
import { Global } from '/vendor/infrajs/layer-global/Global.js'
import { Ascroll } from '/vendor/infrajs/ascroll/Ascroll.js'
import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { DOM } from '/vendor/akiyatkin/load/DOM.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Fire } from '/vendor/akiyatkin/load/Fire.js'
import { Goal } from '/vendor/akiyatkin/goal/Goal.js'

let Cart = {
	ok: (...params) => Fire.ok(Cart, ...params),
	race: (...params) => Fire.race(Cart, ...params),
	tikok: (...params) => Fire.tikok(Cart, ...params),
	wait: (...params) => Fire.wait(Cart, ...params),
	blockform: function (layer) {
		var form = $("#" + layer.div).find('form');
		form.find("input,button,textarea,select").attr("disabled", "disabled");
	},
	refresh: function (el) {
		if (el) $(el).removeClass('btn-secondary').addClass('btn-danger').find('span').addClass('spin');
		setTimeout(async () => {
			Controller.global.set(['user', 'cart']);
			console.log('asdf')
			await Session.async();
			Controller.check();
			//Cart.goTop();
			if (el) $(el).removeClass('btn-danger').addClass('btn-secondary').find('span').removeClass('spin');
		}, 100);
	},
	logout: function () {
		Session.logout();
		Session.syncNow();
		Global.check(['cart', 'user']);
	},
	unblockform: function (layer) {
		var div = $("#" + layer.div).find('form');
		div.find("input").removeAttr("disabled");
		div.find("button").removeAttr("disabled");
		div.find("textarea").removeAttr("disabled");
		div.find("select").removeAttr("disabled");
	},
	getLink: function (order, place) {
		if (place == 'admin') {
			var link = '<a onclick = "Popup.closeAll();" href="/cart/' + place + '/{id}">{id}</a>';
		} else {//place =='orders'
			if (!order.id) {
				var link = '<a onclick = "Popup.closeAll();" href="/cart/' + place + '/my/list">Оформление заказа</a>';
			} else {
				var link = '<a onclick = "Popup.closeAll();" href="/cart/' + place + '/{id}">{id}</a>';
			}
		}
		link = Template.parse([link], order);
		return link;
	},
	reach: async (name) => {
		Goal.reach(name);
	},
	act: function (place, name, orderid, cb, param) {
		if (!cb) cb = function () { };

		var rules = Load.loadJSON('-cart/rules.json');
		var act = rules.actions[name];
		var order = Cart.getGoodOrder(orderid);
		order.place = place;
		if (act.link) {
			Crumb.go(Template.parse([act.link], order));
			return cb({ result: 1 });
		}
		if (param) param = '&' + param;
		else param = '';
		var path = '-cart/actions.php?id=' + orderid + '&type=' + name + '&place=' + place + param;
		Session.syncNow();
		Cart.getJSON(path, function (ans) {
			Session.syncNow();
			Global.set(['cart', 'user']); //при заказе может произойти авторизация
			cb(ans);
		});
	},
	inaction: false,
	action: function (place, name, orderid, cb, param) {
		//place - контекст в котором идёт работа
		if (Cart.inaction) return;
		Cart.inaction = true;
		var rules = Load.loadJSON('-cart/rules.json');
		var act = rules.actions[name];
		var order = Cart.getGoodOrder(orderid);
		order.place = place;
		var layer = Controller.ids['order'];
		//if (!act.link && (!act.go || !act.go[place])) alert('Ошибка. Действие невозможно выполнить с этой странице!');
		var link = Cart.getLink(order, place);

		var justdo = function () {
			//if (!act.link) Cart.blockform(layer);
			Cart.inaction = true;
			Cart.act(place, name, orderid, function (ans) {
				Cart.inaction = false;
				var call = function () {
					var order = Cart.getGoodOrder(ans.order.id);
					if (order) {
						order.place = place;
						if (act.link) {
							if (act.result) {
								var msg = Template.parse([act.result], order);
								var link = Cart.getLink(order, place);
								//popup.alert(link+'<br>'+msg);
								Popup.alert(msg);
							}
							return;
						}
						//Cart.unblockform(layer);

						if (ans.result) {
							if (act.goal) Cart.reach(act.goal)
							if (!act.silent && act.result) {
								var msg = Template.parse([act.result], order);
								var link = Cart.getLink(order, place);
								//Popup.alert(link+'<br>'+msg);
								Popup.alert(msg);
							}
							if (act.go && act.go[place]) Crumb.go(Template.parse([act.go[place]], order));
							else Controller.check();
						} else {
							if (ans.msg) {
								var msg = Template.parse([ans.msg], order);
								var link = Cart.getLink(order, place);
								//Popup.alert(link+'<br>'+msg);
								Popup.alert(msg);
							} else {
								Popup.alert(link + '<br>Произошла обшибка, попробуйте позже!');
							}
						}
					} else {//Заявка удалена

						if (ans.result) Crumb.go(act.go[place]);
						if (ans.msg) {
							Popup.alert(ans.msg);
						}
					}
					if (cb && ans.result) cb(ans);
				}
				//if (act.noscroll) call();
				//else Cart.goTop(call);	
				call();
				if (!act.noscroll) Cart.goTop();
			}, param);
		};
		if (act.confirm) {

			var ask = Template.parse([act.confirm], order);
			ask = 'Заказ ' + link + '<br>' + ask;
			Cart.inaction = false;
			Popup.confirm(ask, justdo);

		} else {
			justdo();
		}
	},
	init: async () => {
		await DOM.wait('load')
		await CDN.on('load','jquery')
		let rules = await Load.on('json', '-cart/rules.json')

		for (let name in rules.actions) {
			$(".cart .act-" + name).not('[cartinit]').attr('cartinit', name).click(function () {
				var name = $(this).attr('cartinit');
				var place = $(this).attr('data-place');
				if (!place) place = $(this).parents('.myactions').attr('data-place');
				var param = $(this).attr('data-param');
				var id = $(this).attr('data-id');
				Cart.action(place, name, id, function () { }, param);
				return false;
			});
		}
	},
	getJSON: function (src, call) {
		$.ajax({
			dataType: "json",
			url: '/' + src,
			cache: false,
			async: true,
			success: call,
			error: function () {
				Popup.alert('Ошибка на сервере. Попробуйте позже.');
			}
		});
	},
	sync: function (place, orderid) {
		//Синхронизируем сессию клиента с реальной заявкой на сервере
		Cart.getJSON('-cart/actions.php?type=sync&id=' + orderid + '&place=' + place, function () {
			Global.set('cart');
		});
	},
	usersync: async () => {
		//Синхронизируем user с активной заявкой
		await Session.async()
		var props = ['email', 'name', 'phone'];
		Each.exec(props, function (prop) {
			var userval = Session.get(['user', prop]);
			var cartval = Session.get(['orders', 'my', prop]);
			if (userval && cartval) return;
			if (!userval && !cartval) return;
			if (!cartval) Session.set(['orders', 'my', prop], userval);
			if (!userval) Session.set(['user', prop], cartval);
		});
	},
	goTop: function (cb) {
		Ascroll.go(null, null, cb);
	},
	canI: function (id, action) {//action true совпадёт с любой строчкой
		var order = Cart.getGoodOrder(id);
		if (!order) return false;
		//if (Sequence.get(order,['rule','user','buttons',action]))return true;
		return Each.exec(Sequence.get(order, ['rule', 'user', 'actions']), function (r) {
			if (r['act'] == action) return true;
		});
	},
	getGoodOrder: function (orderid) {
		if (!orderid) orderid = '';
		//генерирует объект описывающий все цены... передаётся basket на случай если count актуальный именно в basket
		var path = '-cart/?type=order&id=' + orderid;
		Global.unload('cart', path);
		var path = '-cart?type=order&id=' + orderid;
		Global.unload('cart', path);
		//Load.unload(path);
		//Session.syncNow();
		var order = Load.loadJSON(path);//GoodOrder серверная версия
		if (!order.result) return false;
		return order.order;
	},
	toggle: function (place, orderid, prodart, cb) {
		var name = [place, orderid, 'basket', prodart];
		var order = Cart.getGoodOrder(orderid);
		var r = Sequence.get(order, ['basket', prodart, 'count']);
		if (r) {
			Cart.remove(place, orderid, prodart, cb);
		} else {
			Cart.add(place, orderid, prodart, cb);
		}
		return !r;
	},
	/*clear: function (place, orderid, cb, param) {
		var fn = function () {
			if (cb) cb();
			Global.check('cart');
		}
		Cart.action(place, 'clear', orderid, function () {
			var name = [place, orderid, 'basket'];
			Session.set(name, null, true, fn);
		});
	},*/
	remove: function (place, orderid, prodart, cb) {
		var fn = function () {
			if (cb) cb();
			Global.check('cart');
		}
		Cart.action(place, 'remove', orderid, function () {
			var name = [place, orderid, 'basket', prodart];
			Session.set(name, null, true, fn);
		}, 'prodart=' + prodart);
	},
	set: function (place, orderid, prodart, count, cb) {
		if (!orderid) orderid = 'my';
		var name = [place, orderid, 'basket', prodart, 'count'];
		count = Number(count);
		if (!count) count = null;
		Cart.reach('basket');
		Session.set(name, count, true, cb);
	},
	add: function (place, orderid, prodart, cb) {
		var fn = function () {
			if (cb) cb();
			Global.check('cart');
		}
		if (!orderid) orderid = 'my';

		var name = [place, orderid, 'basket', prodart];

		Cart.reach('basket');
		Session.set(name, { count: 1 }, true, fn);
	},
	lang: function (str) {
		if (typeof (str) == 'undefined') return Lang.name('cart');
		return Lang.str('cart', str);
	}
	/*,
	initPrice: function (div) {
		div.find('.cat_item').each( function () {
			var cart = $(this).find('.basket_img');

			var id = cart.data('producer')+' '+cart.data('article');
			if (Session.get('order.my.basket.'+id)) {
				$(this).find('.posbasket').show();
				cart.addClass('basket_img_sel');
				cart.attr('title','Удалить из корзины');
			} else {
				cart.attr('title','Добавить в корзину');
			}
		});
		var callback = function () {
			Global.set('cart');
			Controller.check();
		}
		div.find('.cat_item .basket_img').click( function () {
			var cart=$(this);
			var id=cart.data('producer')+' '+cart.data('article');
			var name = 'order.my.basket.'+id;
			var r = Session.get(name);
			if (r) {
				$(this).removeClass('basket_img_over');
				$(this).removeClass('basket_img_sel');
				$(this).parents('.cat_item').find('.posbasket').hide();
				Session.set(name,null,true,callback);
				cart.attr('title','Добавить в корзину');
			} else {
				
				$(this).addClass('basket_img_sel');
				$(this).parents('.cat_item').find('.posbasket').show();
				Session.set(name,{ count:1 },true,callback);
				cart.attr('title','Удалить из корзины');

			}
		}).hover( function () {
			$(this).addClass('basket_img_over');
		}, function () {
			$(this).removeClass('basket_img_over');
		});
	}*/
	,
	activate: function (a) {
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';

		var prodart = a.data('producer') + ' ' + a.data('article');
		var id = a.data('id');
		if (id) prodart += ' ' + a.data('id');

		var name = ['orders', orderid, 'basket', prodart];
		var r = Session.get(name);
		if (r || orderid != 'my') {
			a.parent().find('.bbasket').stop().slideDown();
			a.parent().find('.basketdescr').stop().slideUp();

			a.addClass('selected');
			a.attr('title', 'Удалить из корзины');
		} else {
			a.parent().find('.bbasket').stop().slideUp();
			a.parent().find('.basketdescr').stop().slideDown();
			a.removeClass('selected');
			a.attr('title', 'Добавить в корзину');
		}
	},
	/*activate: function (a) {
		var orderid = a.data('order');
		if (!orderid) orderid = 'my';

		var prodart = a.data('producer')+' '+a.data('article');
		var name = ['orders', orderid, 'basket', prodart];
		var r = Session.get(name);
		if (r || orderid != 'my') {
			a.addClass('selected');
			a.attr("data-crumb","true");
			a.attr('title','Перейти в корзину');
		} else {
			a.removeClass('selected');
			a.attr('title','Добавить в корзину');
		}
	}*/
}
window.Cart = Cart
export { Cart }
/*
Event.handler('Session.onsync', function () {
	$(document).find('.cat_item').each( function () {
		var cart = $(this).find('.basket_img');
		var id = cart.data('producer') + ' ' + cart.data('article');
		if (Session.get('order.my.basket.' + id)) {
			$(this).find('.posbasket').show();
			cart.addClass('basket_img_sel');
			cart.attr('title','Удалить из корзины');
		} else {
			cart.attr('title','Добавить в корзину');
		}
	});
});
*/