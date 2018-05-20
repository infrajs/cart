{orig::}vendor/infrajs/catalog/extend.tpl
{pos-page:}{:orig.pos-page}
{nds:}{:orig.nds}
{pos-sign:}{:orig.pos-sign}
{pos-item-css:}{:orig.pos-item-css}
{pos-item:}{:orig.pos-item}
{pos-img:}{:orig.pos-img}
{priceblockbig:}{:orig.priceblockbig}
{itemcost:}{~cost((Цена|...Цена))}&nbsp;<small>руб.</small>
{itemnocost:}<a href="/contacts">Уточнить</a>
{nalichie:}{:orig.nalichie}
{orig.priceblockbig:}
	<span style="font-size: 24px;" class="cart-basket form-inline form-group has-success">
		{(Цена|...Цена)?:itemcost}
		<div class="input-group " title="{producer|...producer} {article|...article}{:cat.idsp}">
			<input type="number" value="0" min="0" max="999" class="form-control" style="width:100px; font-size:24px; padding:0 5px">
			<span data-producer="{producer|...producer}"" data-article="{article|...article}" data-id="{id}" class="add btn btn-success input-group-addon">Добавить в корзину</span>
		</div>
	</span>
{priceblock:}{:orig.priceblock}
{orig.priceblock:}
	<div class="cart alert alert-success text-right basketfont" style="padding:10px">
			{(Цена|...Цена)?:itemcost}{:orig.nds}&nbsp;{:basket}<div style="display:none; font-size:16px">
			<small>Позиция в <a href="/cart/orders/my/list">корзине</a></small>
		</div>
		</div>
	{basket:}
		<a class="abasket" data-producer="{producer}" data-article="{article}" data-id="{id}" href="/cart/orders/my/list/add/{producer} {article}{:cat.idsp}"><span class="pe-7s-cart flash"></span></a>
{cat::}-catalog/cat.tpl