{priceblock:}
	<small>Оптовая цена</small>
	<div class="text-center" style="background-color: #89B906; font-size: 20px; height: 30px; font-weight: bold; color: #ffffff;">
		{Цена оптовая?Цена оптовая:itemcost?:itemnocost}<img class="basket_img" style="float:right;" src="infra/layers/cart/images/basket_img.png">
		<style>
			img.basket_img:hover{
				background-color: #F7662C;
			}
		</style>
		<script>
		infra.listen(infrajs,'onshow',
			function(){
				$(".basket_img").hover(function(){
					$(this).attr("src", "infra/layers/cart/images/basket_active.png");
				}, 
				function(){
					$(this).attr("src", "infra/layers/cart/images/basket_img.png");
				});
			});
		</script>
	</div>
	
	<div class="posbasket" style="float:right; margin-bottom:3px; display:none">
		<small>Позиция в <a onclick="infra.require('*cart/cart.js'); cart.goTop();" href="?office/cart">корзине</a></small>
	</div>
		{itemcost:}{~cost(.)}<small> руб.</small>
	{itemnocost:}<a style="color:white" href="?Контакты менеджеров">Уточнить</a>
{priceblockall:}
	<div>
		<small>Оптовая цена</small></br>
		<b style="font-size:14px">
			{Цена оптовая?Цена оптовая:itemcost?:itemnocost}
		</b>
	</div>
	<div>
		<small>Розничная цена</small></br>
		<b style="font-size:14px">{Цена розничная?Цена розничная:itemcost?:itemnocost}</b>
	</div>
	<div data-article="{article}" data-producer="{Производитель}" class="basket_img"></div>
	<div class="posbasket" style="margin-bottom:3px; display:none">
		<small>Позиция в <a href="?office/cart">корзине</a></small>
	</div>