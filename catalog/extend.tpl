{orig::}vendor/infrajs/catalog/extend.tpl
{pos-page:}{:orig.pos-page}
{pos-sign:}{:orig.pos-sign}
{pos-item-css:}{:orig.pos-item-css}
{pos-item:}{:orig.pos-item}
{orig.priceblock:}
	<div class="cart alert alert-success text-right" style="font-size: 24px; padding:10px">
		{Цена?:itemcost?:itemnocost}
		<a class="actionbasket" href="/cart/orders/my/list/add/{producer} {article}"><span class="pe-7s-cart"></span></a>
	</div>

	<div class="posbasket" style="float:right; margin-bottom:3px; display:none">
		<small>Позиция в <a onclick="Cart.goTop();" href="/cart/orders/my/list">корзине</a></small>
	</div>
	{itemcost:}{~cost(Цена)}<small> руб.</small>
	{itemnocost:}<a href="/contacts">Уточнить</a>