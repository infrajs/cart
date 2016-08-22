infra.wait(infrajs,'onshow',function(){
	var test=infra.test;
	test.tgo=function(title,css,src){
		test.tasks.push([title,function(){
			test.tgo.ses=infra.session.getId();
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			$(css).filter(':first').click();
		},function(){
			test.checksrc(src);
			if(!test.tgo.ses&&infra.session.getId())return test.err('При переходам по страницам появляется сессия');
			test.ok();
		}]);
	}
	test.tgoa=function(title,css,src){
		test.tasks.push(['Переход '+title,function(){
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			$(css).filter(':first').find('a[weblife_href="?'+src+'"]').click();
		},function(){
			test.checksrc(src);
			test.ok();
		}]);
	}
	test.tclick=function(title,css,check){
		test.tasks.push([title,function(){
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			$(css).filter(':first').click();
		},function(){
			check();
		}]);
	}
	test.checksrc=function(src){
		if(typeof(src)=='undefined')return;
		if(infra.State.get()!=src)test.err('Не перешли на страницу '+src);
	}
	test.orderaction=function(action,src){
		var rules=infra.loadJSON('-cart/rules.json');
		var title=rules.actions[action].title;
		test.tasks.push([title,function(){
			infra.when(infrajs,'onshow',function(){//Окно подтверждения
				infra.when(infrajs,'onshow',function(){//Окно подтверждения закрылось
					infra.when(infrajs,'onshow',function(){//Переход на страницу
						if(!rules.actions[action].result)return test.check();//Результат о действии не предусмотрен
						infra.when(infrajs,'onshow',function(){//Показано окно результата
							infra.when(infrajs,'onshow',function(){//Закрыто окно результатов
								test.check();
							});
							popup.close();
						});
					});
				});
				$('.modal .popup-confirm-ok').click();
			});
			if($('.myactions a.act-'+action).length>1)console.warn('Кнопок '+action+' больше одной')
			$('.myactions a.act-'+action).click();
		},function(){
			test.checksrc(src);
			test.ok();
		}]);
	}
	test.adminorder=function(status){
		test.tgoa('Управление заявками','#usermenu','office/admin');
		test.tasks.push(['Переход на первую заявку от менеджера',function(){
			infra.when(infrajs,'onshow',function(){
				test.check();
			});

			var a=false;
			$('#orderscontrol > tbody > tr').each(function(){
				test.orderid
				var aa=$(this).find('td:nth-child(1) a');
				if(aa.text()==test.orderid)a=aa;
			});
			if(a)a.click();
		},function(){
			var state=infra.State.getState('').child.child;
			var id=infra.foro(state.obj,function(name,key){return key});
			if(!id)return test.err('В адресной строке не появился идентификатор заявки');
			var idonpage=$('#content > b:nth-child(4)').text();
			if(id!=idonpage)return test.err('На странице id и в адресной строке id не совпадают');
			var order=cart.getGoodOrder(id);
			if(!order||!order.id||order.id!=id)return test.err('Сервер вернул некорректные данные по заявке');
			if(order.status!==status)return test.err('У заявки некорректный статус '+order.status+' должен быть '+status);
			if(!order.rule.edit.admin&&!$('#content > form input[name="name"]').is(':disabled'))return test.err('Не заблокированное поле name');
			if($('.cartcontacts input[name="email"]').val()!='test@itlf.ru')return test.err('Некорректный email в заявке');
			test.ok();
		}]);
	}
	test.userorder=function(status){
		test.tgoa('Мои заявки','#usermenu','office/orders');
		test.tasks.push(['Переход на первую заявку от пользователя',function(){
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			var tr=$('#content table.ordersList > tbody > tr:first');
			var td=tr.find('td:nth-child(1)');
			td.find('a').click();
		},function(){
			var state=infra.State.getState('').child.child;
			var id=infra.foro(state.obj,function(name,key){return key});
			if(!id)return test.err('В адресной строке не появился идентификатор заявки');
			test.orderid=id;//Для Управления заявками чтобы нужную заявку смотреть
			var idonpage=$('#content > b:nth-child(4)').text();
			if(id!=idonpage)return test.err('На странице id и в адресной строке id не совпадают')
			var order=cart.getGoodOrder(id);
			if(!order||!order.id||order.id!=id)return test.err('Сервер вернул некорректные данные по заявке');
			if(order.status!==status)return test.err('У заявки некорректный статус '+order.status+' должен быть '+status);
			if(!order.rule.edit.orders&&!$('#content > form > div.cartcontacts > div:nth-child(1) > input').is(':disabled'))return test.err('Не заблокированное поле name');
			if($('.cartcontacts input[name="email"]').val()!='test@itlf.ru')return test.err('Некорректный email в заявке');
			test.ok();
		}]);
	}
	test.setManager=function(is){
		test.tgoa('Личный кабинет','#usermenu','office');
		var val=is?'Да':'Нет';
		test.tasks.push(['Устанавливаем менеджера '+val,function(){
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			$('#content form .btn').click();
		},function(){
			if(is&&!infra.session.get('safe.manager'))return test.err('Не стал менеджером');
			if(!is&&infra.session.get('safe.manager'))return test.err('Стал менеджером');
			test.ok();
		}]);
	}
	test.INITLOGIN=function(){
		
		//===================== шаг 1 Авторизация ===================//
		test.tasks.push(['Инициализация',function(){
			console.log('INITLOGIN');
			infra.require('-cart/cart.js');
			infra.when(infra.State,'onchange',function(){
				infra.session.logout();
				infrajs.global.set(['order','cat_basket','sign']);
				infra.when(infrajs,'onshow',function(){
					test.check();
				});
				infrajs.check();
			});
			infra.State.go('?');
		},function(){
			var email=$('#basket_text > span > a').text();
			if(email!='Гость')return test.err('Когда был logout в блоке показывается какой-то email '+email);
			test.checksrc('');
			if(infra.session.getId())return test.err('Все ещё есть авторизация');
			if(!window.cart)return test.err('Нет объекта window.cart');
			test.ok();
		}]);

		
		test.tgo('Вход','#basket_text > span > a','office/signin')
		


		test.tasks.push(['Отправить форму авторизации',function(){
			$('#sign-email').val('test@itlf.ru');
			$('#sign-password').val('04eae403');
			infra.when(infrajs,'onshow',function(){
				test.check();
			});
			$('#content > form').submit();
		},function(){
			var msg=$('#content > form > div.alert.alert-danger').text();
			var email=$('#basket_text > span > a').text();
			if(email!='test@itlf.ru')return test.err('Email авторизации не показался в блоке '+msg);
			test.ok();
		}]);

		test.tasks.push(['Очистить корзину',function(){
			infra.session.set('user.basket',null,true,function(){
				infrajs.global.set(['order','cat_basket','sign']);
				infra.when(infrajs,'onshow',function(){
					test.check()
				});
				infra.State.go('?office/cart');
			});
		},function(){
			test.checksrc('office/cart');
			var basket=infra.session.get('user.basket');
			if(basket)return test.err('Не удалось очистить корзину');
			return test.ok();
		}]);

		test.tgo('Каталог','#nav > table > tbody > tr > td:nth-child(3) > a','Каталог/Каталог');

		
		test.tasks.push([
			'Клик по добавить в корзину',
			function(){
				$('#content > div.cat_items > table:nth-child(2) > tbody > tr:nth-child(2) > td.producer > table > tbody > tr:nth-child(2) > td:nth-child(2) > div').click();
				test.check();
			},function(){
				//Сессия не синхронизировалась, а пошёл переход/ Такое могло быть и спользователем
				var block=$('.cat_items .posbasket:first');
				if(block.css('display')!=='block')return test.err('Не показался блок со ссылкой в корзину');
				return test.ok();
			}
		]);

		test.tgo('Корзина','div.cat_items td.producer > table > tbody > tr:nth-child(3) > td > div > small > a','office/cart');


		
		test.tgo('Активная заявка','#cart > div.usercart > div:nth-child(3) > a','office/orders/my');




		test.tclick('Клик по пункту в меню очистить корзину','#content > div.myactions .act-clear',function(){
			if(!popup.st)return test.err('Не открылось окно confirm');
			test.ok();
		});
		test.tclick('Клик ОК в окне подтверждения','.modal .popup-confirm-ok',function(){
			//сейчас onshow скрываемого окна confirm 
			infra.when(infrajs,'onshow',function(){
				//Пришёл ответ и запусился общий onshow
				infra.when(infrajs,'onshow',function(){
					//А вот это уже показалось окно результата
					if(!popup.st)return test.err('Не открылось окно result');
					test.checksrc('office/orders');
					if(infra.session.get('user.basket'))return test.err('Не очистилась корзина');
					popup.close();
					test.ok();
				});
			});
		});

		test.tasks.push([
			'Очистить сессию',
			function(){
				var orders=infra.session.get('safe.orders');
				var counter=0;
				var check=function(){
					if(counter)return;
					var src='-session/set.php?name=safe';
					infra.unload(src);
					infra.loadJSON(src);
					infra.session.clear(function(){
						console.log(infra.session.get());
						test.check();
					});
				};
				infra.forr(orders,function(id){
					if(cart.canI(id,'realdel')){
						counter++;
						cart.act('orders','realdel',id,function(ans){
							if(!ans.result){
								console.error(ans.msg);
								return;
							}
							counter--;
							check();
						});
						//Совершить действие удалить заявку
					}
				});
				check();
			},function(){
				if(infra.session.get('safe'))return test.err('safe остался');
				var data=infra.session.get();
				if(infra.foro(data,function(val,name){
					return true;
				}))return test.err('Сессия не очистилась');
				return test.ok();
			}
		]);
		
		test.tgoa('Главная страница','#head_block','');
	}
	test.ADDGOOD=function(){
		
		test.tasks.push(['Добавляем в корзину первый товар на главной',
			function(){
				console.log('ADDGOOD');
				$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table > tbody > tr:nth-child(2) > td:nth-child(2) > div').click();
				test.check();
			},function(){
				var block=$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table > tbody > tr:nth-child(2) > td:nth-child(2) > div').click();
				if(block.css('display')!=='block')return test.err('Не показался блок со ссылкой в корзину');
				if(!infra.fora(basket,function(){return true}))return test.err('Товара нет в корзине');
				return test.ok();
			}
		]);
		test.tasks.push(['Удаляем из корзины первый товар на главной',
			function(){
				$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table > tbody > tr:nth-child(2) > td:nth-child(2) > div').click();
				test.check();
			},function(){
				var basket=infra.session.get('user.basket');
				if(infra.fora(basket,function(){return true}))return test.err('Товар есть в корзине');
				var block=$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table .posbasket:first');
				if(block.css('display')=='block')return test.err('Показан блок со ссылкой в корзину');
				return test.ok();
			}
		]);
		test.tasks.push(['Добавляем в корзину первый товар на главной',
			function(){
				$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table > tbody > tr:nth-child(2) > td:nth-child(2) > div').click();
				test.check();
			},function(){
				var block=$('#content table:nth-child(2) > tbody > tr:nth-child(3) > td > table .posbasket:first');
				if(!infra.fora(basket,function(){return true}))return test.err('Товара нет в корзине');
				if(block.css('display')!=='block')return test.err('Не показался блок со ссылкой в корзину');
				var num=Number($('#basket_text > div > span').text());
				if(num!==1)return test.err('В блоке не показывается что в корзине есть 1 товар');
				return test.ok();
			}
		]);
		test.tgo('Переход в корзину','#basket_text > div > a:nth-child(5)','office/cart');
		
		test.tasks.push(['Устанавливаем количество 7',
			function(){
				infra.when(infra.session,'onsync',function(){
					test.check();
				});
				$('#cart > div.usercart > table > tbody > tr:nth-child(3) > td:nth-child(2) > input[type="number"]').val(7).change();
			},function(){
				var basket=infra.session.get('user.basket');
				pos=infra.foro(basket,function(pos){return pos});
				if(pos.count!=7)return test.err('Количество не установилось');
				test.ok();
			}
		]);
		test.tgo('Переход к активной заявке','#cart > div.usercart > div:nth-child(3) > a','office/orders/my');
		


		test.tasks.push(['Заполнить заявку',
			function(){
				infra.when(infra.session,'onsync',function(){
					test.check();
				});
				$('input[name="name"]').val('Антон').change();
				$('input[name="phone"]').val('1231231231').change();
				$('input[name="entity"]').val('individual').change();
				$('input[name="paymenttype"]').val('cash').change();
				$('input[name="delivery"]').val('pickup').change();
				$('textarea[name="comment"]').val('ТЕСТ').change();
				infra.session.sync();
			},function(){
				var order=infra.session.get('user');
				if(order.name!='Антон')return test.err('name не установилось');
				if(order.phone!='1231231231')return test.err('phone не установилось');
				if(order.entity!='individual')return test.err('entity не установилось');
				if(order.paymenttype!='cash')return test.err('paymenttype не установилось');
				if(order.delivery!='pickup')return test.err('delivery не установилось');
				if(order.comment!='ТЕСТ')return test.err('comment не установилось');
				pos=infra.foro(order.basket,function(pos){return pos});
				if(pos.count!=7)return test.err('Количество не установилось');
				test.ok();
			}
		]);
		test.orderaction('saved','office');
		test.tgoa('Главная страница','#head_block','');
	}
	test.ONESELL=function(){
		test.tasks.push(['ONESELL',function(){
			test.check();
		},function(){
			test.ok();
		}]);
		/================== Продажа одного товара. (корзина пуста, аккаунт тестовый, страница главная, сессия пустая)=======================/
		test.tgoa('Корзина','#basket_text','office/cart');
		test.userorder('saved');
		
		test.orderaction('check','office');

		
		test.userorder('check');
		
		test.setManager(true);
		
		test.adminorder('check');
		test.tasks.push(['Устанавливаем комментарий',
			function(){
				infra.when(infra.session,'onsync',function(){
					cart.act('admin','savechanges',test.orderid,function(ans){
						test.check();
					});
				});
				$('#adminForm > div > textarea').val('ТЕСТ МЕНЕДЖЕР').change();
				
			},function(){
				var order=cart.getGoodOrder(test.orderid);
				if(!order.manage.comment)return test.err('Коммент не установился');
				test.ok();
			}
		]);
		test.orderaction('execution','office/admin');
		
		test.adminorder('execution');
		test.orderaction('picked','office/admin');
		
		test.adminorder('picked');
		test.orderaction('complete','office/admin');
		
		test.adminorder('complete');
		test.orderaction('realdel','office/admin');
		test.setManager(false);
		test.tgoa('Главная страница','#head_block > li.head_block_1','');
	}
	test.BANK=function(){
		test.tasks.push(['BANK',function(){
			test.check();
		},function(){
			test.ok();
		}]);
		test.tgoa('Корзина','#basket_text','office/cart');
		test.userorder('saved');
		test.orderaction('active','office/orders/my');

		test.tasks.push(['Заполняем заявку',function(){
			infra.when(infra.session,'onsync',function(){
				test.check();
			});
			$('input[name=paymenttype][value=card]').prop('checked',true).change();
		},function(){
			var paymenttype=infra.session.get('user.paymenttype');
			if(paymenttype!='card')return test.err('Не смогли указать тип оплаты картой');
			test.ok();
		}]);
		test.orderaction('check','office');
		test.setManager(true);
		test.adminorder('check');
		test.orderaction('ready','office/admin');
		test.userorder('ready');
		test.orderaction('paycard');
		test.tasks.push(['Проверяем страницу оплаты',function(){
			test.check();
		},function(){
			var paymenttype=infra.session.get('user.paymenttype');
			if(paymenttype!='card')return test.err('Тип оплаты не указан что картой');
			var inputnames=['AMOUNT','CURRENCY','ORDER','DESC','TERMINAL','TRTYPE','MERCH_NAME',
			'MERCHANT','EMAIL','TIMESTAMP','NONCE','BACKREF','P_SIGN'];
			var r=infra.forr(inputnames,function(name){
				if(!$('input[name='+name+']').val())return 'Нет значения '+name;
			});
			if(r)return test.err(r);
			test.ok();
		}]);
		test.adminorder('ready');
		test.orderaction('realdel','office/admin');
		test.setManager(false);
		test.tgoa('Главная страница','#head_block','');
	};

	test.INITLOGIN();
	test.ADDGOOD();
	test.ONESELL();
	test.INITLOGIN();
	test.ADDGOOD();
	test.BANK();
	test.exec();
	//Установить что оплата картой и отправить на проверку
});