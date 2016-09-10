{carttime:}
	<div style="margin-bottom:5px">
	Последний раз заявка отправлялась<br>{~date(:j F Y,data.carttime)} в {~date(:H:i,data.carttime)}<br>
	</div>
{cartanswer:}
	<pre>{mail}</pre>
{LIST:}
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
	<ol class="breadcrumb">
		<li><a href="/">Главная</a></li>
		<li><a href="/catalog">Каталог</a></li>
		<li><a href="/cart">Сообщения</a></li>
		<li><a href="/cart/orders">Мои заявки</a></li>
		<li><a href="/{crumb.parent}">Заявка {crumb.parent.name=:my?:Активная?crumb.parent.name}</a></li>
		<li class="active">Корзина</li>
	</ol>
	<h1>Корзина {crumb.parent.name=:my|crumb.parent.name}</h1>
	{~conf.cart.opt?(data.order.merch?:infoopt?:inforoz)}
	<div class="usercart" style="margin-top:15px;">		
		{data.order.count?data.order:cartlist?:cartmsg}
	</div>
	<script>

		domready(function(){
			Once.exec('layer{id}', function () {
				Event.one('Controller.oncheck', function () {
					var layer = Controller.ids['{id}'];
					Event.handler('Layer.onshow', function () {
						var div = $('#'+layer.div);
						Cart.calc(div);
						div.find('[type=number]').change( function () {
							Cart.calc(div);
						});
					}, 'cart', layer);
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
					Сумма оплаченых заявок: <b>{~cost(data.order.hadpaid)} руб.</b><br>
					Розничная сумма текущей заявки: <b class="cartsumroz"></b><br>
					Оптовая сумма текущей заявки: <b class="cartsumopt"></b>
				</p>
				<p>
					Оптовые цены действуют от <b>{~cost(data.order.level)} руб.</b><br>
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
					Сумма оплаченых заявок: <b>{~cost(data.order.hadpaid)} руб.</b><br>
					Розничная сумма текущей заявки: <b class="cartsumroz"></b><br>
					Оптовая сумма текущей заявки: <b class="cartsumopt"></b>
				</p>
			</div>
		</div>
	{cartlist:}
		<table class="table">
			{basket::cartpos}
		</table>
		<div>Итого: <span class="cartsum"></span> <del title="Розничная цена" style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel"></del></div>
		<div style="margin-top:10px">
			<a onclick="Cart.goTop();" href="/{crumb.parent}" style="text-decoration:none" class="btn btn-success">Перейти к {id?:заявке {id}?:оформлению заявки}</a>
		</div>
		{cartname:}
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
				<td style="vertical-align:middle;">
					<div style="float:right; margin-right:10px" class="cart">
						<span class="abasket bg-danger" data-order="{data.order.id}" data-producer="{producer}" data-article="{article}">
							<span class="pe-7s-close-circle"></span>
						</span>
					</div>
				</td>
			</tr>
			<tr>
				<td rowspan="3"></td>
				<td rowspan="3" style="width:1px">
					<a href="/catalog/{producer}/{article}">
						<img src="/-imager/?h=90&src={Config.get(:catalog).dir}{Производитель}/{article}/&or=-imager/empty">
					</a>
				</td>
				<td style="">
					Цена:
				</td>
				<td></td>
				<td style="white-space:nowrap;">
					<span class="myprice" data-article="{article}" data-producer="{Производитель}">
						{Цена?Цена:itemcost?:itemnocost}
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
{RBREAD:}
	<ul class="breadcrumb cart">
		{data.email?:breaduser?:breadguest}
		<span onclick="Cart.refresh(this)" class="btn btn-default btn-xs pull-right"><span class="pe-7s-refresh"></span></span>
	</ul>
	{breaduser:}
		<li><a href="/user">{data.email|:Профиль}</a></li>
		<li><a href="/cart/orders/my/list">Корзина</a></li>
	{breadguest:}
		<li><a href="/user/signin">Вход</a></li>
		<li><a href="/user/signup">Регистрация</a></li>
		<li><a href="/user/remind">Напомнить пароль</a></li>
{CART:}
	<ol class="breadcrumb">
		<li><a href="/">Главная</a></li>
		<li><a href="/catalog">Каталог</a></li>
		<li class="active">Сообщения</li>
		<li><a href="/cart/orders">Мои заявки</a></li>
		<li><a href="/cart/orders/my">Заявка Активая</a></li>
		<li><a href="/cart/orders/my/list">Корзина</a></li>
	</ol>
	<h1>Сообщения</h1>
	{data.email?:account?:noaccount}
	
	<p>{~length(data.list)?:showinfo?:Для вас нет важных сообщений.}</p>
	
	
	<p>
		В <a onclick="Cart.goTop();" href="/cart/orders/my/list">корзине</a> {data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)}.
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
							Controller.global.set(["sign",'cat_basket']);
						});
					});
				})
			</script>
		{allertForAdmin:}
			<div class="mesage">Необходимо <a onclick="Cart.goTop()" href="/cart/signup">зарегистрироваться</a>, чтобы получить права менеджера</div>
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


{ORDERS:}
	<ol class="breadcrumb">
		<li><a href="/">Главная</a></li>
		<li><a href="/catalog">Каталог</a></li>
		
		<li><a href="/cart">Сообщения</a></li>
		<li class="active">Мои заявки</li>
		<li><a href="/cart/orders/my">Заявка Активная</a></li>
		<li><a href="/cart/orders/my/list">Корзина</a></li>
	</ol>
	<h1>Мои заявки</h1>
	{~length(data.orders)?:ordersList?:noOrders}
	{noOrders:} <div>В данный момент у вас нет сохранённых заявок с товарами.</div>
	<div style="margin-top:10px">
		<a onclick="Cart.goTop();" href="/cart/orders/my" style="text-decoration:none" class="btn btn-success">Активная заявка ({data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)})</a>
	</div>
{ordersList:}
	
	<!--<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>-->
	<table class="ordersList table table-striped">
		<thead>
		<tr>
			<th>Номер</th>
			<th>Статус</th>
			<th>Сумма</th>
			<th>Состав</th>
			<th>Дата</th>
		</tr>
		</thead>
		<tbody>
			{data.orders::rowOrders}
		</tbody>
	</table>
	
	{rowOrders:}
		<tr>
			<td>
				<a onclick="Cart.goTop()" href="/cart/orders/{status=:active?:my?id}">{status=:active?:Активная?id}</a>
			</td>
			<td>
				{rule.short}
			</td>
			<td>
				<span class="{merchdyn?:bg-success?(manage.summary|:bg-info)}">{total:itemcost}</span>
			</td>
			<td>
				{basket::product}
			</td>
			<td>{~date(:j F H:i,time)}</td>
		</tr>
	{dateform:}d.m.Y
	{product:} <nobr>{count} <a href="/catalog/{producer}/{article}">{Артикул}</a>{~last()|:comma}</nobr>
	
	{copyOnly:}
		<span class="a copy" data-id="{id}">Копировать</span>

	{copyWithCancel:}
		<span class="a copy" data-id="{id}">Копировать</span><br>
		<span class="a refunds" data-id="{id}">Отменить</span>

	{readyPack:} 
		<span class="a paycard" data-id="{id}">оплатить</span><br>
		<span class="a active" data-id="{id}">сделать активной</span><br>
		<span class="a copy" data-id="{id}">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>

	{savedPack:}
		<span class="a check" data-id="{id}">на проверку</span><br>
		<span class="a active" data-id="{id}">сделать активной</span><br>
		<span class="a copy" data-id="{id}">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>

	{activePack:}
		<span class="a save" data-id="{id}">сохранить</span><br>
		<span class="a clear" data-id="{id}">очистить</span><br>
		<span class="a check" data-id="{id}">на&nbsp;проверку</span><br>
		<a href="/cart/cart">корзина</a>
{orderfields:}
	<div class="form-group">
		<label>Контактное лицо <span class="req">*</span></label>
		<input {rule.edit[place]|:disabled} type="text" name="name" value="{name}" class="form-control" placeholder="Контактное лицо">
	</div>
	<div class="form-group">
		<label>Телефон <span class="req">*</span></label>
		<input {rule.edit[place]|:disabled} type="tel" name="phone"  value="{phone}" class="form-control" placeholder="Телефон">
	</div>
	<div class="form-group">
		<label>Email <span class="req">*</span></label>
		<input type="email" name="email" value="{email}" {email?:disabled} class="form-control" placeholder="Email">
	</div>
	<strong>
		Кто будет оплачивать <span class="req">*</span>
	</strong>
	<div class="radio">
		<label>
			<input {rule.edit[place]|:disabled} name="entity" {entity=:individual?:checked} type="radio" value="individual">
			Физическое лицо
		</label>
	</div>
	<div class="radio">
		<label>
			<input {rule.edit[place]|:disabled} name="entity" {entity=:legal?:checked} type="radio" value="legal">
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
				<input {rule.edit[place]|:disabled} name="details" {details=:here?:checked} type="radio" value="here">
				Указать реквизиты в полях для ввода
			</label>
		</div>
		<div class="radio">
			<label>
				<input {rule.edit[place]|:disabled} name="details" {details=:allentity?:checked} type="radio" value="allentity">
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
				<textarea {rule.edit[place]|:disabled} class="form-control" rows="8" name="allentity"></textarea>
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
				<input {rule.edit[place]|:disabled} type="text" name="company" value="{company}" class="form-control" placeholder='Название организации'>
			</div>
			<div class="form-group">
				<label>ИНН <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="inn" value="{inn}" class="form-control" placeholder="ИНН">
			</div>
			<div class="form-group">
				<label>Юридический адрес <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="addreslegal" value="{addreslegal}" class="form-control" placeholder="Юридический адрес">
			</div>
			<div class="form-group">
				<label>Почтовый адрес <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="addrespochta" value="{addrespochta}" class="form-control" placeholder="Почтовый адрес">
			</div>
			<div class="form-group">
				<label>Наименование банка <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="bankname" value="{bankname}" class="form-control" placeholder="Наименование банка">
			</div>
			<div class="form-group">
				<label>Бик <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="bik" value="{bik}" class="form-control" placeholder="Бик">
			</div>
			<div class="form-group">
				<label>Расчётный счёт <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="rasaccount" value="{rasaccount}" class="form-control" placeholder="Расчётный счёт">
			</div>
			<div class="form-group">
				<label>Корреспондентский счёт <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="coraccount" value="{coraccount}" class="form-control" placeholder="Корреспондентский счёт">
			</div>
			
		</div>
		
	</div>
	
	<strong>
			Способ оплаты <span class="req">*</span>
	</strong>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="paymenttype" {paymenttype=:card?:checked} type="radio" value="card"> Оплата картой</label>
	</div>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="paymenttype" {paymenttype=:cash?:checked} type="radio" value="cash"> Оплата наличными курьеру или в магазине</label>
	</div>
	

	<strong>
			Способ доставки <span class="req">*</span>
	</strong>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="delivery" {delivery=:pickup?:checked} type="radio" value="pickup"> Самовывоз</label>
	</div>
	<div class="radio">
		<label><input id="delivery" {rule.edit[place]|:disabled} name="delivery" {delivery=:delivery?:checked} type="radio" value="delivery"> Доставка транспортной компанией</label>
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
			<input {rule.edit[place]|:disabled} type="text" name="addresdelivery" value="{addresdelivery}" class="form-control" placeholder="Адрес доставки">
		</div>
	</div>
{ORDER:}
	<ol class="breadcrumb">
		<li><a href="/">Главная</a></li>
		<li><a href="/catalog">Каталог</a></li>
		<li><a href="/cart">Сообщения</a></li>
		<li><a href="/cart/orders">Мои заявки</a></li>
		<li class="active">Заявка {crumb.name=:my?:Активная?crumb.name}</li>
		<li><a href="/{crumb}/list">Корзина</a></li>
	</ol>
	{data.result?data:orderPageContent?:message}

	{message:}
		<h1>{data.id}</h1>
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
		{data.ismy?:activebutton}
	{activebutton:}
		<div style="margin-top:10px">
			<a onclick="Cart.goTop()" href="/cart/orders/my" class="btn btn-success">
				Показать заявку
			</a>
		</div>
	{manage:}
		
		<div class="alert alert-info" role="alert"><h3 style="margin-top:0">Сообщение менеджера</h3>{manage.comment}</div>
	{orderPageContent:}
		<h1>{order.rule.title}</h1>
		{order.id?order:ordernum}
		{manage.comment?:manage}
		<form>
			<div class="cartcontacts">
				{order:orderfields}
				<div>
					<strong>Сообщение для менеджера</strong>
					<textarea {order.rule.edit[place]|:disabled} name="comment" class="form-control" rows="4">{comment}</textarea>
				</div>
			</div>
			<div class="answer"><b class="alert">{config.ans.msg}</b></div>
			<script>
				domready ( function () {
					Event.one('Controller.oncheck', function () {
						var layer = Controller.ids["{..id}"];
						Event.one('Layer.onshow', function () {
							var div=$('#'+layer.div);
							var id="{crumb.name}";
							if (id == 'my') id = null;
							var order = Cart.getGoodOrder(id);
							var place = div.find('.myactions').data('place');
						}, '', layer);
					});
				});
			</script>
		</form>
		
		{~length(order.basket)?order:tableWidthProduct?order:noProducts}
		<div style="margin-bottom:10px">Итого: <span class="cartsum">{~sum(order.total,order.manage.deliverycost|:0):itemcost}</span></div>
		<h3>{order.rule.title}</h3>
		{data.order.id?order:ordernum}
		<div class="myactions" data-place="orders">
			{order.rule.user:myactions}
		</div>
		
	{myactions:}
		<div style="margin:20px 0;" class="cart">
			<div class="btn-toolbar dropup" role="toolbar">
				<div class="btn-group">
					<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
						<span class="caret"></span>
					</button>
					<ul class="dropdown-menu pull-left" role="menu">
						{actions::actprint}
					</ul>
				</div>
				{buttons::mybtns}
			</div>
			<script>
				domready( function () {
					Event.one('Controller.onshow', function () {
						Cart.init();
					});
				});
			</script>
		</div>
		{mybtns:}
			<div class="btn-group">
				<a class="act-{act} btn btn-{cls}" data-id="{data.id}" data-crumb="false" onclick="return false"
					href="{link?:link?:actact}" style="text-decoration:none">
					{title}
				</a>
			</div>
		{actprint:}
			<li>
				<a class="act-{act}" style="text-decoration:none"  data-id="{data.id}" 
					data-crumb="false" onclick="return false" href="{link?link?:actact}">
					{title}
				</a>
			</li>
			{actact:}/{crumb}
	{b:}<b>
	{/b:}</b>
	{noProducts:}
		<h3>В заявке нет товаров.</h3>
{dateFormat:}d.m.Y h:i:s
{tableWidthProduct:}
	<table class="table table-striped">
		<tr>
			<th>Позиция</th>
			<th><span class="bg-info">Цена</span></th>
			<th>Количество</th>
			<th>Сумма</th>
		</tr>
		{basket::positionRow}
		<tr><th colspan="3"><a href="/{crumb}/list">Редактировать корзину</a></td><td>{sum:itemcost}</td></tr>
	</table>
{tableWidthProductopt:}
	<table class="table table-striped">
		<tr>
			<th>Позиция</th>
			<th><span class="{merchdyn?:bg-success?:bg-info}">Цена {merchdyn?: оптовая?: розничная}</span></th>
			<th>Количество</th>
			<th>Сумма</th>
		</tr>
		{basket::positionRow}
		<tr><td></td><td></td><td></td><td>{sum:itemcost}</td></tr>
	</table>
	{manage.summary?:widthSummary}
	{manage.deliverycost?:widthDivelery}

	
	{positionRow:}
		<tr>
			<td><a href="/catalog/{producer}/{article}">{Производитель} {Артикул}</a>{change?:star}</td>
			<td>{cost:itemcost}</td>
			<td>{count}</td>
			<td>{sum:itemcost}</td>
		</tr>

	{widthSummary:}
		<div>
			Сумма подтверждёная менеджером: <span>{manage.summary:itemcost}</span>
		</div>
	{widthDivelery:}
		<div>
			Доставка: <span>{manage.deliverycost:itemcost}</span>
		</div>



{adm_root:}
	{data.result?:adm_listPage?:adm_message}
{adm_listPage:}
	<h1>Список заявок <button type="button" class="btn btn-default pull-right" onclick="Cart.refresh()"><span class="glyphicon glyphicon-refresh"></span></button></h1>
	<script>
		domready( function () {
			Event.one('Controller.onshow', function () {
				$('#orderscontrol').tablesorter();
			});
		});
	</script>
	<table id="orderscontrol" class="table table-striped ordersList tablesorter-bootstrap tablesorter-icon">
		<thead>
		<tr>
			<th>Номер</th>
			<th>Клиент</th>
			<th>Статус</th>
			<th>Цена</th>
			<th>Оплата</th>
			<th>Состав</th>
			<th data-date-format="ddmmyyyy">Дата</th>
		</tr>
		</thead>
		<tbody>
			{data.products::adm_row}
		</tbody>
	</table>

	{adm_row:}
		<tr>
			<td>
				<a onclick="Cart.goTop()" href="/cart/admin/{id}">{id}</a>
			</td>
			<td>{email}</td>
			<td>	
				{rule.short}
			</td>
			<td>
				<span style="cursor:pointer" onclick="$(this).next().toggle()" class="{merchdyn?:bg-success?(manage.summary|:bg-info)}">
					{total:itemcost}</span>
					<div style="font-size:10px; text-align:left; display:none;">
						Доставка <b>{manage.deliverycost:itemcost}</b><br>
						Цена товаров по прайсу <b>{sum:itemcost}</b><br>
						Цена товаров со скидкой <b>{manage.summary:itemcost}</b><br>
						Цена к оплате <b>{alltotal:itemcost}</b><br>
						Цена возвращаемая при возврате товара <b>{total:itemcost}</b><br>
					</div>
			</td>
			<td><small>{manage.paid?:adm_paidorder}</small></td>


			<td>
				{basket::adm_product}
			</td>
			<td>
				{~date(:d.m.Y H:i,time)}
			</td>
		</tr>
		{adm_product:} <nobr>{count} <a href="/catalog/{producer}/{article}">{Артикул}</a>{~last()|:comma}</nobr>

{adm_paidorder:}<b>{~cost(manage.paid)} руб.</b> {manage.paidtype=:bank?:банк?:менеджер} {~date(:d.m.Y H:i,manage.paidtime)}
{adm_orderPage:}
	{data.result?data:adm_orderPageContent?:adm_message}

	
{adm_message:}
	<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>

{freezemsg:}<br>Цены зафиксированы {~date(manage.freeze)}
{adm_orderPageContent:}
	<h1>{rule.title}</h1>
	{data.id?order:ordernum}
	<form action="/-cart/orderscontrol.php?save=1" id="adminForm" method="post">
		<div class="disabled">
			<div class="cartcontacts">
				{:orderfields}
				<label>Сообщение для менеджера</label><br> 
				<textarea disabled name="comment" class="form-control" rows="4">{comment}</textarea>
			</div>
			<br><hr><br>
			
			{count?:tableWidthProduct?:noProducts}
			
			<div style="margin-bottom:10px">Итого: <span class="cartsum">{~sum(total,manage.deliverycost|:0):itemcost}</span></div>


			<label>Цена со скидкой<br> 
			<input name="manage.summary" value="{manage.summary}" type="text"></label><br />
			<label>Цена доставки <br> 
			<input name="manage.deliverycost" value="{manage.deliverycost}" type="text"></label><br />
			<label>Сообщение для клиента</label><br>
			<textarea name="manage.comment" class="form-control" rows="4">{manage.comment}</textarea>
			<div class="answer"><b class="alert">{config.ans.msg}</b></div>
		</div>
	</form>
	<h3>{rule.title}</h3>
	{data.id?order:ordernum}
	{data.rule.freeze?:freezemsg}
	<div class="checkbox">
		<label>
			<input type="checkbox" "autosave"="0" onclick="Session.set('dontNotify',this.checked)" name="dontNotify">
			НЕ оповещать пользователя о совершённом действии
		</label>
		<script>
			domready(function(){
				Event.one('Controller.onshow', function () {
					var layer = Controller.ids['{id}'];
					var div = $('#'+layer.div);
					var check=!!Session.get('dontNofify');
					div.find('[name=dontNotify]').val(check);
				});
			});
		</script>
	</div>

	<div class="myactions" data-place="admin">
		{rule.manager:myactions}
	</div>
	
	
	
	
	<script>
		domready(function(){
			Event.one('Controller.onshow', function () {
				var layer = Controller.ids['{id}'];
				var div = $('#'+layer.div);
				var counter = {counter};
				var id = "{state.name}";
				if (id == 'my') id=null;
				var order=Cart.getGoodOrder(id);
				var place=div.find('.myactions').data('place');
				if(!order.rule.edit[place])Cart.blockform(layer);

				Event.handler('Layer.onsubmit', function (layer) {
					if (!layer.showed || counter != layer.counter) return;
					var ans = layer.config.ans;
					Controller.global.set('order');
					Ascroll.go();
				},'',layer);
				
				if(Session.get('manager{data.id}')){
					$('.clearMyDelta').css('fontWeight', 'bold');
				}else{
					$('.clearMyDelta').css('fontWeight', 'normal');
				}
				
				Event.handler('Session.onsync', function () {
					if (!layer.showed || counter != layer.counter) return;
					if (Session.get('manager{data.id}')) {
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
				
				$("input[name=entity]:radio").change(function() {
					if ($("#legal").prop('checked')) {
						$('.legal').slideDown();
					} else {
						$('.legal').slideUp();
					}
				});
				$("input[name=delivery]:radio").change(function() {
					if ($("#delivery").prop('checked')) {
						$('.delivery').slideDown();
					} else {
						$('.delivery').slideUp();
					}
				});
			});
		});
	</script>
{comma:},
{itemcost:}{~cost(.)}&nbsp;<small>руб.</small>
{star:}*
{ordernum:}Номер заявки: <b>{id}</b>{manage.paid?:msgpaidorder}
	{msgpaidorder:}. Оплата <b>{~cost(manage.paid)} руб.</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}