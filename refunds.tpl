{root:}
	<style>
	</style>

	{data.msg?:message}
	{data.result?:table}

{message:}
	<div class="{data.msgclass}">{data.msg}</div>
	
{table:}
	<div class="data">
		Сумма возврата {data.amount},<br><br>
		После нажатия на кнопку вы будете перенаправлены<br>
		на банковский шлюз для оформления возврата.
	</div>
	<form name="tranform" method="POST" action="{data.bankurl}">
		<input type="TEXT"  size="12" value="{data.amount}" id="AMOUNT" name="AMOUNT">
		<input type="TEXT" maxlength="3" size="3" value="{data.currency}" id="CURRENCY" name="CURRENCY">
		<input type="TEXT" maxlength="32" size="32" value="{data.orderNumber}" id="ORDER" name="ORDER">
		<input type="TEXT" maxlength="32" size="32" value="{data.org_amount}" id="org_amount" name="ORG_AMOUNT">
		<input type="TEXT" maxlength="32" size="32" value="{data.RRN}" id="RRN" name="RRN">
		<input type="TEXT" maxlength="32" size="32" value="{data.INT_REF}" id="INT_REF" name="INT_REF">
		<input type="TEXT" maxlength="8" value="{data.merchantTerminal}" size="8" id="TERMINAL" name="TERMINAL">
		<input type="TEXT" maxlength="1" value="{data.trType}" size="1" id="TRTYPE" name="TRTYPE">
		<input type="TEXT" value="{data.email}" id="EMAIL" name="EMAIL">
		<input type="TEXT" value="{data.timestamp}" id="TIMESTAMP" name="TIMESTAMP">
		<input type="TEXT" value="{data.nonce}" id="NONCE" name="NONCE">
		<input type="TEXT" value="{data.backref}" id="BACKREF" name="BACKREF">
		<input type="TEXT" value="{data.sign}" id="P_SIGN" name="P_SIGN">
		<input type="submit" value="Приступить к возврату денег">
	</form>