{root:}
<div class="cart-search-complete">
	<style>
		.autocomplete-suggestions { border: 1px solid #999; background: #FFF; overflow: auto; }
		.autocomplete-suggestion { padding: 2px 5px; white-space: nowrap; overflow: hidden; }
		.autocomplete-selected { background: #F0F0F0; }
		.autocomplete-suggestions strong { font-weight: normal; color: #3399FF; cursor:pointer;}
		.autocomplete-group { padding: 2px 5px; }
		.autocomplete-group strong { display: block; border-bottom: 1px solid #000; }
	</style>
	<h1>Добавить в корзину</h1>
	<!--<p><a href="/cart/{config.place}/{config.id|:my}/list">Оформление заказа {config.id}</a></p>-->
	<p>
		<input value='' min="0" max="999" autosave="0" type="text" class="formControll input" style="width:100%">
	</p>
	<!--<span class="btn btn-secondary button">Добавить</span>-->
	<script>
		domready(function () {
			//https://github.com/devbridge/jQuery-Autocomplete
			var prodart = false;
			var div = $('.cart-search-complete');
			div.find('.button').click( function () {
				if (!prodart) return;
				Cart.add('{config.place}', '{config.id}', prodart);
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
					prodart = pos['producer_nick'] + ' ' + pos['article_nick'];
					if (pos['id']) prodart += ' ' + pos['id'];
					Popup.confirm('Количество: <input name="count" type="number">', function(div){
						var count = div.find('[name=count]').val();
						Cart.set('{config.place}', '{config.id}', prodart, count, function(){
							Cart.act('{config.place}', 'sync', '{config.id}', function(ans){
								console.log(ans);
							});
							Global.check('cart');	
						});
						
					}, pos['producer'] + ' ' + pos['article'] + '<br><small>' + pos['item_nick']+'</small>');
					
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
					var res = Template.parse('-cart/rest/search/layout.tpl',suggestion.data, 'SUGGESTION');

					return res;
			    }
			});
		});
	</script>
</div>
{extend::}-catalog/extend.tpl
{SUGGESTION:}
		{images.0?:img}
		<b><a href="/catalog/{producer_nick}/{article_nick}{:extend.cat.idsl}">{producer} {article}</a></b><wbr> {Цена?:cost}<br>
		<a href="/catalog/{group_nick}">{group}</a>
		{item_nick}	
	{cost:}<b>{~cost(Цена)}{:extend.unit}</b>
	{img:}<img style="clear:both; margin-left:5px; float:right; position:relative" src="/-imager/?src={images.0}&h=60">
{JS:}
	<div>
		<style>
			.autocomplete-suggestions { border: 1px solid #999; background: #FFF; overflow: auto; }
			.autocomplete-suggestion { 
				padding: 2px 5px; 
				/*white-space: nowrap; */
				/*overflow: hidden; */
			}
			.autocomplete-selected { background: #F0F0F0; }
			.autocomplete-suggestions strong { font-weight: normal; color: #3399FF; cursor:pointer;}
			.autocomplete-group { padding: 2px 5px; }
			.autocomplete-group strong { display: block; border-bottom: 1px solid #000; }
		</style>
		<script>
			domready(function () {
				//https://github.com/devbridge/jQuery-Autocomplete
				var prodart = false;
				var div = $('#{div}');
				var query = '';
				div.find('input').autocomplete({
					triggerSelectOnValidInput:false,
					showNoSuggestionNotice:true,
					noSuggestionNotice:'<div class="p-2">По запросу ничего не найдено. Попробуйте изменить запрос или поискать по <a onclick="Crumb.go(\'/catalog\'); $(\'#{div}\').find(\'input\').blur(); return false" href="/catalog">группам</a>.</div>',
					serviceUrl: function (q) {
						query = q;
						return '/-cart/rest/search/' + q;
					},
					onSelect: function (suggestion) {
						return;
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
						var res = Template.parse('-cart/rest/search/layout.tpl',suggestion.data, 'SUGGESTION');
						return res;
				    },
				    groupBy2:'group',
				    onSearchComplete: function (suggestion) {
				    	if ($('.autocomplete-suggestion').length < 10) return;
				    	$('.autocomplete-suggestions').append('<div style="margin-left:4px; margin-top:10px" onclick="$(\'#{div} form\').submit(); $(\'#{div}\').find(\'input\').autocomplete(\'hide\')"><span class="a">Показать всё</span></div>');
				    }
				}).autocomplete('disable').click( function (){
					$(this).autocomplete('enable');
				});
			});
		</script>
	</div>