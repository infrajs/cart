{header:}
	<style>
	</style>
	<div id="usermenu"></div>

{root:}
	{:header}
	<div class="myactions" data-place="wholesale">
		{data.result?:listPage?:message}
	</div>
{message:}{config.ans.msg?config.ans.msg?data.msg}

{listPage:}
	<h1>Список клиентов со статусом "Оптовик"</h1>

	<form action="{infra.theme(:*cart/wholesalecontrol.php)}?add=1" method="post">
		<div class="form-group">
			<label for="whole-email">Email <span class="req">*</span></label>
			<input type="email" id="whole-email" name="email" class="form-control" placeholder="Email">
		</div>
		<div class="form-group">
			<label for="whole-name">Имя <span class="req">*</span></label>
			<input type="text" id="whole-name" name="name" class="form-control" placeholder="Имя">
		</div>
		<input class="btn btn-secondary" type="submit" value="Добавить">
	</form><br>
	<div id="level"></div>
	<br>
	{data.merchants?:table?:message}
	
{table:}
	<table class="table">
		<tr>
			<th>Имя</th>
			<th>email</th>
			<th></th>
		</tr>
		{data.merchants::row}
	</table>

{row:}
	<tr>
		<td>
			{name}
		</td>
		<td>
			{~key}
		</td>
		<td>
			<span class="a act-wholesaleDelete" data-id="{~key}">X</span>
		</td>
	</tr>
	
{level:}
	<form action="{infra.theme(:*cart/wholesalecontrol.php)}?change=1" method="post">
		<div class="form-group">
			<label for="whole-level">Сумма, при которой начинают действовать оптовые цены, руб.</label>
			<input value="{data.level}" type="number" id="whole-level" name="level" class="form-control" placeholder="Имя">
		</div>
		<input class="btn btn-secondary" type="submit" value="Сохранить">
	</form>