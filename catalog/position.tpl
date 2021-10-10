{::}vendor/infrajs/catalog/position.tpl?v={~conf.index.v}
{model.showitemonecost:}{:model.showonecost}
{props:}
	<div style="margin-bottom:1rem">
		{:model.POS-props}
	</div>
	{items?:showitems}
	<div>
		{Скрыть фильтры в полном описании??:print_more}
	</div>
	{Цена?:model.basket}
