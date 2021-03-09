{::}vendor/infrajs/catalog/model.tpl?v={~conf.index.v}
{CART-props:}
	<div class="d-none d-sm-block">
		<table class="props">
			<tr>
				<td class="d-flex"><nobr>Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
			</tr>
			<tr>
				<td class="d-flex"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}{item:pr}</td>
			</tr>
		</table>
	</div>
	<div class="d-block d-sm-none">
		{producer} {article}{item:pr}
	</div>
{CARDS-basket:}
	{Цена?:basket-between}
{ROWS-basket:}
	<div style="clear:both" class="my-3 float-left">{Цена?:basket-between}</div>
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
	<script type="module" async id="scriptadd{~key}">
		import { Cart } from '/vendor/infrajs/cart/Cart.js'
		import { Global } from '/vendor/infrajs/layer-global/Global.js'
		import { Popup } from '/vendor/infrajs/popup/Popup.js'
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
			let catkit = btn.dataset.catkit
			let item_num = btn.dataset.item_num
			let btnoff = () => {
				btn.classList.add('btn-success')
				btn.classList.remove('btn-danger')
				btn.innerHTML = 'В корзину'
			}
			let btnon = () => {
				btn.classList.remove('btn-success')
				btn.classList.add('btn-danger')
				btn.innerHTML = 'Оформить'
			}
			
			Cart.get('orderfast', { order_id, place }).then( ans => {
				input.value = 0
				btnoff()
				if (!ans.result) return //Нет заказа ну чтож
				const list = ans.order.basket ?? []
				for (const pos of list) {
					if (pos.producer_nick != producer_nick) continue
					if (pos.article_nick != article_nick) continue
					if (pos.catkit != catkit) continue
					if (pos.item_num != item_num) continue
					input.value = pos.count
					btnon()
				}
			})
			
			input.addEventListener('change', async () => {
				let count = Number(input.value)
				if (count) btnon() 
				else btnoff()
				let ans = await Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count })
				if (!ans.result) return Popup.alert(ans.msg)
			})
			btn.addEventListener('click', async () => {
				let count = Number(input.value)
				
				if (!count) {
					count = 1
					input.value = 1;
					btnon();
					let ans = Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count })
					if (!(await ans).result) return Popup.alert(ans.msg)
				} else {
					let ans = Cart.post('addtoactive', { place, producer_nick, article_nick, catkit, item_num }, { count })
					Crumb.go('/cart/orders/active/list')
				}
			});
		}
	</script>
	{compolect:}<div style="font-size:1rem">Комплектация{iscatkit?:m}: <ul>{kit::kitlig}</ul></div>
		{kitlig:}{::kitli}
		{kitli:}<li><a href="{:link-pos}">{article}</a></li>
		{m:}<span style="color:red" title="Нестандартная комплектация">*</span>
	{showitemonecost:}
		<div class="form-inline has-success">
			<div>{:cost-one}</div>
			<a class="ml-2 my-1 btn btn-sm btn-success" href="{:link-pos}">Выбрать</a>
		</div>
	{showonecost:}
		<div class="form-inline has-success">
			<div class="mr-2">{:cost-one}</div>
			<div class="input-group" title="Купить {producer|...producer} {article|...article}">
				<input type="number" value="" min="0" max="999" class="form-control" 
				style="width: 3.9em; padding-left: 6px; padding-right: 6px;">
				<div class="input-group-append">
					<span data-order_id="active"  style="min-width:100px" data-producer_nick="{producer_nick}" data-article_nick="{article_nick}" data-item_num="{item_num}" data-catkit="{catkit:ampval}" class="add btn input-group-addon"></span>
				</div>
			</div>
		</div>
		<div class="bbasket" style="display:none; position: absolute; border-bottom: 1px solid var(--gray);
			    margin-left: -4px;
			    padding: 0px 4px 4px;
			    background-color: white;">
			Оформить
		</div>
	{showitemscost:}
		<div class="form-inline has-success">
			<div>{:cost-two}</div>
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>