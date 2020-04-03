{::}vendor/infrajs/catalog/model.tpl
{CART-props:}
	<table class="props">
		<tr>
			<td class="d-flex"><nobr class="d-none d-sm-block">Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
		</tr>
		<tr>
			<td class="d-flex"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}{item:pr}</td>
		</tr>
	</table>
{CARDS-basket:}
	{Цена?:basket-between}
{ROWS-basket:}
	<div style="clear:both" class="my-3 float-left">{Цена?:basket-between}</div>
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
			<div>{:cost-one}</div>
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>
	{showonecost:}
		<div class="form-inline has-success">
			<div class="mr-2">{:cost-one}</div>
			<div class="input-group input-group-sm" title="Купить {producer|...producer} {article|...article} {item|...item}">
				<input type="number" value="1" min="0" max="999" class="form-control" style="width:4em">
				<div class="input-group-append">
					<span data-producer="{producer_nick|...producer_nick}" data-article="{article_nick|...article_nick}" data-id="{item_nick}{catkit:ampval}" class="add btn input-group-addon">{~conf.cart.textadd}</span>
				</div>
			</div>
		</div>
		<div class="bbasket" style="display:none; position: absolute; border-bottom: 1px solid var(--gray);
			    margin-left: -4px;
			    padding: 0px 4px 4px;
			    background-color: white;">
			{~conf.cart.textin}
		</div>
	{showitemscost:}
		<div class="form-inline has-success">
			<div>{:cost-two}</div>
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>