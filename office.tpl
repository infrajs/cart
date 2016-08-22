{root:}
	<div id="usermenu"></div>
	<h1>Личный кабинет <button type="button" class="btn btn-default pull-right" onclick="cart.refresh()"><span class="glyphicon glyphicon-refresh"></span></button></h1>
	{data.email?:account?:noaccount}
	
	<p>{~length(data.list)?:showinfo?:Для вас нет важных сообщений.}</p>
	
	
	<p>
		В <a onclick="cart.goTop();" href="?office/cart">корзине</a> {data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)}.
	</p>
	
	{data.admin?:adminControl?(data.manager?:youAreManager)}
	
	<script>
		infra.require('*cart/cart.js');
	</script>
	{showinfo:}
		<table class="table table-striped">
			{data.list::stinfo}
		</table>
	{stinfo:}
		<tr class="{data.rules.rules[~key].notice}"><td>{data.rules.rules[~key].caption}</td><td>{::prorder}</td></tr>
		{prorder:}{~key?:comma}<a onclick="cart.goTop()" href="?office/orders/{id}">{id}</a>
{comma:}, 

{noaccount:}
	<p>
		<b><a onclick="cart.goTop()" href="?office/signin">Вход</a> не выполнен!</b>
	</p>
{account:}
	<p>
		Пользователь <b>{data.email}.</b>
	</p>
{youAreManager:}
	<div class="alert alert-success" role="alert">
		<b>Вы являетесь менеджером</b>
	</div>
{adminControl:}
	<div class="alert alert-{data.manager?:success?:danger}" role="alert">
		{data.email?:adminForm?:allertForAdmin}

	</div>
	{adminForm:}
			<p>Введён логин и пароль администратора сайта</p>
			<p>Вы можете изменить свой статус</p>
			<p style="font-weight:bold">Вы {data.manager?:менеджер?:обычный пользователь}</p>
			<form style="margin-top:10px" class="managerForm" action="{infra.theme(:*cart/office.php)}?submit=1" method="post">
				 <div style="display:none" class="checkbox">
					<label>
						<input name="IAmManager" type="checkbox" {data.manager??:checked}>
					</label>
				</div>
				<div class="input-group">
					<input type="submit" class="btn btn-{data.manager?:success?:danger}" value="{data.manager?:Сделать меня обычным пользователем?:Сделать меня менеджером}">
				</div>
			</form>
		
		<script>
			infra.when(infrajs,'onshow',function(){
				
				var layer=infrajs.getUnickLayer('{unick}');
				var div=$('#'+layer.div);
				var counter={counter};
				console.log(layer.data);
				infra.listen(layer,'onsubmit',function(layer){
					if(counter!=layer.counter||!layer.showed)return;
					var ans=layer.config.ans;
					console.log(ans);

					infrajs.global.set(["sign",'cat_basket']);
				});
			});
		</script>
	{allertForAdmin:}
		<div class="mesage">Необходимо <a onclick="cart.goTop()" href="?office/signup">зарегистрироваться</a>, чтобы получить права менеджера</div>
	
	