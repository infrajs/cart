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
		<div style="max-width:800px">
			
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
			const place = "{:place}"

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
			В корзине нет товаров. {data.order?(data.active?:opencatalog?:searchbutton)?:opencatalog}.
			{searchbutton:}<span class="cart-search a">Добавить</span>
			{opencatalog:}<a href="/catalog">Открыть каталог</a>
		{showlist:}
			{:cartlistborder}
			{:couponinfolist}
		{couponinfolist:}
			<div class="couponinfolist">
				<style>
					#{div} .couponinfolist {
						display: grid;
						grid-template-columns: 1fr max-content;
						grid-gap: 10px;
						justify-content: space-between;
						align-items: center;
						margin-top:15px;
					}
					#{div} .couponinfolist .label {
						 flex-grow: 1;
						 text-align: right;
					}
					#{div} .couponinfolist .input {
					}
					@media(max-width: 991px) {
						#{div} .couponinfolist .input {
							/*margin-left: auto;
							margin-right: auto;*/
							text-align: center;
						}
						#{div} .couponinfolist .label {
							text-align: center;
							
						}
						#{div} .couponinfolist {
							grid-template-columns: 1fr;
						}
					}
				</style>
				<div class="input">
					{:couponinp}
				</div>
				<div class="label">
					<p style="display: {sumclear!sum??:none}">
						Сумма со скидкой: <b class="cartsum" style="font-size:140%">{sum:itemcostrub}</b> 
					</p>
					<a style="white-space: nowrap; text-decoration: underline;" href="/{crumb.parent}">
						Перейти к {data.order.status!:wait?:заказу?:оформлению заказа}
					</a>
					<br>
					Займёт не&nbsp;более 3&nbsp;минут.
				</div>
			</div>
		{showcartlist:}
			{order:cartlist}
		{cartlist:}
			{:model.css}
			<style>
				#{div} hr {
					margin-top: 1rem;
	    			margin-bottom: 1rem;
	    			background-color: #dee2e6;
				}
			</style>
			<div style="{:ishidedisabled}">
				<div style="display: flex; justify-content: space-between;">
					<div>
						<div>
							<input type="checkbox" name="checkall" id="checkall">
							<label for="checkall">Выделенное: </label>
							<span class="act-clear a">Удалить</span>
							<script type="module" async>
								import { Cart } from '/vendor/infrajs/cart/Cart.js'
								import { Popup } from '/vendor/infrajs/popup/Popup.js'
								import { DOM } from '/vendor/akiyatkin/load/DOM.js'
								import { Global } from '/vendor/infrajs/layer-global/Global.js'

								const div = document.getElementById('{div}')
								const cls = (div, cls) => div.getElementsByClassName(cls)
								const checkall = document.getElementById('checkall')
								const form = document.forms.basket
								const dels = cls(form, 'del')
								const place = "{:place}"
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
									let ans = await Cart.post('remove', { place, order_id, position_ids })
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
				<style>
					#{div} del {
						color: gray;
					}
					#{div} .sumitogdis {
						text-align: right;
					}
					@media (max-width: 991px) {
					  	#{div} .sumitogdis {
							text-align: center;
						}
					}
				</style>
				{basket::cartpos}
			</form>
			<div class="sumitogdis" style="margin-bottom: 10px;">
				Сумма{sumclear!sum?:nodiscount}: 
				<span style="font-size:120%; font-weight:bold" class="cartsumclear">{sumclear:itemcostrub}</span>
			</div>
			<script type="module">
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { Template } from '/vendor/infrajs/template/Template.js'
				let div = document.getElementById('{div}')
				let cls = (el, cls) => el.getElementsByClassName(cls)

				let form = document.forms.basket
				let inputs = cls(form, 'count')

				const order_id = {:order_id}
				const place = "{:place}"
				const order_nick = {data.order.order_nick}

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
						const ans = await Cart.post('add',{ order_id, position_id }, { place, count })
						if (!ans.result) Popup.alert(ans.msg)

					})
				}
			</script>
			{false:}0
			{true:}1
		{cartlistborder:}
			<div style="padding: 1rem; border: 1px solid #dee2e6; border-radius: .25rem;">
				{:cartlist}
			</div>
		{badgecoupon:}&nbsp;<span title="Скидка по купону {data.order.coupon}" class="badge badge-pill badge-danger">-{.}%</span>
		{cartpos:}
			<div style="display: flex;" class="cartpos">
				<style>
					#{div} .mobile {
						display: none;
					}
					#{div} .pc {
						display: block;
					}
					@media (max-width: 767px) {
						#{div} .mobile {
							display: block;
						}
						#{div} .pc {
							display: none;
						}
					}
				</style>
				<div style="{:ishidedisabled}">
					<input style="margin-right: 0.5rem;" data-position_id="{position_id}" type="checkbox" class="del" id="check{~key}" name="del{position_id}">
				</div>
				<div class="pc" style="min-width:70px; margin-right: 1rem">
					{model.images.0?model:cartposimg}
				</div>
				<div style="flex-grow: 1">
					<div>
						<div style="float: right">{model:model.badgenalichie}{discount:badgecoupon}</div>
						<b>{model.changed?:star} <a href="/catalog/{model.producer_nick}/{model.article_nick}{model:cat.idsl}">
							{model.Наименование}</a>
						</b>
					</div>
					<div style="display:flex" class="{~sid}1">
						<style media="(max-width: 991px)">
							.{~sid}1 { 
								flex-direction: column 
							}
						</style>
						{model.images.0?model:cartposimgm}
						<div style="margin: 0.5rem 0; flex-grow:1">
							{model:model.CART-props}
						</div>
						<div class="{~sid}2 costblock" style="margin-bottom: 0.5rem; margin-top: 0.5rem; display:flex; flex-direction: column">
							<style media="(min-width: 992)">
								.{~sid}2 { 
									margin-left: 1rem 
								}
							</style>	
							<div style="min-width:70px;" class="{~sid}3">
								<style media="(min-width: 992)">
									.{~sid}3 { 
										text-align:right 
									}
								</style>	
								<div><del>{cost!model.Цена?model.Цена:itemcostrub?model.Старая цена:itemcostrub}</del></div>
								{cost:itemcostrub}
							</div>
							<div style="margin: 0.5rem 0;">
								<input data-autosave="false" {:isdisabled} data-position_id="{position_id}" data-cost="{cost}" data-costclear="{model.Цена}" style="width:5em" value="{count}" type="number" min="0" max="999" class="count form-control" type="number">
							</div>
							<div style="min-width:70px;" class="l{id}5">
								<b class="sum">{sum:itemcostrub}</b>
							</div>
						</div>
					</div>
				</div>
			</div>
			<hr>
			{nodiscount:} <nobr>без скидки</nobr>
			{cartposimg:}
				<a href="{:model.link-pos}">
					<img style="max-width:100%" src="/-imager/?w=60&crop=1&h=60&src={images.0}&or=-imager/empty.png">
				</a>
			{cartposimgm:}
				<a href="{:model.link-pos}" class="mobile" style="margin:0.5rem 1rem 0.5rem 0">
					<img style="max-width:100%" src="/-imager/?h=100&src={images.0}&or=-imager/empty.png">
				</a>
	{PAYLAYOUT:}{:*pay.INFO}
	{ORDER:}
		{:ordercrumb}
		{data.result??(data.msg?:ordermessage)}
		{data.order.sum>0|(data.user.admin|data.order.status!:wait)?data.order:ordercontent?:emptyorder}		

		{ordermessage:}
			<h1>Ошибка</h1>
			{data.msg}
		{emptyorder:}
			<h1>{data.rule.title} <span style="float:right">{:ordernick}</span></h1>
			{:emptylist}
		{showManageComment:}
			<div style="margin-bottom:10px;" class="alert alert-success" role="alert"><b>Сообщение менеджера</b>
				<pre style="margin:0; padding:0; font-family: inherit; background:none; border:none; white-space: pre-wrap">{commentmanager}</pre>
			</div>		
		{checked:}checked
		{ordernick:}№{data.order.order_nick}
		
		{autosavename:}{:place}.{order_nick}
		
					
		{transportradio:}
			<div class="line" style="margin-top: 0.25rem; color: {...transport=type?:black}; font-weight:{...transport=type?:600}">
				<div style="display: flex">
					<div style="flex-grow: 1; position: relative; padding-left: 1.25rem;" style2="max-width:200px">
						<input {:isdisabled} style="position: absolute; margin-top: .334rem; margin-left: -1.25rem;" class="radio" type="radio" name="transport" {...transport=type?:checked} id="transport_{type}" 
						data-cost="{cost}" value="{type}">
						<label class="ml-1 form-check-label" for="transport_{type}">
							{:label_{type}_short}
						</label>
					</div>
					{((type!:any)&(type!:self))?:transprice}
				</div>
				<div class="descr {...transport=type?:show}">
					{:descr_{type}}
				</div>
			</div>
		{pochtalogo:}
			<div style="margin-top: 1rem; margin-bottom:0.5rem">{:pochtalogoimg}</div>
			{pochtalogoimg:}<img alt="Почта России" src="/-imager/?w=75&src=-cart/images/pochtabig.png">
		{cdeklogo:}
			<div style="margin-top: 1rem; margin-bottom:0.5rem">{:cdeklogoimg}</div>
			{cdeklogoimg:}<img alt="СДЕК" src="/-imager/?w=75&src=-cart/images/cdekline.png">
		{hometown:}
			<div style="margin-top: 1rem; margin-bottom:0.5rem"><img src="/-imager/?w=75&src=images/logo.png"></div>
		{anytranslogo:}
			<div style="margin-top: 1rem; margin-bottom:0.5rem"><img src="/-imager/?w=65&src=-cart/images/any.png"></div>
		{noweight:}недостаточно данных
		{showweight:}<b>{data.order.weight} кг</b>
		{ordercontent:}
			<style>
				#{div} form {
					display: grid; 
					grid-row-gap: 20px;
					grid-column-gap: 31px; /*до 768 контейнер 720 - padding 15x2 для контена 690 и в контенте 330*2 + 30 и +1 для переноса в одну колонку*/
					grid-template-columns: repeat(auto-fit, minmax(330px, 1fr));		
				}
				#{div} label {
				    display: inline-block;
				    margin-bottom: .5rem;
				}
				@media(min-width: 1191px) {
					#{div} form  {
						grid-template-columns: repeat(2, 1fr);		
					}
				}
			</style>
			<h1 title="Последние измения {~date(:j F H:i,data.order.dateedit)}">
				{data.rule.title} 
				{:ordernick}
			</h1>
			<form name="cart">
				<div>
					{commentmanager?:showManageComment}
					{data.order.paydata:PAYLAYOUT}
					{:ordercontentbody}
				</div>
				<div>
					<div style="top:68px; position: sticky;">
						{:resume}
						{:orderactionsblock}
					</div>
				</div>
			</form>
		{orderactionsblock:}
			<div>
				<style>
					.act-check {
						display: {:place=:admin??(:online?:none)}
					}
					.act-tocheck,
					.act-delete,
					.act-wait {
						display: {paid?:none}	
					}
					.act-pay {
						display: {:place=:admin??(:online??:none)}
					}
				</style>
				{:place=:admin?:adminactions?:useractions}
			</div>
		{raschetniives:}
			<div class="mt-n2">
				Расчётный вес: {data.order.weight?:showweight?:noweight}
			</div>
		{ordercontentbody:}
				<style>
					#{div} .form-group {
						 margin-bottom: 1rem;
					}
					#{div} .borderblock {
						border: solid 1px #ddd;
						margin: 15px 0 20px;
						/*background-color:rgba(253,234,181,0.25);*/
	    				padding: 10px 15px;
					}
					@media (max-width: 575px) {
						#{div} .borderblock {
							/*border: none;
							padding: 0;
							margin: 0;
							margin-bottom:20px;*/
							
						}
					}
				</style>
				<div class="borderblock" style="margin-top:0">
					<div style="max-width:350px">
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
								const place = "{:place}"
								const order_id = {:order_id}
								if (input.value) msg.innerHTML = ''
								const change = async () => {
									msg.innerHTML = '...'
									msg.style.color = "black"
									const name = Cart.strip_tags(input.value)
									cls('nameresume').innerHTML = name ? ', ' + name : ''
									const ans = await Cart.posts('setname', { place, order_id }, { name })
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
								const place = "{:place}"
								const order_id = {:order_id}
								if (input.value) msg.innerHTML = ''
								const change = async () => {
									msg.innerHTML = '...'
									msg.style.color = "black"
									const phone = Cart.strip_tags(input.value)
									cls('phoneresume').innerHTML = phone ? ', ' + phone : ''
									const ans = await Cart.posts('setphone', { place, order_id }, { phone })
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
								//import { Session } from '/vendor/infrajs/session/Session.js'
								import { Ses } from '/vendor/akiyatkin/form/Ses.js'
								const form = document.forms.cart
								const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
								const block = cls('input-email')
								const msg = cls('msg', block)
								const input = form.elements.email
								const place = "{:place}"
								const order_id = {:order_id}
								if (input.value) msg.innerHTML = ''
								const change = async () => {
									msg.innerHTML = '...'
									msg.style.color = "black"
									const email = Cart.strip_tags(input.value)
									Ses.set('user.email', email)
									cls('emailresume').innerHTML = email ? ', '+email : ''
									const ans = await Cart.posts('setemail', { place, order_id }, { email })
									msg.innerHTML = ans.msg
									if (ans.result) msg.style.color = "green"
									else msg.style.color = "red"

								}
								//input.addEventListener('change', change)
								input.addEventListener('keyup', change)
							</script>
						</div>
					</div>
				</div>
				<div id="transblock" class="transblock">
					<h2>
						<span class="transportreset" style="cursor: default">Населённый пункт</span> 
						<nobr class="{:isedit?:a?:text-danger} citychoice">{data.order.city.city|:citynone}</nobr>
					</h2>
					{:raschetniives}
					
					<div class="borderblock" style="color:#444; padding-top:10px; padding-bottom:15px">
						<div style="max-width:350px">
							<style>
								.transblock select,
								.transblock input,
								.transblock label,
								.transblock .line {
									cursor: {:isedit?:pointer?:default};
								}
								/*.transblock .descr {
									padding-bottom:1px;
								}*/
								.transblock .descr {
									max-height: 0;
									opacity: 0;
									position: relative; 
									padding-left: 1.25rem;
									font-weight: normal;
									overflow: hidden;
									transition-property: margin-top, opacity, max-height;
									transition-duration: 0.2s;
								}
								.transblock .descr.show {
									display: block;
									opacity: 1;
									max-height: 200px;
									margin-top:5px;
								}
								.transblock .input-address, 
								.transblock .input-zip {
									margin-top:5px;
									margin-bottom:5px;
								}
							</style>
							{(transports.cdek_pvz|transports.cdek_courier)?:cdeklogo}
							{transports.cdek_pvz:transportradio}
							{transports.cdek_courier:transportradio}
							

							
							{transports.pochta_simple?:pochtalogo}
							{transports.pochta_simple:transportradio}
							{transports.pochta_1:transportradio}
							{transports.pochta_courier:transportradio}


							{(transports.city|transports.self)?:hometown}
							{transports.city:transportradio}
							{transports.self:transportradio}
							{(transports.any)?:anytranslogo}
							{transports.any:transportradio}
							<script type="module" async>
								import { Cart } from '/vendor/infrajs/cart/Cart.js'
								/*
									Обработка Индекса
								*/
								const form = document.forms.cart
								const cls = (cls, div = form) => div.getElementsByClassName(cls)
								const blocks = cls('input-zip')
								const place = "{:place}"
								const order_id = {:order_id}
								for (const block of blocks) {
									const input = cls('zip', block)[0]
									const change = async () => {
										const zip = input.value
										for (const block of blocks) {
											const input = cls('zip', block)[0]
											const msg = cls('msg', block)[0]
											msg.innerHTML = '...'
											msg.style.color = "black"
											input.value = zip
										}
										
										const transport = form.elements.transport.value
										const data = {
											"city":{
												"city":"{data.order.city.city}"
											},
											"address":cls('address',form)[0].value,
											"zip":cls('zip',form)[0].value,
											"pvz":"{data.order.pvz}"
										}
										cls('transresume')[0].innerHTML = transport ? Template.parse("{tpl}", data, "info_" + transport) : ''
										const ans = await Cart.posts('setzip', { place, order_id, zip })
										//if (!ans.result) Popup.alert(ans.msg)
										for (const block of blocks) {
											const input = cls('zip', block)[0]
											const msg = cls('msg', block)[0]
											msg.innerHTML = ans.msg
											if (ans.result) msg.style.color = "green"
											else msg.style.color = "red"
										}
									}
									input.addEventListener('keyup', change)
								}
							</script>
							<script type="module" async>
								import { Cart } from '/vendor/infrajs/cart/Cart.js'
								import { CDEK } from '/vendor/infrajs/cart/cdek/CDEK.js'
								import { Popup } from '/vendor/infrajs/popup/Popup.js'
								import { Load } from '/vendor/akiyatkin/load/Load.js'
								/*
									Обработка Пункта выдачи СДЕК
								*/
								const form = document.forms.cart
								const cls = (cls, div = form) => div.getElementsByClassName(cls)
								const order_id = {:order_id}
								const place = "{:place}"
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
								/*
									Обработка Адреса
								*/
								const form = document.forms.cart
								const cls = (cls, div = form) => div.getElementsByClassName(cls)
								const blocks = cls('input-address')
								const order_id = {:order_id}
								const place = "{:place}"
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

										const transport = form.elements.transport.value
										
										const address_value = address;

										const zip = cls('zip',form)[0]
										const zip_value = zip ? zip.value : ''
										
										let tk_value = '';
										const tkselect = cls('select-tk')[0]
										if (tkselect) {
											const tkindex = tkselect.options.selectedIndex
											tk_value = tkselect.options[tkindex].value
										}
										
										const data = {
											"city":{
												"city":"{data.order.city.city}"
											},
											"tk":tk_value,
											"address":address_value,
											"pvz":"{data.order.pvz}"
										}
										cls('transresume')[0].innerHTML = transport ? Template.parse("{tpl}", data, "info_" + transport) : ''

										const ans = await Cart.posts('setaddress', { place, order_id }, { address })

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
								import { Config } from '/vendor/infrajs/config/Config.js'
								import { Popup } from '/vendor/infrajs/popup/Popup.js'
								import { Global } from '/vendor/infrajs/layer-global/Global.js'
								import { Template } from '/vendor/infrajs/template/Template.js'
								import { Layer } from '/vendor/infrajs/controller/src/Layer.js'
								/*
									Обработка radio - способ доставки.
								*/
								const form = document.forms.cart
								const cls = (cls, div = form) => div.getElementsByClassName(cls)
								const transblock = cls('transblock')[0]
								const tag = (tag, div = form) => div.getElementsByTagName(tag)
								const radios = cls('radio', transblock)
								const order_id = {:order_id}
								const place = "{:place}"
								const sum = {data.order.sum}
								const lines = cls('line', transblock)
								const isedit = {:isedit?:true?:false}

								const tplcost = val => {
									let cost = Template.scope['~cost'](val) + '{:model.unit}'
									return cost
								}
								for ( const map of cls('showMap', transblock)) map.addEventListener('click', () => {
									Popup.showbig(Cart.maplayer)
								})

								const transportreset = cls('transportreset')[0]
								if (transportreset) transportreset.addEventListener('click', () => {
									for (const radio of radios) radio.checked = false
									change(true)
								})

								const descrs = cls('descr', transblock)
								let lasttransport = "{data.order.transport}"
								const change = async (r) => {
									if (!isedit) return
									const transport = r === true ? '' : form.elements.transport.value
									
									cls('transportready')[0].style.display = transport ? 'block' : 'none'
									
									if (lasttransport == transport) return
									lasttransport = transport

									const radio = form.elements['transport_' + transport]
									const sumtrans = radio ? Number(radio.dataset.cost) : 0
									
									
									const pay = form.elements.pay ? form.elements.pay.value : ''
									

									//const online = (pay == 'card' && (Config.conf.cart.paycheck || (transport != 'any' && transport)))
									const online = (pay == 'card' && (Config.conf.cart.paycheck && (transport != 'any' && transport)))
									for (const img of cls('visalogo')) img.style.display = online ? '' : 'none'
									for (const btn of cls('act-check')) btn.style.display = online ? 'none' : 'inline-block'
									for (const btn of cls('act-pay')) btn.style.display = online ? 'inline-block' : 'none'

									let total = sum + sumtrans

									const payselfcost = pay == 'self' && (!transport || ~['cdek_pvz', 'any', 'cdek_courier','pochta_simple','pochta_1','pochta_courier'].indexOf(transport));
									if (payselfcost) {
										total = Math.round(total * (100 + Config.conf.cart.payselfcost)) / 100
									}


									for (const line of lines) {
										line.style.color = ''
										line.style.fontWeight = ''
									}
									for (const descr of descrs) descr.classList.remove('show')
									if (transport) {
										const line = radio.closest('.line')
										if (line) {
											line.style.color = 'black'
											line.style.fontWeight = '600'
										}
										const descr = cls('descr', line)[0]
										if(descr) descr.classList.add('show')
									}
								
									if (~['any','self'].indexOf(transport)) {
										cls('sumtrans')[0].innerHTML = ''
									} else {
										cls('sumtrans')[0].innerHTML = ': '+tplcost(sumtrans)
									}
									const address = cls('address',form)[0]
									const address_value = address ? address.value : '';

									
									let tk_value = '';
									const tkselect = cls('select-tk')[0]
									if (tkselect) {
										const tkindex = tkselect.options.selectedIndex
										tk_value = tkselect.options[tkindex].value
									}
									let data = {
										"city":{
											"city":"{data.order.city.city}"
										},
										"tk":tk_value,
										"address":address_value,
										"zip":"{data.order.zip}",
										"pvz":"{data.order.pvz}"
									}
									for (const span of cls('total')) span.innerHTML = tplcost(total)
									cls('titletrans')[0].innerHTML = Template.parse("{tpl}", data, "label_" + transport)
									
									cls('transresume')[0].innerHTML = Template.parse("{tpl}", data, "info_" + transport)

									const ans = await Cart.posts('settransport', { place, order_id }, { transport })
									if (!ans.result) await Popup.alert(ans.msg)
								}
								for (const radio of radios) radio.addEventListener('change', change)
								for (const line of lines) line.addEventListener('click', () => {
									if (!isedit) return
									let radio = cls('radio', line)[0]
									radio.checked = true
									change()
								})
							</script>
						</div>
				
					</div>
					<script type="module" async>
						import { City } from "/vendor/akiyatkin/city/City.js"
						import { Cart } from '/vendor/infrajs/cart/Cart.js'
						import { Global } from '/vendor/infrajs/layer-global/Global.js'

						/*
							Всплывающее окно выбора города с классом citychoice
						*/
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
									if (city_id && city_id != old_city_id) {
										//const zip = ''
										//await Cart.post('setzip', { order_id }, { zip })
										await Cart.post('setcity', { place, order_id }, { city_id })
									} else if (city_id === 0) {
										await Cart.post('setcity', { place, order_id }, { city_id: '' })
									} else {
										Cart.dis(form, false)
									}
								})
							}
						}
					</script>
				</div>
				{~conf.cart.pays.0?:payblock}
				<div style="display: flex; gap: 15px; flex-wrap: wrap;">
					<div style="margin-bottom: 0.5rem; flex-grow:1" class="col-sm-12 input-comment">
						<div style="margin-bottom:0.5rem">Комментарий к&nbsp;заказу <i style="float: right" class="msg"></i></div>
						<textarea {:isdisabled} name="comment" style="height:auto" class="form-control" rows="3">{data.order.comment}</textarea>
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)[0]
							const block = cls('input-comment')
							const msg = cls('msg', block)
							const input = form.elements.comment
							const order_id = {:order_id}
							const place = "{:place}"
							if (input.value) msg.innerHTML = ''
							const change = async () => {
								msg.innerHTML = '...'
								msg.style.color = "black"
								const comment = Cart.strip_tags(input.value)
								cls('commentresume').innerHTML = comment
								const ans = await Cart.posts('setcomment', { place, order_id }, { comment })
								msg.innerHTML = ans.msg
								if (ans.result) msg.style.color = "green"
								else msg.style.color = "red"
							}
							//input.addEventListener('change', change)
							input.addEventListener('keyup', change)
						</script>
					</div>
					<div class="col-sm-12 callblock">
						<style>
							.callblock input,
							.callblock label,
							.callblock .line {
								cursor: {:isedit?:pointer?:default};
							}
						</style>
						<div class="callback-title" style="margin-bottom: 0.25rem; cursor: default">Звонок менеджера</div>
						<div class="line" style="margin-top: 0.25rem ;padding-left: 1.25rem; font-weight:{callback=:yes?:600}">
							<input style="margin-left: -1.25rem; margin-top: 0.334rem; position:absolute;" data-autosave="false" {:isdisabled} type="radio" name="callback" {callback=:yes?:checked} id="exampleRadios1" value="yes">
							<label for="exampleRadios1">
								Нужен для уточнения деталей.
							</label>
						</div>
						<div class="line" style="margin-top: 0.25rem ;padding-left: 1.25rem; font-weight:{callback=:no?:600}">
							<input style="margin-left: -1.25rem; margin-top: 0.334rem; position:absolute;" data-autosave="false" {:isdisabled} class="form-check-input" type="radio" name="callback" {callback=:no?:checked} id="exampleRadios2" value="no">
							<label for="exampleRadios2">
								Не нужен, информация<br>по заказу понятна.
							</label>
						</div>
						<script type="module">
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							import { Popup } from '/vendor/infrajs/popup/Popup.js'

							const div = document.getElementById('{div}')
							const cls = (cls, el = div) => el.getElementsByClassName(cls)
							let radios = document.forms.cart.elements.callback					
							const order_id = {:order_id}
							const place = "{:place}"
							let order_nick = {data.order.order_nick}
							let isedit = {:isedit?:true?:false}
							let title = cls('callback-title')[0]
							let oldcallback = "{data.order.callback}"
							const callblock = cls('callblock')[0]
							const lines = cls('line', callblock)
							const change = async event => {
								if (!isedit) return
								let callback = radios.value
								if (callback == oldcallback) return
								oldcallback = callback
								for (const line of lines) line.style.fontWeight = 400
								if (event) {
									const radio = event.currentTarget
									const line = radio.closest('.line')
									line.style.fontWeight = 600
								}
								cls('callresume')[0].innerHTML = Template.parse("{tpl}", callback, "callbackresume")
								let ans = await Cart.posts('setcallback', { place, order_id }, { callback })
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
			{payblock:}
				<div class="payblock">
					<h2 class="payreset" style="cursor: default; display:flex; justify-content:space-between; flex-wrap: wrap;">
						<span>Способ оплаты</span>
						<span class="total">{~cost(data.order.total)}{:model.unit}</span>
					</h2>
					<div class="borderblock" style="color:#444; padding-bottom:15px">
						<style>
							.payblock input,
							.payblock label,
							.payblock .line {
								cursor: {:isedit?:pointer?:default};
							}
							.payblock .descr {
								padding-bottom:1px;
							}
							.payblock .descr {
								max-height: 0;
								opacity: 0;
								overflow: hidden;
								transition-property: margin-top, opacity, max-height;
								transition-duration: 0.2s;
							}
							.payblock .descr.show {
								display: block;
								opacity: 1;
								max-height: 100px;
							}
						</style>
						
						{payments.card?(:card):payradio}
						{payments.perevod?(:perevod):payradio}
						<!-- <img src="/-imager?src=-cart/images/cards.png"> -->
				
						{payments.self?(:self):payradio}
						{payments.corp?(:corp):payradio}
						
						<script type="module" async>
							import { Cart } from '/vendor/infrajs/cart/Cart.js'
							import { Popup } from '/vendor/infrajs/popup/Popup.js'
							import { Global } from '/vendor/infrajs/layer-global/Global.js'
							import { Template } from '/vendor/infrajs/template/Template.js'
							import { Layer } from '/vendor/infrajs/controller/src/Layer.js'

							/*
								Выбор radio - способ оплаты. 
								Показываем нужные действия снизу
								Для варианта self - оплата при получении. Добавляется процент.
							*/
							const form = document.forms.cart
							const cls = (cls, div = form) => div.getElementsByClassName(cls)
							const tag = (tag, div = form) => div.getElementsByTagName(tag)
							const payblock = cls('payblock')[0]
							
							const radios = form.elements.pay || []
							const order_id = {:order_id}
							const place = "{:place}"
							const lines = cls('line', payblock)
							const isedit = {:isedit?:true?:false}
							const descrs = cls('descr', payblock)
							const payreset = cls('payreset')[0]
							payreset.addEventListener('click', () => {
								for (const radio of radios) radio.checked = false
								change(true)
							})
									
							let last = "{data.order.pay}"
							const change = async (r) => {
								if (!isedit) return
								const pay = r === true ? '' : radios.value
								const tplcost = val => {
									let cost = Template.scope['~cost'](val, false, true) + '{:model.unit}'
									return cost
								}
								if (last == pay) return
								last = pay
								for (const line of lines) {
									line.style.color = ''
									line.style.fontWeight = ''
								}
								for (const descr of descrs) descr.classList.remove('show')
								if (pay) {
									const radio = form.elements['pay_' + pay]
									const line = radio.closest('.line')
									const descr = cls('descr', line)[0]
									if (descr) descr.classList.add('show')
									if (line) {
										line.style.color = 'black'
										line.style.fontWeight = '600'
									}
									
								}
								const sum = {data.order.sum}
								const transport = form.elements.transport.value
								const radio = form.elements['transport_' + transport]
								const sumtrans = radio ? Number(radio.dataset.cost) : 0

								const payselfcost = pay == 'self' && (!transport || ~['cdek_pvz', 'any', 'cdek_courier','pochta_simple','pochta_1','pochta_courier'].indexOf(transport));
								if (payselfcost) {
									//for (const span of cls('total')) span.innerHTML = tplcost(Math.round((sum + sumtrans) * 104)/100)
									for (const span of cls('total')) span.innerHTML = tplcost(Math.round((sum + sumtrans) * (100 + Config.conf.cart.payselfcost))/100)
								} else {
									for (const span of cls('total')) span.innerHTML = tplcost(sum + sumtrans)
								}


								//const online = (pay == 'card' && transport != 'any' && transport)
								//const online = (pay == 'card' && (Config.conf.cart.paycheck || (transport != 'any' && transport)))
								const online = (pay == 'card' && (Config.conf.cart.paycheck && (transport != 'any' && transport)))
								for (const img of cls('visalogo')) img.style.display = online ? '' : 'none'
								for (const btn of cls('act-check')) btn.style.display = online ? 'none' : 'inline-block'
								for (const btn of cls('act-pay')) btn.style.display = online ? 'inline-block' : 'none'

								cls('payresume')[0].innerHTML = pay ? Template.parse("{tpl}", true, "pay_label_" + pay) : ''
								
								const ans = await Cart.posts('setpay', { place, order_id }, { pay })
								if (!ans.result) await Popup.alert(ans.msg)
							}
							for (const radio of radios) radio.addEventListener('change', change)
							for (const line of lines) line.addEventListener('click', () => {
								if (!isedit) return
								let radio = tag('input', line)[0]
								radio.checked = true
								change()
							})
						</script>
					</div>
				</div>
			{online*:}{((pay=:card)&(transport!:any))&transport?:yes}
			{online*:}{(pay=:card)&(~conf.cart.paycheck|((transport!:any)&transport))?:yes)}
			{online:}{(pay=:card)&(~conf.cart.paycheck&((transport!:any)&transport))?:yes)}
			
			{zipopt:}<option {.=data.order.zip?:selected}>{.}</option>
			{payradio:}
				<div class="mt-1 line" style="color: {data.order.pay=.?:black}; font-weight:{data.order.pay=.?:600}">
					<div class="d-flex">
						<div style="flex-grow:1; padding-left: 1.25rem">
							<input style="position: absolute; margin-top: 0.334rem; margin-left: -1.25rem" {:isdisabled} class="radio" type="radio" name="pay" {data.order.pay=.?:checked} id="pay_{.}" 
							data-cost="{cost}" value="{.}">
							<label for="pay_{.}">
								{:pay_label_{.}}
							</label>
						</div>
					</div>
				</div>
			{pay_label_self:}Оплата при получении (комиссия 4%)<div class2="descr {data.order.pay=.?:show}" style="font-size:13px; color:#888; margin-top:-1px; font-weight: normal;">Наличными или картой</div>
			{pay_label_card:}Оплата картой онлайн<div class2="descr {data.order.pay=.?:show}" style="font-size:13px; color:#888; margin-top:-1px; font-weight: normal;">VISA, Mastercard, МИР</div>
			{pay_label_perevod:}Мобильный банк<div class2="descr {data.order.pay=.?:show}" style="font-size:13px; color:#888; margin-top:-1px; font-weight: normal;">Сбербанк, Tinkoff, Альфа Банк, ВТБ</div>
			{pay_label_corp:}Оплата по счёту для юр.лиц<div class2="descr {data.order.pay=.?:show}" style="font-size:13px; color:#888; margin-top:-1px; font-weight: normal;">Без НДС</div>
			{transprice:}
				<div class="d-flex ml-2" style="max-width:140px">
					<div style="width:70px; text-align:right;">{:days}</div>
					<div style="width:70px; text-align:right; color:{cost=:0?:red}">{~cost(cost)}{:model.unit}</div>
				</div>
				{days:}{min=max?:oneday?:twodays} {~words(max,:день,:дня,:дней)}
				{twodays:}{min}-{max}
				{oneday:}{max}
			{place:}{Crumb.child.child.name=:admin?:admin?:orders}
		{resume:}
			<div class="alert alert-secondary">
				<b>№{order_nick}</b><span class="nameresume">{name:pr-comma}</span><span class="phoneresume">{phone:pr-comma}</span><span class="callresume">{callback:callbackresume}</span><span class="emailresume">{email:pr-comma}</span>, {~length(basket)}&nbsp;{~words(~length(basket),:позиция,:позиции,:позиций)}
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
		{PAYINFO:}<img src="/-cart/images/cards.png">
		{useractions:}
				<div style="display: flex; margin-top:1.5rem">
					<div>
						<div style="display:{:online??:none}" class="visalogo">
							{:PAYINFO}
						</div>
					</div>
					<div style="flex-grow:1" class="myactions" data-place="orders">	
						{data.rule.actions[:place]:myactions}
					</div>
				</div>
			
		
			<!-- <script type="module">
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
			</script> -->
		{adminactions:}
			<div class="myactions" data-place="admin">
				<p>Письмо клиенту {order.dateemail?:wasemail?:noemail}</p>
				{data.rule.actions[:place]:myactions}
			</div>
			<div style="display: none;">
				<h2 style="margin-top: 40px">Техническая информация</h2>
				<div>order_id: {order_id}</div>
				<div>user_id: {user_id}</div>
				<div>order_nick: {order_nick}</div>
				<div>status: {status}</div>
				<div>paid: {paid?:да?:нет}</div>
				<div>freeze: {freeze?:да?:нет}</div>
				<div>sumclear: {sumclear}</div>
				<div>sum: {sum}</div>
				<div>sumtrans: {sumtrans}</div>
				<div>total: {total}</div>
				<div>datecreate: {~date(:d.m.Y H:i,datecreate)}</div>
				<div>datewait: {~date(:d.m.Y H:i,datewait)}</div>
				<div>dateedit: {~date(:d.m.Y H:i,dateedit)}</div>
				<div>datefreeze: {~date(:d.m.Y H:i,datefreeze)}</div>
				<div>datecheck: {~date(:d.m.Y H:i,datecheck)}</div>
				<div>datepaid: {~date(:d.m.Y H:i,datepaid)}</div>
				<div>datecomplete: {~date(:d.m.Y H:i,datecomplete)}</div>
				<div>dateemail: {~date(:d.m.Y H:i,dateemail)}</div>
				<div>datecancel: {~date(:d.m.Y H:i,datecancel)}</div>
				<div>city.country: {city.country}</div>
				<div>city.zip: {city.zip}</div>
				<div>coupon: {coupon}</div>
				{basket::techbasket}
			</div>
			
			{techbasket:}
				<div><b>{producer_nick} {article_nick} {item_num}</b></div>
				<div>count: {count}</div>
				<div>costclear: {costclear}</div>
				<div>sumclear: {sumclear}</div>
				<div>sum: {sum}</div>
				<div>cost: {cost}</div>
				<div>dateedit: {~date(:d.m.Y H:i,dateedit)}</div>
				<div>dateadd: {~date(:d.m.Y H:i,dateadd)}</div>
				<div>discount: {discount:percent}</div>
				<div>model.discount: {model.discount:percent}</div>
				<div>model.change: {model.change?:да?:нет}</div>
				<div>model.Прайс: {model.Прайс}</div>
				<div>model.Цена: {model.Цена}</div>
				<div>model.Старая цена: {model.Старая цена}</div>
				<div>model.Наличие: {model.Наличие}</div>
	{disabled:}disabled
	{percent:}{.}%
	{myactions:}
		<div class="text-right actionsbtn">
			{buttons::mybtns}
		</div>
		<script type="module">
			import { Cart } from '/vendor/infrajs/cart/Cart.js'
			import { Popup } from '/vendor/infrajs/popup/Popup.js'
			import { DOM } from '/vendor/akiyatkin/load/DOM.js'
			import { Global } from '/vendor/infrajs/layer-global/Global.js'
			import { Template } from '/vendor/infrajs/template/Template.js'

			const div = document.getElementById('{div}')
			const cls = cls => div.getElementsByClassName(cls)
			const tag = tag => div.getElementsByTagName(tag)[0]
			const form = document.forms.cart
			let btn = null;
			const order_id = {:order_id}
			const order_nick = {data.order.order_nick}
			const place = "{:place}"
			const isedit = {:isedit?:true?:false}
			
			
			for (const btn of cls('act-check')) btn.addEventListener('click', async () => {
				if (Cart.dis(form)) return
				let ans = await Cart.posts('check', { place, order_id })
				if (!ans.result) {
					await Popup.alert(ans.msg)
				} else {
					await Popup.success(ans.msg)
					await Crumb.go('/cart')	
				}
			})
			for (const btn of cls('act-tocheck')) btn.addEventListener('click', async () => {
				if (Cart.dis(form)) return
				let ans = await Cart.post('tocheck', { place, order_id })
				if (!ans.result) {
					await Popup.alert(ans.msg)
				}
			})

			for (const btn of cls('act-basket')) btn.addEventListener('click', async () => {						
				if (Cart.dis(form)) return
				Crumb.go('/cart/'+place+'/'+order_nick+'/list')
			})

			for (const btn of cls('act-complete')) btn.addEventListener('click', async () => {
				if (Cart.dis(form)) return
				const ans = await Cart.post('complete', { place, order_id })
				if (!ans.result) {
					return Popup.alert(ans.msg)
				}
			})
			for (const btn of cls('act-cancel')) btn.addEventListener('click', async () => {
				if (Cart.dis(form)) return
				const ans = await Cart.post('cancel', { place, order_id })
				if (!ans.result) {
					return Popup.alert(ans.msg)
				}
			})
			for (const btn of cls('act-pay')) btn.addEventListener('click', async () => {	
				if (Cart.dis(form)) return
				const status = "{data.order.status}"
				if (status != 'pay') {
					const ans = await Cart.post('pay', { place, order_id })
					if (!ans.result) {
						return Popup.alert(ans.msg)
					}
				}
				//Надо сбросить active ссылку чтобы назад работал правильно
				Crumb.go('/cart/orders/' + order_nick, false)
				Crumb.go('/cart/orders/' + order_nick + '/pay')
			})

			for (const btn of cls('act-wait')) btn.addEventListener('click', async () => {	
				if (Cart.dis(form)) return
				const ans = await Cart.post('wait', { place, order_id })
				if (!ans.result) {
					return Popup.alert(ans.msg)
				}
			})

			for (const btn of cls('act-delete')) btn.addEventListener('click', async () => {
				if (Cart.dis(form)) return
				Popup.confirm('Крайний вариант. Зказ бесследно исчезнет. Удалить?', async () => {
					const ans = await Cart.posts('delete', { place, order_id })
					if (!ans.result) {
						return Popup.alert(ans.msg)	
					} else {
						Popup.success(ans.msg)
						Crumb.go('/cart/'+place)
					}
				})
			})

			for (const btn of cls('act-email')) btn.addEventListener('click', async () => {	
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
					const ans = await Cart.post('email', { place, order_id }, { commentmanager })
					if (!ans.result) Popup.alert(ans.msg)
					else Popup.success(ans.msg)
				})
				
			})

			for (const btn of cls('act-print')) btn.addEventListener('click', async () => {	
				if (Cart.dis(form)) return
				await Crumb.go('/cart/'+place+'/'+order_nick+'/print')
			})
		</script>
		{mybtns:}
			<div class="act-{~key} btn btn-{cls}" style="margin-bottom: 4px">
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
			    	const place = "{:place}"
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
		{~conf.cart.coupon?:couponinpshow}
	{couponinpshow:}
		
		<input id="coupon" name="coupon" {:isdisabled} value="{data.order.coupon}" type="text" placeholder="Укажите купон">
		<button class="couponbtn" type="button">Активировать</button>

		
		<script type="module">
			import { Cart } from '/vendor/infrajs/cart/Cart.js'
			import { DOM } from '/vendor/akiyatkin/load/DOM.js'
			const div = document.getElementById('{div}')
			const cls = cls => div.getElementsByClassName(cls)
			const btn = cls('couponbtn')[0]
			const input = document.getElementById('coupon')
			const form = document.forms.basket
			const place = "{:place}"

			btn.addEventListener('click', async () => {
				const order_id = {:order_id}
				const coupon = Cart.strip_tags(input.value)
				if (Cart.dis(form)) return
				await Cart.post('setcoupon', { place, order_id, coupon })
			})
		</script>
		<div>
			{coupondata:coupinfo}
		</div>
		{prodart:}{producer_nick} {article_nick}{:cat.idsp}
		{mybasket:}Ваша корзина
		{justbasket:}Корзина
		{numbasket:}Корзина <span class="float-right">{:ordernick}</span>
		
	{cartmsg:}<p>Корзина пустая. Добавьте в корзину интересующие позиции.
			
			</p>
			<p>Чтобы добавить позицию нужно кликнуть по иконке корзины рядом с ценой в <a href="/catalog">каталог</a>.</p>
			<span data-id="{data.order.order_id}" data-place="{crumb.parent.parent.name}" 
			style="float:right" class="cart-search a">Поиск позиций</span>
			<div style="margin-top:10px">
				<a href="/catalog" style="text-decoration:none" class="btn btn-success">Открыть каталог</a>
			</div>
	{itemnocost:}<a href="/contacts">Уточнить</a>
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
					min-width: 1.6rem;
					text-align:center;
				}
			</style>
			{data.list::orderinfo}
			
		{orderinfo:}
			<div class="{~sid} bg-{data.meta.rules[status]notice}2">
				<style>
					.{~sid} {
						margin-bottom:0.5rem;
						display: grid;
						gap: 20px;
						grid-template-columns: 220px 120px 1fr;
					}
					@media(max-width: 575px) {
						.{~sid} { 
							grid-template-columns: 1fr;
							grid-row-gap: 0px;
						}
					}
				</style>
				<div>
					<b><a href="/cart/orders/{order_nick}">№{order_nick}</a></b>&nbsp;&nbsp;<a href="/cart/orders/{order_nick}/list" class="circle">{~length(basket)}</a> &mdash;&nbsp;<b title="Стоимость товаров и доставки">{~cost(total)}{:model.unit}</b>
				</div>
				<div>
					{(status=:wait&active)?data.meta.rules[status]shortactive?data.meta.rules[status]short}{coupon:pr-comma}{paid?(:оплачен):pr-comma}
				</div>
				<div style="text-align: left">
					{~date(:d.m.Y,dateedit)}
				</div>
			</div>
		{br:}<br>
		{noaccount:}
			<p>
				<b><a href="/user/signin?back=ref">Вход</a> не выполнен!</b>
			</p>
		{account:}
			<p>
				<button style="float: right" class="logout">Выход</button>
				<script type="module" async>
					import { User } from "/vendor/infrajs/user/User.js"
					const div = document.getElementById('{div}');
					const btn = div.getElementsByClassName('logout')[0]
					btn.addEventListener('click', () => User.logout())
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
		{dateform:}d.m.Y
		{isedit:}{data.rule.actions[:place]edit?:yes}
		{isdisabled:}{data.rule.actions[:place]edit|:disabled}
		{ishidedisabled:}{data.rule.actions[:place]edit|:disabledhide}
		{disabledhide:}display:none
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
		{month:}<a data-anchor="#YEARS" href="/{crumb}{now?(Crumb.get.status?:quest)?:quest}{now??:startarg}{now??(Crumb.get.status?:amp)}{Crumb.get.status?:statusget}">{F}</a>{~last()??:comma}
		{quest:}?
		{amp:}&
		{startarg:}start={start}
		{startget:}start={Crumb.get.start}
		{statusget:}status={Crumb.get.status}
	{STATUSES:}
		
	{ADMIN:}
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a class="text-danger" href="/cart">Личный кабинет</a></li>
			<li class="breadcrumb-item active">Все заказы</li>
		</ol>
		<h1>Все заказы</h1>
		<p>Заказы сортируются по дате последних изменений посетителем.</p>
		<div id="YEARS"></div>
		<div id="ADMINLIST"></div>
		{ADMINLIST:}
			<div style="margin-bottom: 15px">
				<style>
					/*#{div} .active {
						background-color: var(--warning);
						border-color: var(--warning);
						font-weight: inherit;
					}*/

					#{div} :focus {
						box-shadow: none;
					}
					#{div} a {
						margin: 2px 0;
					}

					/*#{div} a:active {
						background-color: var(--orange);
						border-color: var(--orange);
					}*/
				</style>
				<a data-anchor="#YEARS" class="btn btn-secondary" href="/{crumb}{:quest}{Crumb.get.start?:startget}{Crumb.get.start?:amp}status=wait">Активные <span class="circle">{data.counts.wait|:0}</span></a>
				<a data-anchor="#YEARS" class="btn btn-secondary" href="/{crumb}{:quest}{Crumb.get.start?:startget}{Crumb.get.start?:amp}status=pay">Ожидают оплату <span class="circle">{data.counts.pay|:0}</span></a>
				<a data-anchor="#YEARS" class="btn btn-secondary" href="/{crumb}{Crumb.get.start?:quest}{Crumb.get.start?:startget}">На проверке <span class="circle">{data.counts.check|:0}</span></a>
				<a data-anchor="#YEARS" class="btn btn-secondary" href="/{crumb}{:quest}{Crumb.get.start?:startget}{Crumb.get.start?:amp}status=complete">Выполненные <span class="circle">{data.counts.complete|:0}</span></a>
				<a data-anchor="#YEARS" class="btn btn-secondary" href="/{crumb}{:quest}{Crumb.get.start?:startget}{Crumb.get.start?:amp}status=cancel">Отменённые <span class="circle">{data.counts.cancel|:0}</span></a>
			</div>
			<script type="module" async>
				import { Activelink } from "/vendor/infrajs/activelink/Activelink.js"
				const div = document.getElementById('{div}')
				Activelink(div)
			</script>
			{data.result?:adm_listPage?:adm_message}
		{adm_listPage:}
			<h2>{data.Y}, {data.F} <span title="Отправленных заказов" class="float-right">{data.count} на {~cost(data.total)}{:model.unit}</span></h2>
			{data.list::adm_row}
			<script type="module" async>
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				import { Popup } from '/vendor/infrajs/popup/Popup.js'
				import { DOM } from '/vendor/akiyatkin/load/DOM.js'
				import { Global } from '/vendor/infrajs/layer-global/Global.js'

				const div = document.getElementById('{div}')
				const cls = cls => div.getElementsByClassName(cls)
				const place = "{:place}"
				//const paid = {data.order.paid?:true?:false}
				let btns
				btns = cls('act-complete')
				for (const btn of btns) btn.addEventListener('click', async () => {

					const order_id = btn.dataset.order_id
					const ans = await Cart.post('complete', { place, order_id })
					if (!ans.result) await Popup.alert(ans.msg)
				})
				btns = cls('act-cancel')
				for (const btn of btns) btn.addEventListener('click', async () => {
					const order_id = btn.dataset.order_id
					const ans = await Cart.post('cancel', { place, order_id })
					if (!ans.result) await Popup.alert(ans.msg)
				})

				btns = cls('act-tocheck')
				for (const btn of btns) {
					//if (!paid) btn.style.display = 'inline-block';
					btn.addEventListener('click', async () => {
						const order_id = btn.dataset.order_id
						const ans = await Cart.post('tocheck', { order_id })
						if (!ans.result) await Popup.alert(ans.msg)
					})
				}
			</script>
			{orderpaidb:}, <b>оплачен, {~cost(total)}{:model.unit}</b>
			{bgwait:}opacity:0.5;
			{adm_row:}
				<div style="margin-bottom: 0.5rem; padding: 0.5rem; border:1px solid #dee2e6">
					<style>
						#{div} .circle {
							border-radius:50%;
							display:inline-block;
							border: solid 1px gray;
							min-width: 1.6rem;
							text-align:center;
						}
					</style>
					<b><a href="/cart/admin/{order_nick}">{order_nick}</a></b>
					<a href="/cart/admin/{order_nick}/list" class="circle">{~length(basket)}</a> 
					<nobr>{data.meta.rules[status]shortactive|data.meta.rules[status]short}</nobr>{paid?:orderpaidb}

					<div style="text-align: right; float: right">
						<span title="Дата редактирования">{~date(:d.m.Y H:i,dateedit)}</span><br>
						{email}<br><b>{sum:itemcostrub}</b>
					</div>
					
					<div>
						{city.city|:citynone}{name:pr-comma}{phone:pr-acomma}{coupon:pr-comma}
						{transport?:adminlisttrans}
						{pay?:adminlistpay}
					</div>
					<div style="clear:both">
						{comment:usercomment}
						{commentmanager:admincomment}
					</div>
					
				</div>
				{adminlisttrans:}<br>{:label_{transport}}{sumtrans!:0?:adminsumtrans}
				{adminsumtrans:}&nbsp;<b>{~cost(sumtrans)}{:model.unit}</b>
				{adminlistpay:}<br>{:pay_label_{pay}}
				{pr-acomma:}, <a href="tel:{~tel(.)}">{.}</a>
				{usercomment:}<pre class="mt-2 px-2 p-1 alert-secondary">{.}</pre>
				{admincomment:}<pre class="mt-2 px-2 p-1 alert-success">{.}</pre>	
				{acomplete:} &mdash; <span class="a act-complete" data-order_id="{order_id}">готов</span>
				{atocheck:} &mdash; <span class="a act-tocheck" data-order_id="{order_id}">на проверку</span>
				{productlist:}
					<div style="text-overflow: ellipsis; 
					overflow: hidden;">
						{basket::product}
					</div>
				{product:} 
					<nobr>{count} <a href="/catalog/{model.producer_nick}/{model.article_nick}{model:cat.idsl}">{model.article}</a>{~last()|:comma}</nobr><wbr>

				{adm_paidorder:}<b>{~cost(manage.paid)}{:model.unit}</b> {manage.paidtype=:bank?:банк?:менеджер} {~date(:d.m.Y H:i,manage.paidtime)}
	{cat::}-catalog/cat.tpl?v={~conf.index.v}
	{extend::}-catalog/extend.tpl?v={~conf.index.v}
	{model::}-catalog/model.tpl?v={~conf.index.v}
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
		<i class="msg" style="float:right"></i>
		<div style="margin-bottom: 0.5rem">Письмо <b>{email}</b> об изменениях в заказе <b>№{order_nick}</b></div>
		<textarea rows="4" style="margin-bottom:0.5rem" class="mngcom form-control">{commentmanager}</textarea>
		<p>Письмо {dateemail?:was?:notwas}</p>
		<script type="module" async>
			import { Cart } from '/vendor/infrajs/cart/Cart.js'

			const div = document.getElementsByClassName('input-commentmanager')[0]
			const textarea = div.getElementsByClassName('mngcom')[0]
			const msg = div.getElementsByClassName('msg')[0]
			const order_id = {order_id}
			const place = "{:place}"
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
	{notwas:}<b>ещё не отправлялось</b>
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
	{data.order:resume|:ordermessage}
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

	
{amount:}
	
	<div>
		Стоимость{(coupondata.result&sum!sumclear)?:nodiscount}: <b class="sumclear">{~cost(sumclear)}{:model.unit}</b><br>
		{(coupondata.result&sum!sumclear)?:prcoupon}
	</div>
	
	
	<div class="transportready" style="display:{transport??:none}">
		<div><span class="titletrans">{:label_{transport}}</span><b class="sumtrans">{(transport!:any)&(transport!:self)?:showsumtrans}</b></div>
		<div class="transresume">{:info_{transport}}</div>
	</div>
	<div class="payresume">{pay?:pay_label_{pay}}</div>
	Всего: <b class="total">{~cost(total)}{:model.unit}</b>
	
	{showsumtrans:}: {~cost(sumtrans)}{:model.unit}
	{none:}none
	{any:}any
	{self:}self
	{prcoupon:}
		Купон: <b>{coupon}</b><br>
		Сумма со скидкой: <b class="sum">{~cost(sum)}{:model.unit}</b><br>

	{descr_cdek_pvz:}<div style="margin-bottom:0.5rem">{...pvz} <nobr style="{:ishidedisabled}" class="a showpvz">{...pvz?:Изменить?:Выбрать} пункт выдачи</nobr></div>
	{info_cdek_pvz:}{city.city|:citynone}, {pvz}
	{label_cdek_pvz:}Доставка до пункта выдачи СДЕК
	{label_cdek_pvz_short:}До пункта выдачи

	{descr_city:}{:inpaddress}
	{info_city:}{address}
	{label_city:}Доставка по Тольятти
	{label_city_short:}{:label_city}
	
	{descr_self:}ул. Новозаводская 2Б, торг.павильон №1, 1/23. <span class="a showMap">Схема&nbsp;проезда</span>
	{info_self:}
	{label_self:}Самовывоз из магазина в Тольятти
	{label_self_short:}{:label_self}

	
	{optiontk:}
		<option {.=data.order.tk?:selected}>{.}</option>
	{descr_any:}
		<div style="font-size:13px; color:#888; margin-top:-4px;">
			<p>Стоимость услуг транспортной компании по доставке до города получателя оплачивается самим получателем в транспортной компании при получении заказа.
			</p>
			Укажите предпочтительную ТК
			<select name="tk" {:isdisabled} class="form-control select-tk" style="margin-top: 5px">
				<option value=""></option>
				{...tks::optiontk}
			</select>
			<script type="module" async>
				import { Cart } from '/vendor/infrajs/cart/Cart.js'
				const form = document.forms.cart
				const cls = (cls, div = form) => div.getElementsByClassName(cls)
				const place = "{:place}"
				const order_id = {:order_id}
				const select = cls('select-tk')[0]
				const change = async () => {
					const n = select.options.selectedIndex
					const tk = select.options[n].value
					const transport = form.elements.transport.value
					const data = {
						"city":{
							"city":"{data.order.city.city}"
						},
						"tk":tk
					}
					const ans = await Cart.posts('settk', { place, order_id, tk })
					cls('transresume')[0].innerHTML = transport ? Template.parse("{tpl}", data, "info_" + transport) : ''
					if (!ans.result) Popup.alert(ans.msg)
				}
				select.addEventListener('change', change)
			</script>
		</div>
	{info_any:}{tk?:rectk}
	{rectk:}Предпочтительная ТК {tk}
	{label_any:}Способ и стоимость доставки, согласовываются отдельно. {city.city|:citynone}.
	{label_any_short:}Согласовать оптимальную ТК с менеджером

	{descr_cdek_courier:}{:inpaddress}
	{info_cdek_courier:}{city.city|:citynone}, {address}<br>
	{label_cdek_courier:}Доставка курьером СДЕК
	{label_cdek_courier_short:}Курьер
	
	{descr_pochta_simple:}{:inpzip}{:inpaddress}
	{info_pochta_simple:}{city.city|:citynone}, {zip} {address}<br>
	{label_pochta_simple:}Доставка Почтой России
	{label_pochta_simple_short:}Посылка обыкновенная

	{descr_pochta_1:}{:inpzip}{:inpaddress}
	{info_pochta_1:}{:info_pochta_simple}
	{label_pochta_1:}Доставка Почтой России 1 класс
	{label_pochta_1_short:}Первый класс

	{descr_pochta_courier:}{:inpzip}{:inpaddress}
	{info_pochta_courier:}{:info_pochta_simple}
	{label_pochta_courier:}Доставка курьером Почты России
	{label_pochta_courier_short:}Курьер
	{citynone:}Город не найден
	{inpaddress:}
		<div class="input-address">
			<label class="w-100">Адрес доставки<!--  (<span class="{:isedit?:a?:text-danger} citychoice">{data.order.city.city}</span>)  -->
				<i class="msg float-right"></i>
			</label>
			<input {:isdisabled} type="text" name="address" value="{data.order.address}" class="form-control address" placeholder="ул, дом, кв, офис">
		</div>
	{inpzip:}
		<div class="input-zip">
			<label class="w-100">Почтовый индекс<i class="msg float-right"></i></label>
			<!-- <p><span class="a">указать</span> или <b>выбрать из списка</b></p> -->
			<input {:isdisabled} type="text" name="zip" value="{data.order.zip}" class="form-control zip" placeholder="Индекс">
			<!-- <select name="zip" {:isdisabled} class="zip form-control" type="text" list="zips" autocomplete="off">
				<option></option>
				{data.order.city.zips::zipopt}
			</select> -->

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