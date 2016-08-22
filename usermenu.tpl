<style>
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
		infra.require('*cart/cart.js');
		infra.when(infrajs,'onshow',function(){
			cart.init();
		});
	</script>
<table class="userMenu table">
 	<tr>
 		<td class="info"><a class="{state.child??:active}" onclick="cart.goTop()" href="?office">Личный кабинет</a></td>
 		<td class="info"><a class="{state.child.name=:cart?:active}" onclick="cart.goTop()" href="?office/cart">Корзина</a></td>
 		<td class="info"><a class="{state.child.name=:orders?:active}" onclick="cart.goTop()" href="?office/orders">Мои заявки</a></td>
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
	<td class="danger"><a class="signout" href="?office/signout">Выход</a>
		<script>
			$('.signout').click(function(){
				infra.session.logout();
				infrajs.global.set(['cat_basket',"sign"]);
				infra.session.syncNow();
				cart.goTop();

			});
		</script>
	</td>

{unsigned:}
	<td class="warning"><a class="{state.child.name=:signin?:active}" 
		onclick="cart.goTop()" href="?office/signin">Вход</a></td>
	<td class="warning"><a class="{state.child.name=:signup?:active}" 
		onclick="cart.goTop()" href="?office/signup">Регистрация</a></td>
	<td class="warning"><a class="{state.child.name=:resendpass?:active}" 
		onclick="cart.goTop()" href="?office/resendpass">Напомнить пароль</a></td>

{youAreManager:}
	<td class="success"><a class="{state.child.name=:admin?:active}" onclick="cart.goTop()" href="?office/admin">Управление заявками</a></td>
	<td class="success"><a class="{state.child.name=:wholesale?:active}" onclick="cart.goTop()" href="?office/wholesale">Оптовики</a></td>