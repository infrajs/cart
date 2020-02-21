{::}vendor/infrajs/catalog/model.tpl
{orig::}vendor/infrajs/catalog/model.tpl
{CARDS-cost:}
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
{basket:}
	{min?(show?:showonecost?:showitemscost)?(~length(items)?:showitemonecost?:showonecost)}
	{~length(kit)?:compolect}
	
	{showitemonecost:}
		<div class="cart-basket">
			<div class="form-inline has-success">
				<div class="my-2">Цена:&nbsp;<b>{(Цена|...Цена)?:itemcost}</b>
				&nbsp;</span>
				<a class="btn btn-sm {~conf.cart.clsadd}" href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit:ampval}">Выбрать</a>
			</div>
		</div>
	{showonecost:}
		<div class="cart-basket">
			<div class="form-inline has-success">
				<div class="mr-2 my-2">Цена:&nbsp;<b>{(Цена|...Цена)?:itemcost}</b></div>
				<div class="input-group input-group-sm" title="Купить {producer|...producer} {article|...article} {item|...item}">
					<input type="number" value="1" min="0" max="999" class="form-control" style="width:60px">
					<div class="input-group-append">
						<span data-producer="{producer_nick|...producer_nick}" data-article="{article_nick|...article_nick}" data-id="{item_nick}{catkit:ampval}" class="add btn input-group-addon">{~conf.cart.textadd}</span>
					</div>
				</div>
			</div>
			<div class="bbasket" style="display:none; font-size:1rem">
				{~conf.cart.textin}
			</div>
		</div>	
	{showitemscost:}
		<div class="cart-basket">
			<div class="form-inline has-success">
				<span>Цена от&nbsp;<b class="cost">{~cost(min)}</b> до&nbsp;<b class="cost">{~cost(max)}{:unit}</b>&nbsp;</span> 
				<a class="btn btn-sm {~conf.cart.clsadd}" href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit:ampval}">Выбрать</a>
			</div>
		</div>
	