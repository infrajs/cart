{carttime:}
	<div style="margin-bottom:5px">
	Последний раз заказ отправлялся<br>{~date(:j F Y,data.carttime)} в {~date(:H:i,data.carttime)}<br>
	</div>
{cartanswer:}
	<pre>{mail}</pre>
{css:}
	<style>
		@media (max-width: 992px) {
		   #COLUMN {
				display:none;
			}
		}
		.cart .req {
			color:red;
		}
		.cart .myactions {
			float:right;
		}
		.cart .card {
			border-color:#fbb765;
		}
		.cart .card-header {
			cursor:pointer; 
			border-color:#fbdb65; 
			background-color: #fbdb65;
		}
		.cart .item {
			width:150px;
			cursor: pointer;
		}
		.cart .item.active {
			background-color: #fbdb65;
		}
		.cart .item.active .title {
			font-weight: bold;
		}
		.cart .item:hover {
			background-color:#fff37d;
		}
		.cart .iteminfo {
			display: none;
		}
		.cart .more {
			display: none;
		}
	</style>
{js:}
	<script>
		domready(function(){
			Event.one('Controller.onshow', function () {
				Cart.init();
			});
		});
	</script>
{LIST:}
	{:css}
	{:listcrumb}
	<div class="cart">
		<h1>{data.order.id?:numbasket?(data.result?:mybasket?:numbasket)}</h1>
		{data.result?data.order:showlist?:adm_message}
	</div>
	{:js}
	{showlist:}
		{:cartlistborder}
		{:couponinfolist}
	{couponinfolist:}
		<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
			<div class="mr-sm-3 mx-auto mx-sm-0">{:couponinp}</div>
			<div class="flex-grow-1">
				<p class="text-center text-sm-right {coupon_discount??:d-none}">
					Итого: <b class="carttotal" style="font-size:140%">{total:itemcostrub}</b> 
					<!--<del style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel">{total!sum?sum:itemcostrub}</del>-->
				</p>
				<div class="d-flex text-center text-sm-right flex-column">
					<div><a href="/{crumb.parent}" style="text-decoration:none" class="btn btn-warning">Перейти к {data.order.id?:заказу {data.order.id}?:оформлению заказа}</a></div>
					<div>Займёт не более 3 минут.</div>
				</div>
			</div>
		</div>
	{couponinfoorder:}
		<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
			<div class="mr-sm-3 mx-auto mx-sm-0">{:couponinp}</div>
			<div class="flex-grow-1">
				<p class="text-center text-sm-right {coupon_discount??:d-none}">
					Итого: <b class="carttotal" style="font-size:140%">{total:itemcostrub}</b> 
					<!--<del style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel">{total!sum?sum:itemcostrub}</del>-->
				</p>
				<div class="d-flex text-center text-sm-right flex-column">
					
				</div>
			</div>
		</div>
	{cartlist:}
		<div style="{:ishidedisabled}">
			<div class="d-flex justify-content-between">
				<div>
					<div class="custom-control custom-checkbox">
						<input onclick="$('.showlist :checkbox').prop('checked',$(this).is(':checked')).change();" type="checkbox" class="custom-control-input" name="checkall" id="checkall">
						<label class="custom-control-label" for="checkall">
							Выделенное: </label>
							<span data-param='prodart=' data-id="{data.order.id}" data-place="{data.place}" class="act-clear a">
								Удалить
							</span>
						
					</div>		
				</div>
				<div class="text-right">
					<span data-id="{data.order.id}" data-place="{data.place}" class="cart-search a">Добавить</span>
				</div>
			</div>
		</div>
		
		<hr>
		<div class="showlist">
			{basket::cartpos}
		</div>
		<div class="d-flex align-items-center justify-content-center justify-content-sm-end">
			<div class="mr-2">Сумма: </div><div style="font-size:120%; font-weight:bold" class="cartsum">{sum:itemcostrub}</div>
		</div>
		<script>
			domready( function () {
				//При изменении инпутов. надо рассчитать Сумму и Итого с учётом coupon_discount
				/*
				cartsum
				cartsumdel
				carttotal
				*/
				var tplcost = function (val) {
					return Template.parse('-cart/cart.tpl', val, 'itemcost')
				}
				
				var set = function(el, to) {
					el = $(el);
					el.stop();
					var lastsum = el.data('lastsum');
					//el.width(el.width()).css('display','inline-block');
					$({ 
						n: lastsum
					}).animate({
						n: to 
					}, {
						duration: 500,
						step: function (a) {
							$(el).html(tplcost(Math.round(a)));
						},
						complete:  function(){
							$(el).html(tplcost(to));
							//el.width('auto');
						}
					});
					el.data('lastsum',to);
				}

				var calc = function () {
					var sum = $('.cart [type=number]').reduce(function(ak, el){
						ak+=el.value * $(el).attr('data-cost');
						return ak;
					}, 0);
					set('.cartsum', sum);
					
					if ("{coupon_discount}") {
						var total = sum * (1-{coupon_discount|:0});
						set('.carttotal', total);
						set('.cartsumdel', sum);
						//$('.carttotal').html(tplcost(total));
						//$('.cartsumdel').html(tplcost(sum));
					} else {
						set('.carttotal', sum);
						$('.carttotal').html(tplcost(sum));
						$('.cartsumdel').html('');
					}
				}
				$('.cart [type=number]').change(calc);
			});
		</script>
	{cartlistborder:}
		<div class="border rounded p-3">
			{:cartlist}
		</div>
	{cartpos:}
		<div class="d-flex align-items-sm-center">
			<div style="{:ishidedisabled}">
				<div class="custom-control custom-checkbox">
					<input onchange="$('.act-clear').attr('data-param','prodart='+$('.showlist :checkbox:checked').reduce(function (ak, el){ ak.push($(el).attr('data-prodart')); return ak },[]).join(','))" 
					data-prodart="{:prodart}" type="checkbox" class="custom-control-input" name="check[{~key}]" id="check{~key}">
					<label class="custom-control-label" for="check{~key}"></label>
				</div>
			</div>
			<div class="mr-3 d-none d-sm-block" style="min-width:70px">
				{images.0?:cartposimg}
			</div>
			<div class="flex-grow-1">
				<div class="">{change:star}<b><a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{Наименование}</a></b></div>
				<div class="d-flex align-items-center flex-column flex-sm-row">
					{images.0?:cartposimgm}
					<div class="my-2 flex-grow-1">
						{:basket.props}
					</div>
					<div class="my-2 d-flex align-items-center ml-sm-3">
						<div class="mr-2"><input {:isdisabled} data-cost="{Цена}" style="width:60px" value="{basket[{:prodart}]count}" type="number" min="0" max="999" name="basket.{producer_nick} {article_nick}{:cat.idsp}.count" class="form-control" type="number"></div>
						<div style="min-width:70px;"><b>{Цена:itemcostrub}</b>{*...coupon_discount?:nodiscount}</div>
					</div>
				</div>
			</div>
		</div>
		<hr>
		{nodiscount:}<br><small><nobr>без скидки</nobr></small>
		{cartposimg:}
			<img class="img-thumbnail" src="/-imager/?w=60&crop=1&h=60&src={images.0}&or=-imager/empty.png">
		{cartposimgm:}
			<div class="my-2 mr-3 d-bock d-sm-none">
				<img class="img-thumbnail" src="/-imager/?h=100&src={images.0}&or=-imager/empty.png">
			</div>
{ADMORDER:}
	{:css}
	{:ordercrumb}
	<div class="cart">
		{data.result?data:orderPageContent?:ordermessage}
	</div>
	{:js}
	{*adm_orderPageContent:}
		<div class="float-right" title="Последние измения">{~date(:j F H:i,time)}</div>
		<h1>{rule.title}</h1>
		{id?:ordernum}
		{(data.place=:admin&status=:active)?:adm_orderinfo?:adm_orderinputs}
	{*msg_samples:}
		<span class="a" onclick="var t=$('[name=\'manage.comment\']'); t.val(t.val()+$(this).next().html()).change();">{~key}</span><pre style="display:none">{.}
</pre>{~last()|:comma}
{ORDER:}
	{:css}
	{:ordercrumb}
	<div class="cart">
		{data.result?data:orderPageContent?:ordermessage}
	</div>
	{:js}
	{ordermessage:}
		<h1>{data.order.id}</h1>
		<h1>{data.order.id?:numorder?:myorder}</h1>
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
		{data.ismy?:activebutton}
	{activebutton:}
		<div style="margin-top:10px">
			<a href="/cart/orders/my" class="btn btn-success">
				Показать заказ
			</a>
		</div>
	{showManageComment:}
		<div style="margin-top:10px; margin-bottom:10px;" class="alert alert-info" role="alert"><b>Сообщение менеджера</b>
				<pre style="margin:0; padding:0; font-family: inherit; background:none; border:none; white-space: pre-wrap">{manage.comment}</pre>
		</div>
	{accordCard:}
		<div class="card" data-num="{num}">
			<div onclick="Ascroll.go('#heading{num}')" 
			class="card-header {show?:font-weight-bold}" id="heading{num}" data-toggle="collapse" data-target="#collapse{num}">
				<span class="badge badge-light text-dark badge-pill">{num}</span> <span class="a" aria-expanded="true" aria-controls="collapse{num}">
				{title}
				</span>

			</div>
			<div id="collapse{num}" class="collapse {show?:show}" aria-labelledby="heading{num}" data-*parent="#accordionorder">
				<div class="card-body">
					{content}
				</div>
			</div>
		</div>
	{orderPageContent:}
		<div class="float-right" title="Последние измения">{~date(:j F H:i,order.time)}</div>
		<h1>{order.rule.title} {order.id}</h1>
		
		{order.manage.comment?order:showManageComment}
		<form>
			<div class="accordion" id="accordionorder">
				{~obj(:title,:Корзина,:content,order:cartlist,:num,:1):accordCard}
				{~obj(:title,:Купон,:content,order:couponinfoorder,:num,:2):accordCard}
				{~obj(:title,:Получатель,:content,:fiocard,:num,:3):accordCard}
				{~obj(:title,:Доставка,:content,:transcard,:num,:4):accordCard}
				{~obj(:title,:Оплата,:content,:paycard,:num,:5):accordCard}
			</div>
		</form>
		<script>
			domready( function (){
				Event.one('Controller.onshow', function (){
					var layer = Controller.ids["{id}"];
					$('.accordion .collapse').on('show.bs.collapse', function(){
						var tab = $(this).parent();
						tab.find('.card-header').addClass('font-weight-bold');
						var num = tab.attr('data-num');	
						if (Session.is()) Autosave.set(layer,'accordion.'+num, true);
					});
					$('.accordion .collapse').on('hide.bs.collapse', function(){
						var tab = $(this).parent();
						tab.find('.card-header').removeClass('font-weight-bold');
						var num = tab.attr('data-num');
						if (Session.is()) Autosave.set(layer,'accordion.'+num);
					});
					var layer = Controller.ids["{id}"];
					var list = Autosave.get(layer,'accordion',{~json(order.accordion)});
					if (!list) {
						list = { };
						list[3] = true;
					}
					var first = true;
					for (num in list) {
						if (!first) Ascroll.once=false;
						first = false;


						$('.accordion').find('[data-num='+num+'] .card-header').click();
					}
				});
			})
		</script>
		<div class="my-2 row">
			<div class="col-sm-6">
				<div>Комментарий к заказу</div>
				<textarea {:isdisabled} name="comment" class="form-control" rows="3">{order.comment}</textarea>
			</div>
			<div class="col-sm-6">
				<div>Звонок менеджера <span class="req">*</span></div>
				<div class="form-check mt-1">
					<input {:isdisabled} class="form-check-input" type="radio" name="call" {order.call=:yes?:checked} id="exampleRadios1" value="yes">
					<label class="form-check-label" for="exampleRadios1">
						Мне нужен звонок менеджера для уточнения деталей заказа.
					</label>
				</div>
				<div class="form-check">
					<input {:isdisabled} class="form-check-input" type="radio" name="call" {order.call=:no?:checked} id="exampleRadios2" value="no">
					<label class="form-check-label" for="exampleRadios2">
						Звонок не нужен, информация по заказу понятна.
					</label>
				</div>
			</div>
		</div>
		<div class="alert alert-secondary">Вся информация по зказау, сроки, стоимость доставки, сумма с учётом скидки и доставки, а также данные для оплаты, будет отправлена в SMS по указанному номеру и на электронную почту.</div>
		{crumb.parent.name=:admin?:adminactions?:useractions}
		
	{useractions:}
		<div class="myactions" data-place="orders">
			{order.rule.user:myactions}
		</div>
	{adminactions:}

		<div class="myactions" data-place="admin">
			<p>Письмо клиенту {order.emailtime?:wasemail?:noemail}</p>
			{order.rule.manager:myactions}
		</div>
	{transcard:}
		<div class="transportcard">
			<div class="d-flex flex-wrap" style="font-size:11px">
				{fields.transport::trans}
			</div>
			{fields.transport::transinfo}
		</div>
		<script>
			domready(function (){
				var name = 'transport';
				{:jsitem}
				Event.one('Controller.onshow', function (){
					var tcard = $('.transportcard');
					var pcard = $('.paycard');
					tcard.find('.item').click( function (){
						var layer = Controller.ids["{id}"];
						var value = Autosave.get(layer, 'transport.choice');
						pcard.find('.item').css('display','flex');
						if (!value) return;
						var data = Load.loadJSON(layer.json);
						if (!data) return;
						
						if (!data.fields.transport[value] || !data.fields.transport[value].hide) return;
						var hide = data.fields.transport[value].hide;
						var payvalue = Autosave.get(layer, 'pay.choice');

						
						if (~hide.indexOf(payvalue)) {
							pcard.find('.item').each(function(){
								var val = $(this).data('value');
								console.log(val);
								if (val == payvalue) $(this).click(); //отменили выбор
							});
						}
						
						pcard.find('.item').each(function(){
							var val = $(this).data('value');
							console.log(val);
							if (~hide.indexOf(val)) {
								$(this).hide();//Скрыли кнопку
							}
						});
						
					});
				});
			})
		</script>
		{trans:}
		<div data-value="{~key}" class="item d-flex flex-column border rounded m-1 p-1">
			<div class="d-flex mb-auto title">
				<div><img class="mr-1" src="/-imager/?w=40&src={ico}"></div><div style="text-transform: uppercase;">{~key}</div>
			</div>
			<div>
				<b>{cost}</b><br>
				{term} 
				<span class="morelink ml-1 a float-right">Подробней</span>
			</div>
		</div>
		{transinfo:}
			<div data-value="{~key}" class="iteminfo">{:basket.fields.{tpl}}</div>
{paycard:}
	<div class="paycard">
		<div class="d-flex flex-wrap" style="font-size:11px">
			{fields.pay::pay}
		</div>
		{fields.pay::payinfo}
	</div>
	<script>
		domready(function (){
			var name = 'pay';
			{:jsitem}
		})
	</script>
	{pay:}
	<div data-value="{~key}" style="display:flex" class="item flex-column border rounded m-1 p-1">
		<div style="height:60px" class="d-flex align-items-center justify-content-center"><div><img class="img-fluid" src="/-imager/?h=60&src={ico}"></div></div>
		<div class="mb-auto title"><big>{~key}</big></div>
		<div class="text-right">
			<span class="morelink ml-1 a">Подробней</span>
		</div>
	</div>
	
	{payinfo:}
		<div data-value="{~key}" class="iteminfo"><div class="alert border more">{:basket.fields.{tpl}}</div></div>
{fiocard:}
	<div class="cartcontacts row">
		<div class="col-sm-4 order-sm-2">
			{data.user.email?:fiouser?:fioguest}
		</div>
		<div class="col-sm-8 order-sm-1">
			{order:orderfields}
		</div>
		
	</div>
	{ans:config.ans}
	{fiouser:}<b>Вы авторизованы</b><p>Ваш аккаунт <b>{data.user.email}</b></p>
	{fioguest:}<b>Уже покупали у нас?</b>
	<p><a href="/user/signin?back=ref">Авторизуйтесь</a>, чтобы не заполнять форму повторно.</p>
{jsitem:}
	//< script>
	Event.one('Controller.onshow', function (){
		var div = $('.'+name+'card');
		var layer = Controller.ids["{id}"];
		var value1 = Autosave.get(layer,name+'.choice','{data.order.pay.choice}');
		var value2 = Autosave.get(layer,name+'.choice','{data.order.transport.choice}');
		if(name == 'pay') var value = value1;
		else var value = value2;
		var first = false;
		div.find('.item').click( function (){
			if (first && !{data.order.rule.edit[data.place]?:true?:false}) return;
			first = true;
			div.find('.item').not(this).removeClass('active');
			if ($(this).is('.active')) {
				$(this).removeClass('active');
				Autosave.set(layer,name+'.choice');	
			} else {
				var value = $(this).data('value');
				$(this).addClass('active');
				Autosave.set(layer,name+'.choice',value);	
			}
			div.find('.iteminfo').hide();
			if (value) div.find('.iteminfo').each( function () {
				if ($(this).data('value') == value) {
					$(this).fadeIn();
				}
			});
			Autosave.loadAll(layer);
		}).each(function(){
			if ($(this).data('value') == value) {
				$(this).click();
			}
		});
		first = true;
		div.find('.morelink').click( function (event){
			var item = $(this).parents('.item');
			var value = item.data('value');
			if (item.is('.active')) {
				event.stopPropagation();
			} 
			div.find('.iteminfo').each( function () {
				if ($(this).data('value') == value) {
					if (item.is('.active')) $(this).find('.more').slideToggle();
					else $(this).find('.more').show();
				}
			});
			
		});
	});
	{myactions:}
		<div style="margin:20px 0;" class="cart">
			<div class="btn-toolbar" role="toolbar">
				<div class="btn-group dropup">
					<button class="btn btn-secondary dropdown-toggle" id="dropdownActionMenu" type="button" data-toggle="dropdown">
						
					</button>
					<div class="dropdown-menu" role="menu" aria-labelledby="dropdownActionMenu">
						{actions::actprint}
					</div>	
				</div>
				<div class="btn-group ml-2">
					{buttons::mybtns}
				</div>
			</div>
		</div>
		{mybtns:}
			<div class="act-{act} btn btn-{cls}" data-id="{data.order.id}">
				{title}
			</div>
		{actprint:}
			<div class="dropdown-item act-{act}" style="cursor:pointer" data-id="{data.order.id}">
				{title}
			</div>
			{actact:}/{crumb}
	{b:}<b>
	{/b:}</b>
	{noProducts:}
		<h3>В заказе нет товаров</h3>
		<p align="right">
			<a href="/{crumb}/list">Редактировать корзину</a><br>
			<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span>
		</p>
{dateFormat:}d.m.Y h:i:s
{couponinp:}
	<div style="max-width:250px" class="input-group">
		<input name="coupon" {:isdisabled} value="{coupon}" type="text" class="form-control" id="coupon" placeholder="Укажите купон">
		<div class="input-group-append">
		    <button onclick="Cart.action('{crumb.parent.name}', 'sync', {data.order.id});" class="btn btn-secondary" type="button">Активировать</button>
		</div>
	</div>
	<div class="py-2">
		{data.order.coupon_msg}
	</div>
	{prodart:}{producer_nick} {article_nick}{:cat.idsp}
	{mybasket:}Ваша корзина
	{numbasket:}Корзина {data.order.id}
	{myorder:}Оформление заказа
	{numorder:}Заказ {data.order.id}
{cartmsg:}<p>Корзина пустая. Добавьте в корзину интересующие позиции.
		
		</p>
		<p>Чтобы добавить позицию нужно кликнуть по иконке корзины рядом с ценой в <a href="/catalog">каталог</a>.</p>
		<span data-id="{data.order.id}" data-place="{crumb.parent.parent.name}" class="cart-search a float-right">Поиск позиций</span>
		<div style="margin-top:10px">
			<a href="/catalog" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
		</div>
{itemnocost:}<a href="/contacts">Уточнить</a>
{RBREAD:}
	<ul class="breadcrumb cart">
		{data.email?:breaduser?:breadguest}
		<span onclick="Cart.refresh(this)" class="btn btn-secondary btn-sm float-right"><span class="pe-7s-refresh"></span></span>
	</ul>
	{breaduser:}
		<li class="breadcrumb-item"><a href="/user">{data.email|:Профиль}</a></li>
		<li class="breadcrumb-item"><a href="/cart/orders/my/list">Корзина</a></li>
	{breadguest:}
		<li class="breadcrumb-item"><a href="/user/signin">Вход</a></li>
		<li class="breadcrumb-item"><a href="/user/signup">Регистрация</a></li>
		<li class="breadcrumb-item"><a href="/user/remind">Напомнить пароль</a></li>
{CART:}
	{:usercrumb}
	<h1>Личный кабинет</h1>
	{data.email?:account?:noaccount}

	<p>{~length(data.list)?:showinfo}</p>
	<p>
		В вашей <a href="/cart/orders/my/list">корзине</a> <b>{data.order.count}</b> {~words(data.order.count,:позиция,:позиции,:позиций)}.
	</p>
	
	{data.admin?:adminControl}
	{data.manager?:mngControl}
	{showinfo:}
		<table class="table table-striped">
			{data.list::stinfo}
		</table>
	{stinfo:}
		<tr class="{data.rules.rules[~key].notice}"><td>{data.rules.rules[~key].caption}</td><td>{::prorder}</td></tr>
		{prorder:}{~key?:comma}<a href="/cart/orders/{id}">{id}</a>
	{noaccount:}
		<p>
			<b><a href="/user/signin">Вход</a> не выполнен!</b>
		</p>
	{account:}
		<p>
			Пользователь <a href="/user"><b>{data.email}.</b></a>
		</p>
	{youAreManager:}
		<div class="alert alert-success" role="alert">
			<b>Вы являетесь менеджером</b>
		</div>
	{mngControl:}
		<div class="alert alert-success" role="alert">
			<b>Вы менеджер - <a href="/cart/admin">все заказы</a></b>
		</div>
	{adminControl:}
		<div class="alert alert-{data.manager?:success?:danger}" role="alert">
			{data.email?:adminForm?:allertForAdmin}
		</div>
		
		{adminForm:}
			<p>Введён логин и пароль администратора сайта</p>
			<p>Вы можете изменить свой статус</p>
			<form style="margin-top:10px" class="managerForm" action="/-cart/?type=cart&amp;submit=1" method="post">
				 <div style="display:none" class="checkbox">
					<label>
						<input name="IAmManager" type="checkbox" {data.manager??:checked}>
					</label>
				</div>
				<div class="input-group">
					<input type="submit" class="btn btn-{data.manager?:success?:danger}" value="{data.manager?:Сделать меня обычным пользователем?:Сделать меня менеджером}">
				</div>
			</form>
			
			<script>
				domready( function () {
					Once.exec('layer{id}', function () {
						var layer = Controller.ids['{id}'];
						Event.handler('Controller.onsubmit', function (layer) {
							if (!layer.showed) return;
							var ans = layer.config.ans;
							Global.set(["user","cart"]);
						});
					});
				})
			</script>
		{allertForAdmin:}
			<div class="mesage">Необходимо <a href="/user/signup">зарегистрироваться</a>, чтобы получить права менеджера</div>
{ORDERS:}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<li class="breadcrumb-item active">Мои заказы</li>
		<li class="breadcrumb-item"><a href="/cart/orders/my/list">Содержимое корзины</a></li>
		<li class="breadcrumb-item"><a href="/cart/orders/my">Оформление заказа</a></li>
		
	</ol>
	<h1>Мои заказы</h1>
	{~length(data.orders)?:ordersList?:noOrders}
	<div style="margin-top:10px">
		<a href="/cart/orders/my/list" style="text-decoration:none" class="btn btn-success">Заказ ({data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)})</a>
	</div>
	{noOrders:} <div>В данный момент у вас нет сохранённых заказов с товарами.</div>
	
	{ordersList:}
		
		
		{data.orders::rowOrders}
		
		
		{rowOrders:}
			<div class="border mb-2 p-2">
				
				<b><a href="/cart/orders/{status=:active?:my?id}">{status=:active?:Заказ?id}</a></b>
				 &mdash; <nobr>{rule.short}</nobr>
				 <div class="float-right">
				 	{~date(:j F H:i,time)}<br>
				 	<b>{total:itemcostrub}</b>
				 </div>
				
				
				
				<div style="text-overflow: ellipsis; 
				overflow: hidden;">
				{basket::product}
				</div>
				<div class="clearfix"></div>
				
			</div>


			{dateform:}d.m.Y
	{orderfields:}
		<div class="form-group">
			<label>ФИО <span class="req">*</span></label>
			<input {:isdisabled} type="text" name="name" value="{name}" class="form-control" placeholder="{data.fields.fio?:helpFIO?:helpCont}">
		</div>
		<div class="form-group">
			<label>Телефон <span class="req">*</span></label>
			<input {:isdisabled} type="tel" name="phone"  value="{phone}" class="form-control" placeholder="+79270000000">
		</div>
		<div class="form-group">
			<label>Email <span class="req">*</span></label>
			<input {:isdisabled} type="email" name="email" value="{email}" class="form-control" placeholder="Email">
		</div>
		{*hide:}
		{data.fields.passport?:passprot}
		{data.fields.address?:address}
		{~conf.cart.pay?:orderpayinfo}
		{~conf.cart.deliverychoice?:ordertransportinfo}
		{helpCont:}Контактное лицо
		{helpFIO:}Иванов Иван Иванович
		{strФИО:} (ФИО)
		{address:}
			<div class="form-group">
				<label>Адресс доставки <span class="req">*</span></label>
				<input {:isdisabled} type="text" name="address" value="{address}" class="form-control" placeholder="443456, Самарская обл., г. Тольятти, ул. Ивана Грозного 13, офис 12">
			</div>
		{passprot:}
			<div class="form-group">
				<label>Серия и номер паспорта <span class="req">*</span></label>
				<input {:isdisabled} type="text" name="passport" value="{passport}" class="form-control" placeholder="88 88 999999">
			</div>
		{ordertransportinfo:}
			<strong>
					Способ доставки <span class="req">*</span>
			</strong>
			<div class="radio">
				<label><input {:isdisabled} name="delivery" {delivery=:pickup?:checked} type="radio" value="pickup"> Самовывоз</label>
			</div>
			<div class="radio">
				<label><input id="delivery" {:isdisabled} name="delivery" {delivery=:delivery?:checked} type="radio" value="delivery"> Доставка транспортной компанией</label>
			</div>
			<div class="delivery">
				<script>
					domready( function () {
						Event.one('Controller.onshow', function () {
							var div = $('#{div}');
							if(div.find("input[name=delivery]:checked").val()!='delivery'){
								div.find('.delivery').hide();
							}
							div.find("input[name=delivery]:radio").change(function() {
								if ($(this).val()=='delivery') {
									$('.delivery').slideDown();
								} else {
									$('.delivery').slideUp();
								}
							});
						});
					});
				</script>
				<div class="form-group">
					<label>Адрес доставки <span class="req">*</span></label>
					<input {:isdisabled} type="text" name="addresdelivery" value="{addresdelivery}" class="form-control" placeholder="Адрес доставки">
				</div>
			</div>
		{orderpayinfo:}
			<strong>
				Кто будет оплачивать <span class="req">*</span>
			</strong>
			<div class="radio">
				<label>
					<input {:isdisabled} name="entity" {entity=:individual?:checked} type="radio" value="individual">
					Физическое лицо
				</label>
			</div>
			<div class="radio">
				<label>
					<input {:isdisabled} name="entity" {entity=:legal?:checked} type="radio" value="legal">
					Юридическое лицо
				</label>
			</div>
			<div class="entitylegal">
				<script>
					domready( function () {
						Event.one('Controller.onshow', function () {
							var div=$('#{div}');
							if(div.find("input[name=entity]:checked").val()!='legal'){
								div.find('.entitylegal').hide();
							}
							div.find("input[name=entity]:radio").change(function() {
								if ($(this).val()=='legal') {
									$('.entitylegal').slideDown('slow');
								} else {
									$('.entitylegal').slideUp('slow');
								}
							});
						});
					});
				</script>
				<strong>Реквизиты <span class="req">*</span></strong>
				<div class="radio">
					<label>
						<input {:isdisabled} name="details" {details=:here?:checked} type="radio" value="here">
						Указать реквизиты в полях для ввода
					</label>
				</div>
				<div class="radio">
					<label>
						<input {:isdisabled} name="details" {details=:allentity?:checked} type="radio" value="allentity">
						Указать все реквизиты в одном поле для ввода
					</label>
				</div>
				<div class="allentity">
					<script>
						domready( function () {
							Event.one('Controller.onshow', function () {
								var div = $('#{div}');
								if(div.find("input[name=details]:checked").val()!='allentity'){
									div.find('.allentity').hide();
								}
								div.find("input[name=details]:radio").change(function() {
									if ($(this).val()=='allentity') {
										$('.allentity').slideDown('slow');
									} else {
										$('.allentity').slideUp('slow');
									}
								});
								
							});
						});
					</script>
					<div class="form-group">
						<label>
							Скопируйте реквизиты из карточки компании
						</label>
						<textarea {:isdisabled} class="form-control" rows="8" name="allentity"></textarea>
					</div>
					
				</div>
				<div class="detailshere">
					<script>
						domready( function () {
							Event.one('Controller.onshow', function () {
								var div=$('#{div}');
								if(div.find("input[name=details]:checked").val()!='here'){
									div.find('.detailshere').hide();
								}
								
								div.find("input[name=details]:radio").change(function() {
									if ($(this).val()=='here') {
										$('.detailshere').slideDown('slow');
									} else {
										$('.detailshere').slideUp('slow');
									}
								});
								
							});
						});
					</script>
					<div class="form-group">
						<label>Название организации <span class="req">*</span></label>
						<input {:isdisable} type="text" name="company" value="{company}" class="form-control" placeholder='Название организации'>
					</div>
					<div class="form-group">
						<label>ИНН <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="inn" value="{inn}" class="form-control" placeholder="ИНН">
					</div>
					<div class="form-group">
						<label>Юридический адрес <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="addreslegal" value="{addreslegal}" class="form-control" placeholder="Юридический адрес">
					</div>
					<div class="form-group">
						<label>Почтовый адрес <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="addrespochta" value="{addrespochta}" class="form-control" placeholder="Почтовый адрес">
					</div>
					<div class="form-group">
						<label>Наименование банка <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="bankname" value="{bankname}" class="form-control" placeholder="Наименование банка">
					</div>
					<div class="form-group">
						<label>Бик <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="bik" value="{bik}" class="form-control" placeholder="Бик">
					</div>
					<div class="form-group">
						<label>Расчётный счёт <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="rasaccount" value="{rasaccount}" class="form-control" placeholder="Расчётный счёт">
					</div>
					<div class="form-group">
						<label>Корреспондентский счёт <span class="req">*</span></label>
						<input {:isdisabled} type="text" name="coraccount" value="{coraccount}" class="form-control" placeholder="Корреспондентский счёт">
					</div>
					
				</div>
				
			</div>
			
			<strong>
					Способ оплаты <span class="req">*</span>
			</strong>
			<div class="radio">
				<label><input {:isdisabled} name="paymenttype" {paymenttype=:card?:checked} type="radio" value="card"> Оплата картой</label>
			</div>
			<div class="radio">
				<label><input {:isdisabled} name="paymenttype" {paymenttype=:cash?:checked} type="radio" value="cash"> Оплата наличными курьеру или в магазине</label>
			</div>
	{isdisabled:}{data.order.rule.edit[data.place]|:disabled}
	{ishidedisabled:}{data.order.rule.edit[data.place]|:disabledhide}
	{disabledhide:}display:none
{basketedit:}
	<p align="right">
		<a href="/{crumb}/list">Редактировать корзину</a><br>
		<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span><br>
		<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="act-clear a">Очистить</span>
	</p>
{tableWidthProductopt:}
	<table class="table table-striped">
		<tr>
			<th>Позиция</th>
			<th class="{merchdyn?:bg-success?:bg-info}"><span>Цена {merchdyn?: оптовая?: розничная}</span></th>
			<th>Кол<span class="d-none d-sm-inline">ичество</span></th>
			<th>Сумма</th>
		</tr>
		{basket::positionRow}
		<tr><td class="d-none d-sm-table-cell"></td><td colspan=3 style="text-align:right">{sum:itemcostrub}</td></tr>
	</table>
	{manage.summary?:widthSummary}
	{manage.deliverycost?:widthDivelery}

	
	{positionRow:}
		<tr>
			<td><a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{producer} {article}</a>{change?:star}<br>{itemrow}</td>
			<td>{cost:itemcost}</td>
			<td>{count}</td>
			<td class="d-none d-sm-table-cell">{sum:itemcost}</td>
		</tr>

	{widthSummary:}
		<div>
			Сумма подтверждёная менеджером: <span>{manage.summary:itemcostrub}</span>
		</div>
	{widthDivelery:}
		<div>
			Доставка: {manage.deliverycost:itemcostrub}
		</div>

{ADMIN:}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<li class="breadcrumb-item active">Все заказы</li>
	</ol>
	{data.result?:adm_listPage?:adm_message}
	{longlistlink:}<a href="/cart/admin/all">Готовые заказы</a>
	{shortlistlink:}<a href="/cart/admin">В работе</a>
	{adm_listPage:}
		<div class="float-right">{crumb.child.name=:all?:shortlistlink?:longlistlink}</div>
		<h1>Все заказы</h1>
		
		
			{data.products::adm_row}
		
		
		{adm_row:}
		
			<div class="border mb-2 p-2">
				
				<b><a href="/cart/admin/{id}">{id}</a></b> &mdash; <nobr>{rule.short}</nobr>
			
				<div class="float-right text-right">
					{email}<br>
					{~date(:d.m.Y H:i,time)}<br>
					<b>{total:itemcostrub}</b>
				</div>
				
				
				<div style="text-overflow: ellipsis; 
				overflow: hidden;">
					{basket::product}
				</div>
				<div class="clearfix"></div>
			</div>
			
			{product:} <nobr>{count} <a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{article}</a>{~last()|:comma}</nobr><wbr>

			{adm_paidorder:}<b>{~cost(manage.paid)} руб.</b> {manage.paidtype=:bank?:банк?:менеджер} {~date(:d.m.Y H:i,manage.paidtime)}
{cat::}-catalog/cat.tpl
{extend::}-catalog/extend.tpl

{basket::}-cart/basket.tpl

	{*adm_orderinputs:}
		<form method="post">
			<div class="disabled">
				<div class="cartcontacts">
					{:orderfields}
					<label>Сообщение для менеджера</label><br> 
					<textarea name="comment" class="form-control" rows="6">{comment}</textarea>
				</div>
				
				<br>
				{count?:tableWidthProduct?:noProducts}
				

				<div class="py-2">Итоговая цена, руб</div>
				<div style="max-width:300px" class="input-group pb-3">
					<input class="form-control" name="manage.summary" value="{manage.summary}" type="text">
					<div class="input-group-append">
					    <button onclick="Cart.action('{crumb.parent.name}', 'sync', {data.order.id});" class="btn btn-outline-secondary" type="button">Применить</button>
					</div>
				</div>
				
				
				{data.fields.address?:mngdelivery}
				<div style="margin-bottom:10px">Итого: <b class="cartsum">{~sum(data.order.total,data.order.manage.deliverycost|:0):itemcostrub}</b>{data.order.manage.summary?:totalwarn}</div>
				<label>Сообщение для клиента</label>&nbsp;<small>{data.messages::msg_samples}</small><br>
				<textarea autosavebreak="1" name="manage.comment" class="form-control" rows="6">{manage.comment}</textarea>

				<div class="answer"><b class="alert">{config.ans.msg}</b></div>
			</div>
		</form>
		<p>Письмо клиенту {emailtime?:wasemail?:noemail}</p>
		<!--<h3>{rule.title}</h3>
		{data.id?order:ordernum}-->
		{data.rule.freeze?:freezemsg}
		<!--<div class="checkbox">
			<label>
				<input type="checkbox" "autosave"="0" onclick="Session.set('dontNotify',this.checked)" name="dontNotify">
				НЕ оповещать пользователя о совершённом действии
			</label>
			<script>
				domready(function(){
					Event.one('Controller.onshow', function () {
						var layer = Controller.ids['{...id}'];
						var div = $('#'+layer.div);
						var check=!!Session.get('dontNofify');
						div.find('[name=dontNotify]').val(check);
					});
				});
			</script>
		</div>-->

		<div class="myactions" data-place="admin">
			{rule.manager:myactions}
		</div>
		
		<script>
			domready(function(){
				Event.one('Controller.onshow', function () {
					var layer = Controller.ids['{...id}'];
					var div = $('#'+layer.div);
					var counter = {counter};
					var id = "{crumb.name}";
					if (id == 'my') id=null;
					var order = Cart.getGoodOrder(id);
					var place = div.find('.myactions').data('place');
					if (!order.rule.edit[place]) Cart.blockform(layer);

					Event.handler('Layer.onsubmit', function (layer) {
						if (!layer.showed || counter != layer.counter) return;
						var ans = layer.config.ans;
						Global.set('cart');
						Ascroll.go();
					}, '', layer);
					
					if (Session.get('manager{data.order.id}')) {
						$('.clearMyDelta').css('fontWeight', 'bold');
					} else {
						$('.clearMyDelta').css('fontWeight', 'normal');
					}
					
					Event.handler('Session.onsync', function () {
						if (!layer.showed || counter != layer.counter) return;
						if (Session.get('manager{data.order.id}')) {
							$('.clearMyDelta').css('fontWeight', 'bold');
						} else {
							$('.clearMyDelta').css('fontWeight', 'normal');
						}
					});
					if ($("#legal").prop('checked')) {
						$('.legal').slideDown();
					} else {
						$('.legal').slideUp();
					}			
					if ($("#delivery").prop('checked')) {
						$('.delivery').slideDown();
					} else {
						$('.delivery').slideUp();
					}
					
					$("input[name=entity]:radio").change( function () {
						if ($("#legal").prop('checked')) {
							$('.legal').slideDown();
						} else {
							$('.legal').slideUp();
						}
					});
					$("input[name=delivery]:radio").change( function () {
						if ($("#delivery").prop('checked')) {
							$('.delivery').slideDown();
						} else {
							$('.delivery').slideUp();
						}
					});
				});
			});
		</script>
	{totalwarn:} <i title="установлено менеджером">*</i>
	{noemail:}<b>ещё не отправлялось</b>{wasemail:}было <b>{~date(:j F H:i,order.emailtime)}</b>
	{mngdelivery:}
	<div class="form-group">
		<label>Цена доставки</label>
		<input class="form-control" name="manage.deliverycost" value="{manage.deliverycost}" type="text">
	</div>
	{freezemsg:}<br>Цены зафиксированы {~date(manage.freeze)}
	{adm_orderinfo:}
		<div>
			Контактное лицо: <b>{name}</b><br>
			Email: <b>{email}</b><br>
			Телефон: <b>{phone}</b>
		</div>
{comma:}, 
{text-danger:}text-danger
{usersync:}
	<script>
		domready( function () {
			Cart.usersync();
		});
	</script>
{usercrumb:}
	<ol class="breadcrumb">
		<li class="breadcrumb-item active {data.manager?:text-danger}">Личный кабинет</li>
		<li class="breadcrumb-item"><a href="/cart/orders">Мои заказы</a></li>
	</ol>
{listcrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		{data.place=:admin?:liallorder}
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заявка {crumb.parent.name=:my?:Активная?crumb.parent.name}</a></li>-->
		<li class="breadcrumb-item active">Содержимое корзины</li>
		<li class="breadcrumb-item"><a href="/cart/orders/my">Оформление заказа {data.order.id}</a></li>
	</ol>
{ordercrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item active">Заявка {crumb.name=:my?:Активная?crumb.name}</li>-->
		{data.place=:admin?:liallorder}
		<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb}/list">Содержимое корзины</a>
		<li class="breadcrumb-item active">Оформление заказа {data.order.id}</li></li>
	</ol>
{liallorder:}<li class="breadcrumb-item"><a class="{data.place=:admin?:text-danger}" href="/{crumb.parent}">{data.place=:admin?:Все?:Мои} заявки</a></li>
{itemcost:}{~cost(.)}<span class="d-none d-sm-inline">&nbsp;<small>{:extend.unit}</small></span>
{itemcostrub:}{~cost(.)}&nbsp;<small>{:extend.unit}</small>
{star:}<span class="req" title="Позиция в каталоге изменилась">*</span> 
{ordernum:}Номер заказа: <b>{id}</b>{manage.paid?:msgpaidorder}
	{msgpaidorder:}. Оплата <b>{~cost(manage.paid)} руб.</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}
{adm_message:}
	<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
{PRINT:}
<ol class="breadcrumb noprint">
	<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
	<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заказы</a></li>
	<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заказ {crumb.parent.name=:my??crumb.parent.name}</a></li>
	<li class="breadcrumb-item active">Версия для печати</li>
</ol>
<pre style="border:none;"><h1 style="margin-bottom:0px">Заказ {id}</h1>
ФИО: {name}
Почта: {email}
Телефон: {phone}
Перезвонить: {call=:yes?:да?(call=:no?:нет)}{time?:pr-time}
{transport::iprint}
{pay::iprint}

===== {count} {~words(count,:позиция,:позиции,:позиций)} =====
{basket::basket.pritem}

Сумма: {~cost(sum)}&nbsp;руб.
{coupon?:prcoupon} 

==== Сообщение =====
<span style="white-space: pre-wrap;">{comment}</span>

====================
<span style="white-space: pre-wrap;">{manage.comment}</span>
</pre>
{iprint:}
{~key}: {.}
{prcoupon:}Купон: {coupon}
Итого: {~cost(total)}&nbsp;руб.
{pr-time:}
Дата изменений: {~date(:H:i j F Y,time)}
{pr-deliver:}
Доставка: {~cost(manage.deliverycost)}&nbsp;руб.