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
	<span style="font-size: 24px;" class="mt-4 cart-basket form-inline form-group has-success">
		{(Цена|...Цена)?:itemcost}&nbsp;&nbsp;&nbsp;
		<div class="input-group " title="{producer_nick|...producer_nick} {article_nick|...article_nick}{:cat.idsp}">
			<input type="number" value="1" min="0" max="999" class="form-control">
			<div class="input-group-append">
				<span data-producer="{producer_nick|...producer_nick}" data-article="{article_nick|...article_nick}" data-id="{item_nick}" class="add btn btn-success input-group-addon">В корзину</span>
			</div>
		</div>
	</span>
{priceblock:}{:orig.priceblock}
{orig.price:}{:price}
{price:}
		<div class="cart text-left basketfont" style="padding:6px">
			{:basket}&nbsp;{(Цена|...Цена)?:itemcost}
			<div class="bbasket" style="display:none; font-size:16px">
				<small>Позиция в <a href="/cart/orders/my/list">корзине</a></small>
			</div>
		</div>
{orig.priceblock:}
	<div class="cart alert alert-success text-right basketfont" style="padding:6px">
			{(Цена|...Цена)?:itemcost}{:orig.nds}&nbsp;{:basket}<div style="display:none; font-size:16px">
			<small>Позиция в <a href="/cart/orders/my/list">корзине</a></small>
		</div>
		</div>
	{basket:}
		<a class="abasket" data-producer="{producer_nick}" data-article="{article_nick}" data-id="{item_nick}" href="/cart/orders/my/list/add/{producer_nick} {article_nick}{:cat.idsp}"><span class="pe-7s-cart flash"></span></a>
{cat::}-catalog/cat.tpl