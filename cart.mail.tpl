{AdmOrderToCheck:}
	<p>Заказ <b>{id}</b> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки.</p>
	{:cart.printorder}
	{:AdmLinks}
{AdmLinks:}
	<p>
		<a href="http://{site}/cart/admin/{id}">Заказ {id}</a><br>
		<a href="http://{site}">{site}</a>
	</p>
{payorrec:}{(sbrfpay.info.orderStatus=:2|paykeeper.info)?:payd?:rec}
{cart::}-cart/cart.tpl
{payd:}<b>оплачен</b>
{rec:}принят
{2:}2
{orderToCheck:}
	<p>{name}, Ваш заказ <b>{id}</b> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки. После проверки позиций в заказе, с вами свяжется наш менеджер для подтверждения и уточнения деталей заказа.</p>
	<p>Отслеживать состояние заказа можно в <a href="{link}&src=cart">личном кабинете</a>.</p>
	{:cart.printorder}
	<p>
		По всем вопросам обращайтесь по нашим <a href="https://{site}/contacts">контактам</a>. При возникновении вопросов наш сотрудник свяжется с вами! Спасибо, что выбрали наш магазин.
	</p>
	<p>С уважением, команда <a href="https://{site}">{site}</a></p>
	{:links}

{edit:}
	<p>Есть изменения по вашему заказу.</p>
	<hr>
	<pre>{manage.comment}</pre>
	</hr>
	{:links}
{links:}
	<p><b><a href="{link}&src=cart/orders/{id}">Заказ {id}</a></b></p>
	<p>
		<a href="{link}&src=catalog">Каталог товаров</a><br>
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

