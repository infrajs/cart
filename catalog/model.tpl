{::}vendor/infrajs/catalog/model.tpl
{orig::}vendor/infrajs/catalog/model.tpl
{CARDS-basket:}
	{:basket-between}
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
		{kitli:}<li><a href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit?:sl}{catkit:ampval}">{article}</a></li>
		{m:}<span style="color:red" title="Нестандартная комплектация">*</span>
	{showitemonecost:}
		<div class="form-inline has-success">
			{:cost-one}
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit:ampval}">Выбрать</a>
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
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit:ampval}">Выбрать</a>
		</div>
	