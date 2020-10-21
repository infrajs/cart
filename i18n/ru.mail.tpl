
{AdmOrderToCheck-subject:}{host} {email} заказ отправлен на проверку
{AdmOrderToCheck:}
	<p>Заказ <b>{order.order_nick}</b> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки.</p>
	{order:cart.resume}
	{:AdmLinks}

{orderToCheck-subject:}Оформлен заказ в интернет-магазине {host}
{orderToCheck:}
	<p>
		{order.name}, Ваш заказ <a href="{site}/cart/orders/{order.order_nick}">№{order.order_nick}</a> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки. При возникновении вопросов с Вами свяжется менеджер для подтверждения или уточнения деталей заказа. Отслеживать состояние заказа можно в <a href="{site}/cart">личном кабинете</a>.
	</p>
	{order:cart.resume}
	<p>
		По всем вопросам обращайтесь по нашим <a href="{site}/contacts">контактам</a>.<br>Спасибо, что выбрали наш магазин.
	</p>
	{:links}
{email-subject:}{host} изменения по вашему заказу
{email:}
	<p>
		Добрый день!
	</p>
	<p>
		Есть изменения по вашему заказу <a href="{site}/cart/orders/{order.order_nick}">№{order.order_nick}</a>
	</p>
	<pre>{order.commentmanager}</pre>
	{:links}

{links:}
	<p>
		С уважением, команда <a href="{site}">{host}</a>
	</p>
{AdmLinks:}
	<p>
		<a href="{site}/cart/admin/{order.order_nick}">Заказ {order.order_nick}</a><br>
		<a href="{site}">{host}</a>
	</p>
{payorrec:}{order.paid?:paid?:rec}
{cart::}-cart/layout.tpl
{paid:}<b>оплачен</b>
{rec:}принят
{2:}2