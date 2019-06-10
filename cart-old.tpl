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
		
	</style>
{js:}
	<script>
		domready(function(){
			Cart.init();
		});
	</script>
{LIST:}
	{:css}
	{:listcrumb}
	<div class="cart">
		<h1>{data.order.id?:numorder?:myorder}</h1>
		{data.result?:showlist?:adm_message}
	</div>
	{:js}
	{showlist:}
		{data.order:cartlist}
	{cartlist:}
		<div class="border rounded p-3">
			<div class="d-flex justify-content-between">
				<div>
					<div class="custom-control custom-checkbox">
						<input onclick="$('.showlist :checkbox').prop('checked',$(this).is(':checked')).change();" type="checkbox" class="custom-control-input" name="checkall" id="checkall">
						<label class="custom-control-label" for="checkall">
							Выделенное: </label>
							<span data-param='prodart=' data-id="{data.id}" data-place="{crumb.parent.parent.name}" class="act-clear a">
								Удалить
							</span>
						
					</div>		
				</div>
				<div class="text-right">
					<span data-id="{data.id}" data-place="{crumb.parent.parent.name}" class="cart-search a">Добавить</span>
				</div>
			</div>
			
			<hr>
			<div class="showlist">
				{basket::cartpos}
			</div>
			<div class="d-flex align-items-center justify-content-center justify-content-sm-end">
				<div class="mr-2">Сумма: </div><div style="font-size:120%; font-weight:bold" class="cartsum">{sum:itemcostrub}</div>
			</div>
		</div>
		
		<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
			<div class="mr-sm-3 mx-auto mx-sm-0">{:couponinp}</div>
			<div class="flex-grow-1">
				<p class="text-center text-sm-right {coupon_discount??:d-none}">
					Итого: <b class="carttotal" style="font-size:140%">{total:itemcostrub}</b> 
					<!--<del style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel">{total!sum?sum:itemcostrub}</del>-->
				</p>
				<div class="d-flex text-center text-sm-right flex-column">
					<div><a href="/{crumb.parent}" style="text-decoration:none" class="btn btn-warning">Перейти к {data.order.id?:заявке {data.order.id}?:оформлению заявки}</a></div>
					<div>Займёт не более 3 минут.</div>
				</div>
			</div>
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
					el.width(el.width()).css('display','inline-block');
					$({ 
						n: lastsum
					}).animate({
						n: to 
					}, {
						duration: 500,
						step: function (a) {
							$(el).html(tplcost(a));
						},
						complete:  function(){
							el.width('auto');
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
	{cartpos:}
		<div class="d-flex align-items-sm-center">
			<div>
				<div class="custom-control custom-checkbox">
					<input onchange="$('.act-clear').attr('data-param','prodart='+$('.showlist :checkbox:checked').reduce(function (ak, el){ ak.push($(el).attr('data-prodart')); return ak },[]).join(','))" 
					data-prodart="{:prodart}" type="checkbox" class="custom-control-input" name="check{~key}" id="check{~key}">
					<label class="custom-control-label" for="check{~key}"></label>
				</div>
			</div>
			<div class="mr-3 d-none d-sm-block" style="min-width:70px">
				{images.0?:cartposimg}
			</div>
			<div class="flex-grow-1">
				<div class=""><b><a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{Наименование}</a></b></div>
				<div class="d-flex align-items-center flex-column flex-sm-row">
					{images.0?:cartposimgm}
					<div class="my-2 flex-grow-1">
						{:basket.props}
					</div>
					<div class="my-2 d-flex align-items-center ml-sm-3">
						<div class="mr-2"><input data-cost="{Цена}" style="width:60px" value="{basket[{:prodart}]count}" type="number" min="0" max="999" name="basket.{producer_nick} {article_nick}{:cat.idsp}.count" class="form-control" type="number"></div>
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
{ORDER:}
	{:css}
	{:ordercrumb}
	<div class="cart">
		{data.result?data:orderPageContent?:ordermessage}
	</div>
	{:js}
	{ordermessage:}
		<h1>{data.id}</h1>
		<h1>{data.order.id?:numbasket?:mybasket}</h1>
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
		{data.ismy?:activebutton}
	{activebutton:}
		<div style="margin-top:10px">
			<a href="/cart/orders/my" class="btn btn-success">
				Показать заявку
			</a>
		</div>
	{clearfields:}<span class="float-right a" onclick="$('.cartcontacts input, .cartcontacts textarea').val('').change();">Очистить данные</span>
	{manage:}
		<div style="margin-top:10px; margin-bottom:10px;" class="alert alert-info" role="alert"><b>Сообщение менеджера</b>
				<pre style="margin:0; padding:0; font-family: inherit; background:none; border:none; white-space: pre-wrap">{manage.comment}</pre>
		</div>
	{orderPageContent:}
		<h1>{order.rule.title}</h1>
		{data.result?:showlist?:adm_message}
		{order.status=:active?:clearfields}
		<div class="float-right" title="Последние измения">{~date(:j F H:i,order.time)}</div>
		
		{order.id?order:ordernum}
		<form>
			<div class="cartcontacts">
				{order:orderfields}
				<div>
					<strong>Сообщение для менеджера</strong>
					<div>
						<i>{data.fields.help}</i>
					</div>
					<textarea name="comment" class="form-control" rows="4">{order.comment}</textarea>
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
		
		
		{~length(order.basket)?order:tableWidthProduct?order:noProducts}
		{order.manage.deliverycost?order:widthDivelery}
		
		
		</form>
		<div style="margin-bottom:10px">Итого: <b class="cartsum">{~sum(order.total,order.manage.deliverycost|:0):itemcostrub}</b>{data.order.manage.summary?:totalwarn}</div>
		<!--<h3>{order.rule.title}</h3>
		{data.order.id?order:ordernum}-->
		{order.manage.comment?order:manage}
		<div class="myactions" data-place="orders">
			{order.rule.user:myactions}
		</div>
		
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
			<script>
				domready( function () {
					Event.one('Controller.onshow', function () {
						Cart.init();
					});
				});
			</script>
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
		<h3>В заявке нет товаров</h3>
		<p align="right">
			<a href="/{crumb}/list">Редактировать корзину</a><br>
			<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span>
		</p>
{dateFormat:}d.m.Y h:i:s
{tableWidthProduct:}
	<table class="table table-striped">
		<tr>
			<th>Позиция</th>
			<th>Цена</th>
			<th>Кол<span class="d-none d-sm-inline">ичество</span></th>
			<th class="d-none d-sm-table-cell">Сумма</th>
		</tr>
		{basket::positionRow}
		<tr><td class="d-none d-sm-table-cell"></td><td colspan=3 style="text-align:right">{sum:itemcostrub}</td></tr>
	</table>
	<div style="margin-bottom:10px">
		{data.order.rule.edit[crumb.parent.name]?:basketedit}
	</div>
	{:couponinp}
	
{couponinp:}
	<div style="max-width:250px" class="input-group">
		<input name="coupon" type="text" class="form-control" id="coupon" placeholder="Укажите купон">
		<div class="input-group-append">
		    <button onclick="Cart.action('{crumb.parent.name}', 'sync', {data.order.id});" class="btn btn-secondary" type="button">Активировать</button>
		</div>
	</div>
	<div class="py-2">
		{data.order.coupon_msg}
	</div>
	{*showlist:}
		<div class="usercart" style="margin-top:15px;">		
			{data.order.count?data.order:cartlist?:cartmsg}
		</div>
	{*cartlist:}
		<table style="width:auto" class="table cart">
			{basket::cartpos}
		</table>
		<div class="d-flex justify-content-between mb-3">
			<div style="padding-left:5px"></div>
			<div class="text-right">
				<span data-id="{data.id}" data-place="{crumb.parent.parent.name}" class="cart-search a">Поиск позиций</span><br>
				<span data-id="{data.id}" data-place="{crumb.parent.parent.name}" class="act-clear a" style="clear:both">Очистить корзину</span>
			</div>
		</div>
		<table>
			<tr>
				<td style="padding:5px">
					Итого: <b class="cartsum"></b>
					<del title="Розничная цена" style="margin-left:10px;font-size:18px; color:#999;" class="cartsumdel"></del>
				</td>
			</tr>
		</table>
		<div style="margin-top:10px">
			<a href="/{crumb.parent}" style="text-decoration:none" class="btn btn-success">Перейти к {data.order.id?:заявке {data.order.id}?:оформлению заявки}</a>
		</div>
		{*cartpos:}
			<tbody class="myprice" data-cost="{cost}" data-count="{count}" data-article="{article_nick}" data-id="{item_nick}" data-producer="{producer_nick}">
				<tr class="active">
					<td style="color:gray; vertical-align:middle">{num}</td>
					<td style="vertical-align:middle;" colspan="2">
						<div class="title">
							<a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{producer} {article}</a>
						</div>
						<!--{Наименование}<br>
						{itemrow}-->
					</td>
					<td style="vertical-align:middle;">
						<div style="float:right; margin-right:10px" class="cart">
							<span class="abasket bg-danger" data-place="{crumb.parent.parent.name}" data-order="{data.order.id}" data-producer="{producer_nick}" data-article="{article_nick}" data-id="{item_nick}">
								<span class="pe-7s-close-circle"></span>
							</span>
						</div>
					</td>

				</tr>
				<tr>
					<td rowspan="3">
						<div class="d-none d-sm-block" style="min-width:120px">
							<a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">
								<img class="img-fluid" src="/-imager/?w=140&h=100&src={images.0}&or=-imager/empty.png">
							</a>
						</div>
					</td>
					<td>
						Цена:
					</td>
					<td style="text-align:center">
						<div class="spin"><span class="pe-7s-refresh refresh"></span></div>

					</td>
					<td style="white-space:nowrap;">
						<span class="cost">
							{Цена?Цена:itemcost?:itemnocost}
						</span>
					</td>
				</tr>
				<tr>
					<td style="vertical-align:middle;">Кол<span class="d-none d-sm-inline">ичество</span>:</td>
					<td style="vertical-align:middle; padding-top:0; padding-bottom:0;">
						<input class="form-control form-control-lg" value="{basket[{:prodart}]count}" type="number" min="0" name="basket.{producer_nick} {article_nick}{:cat.idsp}.count"></td>
					<td style="white-space:nowrap; vertical-align:middle">
						<span class="sum" data-article="{article_nick}" data-producer="{producer_nick}" data-id="{item_nick}"></span>
					</td>

				</tr>
				<tr><td colspan="3" style="height:100%"></td></tr>
			</tbody>
		{prodart:}{producer_nick} {article_nick}{:cat.idsp}
{*LIST:}
	{:listcrumb}
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
			width:80px;
			/*padding:1px 5px;*/
		}
		.usercart .img {
			text-align:center;
			vertical-align:top;
			padding:5px 2px;
		}
		.usercart .refresh {
			color:black;
			display:none;
			cursor: pointer;
		}
		.usercart .cartparam {
			margin-bottom:20px;
		}
		.usercart .cartparam td {
			vertical-align: middle;
		}
	</style>
	
	<h1>{crumb.parent.name=:my?:mybasket?:numbasket}</h1>

	{data.result?:showlist?:adm_message}
	{mybasket:}Ваша корзина
	{numbasket:}Корзина {data.order.id}
	{myorder:}Оформление заказа
	{numorder:}Заказ {data.order.id}
	{*showlist:}
		<div class="usercart" style="margin-top:15px;">		
			{data.order.count?data.order:cartlist?:cartmsg}
		</div>		
		
		<script>

			domready(function(){

				
				var tplcost = function (val) {
					return Template.parse('-cart/cart.tpl', val, 'itemcost')
				}
				var calc = function (div, layer) {
					var orderid = layer.crumb.parent.name;
					var place = layer.crumb.parent.parent.name;
					if (orderid == 'my') orderid = '';
					/*var goodorder = Cart.getGoodOrder(orderid);
					Брать данные из разметки HTML
					*/

					var order = Autosave.get(layer, '', { });
					if (!order.basket) order.basket = { };
					var conf = Config.get('cart');
					if (conf.opt) {
						var gorder = Cart.getGoodOrder(orderid);
						if (!gorder.merch) {
							if (gorder.merchdyn) {
								div.find('.cartinfo').html('оптовые цены');
								div.find('.cartblockinfo').removeClass('alert-info').addClass('alert-success');
							} else {
								div.find('.cartinfo').html('розничные цены');
								div.find('.cartblockinfo').removeClass('alert-success').addClass('alert-info');
							}
							div.find('.cartneed').html(tplcost(gorder.need));
						}
						div.find('.sum').each( function () {
							var prodart = $(this).data('producer_nick')+' '+$(this).data('article_nick');
							var id =  $(this).data('id');
							if (id)  prodart += ' ' +id;
							
							var pos = gorder.basket[prodart];
							if (!pos) {
								//$(this).parent().addClass('bg-info').removeClass('bg-success');
							} else if (gorder.merchdyn) {
								$(this).html(tplcost(pos.sumopt));
								//$(this).parent().addClass('bg-success').removeClass('bg-info');
							} else {
								$(this).html(Template.parse('-cart/cart.tpl',pos,'itemcost','sumroz'));
								//$(this).parent().addClass('bg-info').removeClass('bg-success');
							}
						});

						div.find('.myprice').each( function () {
							var prodart = $(this).data('producer_nick')+' '+$(this).data('article_nick');
							var id =  $(this).data('id');
							if (id)  prodart += ' ' +id;
							var pos = gorder.basket[prodart];
							if (!pos) {
								//$(this).find('.cost').parent().addClass('bg-info').removeClass('bg-success');
							} else if (gorder.merchdyn) {
								$(this).find('.cost').html(tplcost(pos['Цена оптовая']));
								//$(this).find('.cost').parent().addClass('bg-success').removeClass('bg-info');
							} else {
								$(this).find('.cost').html(tplcost(pos['Цена розничная']));
								//$(this).find('.cost').parent().addClass('bg-info').removeClass('bg-success');
							}
						});
						
						div.find('.cartsumroz').html(tplcost(gorder.sumroz));
						div.find('.cartsumopt').html(tplcost(gorder.sumopt));
						if (gorder.merchdyn) {
							div.find('.cartsum').html(tplcost(gorder.sumopt));
							//div.find('.cartsum').parent().addClass('bg-success').removeClass('bg-info');
							if (gorder.sumroz != gorder.sumopt) {
								div.find('.cartsumdel').html(tplcost(gorder.sumroz));
							}
						} else {
							div.find('.cartsum').html(tplcost(gorder.sumroz));
							//div.find('.cartsum').parent().addClass('bg-info').removeClass('bg-success');
							div.find('.cartsumdel').html(tplcost(''));
						}
					} else {
						var ordersumroz = 0;
						div.find('.myprice').each( function () {
							var pos = $(this).data();
							if (pos) {
								var prodart = pos.producer+' '+pos.article;
								if(pos.id)  prodart += ' ' +pos.id;
								var count = pos.count;
								if(order.basket[prodart]) count = order.basket[prodart].count;
								var sumroz = pos.cost * count;
								if (!sumroz) sumroz = 0;
								ordersumroz += sumroz;
								$(this).find('.sum').html(tplcost(sumroz));
							}
							//$(this).find('.sum').parent().addClass('bg-info').removeClass('bg-success');
							//$(this).find('.cost').parent().addClass('bg-info').removeClass('bg-success');
						});
						div.find('.cartsumroz').html(tplcost(ordersumroz));
						div.find('.cartsum').html(tplcost(ordersumroz));
						//div.find('.cartsum').parent().addClass('bg-info').removeClass('bg-success');
						div.find('.cartsumdel').html(tplcost(''));
					}
				}
				Event.one('Controller.oncheck', function () {
					var layer = Controller.ids['{id}'];
					//history.replaceState(null,null,'/'+layer.crumb);
					if (layer.crumb.child) Crumb.go('/'+layer.crumb, false);
					
					Event.handler('Layer.onshow', function () {
						var div = $('#'+layer.div);
						var timer;
						calc(div, layer);
						div.find('[type=number]').change( function () {
							div.find('.refresh').show();
							clearTimeout(timer);
							timer = setTimeout( function () {
								div.find('.refresh').click();	
							}, 2000);
						});
						div.find('.refresh').click( function () {
							clearTimeout(timer);
							div.find('.refresh').hide();
							Global.set('cart');
							calc(div, layer);
						});
					}, 'cart', layer);
				});
				Once.exec('{tpl}{tplroot}', function () {
					Event.one('Controller.onshow', function () {
						Event.handler('Session.onsync', function () {
							var layer = Controller.ids['{id}'];
							var orderid = layer.crumb.parent.name;
							var place = layer.crumb.parent.parent.name;
							Cart.sync(place, orderid);
						});
					});
				})
			});
		</script>
{cartmsg:}<p>Корзина пустая. Добавьте в корзину интересующие позиции.
		
		</p>
		<p>Чтобы добавить позицию нужно кликнуть по иконке корзины рядом с ценой в <a href="/catalog">каталог</a>.</p>
		<span data-id="{data.id}" data-place="{crumb.parent.parent.name}" class="cart-search a float-right">Поиск позиций</span>
		<div style="margin-top:10px">
			<a href="/catalog" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
		</div>
{itemnocost:}<a href="/contacts">Уточнить</a>

{basket*:}
	<div id="basket_text">
		В <a href="/cart/order">корзине</a>
		<!--<span class="bold_basket">{data.allcount}</span> {~words(data.allcount,:позиция,:позиции,:позиций)}<br> Сумма <span class="bold_basket">{~cost(data.allsum)} руб.</span>-->
	</div>
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
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="/">Главная</a></li>
		<li class="breadcrumb-item"><a href="/catalog">Каталог</a></li>
		<li class="breadcrumb-item active {data.manager?:text-danger}">Сообщения</li>
		<li class="breadcrumb-item"><a href="/cart/orders">Мои заявки</a></li>
		<li class="breadcrumb-item"><a href="/cart/orders/my">Оформление заказа</a></li>
		<li class="breadcrumb-item"><a href="/cart/orders/my/list">Содержимое корзины</a></li>
	</ol>
	<h1>Сообщения</h1>
	{data.email?:account?:noaccount}

	<p>{~length(data.list)?:showinfo?:Для вас нет важных сообщений.}</p>
	<p>
		В <a href="/cart/orders/my/list">корзине</a> активной заявки <b>{data.order.count}</b> {~words(data.order.count,:позиция,:позиции,:позиций)}.
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
			<b><a href="/user">Вход</a> не выполнен!</b>
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
			<b>Вы менеджер - <a href="/cart/admin">все заявки</a></b>
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
		<li class="breadcrumb-item"><a href="/">Главная</a></li>
		<li class="breadcrumb-item"><a href="/catalog">Каталог</a></li>
		
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Сообщения</a></li>
		<li class="breadcrumb-item active">Мои заявки</li>
		<li class="breadcrumb-item"><a href="/cart/orders/my">Заказ</a></li>
		<li class="breadcrumb-item"><a href="/cart/orders/my/list">Корзина</a></li>
	</ol>
	<h1>Мои заявки</h1>
	{~length(data.orders)?:ordersList?:noOrders}
	<div style="margin-top:10px">
		<a href="/cart/orders/my/list" style="text-decoration:none" class="btn btn-success">Заказ ({data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)})</a>
	</div>
	{noOrders:} <div>В данный момент у вас нет сохранённых заявок с товарами.</div>
	
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
			<label>Контактное лицо{data.fields.fio?:strФИО} <span class="req">*</span></label>
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
	{isdisabled:}{rule.edit[crumb.parent.name]|:disabled}

{basketedit:}
	<p align="right">
		<a href="/{crumb}/list">Редактировать корзину</a><br>
		<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span><br>
		<span data-id="{data.order.id}" data-place="{crumb.parent.name}" class="act-clear a">Очистить корзину</span>
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
		<li class="breadcrumb-item"><a href="/">Главная</a></li>
		<li class="breadcrumb-item"><a href="/catalog">Каталог</a></li>
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Сообщения</a></li>
		<li class="breadcrumb-item active">Все заявки</li>
	</ol>
	{data.result?:adm_listPage?:adm_message}
	{longlistlink:}<a href="/cart/admin/all">Готовые заявки</a>
	{shortlistlink:}<a href="/cart/admin">В работе</a>
	{adm_listPage:}
		<div class="float-right">{crumb.child.name=:all?:shortlistlink?:longlistlink}</div>
		<h1>Все заявки</h1>
		
		
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
{ADMORDER:}
	{:ordercrumb}
	{data.result?data.order:adm_orderPageContent?:adm_message}
	{adm_orderPageContent:}
		<div class="float-right" title="Последние измения">{~date(:j F H:i,time)}</div>
		<h1>{rule.title}</h1>
		{id?:ordernum}
		{(data.place=:admin&status=:active)?:adm_orderinfo?:adm_orderinputs}
	{msg_samples:}
		<span class="a" onclick="var t=$('[name=\'manage.comment\']'); t.val(t.val()+$(this).next().html()).change();">{~key}</span><pre style="display:none">{.}
</pre>{~last()|:comma}
	{adm_orderinputs:}
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
		<p>Письмо клиенту {emailtime?:was?:no}</p>
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
					
					if (Session.get('manager{data.id}')) {
						$('.clearMyDelta').css('fontWeight', 'bold');
					} else {
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
	{no:}<b>ещё не отправлялось</b>{was:}было <b>{~date(:j F H:i,emailtime)}</b>
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
{listcrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="/">Главная</a></li>
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заявка {crumb.parent.name=:my?:Активная?crumb.parent.name}</a></li>-->
		<li class="breadcrumb-item active">Содержимое корзины</li>
	</ol>
{ordercrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="/">Главная</a></li>
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item active">Заявка {crumb.name=:my?:Активная?crumb.name}</li>-->
		<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb}/list">Содержимое корзины</a>
		<li class="breadcrumb-item active">Оформление заказа</li></li>
	</ol>
{itemcost:}{~cost(.)}<span class="d-none d-sm-inline">&nbsp;<small>{:extend.unit}</small></span>
{itemcostrub:}{~cost(.)}&nbsp;<small>{:extend.unit}</small>
{star:}<span title="Позиция в каталоге изменилась">*</span>
{ordernum:}Номер заявки: <b>{id}</b>{manage.paid?:msgpaidorder}
	{msgpaidorder:}. Оплата <b>{~cost(manage.paid)} руб.</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}
{adm_message:}
	<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
{PRINT:}
<ol class="breadcrumb noprint">
	<li class="breadcrumb-item"><a href="/">Главная</a></li>
	<li class="breadcrumb-item"><a href="/catalog">Каталог</a></li>
	<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Сообщения</a></li>
	<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заявки</a></li>
	<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заказ {crumb.parent.name=:my??crumb.parent.name}</a></li>
	<li class="breadcrumb-item active">Версия для печати</li>
</ol>
<pre style="border:none;"><h1 style="margin-bottom:0px">Заказ {id}</h1>
ФИО: {name}
Почта: {email}
Телефон: {phone}
Паспорт: {passport}
Адрес: {address}{time?:pr-time}

===== {count} {~words(count,:позиция,:позиции,:позиций)} ====={basket::pritem}

Итого: {~cost(sum)}&nbsp;руб.{manage.deliverycost?:pr-deliver}
<!--Всего: {~cost(alltotal)}&nbsp;руб.-->

==== Сообщение =====
<span style="white-space: pre-wrap;">{comment}</span>

====================
<span style="white-space: pre-wrap;">{manage.comment}</span>
</pre>
{pritem:}
{~key}
{count} по {~cost(cost)}&nbsp;руб. = {~cost(sum)}&nbsp;руб.
{pr-time:}
Дата изменений: {~date(:H:i j F Y,time)}
{pr-deliver:}
Доставка: {~cost(manage.deliverycost)}&nbsp;руб.