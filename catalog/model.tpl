{::}vendor/infrajs/catalog/model.tpl
{orig::}vendor/infrajs/catalog/model.tpl
{CARDS-basket:}
	{:basket-between}
{PRINT-item:}
	<p>
		{Наименование} {producer} {article}{item:pr}
		<br><b>{count}</b> по <b>{~cost(cost)}&nbsp;руб.</b> = <b>{~cost(sum)}&nbsp;руб.</b>
	</p>
{CART-props:}
	<table class="props">
		<tr>
			<td class="d-flex"><nobr class="d-none d-sm-block">Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
		</tr>
		<tr>
			<td class="d-flex"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}{item:pr}</td>
		</tr>
	</table>
{basket-between:}
	<div class="between">
		<style>
			#{div} .between .cart-basket .form-inline {
				display: flex;
				justify-content: space-between;
			}
		</style>
		{:basket}
	</div>
	{cost:}{min?(show?:cost-one?:cost-two)?:cost-one}
	{cost-one:}<div class="my-1">Цена:&nbsp;<b>{(Цена|...Цена)?:itemcost}</b></div>
	{cost-two:}<div class="my-1">Цена от&nbsp;<b class="cost">{~cost(min)}</b> до&nbsp;<b class="cost">{~cost(max)}{:unit}</b></div> 
{basket:}
	<div class="cart-basket">
		{min?(show?:showonecost?:showitemscost)?(~length(items)?:showitemonecost?:showonecost)}
		{~length(kit)?:compolect}
	</div>
	{compolect:}<div style="font-size:1rem">Комплектация{iscatkit?:m}: <ul>{kit::kitlig}</ul></div>
		{kitlig:}{::kitli}
		{kitli:}<li><a href="{:link-pos}">{article}</a></li>
		{m:}<span style="color:red" title="Нестандартная комплектация">*</span>
	{showitemonecost:}
		<div class="form-inline has-success">
			{:cost-one}
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>
	{showonecost:}
		<div class="form-inline has-success">
			{:cost-one}
			<div class="ml-2 my-1 input-group input-group-sm" title="Купить {producer|...producer} {article|...article} {item|...item}">
				<input type="number" value="1" min="0" max="999" class="form-control" style="width:60px">
				<div class="input-group-append">
					<span data-producer="{producer_nick|...producer_nick}" data-article="{article_nick|...article_nick}" data-id="{item_nick}{catkit:ampval}" class="add btn input-group-addon">{~conf.cart.textadd}</span>
				</div>
			</div>
		</div>
		<div class="bbasket" style="display:none; font-size:1rem">
			{~conf.cart.textin}
		</div>
	{showitemscost:}
		<div class="form-inline has-success">
			{:cost-two}
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>