<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\user\User;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\access\Access;
use infrajs\session\Session;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}

Nostore::on();

$type = Ans::GET('type', 'string', false);
if (!$type) return Ans::err($ans, 'Требуется параметр type');

if ($type == 'user') {
	$ans = User::get();
	$ans['manager'] = Session::get('safe.manager');
	return Ans::ret($ans);
} else if ($type == 'cart') {
	if ($_REQUEST['submit']) {
		$ans = array('msg'=>'','result'=>0);
		
		if (Access::admin() && Session::getEmail()) {
			if($_REQUEST['IAmManager'])
				Session::set('safe.manager',true);
			else
				Session::set('safe.manager',false);
			return Ans::ret($ans);
		}else{
			return Ans::err($ans,'У вас недостаточно прав!');
		}
	}
	$orders = Cart::getMyOrders();
	$order = Cart::getGoodOrder();
	$ans['order']=$order;
	$list=array();
	Each::forr($orders,function($order) use(&$list){
		$status=$order['status'];
		if(!$list[$status])$list[$status]=array();
		$list[$status][]=array(
			'id'=>$order['id'],
			'time'=>$order['time']
		);
	});
	$ans['rules']=Load::loadJSON('*cart/rules.json');
	$ans['list']=$list;
	$ans['admin']=Access::admin();
	$ans['email']=Session::getEmail();
	$ans['manager']=Session::get('safe.manager');

	return Ans::ret($ans);
} else if ($type == 'orders') {
	
	$ans = array();
	$ans['id'] = $id = Ans::REQ('id','int');
	if ($id) {
		if (!$id) {
			// работаем с активной заявкой
			$order = Cart::getGoodOrder();
			$ans['order'] = $order;
			return Ans::ret($ans);
		}else{
			//работаем с сохранённой заявкой
			$order = Cart::getGoodOrder($id);
			if (!$order) return Ans::err($ans, 'Заявка не найдена!');
			if (!Session::get('safe.manager') && !Cart::isMy($id)) return Ans::err($ans, 'Заявки нет в списке ваших заявок!');
			return Ans::ret($order);
		}
	}
	$ans = array();	
	$ans['order'] = Cart::getGoodOrder();
	$ans['list'] = Cart::getMyOrders();
	
	return Ans::ret($ans);
} else if ($type == 'list') {

	$ans = array();
	$id = Ans::REQ('id');
	$ans['id'] = $id;
	if ($id == 'my') $id = null;
	$place = Ans::REQ('place',['orders', 'admin']);
	$ans['place'] = $place;
	
	if (!Cart::loadOrder($id)) return Ans::err($ans,'Заявка не найдена!');
	if (!Session::get('safe.manager') && !Cart::isMy($id)) return Ans::err($ans,'Заявки нет в списке ваших заявок!');
	if (!Session::get('safe.manager') && $place == 'admin') return Ans::err($ans,'У вас нет доступа к этому разделу!');
	if (!Cart::canI($id)) return Ans::err($ans,'Действие не разрешено!');

	//Заява либо моя либо это менеджер
	if (isset($_GET['easy'])){
		$order = Cart::loadOrder($id);
	} else {
		$order = Cart::getGoodOrder($id);
		$order['place'] = $place;
		$order['user'] = Load::loadJSON('-cart/?type=user');
		$order['ismy'] = Cart::isMy($id);
	}
	return Ans::ret($order, 'Ваша заявка');
}
return Ans::err($ans, 'Передан незарегистрированный type');