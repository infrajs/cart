{::}vendor/infrajs/catalog/model.tpl
{CART-props:}
	<table class="props">
		<tr>
			<td class="d-flex"><nobr class="d-none d-sm-block">Производитель:</nobr><div class="line"></div></td><td>{producer}</td>
		</tr>
		<tr>
			<td class="d-flex"><nobr>Артикул:</nobr><div class="line"></div></td><td>{article}{item:pr}</td>
		</tr>
	</table>
{CARDS-basket:}
	{Цена?:basket-between}
{ROWS-basket:}
	<div style="clear:both" class="my-3 float-left">{Цена?:basket-between}</div>
{basket-between:}
	<div class="between">
		<style>
			#{div} .between .cart-basket .form-inline {
				display: flex;
				justify-content: space-between;
			}
		</style>
		{:basket}
	</div>
{basket:}
	<div class="cart-basket">
		{min?(show?:showonecost?:showitemscost)?(~length(items)?:showitemonecost?:showonecost)}
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
		let input = tag('input')
		let order_id = btn.dataset.order_id
		let model_id = btn.dataset.model_id
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
			btn.innerHTML = 'В корзину'
		}
		
		Cart.get('order', { order_id }).then( ans => {
			input.value = 0
			if (ans.result) {
				let order = ans.order
				btnoff()
				for (let pos of order.basket) {
					if (pos.model.model_id != model_id) continue
					if (pos.model.catkit != catkit) continue
					if (pos.model.item_num != item_num) continue
					input.value = pos.count
					btnon()
				}
			}
		})
		
		input.addEventListener('change', async () => {
			let count = Number(input.value)
			if (count) btnon() 
			else btnoff()
			let ans = await Cart.post('addremove', { order_id, model_id, catkit, item_num }, { count })
			if (!ans.result) return Popup.alert(ans.msg)
			DOM.puff('check')
		})
		btn.addEventListener('click', async () => {
			let count = Number(input.value)
			if (!count) count = 1
			let ans = await Cart.post('addremove', { order_id, model_id, catkit, item_num }, { count })
			if (!ans.result) return Popup.alert(ans.msg)
			Crumb.go('/cart/orders/active/list')
		});
	</script>
	{compolect:}<div style="font-size:1rem">Комплектация{iscatkit?:m}: <ul>{kit::kitlig}</ul></div>
		{kitlig:}{::kitli}
		{kitli:}<li><a href="{:link-pos}">{article}</a></li>
		{m:}<span style="color:red" title="Нестандартная комплектация">*</span>
	{showitemonecost:}
		<div class="form-inline has-success">
			<div>{:cost-one}</div>
			<a class="ml-2 my-1 btn btn-sm {~conf.cart.clsadd}" href="{:link-pos}">Выбрать</a>
		</div>
	{showonecost:}
		<div class="form-inline has-success">
			<div class="mr-2">{:cost-one}</div>
			<div class="input-group" title="Купить {producer|...producer} {article|...article} {item|...item}">
				<input type="number" value="" min="0" max="999" class="form-control" 
				style="width: 3.9em; padding-left: 6px; padding-right: 6сpx;">
				<div class="input-group-append">
					<span data-order_id="active" data-model_id="{model_id}" data-item_num="{item_num}" data-catkit="{catkit:ampval}" class="add btn input-group-addon"></span>
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