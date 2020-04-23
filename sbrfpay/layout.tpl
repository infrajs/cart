{root:}
	{(:Онлайн оплата):cart.utilcrumb}
	<h1>Заказ {data.id}</h1>
	{data.formUrl?:redirect}
	{data.msg?data:ans.msg}
	{data.order.sbrfpay.info:cart.sbrfpay}
	{:links}
{SUCCESS:}
	{(:Успешная оплата):cart.utilcrumb}
	<h1>Онлайн оплата</h1>
	{data:ans.msg}
	{data.order.sbrfpay.info:cart.sbrfpay}
	{:links}
{ERROR:}
	{(:Ошибка при оплате):cart.utilcrumb}
	<h1>Заказ {data.id}</h1>
	{data:ans.msg}
	{data.order.sbrfpay.info:cart.sbrfpay}
	{:links}
	
{redirect:}
	<p>После нажатия на кноку откроется страница банка для вводы платёжных данных.</p>
	<a class="btn btn-lg btn-success" href="{data.formUrl}">Оплатить</a>
{cart::}-cart/cart.tpl
{ans::}-ans/ans.tpl
{links:}
	<!-- <p>
		<a href="/cart/orders/{data.id}">Данные заказа</a><br>
		<a href="/cart/orders/{data.id}/list">Корзина</a>
	</p> -->