{root:}
<div class="client">
	<style>
		.client label {
			margin-top:5px;
			text-align: left;
			font-size: 14px;
			padding-top: 5px;
		}
		.client label span {
			color:red;
		}
		.client form {
			padding-bottom: 5px;
		}
		.client .answer {
			width: 290px;
		}
		.cartcontacts input {
			width: 290px;
			height: 18px;
			padding-top: 2px;
			border: 1px solid #7f9db9;
			margin: 0 auto;
			margin-bottom:10px;
			margin-top:2px;
		}
		.cartcontacts textarea {
			width: 290px;
			height:102px;
			border: 1px solid #7f9db9;
		}
		.client .submit {
			margin-top:20px;			
			font-size:14px;
			padding: 5px 10px;
		}
	</style>
	<div id="usermenu"></div>
	<!--<div class="answer">
		<b class="alert">{config.ans.msg}</b>
	</div>-->
	<div id="cart">
	</div>
	
	<script>
		infra.when(infrajs,'onshow',function(){
			var layer=infrajs.getUnickLayer('{unick}');
			var div=$('#'+layer.div);
			var counter={counter};
			infra.require('-cart/cart.js');
			infra.listen(layer,'onsubmit',function(layer){
				if(!layer.showed||counter!=layer.counter)return;
				var ans=layer.config.ans;
				infrajs.global.set(['cat_basket','order']);
				cart.goTop();
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
{cart:}
	<style>
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
		infra.when(infrajs,'onshow',function(){
			var layer=infrajs.getUnickLayer('{unick}');
			var div=$('#'+layer.div);

			infra.require('-cart/cart.js');
			cart.calc(div);
			div.find('[type=number]').change(function(){
				cart.calc(div);
			});

			div.find('.posremove').click(function(){
				var prodart=$(this).data('producer')+' '+$(this).data('article');
				infra.session.set(['user','basket',prodart]);
				infrajs.global.set('cat_basket');
				infra.session.syncNow();
				infrajs.check();
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
			<a onclick="cart.goTop();" href="?office/orders/my" style="text-decoration:none" class="btn btn-success">Перейти к оформлению заявки</a>
		</div>
	{cartpos:}
		<tr class="active">
			<td style="color:gray; vertical-align:middle">{num}</td>
			<td style="vertical-align:middle">
				<div class="title">
					
					<a href="?Каталог/{Производитель}/{article}"><nobr>{Производитель}</nobr> <nobr>{Артикул}</nobr></a>

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
				<a href="?Каталог/{Производитель}/{article}">
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
			<a href="?Каталог/Каталог" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
		</div>
{itemcost:}{~cost(.)} <small>руб.</small>
{itemnocost:}<a style="color:white" href="?Контакты менеджеров">Уточнить</a>
{basket:}
	<div id="basket_text">
		В <a href="?Каталог/Корзина">корзине</a>
		<!--<span class="bold_basket">{data.allcount}</span> {~words(data.allcount,:позиция,:позиции,:позиций)}<br> Сумма <span class="bold_basket">{~cost(data.allsum)} руб.</span>-->
	</div>