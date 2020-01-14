{orig::}vendor/infrajs/catalog/extend.tpl
{pos-page:}{:orig.pos-page}
{nds:}{:orig.nds}
{pos-sign:}{:orig.pos-sign}
{pos-item-css:}{:orig.pos-item-css}
{pos-item:}{:orig.pos-item}
{pos-img:}{:orig.pos-img}
{unit:}{:orig.unit}
{priceblockbig:}{:orig.priceblockbig}
	{itemcost:}<span class="cost">{~cost((Цена|...Цена))}{:orig.unit}</span>
	{itemnocost:}<a href="/contacts">Уточнить</a>
	{nalichie:}{:orig.nalichie}
	{badgenalichie:}{:orig.badgenalichie}
{orig.priceblockbig:}
	{min?(show?:showonecost?:showitemscost)?(~length(items)?:showitemonecost?:showonecost)}
	{~length(kit)?:compolect}
	{showitemonecost:}
		<div class="cart-basket">
			<div class="form-inline has-success">
				<span>Цена:&nbsp;<b>{(Цена|...Цена)?:itemcost}</b>
				&nbsp;</span>
				<a class="btn btn-sm {~conf.cart.clsadd}" href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit:ampval}">Выбрать</a>
			</div>
		</div>
	{showonecost:}
		<div class="cart-basket">
			<style>
				.between .cart-basket .form-inline {
					display: flex;
					justify-content: space-between;
				}
			</style>
			<div class="form-inline has-success">
				<div class="mr-2">Цена:&nbsp;<b>{(Цена|...Цена)?:itemcost}</b></div>
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
{compolect:}<div style="font-size:1rem">Комплектация{iscatkit?:m}: <ul>{kit::kitlig}</ul></div>
	{kitlig:}{::kitli}
	{kitli:}<li><a href="/{Controller.names.catalog.crumb}/{producer_nick}/{article_nick}{item_nick:sl}{catkit?:sl}{catkit:ampval}">{article}</a></li>
	{m:}<span style="color:red" title="Нестандартная комплектация">*</span>
{comma:}, 
{sl:}/{.}
{priceblock:}{:orig.priceblock}
{orig.price:}{:price}
{pricerow:}
	<div class="d-flex justify-content-between"><div>Цена:&nbsp;</div><div>{:itemcost}</div></div>
{basketrow:}
	<div class="cart-basket">
			<style>
				.between .cart-basket .input-group {
					width:100%;
				}
			</style>
			<div class="form-inline has-success">
				<div class="input-group input-group-sm" title="Купить {producer} {article} {item}">
					<input type="number" value="1" min="0" max="999" class="form-control" style="width:60px;">
					<div class="input-group-append">
						<span data-producer="{producer_nick}" data-article="{article_nick}" data-id="{item_nick}{catkit:ampval}" class="add btn input-group-addon">{~conf.cart.textadd}</span>
					</div>
				</div>
			</div>
			<div class="bbasket" style="display:none; font-size:1rem">
				{~conf.cart.textin}
			</div>
		</div>
{priceold:}<div class="d-flex justify-content-between"><div>Цена:&nbsp;</div><div>{:itemcost}</div></div>
{price:}
		<div class="cart text-left basketfont" style="padding:6px">
			{:basket}&nbsp;{(Цена|...Цена)?:itemcost}
			<div class="bbasket" style="display:none; font-size:1rem">
				{~conf.cart.textin}
			</div>
		</div>
{orig.priceblock:}
	<div class="cart alert alert-success text-right basketfont" style="padding:6px">
		{(Цена|...Цена)?:itemcost}{:basket}
		<div class="bbasket" style="display:none; font-size:1rem">
			<small>{~conf.cart.textin}</small>
		</div>
	</div>
	{basket:}
		<a class="abasket" data-producer="{producer_nick}" data-article="{article_nick}" data-id="{item_nick}{catkit:ampval}" href="/cart/orders/my/list"><span class="pe-7s-cart flash"></span></a>
{cat::}-catalog/cat.tpl
{ampval:}&{.}