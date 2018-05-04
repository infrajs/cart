<div class="cart-search-complete">
	<style>
		.autocomplete-suggestions { border: 1px solid #999; background: #FFF; overflow: auto; }
		.autocomplete-suggestion { padding: 2px 5px; white-space: nowrap; overflow: hidden; }
		.autocomplete-selected { background: #F0F0F0; }
		.autocomplete-suggestions strong { font-weight: normal; color: #3399FF; cursor:pointer;}
		.autocomplete-group { padding: 2px 5px; }
		.autocomplete-group strong { display: block; border-bottom: 1px solid #000; }
	</style>
	<h1>Добавить позицию</h1>
	<p>Заявка: <a href="/cart/{config.place}/{config.orderid|:my}/list">{config.orderid|:Активная}</a></p>
	<p>
		<input value='' autosave="0" type="text" class="formControll input" style="width:100%">
	</p>
	<!--<span class="btn btn-default button">Добавить</span>-->
	<script>
		domready(function () {
			//https://github.com/devbridge/jQuery-Autocomplete
			var prodart = false;
			var div = $('.cart-search-complete');
			div.find('.button').click( function () {
				if (!prodart) return;
				Cart.add('{config.place}', '{config.orderid}', prodart);
				div.find('.input').val('');
			});
			var query = '';
			div.find('.input').autocomplete({
				serviceUrl: function (q) {
					query = q;
					return '/-cart/rest/search/' + q;
				},
				onSelect: function (suggestion) {
					var pos = suggestion.data;
					prodart = pos['producer'] + ' ' + pos['article'];
					if (pos['id']) prodart += ' ' + pos['id'];
					Popup.confirm('Количество: <input name="count" type="number">', function(div){
						var count = div.find('[name=count]').val();
						Cart.set('{config.place}', '{config.orderid}', prodart, count);
						//Cart.sync('{config.place}', '{config.orderid}');
						Cart.act('{config.place}', 'sync', '{config.orderid}');
					}, pos['Производитель'] + ' ' + pos['Артикул'] + '<br><small>' + pos['itemrow']+'</small>');
					
				},
				transformResult: function (ans) {
					return {
						suggestions: $.map(ans.list, function (pos) {
							//var itemrow = Catalog.getItemRowValue(pos);
							//if (itemrow) itemrow = ' ' + itemrow;
							//var value = pos['Производитель'] + ' ' + pos['Артикул'] + itemrow;
							return { 
								value: query, 
								data: pos 
							};
						})
					};
				},
				dataType:"json",
				ignoreParams: true,
				onSearchComplete: function () {
					Controller.check();
				},
				formatResult: function (suggestion, currentValue) {
					if (!currentValue) return suggestion;
					//var pattern = '(' + $.Autocomplete.utils.escapeRegExChars(currentValue) + ')';
					//var res = suggestion.value;
					suggestion.data.itemrow = Catalog.getItemRowValue(suggestion.data);
					var res = Template.parse('-cart/rest/search/layout.tpl',suggestion.data, 'SUGGESTION');

					return res;
			    }
			});
		});
	</script>
</div>
{cat::}-catalog/cat.tpl
{SUGGESTION:}
		{images.0?:img}
		<b><a href="/catalog/{producer}/{article}{:cat.idsl}">{Производитель} {Артикул}</a></b> {Цена?:cost}<br>
		<!--<a href="/catalog?m=:group::.{group}=1">{Группа}</a> <br>-->
		{itemrow}
		
		
	{cost:}<b>{~cost(Цена)}&nbsp;руб.</b>
	{img:}<img style="margin-left:5px; float:right" src="/-imager/?src={images.0}&h=60">