import { Crumb } from '/vendor/infrajs/controller/src/Crumb.js'
import { Ascroll } from '/vendor/infrajs/ascroll/Ascroll.js'
import { Popup } from '/vendor/infrajs/popup/Popup.js'
import { CDN } from '/vendor/akiyatkin/load/CDN.js'
import { Fire } from '/vendor/akiyatkin/load/Fire.js'
import { Goal } from '/vendor/akiyatkin/goal/Goal.js'
import { Load } from '/vendor/akiyatkin/load/Load.js'
import { Session } from '/vendor/infrajs/session/Session.js'
let Template, Global, Autosave

let Cart = {
	...Fire, 
	blockform: function (layer) {
		var form = $("#" + layer.div).find('form');
		form.find("input,button,textarea,select").attr("disabled", "disabled");
	},
	refresh: function (el) {
		if (el) $(el).removeClass('btn-secondary').addClass('btn-danger').find('span').addClass('spin');
		setTimeout(async () => {
			let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
			Global.set(['user', 'cart']);
			await Session.async();
			DOM.emit('check')
			//Cart.goTop();
			if (el) $(el).removeClass('btn-danger').addClass('btn-secondary').find('span').removeClass('spin');
		}, 100);
	},
	logout: async () => {
		Session.logout();
		await Session.async();
		let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
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
	act: async (place, name, orderid, cb, param) => {
		Template = (await import('/vendor/infrajs/template/Template.js')).Template
		if (!cb) cb = function () { };
		let rules = await Load.on('json', '-cart/rules.json')
		var act = rules.actions[name];
		var order = await Cart.getGoodOrder(orderid);
		order.place = place;
		if (act.link) {
			Crumb.go(Template.parse([act.link], order));
			return cb({ result: 1 });
		}
		if (param) param = '&' + param;
		else param = '';
		var path = '/-cart/actions.php?id=' + orderid + '&type=' + name + '&place=' + place + param;
		await Session.async();
		let ans = await fetch(path).then(res => res.json())
		await Session.async();
		let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
		Global.set(['cart', 'user']); //при заказе может произойти авторизация
		await cb(ans);
	},
	inaction: false,
	action: async (place, name, orderid, cb, param) => {
		//place - контекст в котором идёт работа
		Template = (await import('/vendor/infrajs/template/Template.js')).Template
		if (Cart.inaction) return;
		Cart.inaction = true;

		let div = document.getElementsByClassName('cart')[0]
		if (div) {
			await CDN.fire('load','jquery')
			Autosave = (await import('/vendor/akiyatkin/form/Autosave.js')).Autosave
			var inps = Autosave.getInps(div);
			for (let inp of inps) {
				Autosave.fireEvent(inp, 'change');
			}
		}

		
		let rules = await Load.on('json', '-cart/rules.json')
		var act = rules.actions[name];
		var order = await Cart.getGoodOrder(orderid);
		order.place = place;
		//var layer = Controller.names['order'];
		//if (!act.link && (!act.go || !act.go[place])) alert('Ошибка. Действие невозможно выполнить с этой странице!');
		var link = Cart.getLink(order, place);

		var justdo = async () => {
			//if (!act.link) Cart.blockform(layer);
			Cart.inaction = true;
			await Cart.act(place, name, orderid, async (ans) => {
				Cart.inaction = false;
				var call = async () => {
					var order = await Cart.getGoodOrder(ans.order.id);
					if (order) {
						order.place = place;
						if (act.link) {
							if (act.result) {
								var msg = Template.parse([act.result], order);
								var link = Cart.getLink(order, place);
								//popup.alert(link+'<br>'+msg);
								await Popup.alert(msg);
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
								await Popup.alert(msg);
							}
							if (act.gohistory && act.gohistory[place]) {
								Crumb.go(Template.parse([act.gohistory[place]], order));								
							}

							if (act.go && act.go[place]) {
								Crumb.go(Template.parse([act.go[place]], order));
							} else {
								DOM.emit('check');
							}
						} else {
							
							if (ans.msg) {
								var msg = Template.parse([ans.msg], order);
								var link = Cart.getLink(order, place);
								//Popup.alert(link+'<br>'+msg);
								await Popup.alert(msg);
							} else {
								await Popup.alert(link + '<br>Произошла обшибка, попробуйте позже!');
							}
						}
					} else {//Заявка удалена

						if (ans.result) Crumb.go(act.go[place]);
						if (ans.msg) {
							await Popup.alert(ans.msg);
						}
					}
					if (cb && ans.result) await cb(ans);
				}
				//if (act.noscroll) call();
				//else Cart.goTop(call);	
				await call();
				if (!act.noscroll) Cart.goTop();
			}, param);
		};
		if (act.confirm) {

			var ask = Template.parse([act.confirm], order);
			ask = 'Заказ ' + link + '<br>' + ask;
			Cart.inaction = false;
			Popup.confirm(ask, justdo);

		} else {
			await justdo();
		}
	},
	init: async () => {
		await CDN.fire('load','jquery')
		await CDN.fire('load','bootstrap')
		let rules = await Load.fire('json', '-cart/rules.json')

		for (let name in rules.actions) {
			
			$(".cart .act-" + name).not('[cartinit]').attr('cartinit', name).click(async function () {
				var place = $(this).attr('data-place');
				if (!place) place = $(this).parents('.myactions').attr('data-place');
				var param = $(this).attr('data-param');
				var id = $(this).attr('data-id');
				await Cart.action(place, name, id, function () { }, param);
				return false;
			});
		}
	},
	// sync: async (place, orderid) => {
	// 	//Синхронизируем сессию клиента с реальной заявкой на сервере
	// 	await fetch('/-cart/actions.php?type=sync&id=' + orderid + '&place=' + place)
	// 	Global.set('cart');
	// },
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
	// canI: async (id, action) => {//action true совпадёт с любой строчкой
	// 	var order = await Cart.getGoodOrder(id);
	// 	if (!order) return false;
	// 	//if (Sequence.get(order,['rule','user','buttons',action]))return true;
	// 	return Each.exec(Sequence.get(order, ['rule', 'user', 'actions']), function (r) {
	// 		if (r['act'] == action) return true;
	// 	});
	// },
	getGoodOrder: async (orderid) => {
		if (!orderid) orderid = '';
		//генерирует объект описывающий все цены... передаётся basket на случай если count актуальный именно в basket
		var path = '-cart/?type=order&id=' + orderid;
		Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
		Global.unload('cart', path);
		//var path = '-cart?type=order&id=' + orderid;
		//Global.unload('cart', path);

		let order = await Load.fire('json', path)
		//var order = Load.loadJSON(path);//GoodOrder серверная версия
		if (!order.result) return false;
		return order.order;
	},
	toggle: async (place, orderid, prodart, cb) => {
		var name = [place, orderid, 'basket', prodart];
		var order = await Cart.getGoodOrder(orderid);
		var r = Sequence.get(order, ['basket', prodart, 'count']);
		if (r) {
			Cart.remove(place, orderid, prodart, cb);
		} else {
			Cart.add(place, orderid, prodart, cb);
		}
		return !r;
	},
	remove: async (place, orderid, prodart, cb) => {
		let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
		var fn = function () {
			if (cb) cb();
			Global.check('cart');
		}
		await Cart.action(place, 'remove', orderid, function () {
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
		var fn = async () => {
			if (cb) cb();
			let Global = (await import('/vendor/infrajs/layer-global/Global.js')).Global
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
}





Cart.initChoiceBtn = async div => {
	await Session.async()
	Autosave = (await import('/vendor/akiyatkin/form/Autosave.js')).Autosave
	let name = div.dataset.name
	let autosavename = div.dataset.autosave
	let editable = div.dataset.editable
	let value = await Autosave.get(autosavename, name+'.choice', div.dataset.value)
	let cls = cls => div.getElementsByClassName(cls)
	let checkinfo = (value) => {

		for (let info of cls('iteminfo')) {

			if (info.dataset.value == value) {
				info.style.display = 'block'
				info.style.opacity = 1
			} else {
				info.style.display = 'none'
				info.style.opacity = 0
			}
		}
	}
	var first = false;
	for (let item of cls('item')) {
		
		item.addEventListener('click', async () => {
			if (first && !editable) return
			first = true
			for (let active of cls('active')) {
				if (active == item) continue
				active.classList.remove('active')
			}

			let value = item.dataset.value
			Cart.elan('choice' + name, value)
			
			if (item.classList.contains('active')) {
				value = false;
				item.classList.remove('active');
				Autosave.set(autosavename, name + '.choice');
			} else {
				item.classList.add('active');
				Autosave.set(autosavename, name + '.choice', value);
			}
			checkinfo(value)
			
			
			Autosave.loadAll(div, autosavename);
		})
		if (item.dataset.value == value) {

			item.dispatchEvent(new Event('click'))
		}
	}
	
	for (let more of cls('morelink')) {
		more.addEventListener('click', async event => {
			var item = more.closest('.item')
			var value = item.dataset.value
			if (item.classList.contains('active')) event.stopPropagation();
			checkinfo(value)
		})
	}
}





window.Cart = Cart
export { Cart }