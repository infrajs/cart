{refunds:}
	<div id="usermenu"></div>
	<h1>Возврат оплаты</h1>
	{data.id?:ordernum}
	{data.msg?:message}
	{data.result?:formref}
	
{formref:}
	<p>
		После нажатия на кнопку вы будете перенаправлены<br>
		на банковский шлюз для оформления возврата.
	</p>
	<h2>Сумма возврата {~cost(data.amount)} руб.</h2>
	<form name="tranform" method="POST" action="{data.bankurl}">
		<input type="hidden"  size="12" value="{data.amount}" id="AMOUNT" name="AMOUNT">
		<input type="hidden" maxlength="3" size="3" value="{data.currency}" id="CURRENCY" name="CURRENCY">
		<input type="hidden" maxlength="32" size="32" value="{data.orderNumber}" id="ORDER" name="ORDER">
		<input type="hidden" maxlength="32" size="32" value="{data.org_amount}" id="org_amount" name="ORG_AMOUNT">
		<input type="hidden" maxlength="32" size="32" value="{data.RRN}" id="RRN" name="RRN">
		<input type="hidden" maxlength="32" size="32" value="{data.INT_REF}" id="INT_REF" name="INT_REF">
		<input type="hidden" maxlength="8" value="{data.merchantTerminal}" size="8" id="TERMINAL" name="TERMINAL">
		<input type="hidden" maxlength="1" value="{data.trType}" size="1" id="TRTYPE" name="TRTYPE">
		<input type="hidden" value="{data.email}" id="EMAIL" name="EMAIL">
		<input type="hidden" value="{data.timestamp}" id="TIMESTAMP" name="TIMESTAMP">
		<input type="hidden" value="{data.nonce}" id="NONCE" name="NONCE">
		<input type="hidden" value="{data.backref}" id="BACKREF" name="BACKREF">
		<input type="hidden" value="{data.sign}" id="P_SIGN" name="P_SIGN">
		<input type="submit" class="btn btn-success" value="Приступить к возврату денег">
	</form>
{paycard:}
	<div id="usermenu"></div>
	<h1>Оплата заявки</h1>
	{data.id?:ordernum}
	{data.msg?:message}
	{data.result?:form}
{ordernum:}<p>Номер заявки: <a onclick="cart.goTop()" href="?office/orders/{data.id}">{data.id}</a></p>
{message:}
	<div class="{data.msgclass}">{data.msg}</div>
{showdelivery:}Доставка <span style="font-size:18px">{~cost(data.delivery)}</span> руб.<br>
{form:}
	<p>
		{data.description}
	</p>
	<p>
		Стоимость <span style="font-size:18px">{~cost(data.total)}</span> руб.<br>
		{data.delivery?:showdelivery}
	</p>
	<h2>Итого {~cost(data.amount)} руб.</h2>
	<p>
		После нажатия на кнопку перейти к оплате<br>вы будете перенаправлены на банковский шлюз для оплаты.
	</p>
	<form name="tranform" method="POST" action="{data.bankurl}">
		<input type="hidden"  size="12" value="{data.amount}" id="AMOUNT" name="AMOUNT">
		<input type="hidden" maxlength="3" size="3" value="{data.currency}" id="CURRENCY" name="CURRENCY">
		<input type="hidden" maxlength="32" size="32" value="{data.orderNumber}" id="ORDER" name="ORDER">
		<input type="hidden" maxlength="50" size="50" value="{data.description}" id="DESC" name="DESC">
		<input type="hidden" maxlength="8" value="{data.merchantTerminal}" size="8" id="TERMINAL" name="TERMINAL">
		<input type="hidden" maxlength="1" value="{data.trType}" size="1" id="TRTYPE" name="TRTYPE">
		<input type="hidden" value="{data.merchantName}" id="MERCH_NAME" name="MERCH_NAME">                                                                              
		<input type="hidden" value="{data.merchant}" id="MERCHANT" name="MERCHANT">
		<input type="hidden" value="{data.email}" id="EMAIL" name="EMAIL">
		<input type="hidden" value="{data.timestamp}" id="TIMESTAMP" name="TIMESTAMP">
		<input type="hidden" value="{data.nonce}" id="NONCE" name="NONCE">
		<input type="hidden" value="{data.backref}" id="BACKREF" name="BACKREF">
		<input type="hidden" value="{data.sign}" id="P_SIGN" name="P_SIGN">
		<input type="hidden" value="{data.lang}" name="LANG">
		<input type="hidden" value="{data.service}" name="SERVICE">
		<input type="submit" class="btn btn-success" value="Перейти к оплате">
	</form>