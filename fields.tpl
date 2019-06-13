{POCHTA:}
	<h1>Доставка Почтой России</h1>
	{:pochtamore}
	<div class="row">
		{:maininputs}
	</div>
	{col:}col-6 col-md-4
{POCHTA1:}
	<h1>Доставка Почтой России 1 Класс</h1>
	{:pochtamore}
	<div class="row">
		{:maininputs}
	</div>
{CARGO:}
	<h1>Доставка Транспортной Компанией</h1>
	<div class="more alert border">
		<div class="d-flex">
			<div class="mr-3 d-none d-sm-block">
				<img src="/-imager/?w=100&src=-cart/images/cargo.png">
			</div>
			<div class="flex-grow-1">
				<ul>
					<li>Удобный, экономичный и довольно быстрый способ доставки, подходит для отправки товаров любых габаритов.</li>
					<li>После прибытия груза в ваш город, сотрудник транспортной компании известит Вас, позвонив на указанный в заказе номер телефона.</li>
				</ul>
				{:whencost}
			</div>
		</div>
	</div>
	<div class="row">
		<div class="{:col}">
			<label>Выберите транспортную компанию <span class="req">*</span></label>
			<select {:isdisabled} value="{transport.cargo}" name="transport.cargo" class="custom-select form-control">
				<option></option>
				<option {(:Деловые линии):caropt}>Деловые линии</option>
				<option {(:ПЭК):caropt}>ПЭК</option>
				<option {(:СДЭК):caropt}>СДЭК</option>
				<option {(:DPD):caropt}>DPD</option>
				<option {(:КИТ):caropt}>КИТ</option>
				<option {(:Байкал Сервис):caropt}>Байкал Сервис</option>
				<option {(:Энергия):caropt}>Энергия</option>
			</select>
		</div>
		{~obj(:title,:Регион,:name,:region):inp}
		{~obj(:title,:Город/Населённый пункт,:name,:city):inp}
	</div>
	<div class="alert border">
		<div class="row">
			{~obj(:title,:Серия паспорта,:name,:passeriya):inp}
			{~obj(:title,:Номер паспорта,:name,:pasnumber):inp}
		</div>
		<p>
			<i>Для отправки выбранной транспортной компанией, потребуется серия и номер паспорта, по этому документу Вам будет выдаваться груз. <b>Требование грузоперевозчика</b>.</i>
		</p>
	</div>
	{caropt:}{data.order.transport.cargo=.?:selected} value="{.}" 
	{Деловые линии:}Деловые линии
	{ПЭК:}ПЭК
	{СДЭК:}СДЭК
	{DPD:}DPD
	{КИТ:}КИТ
	{Байкал Сервис:}Байкал Сервис
	{Энергия:}Энергия
{SELF:}
	<h1>Самовывоз из пунктов выдачи в г. Тольятти</h1>
	<div class="more alert border">
		<div class="d-flex">
			<div class="mr-3 d-none d-sm-block">
				<img src="/-imager/?w=100&src=-cart/images/self.png">
			</div>
			<div class="flex-grow-1">
				<ul>
					<li>Время готового к выдачи заказа Вам сообщит менеджер, после оформления заказа.</li>
					<li>Если заказ будет оплачен до получения, то при выдачи товара нужно будет предъявить документ удостоверяющий личность.</li>
					<li>Скомплектованный заказ хранится в пункте выдачи не более 3х дней, если вам необходимо продлить срок хранеия готового заказа, сообщайте об этом вашему менеджеру.</li>
				</ul>
			</div>
		</div>
	</div>
	<div class="form-group">
		<label>Пункты выдачи <span class="req">*</span></label>
		<select {:isdisabled} onchange="
				var row = $(this).parent().parent();
				row.find('[data-value]').hide();
				row.find('[data-value=\''+this.value+'\']').fadeIn();
			" {:isdisabled} name="transport.self" class="custom-select form-control">
			<option></option>
			<option {(:Центральный):selfopt}>Центральный район, ул. Новозаводская 2Б, торг. павильон №1, 1/23</option>
			<option {(:Мадагаскар):selfopt}>Автозаводской район, ул. Льва Яшина 14, ТРЦ "Мадагаскар", 20 кв.</option>
			<option {(:8 кв):selfopt}>Автозаводской район, ул. Степана Разина 78Б, офис №113, 8 кв.</option>
		</select>
	</div>
	<div {(:Центральный):selfinfo}>
		<ul>
			<li>Время работы: Пн-Вт с 7:00 до 14:30, Ср-Пт с 9:00 до 12:30</li>
			<li>Время готового к выдачи заказа Вам сообщит менеджер, после оформления заказа.</li>
		</ul>
	</div>
	<div {(:Мадагаскар):selfinfo}>
		<ul>
			<li>Время работы: ежедневно 10:00-21:00 (1-й этаж островной отдел с товарами для праздника, напротив отдела "Рив Гош")</li>
			<li>Время готового к выдачи заказа Вам сообщит менеджер, после оформления заказа.</li>
		</ul>
	</div>
	<div {(:8 кв):selfinfo}>
		<ul>
			<li>Время работы: Пн-Пт с 10:00-17:00</li>
			<li>Время готового к выдачи заказа Вам сообщит менеджер, после оформления заказа.</li>
		</ul>
	</div>
	{selfopt:}{data.order.transport.self=.?:selected} value="{.}" 
	{selfinfo:}style="display:{data.order.transport.self=.??:none}" data-value="{.}" class="alert border"
	{Центральный:}Центральный
	{Мадагаскар:}Мадагаскар
	{8 кв:}8 кв
	{selected:}selected
	{none:}none
{MEN:}
	<h1>Курьерская доставка</h1>
	<div class="more alert border">
		<div class="d-flex">
			<div class="mr-3 d-none d-sm-block">
				<img src="/-imager/?w=100&src=-cart/images/men.png">
			</div>
			<div class="flex-grow-1">
				<ul>
					<li>Стоимость доставки зависит от веса, габаритов и расстояния перевозки из г. Тольятти.</li>
					<li>Возможна оплата заказа при получеии (наложенный платёж)</li>
					<li>Ограничения по весу и габаритам, в зависимости от выбора службы доставки.</li>
				</ul>
				{:whencost}
			</div>
		</div>
	</div>
	<div class="row">
		<div class="col-sm-12">
			<div class="form-group">
				<label>Служба доставки <span class="req">*</span></label>
				<select {:isdisabled} onchange="
					var row = $(this).parents('.row:first');
					row.find('[data-value]').hide();
					row.find('[data-value=\''+this.value+'\']').fadeIn();
				" {:isdisabled} value="{transport.courier}" name="transport.courier" class="custom-select form-control">
					<option></option>
					<option {(:СДЭК):curopt}>Доставка курьером СДЭК</option>
					<option {(:EMS):curopt}>Доставка курьером EMS (Почта России)</option>
					<option {(:Курьер):curopt}>Доставка курьером по г. Тольятти</option>
				</select>
			</div>
		</div>
		<div class="col-sm-12">
			<div {(:СДЭК):curinfo}>
				<ul>
					<li>Стоимость доставки от 310 руб. в зависимости от веса, габаритов и расстояния перевозки из г. Тольятти</li>
					<li>Возможна оплата заказа при получении.</li>
					<li>Ограничения по весу и габаритам: не более 29 кг; длина, ширина, высота - не более 150 см, сумма сторон < 450 см</li>
				</ul>
				{:whencost}
			</div>
			<div {(:EMS):curinfo}>
				<ul>
					<li>Стоимость доставки от 430 руб. в зависимости от веса, габаритов и расстояния перевозки из г. Тольятти</li>
					<li>Возможна оплата заказа при получении.</li>
					<li>Ограничения по весу и габаритам: не более 30 кг; длина, ширина, высота - не более 150 см, сумма сторон < 300 см</li>
				</ul>
				{:whencost}
			</div>
			<div {(:Курьер):curinfo}>
				<ul>
					<li>Стоимость доставки от 0 руб. в зависимости от веса, габаритов и расстояния перевозки.</li>
					<li>Возможна оплата заказа при получении.</li>
				</ul>
				{:whencost}
			</div>
		</div>
		{~obj(:title,:Почтовый индекс,:name,:index):inp}
		{~obj(:title,:Регион,:name,:region):inp}
		{~obj(:title,:Город/Населённый пункт,:name,:city):inp}
		{~obj(:title,:Улица,:name,:street):inp}
		{~obj(:title,:Дом,:name,:house):inp}
		{~obj(:title,:Квартира/офис,:name,:kv):inp}
	</div>
	{curopt:}{data.order.transport.courier=.?:selected} value="{.}" 
	{curinfo:}style="display:{data.order.transport.courier=.??:none}" data-value="{.}" class="alert border"
	{Курьер:}Курьер
	{EMS:}EMS
	{СДЭК:}СДЭК
{inp:}
	<div class="{:col}">
		<div class="form-group">
			<label>{title} <span class="req">*</span></label>
			<input {:isdisabled} type="text" name="transport.{name}" value="{data.order.transport[name]}" class="form-control">
		</div>
	</div>
{isdisabled:}{data.order.rule.edit[data.place]|:disabled}
{disabled:}disabled
	
{maininputs:}
	{~obj(:title,:Почтовый индекс,:name,:index):inp}
	{~obj(:title,:Регион,:name,:region):inp}
	{~obj(:title,:Город/Населённый пункт,:name,:city):inp}
	{~obj(:title,:Улица,:name,:street):inp}
	{~obj(:title,:Дом,:name,:house):inp}
	{~obj(:title,:Квартира/офис,:name,:kv):inp}
{pochtamore:}
	<div class="more alert border">
		<div class="d-flex">
			<div class="mr-3 d-none d-sm-block">
				<img src="/-imager/?w=100&src=-cart/images/pochtabig.png">
			</div>
			<div class="flex-grow-1">
				<ul>
					<li>Возможна оплата заказа при получении (наложенным платежём)</li>
					<li>Ограничения по весу, не более 20 кг</li>
				</ul>
				{:whencost}
			</div>
		</div>
	</div>
{whencost:}
	<i>Точную стоимость доставки вам сообщит менеджер после оформления заказа</i>
{PAYRECIVE:}Оплата в момент получения товара
{PAYCHECK:}Реквизиты сообщит менеджер после оформления заказа
{PAYSBER:}{:PAYCHECK}
{PAYYANDEX:}{:PAYCHECK}
{PAYTINKOFF:}{:PAYCHECK}
{PAYQIWI:}{:PAYCHECK}