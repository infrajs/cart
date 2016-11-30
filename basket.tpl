<div class="cartbasket">
	<style scoped>
		.cartbasket {
			padding:5px 10px;
			height:100%;
			font-size:90%;
			border-radius: 2px;
		}
		.cartbasket #basket_text a {
			
			text-decoration: underline;
		}
		.cartbasket #basket_text a:hover {
			
		}
	</style>
	<div id="basket_text">
		<a href="/cart/orders/my/list" class="pull-right" style="font-size:42px; display:block">
			<span class="pe-7s-cart"></span>
		</a>
		<span class="bold_basket">{data.user.email?:user?:reg}</span>
		<div>
			{data.user.email?:umenu}
			В <a onclick="Cart.goTop()" href="/cart/orders/my/list">корзине</a> <b><span class="bold_basket">{data.order.count}</span> {~words(data.order.count,:позиция,:позиции,:позиций)}</b>
		</div>
	</div>
</div>
{umenu:}
	<a onclick="Cart.goTop()" href="/cart/orders">Мои заявки</a> |
	<a class="signout" onclick="Cart.goTop()" href="/user/signout">Выход</a><br>
	<script>
		domready(function(){
			$('.signout').click(function(){
				infra.session.logout();
				infrajs.global.set(['cat_basket',"sign"]);
				infra.session.syncNow();
				Cart.goTop();

			});
		});
	</script>
{reg:}<a onclick="Cart.goTop()" href="/user/signin">Гость</a>
{user:}{data.order.merch?:icomerch?:icouser} <a onclick="Cart.goTop()" href="/user">{data.user.email}</a>
{icouser:}<span title="Розничный покупатель" class="glyphicon glyphicon-user"></span>
{icomerch:}<span title="Оптовый покупатель" class="glyphicon glyphicon-briefcase"></span>
