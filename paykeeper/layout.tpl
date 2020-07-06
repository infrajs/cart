{ans::}-ans/ans.tpl
{model::}-catalog/model.tpl
{root:}
	{(:Онлайн оплата):utilcrumb}
	<h1>Заказ {data.id}</h1>
	{data.order.paykeeper.formUrl:redirect}
	{data.msg?data:ans.msg}
	{data.order:INFO}
	{redirect:}
		<p>После нажатия на кнопку откроется страница банка для ввода платёжных данных.</p>
		<a target2="about:blank" class="btn btn-lg btn-success" href="{.}">Оплатить</a>
		<script>
			location.replace("{.}")
		</script>
{INFO:}
	{paykeeper.info:showinfo}
	{showinfo:}
	{~print(.)}
	<p>Заказ: {orderid}</p>
	<table style="width:auto" class="table table-sm table-striped">
		<tr><th>Оплачено</th><td>{~date(:d.m.Y H:i,batch_date)}</td></tr>
		<tr><th>Сумма</th><td>{~cost(sum)}{:model.unit}</td></tr>
		<tr><th>Телефон покупателя</th><td>{client_phone}</td></tr>
		<tr><th>Email покупателя</th><td>{client_email}</td></tr>
		<tr><th>УИН в банке</th><td>{id}</td></tr>
	</table>
{DESCR:}
	<i>После нажатия на кнопку <b>Оплатить</b> откроется платёжный шлюз, где будет предложено ввести платёжные данные карты для оплаты заказа.</i>
	<center>
		<img class="img-fluid my-3" src="/-cart/paykeeper/logo3h.png">
	</center>
	<p>
		Ознакомьтесь с информацией <a href="/company">о компании</a>, <a href="/contacts">контакты и реквизиты</a>, <a href="/guaranty">гарантийные условия</a>, <a href="/terms">политика конфиденциальности</a>, <a href="/return">возврат и обмен</a>.
	</p>
{utilcrumb:}
	<ol class="breadcrumb">
		<li class="breadcrumb-item"><a class="{Session.get().safe.manager?:text-danger}" href="/cart">Личный кабинет</a></li>
		<li class="breadcrumb-item"><a href="/cart/{data.place}/{data.order.id|:my}">Оформление заказа {data.order.id}</a></li>
		<li class="breadcrumb-item active">{.}</li>
	</ol>