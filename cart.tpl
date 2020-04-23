	{carttime:}
		<div style="margin-bottom:5px">
		Последний раз заказ отправлялся<br>{~date(:j F Y,data.carttime)} в {~date(:H:i,data.carttime)}<br>
		</div>
	{cartanswer:}
		<pre>{mail}</pre>
	{js:}
		<script>
			domready(function(){
				Event.one('Controller.onshow', function () {
					Cart.init();
				});
			});
		</script>
	{LIST:}
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
					<p class="text-center text-sm-right {data.order.coupon_data.result??:d-none}">
						Итого со скидкой: <b class="carttotal" style="font-size:140%">{total:itemcostrub}</b> 
					</p>
					<div class="d-flex text-center text-sm-right flex-column">
						<div><a href="/{crumb.parent}" style="text-decoration:none" class="btn btn-success">Перейти к {data.order.id?:заказу {data.order.id}?:оформлению заказа}</a></div>
						<div>Займёт не более 3 минут.</div>
					</div>
				</div>
			</div>
		{couponinfoorder:}
			<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
				<div class="mr-sm-3 mx-auto mx-sm-0">{data.order:couponinp}</div>
				<div class="flex-grow-1">
					<p class="text-center text-sm-right {data.order.coupon_data.result??:d-none}">
						Итого со скидкой: <b class="carttotal" style="font-size:140%">{data.order.total:itemcostrub}</b>
					</p>
				</div>
			</div>
		{showcartlist:}
			{order:cartlist}
		{cartlist:}
			{:model.css}
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
				<div class="mr-2">Сумма{coupon_data.result?:nodiscount}: </div><div style="font-size:120%; font-weight:bold" class="cartsum">{sum:itemcostrub}</div>
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

					var proc = 0;
					var calc = function () {
						if (proc) return;
						proc = 1;
						setTimeout(()=>{
							var zero = false;
							if (!$.fn.reduce) $.fn.reduce = [].reduce;
							var sum = $('.cart [type=number]').reduce(function(ak, el){
								var cost = Number($(el).attr('data-cost'));
								if (!cost) zero = true;
								ak+=el.value * cost;
								return ak;
							}, 0);

							if (zero) sum = 0;
							set('.cartsum', sum);

							var total = $('.cart [type=number]').reduce(function(ak, el){
								var cost = $(el).attr('data-coupcost');
								if (!cost) cost = $(el).attr('data-cost');
								var sum = el.value * cost;
								set($(el).parents('.cartpos').find('.coupsum'), sum);
								//$(el).parents('.cartpos').find('.coupsum').html(tplcost(sum));
								ak+=sum;
								return ak;
							}, 0);
							
							if ({coupon_data.result?:true?:false}) {
								//var total = sum * (1-{coupon_discount|:0});
								set('.carttotal', total);
							} else {
								set('.carttotal', sum);
								$('.carttotal').html(tplcost(sum));
							}
							proc = 0;
							Global.set('cart');
						},1);
					}
					
					$('.cart [type=number]').change(calc);
				});
			</script>
			{false:}0
			{true:}1
		{cartlistborder:}
			<div class="border rounded p-3">
				{:cartlist}
			</div>
		{badgecoupon:}&nbsp;<span title="Скидка по купону {Купон}" class="badge badge-pill badge-danger">-{~multi(Скидка,:100)}%</span>
		{cartpos:}
			<div class="d-flex cartpos">
				<div style="{:ishidedisabled}">
					<div class="custom-control custom-checkbox">
						<input onchange="if (!$.fn.reduce) $.fn.reduce = [].reduce; $('.act-clear').attr('data-param','prodart='+encodeURIComponent(encodeURIComponent($('.showlist :checkbox:checked').reduce(function (ak, el){ ak.push($(el).attr('data-prodart')); return ak },[]).join(','))))" 
						data-prodart="{~key}" type="checkbox" class="custom-control-input" name="check[{~key}]" id="check{~key}">
						<label class="custom-control-label" for="check{~key}">&nbsp;</label>
					</div>
				</div>
				<div class="mr-3 d-none d-lg-block" style="min-width:70px">
					{images.0?:cartposimg}
				</div>
				<div class="flex-grow-1">
					<div>
						<div class="float-right">{:model.badgenalichie}{coupon:badgecoupon}</div>
						<b>{change:star} <a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">
							{Наименование}</a>
						</b>
					</div>
					<div class="d-flex flex-column flex-lg-row">
						{images.0?:cartposimgm}
						<div class="my-2 flex-grow-1">
							{:model.CART-props}
						</div>
						<div class="my-2 d-flex flex-column ml-lg-3">
							<div style="min-width:70px;" class="text-lg-right">
								<div><del>{coupcost?Цена:itemcostrub}</del></div>
								{(coupcost|Цена):itemcostrub}
							</div>
							<div class="my-2"><input {:isdisabled} data-coupcost="{coupcost}" data-cost="{Цена}" style="width:5em" value="{basket[{:prodart}]count}" type="number" min="0" max="999" name="basket.{producer_nick} {article_nick}{:cat.idsp}.count" class="form-control" type="number"></div>
							<div style="min-width:70px;" class="text-lg-right">
								<b class="coupsum">{(coupsum|sum):itemcostrub}</b>
							</div>
						</div>
					</div>
				</div>
			</div>
			<hr>
			{nodiscount:} <nobr>без скидки</nobr>
			{cartposimg:}
				<a href="/{:cat.pospath}">
					<img class="img-thumbnail" src="/-imager/?w=60&crop=1&h=60&src={images.0}&or=-imager/empty.png">
				</a>
			{cartposimgm:}
				<a href="/{:cat.pospath}" class="my-2 mr-3 d-bock d-sm-none">
					<img class="img-thumbnail" src="/-imager/?h=100&src={images.0}&or=-imager/empty.png">
				</a>
	{ADMORDER:}
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
		{sbrfpay:}
			{orderStatus=:2?:sbrfpaygood}
		{2:}2
		{sbrfpaygood:}
			<p>{orderDescription}</p>
			<table style="width:auto" class="table table-sm table-striped">
				<tr><th>Оплачено</th><td>{~date(:d.m.Y H:i,date)}</td></tr>
				<tr><th>Сумма</th><td>{~cost(total)}{:model.unit}</td></tr>
			</table>
		{orderPageContent:}
			<div class="float-right" title="Последние измения">{~date(:j F H:i,order.time)}</div>
			<h1>{order.rule.title} {order.id}</h1>
			{order.manage.comment?order:showManageComment}
			{order.sbrfpay.info:sbrfpay}
			<form>
				<div class="accordion" id="accordionorder">
					{:basket.ORDER}
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
						/*var list = Autosave.get(layer, 'accordion', {~json(order.accordion)});
						if (!list) {
							list = { };
							list[3] = true; //Пользователь
						}
						list[4] = true; //Доставка
						var first = true;
						for (num in list) {
							//if (!first) Ascroll.once=false;
							first = false;


							$('.accordion').find('[data-num='+num+'] .card-header').click();
						}*/
					});
				})
			</script>
			<div class="my-3 mb-4 row">
				<div class="col-sm-6">
					<div>Комментарий к заказу</div>
					<textarea {:isdisabled} name="comment" class="form-control" rows="3">{order.comment}</textarea>
				</div>
				<div class="col-sm-6">
					<div>Звонок менеджера</div>
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
			{order:info}
			{crumb.parent.name=:admin?:adminactions?:useractions}
			<div style="clear:both"></div>
		{info:}
			<div class="alert alert-secondary">
				{:basketresume}
				<p>{:amount}</p>
			</div>
		{useractions:}
			<style>
				.act-sbrfpay {
					display: none
				}
			</style>

			<div class="myactions" data-place="orders">
				{order.rule.user:myactions}
			</div>
		
			<script async type="module">
				let div = document.getElementById('{div}')
				let cls = cls => div.getElementsByClassName(cls)
				import('/vendor/akiyatkin/load/Fire.js').then(async obj => {
					let Fire = obj.default
					Fire.hand(Cart, 'choicepay', async (value) => {
						let is = (value == 'Оплатить онлайн')
						for (let act of cls('act-sbrfpay')) act.style.display = 'none'
						for (let act of cls('act-check')) act.style.display = 'block'
						if (!is) return	
						
						/*let Load = (await import('/vendor/akiyatkin/load/Load.js')).default

						let arg = { 
						}
						let ans = Load.on('json', '-sbrf/?'+Load.param(arg))*/
						for (let act of cls('act-check')) act.style.display = 'none'
						for (let act of cls('act-sbrfpay')) act.style.display = 'block'
					})
				})
			</script>
		{adminactions:}

			<div class="myactions" data-place="admin">
				<p>Письмо клиенту {order.emailtime?:wasemail?:noemail}</p>
				{order.rule.manager:myactions}
			</div>
		{transcardsimple:}
		<div class="row">
			<div class="col-12">
				<div class="form-group">
					<label>Адрес</label>
					<input {:isdisabled} type="text" name="transport.address" value="{data.order.transport.address}" class="form-control" placeholder="">
				</div>
			</div>
			<div class="col-12">
				<div class="form-group">
					<label>Серия и номер паспорта для транспортной компании</label>
					<input {:isdisabled} type="text" name="transport.passeriya"  value="{data.order.transport.passeriya}" class="form-control">
				</div>
			</div>
		</div>
		{paycardsimple:}
			<div class="row">
				<div class="col-12">
					<div class="form-group">
						<label>Выберите способ оплаты{:req}</label>
						<select {:isdisabled} value="{transport.cargo}" name="transport.cargo" class="custom-select form-control">
							<option></option>
							<option {(:Банк):caropt}>Банковский перевод для юр.лиц</option>
							<option {(:Наличные):caropt}>Оплата картой VISA или MASTERCARD</option>
							<option {(:Самовывоз):caropt}>Оплата при получении товара</option>
							<option {(:Самовывоз):caropt}>Оплата в магазине</option>
						</select>
					</div>
				</div>
				<div class="col-12">
					<div class="form-group">
						<label>Дополнительная информация</label>
						<textarea name="pay.paycomment" class="form-control">{data.order.pay.paycomment}</textarea>
					</div>
				</div>
			</div>
			{caropt:}{data.order.transport.cargo=.?:selected} value="{.}" 
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
									if (val == payvalue) $(this).click(); //отменили выбор
								});
							}
							
							pcard.find('.item').each(function(){
								var val = $(this).data('value');
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
{fiocard:}
	<div class="cartcontacts row">
			<div class="col-sm-4 order-sm-2">
				{data.place=:orders?(data.user.email?:fiouser?:fioguest)}
			</div>
			<div class="col-sm-8 order-sm-1">
				<div class="form-group">
					<label>ФИО{:req}</label>
					<input {:isdisabled} type="text" name="name" value="{data.order.name}" class="form-control" placeholder="">
				</div>
				<div class="form-group">
					<label>Телефон{:req}</label>
					<input {:isdisabled} type="tel" name="phone"  value="{data.order.phone}" class="form-control" placeholder="+79270000000">
				</div>
				<div class="form-group">
					<label>Email{:req}</label>
					<input {:isdisabled} type="email" name="email" value="{data.order.email|data.user.email}" class="form-control" placeholder="Email">
				</div>
			</div>
			
		</div>
		{ans:config.ans}
		{fioadmin:}
		{fiouser:}<b>Вы авторизованы</b><p>Ваш аккаунт <b style="display:block; max-width:200px; text-overflow: ellipsis; white-space: nowrap; overflow: hidden">{data.user.email}</b></p>
		{fioguest:}<b>Уже покупали у нас?</b>
		<p><a href="/user/signin?back=ref">Авторизуйтесь</a>, чтобы не заполнять форму повторно.</p>
	{transinfo:}
			<div data-value="{~key}" class="iteminfo">{:basket.fields.{tpl}}</div>
	{payinfo:}
			<div data-value="{~key}" class="iteminfo"><div class="m-1 alert border more">{:basket.fields.{tpl}}</div></div>
	{jsitem:}
		//< script>
		Event.one('Controller.onshow', function (){
			var div = $('.'+name+'card');
			var layer = Controller.ids["{id}"];
			
			if (name == 'pay') var value = Autosave.get(layer,name+'.choice','{data.order.pay.choice}');
			else var value = Autosave.get(layer,name+'.choice','{data.order.transport.choice}');

			var first = false;

			div.find('.item').click( function (){
				if (first && !{data.order.rule.edit[data.place]?:true?:false}) return;
				first = true;
				
				
				import('/vendor/akiyatkin/load/Fire.js').then(async obj => {
					let Fire = obj.default
					div.find('.item.active').not(this).removeClass('active');
					
					let value = $(this).data('value');
					Fire.fire(Cart, 'choice' + name, value)
					
					

					if ($(this).is('.active')) {
						value = false;
						$(this).removeClass('active');
						Autosave.set(layer, name+'.choice');
					} else {
						$(this).addClass('active');
						Autosave.set(layer, name+'.choice', value);
					}
					

					div.find('.iteminfo').hide();
					if (value) div.find('.iteminfo').each( function () {
						if ($(this).data('value') == value) {
							$(this).fadeIn();
						}
					});
					Autosave.loadAll(layer);
				})
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
		//< /script>
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
{COUPONCHECK:}
	<div style="max-width: 300px;" class="input-group">
		<input name="coupon" type="text" class="form-control" placeholder="Купон">
		<div class="input-group-append">
		    <button class="btn btn-secondary" onclick="
		    	var name = $('[name=coupon]').val();
		    	var coupon = Load.loadJSON('-cart/coupon?name='+name);
		    	$('#coupinfo').html(Template.parse('-cart/cart.tpl',coupon,'coupinfo'));
		    " type="button">Проверить</button>
		</div>
	</div>
	<div class="py-2" id="coupinfo"></div>
	{coupinfo:}
		{result?:coupinfoshow?:coupinfoerr}
	{coupinfoerr:}{Купон?:coupinfoerr1?:coupinfoerr2}
		{coupinfoerr1:}<div class="alert alert-danger"><b>{Купон}</b> &mdash; купон не найден или устарел.</div>
		{coupinfoerr2:}<div class="alert alert-danger">Укажите код купона.</div>
	{coupinfoshow:}<div class="alert alert-success">
			<b>{Купон}</b> &mdash; купон найден. Скидка до <b>{~multi(Скидка,:100)}%</b>. 
			<br>Скидка не действует на товары участвующие в других акциях и распродажах. 
			{(Производители|Группы)?:clim}
			<!--<br>Точную стоимость укажет менеджер после проверки.-->
		</div>
	{clim:}<br>Есть ограничения по группам и производителям.
	{cprod:}<br>Производители: <b>{Производители}</b>.
	{cgroup:}<br>Группы: <b>{Группы}</b>.
	{100:}100
	{d-none:}d-none
	{couponinp:}
		<div style="max-width: 300px;" class="input-group">
			<input name="coupon" {:isdisabled} value="{data.order.coupon}" type="text" class="form-control" id="coupon" placeholder="Укажите купон">
			<div class="input-group-append">
			    <button onclick="Cart.action('{crumb.parent.name}', 'sync', '{data.order.id}');" class="btn btn-secondary" type="button">Активировать</button>
			</div>
		</div>
		<div class="py-2">
			{coupon_data:coupinfo}
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
		<!--<p><a href="/cart/orders">Мои заказы</a></p>-->
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
			{prorder:}{~key?:br}<a href="/cart/orders/{id}">{id}</a> <nobr>от {~date(:d.m.Y,time)}</nobr> <nobr>на <b>{~cost(total)}</b>&nbsp;руб.</nobr>
		{br:}<br>
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
	{model::}-catalog/model.tpl
	{basket::}-cart/basket.tpl


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
		<li class="breadcrumb-item"><a href="/cart/{data.place}/{data.order.id|:my}">Оформление заказа {data.order.id}</a></li>
	</ol>
{utilcrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		{data.place=:admin?:liallorder}
		<li class="breadcrumb-item"><a class="{data.place=:admin?:text-danger}" href="/cart/{data.place}/{data.order.id|:my}/list">Содержимое корзины</a>
		<li class="breadcrumb-item"><a href="/cart/{data.place}/{data.order.id|:my}">Оформление заказа {data.order.id}</a></li>
		<li class="breadcrumb-item active">{.}</li>
	</ol>
{ordercrumb:}
	{:usersync}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item active">Заявка {crumb.name=:my?:Активная?crumb.name}</li>-->
		{data.place=:admin?:liallorder}
		<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb}/list">Содержимое корзины</a>
		<li class="breadcrumb-item active">Оформление заказа {data.order.id}</li>
	</ol>
	{liallorder:}<li class="breadcrumb-item"><a class="{data.place=:admin?:text-danger}" href="/cart/{data.place}">{data.place=:admin?:Все?:Мои} заказы</a></li>
	{itemcost:}{~cost(.)}<span class="d-none d-sm-inline">&nbsp;<small>{:model.unit}</small></span>
	{itemcostrub:}{~cost(.)}&nbsp;<small>{:model.unit}</small>
	{star:}<span class="req" title="Позиция в каталоге изменилась">*</span> 
	{req:} <span class="req">*</span>
	{ordernum:}Номер заказа: <b>{id}</b>{manage.paid?:msgpaidorder}
		{msgpaidorder:}. Оплата <b>{~cost(manage.paid)} руб.</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}
	{adm_message:}
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
{PRINT:}
	<ol class="breadcrumb noprint">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заказы</a></li>
		<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заказ {crumb.parent.name=:my??crumb.parent.name}</a></li>
		<li class="breadcrumb-item active">Версия для печати</li>
	</ol>
	<h1>Заказ {id}{time:ot}</h1>
	{:printorder}
	{ot:} от {~date(:d.m.Y,.)}
{printorder:}
	<b>ФИО</b>: {name}<br>
	<b>Почта</b>: {email}<br>
	<b>Телефон</b>: {phone}<br>
	{call?:pr-call}
	{time?:pr-time}
	{transport:iprinttr}
	{pay:iprintpay}
	<hr>
	<p>
		<b>{count} {~words(count,:позиция,:позиции,:позиций)}</b>
	</p>
	{:basketresume}
	<p>{:amount}</p>
	{comment?:prcom}
	{manage.comment?:prcomm}
	<hr>
{basketresume:}
	{basket::model.PRINT-item}
{amount:}
	<p>
		Стоимость{coupon?:nodiscount}: <b>{~cost(sum)}&nbsp;руб.</b><br>
		{coupon?:prcoupon}
	</p>
{prcom:}
	
		Комментарий:
		<pre style="margin-top:0"><b><i>{comment}</i></b></pre>
	
{prcomm:}
	
		Комментарий менеджера:
		<pre style="margin-top:0"><b><i>{manage.comment}</i></b></pre>
	
{pr-call:}<b>Перезвонить</b>: {call=:yes?:yescall?(call=:no?:nocall)}<br>
{yes:}yes
{no:}no
{yescall:}да
{my:}my
{nocall:}звонок не требуется
{iprinttr:}
	<b>Доставка</b>: {choice} 
		{choice=:strПочта1?:rowПочта1}
		{choice=:strПочта?:rowПочта}
		{choice=:strТраспорт?:rowТраспорт}
		{choice=:strКурьер?:rowКурьер}
		{choice=:strВывоз?:rowВывоз}
	
	
	{strПочта:}Почта России
	{rowПочта:}{index:pr} {region:pr} {city:pr} {street:pr} {house:pr} {kv:pr}
	
	{strПочта1:}Почта России <nobr>1 класс</nobr>
	{rowПочта1:}{:rowПочта}

	{strТраспорт:}Транспортные компании
	{rowТраспорт:}{region:pr} {city:pr} {cargo:pr} {passeriya:pr} {pasnumber:pr}

	{strКурьер:}Доставка курьером
	{rowКурьер:}{courier:pr} {:rowПочта}

	{strВывоз:}Пункты самовывоза <nobr>в Тольятти</nobr>
	{rowВывоз:}{self:pr}

{pr:} {.}
{iprintpay:}
	<div><b>Оплата</b>: {choice}</div>
{iprinte:}
	{.}{~last()??:comma}
{comma:}, 
{iprint:}
	{~key}: {.}<br>
{prcoupon:}
	Купон: <b>{coupon}</b><br>
	Итого со скидкой: <b>{~cost(total)}&nbsp;руб.</b><br>
{pr-time:}
	<b>Дата изменений</b>: {~date(:H:i j F Y,time)}<br>
{pr-deliver:}
	Доставка: <b>{~cost(manage.deliverycost)}&nbsp;руб.</b><br>