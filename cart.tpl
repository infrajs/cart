{root:}
	<div class="cart">
		<div id="CARTMENU"></div>
		<div id="cartbody"></div>
	</div>
{ORDER:}
	<div>
		<div id="ORDERCART"></div>
		
		<script>
			domready(function(){
				Event.one('Controller.onshow', function () {
					var layer = Controller.ids['{id}'];
					var div = $('#'+layer.div);
					var counter = {counter};
					Event.handler('Layer.onsubmit', function (layer) {
						if (!layer.showed || counter != layer.counter) return;
						var ans = layer.config.ans;
						Controller.global.set(['cat_basket', 'order']);
						Cart.goTop();
					}, '', layer);
				});
			});
		</script>
	</div>
{carttime:}
	<div style="margin-bottom:5px">
	Последний раз заявка отправлялась<br>{~date(:j F Y,data.carttime)} в {~date(:H:i,data.carttime)}<br>
	</div>
{cartanswer:}
	<pre>{mail}</pre>
{ORDERCART:}
	<style scoped>
		.usercart label {
			margin-top:5px;
			text-align: left;
			font-size: 14px;
			padding-top: 5px;
		}
		.usercart label span {
			color:red;
		}
		.usercart form {
			padding-bottom: 5px;
		}
		.usercart .answer {
			width: 290px;
		}
		.usercart .cartcontacts input {
			width: 290px;
			height: 18px;
			padding-top: 2px;
			border: 1px solid #7f9db9;
			margin: 0 auto;
			margin-bottom:10px;
			margin-top:2px;
		}
		.usercart .cartcontacts textarea {
			width: 290px;
			height:102px;
			border: 1px solid #7f9db9;
		}
		.usercart .submit {
			margin-top:20px;			
			font-size:14px;
			padding: 5px 10px;
		}
		.usercart input {
			width:50px;
			padding:1px 5px;
		}
		.usercart .img {
			text-align:center;
			vertical-align:top;
			padding:5px 2px;
		}
		
		.usercart .cartparam {
			margin-bottom:20px;
		}
		.usercart .cartparam td {
			vertical-align: middle;
		}
		
	</style>
	<h1>Корзина</h1>
	{data.merch?:infoopt?:inforoz}
	<div class="usercart" style="margin-top:15px;">		
		{data.count?:cartlist?:cartmsg}
	</div>
	<script>
		domready(function(){
			Event.when('Controller.onshow', function () {
				var layer = Controller.ids['{id}'];
				var div = $('#'+layer.div);
				Cart.calc(div);
				div.find('[type=number]').change( function () {
					cart.calc(div);
				});

				div.find('.posremove').click( function () {
					var prodart=$(this).data('producer')+' '+$(this).data('article');
					Session.set(['user','basket',prodart]);
					Controller.global.set('cat_basket');
					Session.syncNow();
					Controller.check();
				});
			});
		});
	</script>
	{inforoz:}
		<div class="cartblockinfo alert alert-info">
			<p>
			Для вас действуют <b onclick="$(this).parents('.alert:first').find('div').toggle()" class="a cartinfo">розничные цены</b>.
			</p>
			<div style="display:none; margin-top:10px">
				<p>
					Сумма оплаченых заявок: <b>{~cost(data.hadpaid)} руб.</b><br>
					Розничная сумма текущей заявки: <b class="cartsumroz"></b><br>
					Оптовая сумма текущей заявки: <b class="cartsumopt"></b>
				</p>
				<p>
					Оптовые цены действуют от <b>{~cost(data.level)} руб.</b><br>
					В активную заявку нужно добавить товар на сумму <b class="cartneed"></b>
				</p>
			</div>
		</div>
	{infoopt:}
		<div class="alert alert-success">
			<p>
				Для вас всегда действуют <b onclick="$(this).parents('.alert:first').find('div').toggle()" class="a">оптовые цены</b>.
			</p>
			<div style="display:none; margin-top:10px">
				<p>
					Сумма оплаченых заявок: <b>{~cost(data.hadpaid)} руб.</b><br>
					Розничная сумма текущей заявки: <b class="cartsumroz"></b><br>
					Оптовая сумма текущей заявки: <b class="cartsumopt"></b>
				</p>
			</div>
		</div>
	{cartlist:}
		<table class="table">
			{data.basket::cartpos}
		</table>
		<div>Итого: <span class="cartsum"></span> <del title="Розничная цена" style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel"></del></div>
		<div style="margin-top:10px">
			<a onclick="Cart.goTop();" href="/office/orders/my" style="text-decoration:none" class="btn btn-success">Перейти к оформлению заявки</a>
		</div>
	{cartpos:}
		<tr class="active">
			<td style="color:gray; vertical-align:middle">{num}</td>
			<td style="vertical-align:middle">
				<div class="title">
					
					<a href="/catalog/{producer}/{article}"><nobr>{Производитель}</nobr> <nobr>{Артикул}</nobr></a>

				</div>
			</td>
			<td colspan="4" style="vertical-align:middle">
				{Наименование} 
			</td>
			<td style="padding:2px; vertical-align:middle;">
				<div style="float:right;">
					<span title="Удалить из корзины"  data-article="{article}" data-producer="{Производитель}" class="btn btn-sm btn-hover btn-danger posremove">
						<span class="glyphicon glyphicon-remove"></span>
					</span>
				</div>
			</td>
		</tr>
		<tr>
			<td rowspan="3"></td>
			<td rowspan="3" style="width:1px">
				<a href="/catalog/{producer}/{article}">
					<img src="infra/plugins/imager/imager.php?h=90&src={infra.conf.catalog.dir}{Производитель}/{article}/&or=*imager/empty">
				</a>
			</td>
			<td style="">
				Цена:
			</td>
			<td></td>
			<td style="white-space:nowrap;">
				<span class="myprice" data-article="{article}" data-producer="{Производитель}">
					{Цена розничная?Цена розничная:itemcost?:itemnocost}
				</span>
			</td>
			<td style="width:100%"></td><td></td>
		</tr>
		<tr>
			<td style="vertical-align:middle;">Количество:</td>
			<td style="vertical-align:middle; padding-top:0; padding-bottom:0;"><input type="number" min="0" name="basket.{Производитель} {article}.count"></td>
			<td style="white-space:nowrap; vertical-align:middle">
				<span class="sum" data-article="{article}" data-producer="{Производитель}"></span>
			</td>	
		</tr>
		<tr>
			<td colspan="4" style="height:100%"></td>
		</tr>
{cartmsg:}<p>Корзина пустая. Добавьте в корзину интересующие позиции.
		
		</p>
		<p>Чтобы добавить позицию нужно кликнуть по иконке корзины рядом с ценой.</p>
		<div style="margin-top:10px">
			<a href="/catalog" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
		</div>
{itemcost:}{~cost(.)} <small>руб.</small>
{itemnocost:}<a style="color:white" href="/contacts">Уточнить</a>
{basket:}
	<div id="basket_text">
		В <a href="/cart/order">корзине</a>
		<!--<span class="bold_basket">{data.allcount}</span> {~words(data.allcount,:позиция,:позиции,:позиций)}<br> Сумма <span class="bold_basket">{~cost(data.allsum)} руб.</span>-->
	</div>
{breadcrumb:}
	<ol class="breadcrumb activelink">
		<li><a href="/">Главная</a></li>
		<li><a href="/catalog">Каталог</a></li>
		<li class="active">Сообщения <span class="label label-info">42</span></li>
		{data.email?:breaduser?:breadguest}
	</ol>
	{breaduser:}
		<li><a href="/cart/list">Корзина</a></li>
		<li><a href="/cart/order">Активная заявка</a></li>
		<li><a href="/cart/orders">Все заявки</a></li>
		<li><a class="text text-danger" href="/user/logout">Выход</a></li>
		<span class="btn btn-default btn-xs pull-right"><span class="pe-7s-refresh"></span></span>
	{breadguest:}
		<li><a href="/user/signin">Вход</a></li>
		<li><a href="/user/signup">Регистрация</a></li>
		<li><a href="/user/remind">Напомнить пароль</a></li>
{OFFICE:}
	{:breadcrumb}
	<h1>Сообщения <button type="button" class="btn btn-default pull-right" onclick="Cart.refresh()">
		<span class="pe-7s-refresh"></span>
		</button></h1>
	{data.email?:account?:noaccount}
	
	<p>{~length(data.list)?:showinfo?:Для вас нет важных сообщений.}</p>
	
	
	<p>
		В <a onclick="Cart.goTop();" href="/cart/list">корзине</a> {data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)}.
	</p>
	
	{data.admin?:adminControl?(data.manager?:youAreManager)}
	
	{showinfo:}
		<table class="table table-striped">
			{data.list::stinfo}
		</table>
	{stinfo:}
		<tr class="{data.rules.rules[~key].notice}"><td>{data.rules.rules[~key].caption}</td><td>{::prorder}</td></tr>
		{prorder:}{~key?:comma}<a onclick="Cart.goTop()" href="/cart/orders/{id}">{id}</a>
	{comma:}, 

	{noaccount:}
		<p>
			<b><a onclick="Cart.goTop()" href="/user">Вход</a> не выполнен!</b>
		</p>
	{account:}
		<p>
			Пользователь <a href="/user"><b>{data.email}.</b></a>
		</p>
	{youAreManager:}
		<div class="alert alert-success" role="alert">
			<b>Вы являетесь менеджером</b>
		</div>
	{adminControl:}
		<div class="alert alert-{data.manager?:success?:danger}" role="alert">
			{data.email?:adminForm?:allertForAdmin}

		</div>
		{adminForm:}
				<p>Введён логин и пароль администратора сайта</p>
				<p>Вы можете изменить свой статус</p>
				<p style="font-weight:bold">Вы {data.manager?:менеджер?:обычный пользователь}</p>
				<form style="margin-top:10px" class="managerForm" action="/-cart/?type=office&amp;submit=1" method="post">
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
							Controller.global.set(["sign",'cat_basket']);
						});
					});
				})
			</script>
		{allertForAdmin:}
			<div class="mesage">Необходимо <a onclick="Cart.goTop()" href="/cart/signup">зарегистрироваться</a>, чтобы получить права менеджера</div>
{CARTMENU:}
	<style scoped>
		table.userMenu td {
			text-align: center;
			vertical-align: middle;
			padding:10px; 
		}
		table.userMenu {
			margin-top:25px;
			width:100%;
			border-top:3px solid #ccc;
		}
		table.userMenu {
			background-color: #f0f0f0;
		}
		table.userMenu .active {
			font-weight:bold;
		}
	</style>
	<script>
		domready( function () {
			Event.one('Controller.onshow', function () {
				cart.init();
			});
		});
	</script>
	<table class="userMenu table">
	 	<tr>
	 		<td class="info"><a class="{state.child??:active}" onclick="Cart.goTop()" href="/cart">Личный кабинет</a></td>
	 		<td class="info"><a class="{state.child.name=:cart?:active}" onclick="Cart.goTop()" href="/cart/order">Корзина</a></td>
	 		<td class="info"><a class="{state.child.name=:orders?:active}" onclick="Cart.goTop()" href="/cart/orders">Мои заявки</a></td>
	 		{data.email?:signed?:unsigned}
	 	</tr>
	</table>
	<!--
	<h2 style="color:red;">Тестовая версия личного кабинет</h2>
	<p>Оплата картой и оформление заявки тестируется. Для подтверждения заказа необходимо звонить по телефону 8482 51-75-70</p>
	<hr>
	-->	
{signed:}
	
	{data.manager?:youAreManager}
	<td class="danger"><a class="signout" href="/cart/signout">Выход</a>
		<script>
			domready(function(){
				$('.signout').click(function(){
					Session.logout();
					Controller.global.set(['cat_basket',"sign"]);
					Session.syncNow();
					Cart.goTop();

				});
			});
		</script>
	</td>

{unsigned:}
	<td class="warning"><a class="{state.child.name=:signin?:active}" 
		onclick="Cart.goTop()" href="/cart/signin">Вход</a></td>
	<td class="warning"><a class="{state.child.name=:signup?:active}" 
		onclick="Cart.goTop()" href="/cart/signup">Регистрация</a></td>
	<td class="warning"><a class="{state.child.name=:resendpass?:active}" 
		onclick="Cart.goTop()" href="/cart/resendpass">Напомнить пароль</a></td>

{youAreManager:}
	<td class="success"><a class="{state.child.name=:admin?:active}" onclick="Cart.goTop()" href="/cart/admin">Управление заявками</a></td>
	<td class="success"><a class="{state.child.name=:wholesale?:active}" onclick="Cart.goTop()" href="/cart/wholesale">Оптовики</a></td>