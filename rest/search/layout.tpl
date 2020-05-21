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
		<input value='' min="0" max="999" autosave="0" type="text" class="form-control input" style="width:100%">
	</p>
	<!--<span class="btn btn-secondary button">Добавить</span>-->
	<script type="module">
		import { CDN } from '/vendor/akiyatkin/load/CDN.js'
		import { Cart } from '/vendor/infrajs/cart/Cart.js'
		import { Global } from '/vendor/infrajs/layer-global/Global.js'
		import { Popup } from '/vendor/infrajs/popup/Popup.js'
		import { Controller } from '/vendor/infrajs/controller/src/Controller.js'
		import { Template } from '/vendor/infrajs/template/Template.js'
		
		CDN.on('load',"jquery.autocomplete").then(() => {
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
				triggerSelectOnValidInput:false,
				showNoSuggestionNotice:true,
				serviceUrl: function (q) {
					query = q;
					return '/-cart/rest/search/' + q;
				},
				onSelect: function (suggestion) {
					var pos = suggestion.data;
					prodart = pos['producer_nick'] + ' ' + pos['article_nick'];
					if (pos['id']) prodart += ' ' + pos['id'];
					Popup.confirm('Количество: <input name="count" type="number">', function (div) {
						div = $(div)
						var count = div.find('[name=count]').val();
						Cart.set('{config.place}', '{config.id}', prodart, count, async () => {
							await Cart.act('{config.place}', 'sync', '{config.id}', function(ans){
								//console.log(ans);
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
		<a href="/catalog/{producer_nick}/{article_nick}{:extend.cat.idsl}">{images.0?:img}
		{producer} {article}</a>{Наименование:br}{Цена?:cost}<br>
		<a class="float-right" href="/catalog/{group_nick}">{group}</a>
		<hr class="my-2" style="clear:both">
	{br:} <br>{.}
	{cost:} <b>{~cost(Цена)}{:extend.unit}</b>
	{img:}<img style="clear:both; margin-left:5px; float:right; position:relative" src="/-imager/?src={images.0}&h=70&w=70&crop=1">