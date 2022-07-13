{::}vendor/infrajs/catalog/model.tpl?v={~conf.index.v}
{CART-props:}
	<style media="(min-width: 768px)">.{~tid}mshow { display: none }</style>
	<style media="(max-width: 767px)">.{~tid}mhide { display: none }</style>
	<div class="{~tid}mhide">
		<table class="props">
			<tr>
				<td style="display: flex;"><nobr>Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
			</tr>
			<tr>
				<td style="display: flex;"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}{item:pr}</td>
			</tr>
		</table>
	</div>
	<div class="{~tid}mshow">
		{producer} {article}{item:pr}
	</div>
{CARDS-basket:}
	{Цена?:basket-between}
{ROWS-basket:}
	<div style="clear:both; float:left; margin-top:1rem; margin-bottom:1rem">{Цена?:basket-between}</div>
{basket-between:}
	<div class="between">
		<style>
			#{div} .between .cart-basket .form-inline {
				display: flex;
				align-items: center;
				justify-content: space-between;
			}
		</style>
		{:basket}
	</div>
{basket:}
	<div class="cart-basket">
		{min?(show?:showonecost?:showitemscost)?(~length(items)?(data.pos?:showonecost?:showitemonecost)?:showonecost)}
		{~length(kit)?:compolect}
	</div>
	{:basket-script}
{basket-script:}
	<script type="module" async id="scriptadd{~key}">
		import { Cart } from '/vendor/infrajs/cart/Cart.js'
		import { DOM } from '/vendor/akiyatkin/load/DOM.js'

		let script = document.getElementById('scriptadd{~key}')
		let div = script.previousElementSibling
		let tag = tag => div.getElementsByTagName(tag)[0]
		let cls = (cls) => div.getElementsByClassName(cls)[0]
		let btn = cls('add')
		if (btn) {
			let input = tag('input')
			const place = 'orders'
			const order_id = btn.dataset.order_id
			const producer_nick = btn.dataset.producer_nick
			const article_nick = btn.dataset.article_nick

			const name = btn.dataset.name
			const producer = btn.dataset.producer
			const cost = btn.dataset.cost
			const group = btn.dataset.group
			const article = btn.dataset.article
			const descr = { name, producer, cost, group, article }


			let catkit = btn.dataset.catkit
			let item_num = btn.dataset.item_num
			let readyGoToCart = false
			const btnclear = () => {
				btn.classList.remove('btn-danger', 'btn-success','btn-info','btn-secondary')
			}
			const btnoff = () => {
				readyGoToCart = false
				btnclear()
				btn.classList.add('btn-success')
				btn.innerHTML = 'Добавить'
			}
			const btnon = () => {
				readyGoToCart = true
				btnclear()
				btn.classList.add('btn-danger')
				btn.innerHTML = 'Оформить'
			}
			let timer
			const btnadded = (r) => {
				btnclear()
				if (r) {
					btn.innerHTML = 'Добавлено'
					btn.classList.add('btn-info')
				} else {
					btn.innerHTML = 'Удалено'
					btn.classList.add('btn-secondary')
				}
				clearTimeout(timer)
				timer = setTimeout(() => {
					if (r) btnon()
					else btnoff()
				}, 2000)
			}
			let quantity = 0
			Cart.get('orderfast', { order_id, place }).then( ans => {
				input.value = 1
				btnoff()
				if (!ans.result) return //Нет заказа ну чтож
				const list = ans.order.basket ?? []
				for (const pos of list) {
					if (pos.producer_nick != producer_nick) continue
					if (pos.article_nick != article_nick) continue
					if (pos.catkit != catkit) continue
					if (pos.item_num != item_num) continue
					input.value = pos.count
					quantity = pos.count
					btnon()
				}
			})
			
			input.addEventListener('change', async () => {
				let count = Number(input.value)
				descr.dif = count - quantity
				quantity = count
				if (count) btnon() 
				else btnoff()
				btnadded(count)

				let ans = await Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count }, descr)
				if (!ans.result) {
					const { Popup } = await import('/vendor/infrajs/popup/Popup.js')
					return Popup.alert(ans.msg)
				}
			})
			btn.addEventListener('click', async () => {
				let count = Number(input.value)
				descr.dif = quantity - count
				quantity = count
				if (!readyGoToCart || !count) {
					count = 1
					input.value = 1;
					btnon();
					let ans = await Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count }, descr)
					if (!ans.result) {
						const { Popup } = await import('/vendor/infrajs/popup/Popup.js')
						return Popup.alert(ans.msg)
					}
				} else {
					let ans = Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count }, descr)
					const { Crumb } = await import('/vendor/infrajs/controller/src/Crumb.js')
					Crumb.go('/cart/orders/active/list')
				}
			});
		}
	</script>
	{compolect:}
		<div style="font-size: 13px; margin-top:0.75rem">
			<span title="{iscatkit?:m?:mdef}">Комплектация:</span> {kit::kitlig}
		</div>
		{kitlig:}{::kitli}{~last()|:comma}
		{kitli:}<a href="{:link-pos}">{article}</a>{~last()|:comma}
		{m:}Нестандартная комплектация
		{mdef:}Стандартная комплектация
		{comma:}, 
	{showitemonecost:}
		<div style="display: flex; align-items: center; gap: 10px; justify-content: space-between;">
			<div>{:cost-one}</div>			
			<a href="{:link-pos}">Выбрать</a>
		</div>
	{showonecost:}
		<div class="{~sid}" style="display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between">
			<style>
				.{~sid} input { 
					width: 3.3em;
				}
				.{~sid} span { 
					margin-right: 0.5rem;
				}
				@media (max-width:767px) {
					.{~sid} span { 
						margin-left: auto;
						margin-bottom: 0.25rem;

					}
					.{~sid} input { 
						width: 100%;
					}
				}
			</style>
			<span>{:cost-one}</span>
			<div title="Купить {producer|...producer} {article|...article}"
				style="margin-left: auto; display: flex;position: relative; align-items: stretch;">
				<input type="number" value="" min="0" max="999"  
					style="flex-grow: 1; border-top-right-radius: 0;
    					border-bottom-right-radius: 0;
    					padding-left: 6px; padding-right: 6px;">
				
					<button 
						data-order_id="active" 
						data-producer_nick="{producer_nick}" 
						data-article_nick="{article_nick}" 
						data-item_num="{item_num}" 
						data-catkit="{catkit}" 

						data-cost="{Цена}" 
						data-producer="{producer}" 
						data-article="{article}" 
						data-name="{Наименование}" 
						data-group="{group}" 

						class="add btn"></button>
				
			</div>
		</div>
		<div class="bbasket" style="display:none; position: absolute; border-bottom: 1px solid var(--gray);
			    margin-left: -4px;
			    padding: 0px 4px 4px;
			    background-color: white;">
			Оформить
		</div>
	{showitemscost:}
		<div style="display: flex; align-items: center; gap: 10px; justify-content: space-between;">
			<div>{:cost-two}</div>
			<a href="{:link-pos}">Выбрать</a>
		</div>