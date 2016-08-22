{header:}
	<div id="usermenu"></div>
	<style>
		.signform {
			
		}
	</style>
	<script>
		infra.require('*cart/cart.js');
	</script>
{form:}
	<form style="width:400px;" class="signform" action="{infra.theme(:*cart/sign.php)}?type={data.type}&submit=1" type="post">
{/form:}
	{config.ans.msg:alert}	
	</form>
	
{alert:}
	<div style="margin-top:20px" class="alert alert-{..result?:success?:danger}">
		{.}
	</div>
{SIGNUP:}
	{:header}
	<h3>Регистрация</h3>
	{:form}
		<div class="form-group">
	    	<label for="sign-email">Email <span class="req">*</span></label>
			<input id="sign-email" type="email" name="email" class="form-control" placeholder="Электропочта">
		</div>
		<div class="form-group">
	    	<label for="sign-name">Имя</label>
			<input id="sign-name" type="text" name="name" class="form-control" placeholder="Имя">
		</div>
		<div class="form-group">
	    	<label for="sign-phone">Телефон</label>
			<input id="sign-phone" type="text" name="phone" class="form-control" placeholder="Телефон">
		</div>
		<input class="btn btn-success" type="submit" value="Зарегистрироваться">
		<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/signin">Вход</a>
		<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/resendpass">Напомнить пароль</a>
	{:/form}
{SIGNIN:}
	{:header}
	<h3>Вход</h3>
	{data.email?data.msg:alert?:signinform}
	{signinform:}
		{:form}
			<div class="form-group">
		    	<label for="sign-email">Email <span class="req">*</span></label>
				<input id="sign-email" type="email" name="email" class="form-control" placeholder="Электропочта">
			</div>
			<div class="form-group">
		    	<label for="sign-password">Пароль <span class="req">*</span></label>
				<input id="sign-password" type="password" name="password" class="form-control" placeholder="Пароль">
			</div>
			<input class="btn btn-success" type="submit" value="Войти">
			<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/signup">Регистрация</a>
			<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/resendpass">Напомнить пароль</a>
		{:/form}

{RESENDPASS:}
	{:header}
	<h3>Напомнить пароль</h3>
	{:form}
		<div class="form-group">
	    	<label for="sign-email">Email <span class="req">*</span></label>
			<input id="sign-email" type="email" name="email" class="form-control" placeholder="Электропочта">
		</div>
		<input class="btn btn-success" type="submit" value="Напомнить">
		<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/signin">Вход</a>
		<a onclick="cart.goTop()" class="btn btn-primary" style="text-decoration:none" href="?office/signup">Регистрация</a>
	{:/form}

{SIGNOUT:}
	{:header}
	{data.msg:alert}
	{data.email?:signout?:signoutmessage}
	{signoutmessage:}
		<script>
			infra.when(infrajs,'onshow',function(){
				infrajs.check();
			});
		</script>
	{signout:}
		<h3>Для выхода нажмите на конопку</h3>
		<button class="signout btn btn-danger">Выход</button>
		<script>
		$('.signout').click(function(){
			infra.session.logout();
			infrajs.global.set(["cat_basket","sign"]);
			infrajs.check();
		});
		</script>
