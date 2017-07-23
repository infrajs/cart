<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\path\Path;
use infrajs\config\Config;
use infrajs\session\Session;
use infrajs\access\Access;
use infrajs\user\User;
use infrajs\each\Fix;

if (!is_file('vendor/autoload.php')) {
	chdir(explode('vendor/', __DIR__)[0]);
	require_once('vendor/autoload.php');
	Router::init();
}

$ans = array();
$id = Ans::REQ('id','int');
$orderid = $id;
//$ans['id'] = $id;

$rules = Load::loadJSON('-cart/rules.json');
$allactions = array_keys($rules['actions']);
$action = Ans::REQ('type', $allactions);
if (!$action) return Ans::err($ans, 'Указан незарегистрированный Action');

$ans['action'] = $action;
$act = $rules['actions'][$action];

$place = Ans::REQ('place');
$ans['place'] = $place;
$conf = Config::get('cart');

if ($action == 'wholesaleDelete') {	
	if (!Session::get('safe.manager')) return Ans::err($ans, 'У вас нет доступа!');
	$email = $id;
	$data = Load::loadJSON('~cart/merchants.json');
	unset($data['merchants'][$email]);
	file_put_contents(Path::resolve('~cart/merchants.json'), Load::json_encode($data));
	return Ans::ret($ans);
}


//Заявка принадлежит тому человеку, который первым изменил её статус с активного на какой-то
//Передать заявку может и можно, но сумма по заявке будет всегда принадлежать первому человеку
$ans['order'] = array('id' => $id);
if (!Cart::canI($id, $action)) return Ans::err($ans, 'У вас нет доступа на совершение действия '.$action.' с заявкой '.$id.'!');
$order = Cart::loadOrder($id);
if (!$order) return Ans::err($ans, 'Заявка '.$id.' не найдена');
$status = $order['status'];
//На проверку может отправить и менеджер и пользователь, менедежр не может активную отправить на проверку
//Если в текущем статусе были разрешены изменения, значит нужно проверить введёные данные
//Если изменения не разрешены, значит нужно чтобы они не применялись из сессии
//Изменения могут быть порциональными, тут можно тут нельзя, ???
//Изменять статус можно и без строкой проверки данных, сохранить можно любые данные? Это касается только saved


$rule = Cart::getRule($order);


if (Session::get('safe.manager') || !empty($rule['edit'][$place])) { //Place - orders admin wholesale
	Cart::mergeOrder($order, $place);
}

$ans['order'] = $order;
if (!empty($act['checkdata']) && !empty($rule['edit'][$place])) {
	$email = empty($order['email']) ? null : $order['email'];
	$msg = User::checkReg($email);
	if (is_string($msg)) return Ans::err($ans,$msg);
	//Действие требует проверку данных и текущий стату заявки разрешает редактирование, соответственно можно применит ьданные
	if (empty($order['basket'])) return Ans::err($ans, 'Заявк пустая! Добавьте товар!');
	$page = '';
	if (empty($order['phone'])||!User::checkData($order['phone'],'value')) return Ans::err($ans, 'Укажите корректный телефон'.$page);
	if (empty($order['name'])||!User::checkData($order['name'],'value')) return Ans::err($ans, 'Укажите корректное имя контактного лица'.$page);
	if (!empty($conf['pay'])) {
		if (!User::checkData($order['entity'],'radio')) return Ans::err($ans, 'Укажите кто будет оплачивать'.$page);
		if (!User::checkData($order['paymenttype'],'radio')) return Ans::err($ans, 'Укажите способ оплаты'.$page);
		if ($order['entity'] == 'legal') {
			if (!User::checkData($order['details'],'radio')) return Ans::err($ans, 'Необходимо заполнить реквизиты'.$page);
			if ($order['details'] == 'allentity') {
				if (!User::checkData($order['allentity'],'value')) return Ans::err($ans, 'Необходимо указать реквизиты'.$page);
			} else {
				if (!User::checkData($order['company'],'value')) return Ans::err($ans, 'Укажите название юр.лица'.$page);
				if (!User::checkData($order['inn'],'value')) return Ans::err($ans, 'Укажите ИНН'.$page);
				if (!User::checkData($order['addreslegal'],'value')) return Ans::err($ans, 'Укажите адрес юр.лица'.$page);
				if (!User::checkData($order['addrespochta'],'value')) return Ans::err($ans, 'Укажите почтовый адрес юр.лица'.$page);
			}
		}
	}
	if ($conf['delivery']) {
		if (!User::checkData($order['delivery'],'radio')) return Ans::err($ans, 'Укажите способ доставки'.$page);
		if ($order['delivery'] == 'delivery') {
			if (!User::checkData($order['addresdelivery'],'value')) return Ans::err($ans, 'Укажите адрес доставки'.$page);
		}
	}
}



if ($action == 'saved') {
	$order['status'] = 'saved';
	Cart::saveOrder($order, $place);
	if ($status == 'active') {
		Session::set('order.my.basket');//Очистили Текущую активную заявку
		Session::set('order.my.id');
		Session::set('order.my.fixid');
		Session::set('order.my.copyid');
		Session::set('order.my.time');
		Session::set('order.my.manage');
	}
} else if ($action == 'removechanges') {
	if ($order['status'] == 'active') return Ans::err($ans, 'У активной заявки нельзя отменить изменения');
	//Если я user нужно удалить user{id} сессию иначе надо удалить manager{id} сессию 
	//Нужно знать с какого места осуществлён вызов чтобы определит что делать
	if ($place == 'admin'&&!Session::get('safe.manager')) return Ans::err($ans, 'У вас нет доступа!');
	Session::set($place.$id);
} else if ($action == 'refresh') {//Обновить данные из каталога
	Each::foro($order['basket'],function(&$pos) {
		unset($pos['article']);//Если нет артикула данные при сохранении обновятся
	});
	Cart::saveOrder($order, $place);
} else if($action == 'sync') {
	$msg = Cart::sync($place, $orderid);
} else if($action == 'email') {
	$order['emailtime'] = time();
	Cart::saveOrder($order, $place);
} else if ($action == 'setPaid') {//Обновить данные из каталога
	$ogood = Cart::getGoodOrder($orderid);
	if ($order['manage']['paid']) return Ans::err($ans, 'По заявке '.$id.' уже есть отметка об оплате');
	$order['manage']['paid'] = $ogood['alltotal'];
	$order['manage']['paidtime']=time();
	$order['manage']['paidtype']='manager';
	Cart::saveOrder($order, $place);
} else if ($action == 'savechanges') {
	Cart::saveOrder($order, $place);//К order применились изменения и после сохранения эти изменения будут доступны другим
} else if ($action == 'check') {
	$order['status'] = 'check';
	Cart::saveOrder($order, $place);
	if ($status == 'active') {
		Session::set('order.my.basket');//Очистили заявку
		Session::set('order.my.id');
		Session::set('order.my.fixid');
		Session::set('order.my.copyid');
		Session::set('order.my.time');
		Session::set('order.my.manage');
	}
} else if ($action == 'remove') {
	$prodart = Ans::REQ('prodart');
	if (!$prodart) return Ans::err($ans, 'Требуется параметр prodart');
	unset($order['basket'][$prodart]);
	Cart::saveOrder($order, $place);
} else if ($action == 'active') {
	
	/*$noworder = Cart::loadOrder();
	if (!empty($noworder['basket'])) {
		return Ans::err($ans,
			'У вас уже есть <a onclick="cart.goTop(); popup.close()" href="/cart/orders/my">активная непустая заявка</a>.<br>
			Чтобы сделать заявку активной нужно<br>
			очистить или сохранить текущую активную заявку!');
	}*/
	//Текущую заявку просто грохаем
	
	$order['status'] = 'active';
	Cart::saveOrder($order, $place);
} else if ($action == 'copy') {

	$noworder = Cart::loadOrder();
	if ($noworder['basket']) {
		return Ans::err($ans,
			'У вас уже есть <a onclick="Popup.close()" href="/cart/orders/my">активная непустая заявка</a>.<br>
			Чтобы сделать копию заявки нужно<br>
			очистить или сохранить текущую активную заявку!');
	}

	$order['copyid']=$order['id'];
	unset($order['fixid']);
	unset($order['id']);
	unset($order['manage']);

	$order['status'] = 'active';
	Cart::saveOrder($order, $place);

} else if ($action == 'delete') {
	
	$path = Cart::getPath($id);
	$src = Path::theme($path);
	if ($src) {
		$dir = Path::theme(Cart::getPath());
		$r = rename($src, $dir.'deleted/'.$id.'.json');
		if (!$r) return Ans::err($ans, 'Неудалось удалить заявку');
	}


	$myorders = Session::get('safe.orders', array());
	Each::exec($myorders, function ($id) use ($order) {
		if ($order['id'] == $id) return new Fix('del',true);
	});
	

} else if ($action == 'realdel') {
	
	$myorders = Session::get('safe.orders', array());
	Each::exec($myorders, function ($id) use ($order) {
		if ($order['id'] == $id) return new Fix('del',true);
	});
	
	$path = Cart::getPath($id);
	$src = Path::theme($path);
	if ($src) unlink($src);

} else if ($action == 'clear') {
	if (!$order['basket']) return Ans::err($ans, 'Корзина уже пустая');
	unset($order['basket']);
	if ($order['status'] == 'active') {
		Session::set('order.my.basket');
	} else {
		Cart::saveOrder($order, $place);
	} 
} else if ($action == 'refuseable') {
	$order['status'] = 'refunds';
	Cart::saveOrder($order, $place);
} else if ($action == 'editcart') {
	if (!$id) return Ans::err($ans, 'Нельзя активную заявку сделать активной');
	$ans = Load::loadJSON('-cart/action.php?place='.$place.'&id='.$id.'&type=active');
	if (!$ans['result']) return Ans::ans($ans);
	$order = Cart::loadOrder();//Активную заявку сделать активной нельзя... был id а тут его нет
} else if (in_array($action, ['complete', 'delivery', 'picked', 'dismiss', 'execution', 'wait', 'ready'])) {
	$order['status'] = $action;
	Cart::saveOrder($order, $place);
}
$ans['order'] = $order;
return Cart::ret($ans, $action);
