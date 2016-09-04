{orig::}vendor/infrajs/catalog/extend.tpl
{pos-page:}{:orig.pos-page}
{pos-sign:}{:orig.pos-sign}
{pos-item-css:}{:orig.pos-item-css}
{pos-item:}{:orig.pos-item}
{orig.priceblock:}
	<div class="cart alert alert-success text-right" style="font-size: 24px; padding:10px">
		{Цена?:itemcost?:itemnocost}{:orig.nds}
		{:basket}
		<div class="gobasket" style="display:none; font-size:16px">
			<small>Позиция в <a onclick="Cart.goTop();" href="/cart/orders/my/list">корзине</a></small>
		</div>
	</div>
	{itemcost:}{~cost(Цена)}<small> руб.</small>
	{itemnocost:}<a href="/contacts">Уточнить</a>
{orig.priceblockbig:}
	{:orig.priceblock}
{priceblock:}
	{:orig.priceblock}
{basket:}
	<a class="abasket" data-producer="{producer}" data-article="{article}" href="/cart/orders/my/list/add/{producer} {article}">
		<span class="pe-7s-cart"></span>
	</a>
	
