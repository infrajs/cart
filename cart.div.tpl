<style scoped>
	#basket {
		width: 100%;
		height: 60px;
		padding:5px 10px;
		background-image: url('images/basket.png');

		background-position:right center;
	    background-repeat: no-repeat;
		color:white;
		background-color:#009ec3;
	}
	#basket_text a {
		color: white;
		text-decoration: underline;
	}
	#basket_text a:hover {
		color:#Ffd6c5;
	}
	/*#basket_text {
		color: white;
		font: 14px "Open sans", sans-serif;
		position: relative;
		top: 4px;
		left: 10px;
	}


	#basket_text a:hover {
		color:#Ffd6c5;
	}
	.bold_basket {
		font-weight: bold;
	}*/
</style>
<div id="basket_text">
	<script>
		infra.require('-cart/cart.js');
	</script>
	<span class="bold_basket">{data.user.email?:user?:reg}</span>
	<div style="font-size:80%">
		{data.user.email?:umenu}
		В <a onclick="cart.goTop()" href="?office/cart">корзине</a> <span class="bold_basket">{data.count}</span> {~words(data.count,:позиция,:позиции,:позиций)}
	</div>
</div>
{umenu:}
	<a onclick="cart.goTop()" href="?office/orders">Мои заявки</a> |
	<a class="signout" onclick="cart.goTop()" href="?office/signout">Выход</a><br>
	<script>
		$('.signout').click(function(){
			infra.session.logout();
			infrajs.global.set(['cat_basket',"sign"]);
			infra.session.syncNow();
			cart.goTop();

		});
	</script>
{reg:}<a onclick="cart.goTop()" href="?office/signin">Гость</a>
{user:}{data.merch?:icomerch?:icouser} <a onclick="cart.goTop()" href="?office">{data.user.email}</a>
{icouser:}<span title="Розничный покупатель" class="glyphicon glyphicon-user"></span>
{icomerch:}<span title="Оптовый покупатель" class="glyphicon glyphicon-briefcase"></span>
