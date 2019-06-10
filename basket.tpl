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
		<div id="basket_text">
			<a href="/cart/orders" class="float-right" style="font-size:42px;line-height:42px; display:block">
				<span class="pe-7s-cart"></span>
			</a>
			<span class="bold_basket">{data.user.email?:user?:reg}</span>
			<div>
				{data.user.email?:umenu}
				В <a href="/cart/orders/my/list">корзине</a> <b><span class="bold_basket">{data.order.count|:str0}</span>&nbsp;{~words(data.order.count,:позиция,:позиции,:позиций)}</b>
			</div>
			<div style="clear:both"></div>
		</div>
	</div>
	{str0:}0
	{umenu:}
		<a onclick="Cart.goTop()" href="/cart/orders/my">{Cart.lang(:Заказа)}</a> |
		<a class="signout" onclick="Cart.goTop()" href="/user/logout">{Cart.lang(:Выход)}</a><br>
		<script>
			domready(function(){
				$('.signout').click(function(){
					Session.logout();
					Global.set(['cat_basket',"sign"]);
					Session.syncNow();
					Cart.goTop();

				});
			});
		</script>
	{reg:}<a onclick="Cart.goTop()" href="/user/signin">{Cart.lang(:Гость)}</a>
	{user:} <b><a onclick="Cart.goTop()" href="/user">{data.user.email}</a></b>
{props:}
	<table class="props">
		<tr>
			<td class="d-flex"><nobr>Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
		</tr>
		<tr>
			<td class="d-flex"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}</td>
		</tr>
	</table>
{pritem:}
{Наименование}
{producer} {article} {item}<br>
{fields::}-cart/fields.tpl