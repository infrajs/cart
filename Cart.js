
window.Cart = {
	blockform: function (layer) {
		var form=$("#"+layer.div).find('form');
		form.find("input,button,textarea,select").attr("disabled","disabled");
	},
	refresh: function (el) {
		if (el) $(el).removeClass('btn-default').addClass('btn-danger').find('span').addClass('spin');
		setTimeout( function () {
			Controller.global.set(['order','cat_basket','sign']);
			Session.syncNow();
			Controller.check();
			Cart.goTop();
			if (el) $(el).removeClass('btn-danger').addClass('btn-default').find('span').removeClass('spin');
		},100);
	},
	unblockform: function (layer) {
		var div=$("#"+layer.div).find('form');
		div.find("input").removeAttr("disabled");
		div.find("button").removeAttr("disabled");
		div.find("textarea").removeAttr("disabled");
		div.find("select").removeAttr("disabled");
	},
	getLink: function (order,place) {
		if (place =='admin') {
			var link = '<a onclick = "Cart.goTop()" href="/cart/'+place+'/{id}">{id}</a>';
		} else {//place =='orders'
			if (!order.id) {
				var link = '<a onclick = "Cart.goTop()" href="/cart/'+place+'/my">Активная заявка</a>';
			} else {
				var link = '<a onclick = "Cart.goTop()" href="/cart/'+place+'/{id}">{id}</a>';
			}			
		}
		link = Template.parse([link],order);
		return link;
	},
	act: function (place, name, orderid, cb, param) {
		if (!cb) cb = function () {};
		var rules = Load.loadJSON('-cart/rules.json');
		var act = rules.actions[name];
		var order = Cart.getGoodOrder(orderid);
		order.place = place;
		if (act.link) {
			Crumb.go(Template.parse([act.link],order));
			return cb({result:1});	
		}
		if (param) param = '&' + param;
		var path = '/-cart/orderActions.php?id=' + orderid + '&action=' + name + '&place = ' + place + param;
		Cart.getJSON(path, function (ans) {
			Global.set(['order','cat_basket','sign']);
			Session.syncNow();
			cb(ans);
		});
	},
	action: function(name, place, orderid, cb, param) {
		//place - контекст в котором идёт работа
		var rules = Load.loadJSON('-cart/rules.json');
		var act = rules.actions[name];
		var order = Cart.getGoodOrder(orderid);
		order.place = place;
		var layer = Controller.ids['order'];
		//if (!act.link && (!act.go || !act.go[place])) alert('Ошибка. Действие невозможно выполнить с этой странице!');
	
		var link = Cart.getLink(order,place);
		var ask = Template.parse([act.confirm],order);
		ask = link+'<br>'+ask;
		popup.confirm(ask, function () { 
			if (!act.link) Cart.blockform(layer);
			Cart.act(place, name, orderid, function (ans) {
				Cart.goTop( function () {
					var order = Cart.getGoodOrder(ans.id);
					if (order) {
						order.place = place;
						if (act.link) {
							if (act.result) {
								var msg = Template.parse([act.result], order);
								var link = Cart.getLink(order, place);
								popup.alert(link+'<br>'+msg);
							}
							return;
						}
						Cart.unblockform(layer);
						
						if (ans.result) {
							if(act.go && act.go[place]) Crumb.go(Template.parse([act.go[place]], order));
							if (act.result) {
								var msg = Template.parse([act.result], order);
								var link = Cart.getLink(order, place);
								popup.alert(link+'<br>'+msg);
							}
						} else {
							if (ans.msg) { 
								var msg = Template.parse([ans.msg], order);
								var link = Cart.getLink(order, place);
								popup.alert(link+'<br>'+msg);
							} else {
								popup.alert(link+'<br>Произошла обшибка, попробуйте позже!');
							}
						}
					} else {//Заявка удалена
						
						if (ans.result) Crumb.go(act.go[place]);
						if (ans.msg) {
							popup.alert(ans.msg);
						}
					}
					if (cb && ans.result) cb(ans);
				});
			}, param);
		});
	},
	init: function () {
		var rules = Load.loadJSON('-cart/rules.json');
		var layer = Controller.ids['order'];
		for (var name in rules.actions) {
			$(".cart .act-"+name).not('[cartinit]').attr('cartinit', name).click( function () {
				var name = $(this).attr('cartinit');
				var place = $(this).parents('.myactions').data('place');
				var id = $(this).data('id');

				Cart.action(name, place, id);
				return false;
			});
		}
	},
	getJSON: function (src,call) {
		$.ajax({
		  dataType: "json",
		  url: src,
		  async:true,
		  success: call,
		  error: function () {
		  	popup.alert('Ошибка на сервере. Попробуйте позже.');
		  }
		});
	},
	calc: function (div) {
		var order = Cart.getGoodOrder();
		if (!order.basket) order.basket = {};
		var tplcost = function (val) {
			return Template.parse('-cart/cart.tpl', val, 'itemcost')
		}
		var conf = Config.get('cart');
		if (conf.opt) {
			if (!order.merch) {
				if (order.merchdyn) {
					div.find('.cartinfo').html('оптовые цены');
					div.find('.cartblockinfo').removeClass('alert-info').addClass('alert-success');
				} else {
					div.find('.cartinfo').html('розничные цены');
					div.find('.cartblockinfo').removeClass('alert-success').addClass('alert-info');
				}
				div.find('.cartneed').html(tplcost(order.need));
			}
			div.find('.sum').each( function () {
				var prodart=$(this).data('producer')+' '+$(this).data('article');
				var pos=order.basket[prodart];
				if (order.merchdyn) {
					$(this).html(tplcost(pos.sumopt));
					$(this).addClass('bg-success').removeClass('bg-info');
				} else {
					$(this).html(Template.parse('-cart/cart.tpl',pos,'itemcost','sumroz'));
					$(this).addClass('bg-info').removeClass('bg-success');
				}
			});
			div.find('.myprice').each( function () {
				var prodart=$(this).data('producer')+' '+$(this).data('article');
				var pos=order.basket[prodart];
				if (order.merchdyn) {
					$(this).html(Template.parse('-cart/cart.tpl',pos,'itemcost','Цена оптовая'));
					$(this).addClass('bg-success').removeClass('bg-info');
				} else {
					$(this).html(Template.parse('-cart/cart.tpl',pos,'itemcost','Цена розничная'));
					$(this).addClass('bg-info').removeClass('bg-success');
				}
			});
			div.find('.cartsumroz').html(Template.parse('-cart/cart.tpl',order,'itemcost','sumroz'));
			div.find('.cartsumopt').html(Template.parse('-cart/cart.tpl',order,'itemcost','sumopt'));
			if (order.merchdyn) {
				div.find('.cartsum').html(Template.parse('-cart/cart.tpl',order,'itemcost','sumopt'));
				div.find('.cartsum').addClass('bg-success').removeClass('bg-info');
				if (order.sumroz!=order.sumopt) {
					div.find('.cartsumdel').html(tplcost(order.sumroz));
				}
			} else {
				div.find('.cartsum').html(Template.parse('-cart/cart.tpl',order,'itemcost','sumroz'));
				div.find('.cartsum').addClass('bg-info').removeClass('bg-success');
				div.find('.cartsumdel').html(tplcost(''));
			}
		} else {
			div.find('.sum').each( function () {
				var prodart=$(this).data('producer')+' '+$(this).data('article');
				var pos = order.basket[prodart];
				$(this).html(Template.parse('-cart/cart.tpl', pos, 'itemcost', 'sumroz'));
				$(this).addClass('bg-info').removeClass('bg-success');
			});
			div.find('.myprice').each( function () {
				var prodart = $(this).data('producer')+' '+$(this).data('article');
				var pos = order.basket[prodart];
				$(this).html(Template.parse('-cart/cart.tpl',pos,'itemcost','Цена'));
				$(this).addClass('bg-info').removeClass('bg-success');
			});
			div.find('.cartsumroz').html(Template.parse('-cart/cart.tpl', order, 'itemcost', 'sumroz'));
			div.find('.cartsum').html(Template.parse('-cart/cart.tpl', order, 'itemcost', 'sumroz'));
			div.find('.cartsum').addClass('bg-info').removeClass('bg-success');
			div.find('.cartsumdel').html(tplcost(''));
		}
		
	},
	goTop: function (cb) {
		Ascroll.go(null, null, cb);
	},
	canI: function (id, action) {//action true совпадёт с любой строчкой
		var order = Cart.getGoodOrder(id);
		if (!order)return false;
		if (infra.seq.get(order,['rule','user','buttons',action]))return true;
		return infra.forr(infra.seq.get(order,['rule','user','actions']), function (r) {
			if (r['act']==action)return true;
		});
	},
	getGoodOrder: function (orderid) {
		if (!orderid) orderid = '';
		//генерирует объект описывающий все цены... передаётся basket на случай если count актуальный именно в basket
		var path='-cart/?type=list&id='+orderid;
		Global.unload('order', path);
		Load.unload(path);
		Session.syncNow();
		var order = Load.loadJSON(path);//GoodOrder серверная версия
		if (!order.result) return false;
		return order.order;
	},
	toggle: function (orderid, prodart, cb) {
		var fn = function () {
			if (cb) cb();
			Global.check(['cat_basket']);
		}
		if (!orderid) {
			var name = 'user.basket.'+prodart;
			var r = Session.get(name);
			if (r) {
				Session.set(name, null, true, fn);
			} else {
				Session.set(name, { count: 1 }, true, fn);
			}
		} else {
			var order = Cart.getGoodOrder(orderid);
			var param = 'prodart = ' + prodart
			Cart.action('cart-edit', 'orders', orderid, fn, param);
		}
		return !r;
	},
	initPrice: function (div) {
		div.find('.cat_item').each( function () {
			var cart=$(this).find('.basket_img');

			var id=cart.data('producer')+' '+cart.data('article');
			if (Session.get('user.basket.'+id)) {
				$(this).find('.posbasket').show();
				cart.addClass('basket_img_sel');
				cart.attr('title','Удалить из корзины');
			} else {
				cart.attr('title','Добавить в корзину');
			}
		});
		var callback = function () {
			Controller.global.set('cat_basket');
			Controller.check();
		}
		div.find('.cat_item .basket_img').click( function () {
			var cart=$(this);
			var id=cart.data('producer')+' '+cart.data('article');
			var name = 'user.basket.'+id;
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
	}
}