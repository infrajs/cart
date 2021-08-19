{orig::}vendor/infrajs/catalog/extend.tpl?v={~conf.index.v}
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
{model::}-catalog/model.tpl?v={~conf.index.v}
{orig.priceblockbig:}
	{:model.basket}

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
					<span data-order_id="active" data-article_nick="{article_nick}" data-producer_nick="{producer_nick}" data-item_num="{item_num}" data-catkit="{catkit}" class="add btn input-group-addon">Добавить в корзину</span>
				</div>
			</div>
		</div>
		<div class="bbasket" style="display:none; font-size:1rem">
			Позиция добавлена в <a href='/cart/orders/my'>заказ</a>
		</div>
	</div>

{priceold:}<div class="d-flex justify-content-between"><div>Цена:&nbsp;</div><div>{:itemcost}</div></div>
{price:}
		<div class="cart text-left basketfont" style="padding:6px">
			{:basket}&nbsp;{(Цена|...Цена)?:itemcost}
			<div class="bbasket" style="display:none; font-size:1rem">
				Позиция добавлена в <a href='/cart/orders/my'>заказ</a>
			</div>
		</div>
{orig.priceblock:}
	<div class="cart alert alert-success text-right basketfont" style="padding:6px">
		{(Цена|...Цена)?:itemcost}{:basket}
		<div class="bbasket" style="display:none; font-size:1rem">
			<small>Позиция добавлена в <a href='/cart/orders/my'>заказ</a></small>
		</div>
	</div>
	{basket:}
		<a class="abasket" data-producer="{producer_nick}" data-article="{article_nick}" data-item_num="{item_num}" data-catkit="{catkit}" href="/cart/orders/active/list"><span class="pe-7s-cart flash"></span></a>
{cat::}-catalog/cat.tpl?v={~conf.index.v}
{ampval:}&{.}
{print_more_descr:}
	<div>{~cut(:200,Описание)}</div>
{print_more:}
	<table class="props" style="width:auto; font-size:14px">
		{:print_more_rows}
	</table>
	{print_more_rows:}
		{:print_more_list_rows}	
	{print_more_list_rows:}
		{:print_main_props_rows}
		<tr><td class="d-flex"><div style="white-space: nowrap">Группа:</div><div class="line"></div></td><td><a href="/catalog/{group_nick}{:orig.cat.mark.set}">{group}</a></td></tr>
	{rownonal:}<tr><td class="d-flex"><div style="white-space: nowrap">Наличие:</div><div class="line"></div></td><td style="">Нет в наличии</td></tr>
	{rownalichie:}<tr><td class="d-flex"><div style="white-space: nowrap">Наличие:</div><div class="line"></div></td><td style="color:rgb(0, 204, 0); font-weight:bold">Есть в наличии</td></tr>
	{alertnalichie:}{Наличие=:strВ наличии?:nalichieda?Наличие}
	{nalichieda:}<span style="color:rgb(0, 204, 0); font-weight:bold">Есть в наличии</span>
	{strНет:}Нет в наличии
	{strВ наличии:}В наличии
	{print_main_props_rows:}
		<tr><td class="d-flex"><div style="white-space: nowrap">Артикул:</div><div class="line"></div></td><td>{article}</td></tr>
		<tr><td class="d-flex"><div style="white-space: nowrap">Производитель:</div><div class="line"></div></td><td><a href="/catalog/{producer_nick}{:orig.cat.mark.set}">{producer}</a></td></tr>