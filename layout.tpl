	{carttime:}
		<div style="margin-bottom:5px">
		Последний раз заказ отправлялся<br>{~date(:j F Y,data.carttime)} в {~date(:H:i,data.carttime)}<br>
		</div>
	{cartanswer:}
		<pre>{mail}</pre>
	{LISTgood:}
		<h1>Корзина <span class="float-right">{:ordernick}</span></h1>
		{(~length(data.order.basket)|data.order.status!:wait)?data.order:showlist?:emptylist}
	{LISTbad:}
		<h1>Корзина</h1>
		{:emptylist}
	{LIST:}
		{:listcrumb}
		<div style="max-width:700px">
			
			<!-- 
				Корзина есть комбинация шапок. Как это всё выбрать в шаблоне. Когда каждый вариант может ещё дополнительно параметризироваться или лучше нет.

				Если заказа ещё нет это ошибка
			-->
			{data.result?:LISTgood?:LISTbad}
		</div>

		<script type="module" async>
			import { Cart } from '/vendor/infrajs/cart/Cart.js'
			import { Popup } from '/vendor/infrajs/popup/Popup.js'

			const div = document.getElementById('{div}')
			let cls = (cls) => div.getElementsByClassName(cls)[0]
			let btn = cls('cart-search')
			let layer = {
				external: "-cart/search/layer.json"
			}
			const order_id = {:order_id}
			let place = "{:place}"

			if (btn) btn.addEventListener('click', () => {
				layer.config = { place, order_id }
				Popup.open(layer);				
			})
			
					
				
			//cart-search
			// import { Popup } from '/vendor/infrajs/popup/Popup.js'
			// let div = document.getElementById('{div}')
			// let cls = (cls) => div.getElementsByClassName(cls)[0]
			// let checkall = document.getElementById('checkall')
			// let form = document.forms.basket
			// let dels = form.elements.del
			// if (!dels) dels = []
			// else if (!dels.length) dels = [dels]
			// let order_id = {data.order.order_id}
			
			// checkall.addEventListener('click', () => {
			// 	for (let del of dels) del.checked = checkall.checked
			// })
			// cls('act-clear').addEventListener('click', async () => {
			// 	let ids = []
			// 	for (let del of dels) if (del.checked) ids.push(del.dataset.position_id)
			// 	let position_ids = ids.join(',')
			// 	if (!position_ids) return Popup.alert('Выберите позиции для удаления из корзины')
			// 	let ans = await Cart.post('remove', { order_id, position_ids })
			// 	if (!ans.result) return await Popup.alert(ans.msg)
			// 	//await Popup.success(ans.msg)
			// })
			
			
		</script>
		
		{emptylist:}
			В корзине нет товаров. {data.order?(data.order.active?:opencatalog?:searchbutton)?:opencatalog}.
			{searchbutton:}<span class="cart-search a">Добавить</span>
			{opencatalog:}<a href="/catalog">Открыть каталог</a>
		{showlist:}
			{:cartlistborder}
			{:couponinfolist}
		{couponinfolist:}
			<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
				<div class="mr-sm-3 mx-auto mx-sm-0">{:couponinp}</div>
				<div class="flex-grow-1">
					<p class="text-center text-sm-right {sumclear!sum??:d-none}">
						Сумма со скидкой: <b class="cartsum" style="font-size:140%">{sum:itemcostrub}</b> 
					</p>
					<div class="d-flex text-center text-sm-right flex-column">
						<div class="mb-2"><a href="/{crumb.parent}" style="text-decoration:none; white-space: nowrap;" class="btn btn-success">Перейти к {data.order.status!:wait?:заказу?:оформлению заказа}</a></div>
						<div>Займёт не более 3 минут.</div>
					</div>
				</div>
			</div>
		{couponinfoorder:}
			<div class="d-flex flex-column flex-sm-row justify-content-between mt-3">
				<div class="mr-sm-3 mx-auto mx-sm-0">{data.order:couponinp}</div>
				<div class="flex-grow-1">
					<p class="text-center text-sm-right {data.order.coupondata.result??:d-none}">
						Сумма со скидкой: <b class="cartsum" style="font-size:140%">{data.order.total:itemcostrub}</b>
					</p>
				</div>
			</div>
		{showcartlist:}
			{order:cartlist}
		{cartlist:}
			{:model.css}
			<div style="{:ishidedisabled}">
				<div class="d-flex justify-content-between">
					<div>
						<div class="custom-control custom-checkbox">
							<input type="checkbox" class="custom-control-input" name="checkall" id="checkall">
							<label class="custom-control-label" for="checkall">Выделенное: </label>
							<span class="act-clear a">Удалить</span>
							<script type="module" async>
								import { Cart } from '/vendor/infrajs/cart/Cart.js'
								import { Popup } from '/vendor/infrajs/popup/Popup.js'
								import { DOM } from '/vendor/akiyatkin/load/DOM.js'
								import { Global } from '/vendor/infrajs/layer-global/Global.js'

								let div = document.getElementById('{div}')
								let cls = (div, cls) => div.getElementsByClassName(cls)
								let checkall = document.getElementById('checkall')
								let form = document.forms.basket
								let dels = cls(form, 'del')
								if (!dels) dels = []
								else if (!dels.length) dels = [dels]
								const order_id = {:order_id}
								
								checkall.addEventListener('click', () => {
									for (let del of dels) del.checked = checkall.checked
								})
								cls(div, 'act-clear')[0].addEventListener('click', async () => {
									let ids = []
									for (let del of dels) if (del.checked) ids.push(del.dataset.position_id)
									let position_ids = ids.join(',')
									if (!position_ids) return Popup.alert('Выберите позиции для удаления из корзины')
									let ans = await Cart.post('remove', { order_id, position_ids })
									if (!ans.result) return await Popup.alert(ans.msg)
								})
								
								
							</script>
						</div>		
					</div>
					<div class="text-right">
						{:searchbutton}
					</div>
				</div>
			</div>
			
			<hr>
			<form class="form" name="basket" data-autosave="user">
				{basket::cartpos}
			</form>
			<div class="d-flex align-items-center justify-content-center justify-content-sm-end">
				<div class="mr-2">Сумма{sumclear!sum?:nodiscount}: </div><div style="font-size:120%; font-weight:bold" class="cartsumclear">{sumclear:itemcostrub}</div>
			</div>
			<script type="module">
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { Template } from '/vendor/infrajs/template/Template.js'
				let div = document.getElementById('{div}')
				let cls = (el, cls) => el.getElementsByClassName(cls)

				let form = document.forms.basket
				let inputs = cls(form, 'count')

				const order_id = {:order_id}
				let place = "{:place}"
				let order_nick = {data.order.order_nick}

				const tplcost = val => {
					let cost = Template.scope['~cost'](val, false, true) + '{:model.unit}'
					return cost
				}


				for (let input of inputs) {
					input.addEventListener('change', async () => {
						
						//Установили
						let cost = input.dataset.cost
						let count = input.value
						let costblock = input.closest('.costblock')
						cls(costblock, 'sum')[0].innerHTML = tplcost(count * cost)

						//Всё вместе посчитали
						let cartsum = 0;
						let cartsumclear = 0;
						for (let input of inputs) {
							let cost = input.dataset.cost
							let costclear = input.dataset.costclear
							let count = input.value
							cartsumclear += count * costclear
							cartsum += count * cost
						}
						cls(div, 'cartsum')[0].innerHTML = tplcost(cartsum) //Сумма со скидкой
						cls(div, 'cartsumclear')[0].innerHTML = tplcost(cartsumclear) //Сумма без скидки

						const position_id = input.dataset.position_id
						const ans = await Cart.post('add',{ position_id }, { count })

					})
				}
			</script>
			{false:}0
			{true:}1
		{cartlistborder:}
			<div class="border rounded p-3">
				{:cartlist}
			</div>
		{badgecoupon:}&nbsp;<span title="Скидка по купону {data.order.coupon}" class="badge badge-pill badge-danger">-{.}%</span>
		{cartpos:}
			<div class="d-flex cartpos">
				<div style="{:ishidedisabled}">
					<div class="custom-control custom-checkbox">
						<input data-position_id="{position_id}" type="checkbox" class="del custom-control-input" id="check{~key}" name="del{position_id}">
						<label class="custom-control-label" for="check{~key}">&nbsp;</label>
					</div>
				</div>
				<div class="mr-3 d-none d-lg-block" style="min-width:70px">
					{model.images.0?model:cartposimg}
				</div>
				<div class="flex-grow-1">
					<div>
						<div class="float-right">{model:model.badgenalichie}{discount:badgecoupon}</div>
						<b>{changed?:star} <a href="/catalog/{model.producer_nick}/{model.article_nick}{model:cat.idsl}">
							{model.Наименование}</a>
						</b>
					</div>
					<div class="d-flex flex-column flex-lg-row">
						{model.images.0?model:cartposimgm}
						<div class="my-2 flex-grow-1">
							{model:model.CART-props}
						</div>
						<div class="my-2 d-flex flex-column ml-lg-3 costblock">
							<div style="min-width:70px;" class="text-lg-right">
								<div><del>{cost!model.Цена?model.Цена:itemcostrub}</del></div>
								{cost:itemcostrub}
							</div>
							<div class="my-2">
								<input data-autosave="false" {:isdisabled} data-position_id="{position_id}" data-cost="{cost}" data-costclear="{model.Цена}" style="width:5em" value="{count}" type="number" min="0" max="999" class="count form-control" type="number">
							</div>
							<div style="min-width:70px;" class="text-lg-right">
								<b class="sum">{sum:itemcostrub}</b>
							</div>
						</div>
					</div>
				</div>
			</div>
			<hr>
			{nodiscount:} <nobr>без скидки</nobr>
			{cartposimg:}
				<a href="/{:cat.pospath}">
					<img class="img-thumbnail" src="/-imager/?w=60&crop=1&h=60&src={images.0}&or=-imager/empty.png">
				</a>
			{cartposimgm:}
				<a href="/{:cat.pospath}" class="my-2 mr-3 d-bock d-sm-none">
					<img class="img-thumbnail" src="/-imager/?h=100&src={images.0}&or=-imager/empty.png">
				</a>
	{ORDER:}
		{:ordercrumb}
		<div style="max-width:500px">
			{data.result??:ordermessage}
			{~length(data.order.basket)|data.order.status!:wait?data.order:ordercontent?:emptyorder}
		</div>	
		
		{ordermessage:}
			<h1>Ошибка</h1>
			{data.msg}
		{emptyorder:}
			<h1>{data.rule.title} <span class="float-right">{:ordernick}</span></h1>
			{:emptylist}
		{showManageComment:}
			<div style="margin-top:10px; margin-bottom:10px;" class="alert alert-success" role="alert"><b>Сообщение менеджера</b>
				<pre style="margin:0; padding:0; font-family: inherit; background:none; border:none; white-space: pre-wrap">{commentmanager}</pre>
			</div>
		{paylayout::}-cart/sbrfpay/layout.tpl
		{checked:}checked
		{ordernick:}№{data.order.order_nick}
		{orderedit:}<div class="float-right" title="Последние измения">{~date(:j F H:i,order.dateedit)}</div>
		{autosavename:}{:place}.{order_nick}
		
					
		{transportradio:}
			<div class="mt-1 line" style="color: {...transport=type?:black}; font-weight:{...transport=type?:600}">
				<div class="d-flex">
					<div class="form-check flex-grow-1">
						<input {:isdisabled} class="form-check-input" type="radio" name="transport" {...transport=type?:checked} id="transport_{type}" 
						data-cost="{cost}" value="{type}">
						<label class="ml-1 form-check-label" for="transport_{type}">
							{:label_{type}_short}
						</label>
					</div>
					{type!:self?:transprice}
				</div>
				<div class="descr {...transport=type?:show}">
					{:descr_{type}}
				</div>
			</div>
		{pochtalogo:}
			<div class="mt-2 mb-2"><img alt="Почта России" src="/-imager/?w=75&src=-cart/images/pochtabig.png"></div>
		{cdeklogo:}
			<div class="mb-2"><img alt="СДЕК" src="/-imager/?w=75&src=-cart/images/cdekline.png"></div>
		{hometown:}
			<div class="mb-3">
				<div class="mb-2"><img src="/-imager/?w=75&src=images/logo.png"></div>
				{transports.self:transportradio}
				{transports.city:transportradio}
			</div>
		{ordercontent:}
			{status=:wait??:orderedit}
			<form name="cart" class="form" data-autosave2="{data.rule.actions[:place]edit?:autosavename}">
				<h1>{data.rule.title} <span class="float-right">{:ordernick}</span></h1>
				{commentmanager?:showManageComment}
				{:paylayout.INFO}
				
				
				<!-- <h2>Данные о покупателе</h2> -->
				<div class="border px-5 py-4 my-4">
					<div class="form-group input-name">
						<label class="w-100">Имя получателя{:req} <i class="msg float-right"></i></label>
						<input reaqired {:isdisabled} type="text" name="name" value="{data.order.name}" class="form-control" placeholder="Иванов Иван">
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
							const block = cls('input-name')
							const msg = cls('msg', block)
							const input = form.elements.name
							const order_id = {:order_id}
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								msg.innerHTML = '...'
								msg.style.color = "black"
								const name = Cart.strip_tags(input.value)
								cls('nameresume').innerHTML = name ? ', ' + name : ''
								const ans = await Cart.posts('setname', { order_id }, { name })
								msg.innerHTML = ans.msg
								if (ans.result) msg.style.color = "green"
								else msg.style.color = "red"
							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						</script>
					</div>
					<div class="form-group input-phone">
						<label class="w-100">Телефон для связи{:req} <i class="msg float-right"></i></label>
						<input reaqired {:isdisabled} type="tel" name="phone"  value="{data.order.phone}" class="form-control" placeholder="+7 ...">
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
							const block = cls('input-phone')
							const msg = cls('msg', block)
							const input = form.elements.phone
							const order_id = {:order_id}
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								msg.innerHTML = '...'
								msg.style.color = "black"
								const phone = Cart.strip_tags(input.value)
								cls('phoneresume').innerHTML = phone ? ', ' + phone : ''
								const ans = await Cart.posts('setphone', { order_id }, { phone })
								msg.innerHTML = ans.msg
								if (ans.result) msg.style.color = "green"
								else msg.style.color = "red"
							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						</script>
					</div>
					<div class="form-group input-email">
						<label class="w-100">Email для оповещений{:req} <i class="msg float-right"></i></label>
						<input reaqired {:isdisabled} type="email" name="email" value="{data.order.email}" class="form-control" placeholder="...@...">
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							import { Session } from '/vendor/infrajs/session/Session.js'
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
							const block = cls('input-email')
							const msg = cls('msg', block)
							const input = form.elements.email
							const order_id = {:order_id}
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								msg.innerHTML = '...'
								msg.style.color = "black"
								const email = Cart.strip_tags(input.value)
								Session.set('user.email', email)
								cls('emailresume').innerHTML = email ? ', '+email : ''
								const ans = await Cart.posts('setemail', { order_id }, { email })
								msg.innerHTML = ans.msg
								if (ans.result) msg.style.color = "green"
								else msg.style.color = "red"

							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						</script>
					</div>
				</div>
				<h2>Доставка в город <span class="{:isedit?:a} citychoice">{data.order.city.city}<span></h2>
				<div class="border px-5 py-4 my-4 transblock" style="color:#444">
					<style>
						.transblock input,
						.transblock label,
						.transblock .line {
							cursor: pointer
						}
						.transblock .descr {
							padding-bottom:1px;
						}
						.transblock .descr {
							max-height: 0;
							opacity: 0;
							overflow: hidden;
							transition-property: margin-top, opacity, max-height;
							transition-duration: 0.2s;
						}
						.transblock .descr.show {
							display: block;
							opacity: 1;
							max-height: 100px;
						}
					</style>
					{city.city_id=Config.get().cart.city_from_id?:hometown}
					
					
					{transports.cdek_pvz?:cdeklogo}
					{transports.cdek_pvz:transportradio}
					{transports.cdek_courier:transportradio}
					
					{transports.pochta_simple?:pochtalogo}
					{transports.pochta_simple:transportradio}
					{transports.pochta_1:transportradio}
					{transports.pochta_courier:transportradio}
					<script type="module" async>
						import { Cart } from '/vendor/infrajs/cart/Cart.js'
						const form = document.forms.cart
						const cls = (cls, div = form) => div.getElementsByClassName(cls)
						const blocks = cls('input-zip')
						const order_id = {:order_id}
						for (const block of blocks) {
							const select = cls('zip', block)[0]
							const change = async () => {
								const n = select.options.selectedIndex
								const zip = select.options[n].value
								if (Cart.dis(form)) return
								const ans = await Cart.post('setzip', { order_id, zip })
								if (!ans.result) Popup.alert(ans.msg)								
								
							}
							//input.addEventListener('change', change)
							select.addEventListener('change', change)
						}
					</script>
					<script type="module" async>
						import { Cart } from '/vendor/infrajs/cart/Cart.js'
						import { CDEK } from '/vendor/akiyatkin/cdek/CDEK.js'
						import { Popup } from '/vendor/infrajs/popup/Popup.js'
						import { Load } from '/vendor/akiyatkin/load/Load.js'

						const form = document.forms.cart
						const cls = (cls, div = form) => div.getElementsByClassName(cls)
						const order_id = {:order_id}
						const btn = cls('showpvz')[0]
						if (btn) btn.addEventListener('click', async () => {

							//Global.set не сбарывает загрузку, а загрузка уже есть
							//слой перепарсивается с кэшем
							//чтобы этого не было надо прежде чем вызывать Global.set
							//быть уверен что все пути уже добавились в Global.unload
							Global.unload('cart-order','{json}')
							const ans = await Load.fire('json','{json}')
							if (!ans.result) Popup.alert(ans.msg)
							const order = ans.order
							CDEK.open(order)
						})
						
					</script>
					
					<script type="module" async>
						import { Cart } from '/vendor/infrajs/cart/Cart.js'
						import { Template } from '/vendor/infrajs/template/Template.js'

						const form = document.forms.cart
						const cls = (cls, div = form) => div.getElementsByClassName(cls)
						const blocks = cls('input-address')
						const order_id = {:order_id}
						for (const block of blocks) {
							const msg = cls('msg', block)[0]
							const input = cls('address', block)[0]
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								
								const address = input.value
								for (const block of blocks) {
									const input = cls('address', block)[0]
									const msg = cls('msg', block)[0]
									msg.innerHTML = '...'
									msg.style.color = "black"
									input.value = address
								}

								const transport = form.elements.transport.value || 'self'
								let data = {
									"city":{
										"city":"{data.order.city.city}"
									},
									"address":cls('address',form)[0].value,
									"zip":"{data.order.zip}",
									"pvz":"{data.order.pvz}"
								}
								const transresume = cls('transresume')[0]
								if (transresume) transresume.innerHTML = Template.parse("{tpl}", data, "info_" + transport)

								const ans = await Cart.posts('setaddress', { order_id }, { address })

								for (const block of blocks) {
									const input = cls('address', block)[0]
									const msg = cls('msg', block)[0]
									msg.innerHTML = ans.msg
									if (ans.result) msg.style.color = "green"
									else msg.style.color = "red"
								}
							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						}
					</script>
					<script type="module" async>
						import { Cart } from '/vendor/infrajs/cart/Cart.js'
						import { Popup } from '/vendor/infrajs/popup/Popup.js'
						import { Global } from '/vendor/infrajs/layer-global/Global.js'
						import { Template } from '/vendor/infrajs/template/Template.js'
						import { Layer } from '/vendor/infrajs/controller/src/Layer.js'

						const form = document.forms.cart
						const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
						const transblock = cls('transblock')
						const tag = (tag, div = form) => div.getElementsByTagName(tag)[0]
						const clss = (cls, div = form) => div.getElementsByClassName(cls)
						const radios = form.elements.transport
						const order_id = {:order_id}
						const sum = {data.order.sum}
						const lines = clss('line')
						const isedit = {:isedit?:true?:false}

						const tplcost = val => {
							let cost = Template.scope['~cost'](val) + '{:model.unit}'
							return cost
						}
						const map = cls('showMap', transblock)

						if (map) map.addEventListener('click', () => {
							Popup.showbig(Cart.maplayer)
						})

						const descrs = clss('descr', transblock)
						let lasttransport = "{data.order.transport}"
						const change = async () => {
							if (!isedit) return
							const transport = radios.value
							if (lasttransport == transport) return
							lasttransport = transport
							const radio = form.elements['transport_' + transport]
							const sumtrans = Number(radio.dataset.cost)
							const total = sum + sumtrans

							for (const line of lines) {
								line.style.color = ''
								line.style.fontWeight = ''
							}
							const line = radio.closest('.line')
							if (line) {
								line.style.color = 'black'
								line.style.fontWeight = '600'
							}
							for(const descr of descrs) descr.classList.remove('show')
							const descr = cls('descr', line)
							if(descr) descr.classList.add('show')

							let span = cls('sumtrans')
							if (span) span.innerHTML = tplcost(sumtrans)

							span = cls('total')
							if (span) span.innerHTML = tplcost(total)

							span = cls('titletrans')
							if (span) span.innerHTML = Template.parse("{tpl}", true, "label_" + transport)
							let data = {
								"city":{
									"city":"{data.order.city.city}"
								},
								"address":cls('address',form).value,
								"zip":"{data.order.zip}",
								"pvz":"{data.order.pvz}"
							}

							const transresume = clss('transresume')[0]
							if (transresume) transresume.innerHTML = Template.parse("{tpl}", data, "info_" + transport)

							const ans = await Cart.posts('settransport', { order_id }, { transport })
							if (!ans.result) await Popup.alert(ans.msg)
						}
						for (const radio of radios) radio.addEventListener('change', change)
						for (const line of lines) line.addEventListener('click', () => {
							if (!isedit) return
							let radio = tag('input', line)
							radio.checked = true
							change()
						})
					</script>
				</div>
				<script type="module" async>
					//Всплывающее окно выбора города с классом citychoice
					import { City } from "/vendor/akiyatkin/city/City.js"
					import { Cart } from '/vendor/infrajs/cart/Cart.js'
					import { Global } from '/vendor/infrajs/layer-global/Global.js'

					const isedit = {:isedit?:true?:false}
					if (isedit) {
						const div = document.getElementById('{div}')
						const form = document.forms.cart
						const cls = (cls) => form.getElementsByClassName(cls)
						const order_id = {:order_id}
						const place = "{:place}"
						const old_city_id = {data.order.city.city_id|:false}
						for (const btn of cls('citychoice')) {
							btn.addEventListener('click', async () => {
								if (Cart.dis(form)) return
								const city_id = await City.choice()
								if (city_id !== null && city_id != old_city_id) {
									//const zip = ''
									//await Cart.post('setzip', { order_id }, { zip })
									await Cart.post('setcity', { order_id }, { city_id })
									Global.check('cart-order')
								} else {
									Cart.dis(form, false)
								}
							})
						}
					}
				</script>
				<h2>Оплата</h2>
				<div class="my-4 d-flex">
					<div class="flex-grow-1 input-comment">
						<div class="mb-2">Комментарий к заказу <i class="msg float-right"></i></div>
						<textarea {:isdisabled} name="comment" class="form-control" rows="3">{data.order.comment}</textarea>
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
							const block = cls('input-comment')
							const msg = cls('msg', block)
							const input = form.elements.comment
							const order_id = {:order_id}
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								msg.innerHTML = '...'
								msg.style.color = "black"
								const comment = Cart.strip_tags(input.value)
								cls('commentresume').innerHTML = comment
								const ans = await Cart.posts('setcomment', { order_id }, { comment })
								msg.innerHTML = ans.msg
								if (ans.result) msg.style.color = "green"
								else msg.style.color = "red"

							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						</script>
					</div>
					<div class="ml-3">
						<div class="mb-1 callback-title" style="cursor: pointer">Звонок менеджера</div>
						<div class="form-check mt-1">
							<input data-autosave="false" {:isdisabled} class="form-check-input" type="radio" name="callback" {callback=:yes?:checked} id="exampleRadios1" value="yes">
							<label class="ml-1 form-check-label" for="exampleRadios1">
								Нужен для уточнения деталей.
							</label>
						</div>
						<div class="form-check mt-1">
							<input data-autosave="false" {:isdisabled} class="form-check-input" type="radio" name="callback" {callback=:no?:checked} id="exampleRadios2" value="no">
							<label class="ml-1 form-check-label" for="exampleRadios2">
								Не нужен, информация<br>по заказу понятна.
							</label>
						</div>
						<script type="module">
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							import { Popup } from '/vendor/infrajs/popup/Popup.js'

							let div = document.getElementById('{div}')
							const cls = (cls) => div.getElementsByClassName(cls)[0]
							let radios = document.forms.cart.elements.callback					
							const order_id = {:order_id}
							let order_nick = {data.order.order_nick}
							let place = "{:place}"
							let isedit = {:isedit?:true?:false}
							let title = cls('callback-title')
							let oldcallback = "{data.order.callback}"
							const change = async () => {
								if (!isedit) return
								let callback = radios.value
								if (callback == oldcallback) return
								oldcallback = callback
								cls('callresume').innerHTML = Template.parse("{tpl}", callback, "callbackresume")
								let ans = await Cart.posts('setcallback', { order_id }, { callback })
								if (!ans.result) await Popup.alert(ans.msg)
							}
							title.addEventListener('click', () => {
								if (!isedit) return
								for (const radio of radios) radio.checked = false
								radios.value = ''
								change()
							})
							
							for (let radio of radios) radio.addEventListener('change', change)
						</script>
					</div>
				</div>
				{:resume}

				{:place=:admin?:adminactions?:useractions}
				<div class="d-md-none" style="clear:both"></div>	
				{data.fields.pay.Оплатить онлайн?:paydescr}
			</form>
			{zipopt:}<option {.=data.order.zip?:selected}>{.}</option>
			{transprice:}
				<div class="d-flex" style="width:140px">
					<div style="width:70px">{min=max?:oneday?:twodays} {~words(max,:день,:дня,:дней)}</div>
					<div style="color:{cost=:0?:red}">{~cost(cost)}{:model.unit}</div>
				</div>
				{twodays:}{min}-{max}
				{oneday:}{max}
			{place:}{Crumb.child.child.name=:admin?:admin?:orders}
			{paydescr:}
				<div id="paydescr">
					<style>
						#paydescr {
							display: none
						}
					</style>
					{order:paylayout.DESCR}
				</div>
				<script type="module">
					import { Cart } from '/vendor/infrajs/cart/Cart.js'
					let info = document.getElementById('paydescr')
					Cart.done('choicepay', value => {
						if (value == 'Оплатить онлайн') {
							info.style.display = 'block'
						} else {
							info.style.display = 'none'
						}
					})
				</script>
		{resume:}
			<div class="alert alert-secondary">
				<b>№{order_nick}</b><span class="nameresume">{name:pr-comma}</span><span class="phoneresume">{phone:pr-comma}</span><span class="callresume">{callback:callbackresume}</span><span class="emailresume">{email:pr-comma}</span>, {~length(basket)} {~words(~length(basket),:позиция,:позиции,:позиций)}
				<pre style="white-space:pre-line; margin-top:4px; font-style: italic; font-size: 100%;" class="commentresume">{comment}</pre>
				<hr>
				{:basketresume}
				<hr>
				{:amount}
			</div>
		{callbackresume:}{.?(.=:yes?:callneed?:callnoneed):pr-comma}
			{yes:}yes
			{callneed:}требуется звонок
			{callnoneed:}вопросов нет
		{useractions:}
			<style>
				.act-sbrfpay {
					display: none
				}
				.act-paykeeper {
					display: none
				}
			</style>
			<div class="myactions" data-place="orders">
				{data.rule.actions[:place]:myactions}
			</div>
		
			<script type="module">
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				
				let div = document.getElementById('{div}')
				let cls = (cls, el = div) => el.getElementsByClassName(cls)
				
				let actionsbtn = cls('actionsbtn')[0]
				let paybtn = cls('act-sbrfpay', actionsbtn)[0]
				if (!paybtn) cls('act-paykeeper', actionsbtn)[0]
				let checkbtn = cls('act-check', actionsbtn)[0]

				Cart.hand('choicepay', (value) => {

					if (!actionsbtn.closest('html')) return
					let is = (value == 'Оплатить онлайн')


					if (is) {
						for (let act of cls('act-check')) act.style.display = 'none'
						for (let act of cls('act-sbrfpay')) act.style.display = 'block'
						for (let act of cls('act-paykeeper')) act.style.display = 'block'
					} else {
						for (let act of cls('act-sbrfpay')) act.style.display = 'none'
						for (let act of cls('act-paykeeper')) act.style.display = 'none'
						for (let act of cls('act-check')) act.style.display = 'block'
					}

					if (checkbtn && paybtn) {
						if (is) actionsbtn.insertBefore(checkbtn, paybtn)
						else actionsbtn.insertBefore(paybtn, checkbtn)
					}
					
					
				})
			</script>
		{adminactions:}
			<div class="myactions" data-place="admin">
				<p>Письмо клиенту {order.emailtime?:wasemail?:noemail}</p>
				{data.rule.actions[:place]:myactions}
			</div>
		{transcardsimple:}
		<div class="row">
			<div class="col-12">
				<div class="form-group">
					<label>Адрес</label>
					<input {:isdisabled} type="text" name="transport.address" value="{data.order.transport.address}" class="form-control" placeholder="">
				</div>
			</div>
			<div class="col-12">
				<div class="form-group">
					<label>Серия и номер паспорта для транспортной компании</label>
					<input {:isdisabled} type="text" name="transport.passeriya"  value="{data.order.transport.passeriya}" class="form-control">
				</div>
			</div>
		</div>
		{paycardsimple:}
			<div class="row">
				<div class="col-12">
					<div class="form-group">
						<label>Выберите способ оплаты{:req}</label>
						<select {:isdisabled} value="{transport.cargo}" name="transport.cargo" class="custom-select form-control">
							<option></option>
							<option {(:Банк):caropt}>Банковский перевод для юр.лиц</option>
							<option {(:Наличные):caropt}>Оплата картой VISA или MASTERCARD</option>
							<option {(:Самовывоз):caropt}>Оплата при получении товара</option>
							<option {(:Самовывоз):caropt}>Оплата в магазине</option>
						</select>
					</div>
				</div>
				<div class="col-12">
					<div class="form-group">
						<label>Дополнительная информация</label>
						<textarea name="pay.paycomment" class="form-control">{data.order.pay.paycomment}</textarea>
					</div>
				</div>
			</div>
			{caropt:}{data.order.transport.cargo=.?:selected} value="{.}" 
		{transcard:}
			<div class="transportcard" 
				data-name="transport" 
				data-value="{data.order.transport.choice}"
				data-editable="{data.order.rule.edit[data.place]?:yes}"
				data-autosave="{autosavename}">
				<div class="d-flex flex-wrap" style="font-size:11px">
					{fields.transport::trans}
				</div>
				{fields.transport::transinfo}
			</div>

			<script type="module">
				import { Load } from '/vendor/akiyatkin/load/Load.js'
				import { Autosave } from '/vendor/akiyatkin/form/Autosave.js'
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { CDN } from '/vendor/akiyatkin/load/CDN.js'

				let div = document.getElementById('{div}')
				let cls = cls => div.getElementsByClassName(cls)
				let cards = cls('transportcard')[0]

				Cart.initChoiceBtn(cards)

				CDN.fire('load','jquery').then(async () => {
					var tcard = $('.transportcard');
					var pcard = $('.paycard');
					tcard.find('.item').click( async () => {
						let value = await Autosave.get("{autosavename}", 'transport.choice');
						pcard.find('.item').css('display','');
						if (!value) return;
						let data = await Load.on('json','{json}');
						if (!data) return;
						
						if (!data.fields.transport[value] || !data.fields.transport[value].hide) return;
						var hide = data.fields.transport[value].hide;
						var payvalue = await Autosave.get("{autosavename}", 'pay.choice');

						
						if (~hide.indexOf(payvalue)) {
							pcard.find('.item').each(function(){
								var val = $(this).data('value');
								if (val == payvalue) $(this).click(); //отменили выбор
							});
						}
						
						pcard.find('.item').each(function(){
							var val = $(this).data('value');
							if (~hide.indexOf(val)) {
								$(this).hide();//Скрыли кнопку
							}
						})
					})
				})
			</script>
			{trans:}
			<div data-value="{~key}" class="item text-left">
				<div class="body d-flex flex-column rounded m-1 px-2 p-1">
					<div class="d-flex mb-auto title">
						<div><img class="mr-1" src="/-imager/?w=40&src={ico}"></div><div style="text-transform: uppercase;">{~key}</div>
					</div>
					<div>
						<b>{cost}</b><br>
						{term} 
					</div>
				</div>
			</div>
{paycard:}
	<div class="paycard" 
		data-name="pay" 
		data-autosave="{autosavename}"
		data-value="{data.order.pay.choice|data.fields.paydefault}"
		data-editable="{data.order.rule.edit[data.place]?:yes}">
		<div class="d-flex flex-wrap m-n2" style="font-size:11px">
			{fields.pay::pay}
		</div>
	</div>
	<script type="module">
		import { Cart } from '/vendor/infrajs/cart/Cart.js'

		let div = document.getElementById('{div}')
		let cls = cls => div.getElementsByClassName(cls)
		let cards = cls('paycard')[0]
		Cart.initChoiceBtn(cards)
		
	</script>
	{paybig:}
		<div data-value="{~key}" class="item m-2">
			<div style="height:145px" class="body {data.order.rule.edit[data.place]??:disabled} rounded d-flex align-items-center justify-content-center">
				<img style="{icostyle}" class="img-fluid" src="/-imager/?h=124&src={ico}">
			</div>
			<div class="title"><big>{title|~key}</big></div>
		</div>
	{pay:}
		<div data-value="{~key}" class="item m-2">
			<div style="height:100px;" class="body {data.order.rule.edit[data.place]??:disabled} rounded d-flex align-items-center justify-content-center">		
			<img style="{icostyle}" class="img-fluid" src="/-imager/?h=80&w=135&src={ico}">
			</div>
			<div class="title"><big>{title|~key}</big></div>
		</div>	
	{disabled:}disabled
	{transinfo:}
			<div data-value="{~key}" class="pt-2 iteminfo">{:basket.fields.{tpl}}</div>
	{payinfo:}
			<div data-value="{~key}" class="pt-2 iteminfo"><div class="m-1 alert border more">{:basket.fields.{tpl}}</div></div>
		{myactions:}
			<div class="my-4">
				<div class="btn-toolbar float-right" role="toolbar">
					<!-- <div class="btn-group dropup">
						<button class="btn btn-secondary dropdown-toggle" id="dropdownActionMenu" type="button" data-toggle="dropdown">
							
						</button>
						<div class="dropdown-menu" role="menu" aria-labelledby="dropdownActionMenu">
							{actions::actprint}
						</div>	
					</div> -->
					<div class="btn-group actionsbtn">
						{buttons::mybtns}
					</div>
				</div>
			</div>
			<script type="module">
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { Popup } from '/vendor/infrajs/popup/Popup.js'
				import { DOM } from '/vendor/akiyatkin/load/DOM.js'
				import { Global } from '/vendor/infrajs/layer-global/Global.js'
				import { Template } from '/vendor/infrajs/template/Template.js'

				let div = document.getElementById('{div}')
				let cls = cls => div.getElementsByClassName(cls)[0]
				let clss = cls => div.getElementsByClassName(cls)
				let tag = tag => div.getElementsByTagName(tag)[0]
				let form = document.forms.cart
				let btn = null;
				const order_id = {:order_id}
				let order_nick = {data.order.order_nick}
				let place = "{:place}"
				let isedit = {:isedit?:true?:false}
				
				
				btn = cls('act-check')
				if (btn) btn.addEventListener('click', async () => {
					if (Cart.dis(form)) return
					let ans = await Cart.post('check', { order_id })
					if (!ans.result) {
						await Popup.alert(ans.msg)
					} else {
						await Popup.success(ans.msg)
						await Crumb.go('/cart')	
					}
				})
				btn = cls('act-tocheck')
				if (btn) btn.addEventListener('click', async () => {
					if (Cart.dis(form)) return
					let ans = await Cart.post('tocheck', { order_id })
					if (!ans.result) {
						await Popup.alert(ans.msg)
					}
				})

				btn = cls('act-basket')
				if (btn) btn.addEventListener('click', async () => {						
					if (Cart.dis(form)) return
					Crumb.go('/cart/'+place+'/'+order_nick+'/list')
					Cart.dis(form, false)
				})

				btn = cls('act-complete')
				if (btn) btn.addEventListener('click', async () => {
					if (Cart.dis(form)) return
					const ans = await Cart.post('complete', { order_id })
					if (!ans.result) return Popup.alert(ans.msg)
				})

				btn = cls('act-wait')
				if (btn) btn.addEventListener('click', async () => {	
					if (Cart.dis(form)) return
					const ans = await Cart.post('wait', { order_id })
					if (!ans.result) return Popup.alert(ans.msg)
				})

				btn = cls('act-delete')
				if (btn) btn.addEventListener('click', async () => {
					if (Cart.dis(form)) return
					Popup.confirm('Крайний вариант. Зказ бесследно исчезнет. Удалить?', async () => {
						const ans = await Cart.post('delete', { order_id })
						if (!ans.result) {
							return Popup.alert(ans.msg)	
						} else {
							Popup.success(ans.msg)
							Crumb.go('/cart/'+place)
						}
					})
				})

				btn = cls('act-email')
				if (btn) btn.addEventListener('click', async () => {	
					Popup.confirm(Template.parse("-cart/layout.tpl", {
						"commentmanager":{~json(data.order.commentmanager)},
						"email":{~json(data.order.email)},
						"order_id":order_id,
						"order_nick":{~json(data.order.order_nick)},
						"dateemail":{~json(data.order.dateemail)}
					}, "EMAIL"), async () => {
						const block = document.getElementsByClassName('input-commentmanager')[0]
						const textarea = block.getElementsByTagName('textarea')[0]
						const commentmanager = textarea.value
						const ans = await Cart.post('email', { order_id }, { commentmanager })
						if (!ans.result) Popup.alert(ans.msg)
						else Popup.success(ans.msg)
					})
					
				})

				btn = cls('act-print') 
				if (btn) btn.addEventListener('click', async () => {	
					if (Cart.dis(form)) return
					await Crumb.go('/cart/'+place+'/'+order_nick+'/print')
					Cart.dis(form, false)
				})
			</script>
			{mybtns:}
				<div class="act-{~key} btn btn-{cls}">
					{title}
				</div>
			{actprint:}
				<div class="dropdown-item act-{act}" style="cursor:pointer" data-id="{data.order.order_id}">
					{title}
				</div>
				{actact:}/{crumb}
		{b:}<b>
		{/b:}</b>
		{noProducts:}
			<h3>В заказе нет товаров</h3>
			<p align="right">
				<a href="/{crumb}/list">Редактировать корзину</a><br>
				<span data-id="{data.order.order_id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span>
			</p>
	{dateFormat:}d.m.Y h:i:s
{COUPONCHECK:}
	<div class="input-coupon">
		<div style="max-width: 300px;" class="input-group">
			<input name="coupon" type="text" class="form-control" placeholder="Купон">
			<div class="input-group-append">
			    <button class="btn btn-secondary" type="button">Проверить</button>
			    <script type="module" async>
					import { Template } from '/vendor/infrajs/template/Template.js'

			    	const cls = (div, cls) => div.getElementsByClassName(cls)[0]
			    	const div = cls(document, 'input-coupon')
			    	const coupinfo = cls(div, 'coupinfo')
			    	const input = cls(div, 'form-control')
			    	const btn = cls(div, 'btn')
			    	btn.addEventListener('click', () => {
			    		let name = input.value
				    	fetch('/-cart/coupon?name=' + name).then(req => req.json()).then(async coupon => {
				    		coupinfo.innerHTML = Template.parse('-cart/layout.tpl', coupon, 'coupinfo');
				    	})
			    	})
			    </script>
			</div>
		</div>
		<div class="py-2 coupinfo"></div>
	</div>
	{coupinfo:}
		{result?:coupinfoshow?:coupinfoerr}
	{coupinfoerr:}{Купон?:coupinfoerr1}
		{coupinfoerr1:}<div class="alert alert-danger"><b>{Купон}</b> &mdash; купон не найден или устарел.</div>
		{coupinfoerr2:}<div class="alert alert-danger">Укажите код купона.</div>
	{coupinfoshow:}<div class="alert alert-success">
			<b>{Купон}</b> &mdash; купон найден. Скидка до <b>{~multi(Скидка,:100)}%</b>. 
			<br>Скидка не действует на товары участвующие в других акциях и распродажах. 
			{(Производители|Группы)?:clim}
			<!--<br>Точную стоимость укажет менеджер после проверки.-->
		</div>
	{clim:}<br>Есть ограничения по группам и производителям.
	{cprod:}<br>Производители: <b>{Производители}</b>.
	{cgroup:}<br>Группы: <b>{Группы}</b>.
	{100:}100
	{d-none:}d-none
	{couponinp:}
		<div style="max-width: 300px;" class="input-group">
			<input name="coupon" data-autosave="false" {:isdisabled} value="{data.order.coupon}" type="text" class="form-control" id="coupon" placeholder="Укажите купон">
			<div class="input-group-append">
			    <button class="couponbtn btn btn-secondary" type="button">Активировать</button>
			</div>
		</div>
		<script type="module">
			import { Cart } from '/vendor/infrajs/cart/Cart.js'
			import { DOM } from '/vendor/akiyatkin/load/DOM.js'
			let div = document.getElementById('{div}')
			let cls = cls => div.getElementsByClassName(cls)
			let btn = cls('couponbtn')[0]
			let input = document.getElementById('coupon')

			btn.addEventListener('click', async () => {
				const order_id = {:order_id}
				let coupon = Cart.strip_tags(input.value)
				if (Cart.dis(form)) return
				await Cart.post('setcoupon', { order_id, coupon })
			})
		</script>
		<div class="py-2">
			{coupondata:coupinfo}
		</div>
		{prodart:}{producer_nick} {article_nick}{:cat.idsp}
		{mybasket:}Ваша корзина
		{justbasket:}Корзина
		{numbasket:}Корзина <span class="float-right">{:ordernick}</span>
		
	{cartmsg:}<p>Корзина пустая. Добавьте в корзину интересующие позиции.
			
			</p>
			<p>Чтобы добавить позицию нужно кликнуть по иконке корзины рядом с ценой в <a href="/catalog">каталог</a>.</p>
			<span data-id="{data.order.order_id}" data-place="{crumb.parent.parent.name}" class="cart-search a float-right">Поиск позиций</span>
			<div style="margin-top:10px">
				<a href="/catalog" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
			</div>
	{itemnocost:}<a href="/contacts">Уточнить</a>
	{RBREAD:}
		<ul class="breadcrumb cart">
			{data.email?:breaduser?:breadguest}
			<span onclick="Cart.refresh(this)" class="btn btn-secondary btn-sm float-right"><span class="pe-7s-refresh"></span></span>
		</ul>
		{breaduser:}
			<li class="breadcrumb-item"><a href="/user">{data.email|:Профиль}</a></li>
			<li class="breadcrumb-item"><a href="/cart/orders/active/list">Корзина</a></li>
		{breadguest:}
			<li class="breadcrumb-item"><a href="/user/signin?back=ref">Вход</a></li>
			<li class="breadcrumb-item"><a href="/user/signup?back=ref">Регистрация</a></li>
			<li class="breadcrumb-item"><a href="/user/remind">Напомнить пароль</a></li>
	{CART:}
		{:usercrumb}
		<h1>Личный кабинет</h1>
		{data.user.email?:account?:noaccount}
		<!--<p><a href="/cart/orders">Мои заказы</a></p>-->
		<p>{~length(data.list)?:showinfo?:showempty}</p>
		
		{showempty:}
			В Вашей корзине нет <a href="/catalog">товаров</a>.
		{showinfo:}
			<h2>Ваши заказы</h2>
			<style>
				#{div} .circle {
					border-radius:50%;
					display:inline-block;
					border: solid 1px gray;
					min-width:20px;
					text-align:center;
					padding:0 2px;
				}
			</style>
			<table class="table table-striped">
				{data.list::orderinfo}
			</table>
		{orderinfo:}
			<tr class="{data.rules.rules[~key].notice}">
				<td><a href="/cart/orders/{order_nick}">{order_nick}</a></td>
				<td>{(status=:wait&active)?data.meta.rules[status]shortactive?data.meta.rules[status]short}</td>
				<td>{~cost(sum)}{:model.unit}&nbsp;&nbsp;<span class="circle">{~length(basket)}</span></td>
				<td>{~date(:d.m.Y,dateedit)}</td>
			</tr>
		{br:}<br>
		{noaccount:}
			<p>
				<b><a href="/user/signin?back=ref">Вход</a> не выполнен!</b>
			</p>
		{account:}
			<p>
				<div class="logout float-right btn btn-sm btn-secondary">Выход</div>
				<script type="module" async>
					import { User } from "/vendor/infrajs/user/User.js"
					const div = document.getElementById('{div}');
					const btn = div.getElementsByClassName('logout')[0]
					btn.addEventListener('click', () => {
						User.logout()
					})
				</script>
				Пользователь <a href="/user"><b>{data.user.email}.</b></a> 
			</p>
			{data.user.admin?:mngControl}
		{mngControl:}
			<p>
				<a class="text-danger" href="/cart/admin">Все заказы</a><!-- , <a class="text-danger" href="/user/list">Все пользователи</a> -->
			</p>
	{ORDERS:}
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a class="{data.user.admin?:text-danger}" href="/cart">Личный кабинет</a></li>
			<li class="breadcrumb-item active">Мои заказы</li>
		</ol>
		<h1>Мои заказы</h1>
		{~length(data.list)?:showinfo?:noOrders}
		<div style="margin-top:10px">
			<a href="/cart/orders/active/list" style="text-decoration:none" class="btn btn-success">Заказ ({~length(data.order.basket)} {~words(~length(data.order.basket),:позиция,:позиции,:позиций)})</a>
		</div>
		{noOrders:} <div>В данный момент у вас нет сохранённых заказов с товарами.</div>
			
		{*rowOrders:}
			<div class="border mb-2 p-2">
				
				<b><a href="/cart/orders/{status=:active?:active?id}">{status=:active?:Заказ?id}</a></b>
					&mdash; <nobr>{rule.short}</nobr>
					<div class="float-right">
					{~date(:j F H:i,time)}<br>
					<b>{total:itemcostrub}</b>
					</div>
				
				
				
				<div style="text-overflow: ellipsis; 
				overflow: hidden;">
				{basket::product}
				</div>
				<div class="clearfix"></div>
				
			</div>


			{dateform:}d.m.Y
		{isedit:}{data.rule.actions[:place]edit?:yes}
		{isdisabled:}{data.rule.actions[:place]edit|:disabled}
		{ishidedisabled:}{data.rule.actions[:place]edit|:disabledhide}
		{disabledhide:}display:none
	{*basketedit:}
		<p align="right">
			<a href="/{crumb}/list">Редактировать корзину</a><br>
			<span data-id="{data.order.order_id}" data-place="{crumb.parent.name}" class="cart-search a">Поиск позиций</span><br>
			<span data-id="{data.order.order_id}" data-place="{crumb.parent.name}" class="act-clear a">Очистить</span>
		</p>
		{manage.summary?:widthSummary}
		{manage.deliverycost?:widthDivelery}

		
		{positionRow:}
			<tr>
				<td><a href="/catalog/{producer_nick}/{article_nick}{:cat.idsl}">{producer} {article}</a>{changed?:star}<br>{itemrow}</td>
				<td>{cost:itemcost}</td>
				<td>{count}</td>
				<td class="d-none d-sm-table-cell">{sum:itemcost}</td>
			</tr>

		{widthSummary:}
			<div>
				Сумма подтверждёная менеджером: <span>{manage.summary:itemcostrub}</span>
			</div>
		{widthDivelery:}
			<div>
				Доставка: {manage.deliverycost:itemcostrub}
			</div>

	{YEARS:}
		<div class="mb-3">{data.years::year}</div>
		<script type="module" async>
			import { Activelink } from "/vendor/infrajs/activelink/Activelink.js"
			const div = document.getElementById('{div}')
			Activelink(div)
		</script>
		{year:}
			<div>
				{~key} &mdash; {::month}
			</div>
		{month:}<a href="/cart/admin{now??:startarg}">{F}</a>{~last()??:comma}
		{startarg:}?start={start}
	{ADMIN:}
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a class="{data.user.admin?:text-danger}" href="/cart">Личный кабинет</a></li>
			<li class="breadcrumb-item active">Все заказы</li>
		</ol>
		<h1>Все заказы</h1>
		<div id="YEARS"></div>
		<div id="ADMINLIST"></div>
		{ADMINLIST:}
			{data.result?:adm_listPage?:adm_message}
		{adm_listPage:}
			<h2>{data.Y}, {data.F} <span class="float-right">{~cost(data.total)}{:model.unit}</span></h2>
			{data.list::adm_row}
			<script type="module" async>
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { Popup } from '/vendor/infrajs/popup/Popup.js'
				import { DOM } from '/vendor/akiyatkin/load/DOM.js'
				import { Global } from '/vendor/infrajs/layer-global/Global.js'

				const div = document.getElementById('{div}')
				const cls = cls => div.getElementsByClassName(cls)
				const place = "{:place}"
				let btns
				btns = cls('act-complete')
				for (const btn of btns) btn.addEventListener('click', async () => {
					const order_id = btn.dataset.order_id
					const ans = await Cart.post('complete', { order_id })
					if (!ans.result) await Popup.alert(ans.msg)
				})

				btns = cls('act-tocheck')
				for (const btn of btns) btn.addEventListener('click', async () => {
					const order_id = btn.dataset.order_id
					const ans = await Cart.post('tocheck', { order_id })
					if (!ans.result) await Popup.alert(ans.msg)
				})
			</script>
			
			{adm_row:}
				<div class="border mb-2 p-2">
					<style>
						#{div} .circle {
							border-radius:50%;
							display:inline-block;
							border: solid 1px gray;
							min-width:20px;
							text-align:center;
							padding:0 2px;
						}
					</style>
					<b><a href="/cart/admin/{order_nick}">{order_nick}</a></b>
					<a href="/cart/admin/{order_nick}/list" class="circle">{~length(basket)}</a> 
					<nobr style="color:{status=:check?:red}">{(status=:wait&active)?data.meta.rules[status]shortactive?data.meta.rules[status]short}</nobr>
					{status=:check?:acomplete}
					{status=:complete?:atocheck}
					
						
						
				
					<div class="float-right text-right">
						<span title="Отправлен на проверку">{~date(:d.m.Y,datecheck)}</span><br>{email}<br><b>{sum:itemcostrub}</b>
					</div>
					
					<div>
						{city.city}{name:pr-comma}{phone:pr-acomma}{coupon:pr-comma}
						{transport?:adminlisttrans}
					</div>
					<div class="clearfix">
						{comment:usercomment}
						{commentmanager:admincomment}
					</div>
					
				</div>
				{adminlisttrans:}<br>{:label_{transport}}&nbsp;<b>{~cost(sumtrans)}{:model.unit}</b>
				{pr-acomma:}, <a href="tel:{~tel(.)}">{.}</a>
				{usercomment:}<pre class="mt-2 px-2 p-1 alert-secondary">{.}</pre>
				{admincomment:}<pre class="mt-2 px-2 p-1 alert-success">{.}</pre>	
				{acomplete:} &mdash; <span class="a act-complete" data-order_id="{order_id}">Готов</span>
				{atocheck:} &mdash; <span class="a act-tocheck" data-order_id="{order_id}">Вернуть на проверку</span>
				{productlist:}
					<div style="text-overflow: ellipsis; 
					overflow: hidden;">
						{basket::product}
					</div>
				{product:} 
					<nobr>{count} <a href="/catalog/{model.producer_nick}/{model.article_nick}{model:cat.idsl}">{model.article}</a>{~last()|:comma}</nobr><wbr>

				{adm_paidorder:}<b>{~cost(manage.paid)}{:model.unit}</b> {manage.paidtype=:bank?:банк?:менеджер} {~date(:d.m.Y H:i,manage.paidtime)}
	{cat::}-catalog/cat.tpl
	{extend::}-catalog/extend.tpl
	{model::}-catalog/model.tpl
	{totalwarn:} <i title="установлено менеджером">*</i>
	{noemail:}<b>ещё не отправлялось</b>{wasemail:}было <b>{~date(:j F H:i,order.dateemail)}</b>
	{mngdelivery:}
	<div class="form-group">
		<label>Цена доставки</label>
		<input class="form-control" name="manage.deliverycost" value="{manage.deliverycost}" type="text">
	</div>
	{freezemsg:}<br>Цены зафиксированы {~date(manage.freeze)}
	{adm_orderinfo:}
		<div>
			Контактное лицо: <b>{name}</b><br>
			Email: <b>{email}</b><br>
			Телефон: <b>{phone}</b>
		</div>
{EMAIL:}
	<div class="input-commentmanager">
		<i class="msg float-right"></i>
		<div class="mb-2">Письмо <b>{email}</b> об изменениях в заказе <b>№{order_nick}</b></div>
		<textarea rows="4" class="mngcom form-control mb-2">{commentmanager}</textarea>
		<p>Письмо {dateemail?:was?:no}</p>
		<script type="module" async>
			const div = document.getElementsByClassName('input-commentmanager')[0]
			const textarea = div.getElementsByClassName('mngcom')[0]
			const msg = div.getElementsByClassName('msg')[0]
			const order_id = {order_id}
			textarea.addEventListener('keyup', async () => {
				msg.innerHTML = '...'
				msg.style.color = "black"
				const commentmanager = Cart.strip_tags(textarea.value)
				const ans = await Cart.posts('setcommentmanager', { order_id }, { commentmanager })
				msg.innerHTML = ans.msg
				if (ans.result) msg.style.color = "green"
				else msg.style.color = "red"
			})
		</script>
	</div>
	{no:}<b>ещё не отправлялось</b>
	{was:}было отправлено <b>{~date(:j F H:i,dateemail)}</b>
{comma:}, 
{text-danger:}text-danger
{usersync:}
	<script type="module">
		import { Cart } from '/vendor/infrajs/cart/Cart.js'
		//Cart.usersync()
	</script>
{usercrumb:}
	<ol class="breadcrumb">
		<li class="breadcrumb-item active {data.user.admin?:text-danger}">Личный кабинет</li>
		<li class="breadcrumb-item"><a href="/cart/orders/active/list">Корзина</a></li>
	</ol>
{listcrumb:}
	{:usersync}
	<ol class="breadcrumb">
		{:mainli}
		{data.place=:admin?:adminli}
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent.parent}">{crumb.parent.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.parent.name=:admin?:text-danger}" href="/{crumb.parent}">Заявка {crumb.parent.name=:active?:Активная?crumb.parent.name}</a></li>-->
		<li class="breadcrumb-item active">Содержимое корзины</li>
		<li class="breadcrumb-item"><a href="/cart/{:place}/{data.order.order_nick|:active}">Оформление заказа</a></li>
	</ol>
{ordercrumb:}
	{:usersync}
	<ol class="breadcrumb">
		{:mainli}
		<!--<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb.parent}">{crumb.parent.name=:admin?:Все?:Мои} заявки</a></li>-->
		<!--<li class="breadcrumb-item active">Заявка {crumb.name=:active?:Активная?crumb.name}</li>-->
		{:place=:admin?:adminli}
		<li class="breadcrumb-item"><a class="{crumb.parent.name=:admin?:text-danger}" href="/{crumb}/list">Содержимое корзины</a>
		<li class="breadcrumb-item active">Оформление заказа</li>
	</ol>
	{mainli:}<li class="breadcrumb-item"><a class="{data.user.admin?:text-danger}" href="/cart">Личный кабинет</a></li>
	{itemcost:}{~cost(.,~false,~true)}<span class="d-none d-sm-inline">{:model.unit}</span>
	{itemcostrub:}{~cost(.,~false,~true)}{:model.unit}
	{star:}<span class="req" title="Позиция в каталоге изменилась">*</span> 
	{req:}{req*:} <span class="req">*</span>
	{ordernum:}Номер заказа: <b>{order_nick}</b>{manage.paid?:msgpaidorder}
		{msgpaidorder:}. Оплата <b>{~cost(manage.paid)}{:model.unit}</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}
	{adm_message:}
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
{PRINT:}
	<ol class="breadcrumb noprint">
		{:mainli}
		{:place=:admin?:adminli}
		<li class="breadcrumb-item"><a class="{:place=:admin?:text-danger}" href="/{crumb.parent}">Заказ {crumb.parent.name=:active??crumb.parent.name}</a></li>
		<li class="breadcrumb-item active">Версия для печати</li>
	</ol>
	<!-- <h1>Заказ {order_nick}{time:ot}</h1> -->
	{:resume}
	{ot:} от {~date(:d.m.Y,.)}
	{adminli:}<li class="breadcrumb-item"><a class="text-danger" href="/cart/admin">Все заказы</a></li>
{pr-comma:}, {.}
{printorder:}
	<b>ФИО</b>: {name}<br>
	<b>Почта</b>: {email}<br>
	<b>Телефон</b>: {phone}<br>
	{callback?:pr-call}
	{time?:pr-time}
	{transport:iprinttr}
	{pay:iprintpay}
	<hr>
	<p>
		<b>{~length(basket)} {~words(~length(basket),:позиция,:позиции,:позиций)}</b>
	</p>
	{:basketresume}
	{:amount}
	{comment?:prcom}
	{manage.comment?:prcomm}
	<hr>
{basketresume:}
	{basket::model.PRINT-item}
{transresume:}
	<div><span class="titletrans">{:label_{transport}}</span>: <b class="sumtrans">{~cost(sumtrans)}{:model.unit}</b></div>
	<div class="transresume">{:info_{transport}}</div>
	<p></p>
	<p>
		Всего: <b class="total">{~cost(total)}{:model.unit}</b>
	</p>
{amount:}
	<p>
		Стоимость{(coupondata.result&sum!sumclear)?:nodiscount}: <b class="sumclear">{~cost(sumclear)}{:model.unit}</b><br>
		{(coupondata.result&sum!sumclear)?:prcoupon}
	</p>
	
	{transport?:transresume}
	
	{prcoupon:}
		Купон: <b>{coupon}</b><br>
		Сумма со скидкой: <b class="sum">{~cost(sum)}{:model.unit}</b><br>

	{descr_cdek_pvz:}<div class="my-2">{...pvz}<div class="mb-1"><span class="a showpvz">{...pvz?:Изменить?:Выбрать} пункт выдачи</span></div></div>
	{info_cdek_pvz:}{pvz}<br>
	{label_cdek_pvz:}Доставка до пункта выдачи СДЕК
	{label_cdek_pvz_short:}До пункта выдачи

	{descr_city:}{:inpaddress}
	{info_city:}{address}
	{label_city:}Доставка по Тольятти
	{label_city_short:}{:label_city}
	
	{descr_self:}ул. Новозаводская 2Б, торг.павильон №1, 1/23. <span class="a showMap">Схема проезда</span>
	{info_self:}
	{label_self:}Самовывоз из магазинов в Тольятти
	{label_self_short:}{:label_self}

	{descr_cdek_courier:}{:inpaddress}
	{info_cdek_courier:}{city.city}, {address}<br>
	{label_cdek_courier:}Доставка курьером СДЕК
	{label_cdek_courier_short:}Курьер
	
	{descr_pochta_simple:}{:inpzip}
	{info_pochta_simple:}{zip}<br>
	{label_pochta_simple:}Доставка Почтой России
	{label_pochta_simple_short:}Посылка обыкновенная

	{descr_pochta_1:}{:inpzip}
	{info_pochta_1:}{zip}<br>
	{label_pochta_1:}Доставка Почтой России 1 класс
	{label_pochta_1_short:}Первый класс

	{descr_pochta_courier:}{:inpaddress}
	{info_pochta_courier:}{city.city}, {address}<br>
	{label_pochta_courier:}Доставка курьером Почты России
	{label_pochta_courier_short:}Курьер
	{inpaddress:}
		<div class="mt-2 input-address">
			<label class="w-100">Адрес доставки (<span class="a citychoice">{data.order.city.city}</span>) <i class="msg float-right"></i></label>
			<input {:isdisabled} type="text" name="address" value="{data.order.address}" class="form-control address" placeholder="ул, дом, кв">
		</div>
	{inpzip:}
		<div class="form-group input-zip mt-2">
			<label class="w-100">Почтовый индекс (<span class="a citychoice">{data.order.city.city}</span>) <i class="msg float-right"></i></label>
			<select name="zip" class="zip form-control" type="text" list="zips" autocomplete="off">
				<option></option>
				{data.order.city.zips::zipopt}
			</select>
		</div>
		
{MAP:}
	<div class="embed-responsive embed-responsive-16by9">
		<iframe class="embed-responsive-item" src="https://yandex.ru/map-widget/v1/-/CCR~5Giy" frameborder="1" allowfullscreen="true"></iframe>
	</div>
{prcom:}
	
		Комментарий:
		<pre style="margin-top:0"><b><i>{comment}</i></b></pre>
	
{prcomm:}
	
		Комментарий менеджера:
		<pre style="margin-top:0"><b><i>{manage.comment}</i></b></pre>
	
{pr-call:}<b>Перезвонить</b>: {callback=:yes?:yescall?(callback=:no?:nocall)}<br>
{yes:}yes
{no:}no
{yescall:}да
{active:}active
{nocall:}звонок не требуется
{iprinttr:}
	<b>Доставка</b>: {choice} 
		{choice??:nochoice}
		{choice=:strПочта1?:rowПочта1}
		{choice=:strПочта?:rowПочта}
		{choice=:strТраспорт?:rowТраспорт}
		{choice=:strКурьер?:rowКурьер}
		{choice=:strВывоз?:rowВывоз}
	
	{nochoice:} {address} {passeriya:pr}
	{strПочта:}Почта России
	{rowПочта:}{index:pr} {region:pr} {city:pr} {street:pr} {house:pr} {kv:pr}
	
	{strПочта1:}Почта России <nobr>1 класс</nobr>
	{rowПочта1:}{:rowПочта}

	{strТраспорт:}Транспортные компании
	{rowТраспорт:}{region:pr} {city:pr} {cargo:pr} {passeriya:pr} {pasnumber:pr}

	{strКурьер:}Доставка курьером
	{rowКурьер:}{courier:pr} {:rowПочта}

	{strВывоз:}Пункты самовывоза <nobr>в Тольятти</nobr>
	{rowВывоз:}{self:pr}

{pr:} {.}
{iprintpay:}
	<div><b>Оплата</b>: {choice}</div>
{iprinte:}
	{.}{~last()??:comma}
{comma:}, 
{iprint:}
	{~key}: {.}<br>
{pr-time:}
	<b>Дата изменений</b>: {~date(:H:i j F Y,time)}<br>
{pr-deliver:}
	Доставка: <b>{~cost(manage.deliverycost)}{:model.unit}</b><br>
{order_id:}{data.order.order_id|:stractive}
{stractive:}"active"