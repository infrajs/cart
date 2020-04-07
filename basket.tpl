{model::}-catalog/model.tpl
{root:}
	<div class="cartbasket">
		<style scoped>
			.cartbasket {
				padding:5px 10px;
				/*height:100%;
				font-size:90%;
				border-radius: 2px;*/
			}
			.cartbasket #basket_text a {
				
				text-decoration: underline;
			}
			.cartbasket #basket_text a:hover {
				
			}
			
			@media (max-width:767px) {
				.cartbasket {
					padding:10px 20px;
				}
			}
		</style>
		<div id="basket_text" style="margin-top:-5px">
			<a href="/cart/orders" class="float-right" style="font-size:42px;line-height:42px; display:block">
				<span class="pe-7s-cart"></span>
			</a>
			<span class="bold_basket">{data.user.email?:user?:reg}</span>
			<div>
				{data.user.email?:umenu}
				<nobr>В <a href="/cart/orders/my/list">корзине</a> <b><span>{data.order.count|:str0}</span>&nbsp;{~words(data.order.count,:позиция,:позиции,:позиций)}</b></nobr>
			</div>
			<div style="clear:both"></div>
		</div>
	</div>
	{str0:}0
	{umenu:}
		<a onclick="Cart.goTop()" href="/cart/orders/my">{Cart.lang(:Заказ)}</a> |
		<a data-crumb="false" onclick="Cart.logout(); return false;" href="/user/logout?back=ref">{Cart.lang(:Выход)}</a><br>
	{reg:}<a href="/user/signin?back=ref">{Cart.lang(:Гость)}</a>
	{user:} <b><a href="/user">{data.user.email}</a></b>

{pr:} {.}
{fields::}-cart/fields.tpl

{*:}
	{~obj(:title,:Корзина,:content,:showcartlist,:num,:1):accordCard}
	{~conf.cart.coupon?~obj(:title,:Купон,:content,:couponinfoorder,:num,:2):accordCard}
{ORDER:}
	{~obj(:title,:Получатель,:content,:fiocard,:num,:3):accordCard}
	{~obj(:title,:Доставка,:content,:transcardsimple,:num,:4):accordCard}
	{~conf.cart.pay?~obj(:title,:Оплата,:content,:paycard,:num,:5):accordCard}
	{accordCard:}
		<div class="card" data-num="{num}">
			<div class="card-header font-weight-bold" id="heading{num}" data-toggle="collapse" data-target="#collapse{num}">
				<!--<span class="badge badge-light text-dark badge-pill">{num}</span>-->
				<span class="a" aria-expanded="true" aria-controls="collapse{num}">
				{title}
				</span>
			</div>
			<div id="collapse{num}" class="collapse show" aria-labelledby="heading{num}" data-*parent="#accordionorder">
				<div class="card-body">
					{content}
				</div>
			</div>
		</div>