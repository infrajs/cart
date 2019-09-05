{AdmOrderToCheck:}
	<p>На проверку поступил новый заказ.</p>
	{:cart.printorder}
	{:AdmLinks}
{cart::}-cart/cart.tpl
{AdmLinks:}
	<p>
		<a href="http://{site}/cart/admin/{id}">Заказ {id}</a><br>
		<a href="http://{site}">{site}</a>
	</p>
{orderToCheck:}
	<p>Заказ отправлен на проверку менеджеру.</p>
	{:cart.printorder}
	{:links}
{edit:}
	<p>Есть изменения по вашему заказу.</p>
	<hr>
	<pre>{manage.comment}</pre>
	</hr>
	{:links}
{links:}
	<p><b><a href="http://{site}/cart/orders/{id}">Заказ {id}</a></b></p>
	<p>
		<a href="http://{site}/cart">Личный кабинет</a><br>
		<a href="http://{site}/catalog">Каталог товаров</a><br>
		<a href="{link}&src=cart/orders/{id}">Быстрый вход</a>
	</p>















{setPaid:}
	Зафиксирована оплата заказа.
	{:links}
{ready:}
	Заказ готов к оплате. Перейти к оплате: <a href="http://{site}/cart/orders/{id}/paycard">http://{site}/cart/orders/{id}/paycard</a>
	{:links}
{dismiss:}
	Заказ отклонён.
	{:links}
{complete:}
	Заказ выполнен!
	{:links}
{execution:}
	Заказ в исполнении.
	{:links}
{picked:}
	Заказ укомплектован.
	{:links}
{bankrefunds:}
	Осуществлён возврат оплаты.
	{:links}
{AdmBankrefunds:}
	Осуществлён возврат оплаты.
	{:AdmLinks}
{bankpaid:}
	Заказ оплачен.
	{:links}
{AdmEdit:}
	Внесены изменения в заказ
	{:AdmLinks}
{AdmBankpaid:}
	Оплачен заказ.
	{:AdmLinks}
{refuseable:}
	Разрешён возврат денег.
	{:links}

