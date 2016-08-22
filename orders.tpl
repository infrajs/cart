{header:}
	<style>
		.a.pay > a {
			color: inherit;
			text-decoration: none;
		}
		.a.pay > a:hover {
			color: inherit;
			text-decoration: none;
		}
		.delivery, .legal{
			display:none;
		}
		.ordersList td {
			text-align: center;
			vertical-align: middle;
		}
		table.common.ordersList th.com {
			text-align: center;
			vertical-align: top;
			border-bottom: 1px solid #ccc;
			border-left: 1px solid #ccc;
		}
		table.common.ordersList th.com.first {
			border-left: none;
		}
		#content > form#adminForm {
			margin: 20px 0;
		}
	</style>
	<div id="usermenu"></div>
{root:}
	{:header}
	{data?:ordersList?:noOrders}

{ordersList:}
	<h1>Мои заявки 
		<button type="button" class="btn btn-default pull-right" onclick="cart.refresh()"><span class="glyphicon glyphicon-refresh"></span></button>
	</h1>
	<!--<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>-->
	<table class="ordersList table table-striped">
		<thead>
		<tr>
			<th>Номер</th>
			<th>Статус</th>
			<th>Сумма</th>
			<th>Состав</th>
			<th>Дата</th>
		</tr>
		</thead>
		<tbody>
			{data.list::rowOrders}
		</tbody>
	</table>
	<div style="margin-top:10px">
		<a onclick="cart.goTop();" href="?office/orders/my" style="text-decoration:none" class="btn btn-success">Активная заявка ({data.order.count} {~words(data.order.count,:позиция,:позиции,:позиций)})</a>
	</div>
	{noOrders:} <div>В данный момент у вас нет заявок с товарами.</div>
	{rowOrders:}
		<tr>
			<td>
				<a onclick="cart.goTop()" href="?office/orders/{status=:active?:my?id}">{status=:active?:Активная?id}</a>
			</td>
			<td>
				{rule.short}
			</td>
			<td>
				<span class="{merchdyn?:bg-success?(manage.summary|:bg-info)}">{total:itemcost}</span>
			</td>
			<td>
				{basket::product}
			</td>
			<td>{~date(:j F H:i,time)}</td>
		</tr>
	{dateform:}d.m.Y
	{product:} <nobr>{count} <a href="?Каталог/{Производитель}/{article}">{Артикул}</a>{~last()|:comma}</nobr>
	
	{copyOnly:}
		<span class="a copy" data-id="{id}">Копировать</span>

	{copyWithCancel:}
		<span class="a copy" data-id="{id}">Копировать</span><br>
		<span class="a refunds" data-id="{id}">Отменить</span>

	{readyPack:} 
		<span class="a paycard" data-id="{id}">оплатить</span><br>
		<span class="a active" data-id="{id}">сделать активной</span><br>
		<span class="a copy" data-id="{id}">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>

	{savedPack:}
		<span class="a check" data-id="{id}">на проверку</span><br>
		<span class="a active" data-id="{id}">сделать активной</span><br>
		<span class="a copy" data-id="{id}">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>

	{activePack:}
		<span class="a save" data-id="{id}">сохранить</span><br>
		<span class="a clear" data-id="{id}">очистить</span><br>
		<span class="a check" data-id="{id}">на&nbsp;проверку</span><br>
		<a href="?office/cart">корзина</a>
{orderfields:}
	<div class="form-group">
		<label>Контактное лицо <span class="req">*</span></label>
		<input {rule.edit[place]|:disabled} type="text" name="name" value="{name}" class="form-control" placeholder="Контактное лицо">
	</div>
	<div class="form-group">
		<label>Телефон <span class="req">*</span></label>
		<input {rule.edit[place]|:disabled} type="tel" name="phone"  value="{phone}" class="form-control" placeholder="Телефон">
	</div>
	<div class="form-group">
		<label>Email <span class="req">*</span></label>
		<input type="email" name="email" value="{email}" {email?:disabled} class="form-control" placeholder="Email">
	</div>
	<strong>
		Кто будет оплачивать <span class="req">*</span>
	</strong>
	<div class="radio">
		<label>
			<input {rule.edit[place]|:disabled} name="entity" {entity=:individual?:checked} type="radio" value="individual">
			Физическое лицо
		</label>
	</div>
	<div class="radio">
		<label>
			<input {rule.edit[place]|:disabled} name="entity" {entity=:legal?:checked} type="radio" value="legal">
			Юридическое лицо
		</label>
	</div>
	<div class="entitylegal">
		<script>
			infra.when(infrajs,'onshow',function(){
				var layer=infrajs.getUnickLayer('{unick}');
				var div=$('#'+layer.div);
				if(div.find("input[name=entity]:checked").val()!='legal'){
					div.find('.entitylegal').hide();
				}
				div.find("input[name=entity]:radio").change(function() {
					if ($(this).val()=='legal') {
						$('.entitylegal').slideDown('slow');
					} else {
						$('.entitylegal').slideUp('slow');
					}
				});
			});
		</script>
		<strong>Реквизиты <span class="req">*</span></strong>
		<div class="radio">
			<label>
				<input {rule.edit[place]|:disabled} name="details" {details=:here?:checked} type="radio" value="here">
				Указать реквизиты в полях для ввода
			</label>
		</div>
		<div class="radio">
			<label>
				<input {rule.edit[place]|:disabled} name="details" {details=:allentity?:checked} type="radio" value="allentity">
				Указать все реквизиты в одном поле для ввода
			</label>
		</div>
		<div class="allentity">
			<script>
				infra.when(infrajs,'onshow',function(){
					var layer=infrajs.getUnickLayer('{unick}');
					var div=$('#'+layer.div);
					if(div.find("input[name=details]:checked").val()!='allentity'){
						div.find('.allentity').hide();
					}
					div.find("input[name=details]:radio").change(function() {
						if ($(this).val()=='allentity') {
							$('.allentity').slideDown('slow');
						} else {
							$('.allentity').slideUp('slow');
						}
					});
					
				});
			</script>
			<div class="form-group">
				<label>
					Скопируйте реквизиты из карточки компании
				</label>
				<textarea {rule.edit[place]|:disabled} class="form-control" rows="8" name="allentity"></textarea>
			</div>
			
		</div>
		<div class="detailshere">
			<script>
				infra.when(infrajs,'onshow',function(){
					var layer=infrajs.getUnickLayer('{unick}');
					var div=$('#'+layer.div);
					if(div.find("input[name=details]:checked").val()!='here'){
						div.find('.detailshere').hide();
					}
					
					div.find("input[name=details]:radio").change(function() {
						if ($(this).val()=='here') {
							$('.detailshere').slideDown('slow');
						} else {
							$('.detailshere').slideUp('slow');
						}
					});
					
				});
			</script>
			<div class="form-group">
				<label>Название организации <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="company" value="{company}" class="form-control" placeholder='Название организации'>
			</div>
			<div class="form-group">
				<label>ИНН <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="inn" value="{inn}" class="form-control" placeholder="ИНН">
			</div>
			<div class="form-group">
				<label>Юридический адрес <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="addreslegal" value="{addreslegal}" class="form-control" placeholder="Юридический адрес">
			</div>
			<div class="form-group">
				<label>Почтовый адрес <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="addrespochta" value="{addrespochta}" class="form-control" placeholder="Почтовый адрес">
			</div>
			<div class="form-group">
				<label>Наименование банка <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="bankname" value="{bankname}" class="form-control" placeholder="Наименование банка">
			</div>
			<div class="form-group">
				<label>Бик <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="bik" value="{bik}" class="form-control" placeholder="Бик">
			</div>
			<div class="form-group">
				<label>Расчётный счёт <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="rasaccount" value="{rasaccount}" class="form-control" placeholder="Расчётный счёт">
			</div>
			<div class="form-group">
				<label>Корреспондентский счёт <span class="req">*</span></label>
				<input {rule.edit[place]|:disabled} type="text" name="coraccount" value="{coraccount}" class="form-control" placeholder="Корреспондентский счёт">
			</div>
			
		</div>
		
	</div>
	
	<strong>
			Способ оплаты <span class="req">*</span>
	</strong>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="paymenttype" {paymenttype=:card?:checked} type="radio" value="card"> Оплата картой</label>
	</div>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="paymenttype" {paymenttype=:cash?:checked} type="radio" value="cash"> Оплата наличными курьеру или в магазине</label>
	</div>
	

	<strong>
			Способ доставки <span class="req">*</span>
	</strong>
	<div class="radio">
		<label><input {rule.edit[place]|:disabled} name="delivery" {delivery=:pickup?:checked} type="radio" value="pickup"> Самовывоз</label>
	</div>
	<div class="radio">
		<label><input id="delivery" {rule.edit[place]|:disabled} name="delivery" {delivery=:delivery?:checked} type="radio" value="delivery"> Доставка транспортной компанией</label>
	</div>
	<div class="delivery">
		<script>
			infra.when(infrajs,'onshow',function(){
				var layer=infrajs.getUnickLayer('{unick}');
				var div=$('#'+layer.div);
				if(div.find("input[name=delivery]:checked").val()!='delivery'){
					div.find('.delivery').hide();
				}
				div.find("input[name=delivery]:radio").change(function() {
					if ($(this).val()=='delivery') {
						$('.delivery').slideDown();
					} else {
						$('.delivery').slideUp();
					}
				});
			});
		</script>
		<div class="form-group">
			<label>Адрес доставки <span class="req">*</span></label>
			<input {rule.edit[place]|:disabled} type="text" name="addresdelivery" value="{addresdelivery}" class="form-control" placeholder="Адрес доставки">
		</div>
		<script>
			/*infra.when(infrajs,'onshow',function(){
				var layer=infrajs.getUnickLayer('{unick}');
				var div=$('#'+layer.div);
				if ($("#delivery").prop('checked')) {
					div.find('.delivery').slideDown();
				} else {
					div.find('.delivery').slideUp();
				}
			});
			*/
		</script>
	</div>
{orderPage:}
	{:header}
	{data.result?data:orderPageContent?:message}
	{message:}
		<h1>{data.id}</h1>
		<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>
		{data.ismy?:activebutton}
	{activebutton:}
		<div style="margin-top:10px">
			<a onclick="cart.goTop()" href="?office/orders/my" class="btn btn-success">
				Показать заявку
			</a>
		</div>
	{manage:}
		
		<div class="alert alert-info" role="alert"><h3 style="margin-top:0">Сообщение менеджера</h3>{manage.comment}</div>
	{orderPageContent:}
		<h1>{rule.title}</h1>
		{data.id?:ordernum}
		{manage.comment?:manage}
		<form>
			<div class="cartcontacts">
				{:orderfields}
				<div>
					<strong>Сообщение для менеджера</strong>
					<textarea {rule.edit[place]|:disabled} name="comment" class="form-control" rows="4">{comment}</textarea>
				</div>
			</div>
			<div class="answer"><b class="alert">{config.ans.msg}</b></div>
			<script>
				infra.when(infrajs,'oncheck',function(){
					var layer=infrajs.getUnickLayer("{unick}");
					infra.when(layer,'onshow',function(){
						var div=$('#'+layer.div);
						var id="{state.name}";
						if(id=='my')id=null;
						var order=cart.getGoodOrder(id);
						var place=div.find('.myactions').data('place');
						//if(!order.rule.edit[place])cart.blockform(layer);
					});
				});
			
			</script>
		</form>
		
		{~length(basket)?:tableWidthProduct?:noProducts}
		<div style="margin-bottom:10px">Итого: <span class="cartsum">{~sum(total,manage.deliverycost|:0):itemcost}</span></div>
		<h3>{rule.title}</h3>
		{data.id?:ordernum}
		<div class="myactions" data-place="orders">
			{rule.user:myactions}
		</div>
		
	{myactions:}
		<div style="margin:20px 0;">
			<div class="btn-toolbar dropup" role="toolbar">
				<div class="btn-group">
					<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
						<span class="caret"></span>
					</button>
					<ul class="dropdown-menu pull-left" role="menu">
						{actions::actprint}
					</ul>
				</div>
				{buttons::mybtns}
				
			</div>
		</div>
		{mybtns:}
			<div class="btn-group">
				<a data-id="{data.id}" class="act-{act} btn btn-{cls}"
					{link?:actlink?:actact} style="text-decoration:none">
					{title}
				</a>
			</div>
		{actprint:}
			<li>
				<a onclick="return false" class="act-{act}" style="text-decoration:none" {link?:actlink?:actact}>
					{title}
				</a>
			</li>
			{actlink:}href="{link}" data-id="{data.id}" onclick="return false"
			{actact:}data-id="{data.id}" href="?{state}" onclick="return false"
	{b:}<b>
	{/b:}</b>
	{noProducts:}
		<h3>В заявке нет товаров.</h3>
	{copyOnly2:}
	<!--	<span class="a copy" data-id="{id}" data-orderPage="1">Копировать</span>-->

	{copyWithCancel2:}
	<!--	<span class="a copy" data-id="{id}" data-orderPage="1">Копировать</span><br>
		<span class="a refunds" data-id="{id}">Отменить</span>-->

	{readyPack2:} 
		<!--<div style="margin-bottom:10px">
			<span data-id="{id}" data-orderPage="1" class="paycard btn btn-success">
				Перейти к оплате
			</span>
			<span data-id="{id}" data-orderPage="1" class="active btn btn-primary">
				сделать активной
			</span>
		</div>
		<span class="a copy" data-id="{id}" data-orderPage="1">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>-->
	{savedPack2:}
		<!--<span class="a check" data-id="{id}" data-orderPage="1">на проверку</span><br>
		<span class="a active" data-id="{id}" data-orderPage="1">сделать активной</span><br>
		<span class="a copy" data-id="{id}" data-orderPage="1">копировать</span><br>
		<span class="a remove" data-id="{id}">удалить</span>-->

	{activePack2:}
		<!--<div class="btn-toolbar" role="toolbar">
			<div class="btn-group pull-right">
				<span data-id="{id}" data-orderPage="1" class="check btn btn-success">
					Отправить заявку на проверку
				</span>
			</div>
			<div class="btn-group pull-left">
				<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
					Доступные действия <span class="caret"></span>
				</button>
				<ul class="dropdown-menu pull-left" role="menu">
					<li>
						<a class="check" data-id="{id}" data-orderPage="1" href="?{state}"
							onclick="return false" style="text-decoration:none">
							<b>Отправить заявку на проверку</b>
						</a>
					</li>
					<li class="divider"></li>
					
					<li>
						<a href="?office/cart"
							onclick="cart.goTop()" style="text-decoration:none">
							Редактировать товары в заявке
						</a>
					</li>
					
					<li>
						<a class="save" data-id="{id}" data-orderPage="1" href="?{state}"
							onclick="return false" style="text-decoration:none">
							Перенести заявку в сохранённые
						</a>
					</li>
					<li>
						<a class="clear" data-id="{id}" href="?{state}"
							onclick="return false" style="text-decoration:none">
							Очистить все товары из заявки
						</a>
					</li>
				</ul>
			</div>
		</div>-->
		


{dateFormat:}d.m.Y h:i:s

{tableWidthProduct:}
	<table class="table table-striped">
		<tr>
			<th>Позиция</th>
			<th><span class="{merchdyn?:bg-success?:bg-info}">Цена {merchdyn?: оптовая?: розничная}</span></th>
			<th>Количество</th>
			<th>Сумма</th>
		</tr>
		{basket::positionRow}
		<tr><td></td><td></td><td></td><td>{sum:itemcost}</td></tr>
	</table>
	{manage.summary?:widthSummary}
	{manage.deliverycost?:widthDivelery}

	
	{positionRow:}
		<tr>
			<td><a href="?Каталог/{Производитель}/{article}">{Производитель} {article}</a>{change?:star}</td>
			<td>{cost:itemcost}</td>
			<td>{count}</td>
			<td>{sum:itemcost}</td>
		</tr>

	{widthSummary:}
		<div>
			Сумма подтверждёная менеджером: <span>{manage.summary:itemcost}</span>
		</div>
	{widthDivelery:}
		<div>
			Доставка: <span>{manage.deliverycost:itemcost}</span>
		</div>



{adm_root:}
	{:header}
	{data.result?:adm_listPage?:adm_message}
{adm_listPage:}
	<h1>Список заявок <button type="button" class="btn btn-default pull-right" onclick="cart.refresh()"><span class="glyphicon glyphicon-refresh"></span></button></h1>
	<script>
		infra.when(infrajs,'onshow',function(){
			infra.require('vendor/christianbach/tablesorter/jquery.tablesorter.min.js');
			$('#orderscontrol').tablesorter();
		});
	</script>
	<table id="orderscontrol" class="table table-striped ordersList tablesorter-bootstrap tablesorter-icon">
		<thead>
		<tr>
			<th>Номер</th>
			<th>Клиент</th>
			<th>Статус</th>
			<th>Цена</th>
			<th>Оплата</th>
			<th>Состав</th>
			<th data-date-format="ddmmyyyy">Дата</th>
		</tr>
		</thead>
		<tbody>
			{data.products::adm_row}
		</tbody>
	</table>

	{adm_row:}
		<tr>
			<td>
				<a onclick="cart.goTop()" href="?office/admin/{id}">{id}</a>
			</td>
			<td>{email}</td>
			<td>	
				{rule.short}
			</td>
			<td>
				<span style="cursor:pointer" onclick="$(this).next().toggle()" class="{merchdyn?:bg-success?(manage.summary|:bg-info)}">
					{total:itemcost}</span>
					<div style="font-size:10px; text-align:left; display:none;">
						Доставка <b>{manage.deliverycost:itemcost}</b><br>
						Цена товаров по прайсу <b>{sum:itemcost}</b><br>
						Цена товаров со скидкой <b>{manage.summary:itemcost}</b><br>
						Цена к оплате <b>{alltotal:itemcost}</b><br>
						Цена возвращаемая при возврате товара <b>{total:itemcost}</b><br>
					</div>
			</td>
			<td><small>{manage.paid?:adm_paidorder}</small></td>


			<td>
				{basket::adm_product}
			</td>
			<td>
				{~date(:d.m.Y H:i,time)}
			</td>
		</tr>
		{adm_product:} <nobr>{count} <a href="?Каталог/{Производитель}/{article}">{Артикул}</a>{~last()|:comma}</nobr>

{adm_paidorder:}<b>{~cost(manage.paid)} руб.</b> {manage.paidtype=:bank?:банк?:менеджер} {~date(:d.m.Y H:i,manage.paidtime)}
{adm_orderPage:}
	{:header}
	{data.result?data:adm_orderPageContent?:adm_message}

	
{adm_message:}
	<div class="{data.msgclass}">{config.ans.msg?config.ans.msg?data.msg}</div>

{freezemsg:}<br>Цены зафиксированы {~date(manage.freeze)}
{adm_orderPageContent:}
	<h1>{rule.title}</h1>
	{data.id?:ordernum}
	<form action="{infra.theme(:*cart/orderscontrol.php)}?save=1" id="adminForm" method="post">
		<div class="disabled">
			<div class="cartcontacts">
				{:orderfields}
				<label>Сообщение для менеджера</label><br> 
				<textarea disabled name="comment" class="form-control" rows="4">{comment}</textarea>
			</div>
			<br><hr><br>
			
			{count?:tableWidthProduct?:noProducts}
			
			<div style="margin-bottom:10px">Итого: <span class="cartsum">{~sum(total,manage.deliverycost|:0):itemcost}</span></div>


			<label>Цена со скидкой<br> 
			<input name="manage.summary" value="{manage.summary}" type="text"></label><br />
			<label>Цена доставки <br> 
			<input name="manage.deliverycost" value="{manage.deliverycost}" type="text"></label><br />
			<label>Сообщение для клиента</label><br>
			<textarea name="manage.comment" class="form-control" rows="4">{manage.comment}</textarea>
			<div class="answer"><b class="alert">{config.ans.msg}</b></div>
		</div>
	</form>
	<h3>{rule.title}</h3>
	{data.id?:ordernum}
	{data.rule.freeze?:freezemsg}
	<div class="checkbox">
		<label>
			<input type="checkbox" "autosave"="0" onclick="infra.session.set('dontNotify',this.checked)" name="dontNotify">
			НЕ оповещать пользователя о совершённом действии
		</label>
		<script>
			infra.when(infrajs,'onshow',function(){
				var layer=infrajs.getUnickLayer('{unick}');
				var div=$('#'+layer.div);
				var check=!!infra.session.get('dontNofify');
				div.find('[name=dontNotify]').val(check);
			});
		</script>
	</div>

	<div class="myactions" data-place="admin">
		{rule.manager:myactions}
	</div>
	
	
	
	
	<script>
		infra.when(infrajs,'onshow',function(){
			var layer=infrajs.getUnickLayer('{unick}');
			var div=$('#'+layer.div);
			var counter={counter};
			var id="{state.name}";
			if(id=='my')id=null;
			var order=cart.getGoodOrder(id);
			var place=div.find('.myactions').data('place');
			if(!order.rule.edit[place])cart.blockform(layer);

			infra.listen(layer,'onsubmit',function(layer){
				if(!layer.showed||counter!=layer.counter)return;
				var ans=layer.config.ans;
				infrajs.global.set('order');
				roller.goTop();
			});
			
			if(infra.session.get('manager{data.id}')){
				$('.clearMyDelta').css('fontWeight', 'bold');
			}else{
				$('.clearMyDelta').css('fontWeight', 'normal');
			}
			
			infra.listen(infra.session,'onsync',function(){
				if(!layer.showed||counter!=layer.counter)return;
				if(infra.session.get('manager{data.id}')){
					$('.clearMyDelta').css('fontWeight', 'bold');
				}else{
					$('.clearMyDelta').css('fontWeight', 'normal');
				}
			});
			if ($("#legal").prop('checked')) {
				$('.legal').slideDown();
			} else {
				$('.legal').slideUp();
			}			
			if ($("#delivery").prop('checked')) {
				$('.delivery').slideDown();
			} else {
				$('.delivery').slideUp();
			}
			
			$("input[name=entity]:radio").change(function() {
				if ($("#legal").prop('checked')) {
					$('.legal').slideDown();
				} else {
					$('.legal').slideUp();
				}
			});
			$("input[name=delivery]:radio").change(function() {
				if ($("#delivery").prop('checked')) {
					$('.delivery').slideDown();
				} else {
					$('.delivery').slideUp();
				}
			});
		});
	</script>
{comma:},
{itemcost:}{~cost(.)}&nbsp;<small>руб.</small>
{star:}*
{ordernum:}Номер заявки: <b>{data.id}</b>{manage.paid?:msgpaidorder}
	{msgpaidorder:}. Оплата <b>{~cost(manage.paid)} руб.</b> отметка {manage.paidtype=:bank?:банка?:менеджера} {~date(:d.m.Y H:i,manage.paidtime)}