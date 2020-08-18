
{AdmOrderToCheck-subject:}{host} {email} заказ отправлен на проверку
{AdmOrderToCheck:}
	<p>Заказ <b>{id}</b> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки.</p>
	{:cart.printorder}
	{:AdmLinks}

{orderToCheck-subject:}Оформлен заказ в интернет-магазине {host}
{orderToCheck:}
	<p>{name}, Ваш заказ <b>{id}</b> от {~date(:j.m.Y,time)} {:payorrec} и ожидает проверки. После проверки позиций в заказе, с вами свяжется наш менеджер для подтверждения и уточнения деталей заказа.</p>
	<p>Отслеживать состояние заказа можно в <a href="{link}&src=cart">личном кабинете</a>.</p>
	{:cart.printorder}
	<p>
		По всем вопросам обращайтесь по нашим <a href="{site}/contacts">контактам</a>. При возникновении вопросов наш сотрудник свяжется с вами! Спасибо, что выбрали наш магазин.
	</p>
	<p>С уважением, команда <a href="{site}">{host}</a></p>
	{:links}

{order_id-subject:}{host} изменения по вашему заказу
{order_id:}
	<p>Есть изменения по вашему заказу.</p>
	<hr>
	<pre>{commentmanager}</pre>
	</hr>
	{:links}



	
{links:}
	<p><b><a href="{link}&src=cart/orders/{id}">Заказ {id}</a></b></p>
	<p>
		<a href="{link}&src=catalog">Каталог товаров</a><br>
	</p>
{AdmLinks:}
	<p>
		<a href="{site}/cart/admin/{id}">Заказ {id}</a><br>
		<a href="{site}">{host}</a>
	</p>
{payorrec:}{(sbrfpay.info.orderStatus=:2|paykeeper.info)?:payd?:rec}
{cart::}-cart/cart.tpl
{payd:}<b>оплачен</b>
{rec:}принят
{2:}2