{orig::}vendor/infrajs/catalog/extend.tpl
{pos-page:}{:orig.pos-page}
{nds:}{:orig.nds}
{pos-sign:}{:orig.pos-sign}
{pos-item-css:}{:orig.pos-item-css}
{pos-item:}{:orig.pos-item}
{orig.priceblockbig:}{:orig.priceblock}
{itemcost:}{~cost(Цена|...Цена)}&nbsp;<small>руб.</small>
{itemnocost:}<a href="/contacts">Уточнить</a>

{orig.priceblock:}
	<span style="font-size: 24px;" class="cart-basket form-inline form-group has-success">
		{(Цена|...Цена)?:cost}
		<div class="input-group " title="{producer|...producer} {article|...article}{:cat.idsp}">
			<input type="number" value="0" min="0" max="999" class="form-control" style="width:100px; font-size:24px">
			<span data-producer="{producer|...producer}"" data-article="{article|...article}" data-id="{id}" class="add btn btn-success input-group-addon">Добавить в корзину</span>
		</div>
	</span>
	{cost:}{:itemcost}

{cat::}-catalog/cat.tpl