//infra.listen(infrajs,'onshow',function(){
//	cart.init();
//});
window.Cart = {
	blockform: function(layer){
		var form=$("#"+layer.div).find('form');
		form.find("input,button,textarea,select").attr("disabled","disabled");
	},
	refresh:function(){
		infra.loader.show();
		setTimeout(function(){
			Controller.global.set(['order','cat_basket','sign']);
			Session.syncNow();
			Controller.check();
			Cart.goTop();
		},100);
	},
	unblockform: function(layer){
		var div=$("#"+layer.div).find('form');
		div.find("input").removeAttr("disabled");
		div.find("button").removeAttr("disabled");
		div.find("textarea").removeAttr("disabled");
		div.find("select").removeAttr("disabled");
	},
	getLink: function(order,place){
		if(place=='admin'){
			var link='<a onclick="Cart.goTop()" href="?office/'+place+'/{id}">{id}</a>';
		}else{//place=='orders'
			if(!order.id){
				var link='<a onclick="Cart.goTop()" href="?office/'+place+'/my">Активная заявка</a>';
			}else{
				var link='<a onclick="Cart.goTop()" href="?office/'+place+'/{id}">{id}</a>';
			}			
		}
		link=infra.template.parse([link],order);
		return link;
	},
	act:function(place,name,id,cb){
		if(!cb)cb=function(){};
		var rules=Load.loadJSON('-cart/rules.json');
		var act=rules.actions[name];
		var order=Cart.getGoodOrder(id);
		order.place=place;
		if(act.link){
			infra.State.go(infra.template.parse([act.link],order));
			return cb({result:1});	
		}
		var path='-cart/orderActions.php?id='+id+'&action='+name+'&place='+place;
		Cart.getJSON(infra.theme(path), function(ans){
			Controller.global.set(['order','cat_basket','sign']);
			Session.syncNow();
			cb(ans);
		});
	},
	init:function(){
		var rules=infra.loadJSON('-cart/rules.json');
		var layer=Controller.getUnickLayer('order');
		infra.foro(rules.actions,function(act,name){
			$(".act-"+name).not('[cartinit]').attr('cartinit',1).click(function(){
				var place=$(this).parents('.myactions').data('place');
				var id=$(this).data('id');

				
				var order=Cart.getGoodOrder(id);
				order.place=place;

				if(!act.link&&!act.go[place])alert('Ошибка. Действие невозможно выполнить с этой страницы!');
			
				var link=Cart.getLink(order,place);
				var ask=infra.template.parse([act.confirm],order);
				ask='<div style="width:300px">'+link+'<br>'+ask+'</div>';
				popup.confirm(ask,function(){ 
					if(!act.link)Cart.blockform(layer);
					infra.loader.show();

					Cart.act(place,name,id,function(ans){
						Cart.goTop(function(){
							var order=Cart.getGoodOrder(ans.id);
							if(order){
								order.place=place;
								
								if(act.link){
									if(act.result){
										var msg=infra.template.parse([act.result],order);
										var link=Cart.getLink(order,place);
										popup.alert('<div style="width:300px">'+link+'<br>'+msg+'</div>');
									}
									return;
								}
								Cart.unblockform(layer);


								
								if(ans.result)infra.State.go(infra.template.parse([act.go[place]],order));
								if(ans.msg){
									
									var link=Cart.getLink(order,place);
									popup.alert('<div style="width:300px">'+link+'<br>'+ans.msg+'</div>');
								}
							}else{//Заявка удалена
								
								if(ans.result)infra.State.go(act.go[place]);
								if(ans.msg){
									popup.alert('<div style="width:300px">'+ans.msg+'</div>');
								}
							}

						});
					});
					
				});
				return false;
			});
		});
	},
	getJSON:function(src,call){
		$.ajax({
		  dataType: "json",
		  url: src,
		  async:true,
		  success: call,
		  error:function(){
		  	popup.alert('Ошибка на сервере. Попробуйте позже.');
		  }
		});
	},
	calc:function(div){
		
		var order=Cart.getGoodOrder();
		var tplcost=function(val){
			return infra.template.parse('-cart/cart.tpl',val,'itemcost')
		}
		if(!order.merch){
			if(order.merchdyn){
				div.find('.cartinfo').html('оптовые цены');
				div.find('.cartblockinfo').removeClass('alert-info').addClass('alert-success');
			}else{
				div.find('.cartinfo').html('розничные цены');
				div.find('.cartblockinfo').removeClass('alert-success').addClass('alert-info');
			}
			div.find('.cartneed').html(tplcost(order.need));
		}
		
		div.find('.sum').each(function(){
			var prodart=$(this).data('producer')+' '+$(this).data('article');
			var pos=order.basket[prodart];
			if(order.merchdyn){
				$(this).html(tplcost(pos.sumopt));
				$(this).addClass('bg-success').removeClass('bg-info');
			}else{
				$(this).html(infra.template.parse('-cart/cart.tpl',pos,'itemcost','sumroz'));
				$(this).addClass('bg-info').removeClass('bg-success');
			}
		});
		div.find('.myprice').each(function(){
			var prodart=$(this).data('producer')+' '+$(this).data('article');
			var pos=order.basket[prodart];
			if(order.merchdyn){
				$(this).html(infra.template.parse('-cart/cart.tpl',pos,'itemcost','Цена оптовая'));
				$(this).addClass('bg-success').removeClass('bg-info');
			}else{
				$(this).html(infra.template.parse('-cart/cart.tpl',pos,'itemcost','Цена розничная'));
				$(this).addClass('bg-info').removeClass('bg-success');
			}
		});
		div.find('.cartsumroz').html(infra.template.parse('-cart/cart.tpl',order,'itemcost','sumroz'));
		div.find('.cartsumopt').html(infra.template.parse('-cart/cart.tpl',order,'itemcost','sumopt'));
		if(order.merchdyn){
			div.find('.cartsum').html(infra.template.parse('-cart/cart.tpl',order,'itemcost','sumopt'));
			div.find('.cartsum').addClass('bg-success').removeClass('bg-info');
			if(order.sumroz!=order.sumopt){
				div.find('.cartsumdel').html(tplcost(order.sumroz));
			}
		}else{
			div.find('.cartsum').html(infra.template.parse('-cart/cart.tpl',order,'itemcost','sumroz'));
			div.find('.cartsum').addClass('bg-info').removeClass('bg-success');
			div.find('.cartsumdel').html(tplcost(''));
		}
	},
	goTop:function(){
		Ascroll.go();
	},
	canI:function(id,action){//action true совпадёт с любой строчкой
		var order=Cart.getGoodOrder(id);
		if(!order)return false;
		if(infra.seq.get(order,['rule','user','buttons',action]))return true;
		return infra.forr(infra.seq.get(order,['rule','user','actions']),function(r){
			if(r['act']==action)return true;
		});
	},
	getGoodOrder:function(id){
		if(!id)id='';
		//генерирует объект описывающий все цены... передаётся basket на случай если count актуальный именно в basket
		var path='-cart/?type=order&id='+id;
		Controller.global.unload('order',path);
		infra.unload(path);
		Session.syncNow();
		var order=infra.loadJSON(path);//GoodOrder серверная версия
		if(!order.result)return false;
		return order;
	},
	toggle: function (id, callback) {
		var name='user.basket.'+id;
		var r = Session.get(name);
		var fn = function(){
			Controller.global.set(['cat_basket']);
			infrajs.check();
			if (callback) callback();
		}
		if (r) {
			Session.set(name, null, true, fn);
		}else{
			Session.set(name, { count: 1 }, true, fn);
		}
		return !r;
	},
	initPrice: function (div) {
		div.find('.cat_item').each(function(){
			var cart=$(this).find('.basket_img');

			var id=cart.data('producer')+' '+cart.data('article');
			if(Session.get('user.basket.'+id)){
				$(this).find('.posbasket').show();
				cart.addClass('basket_img_sel');
				cart.attr('title','Удалить из корзины');
			}else{
				cart.attr('title','Добавить в корзину');
			}
		});
		var callback=function(){
			Controller.global.set('cat_basket');
			Controller.check();
		}
		div.find('.cat_item .basket_img').click(function(){
			var cart=$(this);
			var id=cart.data('producer')+' '+cart.data('article');
			var name='user.basket.'+id;
			var r=Session.get(name);
			infra.loader.show();
			if(r){
				$(this).removeClass('basket_img_over');
				$(this).removeClass('basket_img_sel');
				$(this).parents('.cat_item').find('.posbasket').hide();
				Session.set(name,null,true,callback);
				cart.attr('title','Добавить в корзину');
			}else{
				
				$(this).addClass('basket_img_sel');
				$(this).parents('.cat_item').find('.posbasket').show();
				Session.set(name,{ count:1 },true,callback);
				cart.attr('title','Удалить из корзины');

			}
		}).hover(function(){
			$(this).addClass('basket_img_over');
		},function(){
			$(this).removeClass('basket_img_over');
		});
	}
}