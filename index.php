<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\user\User;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\path\Path;
use infrajs\access\Access;
use infrajs\session\Session;
use infrajs\sequence\Sequence;

Nostore::on();
$ans = array();
$type = Ans::REQ('type', ['sync', 'orders','order','list','cart','user','admin']);
if (!$type) return Ans::err($ans, 'Указан неправильный параметр type');
$place = Ans::REQ('place',['orders', 'admin'], 'orders');
$ans['place'] = $place;
$ans['type'] = $type;
$orderid = Ans::REQ('id');
if ($orderid == 'my') $orderid = '';


if (!Cart::canI($orderid)) return Ans::err($ans,'Действие не разрешено!');
//Session::set(['safe','orders'],['1473553045','1473369982']);
if ($type == 'user') {
	$ans = User::get();
	$ans['manager'] = Session::get('safe.manager');
} else if ($type == 'cart') {
	if (Ans::REQ('submit')) {
		$ans = array('msg'=>'','result'=>0);
		
		if (Access::admin() && Session::getEmail()) {
			if ($_REQUEST['IAmManager']) {
				Session::set('safe.manager', true);
			} else {
				Session::set('safe.manager', false);
			}
			return Ans::ret($ans);
		}else{
			return Ans::err($ans,'У вас недостаточно прав!');
		}
	}
	$orders = Cart::getMyOrders();
	$order = Cart::getGoodOrder();
	$ans['order']=$order;
	$list=array();
	Each::forr($orders, function &($order) use(&$list){
		$r = null;
		$status=$order['status'];
		if (empty($list[$status])) $list[$status] = array();
		$list[$status][]=array(
			'id'=>$order['id'],
			'time'=>$order['time']
		);
		return $r;
	});
	$ans['rules'] = Load::loadJSON('-cart/rules.json');
	$ans['list']=$list;
	$ans['admin']=Access::admin();
	$ans['email']=Session::getEmail();
	$ans['manager']=Session::get('safe.manager');
} else if ($type == 'order') {
	if ($orderid) {
		//работаем с сохранённой заявкой
		$order = Cart::getGoodOrder($orderid);
		if ($order['status'] != 'active') {
			if (!$order) return Ans::err($ans, 'Заявка не найдена!');
			if (!Session::get('safe.manager') && !Cart::isMy($orderid)) return Ans::err($ans, 'Заявки нет в списке ваших заявок!');
			$ans['order'] = $order;
		} else {
			$orderid = false;
		}
	} 

	if (!$orderid) {
		// работаем с активной заявкой
		$order = Cart::getGoodOrder();
		$ans['order'] = $order;
	}
	if (Session::getId()) {
		$ans['user'] = User::get();
	}
	
	$ans['messages'] = Load::loadJSON('~cart/messages.json');
	if (!$ans['messages']) $ans['messages'] = Load::loadJSON('-cart/messages.json');

	$ans['manager'] = Session::get('safe.manager'); 
} else if ($type == 'admin') {
	if (!Session::get('safe.manager')) return Ans::err($ans, 'У вас нет доступа к этому разделу. Вы не являетесь Менеджером.');

	if ($orderid) {
		$ans['id'] = $orderid;
		$order = Cart::getGoodOrder($orderid);
		if (!$order) return Ans::err($ans, 'Заявка '.$orderid.' не найдена');
		$order['place'] = $place;	
		$ans['order'] = $order;
		return Ans::ret($ans);
	} else {
		$orders = array();
		$src = Cart::getPath();
		$src = Path::theme($src);
		$file_list = glob($src."*");
		$rules = Cart::getRule();

		$isall = Ans::GET('all','bool');
		foreach ($file_list as $file){
			$f = Load::srcinfo($file);
			if ($f['ext'] !=='json') continue;
			$id = $f['name'];
			$order = Cart::getGoodOrder($id);
			
			if (!$isall && !in_array($order['status'], $rules['list'])) continue;

			$order['place'] = $place;

			$orders[] = $order;
		}
		usort($orders, function ($o1, $o2) {
			if($o2['time'] > $o1['time']) return 1;
		});
		$ans = array("products" => $orders);
		return Ans::ret($ans);
	}
} else if ($type == 'orders') {
	$ans['order'] = Cart::getGoodOrder();
	$ans['orders'] = Cart::getMyOrders();
} else if ($type == 'list') {	
	$ans['id'] = $orderid;
	if ($orderid == 'my') $orderid = '';
	
	$ans['place'] = $place;


	$order = Cart::loadOrder($orderid);	
	
	$add = Ans::GET('add');
	if ($add) {
		$right = array('basket',$add,'count');
		$val = 1;
		if (!Sequence::get($order, $right)) {
			Sequence::set($order, $right, $val);
			Cart::saveOrder($order, $place);
		}
	}
	
	if (!$order) return Ans::err($ans,'Заявка не найдена!');
	
	if (!Session::get('safe.manager') && !Cart::isMy($orderid)) return Ans::err($ans,'Заявки нет в списке ваших заявок!');
	if (!Session::get('safe.manager') && $place == 'admin') return Ans::err($ans,'У вас нет доступа к этому разделу!');

	Cart::sync($place, $orderid);
	
	//Заява либо моя либо это менеджер
	if (!isset($_GET['easy'])){
		$order = Cart::getGoodOrder($order);
		if (!Session::get('safe.manager') && empty($order['rule']['edit'][$place])) return Ans::err($ans,'Редактировать заявку в текущем статусе нельзя. '.$order['rule']['title'].'!');
		$order['place'] = $place;
		$order['user'] = Load::loadJSON('-cart/?type=user');
		$order['ismy'] = Cart::isMy($orderid);
	}
	$ans['order'] = $order;
}
return Ans::ret($ans);