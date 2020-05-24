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
	<p>После нажатия на кнопку откроется страница банка для ввода платёжных данных.</p>
	<a target2="about:blank" class="btn btn-lg btn-success" href="{data.formUrl}">Оплатить</a>
	<script>
		location.replace("{data.formUrl}")
	</script>
{cart::}-cart/cart.tpl
{ans::}-ans/ans.tpl
{links:}
	<!-- <p>
		<a href="/cart/orders/{data.id}">Данные заказа</a><br>
		<a href="/cart/orders/{data.id}/list">Корзина</a>
	</p> -->