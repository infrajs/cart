{(:Онлайн оплата):cart.utilcrumb}
<h1>Онлайн оплата</h1>
<p>Сейчас вы будете перенаправлены на страницу банка!</p>

{data.formUrl?:redirect}


{data:ans.msg}
{redirect:}
	<script>
		document.location.href = "{data.formUrl}";
	</script>
{cart::}-cart/cart.tpl
{ans::}-ans/ans.tpl
{SUCCESS:}
	{(:Успешная оплата):cart.utilcrumb}
	{data:ans.msg}
{ERROR:}
	{(:Ошибка при оплате):cart.utilcrumb}
	{data:ans.msg}