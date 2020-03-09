{::}vendor/infrajs/catalog/position.tpl
{model.showitemonecost:}{:model.showonecost}
{props:}
	<div class="mb-3">
		{:model.POS-props}
	</div>
	{items?:showitems}
	<div>
		{Скрыть фильтры в полном описании??:print_more}
	</div>
	<div class="mb-3">
		{Цена?:model.cost}
	</div>
	{Цена?:model.basket-between}
